# User/API Documentation 

User and API docs for Data Upstream Cloud Service.
The API-Docs are here:
https://github.com/data-upstream/docs/blob/master/dist/docs.md

# Quick Howto

1. Sign up / Login to:
https://alpha.data-upstream.ch/

2. Create Streams / Devices
3. From the list, tab the magnifying glass
4. Copy the token from your first entry in list (these are read-write-tokens)

## prepare your devices

1. Set Headers appriately:          
{
  "Content-Type": "application/json",
  "Accept": "application/json",
  "X-Access-Token": "YOUR_TOKEN"
}
2. From your data source/producer push any valid JSON to 
https://db.alpha.data-upstream.ch/api/log_data
3. Run a Jupyter Notebook to explore the data with Bokeh, etc...
See https://www.data-upstream.ch/ for more informations

## Read-only tokens to for use in external webapps / or devices (e.g. to display data)

We have implemented our read only tokens (See the API-Doc) for use in web apps, or apps you want to share.
However you'll need to use the aggregate log data service to read data. 





