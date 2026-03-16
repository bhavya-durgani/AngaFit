import requests

def download_image(url, filename):
    response = requests.get(url)
    if response.status_code == 200:
        with open(filename, 'wb') as f:
            f.write(response.content)

download_image("https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png", "human.png")
download_image("https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png", "garment.png")

from gradio_client import Client, handle_file

print("Initializing client...")
client = Client("levihsu/OOTDiffusion")
print("Client initialized. Predicting...")

try:
    result = client.predict(
        vton_img=handle_file('human.png'),
        garm_img=handle_file('garment.png'),
        n_samples=1,
        n_steps=20,
        image_scale=2.0,
        seed=-1,
        api_name="/process_hd"
    )
    print("Result HD:", result)
except Exception as e:
    print("Error in /process_hd:", e)

try:
    result_dc = client.predict(
        vton_img=handle_file('human.png'),
        garm_img=handle_file('garment.png'),
        category="Upper-body",
        n_samples=1,
        n_steps=20,
        image_scale=2.0,
        seed=-1,
        api_name="/process_dc"
    )
    print("Result DC:", result_dc)
except Exception as e:
    print("Error in /process_dc:", e)

