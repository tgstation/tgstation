/obj/effect/spawner/template
	name = "map template spawner"
	var/template_name

/obj/effect/spawner/template/Initialize() // I am so glad SSmapping initializes before SSatoms, otherwise so much fuckery would be needed here
	. = ..()
	if(!template_name)
		stack_trace("Tried to spawn a non-existent structure at [COORD(src)]!")
	var/datum/map_template/template = SSmapping.map_templates[template_name]
	if(!template)
		stack_trace("Tried to spawn a non-existent structure ([template_name]) at [COORD(src)]!")
	var/turf/T = get_turf(src)
	if(!T)
		return
	if(!template.load(T, centered = TRUE))
		stack_trace("Failed to place structure \"[template_name]\" at [COORD(src)]!")
	return INITIALIZE_HINT_QDEL