package main

empty(value) {
  count(value) == 0
}
no_violations {
  empty(deny)
}

test_deployment_without_security_context {
  deny["Containers in deployment 'test' must not run as root"]
    with input as {"kind": "Deployment", "metadata": {"name": "test"}}
}

test_deployment_with_security_context {
  no_violations with input as {
    "kind": "Deployment",
    "metadata": { "name": "test" },
    "spec": { "template": { "spec": { "securityContext": { "runAsNonRoot": true }}}}
  }
}
