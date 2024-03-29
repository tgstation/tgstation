/// Makes a mob friendly with most NPC factions
/datum/component/npc_friendly
	/// The list of factions to add to the player
	var/list/npc_factions = list(
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
	var/list/previous_factions = list()

/datum/component/npc_friendly/Initialize()
	. = ..()

	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/player = parent

	previous_factions.Add(player.faction)
	player.faction |= npc_factions

/datum/component/npc_friendly/Destroy(force)
	. = ..()

	var/mob/living/player = parent

	player.faction.Cut()
	player.faction.Add(previous_factions)
