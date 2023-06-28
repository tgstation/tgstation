GLOBAL_LIST_INIT(lazy_templates, generate_lazy_template_map())

/**
 * Iterates through all lazy template datums that exist and returns a list of them as an associative list of key -> instance.
 *
 * Screams if more than one key exists, loudly.
 */
/proc/generate_lazy_template_map()
	. = list()
	for(var/datum/lazy_template/template as anything in subtypesof(/datum/lazy_template))
		var/key = initial(template.key)
		if(key in .)
			stack_trace("Found multiple lazy templates with the same key! '[key]'")
		.[key] = new template
	return .
