..
      Copyright 2017 AT&T Intellectual Property.
      All Rights Reserved.

      Licensed under the Apache License, Version 2.0 (the "License"); you may
      not use this file except in compliance with the License. You may obtain
      a copy of the License at

          http://www.apache.org/licenses/LICENSE-2.0

      Unless required by applicable law or agreed to in writing, software
      distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
      WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
      License for the specific language governing permissions and limitations
      under the License.

.. _api-conventions:

API Conventions
===============

A collection of conventions that components of the UnderCloud Platform (UCP)
utilize for their REST APIs

Resource path naming
--------------------

-  Resource paths nodes follow an all lower case naming scheme, and
   pluralize the resource names. Nodes that refer to keys, ids or names that
   are externally controlled, the external naming will be honored.
-  The version of the API resource path will be prefixed before the first
   node of the path for that resource using v#.# format.
-  By default and unless otherwise noted, the API will be namespaced by /api
   before the version. For the purposes of documentation, this will not be
   specified in each of the resource paths below. In more complex APIs, UCP
   components may use values other than /api to be more specific to point to a
   particular service.

::

  /api/v1.0/sampleresources/ExTeRnAlNAME-1234
        ^         ^       ^       ^
        |         |       |      defer to external naming
        |         |      plural
        |        lower case
       version here

Status responses
----------------

Status responses, and more specifically error responses (HTTP response body
accompanying 4xx and 5xx series responses where possible) are a customized
version of the `Kubernetes standard for error representation`_. UCP utilizes
the details field in a more formalized way to represent multiple messages
related to a status response, as follows:

::

  {
    "kind": "Status",
    "apiVersion": "v{{#.#}}",
    "metadata": {},
    "status": "{{Success | Failure}}",
    "message": "{{message phrase}}",
    "reason": "{{reason name}}",
    "details": {
      "errorCount": {{n}},
      "messageList": [
         { "message" : "{{validation failure message}}", "error": true|false},
         ...
      ]
    },
    "code": {{http status code}}
  }


such that:

*  The metadata field is optionally present, as an empty object. Clients should
   be ready to receive this field, but services are not required to produce it.
*  The message phrase is a terse but descriptive message indicating what has
   happened.
*  The reason name is the short name indicating the cause of the status. It
   should be a camel cased phrase-as-a-word, to mimic the Kubernetes status
   usage.
*  The details field is optional.
*  If used, the details follow the shown format, with a errorCount and
   messageList field present.

  -  The repeating entity inside the messageList can be decorated with as
     many other fields as are useful, but at least have a message field and
     error field.
  -  The errorCount field is an integer representing the count of messageList
     entities that have ``error: true``

*  When using this document as the body of a HTTP response, ``code`` is
   populated with a valid `HTTP status code`_

Required Headers
----------------

X-Auth-Token
  The auth token to identify the invoking user. Required unless the resource is
  explictly unauthenticated.

Optional Headers
----------------

X-Context-Marker
  A context id that will be carried on all logs for this client-provided
  marker. This marker may only be a 36-character canonical representation of an
  UUID (8-4-4-4-12)

Validation API
--------------
All UCP components that participate in validation of the design supplied to a
site implement a common resource to perform document validations. Document
validations are synchronous.
Because of the different sources of documents that should be supported, a
flexible input descriptor is used to indicate from where a UCP component will
retrieve the documents to be validated.

POST /v1.0/validatedesign
~~~~~~~~~~~~~~~~~~~~~~~~~
Invokes a UCP component to perform validations against the documents specified
by the input structure.  Synchronous.

Input structure
^^^^^^^^^^^^^^^

::

  {
    rel : "design",
    href: "deckhand+https://{{deckhand_url}}/revisions/{{revision_id}}/rendered-documents",
    type: "application/x-yaml"
  }

Output structure
^^^^^^^^^^^^^^^^

The output structure reuses the Kubernetes Status kind to represent the result
of validations. The Status kind will be returned for both successful and failed
validation to maintain a consistent of interface. If there are additional
diagnostics that associate to a particular validation, the entry in the error
list may carry fields other than "message".

Failure message example::

  {
    "kind": "Status",
    "apiVersion": "v1.0",
    "metadata": {},
    "status": "Failure",
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

Success message example::

  {
    "kind": "Status",
    "apiVersion": "v1.0",
    "metadata": {},
    "status": "Success",
    "message": "{{UCP Component Name}} validations succeeded",
    "reason": "Validation",
    "details": {
      "errorCount": 0,
      "messageList": []
    },
    "code": 200
  }

Health Check API
----------------
Each UCP component shall expose an endpoint that allows other components
to access and validate its health status. Clients of the health check should
wait up to 30 seconds for a health check response from each component.

GET /v1.0/health
~~~~~~~~~~~~~~~~
Invokes a UCP component to return its health status. This endpoint is intended
to be unauthenticated, and must not return any information beyond the noted
204 or 503 status response. The component invoked is expected to return a
response in less than 30 seconds.

Health Check Output
^^^^^^^^^^^^^^^^^^^
The current design will be for the UCP component to return an empty response
to show that it is alive and healthy. This means that the UCP component that
is performing the query will receive HTTP response code 204.

HTTP response code 503 with a generic response status or an empty message body
will be returned if the UCP component determines it is in a non-healthy state,
or is unable to reach another component it is dependent upon.

GET /v1.0/health/extended
~~~~~~~~~~~~~~~~~~~~~~~~~
UCP components may provide an extended health check. This request invokes a
UCP component to return its detailed health status. Authentication is required
to invoke this API call.

Extended Health Check Output
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The output structure reuses the Kubernetes Status kind to represent the health
check results. The Status kind will be returned for both successful and failed
health checks to ensure consistencies. The message field will contain summary
information related to the results of the health check. Detailed information
of the health check will be provided as well.

Failure message example::

  {
    "kind": "Status",
    "apiVersion": "v1.0",
    "metadata": {},
    "status": "Failure",
    "message": "{{UCP Component Name}} failed to respond",
    "reason": "HealthCheck",
    "details": {
      "errorCount": {{n}},
      "messageList": [
         { "message" : "{{Detailed Health Check failure information}}", "error": true},
         ...
      ]
    },
    "code": 503
  }

Success message example::

  {
    "kind": "Status",
    "apiVersion": "v1.0",
    "metadata": {},
    "status": "Success",
    "message": "",
    "reason": "HealthCheck",
    "details": {
      "errorCount": 0,
      "messageList": []
    },
    "code": 200
  }

Versions API
------------
Each UCP component shall expose an endpoint that allows other components to
discover its different API versions. This endpoint is not prefixed by /api
or a version.

GET /versions
~~~~~~~~~~~~~
Invokes a UCP component to return its list of API versions. This endpoint is
intended to be unauthenticated, and must not return any information beyond the
output noted below.

Versions output
^^^^^^^^^^^^^^^
Each UCP component shall return a list of its different API versions. The
response body shall be keyed with the name of each API version, with
accompanying information pertaining to the version's `path` and `status`. The
`status` field shall be an enum which accepts the values `stable` and `beta`,
where `stable` implies a stable API and `beta` implies an under-development
API.

Success message example::

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

.. _Kubernetes standard for error representation: https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md#response-status-kind
.. _HTTP status code: https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html