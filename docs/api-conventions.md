# UCP API conventions
A collection of conventions that components of the UnderCloud Platform (UCP)
utilize for their REST APIs
---
## Resource path naming
<ul>
  <li>Resource paths nodes follow an all lower case naming scheme, and
pluralize the resource names. Nodes that refer to keys, ids or names that are
externally controlled, the external naming will be honored.</li>
  <li>The version of the API resource path will be prefixed before the first
node of the path for that resource using v#.# format.</li>
  <li>By default, the API will be namespaced by /api before the version. For
the purposes of documentation, this will not be specified in each of the
resource paths below. In more complex APIs, it makes sense to allow the /api
node to be more specific to point to a particular service.</li>
</ul>

```
/api/v1.0/sampleresources/ExTeRnAlNAME-1234
      ^         ^       ^       ^
      |         |       |      defer to external naming
      |         |      plural
      |        lower case
     version here
```
---
## Status responses
Status responses, and more specifically error responses (HTTP response body
accompanying 4xx and 5xx series responses
where possible) are a customized version of the
[Kubernetes standard for error representation](https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md#response-status-kind).
UCP utilizes the details field in a more formalized way to represent multiple
messages related to a status response, as follows:

```
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "{{UCP Component Name}} {{status phrase}}",
  "reason": "{{appropriate reason phrase}}",
  "details": {
    "errorCount": {{n}},
    "messageList": [
       { "message" : "{{validation failure message}}", "error": true|false},
       ...
    ]
  },
  "code": {{http status code}}
}
```

such that:
<ol>
  <li>the details field is still optional</li>
  <li>if used, the details follow that format</li>
  <li>the repeating entity inside the messageList can be decorated with as many
other fields as are useful, but at least have a message field and error field.
  </li>
  <li>the errorCount field is an integer representing the count of messageList
entities that have `error: true`</li>
  <li>when using this document as the body of a HTTP response, `code` is
populated with a valid HTTP
[status code](https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html).</li>
</ol>

---
## Headers
### Required

<dl>
  <dt>X-Auth-Token</dt>
  <dd>The auth token to identify the invoking user.</dd>
</dl>

### Optional

<dl>
  <dt>X-Context-Marker</dt>
  <dd>A context id that will be carried on all logs for this client-provided
marker. This marker may only be a 36-character canonical representation of an
UUID (8-4-4-4-12)</dd>
</dl>

## Validation API
All UCP components that participate in validation of the design supplied to a
site implement a common resource to perform document validations. Document
validations are syncrhonous and target completion in 30 seconds or less.
Because of the different sources of documents that should be supported, a
flexible input descriptor is used to indicate from where a UCP component will
retrieve the documents to be validated.

### POST /v1.0/validatedesign
Invokes a UCP component to perform validations against the documents specified
by the input structure.  Synchronous.

#### Input structure
```
{
  rel : "design",
  href: "deckhand+https://{{deckhand_url}}/revisions/{{revision_id}}/rendered-documents",
  type: "application/x-yaml"
}
```
#### Output structure
The output structure reuses the Kubernetes Status kind to represent the result
of validations. The Status kind will be returned for both successful and failed
validation to maintain a consistent of interface. If there are additional
diagnostics that associate to a particular validation, the entry in the error
list may carry fields other than "message".

Failure message example:
```
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Invalid",
  "message": "{{UCP Component Name}} validations failed",
  "reason": "Validation",
  "details": {
    "errorCount": {{n}},
    "messageList": [
       { "message" : "{{validation failure message}}", "error": true},
       ...
    ]
  },
  "code": 400
}
```

Success message example:
```
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Valid",
  "message": "{{UCP Component Name}} validations succeeded",
  "reason": "Validation",
  "details": {
    "errorCount": 0,
    "messageList": []
  },
  "code": 200
}
```

## Health Check API
Each UCP component shall expose an endpoint that allows other components
to access and validate its health status.  The response shall be received
within 30 seconds.

### GET /v1.0/health
Invokes a UCP component to return its health status

#### Health Check Output
The current design will be for the UCP component to return an empty response
to show that it is alive and healthy. This means that the UCP component that
is performing the query will receive HTTP response code 204.

HTTP response code 503 will be returned if the UCP component fails to receive
any response from the component that it is querying.  The time out will be set
to 30 seconds.

### GET /v1.0/health/extended
Invokes a UCP component to return its detailed health status. Authentication
will be required to invoke this API call.

This feature will be implemented in the future.

#### Extended Health Check Output
The output structure reuses the Kubernetes Status kind to represent the health
check results. The Status kind will be returned for both successful and failed
health checks to ensure consistencies. The message field will contain summary
information related to the results of the health check. Detailed information
of the health check will be provided as well.

Failure message example:
```
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Service Unavailable",
  "message": "{{UCP Component Name}} failed to respond",
  "reason": "Health Check",
  "details": {
    "errorCount": {{n}},
    "messageList": [
       { "message" : "{{Detailed Health Check failure information}}", "error": true},
       ...
    ]
  },
  "code": 503
}
```

Success message example:
```
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Healthy",
  "message": "",
  "reason": "Health Check",
  "details": {
    "errorCount": 0,
    "messageList": []
  },
  "code": 200
}
```

## Versions API
Each UCP component shall expose an endpoint that allows other components to
discover its different API versions.

### GET /versions
Invokes a UCP component to return its list of API versions.

#### Versions output
Each UCP component shall return a list of its different API versions. The
response body shall be keyed with the name of each API version, with
accompanying information pertaining to the version's `path` and `status`. The
`status` field shall be an enum which accepts the values "stable" and "beta",
where "stable" implies a stable API and "beta" implies an under-development
API.

Success message example:
```
{
  "v1.0": {
    "path": "/api/v1.0",
    "status": "stable"
  },
  "v1.1": {
    "path": "/api/v1.1",
    "status": "beta"
  },
  "code": 200
}
```
