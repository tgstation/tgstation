//In this file: Summon Magic/Summon Guns/Summon Events
//and corresponding datum controller for them

GLOBAL_DATUM(summon_guns, /datum/summon_things_controller)
GLOBAL_DATUM(summon_magic, /datum/summon_things_controller)

// 1 in 50 chance of getting something really special.
#define SPECIALIST_MAGIC_PROB 2

GLOBAL_LIST_INIT(summoned_guns, list(
	/obj/item/gun/energy/disabler,
	/obj/item/gun/energy/e_gun,
	/obj/item/gun/energy/e_gun/advtaser,
	/obj/item/gun/energy/laser,
	/obj/item/gun/ballistic/revolver,
	/obj/item/gun/ballistic/revolver/detective,
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
	/obj/item/gun/energy/kinetic_accelerator/crossbow/large,
	/obj/item/gun/energy/e_gun/nuclear,
	/obj/item/gun/ballistic/automatic/proto,
	/obj/item/gun/ballistic/automatic/c20r,
	/obj/item/gun/ballistic/automatic/l6_saw,
	/obj/item/gun/ballistic/automatic/m90,
	/obj/item/gun/energy/alien,
	/obj/item/gun/energy/e_gun/dragnet,
	/obj/item/gun/energy/e_gun/turret,
	/obj/item/gun/energy/pulse/carbine,
	/obj/item/gun/energy/decloner,
	/obj/item/gun/energy/mindflayer,
	/obj/item/gun/energy/kinetic_accelerator,
	/obj/item/gun/energy/plasmacutter/adv,
	/obj/item/gun/energy/wormhole_projector,
	/obj/item/gun/ballistic/automatic/wt550,
	/obj/item/gun/ballistic/shotgun/bulldog,
	/obj/item/gun/ballistic/revolver/grenadelauncher,
	/obj/item/gun/ballistic/revolver/golden,
	/obj/item/gun/ballistic/automatic/sniper_rifle,
	/obj/item/gun/ballistic/rocketlauncher,
	/obj/item/gun/medbeam,
	/obj/item/gun/energy/laser/scatter,
	/obj/item/gun/energy/laser/thermal,
	/obj/item/gun/energy/laser/thermal/inferno,
	/obj/item/gun/energy/laser/thermal/cryo,
	/obj/item/gun/energy/gravity_gun))

//if you add anything that isn't covered by the typepaths below, add it to summon_magic_objective_types
GLOBAL_LIST_INIT(summoned_magic, list(
	/obj/item/book/granter/spell/fireball,
	/obj/item/book/granter/spell/smoke,
	/obj/item/book/granter/spell/blind,
	/obj/item/book/granter/spell/mindswap,
	/obj/item/book/granter/spell/forcewall,
	/obj/item/book/granter/spell/knock,
	/obj/item/book/granter/spell/barnyard,
	/obj/item/book/granter/spell/charge,
	/obj/item/book/granter/spell/summonitem,
	/obj/item/gun/magic/wand/nothing,
	/obj/item/gun/magic/wand/death,
	/obj/item/gun/magic/wand/resurrection,
	/obj/item/gun/magic/wand/polymorph,
	/obj/item/gun/magic/wand/teleport,
	/obj/item/gun/magic/wand/door,
	/obj/item/gun/magic/wand/fireball,
	/obj/item/gun/magic/staff/healing,
	/obj/item/gun/magic/staff/door,
	/obj/item/scrying,
	/obj/item/warpwhistle,
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
	/obj/item/warpwhistle))

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
	if(IS_WIZARD(to_equip) || to_equip.mind.has_antag_datum(/datum/antagonist/survivalist/guns))
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

/*
 * Triggers Summon Ghosts from [user].
 */
/proc/summon_ghosts(mob/user)

	var/datum/round_event_control/wizard/ghost/ghost_event = locate() in SSevents.control
	if(ghost_event)
		if(user)
			to_chat(user, span_warning("You summoned ghosts!"))
			message_admins("[ADMIN_LOOKUPFLW(user)] summoned ghosts!")
			log_game("[key_name(user)] summoned ghosts!")
		else
			message_admins("Summon Ghosts was triggered!")
			log_game("Summon Ghosts was triggered!")
		ghost_event.runEvent()
	else
		stack_trace("Unable to run summon ghosts, due to being unable to locate the associated event.")
		if(user)
			to_chat(user, span_warning("You... try to summon ghosts, but nothing seems to happen. Shame."))

/*
 * Triggers Summon Magic from [user].
 * Can optionally be passed [survivor_probability], to set the chance of creating survivalists.
 * If Summon Magic has already been triggered, gives out magic to everyone again.
 */
/proc/summon_magic(mob/user, survivor_probability = 0)
	if(user)
		to_chat(user, span_warning("You summoned magic!"))
		message_admins("[ADMIN_LOOKUPFLW(user)] summoned magic!")
		log_game("[key_name(user)] summoned magic!")
	else
		message_admins("Summon Magic was triggered!")
		log_game("Summon Magic was triggered!")

	if(GLOB.summon_magic)
		GLOB.summon_magic.survivor_probability = survivor_probability
	else
		GLOB.summon_magic = new /datum/summon_things_controller(/proc/give_magic, survivor_probability)
	GLOB.summon_magic.give_out_gear()

/*
 * Triggers Summon Guns from [user].
 * Can optionally be passed [survivor_probability], to set the chance of creating survivalists.
 * If Summon Guns has already been triggered, gives out guns to everyone again.
 */
/proc/summon_guns(mob/user, survivor_probability = 0)
	if(user)
		to_chat(user, span_warning("You summoned guns!"))
		message_admins("[ADMIN_LOOKUPFLW(user)] summoned guns!")
		log_game("[key_name(user)] summoned guns!")
	else
		message_admins("Summon Guns was triggered!")
		log_game("Summon Guns was triggered!")

	if(GLOB.summon_guns)
		GLOB.summon_guns.survivor_probability = survivor_probability
	else
		GLOB.summon_guns = new /datum/summon_things_controller(/proc/give_guns, survivor_probability)
	GLOB.summon_guns.give_out_gear()

/*
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
			to_chat(user, span_warning("You have intensified summon events, causing them to occur more often!"))
			message_admins("[ADMIN_LOOKUPFLW(user)] intensified summon events!")
			log_game("[key_name(user)] intensified events!")
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
			to_chat(user, span_warning("You have cast summon events!"))
			message_admins("[ADMIN_LOOKUPFLW(user)] summoned events!")
			log_game("[key_name(user)] summoned events!")
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
	/// The proc path we call on someone to equip them with stuff. Cannot function without it.
	var/give_proc_path
	/// The number of equipment we give to latejoiners, to make sure they catch up if it was casted multiple times.
	var/num_to_give_to_latejoiners = 0

/datum/summon_things_controller/New(give_proc_path, survivor_probability = 0)
	. = ..()
	if(isnull(give_proc_path))
		CRASH("[type] was created without a give_proc_path (the proc that gives people stuff)!")

	src.survivor_probability = survivor_probability
	src.give_proc_path = give_proc_path

	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, .proc/gear_up_new_crew)

/datum/summon_things_controller/Destroy(force, ...)
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)

/// Calls our give_proc_path on all humans in the player list.
/datum/summon_things_controller/proc/give_out_gear()
	num_to_give_to_latejoiners++
	for(var/mob/living/carbon/human/to_equip in GLOB.player_list)
		var/turf/turf_check = get_turf(to_equip)
		if(turf_check && is_away_level(turf_check.z))
			continue
		INVOKE_ASYNC(GLOBAL_PROC, give_proc_path, to_equip)

/// Signal proc from [COMSIG_GLOB_CREWMEMBER_JOINED].
/// Calls give_proc_path on latejoiners a number of times (based on num_to_give_to_latejoiners)
/datum/summon_things_controller/proc/gear_up_new_crew(datum/source, mob/living/new_crewmember, rank)
	SIGNAL_HANDLER

	if(!ishuman(new_crewmember))
		return

	for(var/i in 1 to num_to_give_to_latejoiners)
		INVOKE_ASYNC(GLOBAL_PROC, give_proc_path, new_crewmember)
