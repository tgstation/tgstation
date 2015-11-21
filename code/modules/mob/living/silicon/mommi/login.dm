/mob/living/silicon/robot/mommi/Login()

	..()
	/* Inherited
	regenerate_icons()
	show_laws(0)
	if(mind)
		ticker.mode.remove_revolutionary(mind)
	return
	*/
	if(can_see_static())
		add_static_overlays()

/mob/living/silicon/robot/mommi/proc/can_see_static()
	return (keeper && !emagged && !syndicate && (config && config.mommi_static))

/mob/living/silicon/robot/mommi/proc/add_static_overlays()
	remove_static_overlays()
	for(var/mob/living/living in mob_list)
		if(istype(living, /mob/living/silicon))
			continue
		var/image/chosen
		if(static_choice in living.static_overlays)
			chosen = living.static_overlays[static_choice]
		else
			chosen = living.static_overlays[1]
		static_overlays.Add(chosen)
		client.images.Add(chosen)

/mob/living/silicon/robot/mommi/proc/remove_static_overlays()
	if(client)
		for(var/image/I in static_overlays)
			client.images.Remove(I)
	static_overlays.len = 0

/mob/living/silicon/robot/mommi/verb/toggle_statics()
	set name = "Change Vision Filter"
	set desc = "Change the filter on the system used to remove organics from your viewscreen."
	set category = "Robot Commands"

	if(!can_see_static())
		return
	var/selected_style = input("Select a vision filter", "Vision Filter") as null|anything in static_choices
	if(selected_style in static_choices)
		static_choice = selected_style
		add_static_overlays()