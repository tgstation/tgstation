/**
 * # The path of Ash.
 *
 * Goes as follows:
 *
 * Nightwatcher's Secret
 * Grasp of Ash
 * Ashen Passage
 * > Sidepaths:
 *   Priest's Ritual
 *   Ashen Eyes
 *
 * Mark of Ash
 * Ritual of Knowledge
 * Mask of Madness
 * > Sidepaths:
 *   Curse of Corrosion
 *   Curse of Paralysis
 *
 * Fiery Blade
 * Nightwatcher's Rebirth
 * > Sidepaths:
 *   Ashen Ritual
 *   Rusted Ritual
 *
 * Ashlord's Rite
 */
/datum/heretic_knowledge/limited_amount/starting/base_ash
	name = "Nightwatcher's Secret"
	desc = "Opens up the Path of Ash to you. \
		Allows you to transmute a match and a knife into an Ashen Blade. \
		You can only create two at a time."
	gain_text = "The City Guard know their watch. If you ask them at night, they may tell you about the ashy lantern."
	next_knowledge = list(/datum/heretic_knowledge/ashen_grasp)
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/match = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/ash)
	route = PATH_ASH

/datum/heretic_knowledge/limited_amount/starting/base_ash/on_research(mob/user)
	. = ..()
	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	our_heretic.heretic_path = route

/datum/heretic_knowledge/ashen_grasp
	name = "Grasp of Ash"
	desc = "Your Mansus Grasp will burn the eyes of the victim, causing damage and blindness."
	gain_text = "The Nightwatcher was the first of them, his treason started it all. \
		Their lantern, expired to ash - their watch, absent."
	next_knowledge = list(/datum/heretic_knowledge/spell/ash_passage)
	cost = 1
	route = PATH_ASH

/datum/heretic_knowledge/ashen_grasp/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)

/datum/heretic_knowledge/ashen_grasp/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/ashen_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(target.is_blind())
		return

	if(!target.getorganslot(ORGAN_SLOT_EYES))
		return

	to_chat(target, span_danger("A bright green light burns your eyes horrifically!"))
	target.adjustOrganLoss(ORGAN_SLOT_EYES, 15)
	target.blur_eyes(10)

/datum/heretic_knowledge/spell/ash_passage
	name = "Ashen Passage"
	desc = "Grants you Ashen Passage, a silent but short range jaunt."
	gain_text = "He knew how to walk between the planes."
	next_knowledge = list(
		/datum/heretic_knowledge/mark/ash_mark,
		/datum/heretic_knowledge/codex_cicatrix,
		/datum/heretic_knowledge/essence,
		/datum/heretic_knowledge/medallion,
	)
	spell_to_add = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash
	cost = 1
	route = PATH_ASH

/datum/heretic_knowledge/mark/ash_mark
	name = "Mark of Ash"
	desc = "Your Mansus Grasp now applies the Mark of Ash. The mark is triggered from an attack with your Ashen Blade. \
		When triggered, the victim takes additional stamina and burn damage, and the mark is transferred to any nearby heathens. \
		Damage dealt is decreased with each transfer."
	gain_text = "He was a very particular man, always watching in the dead of night. \
		But in spite of his duty, he regularly tranced through the Manse with his blazing lantern held high. \
		He shone brightly in the darkness, until the blaze begin to die."
	next_knowledge = list(/datum/heretic_knowledge/knowledge_ritual/ash)
	route = PATH_ASH
	mark_type = /datum/status_effect/eldritch/ash

/datum/heretic_knowledge/mark/ash_mark/trigger_mark(mob/living/source, mob/living/target)
	. = ..()
	if(!.)
		return

	// Also refunds 75% of charge!
	for(var/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp/grasp in source.mind.spell_list)
		grasp.charge_counter = min(round(grasp.charge_counter + grasp.charge_max * 0.75), grasp.charge_max)

/datum/heretic_knowledge/knowledge_ritual/ash
	next_knowledge = list(/datum/heretic_knowledge/mad_mask)
	route = PATH_ASH

/datum/heretic_knowledge/mad_mask
	name = "Mask of Madness"
	desc = "Allows you to transmute any mask, four candles, a stun baton, and a liver to create a Mask of Madness. \
		The mask instills fear into heathens who witness it, causing stamina damage, hallucinations, and insanity. \
		It can also be forced onto a heathen, to make them unable to take it off..."
	gain_text = "The Nightwatcher was lost. That's what the Watch believed. Yet he walked the world, unnoticed by the masses."
	next_knowledge = list(
		/datum/heretic_knowledge/blade_upgrade/ash,
		/datum/heretic_knowledge/reroll_targets,
		/datum/heretic_knowledge/curse/corrosion,
		/datum/heretic_knowledge/curse/paralysis,
	)
	required_atoms = list(
		/obj/item/organ/internal/liver = 1,
		/obj/item/melee/baton/security = 1,  // Technically means a cattleprod is valid
		/obj/item/clothing/mask = 1,
		/obj/item/candle = 4,
	)
	result_atoms = list(/obj/item/clothing/mask/madness_mask)
	cost = 1
	route = PATH_ASH

/datum/heretic_knowledge/blade_upgrade/ash
	name = "Fiery Blade"
	desc = "Your blade now lights enemies ablaze on attack."
	gain_text = "He returned, blade in hand, he swung and swung as the ash fell from the skies. \
		His city, the people he swore to watch... and watch he did, as they all burnt to cinders."
	next_knowledge = list(/datum/heretic_knowledge/spell/flame_birth)
	route = PATH_ASH

/datum/heretic_knowledge/blade_upgrade/ash/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target)
		return

	target.adjust_fire_stacks(1)
	target.ignite_mob()

/datum/heretic_knowledge/spell/flame_birth
	name = "Nightwatcher's Rebirth"
	desc = "Grants you Nightwatcher's Rebirth, a spell that extinguishes you and \
		burns all nearby heathens who are currently on fire, healing you for every victim afflicted. \
		If any victims afflicted are in critical condition, they will also instantly die."
	gain_text = "The fire was inescapable, and yet, life remained in his charred body. \
		The Nightwatcher was a particular man, always watching."
	next_knowledge = list(
		/datum/heretic_knowledge/final/ash_final,
		/datum/heretic_knowledge/summon/ashy,
		/datum/heretic_knowledge/summon/rusty,
	)
	spell_to_add = /obj/effect/proc_holder/spell/targeted/fiery_rebirth
	cost = 1
	route = PATH_ASH

/datum/heretic_knowledge/final/ash_final
	name = "Ashlord's Rite"
	desc = "The ascension ritual of the Path of Ash. \
		Bring 3 burning or husked corpses to a transumation rune to complete the ritual. \
		When completed, you become a harbinger of flames, gaining two abilites. \
		Cascade, which causes a massive, growing ring of fire around you, \
		and Oath of Flame, causing you to passively create a ring of flames as you walk. \
		You will also become immune to flames, space, and similar environmental hazards."
	gain_text = "The Watch is dead, the Nightwatcher burned with it. Yet his fire burns evermore, \
		for the Nightwatcher brought forth the rite to mankind! His gaze continues, as now I am one with the flames, \
		WITNESS MY ASCENSION, THE ASHY LANTERN BLAZES ONCE MORE!"
	route = PATH_ASH
	/// A static list of all traits we apply on ascension.
	var/static/list/traits_to_apply = list(
		TRAIT_RESISTHEAT,
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOFIRE,
	)

/datum/heretic_knowledge/final/ash_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return

	if(sacrifice.on_fire)
		return TRUE
	if(HAS_TRAIT_FROM(sacrifice, TRAIT_HUSK, BURN))
		return TRUE
	return FALSE

/datum/heretic_knowledge/final/ash_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_heretic_text()] Fear the blaze, for the Ashlord, [user.real_name] has ascended! The flames shall consume all! [generate_heretic_text()]","[generate_heretic_text()]", ANNOUNCER_SPANOMALIES)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/fire_cascade/big)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/fire_sworn)
	user.client?.give_award(/datum/award/achievement/misc/ash_ascension, user)
	for(var/trait in traits_to_apply)
		ADD_TRAIT(user, trait, MAGIC_TRAIT)
