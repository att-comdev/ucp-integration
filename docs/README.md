# Undercloud Platform
The Undercloud Platform (UCP) is a collection of components that coordinate to
form a means of configuring and deploying and maintaining a [Kubernetes]
environment using a declarative set of [yaml] documents. More information about
the UCP and related comonents may be found by using the [Treasuremap]

## Approach
As the UCP revolves around the setup and use of Kubernetes and [Helm],
practices take cues from these projects. Since the sibling work of UCP is the
[Openstack Helm (OSH)] project, now an [Openstack] projet, cues are also taken
from the Openstack approach.

## Language
While these documents are not a IETF RFC, [RFC 2119] provides for useful
language definitions. In this spirit:
* 'must', 'shall', 'will', and 'required' language indicates inflexible rules.
* 'should' and 'recommended' language is expected to be followed but reasonable
exceptions may exist.
* 'may' and 'can' lanugage is intended to be optional, but will provide a recommended approach if used.

## Conventions and Standards
* [Api Conventions](api-conventions.md)
* [Service Logging](service-logging-conventions.md)
* [Alarming](alarming-conventions.md)
* [AuthenticationAuthorization/RBAC](rbac-conventions.md)
* [Code and Project Conventions](code-conventions.md)
* [Security Compliance](security-conventions.md)


[Helm]: https://helm.sh/
[Kubernetes]: https://kubernetes.io/
[Openstack]: https://www.openstack.org/
[Openstack Helm (OSH)]: https://github.com/openstack/openstack-helm
[Treasuremap]: https://github.com/att-comdev/treasuremap
[yaml]: http://yaml.org/
