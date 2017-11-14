# Code and project conventions
Convetions and standards that guide the development and arrangement of UCP
component projects.

## Project Structure

### Charts
Each project that maintains helm charts will keep those charts in a directory
'charts' located at the root of the project. The charts directory will contain
subdirectories for each of the charts maintained as part of that project.
These subdirectories should be named for the component represented by that
chart.

e.g.: For project 'foo', which also maintains the charts for 'bar' and 'baz':
* foo/charts/foo contains the chart for 'foo'
* foo/charts/bar contains the chart for 'bar'
* foo/charts/baz contains the chart for 'baz'

Helm charts utilize the [helm-toolkit] supported by the [Openstack-Helm] team
and follow the standards documented there.

### Images
Each project that creates a [Docker] image will keep the dockerfile in a
directory 'images' located at the root of the project. The images directory
will contain subdirectories for each of the images created as part of that
project. The subdirectory will contain the dockerfile that can be used to
generate the image.

e.g.: For project 'foo', which also produces a Docker image for 'bar'
* foo/images/foo contains the dockerfile for 'foo'
* foo/images/bar contains the dockerfile for 'bar'

### Makefile
Each project must provide a makefile at the root of the project. The makefile
should implement each of the following makefile targets:

* 'images' will produce the docker images for the component and each other
component it is responsible for building.
* 'charts' will helm package all of the charts maintained as part of the
project.
* 'lint' will perform code linting for the code and chart linting for the
charts maintained as part of the project, as well as any other reasonable
linting activity.
* 'dry-run' will produce a helm template for the charts maintained as part of
the project.
* 'all' will run the lint, charts, and images targets.

Other makefile targets may exist. A 'test' endpoint is encouraged.

### Documentation
Documentation and/or documentation source for the component should reside in a
'docs' directory at the root of the project.

### Linting and formatting standards
Code in the UCP components should follow the prevalent linting and formatting
standards for the language being implemented. Examples include Pep-8 for Python
and Gofmt for Go.

UCP components must provide for automation of their formatting standards, such
as the lint step noted above in the makefile.

In lieu of industry accepted code formatting standards for a target language,
strive for readability and maintainability.

### Sample Project Structure
Project foo, supporting a second deliverable bar:
```
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
 |- /bar  (second deliverable's source)
      |- tests
          |- unit
          |- functional
 |- Makefile
 |- README
```

[Docker]: https://www.docker.com/
[RFC 2119]: https://tools.ietf.org/html/rfc2119
[helm-toolkit]: https://github.com/openstack/openstack-helm/tree/master/helm-toolkit
[Openstack-Helm]: https://wiki.openstack.org/wiki/Openstack-helm
