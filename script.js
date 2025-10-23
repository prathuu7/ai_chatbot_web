async function sendMessage() {
    const input = document.getElementById("userInput");
    const message = input.value;
    input.value = "";

    const response = await fetch("/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: message })
    });
    const data = await response.json();

    const chatbox = document.getElementById("chatbox");
    chatbox.innerHTML += `<p><b>You:</b> ${message}</p>`;
    chatbox.innerHTML += `<p><b>Bot:</b> ${data.response}</p>`;
}
