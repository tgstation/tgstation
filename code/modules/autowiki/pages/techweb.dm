/datum/autowiki/techweb
	page = "Template:Autowiki/Content/Techweb"

/datum/autowiki/techweb/generate()
	var/output = ""

	for (var/node_path in sort_list(SSresearch.techweb_nodes, GLOBAL_PROC_REF(sort_research_nodes)))
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_path]
		if (!(node.node_flags & TECHWEB_NODE_WIKI))
			continue

		if (!valid_node(node))
			continue

		output += "\n\n" + include_template("Autowiki/TechwebEntry", list(
			"name" = escape_value(declent_ru_initial(node.display_name, NOMINATIVE, node.display_name)),
			"description" = escape_value(node.description),
			"prerequisites" = generate_prerequisites(node.prerequisite_nodes),
			"designs" = generate_designs(node.unlocked_designs),
		))

	return output

/datum/autowiki/techweb/proc/valid_node(datum/techweb_node/node)
	return !(node.node_flags & TECHWEB_NODE_EXPERIMENTAL)

/datum/autowiki/techweb/proc/generate_designs(list/designs_to_generate)
	var/output = ""

	for (var/design_path in designs_to_generate)
		var/datum/design/design = SSresearch.techweb_designs[design_path]
		output += include_template("Autowiki/TechwebEntryDesign", list(
			"name" = escape_value(declent_ru_initial(design.name, NOMINATIVE, design.name)),
			"description" = escape_value(design.get_description()),
		))

	return output

/datum/autowiki/techweb/proc/generate_prerequisites(list/prerequisites)
	var/output = ""

	for (var/node_path in prerequisites)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_path]
		output += include_template("Autowiki/TechwebEntryPrerequisite", list(
			"name" = escape_value(declent_ru_initial(node.display_name, NOMINATIVE, node.display_name)),
		))

	return output

/datum/autowiki/techweb/experimental
	page = "Template:Autowiki/Content/Techweb/Experimental"

/datum/autowiki/techweb/experimental/valid_node(datum/techweb_node/node)
	return (node.node_flags & TECHWEB_NODE_EXPERIMENTAL)

/proc/sort_research_nodes(node_path_a, node_path_b)
	var/datum/techweb_node/node_a = SSresearch.techweb_nodes[node_path_a]
	var/datum/techweb_node/node_b = SSresearch.techweb_nodes[node_path_b]

	var/prereq_difference = length(node_a.prerequisite_nodes) - length(node_b.prerequisite_nodes)
	if (prereq_difference != 0)
		return prereq_difference

	var/experiment_difference = length(node_a.required_experiments) - length(node_b.required_experiments)
	if (experiment_difference != 0)
		return experiment_difference

	return sorttext(node_b.display_name, node_a.display_name)
