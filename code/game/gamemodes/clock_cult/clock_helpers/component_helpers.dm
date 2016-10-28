//generates a component in the global component cache, either random based on lowest or a specific component
/proc/generate_cache_component(specific_component_id)
	if(specific_component_id)
		clockwork_component_cache[specific_component_id]++
	else
		var/component_to_generate = get_weighted_component_id()
		clockwork_component_cache[component_to_generate]++

//returns a chosen component id based on the lowest amount of that component in the global cache, the global cache plus the slab if there are caches, or the slab if there are no caches.
/proc/get_weighted_component_id(obj/item/clockwork/slab/storage_slab)
	. = list()
	if(storage_slab)
		if(clockwork_caches)
			for(var/i in clockwork_component_cache)
				.[i] = max(MAX_COMPONENTS_BEFORE_RAND - LOWER_PROB_PER_COMPONENT*(clockwork_component_cache[i] + storage_slab.stored_components[i]), 1)
		else
			for(var/i in clockwork_component_cache)
				.[i] = max(MAX_COMPONENTS_BEFORE_RAND - LOWER_PROB_PER_COMPONENT*storage_slab.stored_components[i], 1)
	else
		for(var/i in clockwork_component_cache)
			.[i] = max(MAX_COMPONENTS_BEFORE_RAND - LOWER_PROB_PER_COMPONENT*clockwork_component_cache[i], 1)
	. = pickweight(.)

//returns a component name from a component id
/proc/get_component_name(id)
	switch(id)
		if("belligerent_eye")
			return "Belligerent Eye"
		if("vanguard_cogwheel")
			return "Vanguard Cogwheel"
		if("guvax_capacitor")
			return "Guvax Capacitor"
		if("replicant_alloy")
			return "Replicant Alloy"
		if("hierophant_ansible")
			return "Hierophant Ansible"
		else
			return null

//returns a component id from a component name
/proc/get_component_id(name)
	switch(name)
		if("Belligerent Eye")
			return "belligerent_eye"
		if("Vanguard Cogwheel")
			return "vanguard_cogwheel"
		if("Guvax Capacitor")
			return "guvax_capacitor"
		if("Replicant Alloy")
			return "replicant_alloy"
		if("Hierophant Ansible")
			return "hierophant_ansible"
		else
			return null

//returns a component spanclass from a component id
/proc/get_component_span(id)
	switch(id)
		if("belligerent_eye")
			return "neovgre"
		if("vanguard_cogwheel")
			return "inathneq"
		if("guvax_capacitor")
			return "sevtug"
		if("replicant_alloy")
			return "nezbere"
		if("hierophant_ansible")
			return "nzcrentr"
		else
			return null

//returns a component color from a component id
/proc/get_component_color(id)
	switch(id)
		if("belligerent_eye")
			return "#6E001A"
		if("vanguard_cogwheel")
			return "#1E8CE1"
		if("guvax_capacitor")
			return "#AF0AAF"
		if("replicant_alloy")
			return "#42474D"
		if("hierophant_ansible")
			return "#DAAA18"
		else
			return "#BE8700"

//returns a type for a floating component animation from a component id
/proc/get_component_animation_type(id)
	switch(id)
		if("belligerent_eye")
			return /obj/effect/overlay/temp/ratvar/component
		if("vanguard_cogwheel")
			return /obj/effect/overlay/temp/ratvar/component/cogwheel
		if("guvax_capacitor")
			return /obj/effect/overlay/temp/ratvar/component/capacitor
		if("replicant_alloy")
			return /obj/effect/overlay/temp/ratvar/component/alloy
		if("hierophant_ansible")
			return /obj/effect/overlay/temp/ratvar/component/ansible
		else
			return null

//returns a type for a component from a component id
/proc/get_component_type(id)
	switch(id)
		if("belligerent_eye")
			return /obj/item/clockwork/component/belligerent_eye
		if("vanguard_cogwheel")
			return /obj/item/clockwork/component/vanguard_cogwheel
		if("guvax_capacitor")
			return /obj/item/clockwork/component/guvax_capacitor
		if("replicant_alloy")
			return /obj/item/clockwork/component/replicant_alloy
		if("hierophant_ansible")
			return /obj/item/clockwork/component/hierophant_ansible
		else
			return null