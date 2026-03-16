import urllib.request
import json
from gradio_client import Client, handle_file

urllib.request.urlretrieve('https://upload.wikimedia.org/wikipedia/commons/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg', 'human.jpg')
urllib.request.urlretrieve('https://upload.wikimedia.org/wikipedia/commons/2/24/Blue_Tshirt.jpg', 'garment.jpg')

try:
    client = Client("levihsu/OOTDiffusion")
    result = client.predict(
        vton_img=handle_file('human.jpg'),
        garm_img=handle_file('garment.jpg'),
        category="Upper-body",
        n_samples=1,
        n_steps=20,
        image_scale=2,
        seed=-1,
        api_name="/process_dc"
    )
    print("Success Result:", result)
except Exception as e:
    print("Caught Error:", e)
