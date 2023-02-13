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
 * Fire Blast
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

/datum/heretic_knowledge/ashen_grasp
	name = "Grasp of Ash"
	desc = "Your Mansus Grasp will burn the eyes of the victim, causing damage and blindness."
	gain_text = "The Nightwatcher was the first of them, his treason started it all. \
		Their lantern, expired to ash - their watch, absent."
	next_knowledge = list(/datum/heretic_knowledge/spell/ash_passage)
	cost = 1
	route = PATH_ASH

/datum/heretic_knowledge/ashen_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/ashen_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/ashen_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(target.is_blind())
		return

	if(!target.getorganslot(ORGAN_SLOT_EYES))
		return

	to_chat(target, span_danger("A bright green light burns your eyes horrifically!"))
	target.adjustOrganLoss(ORGAN_SLOT_EYES, 15)
	target.set_eye_blur_if_lower(20 SECONDS)

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
	spell_to_add = /datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash
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
	var/datum/action/cooldown/spell/touch/mansus_grasp/grasp = locate() in source.actions
	if(grasp)
		grasp.next_use_time = min(round(grasp.next_use_time - grasp.cooldown_time * 0.75, 0), 0)
		grasp.build_all_button_icons()

/datum/heretic_knowledge/knowledge_ritual/ash
	next_knowledge = list(/datum/heretic_knowledge/spell/fire_blast)
	route = PATH_ASH

/datum/heretic_knowledge/spell/fire_blast
	name = "Volcano Blast"
	desc = "Grants you Volcano Blast, a spell that - after a short charge - fires off a beam of energy \
		at a nearby enemy, setting them on fire and burning them. If they do not extinguish themselves, \
		the beam will continue to another target."
	gain_text = "No fire was hot enough to rekindle them. No fire was bright enough to save them. No fire is eternal."
	next_knowledge = list(/datum/heretic_knowledge/mad_mask)
	spell_to_add = /datum/action/cooldown/spell/charged/beam/fire_blast
	cost = 1
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
		/obj/item/flashlight/flare/candle = 4,
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
		/datum/heretic_knowledge/ultimate/ash_final,
		/datum/heretic_knowledge/summon/ashy,
		/datum/heretic_knowledge/summon/rusty,
	)
	spell_to_add = /datum/action/cooldown/spell/aoe/fiery_rebirth
	cost = 1
	route = PATH_ASH

/datum/heretic_knowledge/ultimate/ash_final
	name = "Ashlord's Rite"
	desc = "The ascension ritual of the Path of Ash. \
		Bring 3 burning or husked corpses to a transmutation rune to complete the ritual. \
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

/datum/heretic_knowledge/ultimate/ash_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return

	if(sacrifice.on_fire)
		return TRUE
	if(HAS_TRAIT_FROM(sacrifice, TRAIT_HUSK, BURN))
		return TRUE
	return FALSE

/datum/heretic_knowledge/ultimate/ash_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_heretic_text()] Fear the blaze, for the Ashlord, [user.real_name] has ascended! The flames shall consume all! [generate_heretic_text()]","[generate_heretic_text()]", ANNOUNCER_SPANOMALIES)

	var/datum/action/cooldown/spell/fire_sworn/circle_spell = new(user.mind)
	circle_spell.Grant(user)

	var/datum/action/cooldown/spell/fire_cascade/big/screen_wide_fire_spell = new(user.mind)
	screen_wide_fire_spell.Grant(user)

	var/datum/action/cooldown/spell/charged/beam/fire_blast/existing_beam_spell = locate() in user.actions
	if(existing_beam_spell)
		existing_beam_spell.max_beam_bounces *= 2 // Double beams
		existing_beam_spell.beam_duration *= 0.66 // Faster beams
		existing_beam_spell.cooldown_time *= 0.66 // Lower cooldown

	user.client?.give_award(/datum/award/achievement/misc/ash_ascension, user)
	for(var/trait in traits_to_apply)
		ADD_TRAIT(user, trait, MAGIC_TRAIT)
