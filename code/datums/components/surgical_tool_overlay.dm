#define TIER_ALIEN 3
#define TIER_ADVANCED 2
#define TIER_CRUEL 1
#define TIER_NORMAL 0

/datum/component/surgical_tool_overlay
	var/tray_toggled = FALSE

/datum/component/surgical_tool_overlay/Initialize()
	.=..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/surgical_tool_overlay/RegisterWithParent()
	.=..()
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_overlays))
	RegisterSignal(parent, COMSIG_SURGERY_TRAY_TOGGLE, PROC_REF(toggle_tray_state))

/datum/component/surgical_tool_overlay/proc/toggle_tray_state(atom/my_bag, new_state)
	tray_toggled = new_state

/// Check contents for the overlays
/datum/component/surgical_tool_overlay/proc/update_overlays(atom/my_bag, list/overlays)
	SIGNAL_HANDLER

	var/scalpel_overlay
	var/cautery_overlay
	var/hemostat_overlay
	var/retractor_overlay
	var/drill_overlay
	var/saw_overlay
	var/has_bonesetter = FALSE
	var/has_drapes = FALSE
	var/has_filter = FALSE
	var/has_razor = FALSE
	var/has_tape = FALSE
	var/has_gel = FALSE

	for (var/obj/item/tool in my_bag.contents)
		if (istype(tool, /obj/item/surgical_drapes))
			has_drapes = TRUE
			continue
		if (istype(tool, /obj/item/bonesetter))
			has_bonesetter = TRUE
			continue
		if (istype(tool, /obj/item/blood_filter))
			has_filter = TRUE
			continue
		if (istype(tool, /obj/item/razor))
			has_razor = TRUE
			continue

		if (istype(tool, /obj/item/scalpel))
			if (scalpel_overlay == TIER_ALIEN)
				continue
			if (istype(tool, /obj/item/scalpel/alien))
				scalpel_overlay = TIER_ALIEN
				continue
			if (scalpel_overlay == TIER_ADVANCED)
				continue
			if (istype(tool, /obj/item/scalpel/advanced))
				scalpel_overlay = TIER_ADVANCED
				continue
			if (scalpel_overlay == TIER_CRUEL)
				continue
			if (istype(tool, /obj/item/scalpel/cruel))
				scalpel_overlay = TIER_CRUEL
				continue
			scalpel_overlay = TIER_NORMAL
			continue

		if (istype(tool, /obj/item/cautery))
			if (cautery_overlay == TIER_ALIEN)
				continue
			if (istype(tool, /obj/item/cautery/alien))
				cautery_overlay = TIER_ALIEN
				continue
			if (cautery_overlay == TIER_ADVANCED)
				continue
			if (istype(tool, /obj/item/cautery/advanced))
				cautery_overlay = TIER_ADVANCED
				continue
			if (cautery_overlay == TIER_CRUEL)
				continue
			if (istype(tool, /obj/item/cautery/cruel))
				cautery_overlay = TIER_CRUEL
				continue
			cautery_overlay = TIER_NORMAL
			continue

		if (istype(tool, /obj/item/hemostat))
			if (hemostat_overlay == TIER_ALIEN)
				continue
			if (istype(tool, /obj/item/hemostat/alien))
				hemostat_overlay = TIER_ALIEN
				continue
			if (hemostat_overlay == TIER_CRUEL)
				continue
			if (istype(tool, /obj/item/hemostat/cruel))
				hemostat_overlay = TIER_CRUEL
				continue
			hemostat_overlay = TIER_NORMAL
			continue

		if (istype(tool, /obj/item/retractor))
			if (retractor_overlay == TIER_ALIEN)
				continue
			if (istype(tool, /obj/item/retractor/alien))
				retractor_overlay = TIER_ALIEN
				continue
			if (retractor_overlay == TIER_ADVANCED)
				continue
			if (istype(tool, /obj/item/retractor/advanced))
				retractor_overlay = TIER_ADVANCED
				continue
			if (retractor_overlay == TIER_CRUEL)
				continue
			if (istype(tool, /obj/item/retractor/cruel))
				retractor_overlay = TIER_CRUEL
				continue
			retractor_overlay = TIER_NORMAL
			continue

		if (istype(tool, /obj/item/surgicaldrill))
			if (drill_overlay == TIER_ALIEN)
				continue
			if (istype(tool, /obj/item/surgicaldrill/alien))
				drill_overlay = TIER_ALIEN
				continue
			drill_overlay = TIER_NORMAL
			continue

		if (istype(tool, /obj/item/circular_saw))
			if (saw_overlay == TIER_ALIEN)
				continue
			if (istype(tool, /obj/item/circular_saw/alien))
				saw_overlay = TIER_ALIEN
				continue
			saw_overlay = TIER_NORMAL
			continue

	for (var/obj/item/stack in my_bag.contents)
		if(istype(stack, /obj/item/stack/medical/bone_gel))
			has_gel = TRUE
			continue
		if(istype(stack, /obj/item/stack/sticky_tape/surgical))
			has_tape = TRUE
			continue

	if (has_bonesetter)
		overlays |= tray_toggled ? "bonesetter_out" : "bonesetter"
	if (has_drapes)
		overlays |= "drapes"
	if (has_filter)
		overlays |= "filter"
	if (has_razor)
		overlays |= "razor"
	if (has_tape)
		overlays |= tray_toggled ? "tape_out" : "tape"
	if (has_gel)
		overlays |= tray_toggled ? "gel_out" : "gel"
	switch(scalpel_overlay)
		if(TIER_ALIEN)
			overlays += "scalpel_alien"
		if(TIER_ADVANCED)
			overlays += "scalpel_advanced"
		if(TIER_CRUEL)
			overlays += "scalpel_cruel"
		if(TIER_NORMAL)
			overlays += "scalpel_normal"
	switch(cautery_overlay)
		if(TIER_ALIEN)
			overlays += "cautery_alien"
		if(TIER_ADVANCED)
			overlays += "cautery_advanced"
		if(TIER_CRUEL)
			overlays += "cautery_cruel"
		if(TIER_NORMAL)
			overlays += "cautery_normal"
	switch(hemostat_overlay)
		if(TIER_ALIEN)
			overlays += "hemostat_alien"
		if(TIER_CRUEL)
			overlays += "hemostat_cruel"
		if(TIER_NORMAL)
			overlays += "hemostat_normal"
	switch(retractor_overlay)
		if(TIER_ALIEN)
			overlays += "retractor_alien"
		if(TIER_ADVANCED)
			overlays += "retractor_advanced"
		if(TIER_CRUEL)
			overlays += "retractor_cruel"
		if(TIER_NORMAL)
			overlays += "retractor_normal"
	switch(drill_overlay)
		if(TIER_ALIEN)
			overlays += "drill_alien"
		if(TIER_NORMAL)
			overlays += "drill_normal"
	switch(saw_overlay)
		if(TIER_ALIEN)
			overlays += "saw_alien"
		if(TIER_NORMAL)
			overlays += "saw_normal"

/datum/component/surgical_tool_overlay/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS)
	return ..()

#undef TIER_ALIEN
#undef TIER_ADVANCED
#undef TIER_CRUEL
#undef TIER_NORMAL
