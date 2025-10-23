# =========================
# Fully Automated AI Chatbot Deployment Script
# =========================

# -------------------------
# USER SETTINGS
# -------------------------
$GITHUB_USERNAME = "prathuu7"
$REPO_NAME = "ai_chatbot_web"
$PROJECT_PATH = "$env:USERPROFILE\OneDrive\Desktop\ai_chatbot_web"
$RENDER_API_KEY = "rnd_P2jrOvEAWLZb5XqUFRIR1Cp76fDK"  # Replace with your Render API Key
envVars = @(@{ key = "PPLX_API_KEY"; value = "Set_in_Render_Dashboard"; sync = $true })

# -------------------------
# STEP 1: Configure Git
# -------------------------
git config --global user.name "prathuu7"
git config --global user.email "thakkerpratham7@gmail.com"
git config --global init.defaultBranch main

# -------------------------
# STEP 2: Go to project folder
# -------------------------
Set-Location $PROJECT_PATH

# -------------------------
# STEP 3: Initialize repo and commit
# -------------------------
git init
git add .
git commit -m "Initial commit" -ErrorAction SilentlyContinue
git branch -M main

# -------------------------
# STEP 4: Set remote and push
# -------------------------
try { git remote remove origin } catch {}
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
git push -u origin main

Write-Host "✅ Project pushed to GitHub!"

# -------------------------
# STEP 5: Deploy to Render
# -------------------------
$renderApi = "https://api.render.com/v1/services"

$body = @{
    name = $REPO_NAME
    type = "web_service"
    repo = "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    branch = "main"
    env = "python"
    plan = "free"
    envVars = @(@{ key = "PPLX_API_KEY"; value = $PPLX_API_KEY; sync = $true })
    buildCommand = "pip install -r requirements.txt"
    startCommand = "gunicorn app:app"
} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Uri $renderApi -Method Post -Headers @{
    "Authorization" = "Bearer $RENDER_API_KEY"
    "Content-Type" = "application/json"
} -Body $body

Write-Host "✅ Render deployment complete!"
Write-Host "Your chatbot is live at: $($response.serviceDetails.url)"
