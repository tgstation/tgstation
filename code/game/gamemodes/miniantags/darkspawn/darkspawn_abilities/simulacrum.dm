//Creates an illusionary copy of the caster that runs in their direction for ten seconds and then vanishes.
/datum/action/innate/darkspawn/simulacrum
	name = "Simulacrum"
	id = "simulacrum"
	desc = "Creates an illusion that closely resembles you. The illusion will run forward for ten seconds. Costs 20 Psi."
	button_icon_state = "simulacrum"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 20
	lucidity_price = 1

/datum/action/innate/darkspawn/simulacrum/Activate()
	if(isliving(owner.loc))
		var/mob/living/L = owner.loc
		L.visible_message("<span class='warning'>[owner] breaks away from [L]'s shadow!</span>", \
		"<span class='userdanger'>You feel a sense of freezing cold pass through you!</span>", ignore_mob = owner)
		to_chat(owner, "<span class='velvet'><b>zayaera</b><br>You create an illusion of yourself.</span>")
	else
		owner.visible_message("<span class='warning'>[owner] splits in two!</span>", \
		"<span class='velvet'><b>zayaera</b><br>You create an illusion of yourself.</span>")
	playsound(owner, 'sound/magic/devour_will_form.ogg', 50, 1)
	var/obj/effect/simulacrum/simulacrum = new(get_turf(owner))
	simulacrum.mimic(owner)
	return TRUE
