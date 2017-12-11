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

.. _code-conventions:

Code and Project Conventions
============================

Conventions and standards that guide the development and arrangement of UCP
component projects.

Project Structure
-----------------

Charts
~~~~~~
Each project that maintains helm charts will keep those charts in a directory
'charts' located at the root of the project. The charts directory will contain
subdirectories for each of the charts maintained as part of that project.
These subdirectories should be named for the component represented by that
chart.

e.g.: For project 'foo', which also maintains the charts for 'bar' and 'baz':
-  foo/charts/foo contains the chart for 'foo'
-  foo/charts/bar contains the chart for 'bar'
-  foo/charts/baz contains the chart for 'baz'

Helm charts utilize the `helm-toolkit`_ supported by the `Openstack-Helm`_ team
and follow the standards documented there.

Images
~~~~~~
Each project that creates a `Docker`_ image will keep the dockerfile in a
directory 'images' located at the root of the project. The images directory
will contain subdirectories for each of the images created as part of that
project. The subdirectory will contain the dockerfile that can be used to
generate the image.

e.g.: For project 'foo', which also produces a Docker image for 'bar'
-  foo/images/foo contains the dockerfile for 'foo'
-  foo/images/bar contains the dockerfile for 'bar'

Makefile
~~~~~~~~
Each project must provide a makefile at the root of the project. The makefile
should implement each of the following makefile targets:

-  'images' will produce the docker images for the component and each other
   component it is responsible for building.
-  'charts' will helm package all of the charts maintained as part of the
   project.
-  'lint' will perform code linting for the code and chart linting for the
   charts maintained as part of the project, as well as any other reasonable
   linting activity.
-  'dry-run' will produce a helm template for the charts maintained as part of
   the project.
-  'all' will run the lint, charts, and images targets.
-  'docs' should render any documentation that has build steps.
-  'run_{component_name}' should build the image and do a rudimentary (at
   least) test of the image's functionality.
-  'run_images' performs the inidividual run_{component_name} targets for
   projects that produce more than one image.

Other makefile targets may exist. A 'test' endpoint is encouraged. For projects
that are Python based, the makefile targets should reference tox commands, and
those projects should include a tox.ini defining the Tox targets.

Documentation
~~~~~~~~~~~~~
Also see :ref:`documentation-conventions`

Documentation source for the component should reside in a 'docs' directory at
the root of the project.

Linting and Formatting Standards
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Code in the UCP components should follow the prevalent linting and formatting
standards for the language being implemented. Examples include PEP-8 for Python
and Gofmt for Go. In lieu of industry accepted code formatting standards for a
target language, strive for readability and maintainability.

UCP components must provide for automated checking of their formatting
standards, such as the lint step noted above in the makefile. Components may
provide automated reformatting.

Python Formatting
^^^^^^^^^^^^^^^^^
Python-based components should conform to PEP-8. Further conventions may be
applied in addition if they provide further clarity for the component's
development.

Sample Project Structure
~~~~~~~~~~~~~~~~~~~~~~~~
Project foo, supporting a second deliverable bar::

  foo
   |- /docs
   |    |- README
   |- /etc
   |    |- /foo
   |         |- {sample files}
   |- /charts
   |    |- /foo
   |    |- /bar
   |- /images
   |    |- /foo
   |    |    |- Dockerfile
   |    |- /bar
   |         |- Dockerfile
   |- /tools
   |    |- {scripts/utilities supporting build and test}
   |- /foo   (or foo-{modulename})
   |    |- control  (if an API is being exposed)
   |    |- tests
   |        |- unit
   |        |- functional
   |- /bar  (second deliverable source)
        |- tests
            |- unit
            |- functional
   |- Makefile
   |- README  (suitable for github consumption)
   |- tox.ini  (python)

Note that this is a sample structure, and that target languages may preclude
the location of some items (e.g. tests). For those components with language
or ecosystem standards contrary to this structure, ecosystem convention should
prevail.


.. _Docker: https://www.docker.com/
.. _helm-toolkit: https://github.com/openstack/openstack-helm/tree/master/helm-toolkit
.. _Openstack-Helm: https://wiki.openstack.org/wiki/Openstack-helm
