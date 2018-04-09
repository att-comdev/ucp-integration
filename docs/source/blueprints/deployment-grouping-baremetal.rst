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

.. _deployment-grouping-baremetal:

Deployment Grouping for Baremetal Nodes
=======================================

One of the primary functionalities of the Undercloud Platform is the deployment
of baremetal nodes as part of site deployment and upgrade. This blueprint aims
to define how deployment strategies can be applied to the workflow during these
actions.

Overview
--------

When Shipyard is invoked for a deploy_site or update_site action, there are
three primary stages:

1. Preparation and Validaiton
2. Baremetal and Network Deployment
3. Software Deployment

During the Baremetal and Network Deployment stage, the deploy_site or
update_site workflow (and perhaps other workflows in the future) invokes
Drydock to verify the site, prepare the site, prepare the nodes, and deploy the
nodes. Each of thse steps is described in the `Drydock Orchestrator Readme`_

.. _Drydock Orchestrator Readme: https://github.com/att-comdev/drydock/tree/master/drydock_provisioner/orchestrator

The prepare nodes and deploy nodes steps each involve intensive and potentially
time consuming operations on the target nodes, orchestrated by Drydock and
Maas. These steps need to be approached and managed such that grouping,
ordering, and criticality of success of nodes can be managed in support of
fault tolerant site deployments and updates. Some factors that advise this
solution:

1. Limits to the amount of parallelzation that can occur due to a centralized
   Maas system.
2. Faults in the hardware, preventing operational nodes.
3. Miswiring or configuration of network hardware.
4. Incorrect site design causing a mismatch against the hardware.
5. Criticality of particular nodes to the realization of the site design.
6. Desired configurability within the framework of the UCP declarative site
   design.
7. Improved visibility into the current state of node deployment.

Solution
--------

Updates supporting this solution will require changes to Shipyard for changed
workflows and Drydock for the desired node targeting, and for retrieval of
diagnostic and result information.

Deployment Strategy Document (Shipyard)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
To accommodate the needed changes, this design introduces a new
DeploymentStrategy document into the site design to be read and utilized
by the workflows for update_site and deploy_site.

------------------------------------------------------------------------------
TODO: required succesful groups - if groups fail (or are skipped due to a
      failure of a dependency group), under what conditions do we
      proceed with the rest of the overall deploy_site or update_site?
------------------------------------------------------------------------------

Groups
''''''

Groups are named sets of nodes that will be deployed together.

Dependencies
''''''''''''

Each group can specify a depends_on group, which must have completed
successfully for the phase of deployment before it may proceed with the same
phase.

A failure (based on success criteria) of a group prevents any groups dependent
upon the failed group from being attempted.

Success Criteria
''''''''''''''''

Each group may indicate success criteria which is used to indicate if the
deployment of that group is successful. There are 3 values that may be
specified:

- percent_successful_nodes: The calculated success rate of nodes completing the
  deployment phase.

  E.g.: 75 would mean that 3 of 4 nodes must complete the
  phase successfully.

  This is useful for groups that have larger numbers of
  nodes, and do not have critical minimums or are not sensitive to an arbitrary
  number of nodes not working.

- minimum_successful_nodes: An integer number indicating how many nodes must
  complete the phase successfully.

  E.g.: 3 would indicate that 3 nodes must have completed the deployment phase
  successfully

- maximum_failed_nodes: An integer number indicating a number of nodes that are
  allowed to have failed the deployment phase and still consider that group
  succesful.

  E.g.: 1 would indicate that only 1 node may fail the deployment phase.

When no criteria are specified, it means that no checks are done - processing
continues as if nothing is wrong.

When more than one criteria is specified, each is evaluated separately - if
any fail, the group is considered failed.


Selctors
''''''''

Each selector is a 3-part criteria: node_names, node_tags, and rack_names such
that each selctor is an intersection of criteria.
E.g.::

  selectors:
    - node_names:
        - node01
        - node02
      rack_names:
        - rack01
      node_tags:
        - control
    - node_names:
        - node04
      node_tags:
        - monitoring

Will indicate (not really SQL, just for illustration)::

    SELECT nodes
    WHERE node_name in ('node01', 'node02')
          AND rack_name in ('rack01')
          AND node_tags in ('control')
    UNION
    SELECT nodes
    WHERE node_name in ('node04')
          AND node_tag in ('monitoring')

- Having a list of selctors indicates a union of each of the selctor's results.
- Omitting a criteria from a selctor, or using empty list means that criteria
  is ignored.
- Having a completely empty list of selectors, or a selector that has no
  criteria specified indicates ALL nodes.


Example DeploymentvStrategy Document
'''''''''''''''''''`''''''''''''''''

::

  ---
  schema: shipyard/DeploymentStrategy/v1
  metadata:
    schema: metadata/Document/v1
    name: deployment-strategy
    layeringDefinition:
        abstract: false
        layer: global
    storagePolicy: cleartext
  data:
    groups:
      - name: control-nodes
        depends_on: null
        selctors:
          - node_names: []
            node_tags:
            - control
            rack_names:
            - rack03
        success_criteria:
          percent_successful_nodes: 90
          minimum_successful_nodes: 3
          maximum_failed_nodes: 1
      - name: compute-nodes-1
        depends_on: control-nodes
        selctors:
          - rack_names:
              - rack01
            node_tags:
              - compute
        success_criteria:
          percent_successful_nodes: 50
      - name: compute-nodes-2
        depends_on: control-nodes
        selectors:
          - rack_names:
              - rack02
            node_tags:
              - compute
      - name: monitoring-nodes
        depends_on: null
        selctors:
          - node_tags:
              - monitoring
            rack_names:
              - rack03
              - rack02
              - rack01
      - name: ntp-node
        depends_on: null
        selctors:
          node_names:
            - ntp01
        success_criteria:
          minimum_successful_nodes: 1


Deployment Configuration Document (Shipyard)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The existing deployment-configuration document that is used by the workflows
will also be modified to use the existing deployment_strategy field to provide
the name of the deployment-straegy document that will be used.





