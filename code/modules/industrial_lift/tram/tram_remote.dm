#define TRAMCTRL_INBOUND "inbound"
#define TRAMCTRL_OUTBOUND "outbound"
#define TRAMCTRL_SAFE "safe"
#define TRAMCTRL_FAST "fast"

/obj/item/tram_remote
	icon_state = "tramremote_nis"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	icon = 'icons/obj/device.dmi'
	name = "tram remote"
	desc = "A remote control that can be linked to a tram. This can only go well."
	w_class = WEIGHT_CLASS_TINY
	///desired tram direction
	var/direction = TRAMCTRL_INBOUND
	///fast and fun, or safe and boring
	var/mode = TRAMCTRL_FAST
	///weakref to the tram piece we control
	var/datum/weakref/tram_ref

///set tram control direction
/obj/item/tram_remote/attack_self_secondary(mob/user)
	var/static/list/desc = list(TRAMCTRL_INBOUND = "< inbound", TRAMCTRL_OUTBOUND = "outbound >")
	switch(direction)
		if(TRAMCTRL_INBOUND)
			direction = TRAMCTRL_OUTBOUND
		if(TRAMCTRL_OUTBOUND)
			direction = TRAMCTRL_INBOUND
	update_appearance()
	balloon_alert(user, "direction: [desc[direction]]")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

///set safety bypass
/obj/item/tram_remote/CtrlClick(mob/user)
	var/static/list/desc = list(TRAMCTRL_SAFE = "safe", TRAMCTRL_FAST = "fast")
	switch(mode)
		if(TRAMCTRL_SAFE)
			mode = TRAMCTRL_FAST
		if(TRAMCTRL_FAST)
			mode = TRAMCTRL_SAFE
	update_appearance()
	balloon_alert(user, "mode: [desc[mode]]")

/obj/item/tram_remote/examine(mob/user)
	. = ..()
	if(!tram_ref)
		. += "There is an X showing on the display."
		. += "Left-click a tram request button to link."
		return
	else
		switch(direction)
			if(TRAMCTRL_INBOUND)
				. += "The arrow on the display is pointing inbound."
			if(TRAMCTRL_OUTBOUND)
				. += "The arrow on the display is pointing outbound."
		switch(mode)
			if(TRAMCTRL_FAST)
				. += "The rapid mode light is on."
			if(TRAMCTRL_SAFE)
				. += "The rapid mode light is off."
		. += "Left-click to dispatch tram."
		. += "Right-click to toggle direction."
		. += "CTRL-click to toggle safety bypass."

/obj/item/tram_remote/update_overlays()
	. = ..()
	if(!tram_ref)
		icon_state = "tramremote_nis"
		return
	switch(direction)
		if(TRAMCTRL_INBOUND)
			icon_state = "tramremote_ib"
		if(TRAMCTRL_OUTBOUND)
			icon_state = "tramremote_ob"
	if(mode == TRAMCTRL_FAST)
		. += mutable_appearance(icon, "tramremote_emag")

/obj/item/tram_remote/attack_self(mob/user)
	try_force_tram(user)

///send our selected commands to the tram
/obj/item/tram_remote/proc/try_force_tram(mob/user)
	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(!tram_part)
		balloon_alert(user, "no tram linked!")
		return
	if(tram_part.controls_locked || tram_part.travelling) // someone else started already
		balloon_alert(user, "tram busy!")
		return
	var/tram_id = tram_part.specific_lift_id
	var/destination_platform = null
	var/platform = 0
	switch(direction)
		if(TRAMCTRL_INBOUND)
			platform = clamp(tram_part.idle_platform.platform_code - 1, 1, INFINITY)
		if(TRAMCTRL_OUTBOUND)
			platform = clamp(tram_part.idle_platform.platform_code + 1, 1, INFINITY)
	if(platform == tram_part.idle_platform.platform_code)
		balloon_alert(user, "invalid command!")
		return
	for (var/obj/effect/landmark/tram/destination as anything in GLOB.tram_landmarks[tram_id])
		if(destination.platform_code == platform)
			destination_platform = destination
			break
	if(!destination_platform)
		balloon_alert(user, "invalid command!")
		return
	else
		switch(mode)
			if(TRAMCTRL_FAST) // arg is TRUE to bypass safeties
				tram_part.tram_travel(destination_platform, TRUE)
			if(TRAMCTRL_SAFE)
				tram_part.tram_travel(destination_platform, FALSE)
		balloon_alert(user, "tram dispatched")

/obj/item/tram_remote/afterattack(atom/target, mob/user)
	link_tram(user, target)

/obj/item/tram_remote/proc/link_tram(mob/user, atom/target)
	var/obj/machinery/button/tram/smacked_device = target
	if(istype(smacked_device, /obj/machinery/button/tram))
		for(var/datum/lift_master/lift as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
			if(lift.specific_lift_id == smacked_device.lift_id)
				tram_ref = WEAKREF(lift)
				break
		if(tram_ref)
			balloon_alert(user, "tram linked")
		else
			balloon_alert(user, "link failed!")
		update_appearance()

#undef TRAMCTRL_INBOUND
#undef TRAMCTRL_OUTBOUND
