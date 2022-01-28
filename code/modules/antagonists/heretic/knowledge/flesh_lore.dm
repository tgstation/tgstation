#define GHOUL_MAX_HEALTH 25
#define MUTE_MAX_HEALTH 50

/datum/heretic_knowledge/base_flesh
	name = "Principle of Hunger"
	desc = "Opens up the Path of Flesh to you. \
		Allows you to transmute a pool of blood with a kitchen knife, or its derivatives, into a Flesh Blade."
	gain_text = "Hundreds of us starved, but not me... I found strength in my greed."
	banned_knowledge = list(
		/datum/heretic_knowledge/base_ash,
		/datum/heretic_knowledge/base_rust,
		/datum/heretic_knowledge/final/ash_final,
		/datum/heretic_knowledge/final/rust_final,
		/datum/heretic_knowledge/final/void_final,
		/datum/heretic_knowledge/base_void,
	)
	next_knowledge = list(/datum/heretic_knowledge/flesh_grasp)
	required_atoms = list(/obj/item/knife = 1, /obj/effect/decal/cleanable/blood = 1)
	result_atoms = list(/obj/item/melee/sickly_blade/flesh)
	cost = 1
	route = PATH_FLESH

/datum/heretic_knowledge/flesh_ghoul
	name = "Imperfect Ritual"
	desc = "Allows you to resurrect the dead as voiceless dead by \
		sacrificing them on the transmutation rune with a poppy. \
		Voiceless dead are mute and have 50 HP. You can only have 2 at a time."
	gain_text = "I found notes of a dark ritual, unfinished... yet still, I pushed forward."
	cost = 1
	required_atoms = list(/mob/living/carbon/human = 1, /obj/item/food/grown/poppy = 1)
	next_knowledge = list(
		/datum/heretic_knowledge/flesh_mark,
		/datum/heretic_knowledge/void_cloak,
		/datum/heretic_knowledge/ashen_eyes
	)
	route = PATH_FLESH
	var/max_amt = 2
	var/current_amt = 0
	var/list/ghouls = list()

/datum/heretic_knowledge/flesh_ghoul/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			atoms -= body

	return TRUE

/datum/heretic_knowledge/flesh_ghoul/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(length(ghouls) >= max_amt)
		return FALSE
	if(HAS_TRAIT(soon_to_be_ghoul, TRAIT_HUSK))
		return FALSE
	soon_to_be_ghoul.grab_ghost()

	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		message_admins("[ADMIN_LOOKUPFLW(user)] is creating a voiceless dead of a body with no player.")
		var/list/mob/dead/observer/candidates = poll_candidates_for_mob("Do you want to play as a [soon_to_be_ghoul.real_name], a voiceless dead?", ROLE_HERETIC, ROLE_HERETIC, 5 SECONDS, soon_to_be_ghoul)
		if(!LAZYLEN(candidates))
			to_chat(user, span_warning("Your ritual failed! The spirits lie dormant, and the body remains lifeless. Perhaps try later?"))
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
	ghouls += soon_to_be_ghoul

	RegisterSignal(soon_to_be_ghoul, COMSIG_LIVING_DEATH, .proc/remove_ghoul)
	return TRUE

/datum/heretic_knowledge/flesh_ghoul/proc/remove_ghoul(mob/living/carbon/human/source)
	SIGNAL_HANDLER

	ghouls -= source
	source.setMaxHealth(initial(source.maxHealth))
	source.remove_status_effect(/datum/status_effect/ghoul)
	source.mind.remove_antag_datum(/datum/antagonist/heretic_monster)
	UnregisterSignal(source, COMSIG_LIVING_DEATH)

/datum/heretic_knowledge/flesh_grasp
	name = "Grasp of Flesh"
	desc = "Empowers your mansus grasp to be able to create a single ghoul out of a dead person. \
		Ghouls have only 25 HP and look like husks to the heathens' eyes."
	gain_text = "My new found desires drove me to greater and greater heights."
	cost = 1
	next_knowledge = list(/datum/heretic_knowledge/flesh_ghoul)
	route = PATH_FLESH
	var/ghoul_amt = 1
	var/list/spooky_scaries

/datum/heretic_knowledge/flesh_grasp/on_gain(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, .proc/on_eldritch_blade)

/datum/heretic_knowledge/flesh_grasp/on_lose(mob/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_BLADE_ATTACK))

/datum/heretic_knowledge/flesh_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!ishuman(target))
		return

	var/mob/living/carbon/human/human_target = target
	if(QDELETED(human_target) || human_target.stat != DEAD)
		return

	human_target.grab_ghost()
	if(!human_target.mind || !human_target.client)
		to_chat(source, span_warning("There is no soul within this body."))
		return
	if(HAS_TRAIT(human_target, TRAIT_HUSK))
		to_chat(source, span_warning("You cannot revive a husk!"))
		return
	if(LAZYLEN(spooky_scaries) >= ghoul_amt)
		to_chat(source, span_warning("Your patron cannot support more ghouls on this plane!"))
		return

	LAZYADD(spooky_scaries, human_target)
	log_game("[key_name(source)] created a ghoul, controlled by [key_name(human_target)].")
	message_admins("[ADMIN_LOOKUPFLW(source)] created a ghuol, [ADMIN_LOOKUPFLW(human_target)].")

	RegisterSignal(human_target, COMSIG_LIVING_DEATH, .proc/remove_ghoul)
	human_target.revive(full_heal = TRUE, admin_revive = TRUE)
	human_target.setMaxHealth(GHOUL_MAX_HEALTH)
	human_target.health = GHOUL_MAX_HEALTH
	human_target.become_husk()
	human_target.apply_status_effect(/datum/status_effect/ghoul)
	human_target.faction |= FACTION_HERETIC

	var/datum/antagonist/heretic_monster/heretic_monster = human_target.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	heretic_monster.set_owner(source.mind)

/datum/heretic_knowledge/flesh_grasp/proc/on_eldritch_blade(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	var/datum/status_effect/eldritch/mark = target.has_status_effect(/datum/status_effect/eldritch)
	if(istype(mark))
		mark.on_effect()

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	var/obj/item/bodypart/bodypart = pick(carbon_target.bodyparts)
	var/datum/wound/slash/severe/crit_wound = new()
	crit_wound.apply_wound(bodypart)

/datum/heretic_knowledge/flesh_grasp/proc/remove_ghoul(datum/source)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/humie = source
	spooky_scaries -= humie
	humie.setMaxHealth(initial(humie.maxHealth))
	humie.remove_status_effect(/datum/status_effect/ghoul)
	humie.mind.remove_antag_datum(/datum/antagonist/heretic_monster)
	UnregisterSignal(source, COMSIG_LIVING_DEATH)

/datum/heretic_knowledge/flesh_mark
	name = "Mark of Flesh"
	desc = "Your Mansus Grasp now applies the Mark of Flesh on hit. \
		Attack the afflicted with your Sickly Blade to detonate the mark. \
		Upon detonation, the Mark of Flesh causes additional bleeding."
	gain_text = "I saw them, the marked ones. The screams... then... silence."
	cost = 2
	next_knowledge = list(/datum/heretic_knowledge/summon/raw_prophet)
	banned_knowledge = list(/datum/heretic_knowledge/rust_mark, /datum/heretic_knowledge/ash_mark, /datum/heretic_knowledge/void_mark)
	route = PATH_FLESH

/datum/heretic_knowledge/flesh_mark/on_gain(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)

/datum/heretic_knowledge/flesh_mark/on_lose(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/flesh_mark/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	target.apply_status_effect(/datum/status_effect/eldritch/flesh)

/datum/heretic_knowledge/flesh_blade_upgrade
	name = "Bleeding Steel"
	desc = "Your Sickly Blade will now cause additional bleeding."
	gain_text = "And then, blood rained from the heavens. That's when I finally understood the Marshal's teachings."
	cost = 2
	next_knowledge = list(/datum/heretic_knowledge/summon/stalker)
	banned_knowledge = list(/datum/heretic_knowledge/ash_blade_upgrade,/datum/heretic_knowledge/rust_blade_upgrade,/datum/heretic_knowledge/void_blade_upgrade)
	route = PATH_FLESH

/datum/heretic_knowledge/flesh_blade_upgrade/on_gain(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, .proc/on_eldritch_blade)

/datum/heretic_knowledge/flesh_blade_upgrade/on_lose(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK)

/datum/heretic_knowledge/flesh_blade_upgrade/proc/on_eldritch_blade(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	var/obj/item/bodypart/bodypart = pick(carbon_target.bodyparts)
	var/datum/wound/slash/severe/crit_wound = new()
	crit_wound.apply_wound(bodypart)

/datum/heretic_knowledge/summon/raw_prophet
	name = "Raw Ritual"
	gain_text = "The Uncanny Man, who walks alone in the valley between the worlds... I was able to summon his aid."
	desc = "You can now summon a Raw Prophet by transmutating a pair of eyes, a left arm and a pool of blood. \
		Raw prophets have increased seeing range, as well as x-ray vision, but they are very fragile."
	cost = 1
	required_atoms = list(/obj/item/organ/eyes = 1, /obj/effect/decal/cleanable/blood = 1, /obj/item/bodypart/l_arm = 1)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/raw_prophet
	next_knowledge = list(
		/datum/heretic_knowledge/flesh_blade_upgrade,
		/datum/heretic_knowledge/rune_carver,
		/datum/heretic_knowledge/curse/paralysis
	)
	route = PATH_FLESH

/datum/heretic_knowledge/summon/stalker
	name = "Lonely Ritual"
	desc = "You can now summon a Stalker by transmutating a pair of eyes, a candle, a pen and a piece of paper. \
		Stalkers can shapeshift into harmless animals to get close to the victim."
	gain_text = "I was able to combine my greed and desires to summon an eldritch beast I had never seen before. \
		An ever shapeshifting mass of flesh, it knew well my goals."
	cost = 1
	required_atoms = list(/obj/item/pen = 1, /obj/item/organ/eyes = 1 ,/obj/item/candle = 1, /obj/item/paper = 1)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/stalker
	next_knowledge = list(
		/datum/heretic_knowledge/summon/ashy,
		/datum/heretic_knowledge/spell/blood_siphon,
		/datum/heretic_knowledge/final/flesh_final,
	)
	route = PATH_FLESH

/datum/heretic_knowledge/summon/ashy
	name = "Ashen Ritual"
	desc = "You can now summon an Ash Man by transmutating a pile of ash, a head and a book."
	gain_text = "I combined my principle of hunger with my desire for destruction. And the Nightwatcher knew my name."
	cost = 1
	required_atoms = list(/obj/effect/decal/cleanable/ash = 1, /obj/item/bodypart/head = 1, /obj/item/book = 1)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/ash_spirit
	next_knowledge = list(/datum/heretic_knowledge/summon/stalker, /datum/heretic_knowledge/spell/flame_birth)

/datum/heretic_knowledge/summon/rusty
	name = "Rusted Ritual"
	desc = "You can now summon a Rust Walker by transmutating a vomit pool, a severed head and a book."
	gain_text = "I combined my principle of hunger with my desire for corruption. And the Rusted Hills called my name."
	cost = 1
	required_atoms = list(/obj/effect/decal/cleanable/vomit = 1, /obj/item/book = 1, /obj/item/bodypart/head = 1)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/rust_spirit
	next_knowledge = list(/datum/heretic_knowledge/spell/voidpull, /datum/heretic_knowledge/spell/entropic_plume)

/datum/heretic_knowledge/spell/blood_siphon
	name = "Blood Siphon"
	desc = "You gain a spell that drains health from your enemies to restores your own."
	gain_text = "No matter the man, we bleed all the same. That's what the Marshal told me."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/pointed/blood_siphon
	next_knowledge = list(/datum/heretic_knowledge/summon/stalker,/datum/heretic_knowledge/spell/voidpull)

/datum/heretic_knowledge/final/flesh_final
	name = "Priest's Final Hymn"
	desc = "Bring 3 bodies onto a transmutation rune to shed your human form and ascend to untold power."
	gain_text = "Men of this world. Hear me, for the time of the Lord of Arms has come! The Emperor of Flesh guides my army!"
	route = PATH_FLESH

/datum/heretic_knowledge/final/flesh_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_heretic_text()] Ever coiling vortex. Reality unfolded. THE LORD OF ARMS, [user.real_name] has ascended! Fear the ever twisting hand! [generate_heretic_text()]","[generate_heretic_text()]", ANNOUNCER_SPANOMALIES)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shed_human_form)
	user.client?.give_award(/datum/award/achievement/misc/flesh_ascension, user)

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/flesh_grasp/grasp_ghoul = heretic_datum.get_knowledge(/datum/heretic_knowledge/flesh_grasp)
	grasp_ghoul.ghoul_amt *= 3
	var/datum/heretic_knowledge/flesh_ghoul/ritual_ghoul = heretic_datum.get_knowledge(/datum/heretic_knowledge/flesh_ghoul)
	ritual_ghoul.max_amt *= 3

#undef GHOUL_MAX_HEALTH
#undef MUTE_MAX_HEALTH
