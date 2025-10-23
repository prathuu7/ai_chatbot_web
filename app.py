from flask import Flask, request, jsonify, render_template_string
import requests
import datetime

app = Flask(__name__)

import os
PERPLEXITY_API_KEY = os.getenv("PPLX_API_KEY")

def home():
    with open("index.html", "r") as f:
        return f.read()

@app.route('/chat', methods=['POST'])
def chat():
    user_message = request.json.get("message", "")
    date_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    headers = {
        "Authorization": f"Bearer {PERPLEXITY_API_KEY}",
        "Content-Type": "application/json"
    }

    data = {
        "model": "sonar-medium-online",
        "messages": [{"role": "user", "content": f"{user_message} (Current time: {date_time})"}]
    }

    r = requests.post("https://api.perplexity.ai/chat/completions", headers=headers, json=data)

    try:
        reply = r.json()['choices'][0]['message']['content']
    except:
        reply = "Sorry, I couldn’t get that."

    return jsonify({"reply": reply})

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)
