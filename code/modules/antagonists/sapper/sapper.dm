/datum/antagonist/sapper
	name = "\improper Space Sapper"
	antagpanel_category = ANTAG_GROUP_PIRATES
	pref_flag = ROLE_SPACE_SAPPER
	antag_hud_name = "traitor"
	roundend_category = "space sappers"
	show_to_ghosts = TRUE
	var/datum/team/sapper/gang
	var/outfit = /datum/outfit/sapper

/datum/antagonist/sapper/get_preview_icon()
	var/icon/sapper_one_icon = render_preview_outfit(/datum/outfit/sapper_preview)
	sapper_one_icon.Shift(WEST, 5)
	var/icon/sapper_two_icon = render_preview_outfit(/datum/outfit/sapper_preview/partner)
	sapper_two_icon.Shift(EAST, 5)
	var/icon/final_icon = sapper_one_icon
	final_icon.Blend(sapper_two_icon, ICON_OVERLAY)
	final_icon.Shift(NORTH, 1)
	return finish_preview_icon(final_icon)

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

/datum/antagonist/sapper/create_team(datum/team/sapper/new_gang)
	if(!new_gang)
		return
	if(!istype(new_gang))
		stack_trace("Wrong team type passed to [type] initialization.")
	gang = new_gang

/datum/antagonist/sapper/on_gain()
	owner.set_assigned_role(SSjob.get_job_type(/datum/job/space_sapper))
	objectives += gang.objectives
	finalize_sapper()
	find_cargo_hold()
	return ..()

/datum/antagonist/sapper/proc/finalize_sapper()
	var/mob/living/carbon/human/gang_member = owner.current
	gang_member.equipOutfit(outfit)
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_SAPPER_HIDEOUT)
	var/turf/destination = pick(GLOB.sapper_start)
	owner.current.forceMove(destination)

/datum/antagonist/sapper/proc/find_cargo_hold()
	var/our_pad
	for(var/obj/machinery/computer/piratepad_control/sapper/control_pad in SSmachines.get_machines_by_type(/obj/machinery/computer/piratepad_control/sapper))
		if(control_pad)
			our_pad = control_pad
			break
	for(var/datum/objective/creditmining/our_objective in objectives)
		our_objective.cargo_hold = our_pad
		break

/datum/team/sapper
	name = "\improper Sapper gang"

/datum/team/sapper/New()
	add_objective(new /datum/objective/creditmining)

/datum/objective/creditmining
	name = "Credit Mining"
	explanation_text = "Acquire as many credits as you can from the station's powernet and cash it out into the shuttle's cargo hold."
	var/obj/machinery/computer/piratepad_control/sapper/cargo_hold

/datum/objective/creditmining/Destroy()
	if(cargo_hold)
		QDEL_NULL(cargo_hold)
	return ..()

/datum/objective/creditmining/proc/get_loot_value()
	return cargo_hold ? cargo_hold.points : 0

/datum/team/sapper/roundend_report()
	var/list/parts = list()
	parts += printplayerlist(members)
	var/datum/objective/creditmining/objective = locate() in objectives
	parts += "Total cash-out : [objective.get_loot_value()] credits"
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
