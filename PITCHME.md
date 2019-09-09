## Policy as Code

### Why you should, how you can

Olly Stephens, Tech Exeter 2019

---

@snap[north-west span-50]
### Agenda

- Scene setting
- A quick introduction to [Open Policy Agent](https://www.openpolicyagent.org/)
- OPA at run time examples
- Shift-left testing
- OPA at build time examples
@snapend

@snap[north-east span-50]
### About Me

- Architect; Technologist; Gopher
- Head of Platform Engineering at Adarga Ltd
- Self-confessed giant shoulder standerer
- _(today's thanks go to Gareth Rushgrove)_
@snapend

---

## Congratulations

You've worked really hard and you now have a rock solid [Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_code) setup.
No more snowflakes; no more point-and-click configuration.
You rely on [Terraform](https://www.terraform.io/) and
[Kubernetes](https://kubernetes.io/) manifests to build your entire tech stack.
It's done declaratively - you specify what it should look like and the tooling makes it happen. Life is good.

---

## And - somewhere - we have some policies written down

@snap[west span-40]

- Don't do stupid things
- Follow our in-house conventions

@snapend

---

## But where are the guard rails?

---

# Open Policy Agent

A policy enforcement engine for configuration

---

![OPA Benefits](assets/img/opa-benefits.svg)

---

## Kubernetes Example

@fa[quote-left] Developers are not allowed to create public facing services in the DEV kube cluster @fa[quote-right]

---

@snap[north span-100]
@code[ruby](gatekeeper/only-internal-lbs.rego)
@snapend

@snap[south span-100]
@[3,6,7, zoom-10](If we are creating or updating a Service.)
@[8,     zoom-10](And it's type is LoadBalancer.)
@[9,10,  zoom-10](And it doesn't have this annotation.)
@[5,11,  zoom-10](Then deny the request.)
@snapend

---

## Kubernetes Example

@fa[quote-left] Ingress names must be whitelisted @fa[quote-right]

---

@snap[north span-100]
@code[ruby](gatekeeper/whitelist-ingress.rego)
@snapend

@snap[south span-100]
@[10,11, zoom-100](Is the host name whitelisted?)
@[16,17, zoom-100](Whitelisted names are attached to namespace)

---

# Shift Left

Shift-left testing is an approach to software testing and system testing in which testing is performed earlier in the lifecycle (i.e., moved left on the project timeline). It is the first half of the maxim "Test early and often."
[Wikipedia](https://en.wikipedia.org/wiki/Shift-left_testing)

---

@snap[west span-25 text-08]
@box[bg-gold](Local development)
@snapend

@snap[south-west span-25 text-08]
@fa[rocket]Fast
@snapend

@snap[midpoint span-25 text-08]
@box[bg-gold](Continuous integration)
@snapend

@snap[east span-25 text-08]
@box[bg-gold](Cluster)
@snapend

---

# conftest

Write tests against structured configuration data using the Open Policy Agent Rego query language.

---

### Can still check our kubernetes manifests

@code[ruby](conftest/kubernetes/policy/run-as-non-root.rego)

---

### and...

@code[ruby](conftest/kubernetes/policy/must-have-labels.rego)

---

### but this time, we can do it before we push

#### or as part of a continuous deployment trigger

```bash
% conftest test ./bad-deploy.yaml && echo OK
FAIL - ./bad-deploy.yaml - Deployment 'tokenizer' must include standard labels
FAIL - ./bad-deploy.yaml - Containers in deployment 'tokenizer' must not run as root
% conftest test ./good-deploy.yaml && echo OK
OK
```

---

### Similarly with Terraform

@code[ruby](conftest/terraform/policy/cost-codes.rego)

---

#### ...with a little hoop jumping

```bash
% terraform plan -out tfplan
% terraform show -json tfplan | conftest test -
FAIL - aws_internet_gateway.my-vpc-igw does not have cost_code tag
FAIL - aws_vpc.my-vpc does not have cost_code tag
```

---

#### Protect blast radius when auto-deploying

@code[ruby zoom-05](conftest/terraform/policy/blast-radius-core.rego)

---

### Moving back from CD to CI

Snyk example

@code[ruby zoom-05](conftest/snyk/policy/waivers.rego)

Registry example

---

### Testing policies