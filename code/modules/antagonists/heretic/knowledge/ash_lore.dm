/**
 * # The path of Ash.
 *
 * Goes as follows:
 *
 * Nightwatcher's Secret
 * Ashen Shift
 * Grasp of Ash
 * > Sidepaths:
 *   Priest's Ritual
 *   Ashen Eyes
 *
 * Mark of Ash
 * Mask of Madness
 * > Sidepaths:
 *   Curse of Corrosion
 *   Curse of Paralysis
 *
 * Fiery Blade
 * Flame Birth
 * > Sidepaths:
 *   Ashen Ritual
 *   Blood Cleave
 *
 * Ashlord's Rite
 */
/datum/heretic_knowledge/base_ash
	name = "Nightwatcher's Secret"
	desc = "Opens up the Path of Ash to you. \
		Allows you to transmute a match with a kitchen knife, or its derivatives, into an Ashen Blade."
	gain_text = "The City Guard know their watch. If you ask them at night, they may tell you about the ashy lantern."
	next_knowledge = list(/datum/heretic_knowledge/ashen_grasp)
	banned_knowledge = list(
		/datum/heretic_knowledge/base_rust,
		/datum/heretic_knowledge/base_flesh,
		/datum/heretic_knowledge/final/rust_final,
		/datum/heretic_knowledge/final/flesh_final,
		/datum/heretic_knowledge/final/void_final,
		/datum/heretic_knowledge/base_void,
	)
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/match = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/ash)
	cost = 1
	route = PATH_ASH

/datum/heretic_knowledge/ashen_grasp
	name = "Grasp of Ash"
	desc = "Empowers your Mansus Grasp to blind opponents you touch with it."
	gain_text = "The Nightwatcher was the first of them, his treason started it all."
	next_knowledge = list(/datum/heretic_knowledge/spell/ashen_shift)
	cost = 1
	route = PATH_ASH

/datum/heretic_knowledge/ashen_grasp/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, .proc/on_eldritch_blade)

/datum/heretic_knowledge/ashen_grasp/on_lose(mob/user)
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_BLADE_ATTACK))

/datum/heretic_knowledge/ashen_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!iscarbon(target))
		return

	//pocket sand! also, this is the message that changeling blind stings use, and no, I'm not ashamed about reusing it
	var/mob/living/carbon/blind_victim = target
	to_chat(blind_victim, span_danger("Your eyes burn horrifically!"))
	blind_victim.become_nearsighted(EYE_DAMAGE)
	blind_victim.blind_eyes(5)
	blind_victim.blur_eyes(10)

/datum/heretic_knowledge/ashen_grasp/proc/on_eldritch_blade(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	var/datum/status_effect/eldritch/mark = target.has_status_effect(/datum/status_effect/eldritch)
	if(istype(mark))
		mark.on_effect()

	for(var/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp/grasp in user.mind.spell_list)
		grasp.charge_counter = min(round(grasp.charge_counter + grasp.charge_max * 0.75), grasp.charge_max) // refunds 75% of charge.

/datum/heretic_knowledge/spell/ashen_shift
	name = "Ashen Shift"
	desc = "Grants Ashen Shift, a short range jaunt that can help you escape from dire situations."
	gain_text = "He knew how to walk between the planes."
	next_knowledge = list(
		/datum/heretic_knowledge/essence,
		/datum/heretic_knowledge/ash_mark,
		/datum/heretic_knowledge/ashen_eyes,
	)
	spell_to_add = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash
	cost = 1
	route = PATH_ASH

/datum/heretic_knowledge/ash_mark
	name = "Mark of Ash"
	desc = "Your Mansus Grasp now applies the Mark of Ash on hit. \
		Attack the afflicted with your Sickly Blade to detonate the mark. \
		Upon detonation, the Mark of Ash causes stamina damage and burn damage, \
		and spreads to an additional nearby opponent. The damage decreases with each spread."
	gain_text = "The Nightwatcher was a very particular man, always watching in the dead of night. \
		But in spite of his duty, he regularly tranced through the manse with his blazing lantern held high."
	next_knowledge = list(
		/datum/heretic_knowledge/mad_mask,
		/datum/heretic_knowledge/reroll_targets,
	)
	banned_knowledge = list(
		/datum/heretic_knowledge/rust_mark,
		/datum/heretic_knowledge/flesh_mark,
		/datum/heretic_knowledge/void_mark,
	)
	cost = 2
	route = PATH_ASH

/datum/heretic_knowledge/ash_mark/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)

/datum/heretic_knowledge/ash_mark/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/ash_mark/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	target.apply_status_effect(/datum/status_effect/eldritch/ash, 5)

/datum/heretic_knowledge/mad_mask
	name = "Mask of Madness"
	desc = "Allows you to transmute any mask, with a candle and a pair of eyes, to create a mask of madness. \
		It causes passive stamina damage to everyone around the wearer and hallucinations. \
		It can also be forced onto a heathan, to make them unable to take it off..."
	gain_text = "He walks the world, unnoticed by the masses."
	next_knowledge = list(
		/datum/heretic_knowledge/curse/corrosion,
		/datum/heretic_knowledge/ash_blade_upgrade,
		/datum/heretic_knowledge/curse/paralysis,
	)
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/candle = 1,
	)
	result_atoms = list(/obj/item/clothing/mask/madness_mask)
	cost = 1
	route = PATH_ASH

/datum/heretic_knowledge/ash_blade_upgrade
	name = "Fiery Blade"
	desc = "Your blade will now light your enemies ablaze."
	gain_text = "Blade in hand, he swung and swung as the ash fell from the skies. \
		His city, his people... all burnt to cinders, and yet life still remained in his charred body."
	next_knowledge = list(/datum/heretic_knowledge/spell/flame_birth)
	banned_knowledge = list(
		/datum/heretic_knowledge/rust_blade_upgrade,
		/datum/heretic_knowledge/flesh_blade_upgrade,
		/datum/heretic_knowledge/void_blade_upgrade,
	)
	cost = 2
	route = PATH_ASH

/datum/heretic_knowledge/ashen_grasp/on_gain(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, .proc/on_eldritch_blade)

/datum/heretic_knowledge/ashen_grasp/on_lose(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK)

/datum/heretic_knowledge/ash_blade_upgrade/proc/on_eldritch_blade(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	target.adjust_fire_stacks(1)
	target.IgniteMob()

/datum/heretic_knowledge/curse/corrosion/curse(mob/living/chosen_mob)
	chosen_mob.apply_status_effect(/datum/status_effect/corrosion_curse)

/datum/heretic_knowledge/curse/corrosion/uncurse(mob/living/chosen_mob)
	chosen_mob.remove_status_effect(/datum/status_effect/corrosion_curse)

/datum/heretic_knowledge/curse/paralysis/curse(mob/living/chosen_mob)
	ADD_TRAIT(chosen_mob, TRAIT_PARALYSIS_L_LEG, type)
	ADD_TRAIT(chosen_mob, TRAIT_PARALYSIS_R_LEG, type)

/datum/heretic_knowledge/curse/paralysis/uncurse(mob/living/chosen_mob)
	REMOVE_TRAIT(chosen_mob, TRAIT_PARALYSIS_L_LEG, type)
	REMOVE_TRAIT(chosen_mob, TRAIT_PARALYSIS_R_LEG, type)

/datum/heretic_knowledge/spell/flame_birth
	name = "Flame Birth"
	desc = "A spell that steals some health from every burning person around you."
	gain_text = "The Nightwatcher was a man of principles, and yet his power arose from the chaos he vowed to combat."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/cleave,
		/datum/heretic_knowledge/summon/ashy,
		/datum/heretic_knowledge/final/ash_final,
	)
	spell_to_add = /obj/effect/proc_holder/spell/targeted/fiery_rebirth
	cost = 1
	route = PATH_ASH

/datum/heretic_knowledge/final/ash_final
	name = "Ashlord's Rite"
	desc = "Bring 3 corpses onto a transmutation rune. \
		You will become immune to fire, the vacuum of space, cold and other enviromental hazards \
		while overall becoming sturdier to all other damages. \
		You will gain a spell that passively creates ring of fire around you, \
		as well as a powerful ability that lets you create a wave of flames all around you."
	gain_text = "The Nightwatcher found the rite and shared it amongst mankind! For now I am one with the fire, WITNESS MY ASCENSION!"
	route = PATH_ASH
	/// A list of all traits we apply on ascension.
	var/static/list/traits_to_apply = list(
		TRAIT_RESISTHEAT,
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOFIRE,
	)

/datum/heretic_knowledge/final/ash_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_heretic_text()] Fear the blaze, for the Ashlord, [user.real_name] has ascended! The flames shall consume all! [generate_heretic_text()]","[generate_heretic_text()]", ANNOUNCER_SPANOMALIES)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/fire_cascade/big)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/fire_sworn)
	user.client?.give_award(/datum/award/achievement/misc/ash_ascension, user)
	for(var/trait in traits_to_apply)
		ADD_TRAIT(user, trait, MAGIC_TRAIT)
