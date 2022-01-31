/// The max amount of health a ghoul has.
#define GHOUL_MAX_HEALTH 25
/// The max amount of health a voiceless dead has.
#define MUTE_MAX_HEALTH 50

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
 * Raw Ritual
 * > Sidepaths:
 *   Carving Knife
 *   Curse of Paralysis
 *
 * Bleeding Steel
 * Lonely Ritual
 * > Sidepaths:
 *   Ashen Ritual
 *   Blood Siphon
 *
 * Priest's Final Hymn
 */
/datum/heretic_knowledge/limited_amount/base_flesh
	name = "Principle of Hunger"
	desc = "Opens up the Path of Flesh to you. \
		Allows you to transmute a knife and a pool of blood into a Bloody Blade. \
		You can only create three at a time."
	gain_text = "Hundreds of us starved, but not me... I found strength in my greed."
	next_knowledge = list(/datum/heretic_knowledge/limited_amount/flesh_grasp)
	banned_knowledge = list(
		/datum/heretic_knowledge/limited_amount/base_ash,
		/datum/heretic_knowledge/limited_amount/base_rust,
		/datum/heretic_knowledge/limited_amount/base_void,
		/datum/heretic_knowledge/final/ash_final,
		/datum/heretic_knowledge/final/rust_final,
		/datum/heretic_knowledge/final/void_final,
	)
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/effect/decal/cleanable/blood = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/flesh)
	limit = 3 // Bumped up so they can arm up their ghouls too.
	cost = 1
	route = PATH_FLESH

/datum/heretic_knowledge/limited_amount/base_flesh/on_research(mob/user)
	. = ..()
	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	our_heretic.heretic_path = route

/datum/heretic_knowledge/limited_amount/flesh_grasp
	name = "Grasp of Flesh"
	desc = "Your Mansus Grasp gains the ability to create a single ghoul out of corpse with a soul. \
		Ghouls have only 25 health and look like husks to the heathens' eyes, but can use Bloody Blades effectively."
	gain_text = "My new found desires drove me to greater and greater heights."
	next_knowledge = list(/datum/heretic_knowledge/limited_amount/flesh_ghoul)
	limit = 1
	cost = 1
	route = PATH_FLESH

/datum/heretic_knowledge/limited_amount/flesh_grasp/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)

/datum/heretic_knowledge/limited_amount/flesh_grasp/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/limited_amount/flesh_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(target.stat != DEAD)
		return

	// Skeletons can't become husks, and monkeys are monkeys.
	if(!ishuman(target) || isskeleton(target) || ismonkey(target))
		target.balloon_alert(source, "invalid body!")
		return COMPONENT_BLOCK_CHARGE_USE

	var/mob/living/carbon/human/human_target = target
	human_target.grab_ghost()
	if(!human_target.mind || !human_target.client)
		target.balloon_alert(source, "no soul!")
		return COMPONENT_BLOCK_CHARGE_USE
	if(HAS_TRAIT(human_target, TRAIT_HUSK))
		target.balloon_alert(source, "husked!")
		return COMPONENT_BLOCK_CHARGE_USE
	if(LAZYLEN(created_items) >= limit)
		target.balloon_alert(source, "at ghoul limit!")
		return COMPONENT_BLOCK_CHARGE_USE

	LAZYADD(created_items, WEAKREF(human_target))
	log_game("[key_name(source)] created a ghoul, controlled by [key_name(human_target)].")
	message_admins("[ADMIN_LOOKUPFLW(source)] created a ghuol, [ADMIN_LOOKUPFLW(human_target)].")

	RegisterSignal(human_target, COMSIG_LIVING_DEATH, .proc/remove_ghoul)
	human_target.revive(full_heal = TRUE, admin_revive = TRUE)
	human_target.setMaxHealth(GHOUL_MAX_HEALTH)
	human_target.health = GHOUL_MAX_HEALTH
	human_target.become_husk(MAGIC_TRAIT)
	human_target.apply_status_effect(/datum/status_effect/ghoul)
	human_target.faction |= FACTION_HERETIC

	var/datum/antagonist/heretic_monster/heretic_monster = human_target.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	heretic_monster.set_owner(source.mind)

/datum/heretic_knowledge/limited_amount/flesh_grasp/proc/remove_ghoul(mob/living/carbon/human/source)
	SIGNAL_HANDLER

	LAZYREMOVE(created_items, WEAKREF(source))
	source.setMaxHealth(initial(source.maxHealth))
	source.cure_husk(MAGIC_TRAIT)
	source.remove_status_effect(/datum/status_effect/ghoul)
	source.mind.remove_antag_datum(/datum/antagonist/heretic_monster)

	UnregisterSignal(source, COMSIG_LIVING_DEATH)

/datum/heretic_knowledge/limited_amount/flesh_ghoul
	name = "Imperfect Ritual"
	desc = "Allows you to transmute a corpse and a poppy to create a Voiceless Dead. \
		Voiceless Dead are mute ghouls and only have 50 health, but can use Bloody Blades effectively. \
		You can only create two at a time. "
	gain_text = "I found notes of a dark ritual, unfinished... yet still, I pushed forward."
	next_knowledge = list(
		/datum/heretic_knowledge/void_cloak,
		/datum/heretic_knowledge/flesh_mark,
		/datum/heretic_knowledge/medallion,
	)
	required_atoms = list(
		/mob/living/carbon/human = 1,
		/obj/item/food/grown/poppy = 1,
	)
	limit = 2
	cost = 1
	route = PATH_FLESH

/datum/heretic_knowledge/limited_amount/flesh_ghoul/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/mob/living/carbon/human/body in atoms)
		// Skeletons can't become husks, and monkeys because they're monkeys.
		if(body.stat != DEAD || isskeleton(body) || ismonkey(body) || HAS_TRAIT(body, TRAIT_HUSK))
			atoms -= body

	return ..()

/datum/heretic_knowledge/limited_amount/flesh_ghoul/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		return FALSE

	soon_to_be_ghoul.grab_ghost()

	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		message_admins("[ADMIN_LOOKUPFLW(user)] is creating a voiceless dead of a body with no player.")
		var/list/mob/dead/observer/candidates = poll_candidates_for_mob("Do you want to play as a [soon_to_be_ghoul.real_name], a voiceless dead?", ROLE_HERETIC, ROLE_HERETIC, 5 SECONDS, soon_to_be_ghoul)
		if(!LAZYLEN(candidates))
			loc.balloon_alert(user, "ritual failed, no ghosts!")
			return FALSE

		var/mob/dead/observer/chosen_candidate = pick(candidates)
		message_admins("[key_name_admin(chosen_candidate)] has taken control of ([key_name_admin(soon_to_be_ghoul)]) to replace an AFK player.")
		soon_to_be_ghoul.ghostize(FALSE)
		soon_to_be_ghoul.key = chosen_candidate.key

	ADD_TRAIT(soon_to_be_ghoul, TRAIT_MUTE, MAGIC_TRAIT)
	log_game("[key_name(user)] created a voiceless dead, controlled by [key_name(soon_to_be_ghoul)].")
	message_admins("[ADMIN_LOOKUPFLW(user)] created a voiceless dead, [ADMIN_LOOKUPFLW(soon_to_be_ghoul)].")
	soon_to_be_ghoul.revive(full_heal = TRUE, admin_revive = TRUE)
	soon_to_be_ghoul.setMaxHealth(MUTE_MAX_HEALTH)
	soon_to_be_ghoul.health = MUTE_MAX_HEALTH // Voiceless dead are much tougher than ghouls
	soon_to_be_ghoul.become_husk()
	soon_to_be_ghoul.faction |= FACTION_HERETIC
	soon_to_be_ghoul.apply_status_effect(/datum/status_effect/ghoul)

	var/datum/antagonist/heretic_monster/heretic_monster = soon_to_be_ghoul.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	heretic_monster.set_owner(user.mind)

	selected_atoms -= soon_to_be_ghoul
	LAZYADD(created_items, WEAKREF(soon_to_be_ghoul))

	RegisterSignal(soon_to_be_ghoul, COMSIG_LIVING_DEATH, .proc/remove_ghoul)
	return TRUE

/datum/heretic_knowledge/limited_amount/flesh_ghoul/proc/remove_ghoul(mob/living/carbon/human/source)
	SIGNAL_HANDLER

	LAZYREMOVE(created_items, WEAKREF(source))
	source.setMaxHealth(initial(source.maxHealth))
	source.remove_status_effect(/datum/status_effect/ghoul)
	source.mind.remove_antag_datum(/datum/antagonist/heretic_monster)

	UnregisterSignal(source, COMSIG_LIVING_DEATH)

/datum/heretic_knowledge/flesh_mark
	name = "Mark of Flesh"
	desc = "Your Mansus Grasp now applies the Mark of Flesh. The mark is triggered from an attack with your Bloody Blade. \
		When triggered, the victim begins to bleed significantly."
	gain_text = "That's when I saw them, the marked ones. They were out of reach. They screamed, and screamed."
	next_knowledge = list(
		/datum/heretic_knowledge/summon/raw_prophet,
		/datum/heretic_knowledge/reroll_targets,
	)
	banned_knowledge = list(
		/datum/heretic_knowledge/rust_mark,
		/datum/heretic_knowledge/ash_mark,
		/datum/heretic_knowledge/void_mark,
	)
	cost = 2
	route = PATH_FLESH

/datum/heretic_knowledge/flesh_mark/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, .proc/on_eldritch_blade)

/datum/heretic_knowledge/flesh_mark/on_lose(mob/user)
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_BLADE_ATTACK))

/datum/heretic_knowledge/flesh_mark/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	target.apply_status_effect(/datum/status_effect/eldritch/flesh)

/datum/heretic_knowledge/flesh_mark/proc/on_eldritch_blade(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	var/datum/status_effect/eldritch/mark = target.has_status_effect(/datum/status_effect/eldritch)
	if(!istype(mark))
		return

	mark.on_effect()

/datum/heretic_knowledge/summon/raw_prophet
	name = "Raw Ritual"
	desc = "Allows you to transmute a pair of eyes, a left arm, and a pool of blood to create a Raw Prophet. \
		Raw Prophets have a greatly increased sight range and x-ray vision, as well as a long range jaunt and \
		the ability to link minds to communicate with ease, but are very fragile and weak in combat."
	gain_text = "I could not continue alone. I was able to summon The Uncanny Man to help me see more. \
		The screams... once constant, now silenced by the Uncanny Man's appearance. Nothing was out of reach."
	next_knowledge = list(
		/datum/heretic_knowledge/rune_carver,
		/datum/heretic_knowledge/flesh_blade_upgrade,
		/datum/heretic_knowledge/curse/paralysis,
	)
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/effect/decal/cleanable/blood = 1,
		/obj/item/bodypart/l_arm = 1,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/raw_prophet
	cost = 1
	route = PATH_FLESH

/datum/heretic_knowledge/flesh_blade_upgrade
	name = "Bleeding Steel"
	desc = "Your Bloody Blade now causes enemies to bleed heavily on attack."
	gain_text = "The Uncanny Man was not alone. They led me to the Marshal. \
		I finally began to understand. And then, blood rained from the heavens."
	next_knowledge = list(/datum/heretic_knowledge/summon/stalker)
	banned_knowledge = list(
		/datum/heretic_knowledge/ash_blade_upgrade,
		/datum/heretic_knowledge/rust_blade_upgrade,
		/datum/heretic_knowledge/void_blade_upgrade,
	)
	cost = 2
	route = PATH_FLESH

/datum/heretic_knowledge/flesh_blade_upgrade/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, .proc/on_eldritch_blade)

/datum/heretic_knowledge/flesh_blade_upgrade/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK)

/datum/heretic_knowledge/flesh_blade_upgrade/proc/on_eldritch_blade(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	var/obj/item/bodypart/bodypart = pick(carbon_target.bodyparts)
	var/datum/wound/slash/severe/crit_wound = new()
	crit_wound.apply_wound(bodypart, attack_direction = get_dir(user, target))

/datum/heretic_knowledge/summon/stalker
	name = "Lonely Ritual"
	desc = "Allows you to transmute a pair of eyes, a candle, a pen and a piece of paper to create a Stalker. \
		Stalkers can jaunt, release EMPs, shapeshift into animals or automatons, and are strong in combat."
	gain_text = "I was able to combine my greed and desires to summon an eldritch beast I had never seen before. \
		An ever shapeshifting mass of flesh, it knew well my goals. The Marshal approved."
	next_knowledge = list(
		/datum/heretic_knowledge/summon/ashy,
		/datum/heretic_knowledge/final/flesh_final,
		/datum/heretic_knowledge/spell/blood_siphon,
	)
	required_atoms = list(
		/obj/item/pen = 1,
		/obj/item/organ/eyes = 1,
		/obj/item/candle = 1,
		/obj/item/paper = 1,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/stalker
	cost = 1
	route = PATH_FLESH

/datum/heretic_knowledge/final/flesh_final
	name = "Priest's Final Hymn"
	desc = "The ascension ritual of the Path of Flesh. \
		Bring 3 corpses to a transumation rune to complete the ritual. \
		When completed, you gain the ability to shed your human form \
		and become the Lord of the Night, a supremely powerful creature. \
		Just the act of transforming causes nearby heathens great fear and trauma. \
		While in the Lord of the Night form, you can consume arms to heal and regain segments. \
		Additionally, you can summon three times as many Ghouls and Voiceless Dead, \
		and can create unlimited blades to arm them all."
	gain_text = "With the Marshal's knowledge, my power had peaked. The throne was open to claim. \
		Men of this world, hear me, for the time has come! The Marshal guides my army! \
		Reality will bend to THE LORD OF THE NIGHT or be unraveled! WITNESS MY ASCENSION!"
	route = PATH_FLESH

/datum/heretic_knowledge/final/flesh_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_heretic_text()] Ever coiling vortex. Reality unfolded. ARMS OUTREACHED, THE LORD OF THE NIGHT, [user.real_name] has ascended! Fear the ever twisting hand! [generate_heretic_text()]", "[generate_heretic_text()]", ANNOUNCER_SPANOMALIES)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shed_human_form)
	user.client?.give_award(/datum/award/achievement/misc/flesh_ascension, user)

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	var/datum/heretic_knowledge/limited_amount/flesh_grasp/grasp_ghoul = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/flesh_grasp)
	grasp_ghoul.limit *= 3
	var/datum/heretic_knowledge/limited_amount/flesh_ghoul/ritual_ghoul = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/flesh_ghoul)
	ritual_ghoul.limit *= 3
	var/datum/heretic_knowledge/limited_amount/base_flesh/blade_ritual = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/base_flesh)
	blade_ritual.limit = 999

#undef GHOUL_MAX_HEALTH
#undef MUTE_MAX_HEALTH
