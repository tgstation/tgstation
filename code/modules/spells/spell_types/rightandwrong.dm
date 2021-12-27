//In this file: Summon Magic/Summon Guns/Summon Events
//and corresponding datum controller for them

GLOBAL_DATUM(summon_guns, /datum/summon_guns_controller)
GLOBAL_DATUM(summon_magic, /datum/summon_magic_controller)

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

/proc/give_guns(mob/living/carbon/human/H)
	if(H.stat == DEAD || !(H.client))
		return
	if(H.mind)
		if(IS_WIZARD(H) || H.mind.has_antag_datum(/datum/antagonist/survivalist/guns))
			return
	var/datum/summon_guns_controller/controller = GLOB.summon_guns
	if(prob(controller.survivor_probability) && !(H.mind.has_antag_datum(/datum/antagonist)))
		H.mind.add_antag_datum(/datum/antagonist/survivalist/guns)
		H.log_message("was made into a survivalist, and trusts no one!", LOG_ATTACK, color="red")

	var/gun_type = pick(GLOB.summoned_guns)
	var/obj/item/gun/G = new gun_type(get_turf(H))
	if (istype(G)) // The list may contain some non-gun type guns which do not have this proc
		G.unlock()
	playsound(get_turf(H),'sound/magic/summon_guns.ogg', 50, TRUE)

	var/in_hand = H.put_in_hands(G) // not always successful

	to_chat(H, span_warning("\A [G] appears [in_hand ? "in your hand" : "at your feet"]!"))

/proc/give_magic(mob/living/carbon/human/H)
	if(H.stat == DEAD || !(H.client))
		return
	if(H.mind)
		if(IS_WIZARD(H) || H.mind.has_antag_datum(/datum/antagonist/survivalist/magic))
			return
	if(!GLOB.summon_magic)
		return
	var/datum/summon_magic_controller/controller = GLOB.summon_magic
	if(prob(controller.survivor_probability) && !(H.mind.has_antag_datum(/datum/antagonist)))
		H.mind.add_antag_datum(/datum/antagonist/survivalist/magic)
		H.log_message("was made into a survivalist, and trusts no one!</font>", LOG_ATTACK, color="red")

	var/magic_type = pick(GLOB.summoned_magic)
	var/lucky = FALSE
	if(prob(SPECIALIST_MAGIC_PROB))
		magic_type = pick(GLOB.summoned_special_magic)
		lucky = TRUE

	var/obj/item/M = new magic_type(get_turf(H))
	playsound(get_turf(H),'sound/magic/summon_magic.ogg', 50, TRUE)

	var/in_hand = H.put_in_hands(M)

	to_chat(H, span_warning("\A [M] appears [in_hand ? "in your hand" : "at your feet"]!"))
	if(lucky)
		to_chat(H, span_notice("You feel incredibly lucky."))


/proc/rightandwrong(summon_type, mob/user, survivor_probability)
	if(user) //in this case either someone holding a spellbook or a badmin
		to_chat(user, span_warning("You summoned [summon_type]!"))
		message_admins("[ADMIN_LOOKUPFLW(user)] summoned [summon_type]!")
		log_game("[key_name(user)] summoned [summon_type]!")

	if(summon_type == SUMMON_MAGIC)
		GLOB.summon_magic = new /datum/summon_magic_controller(survivor_probability)
	else if(summon_type == SUMMON_GUNS)
		GLOB.summon_guns = new /datum/summon_guns_controller(survivor_probability)
	else
		CRASH("Bad summon_type given: [summon_type]")

/proc/summonevents()
	if(!SSevents.wizardmode)
		SSevents.frequency_lower = 600 //1 minute lower bound
		SSevents.frequency_upper = 3000 //5 minutes upper bound
		SSevents.toggleWizardmode()
		SSevents.reschedule()

	else //Speed it up
		SSevents.frequency_upper -= 600 //The upper bound falls a minute each time, making the AVERAGE time between events lessen
		if(SSevents.frequency_upper < SSevents.frequency_lower) //Sanity
			SSevents.frequency_upper = SSevents.frequency_lower

		SSevents.reschedule()
		message_admins("Summon Events intensifies, events will now occur every [SSevents.frequency_lower / 600] to [SSevents.frequency_upper / 600] minutes.")
		log_game("Summon Events was increased!")

#undef SPECIALIST_MAGIC_PROB

/**
 * The magic controller handles the summon magic event.
 * It is first created when summon magic event is triggered, and it can be referenced from GLOB.summon_magic
 */
/datum/summon_magic_controller
	///chances someone who is given magic will be an antagonist
	var/survivor_probability = 0

/datum/summon_magic_controller/New(survivor_probability)
	. = ..()
	src.survivor_probability = survivor_probability
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, .proc/magic_up_new_crew)

	for(var/mob/living/carbon/human/unarmed_human in GLOB.player_list)
		var/turf/turf_check = get_turf(unarmed_human)
		if(turf_check && is_away_level(turf_check.z))
			continue
		give_magic(unarmed_human)

/datum/summon_magic_controller/Destroy(force, ...)
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)

///signal proc to give magic to new crewmembers
/datum/summon_magic_controller/proc/magic_up_new_crew(datum/source, mob/living/new_crewmember, rank)
	SIGNAL_HANDLER
	if(ishuman(new_crewmember))
		INVOKE_ASYNC(GLOB.summon_magic, .proc/give_magic, new_crewmember)

/**
 * The guns controller handles the summon guns event.
 * It is first created when summon guns event is triggered, and it can be referenced from GLOB.summon_guns
 */
/datum/summon_guns_controller
	///chances someone who is given guns will be an antagonist
	var/survivor_probability = 0

/datum/summon_guns_controller/New(survivor_probability)
	. = ..()
	src.survivor_probability = survivor_probability
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, .proc/arm_up_new_crew)

	for(var/mob/living/carbon/human/unarmed_human in GLOB.player_list)
		var/turf/turf_check = get_turf(unarmed_human)
		if(turf_check && is_away_level(turf_check.z))
			continue
		give_guns(unarmed_human)

/datum/summon_guns_controller/Destroy(force, ...)
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)

///signal proc to give guns to new crewmembers
/datum/summon_guns_controller/proc/arm_up_new_crew(datum/source, mob/living/new_crewmember, rank)
	SIGNAL_HANDLER
	if(ishuman(new_crewmember))
		INVOKE_ASYNC(GLOB.summon_guns, .proc/give_guns, new_crewmember)

