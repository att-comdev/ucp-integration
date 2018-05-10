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

.. _monorepo:

UCP Monorepo
========================

This is a proposal for combining several Undercloud Platform repositories into
a monorepo.  This supports a robust development lifecycle with reliable testing
of coordinated changes and integrations and allows for cohesive documentation.

Overview
--------

A monorepo is a source code repository that combines separate, but related,
parts/modules of a single services ecosystem. These modules are separated based
on repository structure and configuration. Monorepos are common in the industry
and used by many significant development organizations. ACM has published
_commentary on Google's use of a monorepo:
https://cacm.acm.org/magazines/2016/7/204032-why-google-stores-billions-of-lines-of-code-in-a-single-repository/fulltext.

Advantages for UCP Development Workflow
---------------------------------------

There are several advantages gained by UCP developers when code is managed
in a monorepo - each of these either are an efficiency gain or a resiliency
gain, or both.

Coordinated Code Changes
~~~~~~~~~~~~~~~~~~~~~~~~

UCP is made of several separate modules, but they are tightly coupled in
some spots such that enhancements or fixes need to be coordinated between
modules. By utilizing a monorepo, these changes can be made in a single commit
ensuring that that changes to multiple repos ar  tested and merged in a
coordinated manner.

Shared Gating
~~~~~~~~~~~~~

Though each module has unique testing in the form of unit tests and functional
tests, the best test that a change does not break platform deployment or
upgrade is a fully integrated deployment of UCP and a follow-on upgrade. This
is most easily provided by a monorepo in which the latest code for each module
is used to run a deployment gate.

Stable Master Branch
~~~~~~~~~~~~~~~~~~~~

Combining the above, by ensuring that enhancements and fixes that require coordinated
changes are included in a single merge event and gating that merge on full deployment
pipeline, the monorepo supports greater stability in the tip of the master branch.
Users can be confident that any commit merged into the monorepo can be used to deploy
the platform without concerns about compatibility between modules.

Code Reuse and Cross-dependency
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Building shared common modules and supporting cross-depedencies between modules
is low-effort. A monorepo prevents building module images with stale dependency
code. This is true as well with common code shared between all modules.

Converged Documentation
~~~~~~~~~~~~~~~~~~~~~~~

While each UCP module has unique documentation, there is significant areas where
integrating two components needs to be documented. There are also areas that all
the modules can reference common documentation for a shared standard.

Challenges to Overcome
----------------------

While the monorepo provides significant advantages for developers and for the
automated pipelines, there are challenges in converting the existing repositories
to a single converged repositories.

Complicated Layout and Additional Tooling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Supporting multiple artifacts (Helm charts, Docker images, Python packages, ...)
across multiple modules requires a more complicated repository structure
and more complex build tooling. Simple entrypoints like ``tox`` may no longer
be adequate. But there are already community tools in use at monorepo shops such
as _pants https://www.pantsbuild.org/, _bazel https://bazel.build/  and
_buck https://buckbuild.com/.

Time
~~~~

Both the straight labor of doing the work as well as the time to troubleshoot
the build issues from using the above tools will take time. The pace of deadlines
and support requests doesn't leave much time for this. But the advantages will
pay off in the long run.
