# ===== Render Deployment Script =====
# CHANGE THESE VARIABLES
$GITHUB_USERNAME = "prathuu2"         # Your GitHub username
$REPO_NAME = "ai_chatbot_web"              # Your repo name
$RENDER_API_KEY = "rnd_P2jrOvEAWLZb5XqUFRIR1Cp76fDK"    # Get from https://dashboard.render.com/api-keys
# The API key will be set in Render's dashboard as an environment variable

# API Endpoint
$renderApi = "https://api.render.com/v1/services"

# JSON body for Render service
$body = @{
    name = $REPO_NAME
    type = "web_service"
    repo = "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    branch = "main"
    env = "python"
    plan = "free"
    envVars = @(@{ key = "PERPLEXITY_API_KEY"; value = $PPLX_API_KEY; sync = $true })
    buildCommand = "pip install -r requirements.txt"
    startCommand = "gunicorn app:app"
} | ConvertTo-Json -Depth 10

# Create Render service
$response = Invoke-RestMethod -Uri $renderApi -Method Post -Headers @{ "Authorization" = "Bearer $RENDER_API_KEY"; "Content-Type" = "application/json" } -Body $body

Write-Host "✅ Render service created!"
Write-Host "Service URL: $($response.serviceDetails.url)"
