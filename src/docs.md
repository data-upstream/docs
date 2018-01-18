# Introduction
## Authenticated Endpoints

There are two types of access tokens:

1. User access tokens - these tokens are granted to users via the user
   registration and sign in endpoints.
2. Device access tokens - these tokens are granted to devices via the device
   creation endpoint. During device creation, more than one access tokens may be
   granted. The usage of these tokens depend on the key rotation system config.
   If key rotation is enabled, these tokens must be used in sequence (i.e.,
   key 1 follow by key 2 follow by key 3 and so on and come back to key 1). If
   key rotation is disabled, _any_ of the tokens can be used at any time.

Authenticated endpoints have to be called with an access token. The token (both
user access token and device access token) should be specified in the
`X-Access-Token` header field.

Certain authenticated endpoints accept **only** user access tokens, **only**
device access tokens, or **both** user and device access tokens. Such
requirements will be documented at each endpoint.

If an access token is not specified or is invalid, authenticated endpoints will
respond with HTTP status code 401 (unauthorized). Such response will be omitted
from the documentation below.

Certain resources, such as devices, _belong_ to users. As such, not all access
tokens will be accepted. For example, if a device belongs to a user Alice,
another user Bob cannot use his access tokens to update this device. Any attempt
to do so will be rejected and the endpoint will respond with HTTP status code
403 (forbidden). Such response will be omitted from the documentation below.

## Error Handling
An error is indicated by HTTP status code of 400-499. When this happens, the
response will be a JSON object with an `errors` property which contains an array
of strings describing the errors. For example, if the user registration endpoint
is called without any parameters, the endpoint will repond with HTTP status code
422 (unprocessable entity) along with the following body:

```json
{
  "errors": [
    "Email can't be blank",
    "Password can't be blank"
  ]
}
```

## Paging
Endpoints that produce lists of resources (such as list of devices, list of
device access tokens, etc) support paging. Paging can be controlled using the
following optional query parameters:

- `page` - The page number. This value starts from 1. This value defaults to 1.
- `limit` - The maximum number resources to return in the list. This value
  defaults to 100.

The resources are ordered by the id of the resources in descending order (i.e.,
newer resources appear in earlier pages).

Notice that paging is implemented using SQL limit and offset. As such there is a
possibility of entering a race condition with resource creation.

For example, we are listing some resources whose valid ids are 1-100. Suppose we
set limit to 5. Consider the following sequence of operations:

1. Get page = 1. This will return ids 96-100.
2. Create new resource. Suppose this resource has id 101.
3. Get page = 2. This will return ids 92-96.

Notice that id 96 is returned twice. Hence, if your application is enumerating
through pages of a list, remember to keep a list of visited ids to prevent
double processing (unless the processing operation is idempotent).

These parameters will be omitted from the documentation below.

# Endpoints
## User Registration

```http
POST ___BASE_URL___/users.json
```

Parameters:

- `email`
- `password`

Response:

- 200 (OK) - A new user is created.
  - `user`: The newly created user.
  - `access_token`: Access token for the newly created user.
- 422 (Unprocessable entity) - At least one of the fields is invalid.

## User Sign In

```http
POST /users/access_token.json
POST /users/sign_in.json (Deprecated)
```

Parameters:

- `email`
- `password`

Response:

- 200 (OK) - The user is successfully signed in.
  - `access_token`: A new access token.
- 403 (Forbidden) - The user cannot be signed in. This happens if email and/or
  password are wrong.

## User Sign Out

```http
DELETE ___BASE_URL___/users/access_token.json
```

This endpoint is authenticated and accepts only **user access tokens**.

Response:

- 204 (No content) - The user is successfully signed out.

## Listing Streams

```http
GET ___BASE_URL___/users/streams.json
```

This endpoint is authenticated and accepts only **user access tokens**.

Response:

- 200 (OK) - A list of devices is returned.

## Stream Registration

```http
POST ___BASE_URL___/users/streams.json
```

This endpoint is authenticated and accepts only **user access tokens**.

Parameters:

- `name` - Name of the stream
- `key_rotation_enabled` - Whether or not key rotation is enabled.

Response:

- 200 (OK) - A new stream is created.
  - `device`: The newly created stream.
  - `access_tokens`: An array of stream access tokens.

## Stream Update

```http
PUT ___BASE_URL___/users/streams/id.json
```

This endpoint is authenticated and accepts only **user access tokens**.

Parameters:

- Any parameters that the stream registration endpoint accepts

Response:

- 200 (OK) - The stream is updated.
  - The stream is returned.

## Listing Device Access Tokens

```http
GET ___BASE_URL___/devices/:device_id/device_access_tokens.json
```

This endpoint is authenticated and accepts only **user access tokens**.

Response:

- 200 (OK) - A list of device access tokens is returned.

## Listing Log Data

```http
GET ___BASE_URL___/log_data.json
```

This endpoint is authenticated and accepts only **device access tokens**.

Response:

- 200 (OK)
  - An array of log data.

## Creating Log Data

```http
POST ___BASE_URL___/log_data.json
```

This endpoint is authenticated and accepts only **device access tokens**.

Parameters:

- `payload`: Arbitrary JSON object.

Note: Since the request data is a nested data structure, the usual `form-data`
submission won't work. Use JSON payload instead. As a result, it is important to
set the correct `Content-Type` header (which is`application/json`).

Example (JavaScript fetch):

```javascript
const BASE_URL = '___BASE_URL___';

const requestBody = {
  payload: {
    foo: 'bar',
    hello: 'world'
  }
};

const headers = new Headers({
  'Content-Type': 'application/json',
  'X-Access-Token': 'device access token'
});

fetch(BASE_URL + '/log_data', {
  method: 'POST',
  headers,
  body: JSON.stringify(requestBody)
});
```

Example (Python):

```python
import json
import requests

BASE_URL = '___BASE_URL___'

headers = {
    'Content-Type': 'application/json',
    'X-Access-Token': 'device access token'
}

request_body = {
    'payload': {
        'foo': 'bar',
        'hello': 'world'
    }
}

body = json.dumps(request_body)

requests.post(BASE_URL + '/log_data', headers=headers, data=body)
```

Response:

- 200 (OK) - The log data is created.
  - The newly created log data.

## Listing Log Data Images

```http
GET ___BASE_URL___/streams/log_data/:id/images
```

This endpoint is authenticated and accepts only **device access tokens**.

Response:

- 200 (OK)
  - A list of images is returned.

## Create Log Data Images

```http
POST ___BASE_URL___/streams/log_data/:id/images
```

This endpoint is authenticated and accepts only **device access tokens**.

Parameters:

- `images[]` - The file object. This parameter can be specified multiple times
  to upload multiple images in a single request

Response:

- 200 (OK) - The images are uploaded
  - The list of new images is returned.

Example (Python):

```python
import requests

BASE_URL = '___BASE_URL___'

image1 = ('images[]', ('image.png', open('image.png', 'rb'), 'image/png'))
image2 = ('images[]', ('image.png', open('image.png', 'rb'), 'image/png'))
files = [image1, image2]

headers = {'X-Access-Token': device_access_token}
r = requests.post(BASE_URL + '/streams/log_data/21/images', files=files, headers=headers)
print(r.status_code)
print(r.json())
```

## Retrieve System Config

```http
GET ___BASE_URL___/system_config/:key
```

This endpoint is authenticated and accepts only **user access tokens**.

Response:

- 200 (OK)
  - `value` - The value of the specified key

Supported keys:

- `key_rotation`

## Update System Config

```http
POST ___BASE_URL___/system_config/:key
```

This endpoint is authenticated and accepts only **user access tokens**.

Payload:

- `value`: The new value of the specified configurations

Response:

- 200 (OK)
  - `value` - The updated value of the specified key

## User Profile

```http
GET ___BASE_URL___/profile
```

This endpoint is authenticated and accepts only **user access tokens**.

Response:

- 200 (OK) - The user profile

## List Aggregate Log Data

```http
GET ___BASE_URL___/aggregate_log_data
```

This endpoint is authenticated and accepts only **user access tokens**.

Query parameters:

- `device_ids` - A JSON array of device ids to query. Defaults to an empty array.

Response:

- 200 (OK) - The log data is queried and returned.
  - The response is a dictionary mapping device ids (in strings) to arrays of
    log data.

## Webhook Registration

```http
POST ___BASE_URL___/users/streams/:stream_id/webhooks
```

URL Parameters:

- `stream_id` - The ID of the stream to attach the webhook to. Only events
  coming from this stream will invoke the registered webhook.

Parameters:

- `url` - The URL to invoke when an event happens.
- `active` - A boolean, whether the webhook is active. The webhook will be
  invoked only if it is active.

Response:
  - 200 (OK) - The webhook is registered.
    - The created webhook object is returned.

## Webhook Update

```http
PUT ___BASE_URL___/users/webhooks/:id
```

URL Parameters:

- `id` - The ID of the webhook to update.

Parameters:

- All the parameters accepted by the webhook registration endpoint.

Response:
  - 200 (OK) - The webhook is updated.
    - The updated webhook object is returned.
