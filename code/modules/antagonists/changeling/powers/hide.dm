/datum/action/changeling/hide //Be stupid with this and you will be dead dead.
	name = "Hide Identity"
	desc = "Halts chemical production but makes us invisible to the blood test."
	button_icon_state = "mimic_voice" //Much unique, very wow.
	helptext = "We will be unable to regenerate chemicals while this is active. Turning this ability off will take us time."
	chemical_cost = 0//constant chemical drain hardcoded
	dna_cost = 1
	req_human = 0
	active = FALSE

/datum/action/changeling/hide/sting_action(mob/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(!active)
		changeling.chem_recharge_slowdown += 1
		to_chat(user, "<span class='notice'>We slow down our chemical production.</span>")
		active = !active
	else
		to_chat(user, "<span class='notice'>We attempt to restart our chemical production.</span>")
		if(do_after(user, 300, target = get_turf(user)))
			changeling.chem_recharge_slowdown -= 1
			to_chat(user, "<span class='notice'>We restart our chemical production.</span>")
			active = !active
		else
			return FALSE
	..()
	return TRUE
