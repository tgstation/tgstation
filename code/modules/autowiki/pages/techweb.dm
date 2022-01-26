/datum/autowiki/techweb
	page = "Template:Autowiki/Techweb"

/datum/autowiki/techweb/generate()
	var/output = ""

	for (var/node_id in sort_list(SSresearch.techweb_nodes, /proc/sort_research_nodes))
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		if (!node.show_on_wiki)
			continue

		output += "\n\n" + include_template("Autowiki/TechwebEntry", list(
			"name" = escape_value(node.display_name),
			"description" = escape_value(node.description),
			"prerequisites" = generate_prerequisites(node.prereq_ids),
			"designs" = generate_designs(node.design_ids),
		))

	return output

/datum/autowiki/techweb/proc/generate_designs(list/design_ids)
	var/output = ""

	for (var/design_id in design_ids)
		var/datum/design/design = SSresearch.techweb_designs[design_id]
		output += include_template("Autowiki/TechwebEntryDesign", list(
			"name" = escape_value(design.name),
			"description" = escape_value(design.get_description()),
		))

	return output

/datum/autowiki/techweb/proc/generate_prerequisites(list/prereq_ids)
	var/output = ""

	for (var/prereq_id in prereq_ids)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[prereq_id]
		output += include_template("Autowiki/TechwebEntryPrerequisite", list(
			"name" = escape_value(node.display_name),
		))

	return output

/proc/sort_research_nodes(node_id_a, node_id_b)
	var/datum/techweb_node/node_a = SSresearch.techweb_nodes[node_id_a]
	var/datum/techweb_node/node_b = SSresearch.techweb_nodes[node_id_b]

	var/experiment_difference = node_a.required_experiments.len - node_b.required_experiments.len
	if (experiment_difference != 0)
		return experiment_difference

	return sorttext(node_b.display_name, node_a.display_name)
