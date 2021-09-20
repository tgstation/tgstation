/**
 * Component attachable to any datum. Used by mobs the most.
 *
 * If do_faction_check is TRUE, faction checks done to/by the parent also take into account the factions of the faction_master datum.
 * It also gives the attached atom an unique faction trait to make sure faction checks from other datums return TRUE if they both
 * have a faction_bind component with the same faction_master.
 */
/datum/component/faction_bind
	dupe_mode = COMPONENT_DUPE_SELECTIVE
	/// The datum the parent is bound to. Avoids faction checks with him returning FALSE along other things (see above).
	var/datum/faction_master
	/// For living mobs: Wheter the component adds the INNATE_FACTIONS_BLOCKED trait on Initialize. See living/init_signals.dm.
	var/block_innate_factions = FALSE
	/**
	 * The trait source of traits added on init. It's important that the sources are unique and shared among other faction bind
	 * comps in the code, unless it's sure they won't overlap (e.g. MINION_MOB_SPAWN_TRAIT, added right after a new minion is spawned)
	 * or if both AddComponent calls have the highlander arg TRUE.
	 */
	var/trait_source
	/// If false, faction_master.faction_check() won't be called.
	var/do_faction_check = TRUE
	/// list of blacklisted factions that should be ignored in the master faction check.
	var/list/blacklist

/datum/component/faction_bind/Initialize(datum/faction_master, trait_source, block_innate_factions = FALSE, do_faction_check = TRUE, list/blacklist, highlander = FALSE)
	if(!istype(faction_master) || !trait_source)
		return COMPONENT_INCOMPATIBLE
	if(faction_master == parent) // This will cause infinite recursions. Abort.
		stack_trace("a faction_bind comp with faction_master and parent being the same was about to be added (trait_source: [trait_source]).")
		return COMPONENT_INCOMPATIBLE

	src.faction_master = faction_master
	src.block_innate_factions = block_innate_factions
	src.do_faction_check = do_faction_check
	src.blacklist = blacklist

	if(block_innate_factions && isliving(parent))
		ADD_TRAIT(parent, TRAIT_INNATE_FACTIONS_BLOCKED, trait_source)

	RegisterSignal(parent, COMSIG_PARENT_FACTION_CHECK, .proc/on_parent_faction_check)
	RegisterSignal(parent, COMSIG_PARENT_FACTION_CHECKED, .proc/on_parent_faction_checked)
	RegisterSignal(faction_master, COMSIG_PARENT_QDELETING, .proc/on_faction_master_qdeleting)
	ADD_TRAIT(parent, TRAIT_FACTION_MASTER(faction_master), trait_source)

/datum/component/faction_bind/Destroy()
	if(!faction_master || !trait_source)
		return ..()

	UnregisterSignal(faction_master, COMSIG_PARENT_QDELETING)
	UnregisterSignal(parent, list(COMSIG_PARENT_FACTION_CHECK, COMSIG_PARENT_FACTION_CHECKED))

	if(block_innate_factions)
		REMOVE_TRAIT(parent, TRAIT_INNATE_FACTIONS_BLOCKED, trait_source)

	REMOVE_TRAIT(parent, TRAIT_FACTION_MASTER(faction_master), trait_source)
	faction_master = null
	return ..()

/datum/component/faction_bind/CheckDupeComponent(datum/faction_master, trait_source, block_innate_factions = FALSE, do_faction_check = TRUE, list/blacklist, highlander = FALSE)
	if(src.trait_source != trait_source)
		return FALSE
	if(!highlander)
		stack_trace("a faction_bind comp type with same trait_source ([trait_source]) of an instanciated one was about to be added to [parent] with the highlander arg set FALSE.")
	else if(!faction_master)
		stack_trace("the faction_master ([src.faction_master]) of a faction_bind comp (trait_source: [trait_source]) was about to be replaced with a new one, but it turned out to be null.")
	else if(src.faction_master != faction_master) //There can only be one!
		replace_faction_master(faction_master)
	return TRUE

/datum/component/faction_bind/proc/on_faction_master_qdeleting()
	SIGNAL_HANDLER
	if(!ismob(faction_master))
		qdel(src)
		return

	//Try to persist after the mob master has been deleted by retaining with their lingering mind as new master.
	var/mob/mob_master = faction_master
	if(QDELETED(mob_master.mind))
		qdel(src)
		return

	replace_faction_master(mob_master.mind)

/datum/component/faction_bind/proc/replace_faction_master(datum/new_master)
	UnregisterSignal(faction_master, COMSIG_PARENT_QDELETING)
	REMOVE_TRAIT(parent, TRAIT_FACTION_MASTER(faction_master), trait_source)

	faction_master = new_master

	RegisterSignal(faction_master, COMSIG_PARENT_QDELETING, .proc/on_faction_master_qdeleting)
	ADD_TRAIT(parent, TRAIT_FACTION_MASTER(faction_master), trait_source)

/datum/component/faction_bind/proc/on_parent_faction_check(datum/source, factions, exact_match, datum/target)
	SIGNAL_HANDLER
	if(target == faction_master)
		return TRUE
	if(target && !exact_match && HAS_TRAIT(target, TRAIT_FACTION_MASTER(faction_master)))
		return TRUE
	if(do_faction_check)
		do_faction_check = FALSE // Temporarily set it to false to avoid potential infinite loops.
		. = faction_master.faction_check(target || factions, exact_match, blacklist)
		do_faction_check = TRUE

/datum/component/faction_bind/proc/on_parent_faction_checked(datum/source, datum/checker, exact_match)
	SIGNAL_HANDLER
	if(checker == faction_master)
		return TRUE
	if(!exact_match && HAS_TRAIT(checker, TRAIT_FACTION_MASTER(faction_master)))
		return TRUE
	if(do_faction_check)
		do_faction_check = FALSE
		. = checker.faction_check(faction_master, exact_match, blacklist)
		do_faction_check = TRUE
