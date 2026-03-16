const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const FormData = require("form-data");
const crypto = require("crypto");
// Replace with your real Stripe Secret Key. For production this should ideally be in Firebase config.
const stripe = require("stripe")("sk_test_51T2sfBPAvUbK5SvGvFpgYxREzlxe6uJ8EvY9Op8bow7qKURcB3MHxwCMp1eudweTNsvq91UtMskx3aPodm9bMm5V00MdXiALTY");

admin.initializeApp();

// ─────────────────────────────────────────────────────────────────────────────
// IDM-VTON via HuggingFace Spaces Gradio API — 100% FREE, no API key needed.
//
//   Space:  https://huggingface.co/spaces/yisol/IDM-VTON
//   Model:  IDM-VTON (Improving Diffusion Models for Authentic Virtual Try-on)
//   Cost:   $0.00 — runs on HuggingFace ZeroGPU public queue
//   Wait:   ~1–4 minutes in queue
// ─────────────────────────────────────────────────────────────────────────────
const HF_SPACE_URL = "https://yisol-idm-vton.hf.space";

// ── Helpers ──────────────────────────────────────────────────────────────────

/** Random 16-char hex string used as Gradio session_hash */
function randomHash() {
  return crypto.randomBytes(8).toString("hex");
}

/** Download an image from a URL and return it as a Buffer */
async function downloadImage(url) {
  const res = await axios.get(url, { responseType: "arraybuffer", timeout: 30000 });
  return Buffer.from(res.data);
}

/**
 * Upload a Buffer to the HF Gradio Space /upload endpoint.
 * Returns the server-side file path (e.g. "tmp/abc123.jpg").
 */
async function uploadToGradio(buffer, filename) {
  const form = new FormData();
  form.append("files", buffer, { filename, contentType: "image/jpeg" });

  const res = await axios.post(`${HF_SPACE_URL}/upload`, form, {
    headers: form.getHeaders(),
    timeout: 30000,
  });

  // Response is an array of file paths
  return res.data[0];
}

/**
 * Build Gradio FileData object from a server-side path.
 * IDM-VTON inputs expect this structure for image fields.
 */
function makeFileData(path, name) {
  return {
    path,
    url: `${HF_SPACE_URL}/file=${path}`,
    size: null,
    orig_name: name,
    mime_type: "image/jpeg",
    is_stream: false,
    meta: { _type: "gradio.FileData" },
  };
}

// ── Cloud Functions ───────────────────────────────────────────────────────────

/**
 * initiateTryOn
 * Expects: { human_image_url, garment_image_url, category }
 * Returns: { predictionId, sessionHash }
 */
exports.initiateTryOn = functions
  .runWith({ timeoutSeconds: 120 })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Must be logged in.");
    }

    const { human_image_url, garment_image_url, category } = data;
    if (!human_image_url || !garment_image_url) {
      throw new functions.https.HttpsError("invalid-argument", "Missing image URLs.");
    }

    // Map category to garment description text used by IDM-VTON
    const garmentDesc =
      category === "bottoms"
        ? "lower body clothing"
        : category === "one-pieces"
        ? "full body clothing"
        : "upper body clothing";

    try {
      // 1. Download both images in parallel
      console.log("[initiateTryOn] Downloading images...");
      const [humanBuf, garmentBuf] = await Promise.all([
        downloadImage(human_image_url),
        downloadImage(garment_image_url),
      ]);

      // 2. Upload to HF Gradio Space in parallel
      console.log("[initiateTryOn] Uploading to HF Space...");
      const [humanPath, garmentPath] = await Promise.all([
        uploadToGradio(humanBuf, "human.jpg"),
        uploadToGradio(garmentBuf, "garment.jpg"),
      ]);

      const sessionHash = randomHash();
      const seed = Math.floor(Math.random() * 100000);

      // 3. Submit prediction to Gradio queue
      //    fn_index 0 = /tryon named endpoint (the only endpoint in this Space)
      //    Inputs match the IDM-VTON Gradio interface signature:
      //      [human_img (ImageEditor), garm_img, garment_des,
      //       is_checked, is_checked_crop, denoise_steps, seed]
      console.log("[initiateTryOn] Submitting to queue, session:", sessionHash);
      const joinRes = await axios.post(
        `${HF_SPACE_URL}/queue/join`,
        {
          data: [
            {
              background: makeFileData(humanPath, "human.jpg"),
              layers: [],
              composite: null,
            },
            makeFileData(garmentPath, "garment.jpg"),
            garmentDesc,
            true,   // is_checked  — use auto-masking
            false,  // is_checked_crop — no auto-crop
            40,     // denoise_steps — increased for better quality
            seed,   // random seed
          ],
          event_data: null,
          fn_index: 0, // fn_index 0 = /tryon named endpoint (only endpoint)
          trigger_id: 6,
          session_hash: sessionHash,
        },
        {
          headers: { "Content-Type": "application/json" },
          timeout: 30000,
        }
      );

      const eventId = joinRes.data.event_id;
      console.log("[initiateTryOn] Queued — event_id:", eventId);

      return { predictionId: eventId, sessionHash };
    } catch (error) {
      console.error("[initiateTryOn] Error:", error.response?.data || error.message);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to start try-on: " + (error.response?.data?.detail || error.message)
      );
    }
  });

/**
 * getTryOnStatus
 * Expects: { predictionId, sessionHash }
 * Returns: { status, outputUrl? }
 *   status: "processing" | "completed" | "failed"
 */
exports.getTryOnStatus = functions
  .runWith({ timeoutSeconds: 60 })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Must be logged in.");
    }

    const { predictionId, sessionHash } = data;
    if (!sessionHash) {
      throw new functions.https.HttpsError("invalid-argument", "Missing sessionHash.");
    }

    try {
      // Open the SSE stream and read for up to 12 seconds.
      // If process_completed arrives → return result immediately.
      // If timeout → return "processing" (Flutter will poll again in 3s).
      const sseData = await new Promise((resolve, reject) => {
        let accumulated = "";

        axios
          .get(`${HF_SPACE_URL}/queue/data?session_hash=${sessionHash}`, {
            headers: { Accept: "text/event-stream" },
            responseType: "stream",
            timeout: 15000,
          })
          .then((res) => {
            // Kill the stream after 12 seconds whether or not we got a result
            const killTimer = setTimeout(() => {
              res.data.destroy();
              resolve(accumulated);
            }, 12000);

            res.data.on("data", (chunk) => {
              accumulated += chunk.toString();
              // Short-circuit as soon as we see the completion event
              if (
                accumulated.includes('"process_completed"') ||
                accumulated.includes('"process_errored"') ||
                accumulated.includes('"queue_full"')
              ) {
                clearTimeout(killTimer);
                res.data.destroy();
                resolve(accumulated);
              }
            });

            res.data.on("end", () => {
              clearTimeout(killTimer);
              resolve(accumulated);
            });

            res.data.on("error", () => {
              clearTimeout(killTimer);
              resolve(accumulated); // Return whatever we collected
            });
          })
          .catch((err) => {
            // If axios itself times out or errors, treat as still processing
            resolve(accumulated);
          });
      });

      // Parse SSE blocks
      const blocks = sseData.split("\n\n");
      for (const block of blocks) {
        const dataLine = block.split("\n").find((l) => l.startsWith("data:"));
        if (!dataLine) continue;

        let event;
        try {
          event = JSON.parse(dataLine.slice(5).trim());
        } catch {
          continue;
        }

        if (event.msg === "process_completed") {
          // data[0] = try-on image, data[1] = masked image
          const rawOutput = event.output?.data?.[0];
          let outputUrl = null;

          if (typeof rawOutput === "string" && rawOutput.length > 0) {
            outputUrl = rawOutput;
          } else if (rawOutput && typeof rawOutput === "object") {
            // Gradio often returns url: null even when path is populated.
            // Always prefer constructing from path for reliability.
            if (rawOutput.path) {
              outputUrl = `${HF_SPACE_URL}/file=${rawOutput.path}`;
            } else if (rawOutput.url) {
              outputUrl = rawOutput.url;
            }
          }

          if (outputUrl) {
            console.log("[getTryOnStatus] Completed:", outputUrl);
            return { status: "completed", outputUrl };
          }
          return { status: "failed", error: "No output URL in result" };
        }

        if (event.msg === "process_errored" || event.msg === "queue_full") {
          console.error("[getTryOnStatus] Failed:", event.msg);
          return { status: "failed", error: event.msg };
        }

        // Log queue position for debugging
        if (event.msg === "estimation" && event.rank !== undefined) {
          console.log("[getTryOnStatus] Queue position:", event.rank);
        }
      }

      // No completion event yet — still in queue or processing
      return { status: "processing" };
    } catch (error) {
      console.error("[getTryOnStatus] Error:", error.message);
      throw new functions.https.HttpsError("internal", "Failed to check status.");
    }
  });

// ─────────────────────────────────────────────────────────────────────────────
// STRIPE INTEGRATION
// Creates a PaymentIntent and returns the client_secret securely to the app.
// ─────────────────────────────────────────────────────────────────────────────
exports.createStripePaymentIntent = functions
  .runWith({ timeoutSeconds: 60 })
  .https.onCall(async (data, context) => {
      // You can add context.auth checking here if you want to force login
      const { amount, currency } = data;
      
      if (!amount) {
          throw new functions.https.HttpsError("invalid-argument", "Missing payment amount.");
      }

      try {
          const paymentIntent = await stripe.paymentIntents.create({
              amount: parseInt(amount, 10), // amount in cents/paise
              currency: currency || "INR",
              automatic_payment_methods: {
                enabled: true,
              },
          });

          return {
              client_secret: paymentIntent.client_secret,
          };
      } catch (error) {
          console.error("[CreateStripePaymentIntent] Error:", error.message);
          throw new functions.https.HttpsError("internal", "Unable to create payment intent.");
      }
  });Status] Failed:", event.msg);
          return { status: "failed", error: event.msg };
        }

        // Log queue position for debugging
        if (event.msg === "estimation" && event.rank !== undefined) {
          console.log("[getTryOnStatus] Queue position:", event.rank);
        }
      }

      // No completion event yet — still in queue or processing
      return { status: "processing" };
    } catch (error) {
      console.error("[getTryOnStatus] Error:", error.message);
      throw new functions.https.HttpsError("internal", "Failed to check status.");
    }
  });
