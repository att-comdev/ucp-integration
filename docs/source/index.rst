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

Undercloud Platform Integration
===============================

The Undercloud Platform (UCP) is a collection of components that coordinate to
form a means of configuring and deploying and maintaining a `Kubernetes`_
environment using a declarative set of `yaml`_ documents. More information about
the UCP and related comonents may be found by using the `Treasuremap`_

Approach
--------
As the UCP revolves around the setup and use of Kubernetes and `Helm`_,
practices take cues from these projects. Since the sibling work of UCP is the
`Openstack Helm`_ project (now an `Openstack`_ projet) cues are also
taken from the Openstack approach.

Conventions and Standards
-------------------------

.. toctree::
   :maxdepth: 3

   conventions
   ucp-basic-deployment


.. _Helm: https://helm.sh/
.. _Kubernetes: https://kubernetes.io/
.. _Openstack: https://www.openstack.org/
.. _Openstack Helm: https://github.com/openstack/openstack-helm
.. _Treasuremap: https://github.com/att-comdev/treasuremap
.. _yaml: http://yaml.org/
