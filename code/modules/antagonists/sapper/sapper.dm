/datum/antagonist/sapper
	name = "\improper Space Sapper"
	job_rank = ROLE_SPACE_SAPPER
	antag_hud_name = "traitor"
	roundend_category = "Sapper Gang"
	antagpanel_category = "Sapper Gang"
	show_to_ghosts = TRUE
	///Variable to determine what mask is given
	var/mask_no = 0
	///Boolean on whether the starting equipment should be given to their inventory.
	var/give_equipment = FALSE
	///Reference to the team they are part of.
	var/datum/team/sapper/gang

/datum/antagonist/sapper/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/owner_mob = mob_override || owner.current
	var/datum/language_holder/holder = owner_mob.get_language_holder()
	holder.grant_language(/datum/language/uncommon, source = LANGUAGE_PIRATE)
	holder.selected_language = /datum/language/uncommon

/datum/antagonist/sapper/remove_innate_effects(mob/living/mob_override)
	var/mob/living/owner_mob = mob_override || owner.current
	owner_mob.remove_language(/datum/language/uncommon, source = LANGUAGE_PIRATE)
	return ..()

/datum/antagonist/sapper/greet()
	. = ..()
	to_chat(owner, span_notice("<B>You're an illegal credits miner, build your defenses to protect your credit-miner and your ship, and harvest as many credits as you can!</B>"))
	owner.announce_objectives()

/datum/antagonist/sapper/get_team()
	return gang

/datum/antagonist/sapper/create_team(datum/team/sapper/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	gang = new_team

/datum/antagonist/sapper/forge_objectives()
	if(gang)
		objectives |= gang.objectives

/datum/antagonist/sapper/on_gain()
	equip_guy()
	move_to_spawnpoint()
	return ..()

/datum/antagonist/sapper/on_removal()
	owner.special_role = null
	return ..()

/datum/antagonist/sapper/proc/equip_guy()
	if(!ishuman(owner.current))
		return FALSE
	if(!give_equipment)
		return FALSE
	var/mob/living/carbon/human/gang_member = owner.current
	gang_member.equipOutfit(/datum/outfit/sapper)
	if(mask_no <= 1)
		gang_member.put_in_r_hand(new /obj/item/clothing/mask/gas/atmos/sapper)
	else
		gang_member.put_in_r_hand(new /obj/item/clothing/mask/gas/atmos/sapper/partner)
	return TRUE

/datum/antagonist/sapper/proc/get_spawnpoint()
	return pick(GLOB.sapper_start)

/datum/antagonist/sapper/proc/move_to_spawnpoint()
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_SAPPER_HIDEOUT)
	var/turf/destination = get_spawnpoint()
	owner.current.forceMove(destination)

/datum/antagonist/sapper/get_preview_icon()
	var/icon/sapper_one_icon = render_preview_outfit(/datum/outfit/sapper_preview)
	sapper_one_icon.Shift(WEST, 5)

	var/icon/sapper_two_icon = render_preview_outfit(/datum/outfit/sapper_preview/partner)
	sapper_two_icon.Shift(EAST, 5)

	var/icon/final_icon = sapper_one_icon
	final_icon.Blend(sapper_two_icon, ICON_OVERLAY)
	final_icon.Shift(NORTH, 1)

	return finish_preview_icon(final_icon)

/datum/team/sapper
	name = "\improper Sapper gang"

/datum/team/sapper/proc/forge_objectives()
	var/datum/objective/sapper/sapper_objective = new()
	sapper_objective.team = src
	for(var/obj/machinery/computer/piratepad_control/sapper/cargo_hold as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/piratepad_control/sapper))
		var/area/area = get_area(cargo_hold)
		if(istype(area, /area/shuttle/sapper))
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

/datum/objective/sapper/Destroy()
	if(cargo_hold)
		QDEL_NULL(cargo_hold)
	return ..()

/datum/objective/sapper/proc/get_loot_value()
	return cargo_hold ? cargo_hold.points : 0

/datum/team/sapper/roundend_report()
	var/list/parts = list()

	parts += span_header("Sapper Gang were:")
	parts += printplayerlist(members)
	var/datum/objective/sapper/sapper_objective = locate() in objectives
	parts += "Total cash out: [sapper_objective.get_loot_value()] credits"
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
