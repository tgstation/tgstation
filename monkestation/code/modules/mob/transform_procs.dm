/mob/living/carbon/gorillize(keep_name = null)
	var/old_name = real_name || name
	if(isnull(keep_name))
		keep_name = !isnull(key)
	var/mob/living/basic/gorilla/gorilla = ..()
	if(keep_name && old_name && gorilla)
		gorilla.name = gorilla.real_name = old_name
		gorilla.update_name_tag(old_name)
	return gorilla
