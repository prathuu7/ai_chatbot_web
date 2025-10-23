from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

# Hugging Face API Key (we'll inject it from Render env vars)
import os
HF_API_KEY = os.getenv("HF_API_KEY")
MODEL_URL = "https://api-inference.huggingface.co/models/gpt2"  # Free GPT-2 model (or you can pick another HF model)

headers = {"Authorization": f"Bearer {HF_API_KEY}"}

@app.route("/chat", methods=["POST"])
def chat():
    user_input = request.json.get("message", "")
    data = {"inputs": user_input}

    try:
        response = requests.post(MODEL_URL, headers=headers, json=data)
        text = response.json()[0]["generated_text"]
    except Exception as e:
        text = "Sorry, I couldn't generate a response."

    return jsonify({"response": text})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
