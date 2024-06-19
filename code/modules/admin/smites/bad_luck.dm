/// Gives the target bad luck, optionally permanently
/datum/smite/bad_luck
	name = "Bad Luck"

	/// Should the target know they've received bad luck?
	var/silent

	/// Is this permanent?
	var/incidents

/datum/smite/bad_luck/configure(client/user)
	silent = tgui_alert(user, "Do you want to apply the omen with a player notification?", "Notify Player?", list("Notify", "Silent")) == "Silent"
	incidents = tgui_input_number(user, "For how many incidents will the omen last? 0 means permanent.", "Duration?", default = 0, round_value = 1)
	if(incidents == 0)
		incidents = INFINITY

/datum/smite/bad_luck/effect(client/user, mob/living/target)
	. = ..()
	//if permanent, replace any existing omen
	if(incidents == INFINITY)
		var/existing_component = target.GetComponent(/datum/component/omen)
		qdel(existing_component)
	target.AddComponent(/datum/component/omen/smite, incidents_left = incidents)
	if(silent)
		return
	to_chat(target, span_warning("You get a bad feeling..."))
	if(incidents == INFINITY)
		to_chat(target, span_warning("A <b>very</b> bad feeling... As if malevolent forces are watching you..."))
