/datum/antagonist/cortical_borer
	name = "Cortical Borer"
	job_rank = ROLE_CORTICAL_BORER
	roundend_category = "enslaved cortical borers" // may look a bit confusing, but these borers are not a part of a hivemind. So they are probably enslaved
	antagpanel_category = "Cortical Borers"
	ui_name = "AntagInfoBorer"
	count_against_dynamic_roll_chance = FALSE // there are thousands of them, we do not need them to be the only antagonist
	prevent_roundtype_conversion = FALSE
	show_to_ghosts = TRUE
	/// Our linked borer, used for the antagonist panel TGUI
	var/mob/living/basic/cortical_borer/cortical_owner

/datum/antagonist/cortical_borer/antag_token(datum/mind/hosts_mind, mob/spender)
	var/list/vents = list()
	if(isliving(spender) && hosts_mind)
		hosts_mind.current.unequip_everything()
		new /obj/effect/holy(hosts_mind.current.loc)
		QDEL_IN(hosts_mind.current, 20)
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics/components/unary/vent_pump))
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue // No parent vent
			// Stops Cortical Borers getting stuck in small networks.
			// See: Security, Virology
			if(length(temp_vent_parent.other_atmos_machines) > 20)
				vents += temp_vent

	if(!length(vents))
		message_admins("Spawning in as a borer failed!")
		return MAP_ERROR

	var/mob/dead/observer/new_borer = spender
	var/turf/vent_turf = get_turf(pick(vents))
	var/mob/living/basic/cortical_borer/spawned_cb = new(vent_turf)
	spawned_cb.ckey = new_borer.ckey
	spawned_cb.mind.add_antag_datum(/datum/antagonist/cortical_borer/hivemind)
	notify_ghosts(
		"Someone has become a borer due to spending an antag token ([spawned_cb])!",
		source = spawned_cb,
		action = NOTIFY_ORBIT,
		header = "Something's Interesting!",
	)
	message_admins("[ADMIN_LOOKUPFLW(spawned_cb)] has been made into a borer by using an antag token.")
	to_chat(spawned_cb, span_warning("You are a cortical borer! You can fear someone to make them stop moving, but make sure to inhabit them! You only grow/heal/talk when inside a host!"))

/datum/antagonist/cortical_borer/on_gain()
	cortical_owner = owner.current
	forge_objectives()
	return ..()

/datum/antagonist/cortical_borer/get_preview_icon()
	return finish_preview_icon(icon('monkestation/code/modules/antagonists/borers/icons/animal.dmi', "brainslug"))

/datum/antagonist/cortical_borer/hivemind
	roundend_category = "cortical borers"
	/// The team of borers
	var/datum/team/cortical_borers/borers

/datum/antagonist/cortical_borer/hivemind/forge_objectives()
	var/datum/objective/custom/borer_objective_produce_eggs = new
	borer_objective_produce_eggs.explanation_text = "we require [GLOB.objective_egg_borer_number] different borers to produce [GLOB.objective_egg_egg_number] eggs to make sure our hive can spread widelly for increasing our chances of survival"

	var/datum/objective/custom/borer_objective_willing_hosts = new
	borer_objective_willing_hosts.explanation_text = "we require any amount of the borers to get [GLOB.objective_willing_hosts] willing host's trust to ensure our survival"

	var/datum/objective/custom/borer_objective_learn_chemicals = new
	borer_objective_learn_chemicals.explanation_text = "we require any amount of the borers to learn [GLOB.objective_blood_borer] chemicals from blood to aquire further chemical insight"

	objectives += borer_objective_produce_eggs
	objectives += borer_objective_willing_hosts
	objectives += borer_objective_learn_chemicals

/datum/antagonist/cortical_borer/hivemind/create_team(datum/team/cortical_borers/new_team)
	if(!new_team)
		for(var/datum/antagonist/cortical_borer/hivemind/borer in GLOB.antagonists)
			if(!borer.owner)
				stack_trace("Antagonist datum without owner in GLOB.antagonists: [borer]")
				continue
			if(borer.borers)
				borers = borer.borers
				return
		borers = new /datum/team/cortical_borers
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	borers = new_team

/datum/antagonist/cortical_borer/hivemind/get_team()
	return borers

/datum/antagonist/cortical_borer/ui_static_data(mob/user)
	var/list/data = list()
	for(var/datum/action/cooldown/borer/ability as anything in cortical_owner.known_abilities)
		var/list/ability_data = list()

		ability_data["ability_name"] = initial(ability.name)
		ability_data["ability_explanation"] = initial(ability.ability_explanation)
/* Temporarily disabled -- Turn dis on once i figure out how to space stuff out properly in the TGUI
		ability_data["ability_explanation"] += "Restrictions:"
		if(ability.chemical_cost)
			ability_data["ability_explanation"] += "<p>-To use this ability we need to use [ability.chemical_cost] of our internally synthesized chemicals. "
		if(ability.stat_evo_points)
			ability_data["ability_explanation"] += "-To make effective use of this ability we need to spend [ability.stat_evo_points] evolution points. "
		if(ability.chemical_evo_points)
			ability_data["ability_explanation"] += "-We have to use [ability.chemical_evo_points] chemical evolution points to use this ability. "

		if(ability.requires_host)
			ability_data["ability_explanation"] += "-We require a host to use this ability. "
		if(ability.needs_living_host)
			ability_data["ability_explanation"] += "-Our host requires to be alive in order for us to use this ability. "
		if(ability.needs_dead_host)
			ability_data["ability_explanation"] += "-Our host must be deceased in order for us to make effective use of this ability. "
		if(ability.sugar_restricted)
			ability_data["ability_explanation"] += "-We cannot use this ability when our host is under the effect of a highly dangerous chemical known as \"sugar\". "
*/
		ability_data["ability_icon"] = initial(ability.button_icon_state)

		data["ability"] += list(ability_data)

	return data + ..()

/datum/antagonist/cortical_borer/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/borer_icons),
	)
