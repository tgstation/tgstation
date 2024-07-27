//DNA Locks maybe?
/obj/item/pod_equipment/lock
	slot = POD_SLOT_MISC
	exclusive_with = list(/obj/item/pod_equipment/lock)

/// whether the user may do that action, TRUE if they may
/obj/item/pod_equipment/lock/proc/request_permission(mob/requestee)
	return TRUE

/obj/item/pod_equipment/lock/pin
	name = "Pod PIN lock"
	interface_id = "PINPart"
	var/pin
	var/entered_pin = ""
	var/locked = FALSE

/obj/item/pod_equipment/lock/pin/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("keypad")
			. = TRUE
			var/digit = params["digit"]
			if(digit == "C")
				entered_pin = ""
			else if(digit == "E")
				var/entered = text2num(entered_pin)
				if(isnull(entered))
					return
				if(isnull(pin))
					pin = entered
					entered_pin = ""
				else if(pin == entered)
					locked = !locked
					entered_pin = ""
				return
			if(length(entered_pin) >= 4)
				return
			entered_pin += digit

/obj/item/pod_equipment/lock/pin/ui_data(mob/user)
	. = list()
	.["locked"] = locked
	.["entered_pin"] = entered_pin
	for(var/i = 1 to 4 - length(entered_pin))
		.["entered_pin"] += "-" //style

/obj/item/pod_equipment/lock/pin/request_permission(mob/requestee)
	if(isnull(pin) || !locked)
		return TRUE
	. = FALSE
	var/entered_pin = tgui_input_number(requestee, "PIN needed!", "Enter PIN", 0, 9999, 0)
	if(entered_pin == null || !requestee.can_interact_with(src))
		return
	if(entered_pin != pin)
		balloon_alert(requestee, "wrong!")
		return
	return TRUE

/obj/item/pod_equipment/lock/dna
	var/unique_enzymes

/obj/item/pod_equipment/lock/dna/request_permission(mob/living/carbon/user)
	if(!istype(user))
		return FALSE
	if(!unique_enzymes  || (user.has_dna() && user.dna.unique_enzymes == unique_enzymes))
		return TRUE
	balloon_alert(user, UNLINT("DNA doesnt match!"))
	return FALSE
