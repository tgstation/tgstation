/// Makes a mob friendly with most NPC factions
/datum/element/npc_friendly

/datum/element/npc_friendly/Attach(datum/target)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/living/player = target

	player.faction |= list(
		FACTION_BOSS,
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

/datum/element/npc_friendly/Detach(datum/source)
	. = ..()

	var/mob/living/player = source

	player.faction.Remove(
		FACTION_BOSS,
		FACTION_HIVEBOT,
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
