# UCP API conventions
A collection of conventions that components of the UnderCloud Platform (UCP)
utilize for their REST APIs
---
## Resource path naming
* Resource paths nodes follow an all lower case naming scheme, and pluralize
the resource names. Nodes that refer to keys, ids or names that are externally
controlled, the external naming will be honored.
* The version of the API resource path will be prefixed before the first node
of the path for that resource using v#.# format.
* By default, the API will be namespaced by /api before the version. For the
purposes of documentation, this will not be specified in each of the resource
paths below. In more complex APIs, it makes sense to allow the /api node to be
more specific to point to a particular service.
```
/api/v1.0/sampleresources/ExTeRnAlNAME-1234
      ^         ^       ^       ^
      |         |       |      defer to external naming
      |         |      plural
      |        lower case
     version here
```
---
## Error responses
Error responses (HTTP response body accompanying 4xx and 5xx series responses
where possible) are a more specific version of the
[Kubernetes standard for error representation](https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md#response-status-kind).
UCP utilizes the details field in a more formalized way to represent multiple
messages related to an error response, as follows:

```
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "{{UCP Component Name}} {{error phrase}}",
  "reason": "{{appropriate reason phrase}}",
  "details": {
    "errorCount": {{n}},
    "errorList": [
       { "message" : "{{validation failure message}}"},
       ...
    ]
  },
  "code": {{http status code}}
}
```

such that:
1. the details field is still optional
2. if used, the details follow that format
3. the repeating entity inside the errorList can be decorated with as many
other fields as are useful, but at least have a message field
---
## Headers
### Required

* X-Auth-Token  
The auth token to identify the invoking user.

### Optional

* X-Context-Marker  
A context id that will be carried on all logs for this client-provided marker.
This marker may only be a 36-character canonical representation of an UUID
(8-4-4-4-12)

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
  href: "deckhand+https://deckhand/{{revision_id}}/rendered-documents",
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
    "errorList": [
       { "message" : "{{validation failure message}}"},
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
    "errorList": []
  },
  "code": 200
}
```

## Health Check API
Each UCP component shall expose an endpoint that allows other component
to access and validate its health status.  The response shall be received
within 30 seconds.

### GET /v1.0/health
Invokes a UCP component to return its health status

#### Health Check Output
The current design will be for the UCP component to return an empty response to
show that it is alive and healthy. The UCP component performing the query will
return error code 503 if it does not receive a response within 30 seconds. Other
5xx series error codes will be added as the UCP components expand on its health
check capabilities.

The output structure reuses the Kubernetes Status kind to represent the health
check results. The Status kind will be returned for both successful and failed
health checks to maintain consistencies. The message field will contain summary
information related to the results of the health check. Details of the health
check can be added as required.

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
    "errorList": [
       { "message" : "{{Detailed Health Check failure information}}"},
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
    "errorList": []
  },
  "code": 204
}
```
