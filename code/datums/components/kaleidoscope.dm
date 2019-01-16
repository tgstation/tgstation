/datum/component/kaleidoscope
	var/list/colours
	var/mode = KALEDIOSCOPE_RANDOM_COLOUR
	var/colour_priority = ADMIN_COLOUR_PRIORITY
	var/delay = 1
	var/cleanup = TRUE
	var/_index = 1 // Curse you DM, and your 1-indexed lists

/datum/component/kaleidoscope/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	paint()

/datum/component/kaleidoscope/proc/paint()
	if(QDELETED(src))
		return
	var/chosen
	switch(mode)
		if(KALEDIOSCOPE_ORDERED_LIST)
			chosen = colours[_index]
			if(_index >= length(colours))
				_index = 1
			else
				_index = _index + 1
		if(KALEDIOSCOPE_PICK_FROM_LIST)
			chosen = pick(colours)
		if(KALEDIOSCOPE_RANDOM_COLOUR)
			chosen = "#[random_color()]"

	var/atom/A = parent
	A.add_atom_colour(chosen, colour_priority)
	addtimer(CALLBACK(src, .proc/paint), delay, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/component/kaleidoscope/UnregisterFromParent()
	if(cleanup)
		var/atom/A = parent
		A.remove_atom_colour(colour_priority)

/datum/component/kaleidoscope/suicide_by_disk
	colours = list("#00FF00", "#FF0000")
	mode = KALEDIOSCOPE_ORDERED_LIST

/datum/component/kaleidoscope/colorful_reagent
	colours = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")
	mode = KALEDIOSCOPE_PICK_FROM_LIST
	colour_priority = WASHABLE_COLOUR_PRIORITY
	delay = 10
	cleanup = FALSE

/datum/component/kaleidoscope/colorful_reagent/once/paint()
	..()
	qdel(src)
