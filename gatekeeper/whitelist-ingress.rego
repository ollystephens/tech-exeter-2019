package kubernetes.admission

import data.kubernetes.namespaces

operations = {"CREATE", "UPDATE"}

deny[msg] {
	input.request.kind.kind == "Ingress"
	operations[input.request.operation]
	host := input.request.object.spec.rules[_].host
	not fqdn_matches_any(host, valid_ingress_hosts)
	msg := sprintf("invalid ingress host %q", [host])
}

valid_ingress_hosts = {host |
	whitelist := namespaces[input.request.namespace]
                       .metadata.annotations["ingress-whitelist"]
	hosts := split(whitelist, ",")
	host := hosts[_]
}
