# User/API Documentation 

User and API docs for Data Upstream Cloud Service.
The API-Docs are here:
https://github.com/data-upstream/docs/blob/master/dist/docs.md

## The base-Url 

The base url changed to:
https://db.alpha.data-upstream.ch/api/

# Quick Howto

1. Sign up / Login to:
https://alpha.data-upstream.ch/

2. Create Streams / Devices
3. From the list, tab the magnifying glass
4. Copy the token from your first entry in list

## prepare your devices

5. Set Headers appriately:          
{
  "Content-Type": "application/json",
  "Accept": "application/json",
  "X-Access-Token": "YOUR_TOKEN"
}
6. Push any valid JSON to 
https://db.alpha.data-upstream.ch/api/log_data






