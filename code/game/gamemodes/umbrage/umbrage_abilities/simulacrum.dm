//Creates an illusionary copy of the caster that runs in their direction for ten seconds and then vanishes.
/datum/action/innate/umbrage/simulacrum
	name = "Simulacrum"
	id = "simulacrum"
	desc = "Creates an illusion that closely resembles you. The illusion will run forward for ten seconds."
	fluff_text = "Old fantasy books speak of \"displacer beasts\" that bend light rays around them to form illusions. In this case, you're doing the exact same thing - only, you bend certain colors \
	very, very minutely to cause the illusion of an actual person splitting away from you."
	button_icon_state = "umbrage_simulacrum"
	check_flags = AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	psi_cost = 30
	lucidity_cost = 1
	blacklisted = 0

/datum/action/innate/umbrage/simulacrum/Activate()
	owner.visible_message("<span class='warning'>[owner] suddenly splits into two!</span>", "<span class='velvet bold'>zayaera</span><br>\
	<span class='notice'>You create an illusion of yourself.</span>")
	playsound(owner, 'sound/magic/devour_will_form.ogg', 50, 1)
	var/obj/effect/simulacrum/simulacrum = new(get_turf(owner))
	simulacrum.mimic(owner)
	return TRUE

