/**
 * # The path of Lock.
 * Spell names are in this language: EGYPTIAN
 * Both are related: Egyptian-Mysteries-Secrets-Lock
 *
 * Goes as follows:
 *
 * A Steward's Secret
 * Grasp of Lock
 * Key Keeper’s Burden
 * > Sidepaths:
 *   Mindgate
 * Concierge's Rite
 * Mark Of Lock
 * Ritual of Knowledge
 * Burglar's Finesse
 * > Sidepaths:
 *   Opening Blast
 *   Unfathomable Curio
 * 	 Unsealed arts
 *
 * Opening Blade
 * Caretaker’s Last Refuge
 * > Sidepaths:
 * 	 Apetra Vulnera
 *
 * Unlock the Labyrinth
 */
/datum/heretic_knowledge/limited_amount/starting/base_knock
	name = "A Steward's Secret"
	desc = "Opens up the Path of Lock to you. \
		Allows you to transmute a knife and a crowbar into a Key Blade. \
		You can only create two at a time and they function as fast crowbars. \
		In addition, they can fit into utility belts."
	gain_text = "The Locked Labyrinth leads to freedom. But only the trapped Stewards know the correct path."
	next_knowledge = list(/datum/heretic_knowledge/lock_grasp)
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/crowbar = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/lock)
	limit = 2
	route = PATH_LOCK

/datum/heretic_knowledge/lock_grasp
	name = "Grasp of Lock"
	desc = "Your mansus grasp allows you to access anything! Right click on an airlock or a locker to force it open. \
		DNA locks on mechs will be removed, and any pilot will be ejected. Works on consoles. \
		Makes a distinctive knocking sound on use."
	gain_text = "Nothing may remain closed from my touch."
	next_knowledge = list(/datum/heretic_knowledge/key_ring)
	cost = 1
	route = PATH_LOCK

/datum/heretic_knowledge/lock_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp))
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/lock_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/lock_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER
	var/obj/item/clothing/under/suit = target.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	if(istype(suit) && suit.adjusted == NORMAL_STYLE)
		suit.toggle_jumpsuit_adjust()
		suit.update_appearance()

/datum/heretic_knowledge/lock_grasp/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
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
		Hit a pair of airlocks with it to create a pair of portals, which will teleport you between them, but teleport non-heretics randomly. \
		You can ctrl-click the card to invert this behavior for created portals. \
		Each card may only sustain a single pair of portals at the same time. \
		It also functions and appears the same as a regular ID Card. \
		Attacking it with a normal ID card consumes it and gains its access, and you can use it in-hand to change its appearance to a card you fused. \
		Does not preserve the card originally used in the ritual."
	gain_text = "The Keeper sneered. \"These plastic rectangles are a mockery of keys, and I curse every door that desires them.\""
	required_atoms = list(
		/obj/item/storage/wallet = 1,
		/obj/item/stack/rods = 1,
		/obj/item/card/id = 1,
	)
	result_atoms = list(/obj/item/card/id/advanced/heretic)
	next_knowledge = list(
		/datum/heretic_knowledge/mark/lock_mark,
		/datum/heretic_knowledge/spell/mind_gate,
	)
	cost = 1
	route = PATH_LOCK

/datum/heretic_knowledge/mark/lock_mark
	name = "Mark of Lock"
	desc = "Your Mansus Grasp now applies the Mark of Lock. \
		Attack a marked person to bar them from all passages for the duration of the mark. \
		This will make it so that they have no access whatsoever, even public access doors will reject them."
	gain_text = "The Gatekeeper was a corrupt Steward. She hindered her fellows for her own twisted amusement."
	next_knowledge = list(/datum/heretic_knowledge/knowledge_ritual/lock)
	route = PATH_LOCK
	mark_type = /datum/status_effect/eldritch/lock

/datum/heretic_knowledge/knowledge_ritual/lock
	next_knowledge = list(/datum/heretic_knowledge/limited_amount/concierge_rite)
	route = PATH_LOCK

/datum/heretic_knowledge/limited_amount/concierge_rite // item that creates 3 max at a time heretic only barriers, probably should limit to 1 only, holy people can also pass
	name = "Concierge's Rite"
	desc = "Allows you to transmute a white crayon, a wooden plank, and a multitool to create a Labyrinth Handbook. \
		It can materialize a barricade at range that only you and people resistant to magic can pass. 3 uses."
	gain_text = "The Concierge scribbled my name into the Handbook. \"Welcome to your new home, fellow Steward.\""
	required_atoms = list(
		/obj/item/toy/crayon/white = 1,
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/multitool = 1,
	)
	result_atoms = list(/obj/item/heretic_labyrinth_handbook)
	next_knowledge = list(/datum/heretic_knowledge/spell/burglar_finesse)
	cost = 1
	route = PATH_LOCK

/datum/heretic_knowledge/spell/burglar_finesse
	name = "Burglar's Finesse"
	desc = "Grants you Burglar's Finesse, a single-target spell \
		that puts a random item from the victims backpack into your hand."
	gain_text = "Consorting with Burglar spirits is frowned upon, but a Steward will always want to learn about new doors."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/opening_blast,
		/datum/heretic_knowledge/reroll_targets,
		/datum/heretic_knowledge/blade_upgrade/flesh/lock,
		/datum/heretic_knowledge/unfathomable_curio,
		/datum/heretic_knowledge/painting,
	)
	spell_to_add = /datum/action/cooldown/spell/pointed/burglar_finesse
	cost = 1
	route = PATH_LOCK

/datum/heretic_knowledge/blade_upgrade/flesh/lock //basically a chance-based weeping avulsion version of the former
	name = "Opening Blade"
	desc = "Your blade has a chance to cause a weeping avulsion on attack."
	gain_text = "The Pilgrim-Surgeon was not an Steward. Nonetheless, its blades and sutures proved a match for their keys."
	next_knowledge = list(/datum/heretic_knowledge/spell/caretaker_refuge)
	route = PATH_LOCK
	wound_type = /datum/wound/slash/flesh/critical
	var/chance = 35

/datum/heretic_knowledge/blade_upgrade/flesh/lock/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(prob(chance))
		return ..()

/datum/heretic_knowledge/spell/caretaker_refuge
	name = "Caretaker’s Last Refuge"
	desc = "Gives you a spell that makes you transparent and not dense. Cannot be used near living sentient beings. \
		While in refuge, you cannot use your hands or spells, and you are immune to slowdown. \
		You are invincible but unable to harm anything. Cancelled by being hit with an anti-magic item."
	gain_text = "Jealously, the Guard and the Hound hunted me. But I unlocked my form, and was but a haze, untouchable."
	next_knowledge = list(
		/datum/heretic_knowledge/ultimate/lock_final,
		/datum/heretic_knowledge/spell/apetra_vulnera,
	)
	route = PATH_LOCK
	spell_to_add = /datum/action/cooldown/spell/caretaker
	cost = 1

/datum/heretic_knowledge/ultimate/lock_final
	name = "Unlock the Labyrinth"
	desc = "The ascension ritual of the Path of Knock. \
		Bring 3 corpses without organs in their torso to a transmutation rune to complete the ritual. \
		When completed, you gain the ability to transform into empowered eldritch creatures \
		and your keyblades will become even deadlier. \
		In addition, you will create a tear to the Labyrinth's heart; \
		a tear in reality located at the site of this ritual. \
		Eldritch creatures will endlessly pour from this rift \
		who are bound to obey your instructions."
	gain_text = "The Stewards guided me, and I guided them. \
		My foes were the Locks and my blades were the Key! \
		The Labyrinth will be Locked no more, and freedom will be ours! WITNESS US!"
	required_atoms = list(/mob/living/carbon/human = 3)
	route = PATH_LOCK

/datum/heretic_knowledge/ultimate/lock_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue
		if(LAZYLEN(body.get_organs_for_zone(BODY_ZONE_CHEST)))
			to_chat(user, span_hierophant_warning("[body] has organs in their chest."))
			continue

		selected_atoms += body

	if(!LAZYLEN(selected_atoms))
		loc.balloon_alert(user, "ritual failed, not enough valid bodies!")
		return FALSE
	return TRUE

/datum/heretic_knowledge/ultimate/lock_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce(
		text = "Delta-class dimensional anomaly detec[generate_heretic_text()] Reality rended, torn. Gates open, doors open, [user.real_name] has ascended! Fear the tide! [generate_heretic_text()]",
		title = "[generate_heretic_text()]",
		sound = 'sound/ambience/antag/heretic/ascend_knock.ogg',
		color_override = "yellow",
	)
	user.client?.give_award(/datum/award/achievement/misc/lock_ascension, user)

	// buffs
	var/datum/action/cooldown/spell/shapeshift/eldritch/ascension/transform_spell = new(user.mind)
	transform_spell.Grant(user)

	user.client?.give_award(/datum/award/achievement/misc/lock_ascension, user)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	var/datum/heretic_knowledge/blade_upgrade/flesh/lock/blade_upgrade = heretic_datum.get_knowledge(/datum/heretic_knowledge/blade_upgrade/flesh/lock)
	blade_upgrade.chance += 30
	new /obj/structure/lock_tear(loc, user.mind)
