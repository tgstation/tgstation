/**
 * Revenge Vassal
 *
 * Has the goal to 'get revenge' when their Master dies.
 */
/datum/antagonist/vassal/revenge
	name = "\improper Revenge Vassal"
	roundend_category = "abandoned Vassals"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	antag_hud_name = "vassal4"
	special_type = REVENGE_VASSAL
	vassal_description = "The Revenge Vassal will not deconvert on your Final Death, \
		instead they will gain all your Powers, and the objective to take revenge for your demise. \
		They additionally maintain your Vassals after your departure, rather than become aimless."
	remove_on_bloodsucker_death = FALSE

	///all ex-vassals brought back into the fold.
	var/list/datum/antagonist/ex_vassal/ex_vassals = list()

/datum/antagonist/vassal/revenge/roundend_report()
	var/list/report = list()
	report += printplayer(owner)
	if(objectives.len)
		report += printobjectives(objectives)

	// Now list their vassals
	if(ex_vassals.len)
		report += "<span class='header'>The Vassals brought back into the fold were...</span>"
		for(var/datum/antagonist/ex_vassal/all_vassals as anything in ex_vassals)
			if(!all_vassals.owner)
				continue
			report += "<b>[all_vassals.owner.name]</b> the [all_vassals.owner.assigned_role.title]"

	return report.Join("<br>")

/datum/antagonist/vassal/revenge/on_gain()
	. = ..()
	RegisterSignal(master, BLOODSUCKER_FINAL_DEATH, PROC_REF(on_master_death))

/datum/antagonist/vassal/revenge/on_removal()
	UnregisterSignal(master, BLOODSUCKER_FINAL_DEATH)
	return ..()

/datum/antagonist/vassal/revenge/ui_static_data(mob/user)
	var/list/data = list()
	for(var/datum/action/cooldown/bloodsucker/power as anything in powers)
		var/list/power_data = list()

		power_data["power_name"] = power.name
		power_data["power_explanation"] = power.power_explanation
		power_data["power_icon"] = power.button_icon_state

		data["power"] += list(power_data)

	return data + ..()

/datum/antagonist/vassal/revenge/proc/on_master_death(datum/antagonist/bloodsucker/bloodsuckerdatum, mob/living/carbon/master)
	SIGNAL_HANDLER

	show_in_roundend = TRUE
	for(var/datum/objective/all_objectives as anything in objectives)
		objectives -= all_objectives
	BuyPower(new /datum/action/cooldown/bloodsucker/vassal_blood)
	for(var/datum/action/cooldown/bloodsucker/master_powers as anything in bloodsuckerdatum.powers)
		if(master_powers.purchase_flags & BLOODSUCKER_DEFAULT_POWER)
			continue
		master_powers.Grant(owner.current)
		owner.current.remove_status_effect(/datum/status_effect/agent_pinpointer/vassal_edition)

	var/datum/objective/survive/new_objective = new
	new_objective.name = "Avenge Bloodsucker"
	new_objective.explanation_text = "Avenge your Bloodsucker's death by recruiting their ex-vassals and continuing their operations."
	new_objective.owner = owner
	objectives += new_objective

	if(info_button_ref)
		QDEL_NULL(info_button_ref)

	ui_name = "AntagInfoRevengeVassal" //give their new ui
	var/datum/action/antag_info/info_button = new(src)
	info_button.Grant(owner.current)
	info_button_ref = WEAKREF(info_button)
