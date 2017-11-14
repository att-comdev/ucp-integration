# Code and project conventions
Convetions and standards that guide the development and arrangement of UCP
component projects.

While this document is not a IETF RFC, [RFC 2119] provides for useful language
definitions. In this spirit:
* 'must', 'shall', 'will', and 'required' language indicates inflexible rules.
* 'should' and 'recommended' language is expected to be followed but reasonable
exceptions may exist.
* 'may' and 'can' lanugage is intended to be optional, but will provide a recommended approach if used.

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
Each project must provide a makefile at the root of the project. The makefile should implement each of the following makefile targets:

* 'images' will produce the docker images for the component and each other component it is responsible for building
* 'charts' will helm package all of the charts maintained as part of the project.
* 'lint' will perform code linting for the code and chart linting for the charts maintained as part of the project, as well as any other reasonable linting activity.
* 'dry-run' will produce a helm template for the charts maintained as part of the project.

Other makefile targets may exist.


[Docker]: https://www.docker.com/
[RFC 2119]: https://tools.ietf.org/html/rfc2119