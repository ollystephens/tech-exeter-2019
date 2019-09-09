package kubernetes.admission

operations = {"CREATE", "UPDATE"}

deny[msg] {
	input.request.kind.kind == "Service"
	operations[input.request.operation]
	input.request.object.spec.type == "LoadBalancer"
	input.request.object.annotations["cloud.google.com/load-balancer-type"] != "Internal" 
	msg := "Load balancer services must be internal in this cluster"
}
