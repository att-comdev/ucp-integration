#Documentation
Each UCP component will maintain documentation addressing two audiences:

1. Consumer documentation
2. Developer documentation

## Consumer Documentation
Consumer documentation is that which is intended to be referenced by users of
the component. This includes information about each of the following:

- Introduction - the purpose and charter of the software
- Features - capabilies the software has
- Usage - interaction with the software - e.g. API and CLI documentation
- Setup/Installation - how an end user would set up and run the software
  including system requirements
- Support - where and how a user engages support or makes change requests for
  the software


## Developer Documentation
Developer documentation is used by developers of the software, and addresses
the following topics:

- Archiecture and Design - features and structure of the software
- Inline, Code, Method - documentaiton specific to the fuctions and procedures
  in the code
- Development Environment - explaining how a developer would need to configure
  a working environment for the software
- Contribution - how a developer can contribute to the software

## Format

There are multiple means by which consumers and developers will read the
documentation for UCP components. The two common places for UCP components are
[Github] in the form of README and code-based documentation, and
[Readthedocs] for more complete/formatted documentation.

Documentation that is expected to be read in Github must exist and may use
either [reStructuredText] or [Markdown]

Documentation intended for Readthedocs will use reStructuredText, and should
provide a [Sphinx] build of the documentation.

[reStructuredText]: http://www.sphinx-doc.org/en/stable/rest.html
[Markdown]: https://daringfireball.net/projects/markdown/syntax
[Readthedocs]: https://readthedocs.org/
[Github]: https://github.com
[Sphinx]: http://www.sphinx-doc.org/en/stable/index.html
