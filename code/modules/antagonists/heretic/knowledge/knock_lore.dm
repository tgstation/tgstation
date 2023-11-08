/**
 * # The path of Knock.
 *
 * Goes as follows:
 *
 * A Locksmith’s Secret
 * Grasp of Knock
 * > Sidepaths:
 *   Ashen Eyes
 *	 Codex Cicatrix
 * Key Keeper’s Burden
 *
 * Rite Of Passage
 * Mark Of Knock
 * Ritual of Knowledge
 * Burglar's Finesse
 * > Sidepaths:
 *   Apetra Vulnera
 *   Opening Blast
 *
 * Opening Blade
 * Caretaker’s Last Refuge
 *
 * Many secrets behind the Spider Door
 */
/datum/heretic_knowledge/limited_amount/starting/base_knock
	name = "A Locksmith’s Secret"
	desc = "Opens up the Path of Knock to you. \
		Allows you to transmute a knife and a crowbar into a Key Blade. \
		You can only create two at a time and they function as fast crowbars. \
		In addition, they can fit into utility belts."
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
		DNA locks on mechs will be removed, and any pilot will be ejected. Works on consoles. \
		Makes a distinctive knocking sound on use."
	gain_text = "Nothing may remain closed from my touch."
	next_knowledge = list(
		/datum/heretic_knowledge/key_ring,
		/datum/heretic_knowledge/medallion,
		/datum/heretic_knowledge/codex_cicatrix,
	)
	cost = 1
	route = PATH_KNOCK

/datum/heretic_knowledge/knock_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp))
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/knock_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/knock_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER
	var/obj/item/clothing/under/suit = target.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	if(istype(suit) && suit.adjusted == NORMAL_STYLE)
		suit.toggle_jumpsuit_adjust()
		suit.update_appearance()

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
	gain_text = "Gateways shall open before me, my very will ensnaring reality."
	adds_sidepath_points = 1
	required_atoms = list(
		/obj/item/storage/wallet = 1,
		/obj/item/stack/rods = 1,
		/obj/item/card/id = 1,
	)
	result_atoms = list(/obj/item/card/id/advanced/heretic)
	next_knowledge = list(/datum/heretic_knowledge/limited_amount/rite_of_passage)
	cost = 1
	route = PATH_KNOCK

/datum/heretic_knowledge/limited_amount/rite_of_passage // item that creates 3 max at a time heretic only barriers, probably should limit to 1 only, holy people can also pass
	name = "Rite Of Passage"
	desc = "Allows you to transmute a white crayon, a wooden plank, and a multitool to create a Consecrated Book. \
		It can materialize a barricade at range that only you and people resistant to magic can pass. 3 uses."
	gain_text = "With this I can repel those that intend me harm."
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
	desc = "Your Mansus Grasp now applies the Mark of Knock. \
		Attack a marked person to bar them from all passages for the duration of the mark. \
		This will make it so that they have no access whatsoever, even public access doors will reject them."
	gain_text = "Their requests for passage will remain unheeded."
	next_knowledge = list(/datum/heretic_knowledge/knowledge_ritual/knock)
	route = PATH_KNOCK
	mark_type = /datum/status_effect/eldritch/knock

/datum/heretic_knowledge/knowledge_ritual/knock
	next_knowledge = list(/datum/heretic_knowledge/spell/burglar_finesse)
	route = PATH_KNOCK

/datum/heretic_knowledge/spell/burglar_finesse
	name = "Burglar's Finesse"
	desc = "Grants you Burglar's Finesse, a single-target spell \
		that puts a random item from the victims backpack into your hand."
	gain_text = "Their trinkets will be mine, as will their lives in due time."
	adds_sidepath_points = 1
	next_knowledge = list(
		/datum/heretic_knowledge/spell/apetra_vulnera,
		/datum/heretic_knowledge/spell/opening_blast,
		/datum/heretic_knowledge/blade_upgrade/flesh/knock,
	)
	spell_to_add = /datum/action/cooldown/spell/pointed/burglar_finesse
	cost = 2
	route = PATH_KNOCK

/datum/heretic_knowledge/blade_upgrade/flesh/knock //basically a chance-based weeping avulsion version of the former
	name = "Opening Blade"
	desc = "Your blade has a chance to cause a weeping avulsion on attack."
	gain_text = "The power of my patron courses through my blade, willing their very flesh to part."
	next_knowledge = list(/datum/heretic_knowledge/spell/caretaker_refuge)
	route = PATH_KNOCK
	wound_type = /datum/wound/slash/flesh/critical
	var/chance = 35

/datum/heretic_knowledge/blade_upgrade/flesh/knock/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(prob(chance))
		return ..()

/datum/heretic_knowledge/spell/caretaker_refuge
	name = "Caretaker’s Last Refuge"
	desc = "Gives you a spell that makes you transparent and not dense. Cannot be used near living sentient beings. \
		While in refuge, you cannot use your hands or spells, and you are immune to slowdown. \
		You are invincible but unable to harm anything. Cancelled by being hit with an anti-magic item."
	gain_text = "Then I saw my my own reflection cascaded mind-numbingly enough times that I was but a haze."
	adds_sidepath_points = 1
	next_knowledge = list(/datum/heretic_knowledge/ultimate/knock_final)
	route = PATH_KNOCK
	spell_to_add = /datum/action/cooldown/spell/caretaker
	cost = 1

/datum/heretic_knowledge/ultimate/knock_final
	name = "Many secrets behind the Spider Door"
	desc = "The ascension ritual of the Path of Knock. \
		Bring 3 corpses without organs in their torso to a transmutation rune to complete the ritual. \
		When completed, you gain the ability to transform into empowered eldritch creatures \
		and in addition, create a tear to the Spider Door; \
		a tear in reality located at the site of this ritual. \
		Eldritch creatures will endlessly pour from this rift \
		who are bound to obey your instructions."
	gain_text = "With her knowledge, and what I had seen, I knew what to do. \
		I had to open the gates, with the holes in my foes as Ways! \
		Reality will soon be torn, the Spider Gate opened! WITNESS ME!"
	required_atoms = list(/mob/living/carbon/human = 3)
	route = PATH_KNOCK

/datum/heretic_knowledge/ultimate/knock_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue
		var/obj/item/bodypart/chest = body.get_bodypart(BODY_ZONE_CHEST)
		if(LAZYLEN(chest.get_organs()))
			to_chat(user, span_hierophant_warning("[body] has organs in their chest."))
			continue

		selected_atoms += body

	if(!LAZYLEN(selected_atoms))
		loc.balloon_alert(user, "ritual failed, not enough valid bodies!")
		return FALSE
	return TRUE

/datum/heretic_knowledge/ultimate/knock_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce(
		text = "Delta-class dimensional anomaly detec[generate_heretic_text()] Reality rended, torn. Gates open, doors open, [user.real_name] has ascended! Fear the tide! [generate_heretic_text()]",
		title = "[generate_heretic_text()]",
		sound = ANNOUNCER_SPANOMALIES,
		color_override = "pink",
	)
	user.client?.give_award(/datum/award/achievement/misc/knock_ascension, user)

	// buffs
	var/datum/action/cooldown/spell/shapeshift/eldritch/ascension/transform_spell = new(user.mind)
	transform_spell.Grant(user)

	user.client?.give_award(/datum/award/achievement/misc/knock_ascension, user)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	var/datum/heretic_knowledge/blade_upgrade/flesh/knock/blade_upgrade = heretic_datum.get_knowledge(/datum/heretic_knowledge/blade_upgrade/flesh/knock)
	blade_upgrade.chance += 30
	new /obj/structure/knock_tear(loc, user.mind)
