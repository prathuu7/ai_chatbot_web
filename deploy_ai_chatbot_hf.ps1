# -------------------------
# AI Chatbot Deployment
# -------------------------

# Project info
$GITHUB_USERNAME = "prathuu7"
$REPO_NAME = "ai_chatbot_web"

# Ask for sensitive keys securely
$RENDER_API_KEY = Read-Host "Enter your Render API key" -AsSecureString | ConvertFrom-SecureString
$HF_API_KEY     = Read-Host "Enter your Hugging Face API key" -AsSecureString | ConvertFrom-SecureString

# Convert secure strings to plain text for API calls
$secureRender = ConvertTo-SecureString $RENDER_API_KEY
$plainRender  = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureRender))
$secureHF     = ConvertTo-SecureString $HF_API_KEY
$plainHF      = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureHF))

# -------------------------
# GitHub Setup & Push
# -------------------------
git init
git add .
git commit -m "Initial commit" -ErrorAction SilentlyContinue
git branch -M main
try { git remote remove origin } catch {}
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
git push -u origin main
Write-Host "✅ Project pushed to GitHub!"

# -------------------------
# Render Deployment
# -------------------------

# Get Render owner ID
$account = Invoke-RestMethod -Uri "https://api.render.com/v1/accounts" -Headers @{"Authorization"="Bearer $plainRender"}
$OWNER_ID = $account[0].id  # take first account if multiple

# Build request body
$body = @{
    name = $REPO_NAME
    type = "web_service"
    repo = "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    branch = "main"
    env = "python"
    plan = "free"
    ownerID = $OWNER_ID
    envVars = @(@{ key="HF_API_KEY"; value=$plainHF; sync=$true })
    buildCommand = "pip install -r requirements.txt"
    startCommand = "gunicorn app:app"
} | ConvertTo-Json -Depth 10

$renderApi = "https://api.render.com/v1/services"
$response = Invoke-RestMethod -Uri $renderApi -Method Post -Headers @{"Authorization"="Bearer $plainRender"; "Content-Type"="application/json"} -Body $body

Write-Host "✅ Render deployment complete!"
Write-Host "🌐 Your chatbot is live at: $($response.serviceDetails.url)"
