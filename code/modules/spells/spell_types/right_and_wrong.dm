//In this file: Summon Magic/Summon Guns/Summon Events
//and corresponding datum controller for them

/// A global singleton datum used to store a "summon things controller" for Summon Guns, to grant random guns to stationgoers and latejoiners
GLOBAL_DATUM(summon_guns, /datum/summon_things_controller/item)
/// A global singleton datum used to store a "summon things controller" for Summon Magic, to grant random magical items to stationgoers and latejoiners
GLOBAL_DATUM(summon_magic, /datum/summon_things_controller/item)
/// A global singleton datum used to store a "summon things controller" for Mass Teaching, to grant a specific spellbook entry to stationgoers and latejoiners
GLOBAL_DATUM(mass_teaching, /datum/summon_things_controller/spellbook_entry)

// 1 in 50 chance of getting something really special.
#define SPECIALIST_MAGIC_PROB 2

GLOBAL_LIST_INIT(summoned_guns, list(
	/obj/item/gun/energy/disabler,
	/obj/item/gun/energy/e_gun,
	/obj/item/gun/energy/e_gun/advtaser,
	/obj/item/gun/energy/laser,
	/obj/item/gun/ballistic/revolver,
	/obj/item/gun/ballistic/revolver/syndicate,
	/obj/item/gun/ballistic/revolver/c38/detective,
	/obj/item/gun/ballistic/automatic/pistol/deagle/camo,
	/obj/item/gun/ballistic/automatic/gyropistol,
	/obj/item/gun/energy/pulse,
	/obj/item/gun/ballistic/automatic/pistol/suppressed,
	/obj/item/gun/ballistic/shotgun/doublebarrel,
	/obj/item/gun/ballistic/shotgun,
	/obj/item/gun/ballistic/shotgun/automatic/combat,
	/obj/item/gun/ballistic/automatic/ar,
	/obj/item/gun/ballistic/revolver/mateba,
	/obj/item/gun/ballistic/rifle/boltaction,
	/obj/item/gun/ballistic/rifle/boltaction/harpoon,
	/obj/item/gun/ballistic/automatic/mini_uzi,
	/obj/item/gun/energy/lasercannon,
	/obj/item/gun/energy/recharge/ebow/large,
	/obj/item/gun/energy/e_gun/nuclear,
	/obj/item/gun/ballistic/automatic/proto,
	/obj/item/gun/ballistic/automatic/c20r,
	/obj/item/gun/ballistic/automatic/l6_saw,
	/obj/item/gun/ballistic/automatic/m90,
	/obj/item/gun/energy/alien,
	/obj/item/gun/energy/e_gun/dragnet,
	/obj/item/gun/energy/e_gun/turret,
	/obj/item/gun/energy/pulse/carbine,
	/obj/item/gun/energy/mindflayer,
	/obj/item/gun/energy/recharge/kinetic_accelerator,
	/obj/item/gun/energy/plasmacutter/adv,
	/obj/item/gun/energy/wormhole_projector,
	/obj/item/gun/ballistic/automatic/wt550,
	/obj/item/gun/ballistic/shotgun/bulldog,
	/obj/item/gun/ballistic/revolver/grenadelauncher,
	/obj/item/gun/ballistic/revolver/golden,
	/obj/item/gun/ballistic/rifle/sniper_rifle,
	/obj/item/gun/ballistic/rocketlauncher,
	/obj/item/gun/medbeam,
	/obj/item/gun/energy/laser/scatter,
	/obj/item/gun/energy/laser/thermal,
	/obj/item/gun/energy/laser/thermal/inferno,
	/obj/item/gun/energy/laser/thermal/cryo,
	/obj/item/gun/energy/gravity_gun))

//if you add anything that isn't covered by the typepaths below, add it to summon_magic_objective_types
GLOBAL_LIST_INIT(summoned_magic, list(
	/obj/item/book/granter/action/spell/fireball,
	/obj/item/book/granter/action/spell/smoke,
	/obj/item/book/granter/action/spell/blind,
	/obj/item/book/granter/action/spell/mindswap,
	/obj/item/book/granter/action/spell/forcewall,
	/obj/item/book/granter/action/spell/knock,
	/obj/item/book/granter/action/spell/barnyard,
	/obj/item/book/granter/action/spell/charge,
	/obj/item/book/granter/action/spell/summonitem,
	/obj/item/book/granter/action/spell/lightningbolt,
	/obj/item/gun/magic/wand/nothing,
	/obj/item/gun/magic/wand/death,
	/obj/item/gun/magic/wand/resurrection,
	/obj/item/gun/magic/wand/polymorph,
	/obj/item/gun/magic/wand/teleport,
	/obj/item/gun/magic/wand/door,
	/obj/item/gun/magic/wand/fireball,
	/obj/item/gun/magic/staff/healing,
	/obj/item/gun/magic/staff/door,
	/obj/item/gun/magic/staff/babel,
	/obj/item/scrying,
	/obj/item/warp_whistle,
	/obj/item/immortality_talisman,
	/obj/item/melee/ghost_sword))

GLOBAL_LIST_INIT(summoned_special_magic, list(
	/obj/item/gun/magic/staff/change,
	/obj/item/gun/magic/staff/animate,
	/obj/item/storage/belt/wands/full,
	/obj/item/antag_spawner/contract,
	/obj/item/gun/magic/staff/chaos,
	/obj/item/necromantic_stone))

//everything above except for single use spellbooks, because they are counted separately (and are for basic bitches anyways)
GLOBAL_LIST_INIT(summoned_magic_objectives, list(
	/obj/item/antag_spawner/contract,
	/obj/item/gun/magic,
	/obj/item/immortality_talisman,
	/obj/item/melee/ghost_sword,
	/obj/item/necromantic_stone,
	/obj/item/scrying,
	/obj/item/spellbook,
	/obj/item/storage/belt/wands/full,
	/obj/item/warp_whistle))

/*
 * Gives [to_equip] a random gun from a list.
 */
/proc/give_guns(mob/living/carbon/human/to_equip)
	if(!GLOB.summon_guns)
		CRASH("give_guns() was called without a summon guns global datum!")
	if(to_equip.stat == DEAD || !to_equip.client || !to_equip.mind)
		return
	if(IS_WIZARD(to_equip) || to_equip.mind.has_antag_datum(/datum/antagonist/survivalist/guns))
		return

	if(!length(to_equip.mind.antag_datums) && prob(GLOB.summon_guns.survivor_probability))
		to_equip.mind.add_antag_datum(/datum/antagonist/survivalist/guns)
		to_equip.log_message("was made into a survivalist by summon guns, and trusts no one!", LOG_ATTACK, color = "red")

	var/gun_type = pick(GLOB.summoned_guns)
	var/obj/item/gun/spawned_gun = new gun_type(get_turf(to_equip))
	if (istype(spawned_gun)) // The list may contain some non-gun type guns which do not have this proc
		spawned_gun.unlock()
	playsound(get_turf(to_equip), 'sound/magic/summon_guns.ogg', 50, TRUE)

	var/in_hand = to_equip.put_in_hands(spawned_gun) // not always successful

	to_chat(to_equip, span_warning("\A [spawned_gun] appears [in_hand ? "in your hand" : "at your feet"]!"))

/*
 * Gives [to_equip] a random magical spell from a list.
 */
/proc/give_magic(mob/living/carbon/human/to_equip)
	if(!GLOB.summon_magic)
		CRASH("give_magic() was called without a summon magic global datum!")
	if(to_equip.stat == DEAD || !to_equip.client || !to_equip.mind)
		return
	if(IS_WIZARD(to_equip) || to_equip.mind.has_antag_datum(/datum/antagonist/survivalist/magic))
		return

	if(!length(to_equip.mind.antag_datums) && prob(GLOB.summon_magic.survivor_probability))
		to_equip.mind.add_antag_datum(/datum/antagonist/survivalist/magic)
		to_equip.log_message("was made into a survivalist by summon magic, and trusts no one!", LOG_ATTACK, color = "red")

	var/magic_type = prob(SPECIALIST_MAGIC_PROB) ? pick(GLOB.summoned_special_magic) : pick(GLOB.summoned_magic)

	var/obj/item/spawned_magic = new magic_type(get_turf(to_equip))
	playsound(get_turf(to_equip), 'sound/magic/summon_magic.ogg', 50, TRUE)

	var/in_hand = to_equip.put_in_hands(spawned_magic)

	to_chat(to_equip, span_warning("\A [spawned_magic] appears [in_hand ? "in your hand" : "at your feet"]!"))
	if(magic_type in GLOB.summoned_special_magic)
		to_chat(to_equip, span_notice("You feel incredibly lucky."))

/**
 * Triggers Summon Ghosts from [user].
 */
/proc/summon_ghosts(mob/user)

	var/datum/round_event_control/wizard/ghost/ghost_event = locate() in SSevents.control
	if(ghost_event)
		if(user)
			to_chat(user, span_warning("You summoned ghosts!"))
			message_admins("[ADMIN_LOOKUPFLW(user)] summoned ghosts!")
			user.log_message("summoned ghosts!", LOG_GAME)
		else
			message_admins("Summon Ghosts was triggered!")
			log_game("Summon Ghosts was triggered!")
		ghost_event.run_event(event_cause = "a wizard's incantation")
	else
		stack_trace("Unable to run summon ghosts, due to being unable to locate the associated event.")
		if(user)
			to_chat(user, span_warning("You... try to summon ghosts, but nothing seems to happen. Shame."))

/**
 * Triggers Summon Magic from [user].
 * Can optionally be passed [survivor_probability], to set the chance of creating survivalists.
 * If Summon Magic has already been triggered, gives out magic to everyone again.
 */
/proc/summon_magic(mob/user, survivor_probability = 0)
	if(user)
		to_chat(user, span_warning("You summoned magic!"))
		message_admins("[ADMIN_LOOKUPFLW(user)] summoned magic!")
		user.log_message("summoned magic!", LOG_GAME)
	else
		message_admins("Summon Magic was triggered!")
		log_game("Summon Magic was triggered!")

	if(GLOB.summon_magic)
		GLOB.summon_magic.survivor_probability = survivor_probability
	else
		GLOB.summon_magic = new /datum/summon_things_controller/item(survivor_probability, GLOBAL_PROC_REF(give_magic))
	GLOB.summon_magic.equip_all_affected()

/**
 * Triggers Summon Guns from [user].
 * Can optionally be passed [survivor_probability], to set the chance of creating survivalists.
 * If Summon Guns has already been triggered, gives out guns to everyone again.
 */
/proc/summon_guns(mob/user, survivor_probability = 0)
	if(user)
		to_chat(user, span_warning("You summoned guns!"))
		message_admins("[ADMIN_LOOKUPFLW(user)] summoned guns!")
		user.log_message("summoned guns!", LOG_GAME)
	else
		message_admins("Summon Guns was triggered!")
		log_game("Summon Guns was triggered!")

	if(GLOB.summon_guns)
		GLOB.summon_guns.survivor_probability = survivor_probability
	else
		GLOB.summon_guns = new /datum/summon_things_controller/item(survivor_probability, GLOBAL_PROC_REF(give_guns))
	GLOB.summon_guns.equip_all_affected()

/**
 * Triggers Summon Events from [user].
 * If Summon Events has already been triggered, speeds up the event timer.
 */
/proc/summon_events(mob/user)
	// Already in wiz-mode? Speed er up
	if(SSevents.wizardmode)
		SSevents.frequency_upper -= 1 MINUTES //The upper bound falls a minute each time, making the AVERAGE time between events lessen
		if(SSevents.frequency_upper < SSevents.frequency_lower) //Sanity
			SSevents.frequency_upper = SSevents.frequency_lower

		SSevents.reschedule()
		if(user)
			message_admins("[ADMIN_LOOKUPFLW(user)] [ismob(user) ? "":"admin triggered "]intensified summon events!")
			if(ismob(user))
				to_chat(user, span_warning("You have intensified summon events, causing them to occur more often!"))
				user.log_message("intensified events!", LOG_GAME)
			else //admin triggered
				log_admin("[key_name(user)] intensified summon events.")
		else
			log_game("Summon Events was intensified!")

		message_admins("Summon Events intensifies, events will now occur every [SSevents.frequency_lower / 600] to [SSevents.frequency_upper / 600] minutes.")

	// Not in wiz-mode?  Get this show on the road
	else
		SSevents.frequency_lower = 1 MINUTES //1 minute lower bound
		SSevents.frequency_upper = 5 MINUTES //5 minutes upper bound
		SSevents.toggleWizardmode()
		SSevents.reschedule()
		if(user)
			message_admins("[ADMIN_LOOKUPFLW(user)] [ismob(user) ? "summoned":"admin triggered summon"] events!")
			if(ismob(user))
				to_chat(user, span_warning("You have cast summon events!"))
				user.log_message("summoned events!", LOG_GAME)
			else //admin triggered
				log_admin("[key_name(user)] summoned events.")
		else
			message_admins("Summon Events was triggered!")
			log_game("Summon Events was triggered!")

#undef SPECIALIST_MAGIC_PROB

/**
 * The "Give everyone in the crew and also latejoins a buncha stuff" controller.
 * Used for summon magic and summon guns.
 */
/datum/summon_things_controller
	/// Prob. chance someone who is given things will be made a survivalist antagonist.
	var/survivor_probability = 0

/datum/summon_things_controller/New()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(on_latejoin))

/datum/summon_things_controller/Destroy(force)
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)

/// Determins if the mob is valid to be given whatever we're handing out.
/datum/summon_things_controller/proc/can_give_to(mob/who)
	return ishuman(who)

/// Returns a list of minds of all mobs affected by what we're giving out.
/datum/summon_things_controller/proc/get_affected_minds()
	RETURN_TYPE(/list/datum/mind)
	var/list/affected = list()
	for(var/datum/mind/maybe_affected as anything in get_crewmember_minds() | get_antag_minds())
		if(!can_give_to(maybe_affected.current))
			continue
		var/turf/affected_turf = get_turf(maybe_affected.current)
		if(!is_station_level(affected_turf?.z) && !is_mining_level(affected_turf?.z))
			continue
		affected += maybe_affected
	return affected

/// Signal proc from [COMSIG_GLOB_CREWMEMBER_JOINED].
/// Calls give_proc_path on latejoiners a number of times (based on num_to_give_to_latejoiners)
/datum/summon_things_controller/proc/on_latejoin(datum/source, mob/living/new_crewmember, rank)
	SIGNAL_HANDLER

	if(!can_give_to(new_crewmember))
		return

	equip_latejoiner(new_crewmember)

/// Called manually to give out our things to all minds returned by [proc/get_affected_minds()]
/datum/summon_things_controller/proc/equip_all_affected()
	CRASH("[type] did not implement equip_all_affected()!")

/// Called via signal to equip latejoin crewmembers
/datum/summon_things_controller/proc/equip_latejoiner(mob/living/carbon/human/new_crewmember)
	CRASH("[type] did not implement equip_latejoiner()!")

/datum/summon_things_controller/item
	/// The proc path we call on someone to equip them with stuff. Cannot function without it.
	var/give_proc_path
	/// The number of equipment we give to latejoiners, to make sure they catch up if it was casted multiple times.
	var/num_to_give_to_latejoiners = 0

/datum/summon_things_controller/item/New(survivor_probability = 0, give_proc_path)
	. = ..()
	if(isnull(give_proc_path))
		CRASH("[type] was created without a give_proc_path (the proc that gives people stuff)!")

	src.survivor_probability = survivor_probability
	src.give_proc_path = give_proc_path

/datum/summon_things_controller/item/equip_all_affected()
	num_to_give_to_latejoiners += 1
	for(var/datum/mind/crewmember_mind as anything in get_affected_minds())
		INVOKE_ASYNC(GLOBAL_PROC, give_proc_path, crewmember_mind.current)

/datum/summon_things_controller/item/equip_latejoiner(mob/living/carbon/human/new_crewmember)
	for(var/i in 1 to num_to_give_to_latejoiners)
		INVOKE_ASYNC(GLOBAL_PROC, give_proc_path, new_crewmember)

/datum/summon_things_controller/spellbook_entry
	/// Spellbook entry instance to hand out
	var/datum/spellbook_entry/used_entry

/datum/summon_things_controller/spellbook_entry/can_give_to(mob/who)
	return istype(used_entry, /datum/spellbook_entry/item) ? ishuman(who) : isliving(who)

/datum/summon_things_controller/spellbook_entry/get_affected_minds()
	// The wizards get in on this too, wherever they may be
	return ..() | get_antag_minds(/datum/antagonist/wizard)

/datum/summon_things_controller/spellbook_entry/New(entry_type)
	. = ..()
	if(!ispath(entry_type, /datum/spellbook_entry))
		CRASH("[type] was created with an invalid entry type (must be a spellbook entry typepath)!")

	used_entry = new entry_type()

/datum/summon_things_controller/spellbook_entry/equip_all_affected()
	for(var/datum/mind/crewmember_mind as anything in get_affected_minds())
		INVOKE_ASYNC(src, PROC_REF(grant_entry), crewmember_mind.current)

/datum/summon_things_controller/spellbook_entry/equip_latejoiner(mob/living/carbon/human/new_crewmember)
	grant_entry(new_crewmember)

/datum/summon_things_controller/spellbook_entry/proc/grant_entry(mob/to_who)
	var/gained = used_entry.buy_spell(to_who, log_buy = FALSE)
	// Make spells castable without robes
	if(istype(gained, /datum/action/cooldown/spell))
		var/datum/action/cooldown/spell/given_out = gained
		given_out.spell_requirements &= ~SPELL_REQUIRES_WIZARD_GARB

	// Makes staffs and related items usable without penalty
	ADD_TRAIT(to_who.mind, TRAIT_MAGICALLY_GIFTED, INNATE_TRAIT)
