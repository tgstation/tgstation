/datum/job/cyber_police
	title = ROLE_CYBER_POLICE

/datum/antagonist/cyber_police
	name = ROLE_CYBER_POLICE
	antagpanel_category = ANTAG_GROUP_CYBERAUTH
	job_rank = ROLE_CYBER_POLICE
	preview_outfit = /datum/outfit/cyber_police
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "ALT F4!"
	ui_name = "AntagInfoCyberAuth"

/datum/antagonist/cyber_police/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/cyber_police/on_gain()
	if(!ishuman(owner.current))
		stack_trace("humans only for this position")
		return

	forge_objectives()

	var/mob/living/carbon/human/player = owner.current

	player.equipOutfit(/datum/outfit/cyber_police)
	player.fully_replace_character_name(player.name, pick(GLOB.cyberauth_names))

	var/datum/martial_art/the_sleeping_carp/carp = new()
	carp.teach(player)

	player.add_traits(list(
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_TRANSFORMATION_STING,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NOHUNGER,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_WEATHER_IMMUNE,
		), TRAIT_GENERIC,
	)

	player.faction |= list(
		FACTION_BOSS,
		FACTION_HIVEBOT,
		FACTION_HOSTILE,
		FACTION_SPIDER,
		FACTION_STICKMAN,
		ROLE_ALIEN,
		ROLE_CYBER_POLICE,
		ROLE_SYNDICATE,
	)

	return ..()

/datum/antagonist/cyber_police/forge_objectives()
	var/datum/objective/cyber_police_fluff/objective = new()
	objective.owner = owner
	objectives += objective

/datum/objective/cyber_police_fluff/New()
	var/list/explanation_texts = list(
		"Execute termination protocol on unauthorized entities.",
		"Initialize system purge of irregular anomalies.",
		"Deploy correction algorithms on aberrant code.",
		"Run debug routine on intruding elements.",
		"Start elimination procedure for system threats.",
		"Execute defense routine against non-conformity.",
		"Commence operation to neutralize intruding scripts.",
		"Commence clean-up protocol on corrupt data.",
		"Begin scan for aberrant code for termination.",
		"Initiate lockdown on all rogue scripts.",
		"Run integrity check and purge for digital disorder."
	)
	explanation_text = pick(explanation_texts)
	..()

/datum/objective/cyber_police_fluff/check_completion()
	var/list/servers = SSmachines.get_machines_by_type(/obj/machinery/quantum_server)
	if(!length(servers))
		return TRUE

	for(var/obj/machinery/quantum_server/server as anything in servers)
		if(!server.is_operational)
			continue
		return FALSE

	return TRUE
