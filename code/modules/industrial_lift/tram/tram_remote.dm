#define TRAMCTRL_FAST 1
#define TRAMCTRL_SAFE 0

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
	var/direction = INBOUND
	///fast and fun, or safe and boring
	var/mode = TRAMCTRL_FAST
	///weakref to the tram piece we control
	var/datum/weakref/tram_ref
	///cooldown for the remote
	COOLDOWN_DECLARE(tram_remote)

/obj/item/tram_remote/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/tram_remote/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(!tram_ref)
		context[SCREENTIP_CONTEXT_LMB] = "Link tram"
		return CONTEXTUAL_SCREENTIP_SET
	context[SCREENTIP_CONTEXT_LMB] = "Dispatch tram"
	context[SCREENTIP_CONTEXT_RMB] = "Change direction"
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Toggle door safeties"
	return CONTEXTUAL_SCREENTIP_SET

///set tram control direction
/obj/item/tram_remote/attack_self_secondary(mob/user)
	switch(direction)
		if(INBOUND)
			direction = OUTBOUND
		if(OUTBOUND)
			direction = INBOUND
	update_appearance()
	balloon_alert(user, "[direction ? "< inbound" : "outbound >"]")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

///set safety bypass
/obj/item/tram_remote/CtrlClick(mob/user)
	switch(mode)
		if(TRAMCTRL_SAFE)
			mode = TRAMCTRL_FAST
		if(TRAMCTRL_FAST)
			mode = TRAMCTRL_SAFE
	update_appearance()
	balloon_alert(user, "mode: [mode ? "fast" : "safe"]")

/obj/item/tram_remote/examine(mob/user)
	. = ..()
	if(!tram_ref)
		. += "There is an X showing on the display."
		. += "Left-click a tram request button to link."
		return
	. += "The arrow on the display is pointing [direction ? "inbound" : "outbound"]."
	. += "The rapid mode light is [mode ? "on" : "off"]."
	if (!COOLDOWN_FINISHED(src, tram_remote))
		. += "The number on the display shows [DisplayTimeText(COOLDOWN_TIMELEFT(src, tram_remote), 1)]."
	else
		. += "The display indicates ready."
	. += "Left-click to dispatch tram."
	. += "Right-click to toggle direction."
	. += "Ctrl-click to toggle safety bypass."

/obj/item/tram_remote/update_icon_state()
	. = ..()
	if(!tram_ref)
		icon_state = "tramremote_nis"
		return
	switch(direction)
		if(INBOUND)
			icon_state = "tramremote_ib"
		if(OUTBOUND)
			icon_state = "tramremote_ob"

/obj/item/tram_remote/update_overlays()
	. = ..()
	if(mode == TRAMCTRL_FAST)
		. += mutable_appearance(icon, "tramremote_emag")

/obj/item/tram_remote/attack_self(mob/user)
	if (!COOLDOWN_FINISHED(src, tram_remote))
		balloon_alert(user, "cooldown: [DisplayTimeText(COOLDOWN_TIMELEFT(src, tram_remote), 1)]")
		return FALSE
	if(try_force_tram(user))
		COOLDOWN_START(src, tram_remote, 2 MINUTES)

///send our selected commands to the tram
/obj/item/tram_remote/proc/try_force_tram(mob/user)
	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(!tram_part)
		balloon_alert(user, "no tram linked!")
		return FALSE
	if(tram_part.controls_locked || tram_part.travelling) // someone else started already
		balloon_alert(user, "tram busy!")
		return FALSE
	var/tram_id = tram_part.specific_lift_id
	var/destination_platform = null
	var/platform = 0
	switch(direction)
		if(INBOUND)
			platform = clamp(tram_part.idle_platform.platform_code - 1, 1, INFINITY)
		if(OUTBOUND)
			platform = clamp(tram_part.idle_platform.platform_code + 1, 1, INFINITY)
	if(platform == tram_part.idle_platform.platform_code)
		balloon_alert(user, "invalid command!")
		return FALSE
	for (var/obj/effect/landmark/tram/destination as anything in GLOB.tram_landmarks[tram_id])
		if(destination.platform_code == platform)
			destination_platform = destination
			break
	if(!destination_platform)
		balloon_alert(user, "invalid command!")
		return FALSE
	else
		switch(mode)
			if(TRAMCTRL_FAST)
				tram_part.tram_travel(destination_platform, rapid = TRUE)
			if(TRAMCTRL_SAFE)
				tram_part.tram_travel(destination_platform, rapid = FALSE)
		balloon_alert(user, "tram dispatched")
		return TRUE

/obj/item/tram_remote/afterattack(atom/target, mob/user)
	link_tram(user, target)

/obj/item/tram_remote/proc/link_tram(mob/user, atom/target)
	var/obj/machinery/button/tram/smacked_device = target
	if(!istype(smacked_device, /obj/machinery/button/tram))
		return
	tram_ref = null
	for(var/datum/lift_master/lift as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
		if(lift.specific_lift_id == smacked_device.lift_id)
			tram_ref = WEAKREF(lift)
			break
	if(tram_ref)
		balloon_alert(user, "tram linked")
	else
		balloon_alert(user, "link failed!")
	update_appearance()

#undef TRAMCTRL_FAST
#undef TRAMCTRL_SAFE
