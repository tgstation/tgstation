/datum/antagonist/sapper
	name = "\improper Space Sapper"
	job_rank = ROLE_SPACE_SAPPER
	roundend_category = "Sapper Gang"
	antagpanel_category = "Sapper Gang"
	show_to_ghosts = TRUE
	antag_recipes = list(/datum/crafting_recipe/credit_miner)

	var/datum/team/sapper/team

/datum/antagonist/sapper/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/owner_mob = mob_override || owner.current
	var/datum/language_holder/holder = owner_mob.get_language_holder()
	holder.grant_language(/datum/language/gutter, source = LANGUAGE_PIRATE)
	holder.selected_language = /datum/language/gutter

/datum/antagonist/sapper/remove_innate_effects(mob/living/mob_override)
	var/mob/living/owner_mob = mob_override || owner.current
	owner_mob.remove_language(/datum/language/gutter, source = LANGUAGE_PIRATE)
	return ..()

/datum/antagonist/sapper/greet()
	. = ..()
	to_chat(owner, "<B>You're an illegal credits miner, build your defenses to protect your credit-miner and your ship, and harvest as many credits as you can!</B>")
	owner.announce_objectives()

/datum/antagonist/sapper/get_team()
	return team

/datum/antagonist/sapper/create_team(datum/team/sapper/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/sapper/on_gain()
	equip_guy()
	objectives += team.objectives
	return ..()

/datum/antagonist/sapper/on_removal()
	owner.special_role = null
	return ..()

/datum/antagonist/sapper/proc/equip_guy()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/person = owner.current
	var/datum/outfit/outfit_to_apply = new /datum/outfit/sapper
	person.equipOutfit(outfit_to_apply)
	return TRUE

/datum/antagonist/sapper/get_preview_icon()
	var/icon/sapper_one_icon = render_preview_outfit(/datum/outfit/sapper/preview)
	sapper_one_icon.Shift(WEST, 6)

	var/icon/sapper_two_icon = render_preview_outfit(/datum/outfit/sapper/preview/partner)
	sapper_two_icon.Shift(EAST, 6)

	var/icon/final_icon = sapper_one_icon
	final_icon.Blend(sapper_two_icon, ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/team/sapper
	name = "\improper Sapper gang"

/datum/team/sapper/New()
	..()
	forge_objectives()

/datum/team/sapper/proc/forge_objectives()
	var/datum/objective/sapper/sapper_objective = new()
	sapper_objective.team = src
	for(var/obj/machinery/computer/piratepad_control/sapper/cargo_hold as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/piratepad_control/sapper))
		var/area/area = get_area(cargo_hold)
		if(istype(area, /area/shuttle/pirate))
			sapper_objective.cargo_hold = cargo_hold
			break
	sapper_objective.update_explanation_text()
	objectives += sapper_objective
	for(var/datum/mind/mind in members)
		var/datum/antagonist/sapper/sapper = mind.has_antag_datum(/datum/antagonist/sapper)
		if(sapper)
			sapper.objectives |= objectives

/datum/objective/sapper
	var/obj/machinery/computer/piratepad_control/sapper/cargo_hold
	explanation_text = "Use your credit-miner to convert energy into cash."

/datum/objective/sapper/update_explanation_text()
	if(cargo_hold)
		var/area/storage_area = get_area(cargo_hold)
		explanation_text = "Acquire as many credits as you can from the station's powernet and cash it out into the [storage_area.name] cargo hold."

/datum/objective/sapper/proc/get_loot_value()
	return cargo_hold ? cargo_hold.points : 0

/datum/team/sapper/roundend_report()
	var/list/parts = list()

	parts += "<span class='header'>Sapper Gang were:</span>"
	parts += printplayerlist(members)
	var/datum/objective/sapper/sapper_objective = locate() in objectives
	parts += "Total cash out: [sapper_objective.get_loot_value()] credits"
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
