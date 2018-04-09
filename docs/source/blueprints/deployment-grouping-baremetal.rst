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
fault tolerant site deployments and updates.

For the purposes of this document `phase of deployment` refer to the prepare
nodes and deploy nodes steps of the Baremetal and Network deployment.

Some factors that advise this solution:

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
---------------------------------------
To accommodate the needed changes, this design introduces a new
DeploymentStrategy document into the site design to be read and utilized
by the workflows for update_site and deploy_site.

Groups
~~~~~~
Groups are named sets of nodes that will be deployed together. The fields of a
group are:

name
  Required. The identifying name of the group.

critical
  Required. Indicates if this group is required to continue to additional
  phases of deployment.

depends_on
  Required, may be empty list. Group names that must be successful before this
  group can be processed.

selectors
  Required, may be empty list. A list of identifying information to indicate
  the nodes that are members of this group.

success_criteria
  Optional. Criteria that must evaluate to be true before a group is considered
  successfully complete with a phase of deployment.

Criticality
'''''''''''
- Field: critical
- Valid values: true | false

Each group is required to indicate true or false for the `critical` field.
This drives the behavior after the phase of deployment.  If any groups that
are marked as `critical: true` fail to meet that group's success criteria, the
workflow should halt after the current phase. A group that cannot be processed
due to a parent dependency failing will be considered failed, regardless of the
success criteria.

Dependencies
''''''''''''
- Field: depends_on
- Valid values: [] or a list of group names

Each group specifies a list of depends_on groups, or an empty list. All
identified groups must complete successfully for the phase of deployment before
the current group is allowed to be processed by the current phase.

- A failure (based on success criteria) of a group prevents any groups
  dependent upon the failed group from being attempted.
- Circular dependencies will be rejected as invalid during document validation.
- There is no guarantee of ordering among groups that have their dependencies
  met. Any group that is ready for deployment based on declared dependencies
  will execute. Exection of groups is serialized - two groups will not deploy
  at the same time.

Selectors
'''''''''
- Field: selectors
- Valid values: [] or a list of selectors

The list of selectors indicate the nodes that will be included in a group.
Each selector has three available filering values: node_names, node_tags, and
rack_names. Each selctor is an intersection of these criterion, while the list
of selectors are a union of the individual selectors.

- Omitting a criterion from a selctor, or using empty list means that criterion
  is ignored.
- Having a completely empty list of selectors, or a selector that has no
  criteria specified indicates ALL nodes.
- A collection of selectors that results in no nodes being identified will be
  processed as if 100% of nodes successfully deployed (avoiding divison by
  zero), but would fail the minimum or maximum nodes criteria (still counts as
  0 nodes)
- There is no guard against the same node being in multiple groups. Due to the
  nature of Drydock, nodes that have already completed will not be re-deployed,
  but nodes that may have failed in another group may be retried.

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

Success Criteria
''''''''''''''''
- Field: success_criteria
- Valid values: for possible values, see below

Each group optionally contains success criteria which is used to indicate if
the deployment of that group is successful. The values that may be specified:

percent_successful_nodes
  The calculated success rate of nodes completing the deployment phase.

  E.g.: 75 would mean that 3 of 4 nodes must complete the phase successfully.

  This is useful for groups that have larger numbers of nodes, and do not
  have critical minimums or are not sensitive to an arbitrary number of nodes
  not working.

minimum_successful_nodes
  An integer indicating how many nodes must complete the phase successfully.

maximum_failed_nodes
  An integer indicating a number of nodes that are allowed to have failed the
  deployment phase and still consider that group succesful.

When no criteria are specified, it means that no checks are done - processing
continues as if nothing is wrong.

When more than one criterion is specified, each is evaluated separately - if
any fail, the group is considered failed.


Example Deployment Strategy Document
'''''''''''''''''''`''''''''''''''''
This example shows a deployment strategy with 5 groups: control-nodes,
compute-nodes-1, compute-nodes-2, monitoring-nodes, and ntp-node.

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
        critical: true
        depends_on:
          - ntp-node
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
        critical: false
        depends_on:
          - control-nodes
        selctors:
          - rack_names:
              - rack01
            node_tags:
              - compute
        success_criteria:
          percent_successful_nodes: 50
      - name: compute-nodes-2
        critical: false
        depends_on:
          - control-nodes
        selectors:
          - rack_names:
              - rack02
            node_tags:
              - compute
      - name: monitoring-nodes
        critical: false
        depends_on: []
        selctors:
          - node_tags:
              - monitoring
            rack_names:
              - rack03
              - rack02
              - rack01
      - name: ntp-node
        critical: true
        depends_on: []
        selctors:
          node_names:
            - ntp01
        success_criteria:
          minimum_successful_nodes: 1

The ordering of groups, as defined by the dependencies (``depends-on``
fields)::

   ----------        ------------------
  | ntp-node |      | monitoring-nodes |
   ----------        ------------------
       |
       V
   ---------------
  | control-nodes |
   ---------------
       |_________________________
           |                     |
           V                     V
     -----------------     -----------------
    | compute-nodes-1 |   | compute-nodes-2 |
     -----------------     -----------------

Given this, the order of execution could be:

- ntp-node > monitoring-nodes > control-nodes > compute-nodes-1 > compute-nodes-2
- ntp-node > control-nodes > compute-nodes-2 > compute-nodes-1 > monitoring-nodes
- monitoring-nodes > ntp-node > control-nodes > compute-nodes-1 > compute-nodes-2
- and many more ... the only guarantee is that ntp-node will run some time
  beforevcontrol-nodes, which will run sometime before both of the
  compute-nodes. Monitoring-nodes can run at any time.

Also of note are the various combinations of selectors and the varied use of
success criteria.


Deployment Configuration Document (Shipyard)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The existing deployment-configuration document that is used by the workflows
will also be modified to use the existing deployment_strategy field to provide
the name of the deployment-straegy document that will be used.

The default value for the name of the DeploymentStrategy document will be
``deployment-strategy``.

Shipyard Changes
~~~~~~~~~~~~~~~~

API
'''
The commit configdocs api will need to be enhanced to look up the
DeploymentStrategy by using the DeploymentConfiguration.

The DeploymentStrategy document will need to be validated to ensure there are
no circular dependencies in the groups' declared dependencies.

Workflow
''''''''
The deploy_site and update_site workflows will be modified to utilize the
DeploymentStrategy.

TODO: Determination of order of groups - Dag software to detect cycles, traversal?
TODO: Phases... Xcom of group names successful in prior step?



Documentation
'''''''''''''
The action documentation will need to include details defining the
DeploymentStrategy document (mostly as defined here), as well as the update to
the DeploymentConfiguration document to contain the name of the
DeploymentStrategy document.




TODO
----
- check if we're going to prevent retry of failed nodes in the same deploy
  somehow if they are in multiple groups?