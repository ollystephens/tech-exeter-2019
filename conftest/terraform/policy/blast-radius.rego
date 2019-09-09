package main

import input as tfplan

########################
# Parameters for Policy
########################

# acceptable score for automated authorization
blast_radius = 10

# weights assigned for each operation on each resource-type
weights = {
    "aws_autoscaling_group": {"delete": 100, "create": 10, "modify": 1},
    "aws_instance": {"delete": 10, "create": 1, "modify": 1}
}

# Consider exactly these resource types in calculations
resource_types = {"aws_autoscaling_group", "aws_instance", "aws_iam", "aws_launch_configuration"}

#########
# Policy
#########

# Authorization holds if score for the plan is acceptable and no changes are made to IAM
deny[msg] {
    score > blast_radius
    msg = sprintf("Makes too many changes, scoring %v which is greater than current maximum %v", [score, blast_radius])
}

# Compute the score for a Terraform plan as the weighted sum of deletions, creations, modifications
score = s {
    all := [ x |
            some resource_type
            crud := weights[resource_type];
            del := crud["delete"] * num_deletes[resource_type];
            new := crud["create"] * num_creates[resource_type];
            mod := crud["modify"] * num_modifies[resource_type];
            x := del + new + mod
    ]
    s := sum(all)
}

####################
# Terraform Library
####################

# list of all resources of a given type
instance_names[resource_type] = all {
    some resource_type
    resource_types[resource_type]
    all := [name |
        tfplan[name] = _
        startswith(name, resource_type)
    ]
}

# number of deletions of resources of a given type
num_deletes[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := instance_names[resource_type]
    deletions := [name | name := all[_]; tfplan[name]["destroy"] == true]
    num := count(deletions)
}

# number of creations of resources of a given type
num_creates[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := instance_names[resource_type]
    creates := [name | all[_] = name; tfplan[name]["id"] == ""]
    num := count(creates)
}

# number of modifications to resources of a given type
num_modifies[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := instance_names[resource_type]
    modifies := [name | name := all[_]; obj := tfplan[name]; obj["destroy"] == false; not obj["id"]]
    num := count(modifies)
}
