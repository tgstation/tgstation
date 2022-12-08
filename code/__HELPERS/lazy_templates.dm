/proc/gen_lazy_template_map()
	. = list()
	for(var/datum/lazy_template/template as anything in subtypesof(/datum/lazy_template))
		var/key = initial(template.key)
		if(key in .)
			stack_trace("Found multiple lazy templates with the same key! '[key]'")
		.[key] = new template
