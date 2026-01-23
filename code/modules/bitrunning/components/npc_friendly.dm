/// Makes a mob friendly with most NPC factions
/datum/component/npc_friendly
	/// The list of factions to add to the player
	var/static/list/npc_factions = list(
		FACTION_BOSS,
		FACTION_CARP,
		FACTION_HIVEBOT,
		FACTION_HOSTILE,
		FACTION_MIMIC,
		FACTION_PIRATE,
		FACTION_SPIDER,
		FACTION_STICKMAN,
		ROLE_ALIEN,
		ROLE_GLITCH,
		ROLE_SYNDICATE,
	)
	/// List of factions previously held by the player
	var/list/previous_factions

/datum/component/npc_friendly/Initialize()
	. = ..()

	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/player = parent

	previous_factions = player.get_faction()
	player.add_faction(npc_factions)

/datum/component/npc_friendly/Destroy(force)
	var/mob/living/player = parent
	if(!QDELETED(parent))
		player.set_faction(previous_factions)
	return ..()
