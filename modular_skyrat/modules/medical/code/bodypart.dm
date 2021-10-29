/obj/item/bodypart/proc/apply_gauze(obj/item/stack/medical/gauze/new_gauze)
	if(!istype(new_gauze) || current_gauze)
		return
	current_gauze = new new_gauze.gauze_type(src)
	new_gauze.use(1)

/obj/item/bodypart/proc/apply_splint(obj/item/stack/medical/splint/new_splint)
	if(!istype(new_splint) || current_splint)
		return
	current_splint = new new_splint.splint_type(src)
	new_splint.use(1)
