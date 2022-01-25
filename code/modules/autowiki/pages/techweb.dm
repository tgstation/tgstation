/datum/autowiki/techweb
	page = "User:Mothblocks/Techweb"

/datum/autowiki/techweb/generate()
	var/output = ""

	// MOTHBLOCKS TODO: Stable sort, ideally in order of requirements
	for (var/node_id in SSresearch.techweb_nodes)
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

