/datum/component/faction_bind
	dupe_mode = COMPONENT_DUPE_SELECTIVE
	var/datum/faction_master
	var/block_innate_factions = FALSE
	var/trait_source

/datum/component/faction_bind/Initialize(datum/faction_master, block_innate_factions = FALSE, trait_source)
	if(!istype(faction_master) || !trait_source)
		return COMPONENT_INCOMPATIBLE

	src.faction_master = faction_master
	src.block_innate_factions = block_innate_factions

	if(block_innate_factions && isliving(parent))
		if(!HAS_TRAIT(parent, TRAIT_INNATE_FACTIONS_BLOCKED))
			var/mob/living/living_parent = parent
			for(var/faction_trait in living_parent.faction)
				REMOVE_TRAIT(living_parent, faction_trait, INNATE_TRAIT)
		ADD_TRAIT(parent, TRAIT_INNATE_FACTIONS_BLOCKED, trait_source)

	RegisterSignal(parent, COMSIG_PARENT_FACTION_CHECK, .proc/on_parent_faction_check)
	RegisterSignal(faction_master, COMSIG_PARENT_QDELETING, .proc/on_faction_master_qdeleting)
	ADD_TRAIT(parent, TRAIT_FACTION_MASTER(faction_master), trait_source)

/datum/component/faction_bind/Destroy()
	if(!faction_master || !trait_source)
		return ..()

	UnregisterSignal(faction_master, COMSIG_PARENT_QDELETING)
	UnregisterSignal(parent, COMSIG_PARENT_FACTION_CHECK)

	if(block_innate_factions && isliving(parent))
		REMOVE_TRAIT(parent, TRAIT_INNATE_FACTIONS_BLOCKED, trait_source)
		if(!HAS_TRAIT(parent, TRAIT_INNATE_FACTIONS_BLOCKED))
			var/mob/living/living_parent = parent
			for(var/faction_trait in living_parent.faction)
				ADD_TRAIT(living_parent, faction_trait, INNATE_TRAIT)

	REMOVE_TRAIT(parent, TRAIT_FACTION_MASTER(faction_master), trait_source)
	faction_master = null
	return ..()

/datum/component/faction_bind/CheckDupeComponent(datum/faction_master, block_innate_factions, trait_source)
	if(src.trait_source == trait_source)
		stack_trace("a faction_bind component with the same trait_source ([trait_source]) of an existing one was about to be added to [parent]")
		return TRUE

/datum/component/faction_bind/proc/on_faction_master_qdeleting()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/faction_bind/proc/on_parent_faction_check(datum/source, factions, exact_match, datum/target)
	SIGNAL_HANDLER
	if(target && !exact_match && HAS_TRAIT(target, TRAIT_FACTION_MASTER(faction_master)))
		return TRUE
	if(faction_master.faction_check(factions, exact_match))
		return TRUE
