/**
 * # The path of Moon.
 *
 * Goes as follows:
 *
 * Moonlight Troupe
 * Grasp of Lunacy
 * Smile of the moon
 * > Sidepaths:
 *   Mind Gate
 *   Ashen Eyes
 *
 * Mark of Moon
 * Ritual of Knowledge
 * Lunar Parade
 * Moonlight Amulette
 * > Sidepaths:
 *   Curse of Paralasys
 *   Unfathomable Curio
 * 	 Unsealed Arts
 *
 * Moonlight blade
 * Ringleaders Rise
 * > Sidepaths:
 *   Ashen Ritual
 *
 * Last Act
 */
/datum/heretic_knowledge/limited_amount/starting/base_moon
	name = "Moonlight Troupe"
	desc = "Opens up the Path of Moon to you. \
		Allows you to transmute 2 sheets of iron and a knife into an Lunar Blade. \
		You can only create two at a time."
	gain_text = "Under the light of the moon the laughter echoes."
	next_knowledge = list(/datum/heretic_knowledge/moon_grasp)
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/stack/sheet/iron = 2,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/moon)
	route = PATH_MOON

/datum/heretic_knowledge/base_moon/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	add_traits(user ,TRAIT_EMPATH, REF(src))

/datum/heretic_knowledge/moon_grasp
	name = "Grasp of Lunacy"
	desc = "Your Mansus Grasp will cause them to hallucinate everyone as lunar mass, \
		and hides your identity for a short dur	ation."
	gain_text = "The troupe on the side of the moon showed me truth, and I took it."
	next_knowledge = list(/datum/heretic_knowledge/spell/moon_smile)
	cost = 1
	route = PATH_MOON

/datum/heretic_knowledge/moon_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/moon_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/moon_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER
	source.apply_status_effect(/datum/status_effect/moon_grasp_hide)

	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon_target = target
	to_chat(carbon_target, span_danger("You hear echoing laughter from above"))
	carbon_target.cause_hallucination(/datum/hallucination/delusion/preset/moon, "delusion/preset/moon hallucination caused by mansus grasp")
	carbon_target.mob_mood.set_sanity(carbon_target.mob_mood.sanity-20)

/datum/heretic_knowledge/spell/moon_smile
	name = "Smile of the moon"
	desc = "Grants you Smile of the moon, a ranged spell muting, blinding and deafening the target for a short duartion."
	gain_text = "The moon smiles upon us all and those who see its true side can bring its joy."
	adds_sidepath_points = 1
	next_knowledge = list(
		/datum/heretic_knowledge/mark/moon_mark,
		/datum/heretic_knowledge/codex_cicatrix,
		/datum/heretic_knowledge/medallion,
		/datum/heretic_knowledge/spell/mind_gate,
	)
	spell_to_add = /datum/action/cooldown/spell/pointed/moon_smile
	cost = 1
	route = PATH_MOON

/datum/heretic_knowledge/mark/moon_mark
	name = "Mark of Moon"
	desc = "Your Mansus Grasp now applies the Mark of Moon. The mark is triggered from an attack with your Moon Blade. \
		When triggered, the victim is confused, and when the mark is applied they are pacified \
		until attacked."
	gain_text = "The troupe on the moon would dance all day long \
		and in that dance the moon would smile upon us \
		but when the night came its smile would dull forced to gaze on the earth."
	next_knowledge = list(/datum/heretic_knowledge/knowledge_ritual/moon)
	route = PATH_MOON
	mark_type = /datum/status_effect/eldritch/moon

/datum/heretic_knowledge/mark/moon_mark/trigger_mark(mob/living/source, mob/living/target)
	. = ..()
	if(!.)
		return

	// Also refunds 75% of charge!
	var/datum/action/cooldown/spell/touch/mansus_grasp/grasp = locate() in source.actions
	if(grasp)
		grasp.next_use_time = min(round(grasp.next_use_time - grasp.cooldown_time * 0.75, 0), 0)
		grasp.build_all_button_icons()

/datum/heretic_knowledge/knowledge_ritual/moon
	next_knowledge = list(/datum/heretic_knowledge/spell/moon_parade)
	route = PATH_MOON

/datum/heretic_knowledge/spell/moon_parade
	name = "Lunar Parade"
	desc = "Grants you Lunar Parade, a spell that - after a short charge - sends a carnival forward \
		when hitting someone they are forced to join the parade and suffer hallucinations."
	gain_text = "The music like a reflection of the soul compelled them, like moths to a flame they followed"
	adds_sidepath_points = 1
	next_knowledge = list(
		/datum/heretic_knowledge/moon_amulette,
		/datum/heretic_knowledge/reroll_targets,
		/datum/heretic_knowledge/unfathomable_curio,
		/datum/heretic_knowledge/curse/paralysis,
		/datum/heretic_knowledge/painting,
		)
	spell_to_add = /datum/action/cooldown/spell/pointed/projectile/moon_parade
	cost = 1
	route = PATH_MOON


/datum/heretic_knowledge/moon_amulette
	name = "Moonlight Amulette"
	desc = "Allows you to transmute 2 sheets of glass, a pair of eyes, a brain and a tie \
			if the item is used on someone with low sanity they go berserk attacking everyone \
			, if their sanity isnt low enough it decreases their mood. \
			Optionally you can add a poppy in the ritual to further decrease their mood."
	gain_text = "At the head of the parade he stood, the moon condensed into one mass, a reflection of the soul."
	next_knowledge = list(/datum/heretic_knowledge/blade_upgrade/moon)
	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/item/organ/internal/brain = 1,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/clothing/neck/tie = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus/moon_amulette)
	optional_atoms = list(
		/obj/item/food/grown/poppy = 1,
	)
	optional_result_atoms = list(/obj/item/clothing/neck/heretic_focus/moon_amulette/upgraded)
	cost = 1
	route = PATH_MOON

/datum/heretic_knowledge/blade_upgrade/moon
	name = "Moonlight Blade"
	desc = "Your blade now deals brain damage, causes  random hallucinations and does sanity damage."
	gain_text = "His wit was sharp as a blade, cutting through the lie to bring us joy."
	next_knowledge = list(/datum/heretic_knowledge/spell/moon_ringleader)
	cost = 1
	route = PATH_MOON

/datum/heretic_knowledge/blade_upgrade/moon/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target)
		return

	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 100)
	target.cause_hallucination( \
			get_random_valid_hallucination_subtype(/datum/hallucination/body), \
			"upgraded path of moon blades", \
		)
	target.emote(pick("giggle", "laugh"))
	target.mob_mood.set_sanity(target.mob_mood.sanity - 10)

/datum/heretic_knowledge/spell/moon_ringleader
	name = "Ringleaders Rise"
	desc = "Grants you Ringleaders Rise, an aoe spell that deals more brain damage the lower the sanity of everyone in the AoE,\
			causes hallucinations with those who have less sanity getting more. \
			If their sanity is low enough turns them insane, the spell then halves their sanity."
	gain_text = "I grabbed his hand and we rose, those who saw the truth rose with us. \
		The ringleader pointed up and the dim light of truth illuminated us further."
	next_knowledge = list(
		/datum/heretic_knowledge/ultimate/moon_final,
		/datum/heretic_knowledge/summon/ashy,
	)
	spell_to_add = /datum/action/cooldown/spell/aoe/moon_ringleader
	cost = 1
	route = PATH_MOON

/datum/heretic_knowledge/ultimate/moon_final
	name = "The Last Act"
	desc = "The ascension ritual of the Path of Moon. \
		Bring 3 corpses with more than 50 brain damage to a transmutation rune to complete the ritual. \
		When completed, you become a harbinger of madness, all your spells will get a lower cooldown \
		and become stronger. You will also passivly release hallucinations, decrease sanity, and increase \
		confusion. If their sanity is low they will start taking brain damage and go blind."
	gain_text = "We dived down towards the crowd, his soul splitting off in search of greater venture \
		for where the Ringleader had started the parade, I shall continue it unto the suns demise \
		WITNESS MY ASCENSION, THE MOON SMILES ONCE MORE AND FOREVER MORE IT SHALL!"
	adds_sidepath_points = 1
	route = PATH_MOON

/datum/heretic_knowledge/ultimate/moon_final/is_valid_sacrifice(mob/living/sacrifice)

	var/brain_damage = sacrifice.get_organ_loss(ORGAN_SLOT_BRAIN)
	// Checks if our target has enough brain damage
	if(brain_damage<50)
		return FALSE

	return ..()

/datum/heretic_knowledge/ultimate/moon_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_heretic_text()] Laugh, for the ringleader [user.real_name] has ascended! The truth shall finally devour the lie! [generate_heretic_text()]","[generate_heretic_text()]", ANNOUNCER_SPANOMALIES)

	user.client?.give_award(/datum/award/achievement/misc/moon_ascension, user)
	ADD_TRAIT(owner, TRAIT_MADNESS_IMMUNE, REF(src))

	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))

	var/datum/action/cooldown/spell/pointed/moon_smile/smile = locate() in user.actions
	if(smile)
		smile.cooldown_time *= 0.66 // Lower cooldown
		smile.cast_range +=6 // Longer cast range

	var/datum/action/cooldown/spell/pointed/projectile/moon_parade/lunar_parade = locate() in user.actions
	if(lunar_parade)
		lunar_parade.cooldown_time *= 0.66 // Lower cooldown

	var/datum/action/cooldown/spell/aoe/moon_ringleader/ringleader_rise = locate() in user.actions
	if(ringleader_rise)
		ringleader_rise.cooldown_time *= 0.66 // Lower cooldown
		ringleader_rise.aoe_radius +=3 // Bigger AoE

/datum/heretic_knowledge/ultimate/moon_final/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	visible_hallucination_pulse(
		center = get_turf(source),
		radius = 7,
		hallucination_duration = 60 SECONDS)

	for(var/mob/living/carbon/carbon_view in view(7, source))
		var/carbon_sanity=carbon_view.mob_mood.sanity
		if(IS_HERETIC_OR_MONSTER(carbon_view))
			continue
		carbon_view.adjust_confusion(2 SECONDS)
		carbon_view.mob_mood.set_sanity(carbon_sanity-5)
		if(carbon_sanity<30)
			to_chat(carbon_view, span_warning("you feel your mind begining to rend!"))
			carbon_view.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 160)
		if(carbon_sanity<10)
			to_chat(carbon_view, span_warning("it echoes through you!"))
			visible_hallucination_pulse(
			center = get_turf(carbon_view),
			radius = 7,
			hallucination_duration = 50 SECONDS)
			carbon_view.adjust_temp_blindness(5 SECONDS)






