/datum/buildmode_mode
	var/key = "oops"

	var/datum/buildmode/BM

	// would corner selection work better as a component?
	var/list/preview
	var/turf/cornerA
	var/turf/cornerB

/datum/buildmode_mode/New(datum/buildmode/BM)
	src.BM = BM
	preview = list()
	return ..()

/datum/buildmode_mode/Destroy()
	Reset()
	return ..()

/datum/buildmode_mode/proc/enter_mode(datum/buildmode/BM)
	return

/datum/buildmode_mode/proc/exit_mode(datum/buildmode/BM)
	return

/datum/buildmode_mode/proc/get_button_iconstate()
	return "buildmode_[key]"

/datum/buildmode_mode/proc/show_help(mob/user)
	CRASH("No help defined, yell at a coder")

/datum/buildmode_mode/proc/change_settings(mob/user)
	to_chat(user, "<span class='warning'>There is no configuration available for this mode</span>")
	return

/datum/buildmode_mode/proc/Reset()
	deselect_region()

/datum/buildmode_mode/proc/select_tile(turf/T, corner_to_select)
	var/overlaystate
	BM.holder.images -= preview
	switch(corner_to_select)
		if(AREASELECT_CORNERA)
			overlaystate = "greenOverlay"
		if(AREASELECT_CORNERB)
			overlaystate = "blueOverlay"
	preview += image('icons/turf/overlays.dmi', T, overlaystate)
	BM.holder.images += preview
	return T

/datum/buildmode_mode/proc/highlight_region(region)
	BM.holder.images -= preview
	for(var/t in region)
		preview += image('icons/turf/overlays.dmi', t, "redOverlay")
	BM.holder.images += preview

/datum/buildmode_mode/proc/deselect_region()
	BM.holder.images -= preview
	preview.Cut()
	cornerA = null
	cornerB = null

/datum/buildmode_mode/proc/handle_click(user, params, object)
	return