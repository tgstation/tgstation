/obj/item/pod_equipment/lock
	slot = POD_SLOT_MISC
	exclusive_with = list(/obj/item/pod_equipment/lock)

/// whether the user may do that action, TRUE if they may
/obj/item/pod_equipment/lock/proc/request_permission(mob/requestee)
	return TRUE

/obj/item/pod_equipment/lock/pin
	name = "pod PIN lock"
	desc = "Allows you to set a pin lock for a pod."
	interface_id = "PINPart"
	icon_state = "pinlock"
	/// our actual PIN
	var/pin
	/// holds the entered pin in the UI
	var/entered_pin = ""

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
				return
			else if(digit == "E")
				var/entered = text2num(entered_pin)
				if(isnull(entered))
					return
				entered_pin = ""
				if(isnull(pin))
					pin = entered
				else if(pin == entered)
					pin = null //reset
				return
			if(length_char(entered_pin) >= 4)
				return
			entered_pin += digit

/obj/item/pod_equipment/lock/pin/ui_data(mob/user)
	. = list()
	.["ref"] = REF(src)
	.["lockstate"] = !isnull(pin) ? "SET" : "NOT SET"
	.["entered_pin"] = entered_pin
	for(var/i = 1 to 4 - length(entered_pin))
		.["entered_pin"] += "-" //style

/obj/item/pod_equipment/lock/pin/request_permission(mob/requestee)
	if(isnull(pin))
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
	name = "pod DNA lock"
	desc = "This device will make the pod only allow your DNA to enter. Use the pod controls to add your DNA, and use it again to remove the lock."
	interface_id = "DNAPart"
	icon_state = "dnalock"
	/// the unique enzymes of whoever we belong to
	var/unique_enzymes

/obj/item/pod_equipment/lock/dna/ui_data(mob/user)
	. = list()
	.["dnaSet"] = !isnull(unique_enzymes) ? "DNA - SET" : "DNA - NOT SET"

/obj/item/pod_equipment/lock/dna/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/carbon = usr
	if(!request_permission(carbon))
		return
	switch(action)
		if("setprint")
			. = TRUE
			if(unique_enzymes)
				unique_enzymes = null
			else if(carbon.has_dna())
				unique_enzymes = carbon.dna.unique_enzymes

/obj/item/pod_equipment/lock/dna/request_permission(mob/living/carbon/user)
	if(!istype(user))
		return FALSE
	if(!unique_enzymes  || (user.has_dna() && user.dna.unique_enzymes == unique_enzymes))
		return TRUE
	balloon_alert(user, UNLINT("DNA doesnt match!"))
	return FALSE
