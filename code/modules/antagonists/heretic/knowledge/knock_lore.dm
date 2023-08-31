/**
 * # The path of Flesh.
 *
 * Goes as follows:
 *
 * Principle of Hunger
 * Grasp of Flesh
 * Imperfect Ritual
 * > Sidepaths:
 *   Void Cloak
 *   Ashen Eyes
 *
 * Mark of Flesh
 * Ritual of Knowledge
 * Flesh Surgery
 * Raw Ritual
 * > Sidepaths:
 *   Blood Siphon
 *   Curse of Paralysis
 *
 * Bleeding Steel
 * Lonely Ritual
 * > Sidepaths:
 *   Ashen Ritual
 *   Cleave
 *
 * Priest's Final Hymn
 */
/datum/heretic_knowledge/limited_amount/starting/base_knock
	name = "A Locksmith’s Secret"
	desc = "Opens up the Path of Knock to you. \
		Allows you to transmute a knife and a crowbar a Key Blade. \
		You can only create two at a time, and they function as fast crowbars."
	gain_text = "The Knock permits no seal and no isolation. It thrusts us gleefully out of the safety of ignorance."
	next_knowledge = list(/datum/heretic_knowledge/knock_grasp)
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/crowbar = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/knock)
	limit = 2
	route = PATH_KNOCK

/datum/heretic_knowledge/knock_grasp
	name = "Grasp of Knock"
	desc = "Your mansus grasp allows you to access anything! Right click on an airlock or a locker to force it open. \
		DNA locked mechs will remove the lock and force the pilot out. Works on consoles. \
		Makes a distinctive knocking sound on use."
	gain_text = "My new found desires drove me to greater and greater heights."
	next_knowledge = list(/datum/heretic_knowledge/key_ring)
	cost = 1
	route = PATH_KNOCK

/datum/heretic_knowledge/knock_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp))

/datum/heretic_knowledge/knock_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY)

/datum/heretic_knowledge/knock_grasp/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER
	
	if(ismecha(target))
		var/obj/vehicle/sealed/mecha/mecha = target
		mecha.dna_lock = null
		for(var/mob/living/occupant as anything in mecha.occupants)
			if(isAI(occupant))
				continue
			mecha.mob_exit(occupant, randomstep = TRUE)
	else if(istype(target,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/door = target
		door.unbolt()
	else if(istype(target, /obj/machinery/computer))
		var/obj/machinery/computer/computer = target
		computer.authenticated = TRUE
		computer.balloon_alert(source, "unlocked")

	var/turf/target_turf = get_turf(target)
	SEND_SIGNAL(target_turf, COMSIG_ATOM_MAGICALLY_UNLOCKED, src, source)
	playsound(target, 'sound/magic/hereticknock.ogg', 100, TRUE, -1)
	
	return COMPONENT_USE_HAND

/datum/heretic_knowledge/key_ring
	name = "Key Keeper’s Burden"
	desc = "Allows you to transmute a wallet, an iron rod, and an ID card to create an Eldritch Card. \
		It functions the same as an ID Card, but attacking it with an ID card fuses it and gains its access. \
		You can use it in-hand to change its form to a card you fused. \
		Does not preserve the card used in the ritual."
	gain_text = "Every door in the Mansus requires its sacrifice before it will open."
	required_atoms = list(
		/obj/item/storage/wallet = 1,
		/obj/item/stack/rods = 1,
		/obj/item/card/id = 1,
	)
	result_atoms = list(/obj/item/card/id/advanced/heretic)
	next_knowledge = list(/datum/heretic_knowledge/limited_amount/riteofpassage)
	cost = 1
	route = PATH_KNOCK

/datum/heretic_knowledge/limited_amount/riteofpassage // item that creates 3 max at a time heretic only barriers, probably should limit to 1 only, holy people can also pass
	name = "Rite Of Passage"
	desc = "Allows you to transmute a white crayon, a wooden plank, and a multitool to create Consecrated Lintel. \
		It can materialize a barricade at range, that only you and people resistant to magic can pass. 3 uses."
	gain_text = "This is the skull of a door through which power has passed."
	required_atoms = list(
		/obj/item/toy/crayon/white = 1,
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/multitool = 1,
	)
	result_atoms = list(/obj/item/heretic_lintel)
	next_knowledge = list(/datum/heretic_knowledge/mark/knock_mark)
	cost = 1
	route = PATH_KNOCK

/datum/heretic_knowledge/mark/knock_mark
	name = "Mark of Knock"
	desc = "Your Mansus Grasp now applies the Mark of Knock. Attack a marked person to corrupt access on \
		all of their keycards for the duration of the mark. \
		This will make it so that they have no access whatsoever, and even public access doors will deny their passage."
	gain_text = "That's when I saw them, the marked ones. They were out of reach. They screamed, and screamed."
	next_knowledge = list(/datum/heretic_knowledge/knowledge_ritual/knock)
	route = PATH_KNOCK
	mark_type = /datum/status_effect/eldritch/knock

/datum/heretic_knowledge/knowledge_ritual/knock
	next_knowledge = list(/datum/heretic_knowledge/spell/burglar_finesse)
	route = PATH_KNOCK

/datum/heretic_knowledge/spell/burglar_finesse
	name = "Burglar's Finesse"
	desc = "Grants you Burglar's Finesse, a single-target spell \
		that puts a random item from the victims storage into your hand."
	gain_text = "At first I didn't understand these instruments of war, but the Priest \
		told me to use them regardless. Soon, he said, I would know them well."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/apetra_vulnera,
		/datum/heretic_knowledge/blade_upgrade/flesh/knock,
	)
	spell_to_add = /datum/action/cooldown/spell/pointed/burglar_finesse
	cost = 2
	route = PATH_KNOCK

/datum/heretic_knowledge/spell/apetra_vulnera
	name = "Apetra Vulnera"
	desc = "Grants you Apetra Vulnera, a spell \
		that causes heavy bleeding on all bodyparts of the victim that have more than 15 brute."
	gain_text = "To open certain Ways, one must first open oneself."
	next_knowledge = list()
	spell_to_add = /datum/action/cooldown/spell/pointed/apetra_vulnera
	cost = 1
	route = PATH_KNOCK

/datum/heretic_knowledge/blade_upgrade/flesh/knock //basically a chance-based weeping avulsion version of the former
	name = "Opening Blade"
	desc = "Your blade has a chance to cause a weeping avulsion on attack."
	gain_text = "The Uncanny Man was not alone. They led me to the Marshal. \
		I finally began to understand. And then, blood rained from the heavens."
	next_knowledge = list(/datum/heretic_knowledge/summon/stalker)
	route = PATH_KNOCK
	wound_type = /datum/wound/slash/critical

/datum/heretic_knowledge/blade_upgrade/flesh/knock/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(prob(40))
		. = ..()
