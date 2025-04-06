/obj/item/supplypod_beacon
	name = "Supply Pod Beacon"
	desc = "A device that can be linked to an Express Supply Console for precision supply pod deliveries."
	icon = 'icons/obj/devices/tracker.dmi'
	icon_state = "supplypod_beacon"
	inhand_icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	armor_type = /datum/armor/supplypod_beacon
	resistance_flags = FIRE_PROOF
	interaction_flags_click = ALLOW_SILICON_REACH
	/// The linked console
	var/obj/machinery/computer/cargo/express/express_console
	/// If linked
	var/linked = FALSE
	/// If this is ready to launch
	var/ready = FALSE
	/// If it's been launched
	var/launched = FALSE

/datum/armor/supplypod_beacon
		bomb = 100
		fire = 100

/obj/item/supplypod_beacon/proc/update_status(consoleStatus)
	switch(consoleStatus)
		if (SP_LINKED)
			linked = TRUE
			playsound(src,'sound/machines/beep/twobeep.ogg',50,FALSE)
		if (SP_READY)
			ready = TRUE
		if (SP_LAUNCH)
			launched = TRUE
			playsound(src,'sound/machines/beep/triple_beep.ogg',50,FALSE)
			playsound(src,'sound/machines/warning-buzzer.ogg',50,FALSE)
			addtimer(CALLBACK(src, PROC_REF(endLaunch)), 33)//wait 3.3 seconds (time it takes for supplypod to land), then update icon
		if (SP_UNLINK)
			linked = FALSE
			playsound(src,'sound/machines/synth/synth_no.ogg',50,FALSE)
		if (SP_UNREADY)
			ready = FALSE
	update_appearance()

/obj/item/supplypod_beacon/update_overlays()
	. = ..()
	if(launched)
		. += "sp_green"
		return
	if(ready)
		. += "sp_yellow"
		return
	if(linked)
		. += "sp_orange"
		return

/obj/item/supplypod_beacon/proc/endLaunch()
	launched = FALSE
	update_status()

/obj/item/supplypod_beacon/examine(user)
	. = ..()
	. += span_notice("It looks like it has a few anchoring bolts.")
	if(!express_console)
		. += span_notice("[src] is not currently linked to an Express Supply console.")
	else
		. += span_notice("Alt-click to unlink it from the Express Supply console.")

/obj/item/supplypod_beacon/Destroy()
	if(express_console)
		express_console.beacon = null
	return ..()

/obj/item/supplypod_beacon/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if (default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		pixel_x = 0
		pixel_y = 0
	return ITEM_INTERACT_SUCCESS

/obj/item/supplypod_beacon/proc/unlink_console()
	if(express_console)
		express_console.beacon = null
		express_console = null
	update_status(SP_UNLINK)
	update_status(SP_UNREADY)

/obj/item/supplypod_beacon/proc/link_console(obj/machinery/computer/cargo/express/C, mob/living/user)
	if (C.beacon)//if new console has a beacon, then...
		C.beacon.unlink_console()//unlink the old beacon from new console
	if (express_console)//if this beacon has an express console
		express_console.beacon = null//remove the connection the expressconsole has from beacons
	express_console = C//set the linked console var to the console
	express_console.beacon = src//out with the old in with the news
	update_status(SP_LINKED)
	if (express_console.using_beacon)
		update_status(SP_READY)
	to_chat(user, span_notice("[src] linked to [C]."))

/obj/item/supplypod_beacon/click_alt(mob/user)
	if(!express_console)
		to_chat(user, span_alert("There is no linked console."))
		return CLICK_ACTION_BLOCKING
	unlink_console()
	return CLICK_ACTION_SUCCESS

/obj/item/supplypod_beacon/attackby(obj/item/W, mob/user)
	if(IS_WRITING_UTENSIL(W)) //give a tag that is visible from the linked express console
		return ..()
	var/new_beacon_name = tgui_input_text(user, "What would you like the tag to be?", "Beacon Tag", max_length = MAX_NAME_LEN)
	if(isnull(new_beacon_name))
		return
	if(!user.can_perform_action(src))
		return
	name += " ([tag])"
