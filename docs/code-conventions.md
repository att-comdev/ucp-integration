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

Other makefile targets may exist. A 'test' endpoint is encouraged.

### Documentation
Documentation and/or documentation source for the component should reside in a
'docs' directory at the root of the project.

### Linting and formatting standards
Code in the UCP components should follow the prevalent linting and formatting
standards for the language being implemented. Examples include Pep-8 for Python and Gofmt for Go.

UCP components must provide for automation of their formatting standards, such
as the lint step noted above in the makefile.

In lieu of industry accepted code formatting standards for a target language,
strive for readability and maintainability. Here is a short list of factors
that support readability and maintainability:
* Formatting of code is for humans to read. Computers really don't care too
much as long as it's valid instructions.
* Use of language elements that provide greater readability are preferred over less readable equivalent elements.
* Indentation is supported (and in some cases required). Use it. With some
exceptions (e.g. makefiles), spaces are preferred for indentation over tabs.
Indentation of 4 space increments is generally preferred.
* Documentation and documentation comments are expected to be accurate,
non-trivial, and thorough.
* Favor rational over pedantic formatting rules for the code. Document those
rules in the codebase so that they can be known by successors.
* Consistency within a project is as important as the rules themselves. This
allows successors to become familiar with the code more easily.


[Docker]: https://www.docker.com/
[RFC 2119]: https://tools.ietf.org/html/rfc2119