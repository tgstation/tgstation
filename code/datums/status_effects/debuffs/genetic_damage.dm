#define GORILLA_MUTATION_CHANCE_PER_SECOND 0.25
#define GORILLA_MUTATION_MINIMUM_DAMAGE 2500

/datum/status_effect/genetic_damage
	id = "genetic_damage"
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH // New effects will add to total_damage
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 2 SECONDS
	on_remove_on_mob_delete = TRUE // Need to unregister from owner, be_replaced() would cause runtimes
	remove_on_fullheal = TRUE
	/// The total genetic damage accumulated on the mob
	var/total_damage = 0
	/// The amount of genetic damage a mob can sustain before taking toxin damage
	var/minimum_before_tox_damage = 500
	/// The amount of genetic damage to remove per second
	var/remove_per_second = 1 / 3
	/// The amount of toxin damage to deal per second, if over the minimum before taking damage
	var/toxin_damage_per_second = 1 / 3

/datum/status_effect/genetic_damage/on_creation(mob/living/new_owner, total_damage)
	. = ..()
	src.total_damage = total_damage
	RegisterSignal(new_owner, COMSIG_LIVING_HEALTHSCAN, PROC_REF(on_healthscan))

/datum/status_effect/genetic_damage/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_LIVING_HEALTHSCAN)

/datum/status_effect/genetic_damage/refresh(mob/living/owner, total_damage)
	. = ..()
	src.total_damage += total_damage

/datum/status_effect/genetic_damage/tick(seconds_between_ticks)
	if(ismonkey(owner) && total_damage >= GORILLA_MUTATION_MINIMUM_DAMAGE && SPT_PROB(GORILLA_MUTATION_CHANCE_PER_SECOND, seconds_between_ticks))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.gorillize(genetics_gorilla = TRUE)
		qdel(src)
		return

	if(total_damage >= minimum_before_tox_damage)
		owner.adjustToxLoss(toxin_damage_per_second * seconds_between_ticks)

	total_damage -= remove_per_second * seconds_between_ticks
	if(total_damage <= 0)
		qdel(src)
		return

/datum/status_effect/genetic_damage/proc/on_healthscan(datum/source, list/render_list, advanced, mob/user, mode, tochat)
	SIGNAL_HANDLER

	var/message = ""
	if(advanced)
		message = "Genetic damage: [round(total_damage / minimum_before_tox_damage * 100, 0.1)]%"
	else if(total_damage >= minimum_before_tox_damage)
		message = "Severe genetic damage detected."
	else
		message = "Minor genetic damage detected."

	if(message)
		render_list += "<span class='alert ml-1'>"
		render_list += conditional_tooltip("[message]", "Irreparable under normal circumstances - will decay over time.", tochat)
		render_list += "</span><br>"

#undef GORILLA_MUTATION_CHANCE_PER_SECOND
#undef GORILLA_MUTATION_MINIMUM_DAMAGE
