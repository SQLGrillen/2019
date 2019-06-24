#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI under Source Control
# Setup Script for implementing Webhook
#-------------------------------------------------------
break
#-------------------------------------------------------

#Variables already defined
$applicationId = ''
$client_Secret = ''
$tenantId = ''

#-------------------------------------------------------


$authority = "https://login.microsoftonline.com/$($tenantId)/oauth2/token"

$resource = "https://manage.office.com"

$redirectUrl = 'https://yourdomain.com'



$authBody = @{
    'resource'=$resource
    'client_id'=$applicationId
    'grant_type'="client_credentials"
    'client_secret'=$client_Secret
    'redirect_uri'=$redirectUrl
}

$auth = Invoke-RestMethod -Uri $authority -Body $authBody -Method POST -Verbose
# $auth
$token = $auth.access_token

$token

    # Build the API Header with the auth token
    $authHeader = @{
        'Content-Type'='application/json'
        'Authorization'='Bearer ' + $token
    }

#-------------------------------------------------------------------------------
# Testing Activity feed

    $uri = "https://manage.office.com/api/v1.0/$($tenantId)/activity/feed/subscriptions/list"

    Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

#-------------------------------------------------------------------------------
# Setup Webhook

$uri = "https://manage.office.com/api/v1.0/$($tenantId)/activity/feed/subscriptions/start?contentType=Audit.General"

$body = '{
    "webhook" : {
        "address": "PUT YOUR WEBHOOK URL IN HERE FROM FLOW",
        "authId": "PowerBI_Deploy_Audit",
        "expiration": ""
    }}'


Invoke-RestMethod -Uri $uri -Headers $authHeader -Body $body -Method POST