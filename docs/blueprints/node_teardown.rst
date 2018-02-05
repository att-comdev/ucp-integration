..
      Copyright 2018 AT&T Intellectual Property.
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

Undercloud Node Teardown
========================

When redeploying a physical host (server) using the Undercloud Platform(UCP),
it is necessary to trigger a sequence of steps to prevent undesired behaviors
when the server is redeployed. This blueprint intends to document the
interaction that must occur between UCP components to teardown a server.

Overview
--------
Shipyard is the entrypoint for UCP actions, including the need to redeploy a
server. The first part of redeploying a server is the graceful teardown of the
software running on the server; specifically Kubernetes and etcd are of
critical concern. It is the duty of Shipyard to orchestrate the teardown of the
server, followed by steps to deploy the desired new configuration. This design
covers only the first portion - node teardown

Shipyard node teardown Process
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#. (Existing) Shipyard receives request to redeploy_server, specifying a target
   server.
#. (Existing) Shipyard performs preflight, design reference lookup, and
   validation steps.
#. (New) Shipyard invokes Promenade to disassociate a node.
   #. Drain the Kubernetes node based on the target server
   #. Clear the Kubernetes labels on the node of the target server.
   #. Ensure that etcd cluster(s) are in a stable state.
   #. Shutdown the kubelet
#. (Existing) Shipyard invokes Drydock to destroy the node - setting a node
   filter to restrict to a single server.
#. (New) Shipyard invokes Promenade to delete the node from the Kubernetes
   cluster.

Promenade Disassociate Node
---------------------------
Performs steps that will result in the specified node being cleanly
disassociated from Kubernetes, and ready for the server to be destroyed. The
process for disassociating a node will invoke drain node, clear labels,
check etcd, and shutdown kubelet in sequence.

.. attention::

  This API endpoint may not be created - it is a convenience method only.

.. code::

  POST /nodes/{node_id}/disassociate

  {
    rel : "design",
    href: "deckhand+https://{{deckhand_url}}/revisions/{{revision_id}}/rendered-documents",
    type: "application/x-yaml"
  }

Such that the design reference body is the design last committed by Shipyard,
and the node_id references the bare metal node name from the
drydock/BaremetalNode/v1 document in the design.

.. attention::

  Should it be last committed, or last used for deploy/update site?

Responses
~~~~~~~~~
All responses will be form of the UCP Status response.

-  Success: Code: 200, reason: Success

   Indicates that all steps are successful.

-  Failure: Code: 404, reason: NotFound

   Indicates that the target node is not discoverable by Promenade.

-  Failure: Code: 500, reason: DisassociateStepFailure

   The details section should detail the successes and failures further.


Promenade Drain Node
--------------------
Drain the Kubernetes node for the target node. This will ensure that this node
is no longer the target of any pod scheduling, and evicts or deletes the
running pods. In the case of notes running DaemonSet manged pods, or pods
that would prevent a drain from occurring, Promenade may be required to provide
the `ignore-daemonsets` option or `force` option to attempt to drain the node
as fully as possible.

.. code::

  POST /nodes/{node_id}/drain

  {
    rel : "design",
    href: "deckhand+https://{{deckhand_url}}/revisions/{{revision_id}}/rendered-documents",
    type: "application/x-yaml"
  }

.. note::

  Example command being used for drain (reference only)
  `kubectl drain --force --timeout 3600s --grace-period 1800 --ignore-daemonsets --delete-local-data n1`
  https://github.com/att-comdev/promenade/blob/master/promenade/templates/roles/common/usr/local/bin/promenade-teardown

Responses
~~~~~~~~~
All responses will be form of the UCP Status response.

-  Success: Code: 200, reason: Success

   Indicates that the drain node has successfully concluded, and that no pods
   are currently running

-  Failure: Status response, code: 404, reason: NotFound

   The specified node is not discoverable by Promenade

-  Failure: Status response, code: 500, reason: DrainNodeError

   There was a processing exception raised while trying to drain a node. The
   details section should indicate the underlying cause if it can be
   determined.

Promenade Clear Labels
----------------------
Removes the labels that have been added to the target kubernetes node.

.. code::

  POST /nodes/{node_id}/clear-labels

  {
    rel : "design",
    href: "deckhand+https://{{deckhand_url}}/revisions/{{revision_id}}/rendered-documents",
    type: "application/x-yaml"
  }

Responses
~~~~~~~~~
All responses will be form of the UCP Status response.

-  Success: Code: 200, reason: Success

   All labels have been removed from the specified Kubernetes node.

-  Failure: Code: 404, reason: NotFound

   The specified node is not discoverable by Promenade

-  Failure: Code: 500, reason: ClearLabelsError

   There was a failure to clear labels that prevented completion. The details
   section should provide more information about the cause of this failure.


Promenade Check etcd
~~~~~~~~~~~~~~~~~~~~
Retrieves the current interpreted state of etcd.

GET /etcd-cluster-health-statuses?design_ref={the design ref}

Where the design_ref paramter is required for appropriate operation, and is in
the same format as used for the join-scripts API.

Responses
~~~~~~~~~
All responses will be form of the UCP Status response.

-  Success: Code: 200, reason: Success

   The status of each etcd in the site will be returned in the details section.
   Valid values for status are: Healthy, Unhealthy

https://github.com/att-comdev/ucp-integration/blob/master/docs/source/api-conventions.rst#status-responses

.. code::
  { ... standard status response ...
    "details": {
      "errorCount": {{n}},
      "messageList": [
        { "message": "Healthy",
          "error": false,
          "kind": "HealthMessage",
          "name": "{{the name of the etcd service}}"
        },
        { "message": "Unhealthy"
          "error": false,
          "kind": "HealthMessage",
          "name": "{{the name of the etcd service}}"
        },
        { "message": "Unable to access Etcd"
          "error": true,
          "kind": "HealthMessage",
          "name": "{{the name of the etcd service}}"
        }
      ]
    }
    ...
  }

-  Failure: Code: 400, reason: MissingDesignRef

   Returned if the design_ref parameter is not specified

-  Failure: Code: 404, reason: NotFound

   Returned if the specified etcd could not be located

-  Failure: Code: 500, reason: EtcdNotAccessible

   Returned if the specified etcd responded with an invalid health response
   (Not just simply unhealthy - that's a 200).


Promenade Shutdown Kubelet
--------------------------
Shuts down the kubelet on the specified node

.. code::

  POST /nodes/{node_id}/shutdown-kubelet

  {
    rel : "design",
    href: "deckhand+https://{{deckhand_url}}/revisions/{{revision_id}}/rendered-documents",
    type: "application/x-yaml"
  }

Responses
~~~~~~~~~
All responses will be form of the UCP Status response.

-  Success: Code: 200, reason: Success

   The kubelet has been successfully shutdown

-  Failure: Code: 404, reason: NotFound

   The specified node is not discoverable by Promenade

-  Failure: Code: 500, reason: ShutdownKubeletError

   The specified node's kubelet fails to shutdown. The details section of the
   status response should contain reasonable information about the source of
   this failure


Promenade Delete Node from Cluster
----------------------------------
Updates the Kubernetes cluster, removing the specified node

.. code::

  POST /nodes/{node_id}/remove-from-cluster

  {
    rel : "design",
    href: "deckhand+https://{{deckhand_url}}/revisions/{{revision_id}}/rendered-documents",
    type: "application/x-yaml"
  }

Responses
~~~~~~~~~
All responses will be form of the UCP Status response.

-  Success: Code: 200, reason: Success

   The specified node has been removed from the Kubernetes cluster.

-  Failure: Code: 404, reason: NotFound

   The specified node is not discoverable by Promenade

-  Failure: Code: 500, reason: ShutdownKubeletError

   The specified node cannot be removed from the cluster due to an error from
   Kubernetes. The details section of the status response should contain more
   information about the failure.


