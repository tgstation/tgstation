/mob/living/basic/wizard
	name = "Space Wizard"
	desc = "A wizard is never early. Nor is he late. He arrives exactly at the worst possible moment."
	icon = 'icons/mob/simple/simple_human.dmi'
	icon_state = "wizard"
	icon_living = "wizard"
	icon_dead = "wizard_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	speed = 0
	maxHealth = 100
	health = 100
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = TRUE
	habitable_atmos = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 7.5
	faction = list(ROLE_WIZARD)
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/wizard

	/// A list of possible wizard corpses, and therefore wizard outfits, to select from
	var/static/list/wizard_outfits = list(
		/obj/effect/mob_spawn/corpse/human/wizard,
		/obj/effect/mob_spawn/corpse/human/wizard/red,
		/obj/effect/mob_spawn/corpse/human/wizard/yellow,
		/obj/effect/mob_spawn/corpse/human/wizard/black,
	)
	/// A specified wizard corpse spawner to use. If null, picks from the list above instead.
	var/selected_outfit

	/// The wizard's "main" attack, a targeted spell like fireball
	var/datum/action/cooldown/spell/targeted_spell
	/// Typepath for the wizard's targeted spell. If null, selects randomly.
	var/targeted_spell_path
	/// List of possible targeted spells to pick from
	var/static/list/targeted_spell_list = list(
		/datum/action/cooldown/spell/pointed/projectile/fireball,
		/datum/action/cooldown/spell/pointed/projectile/lightningbolt,
		/datum/action/cooldown/spell/pointed/projectile/spell_cards,
	)

	/// The wizard's secondary spell, which should be targetless
	var/datum/action/cooldown/spell/secondary_spell
	/// Typepath for the wizard's secondary spell. If null, selects randomly.
	var/secondary_spell_path
	/// List of possible secondary spells to pick from
	var/static/list/secondary_spell_list = list(
		/datum/action/cooldown/spell/aoe/magic_missile,
		/datum/action/cooldown/spell/charged/beam/tesla,
		/datum/action/cooldown/spell/aoe/repulse,
		/datum/action/cooldown/spell/conjure/the_traps,
	)

	/// The wizard's blink spell. All wizards teleport-spam to be annoying.
	var/datum/action/cooldown/spell/teleport/radius_turf/blink/blink_spell

/mob/living/basic/wizard/Initialize(mapload)
	. = ..()
	if(!selected_outfit)
		selected_outfit = pick(wizard_outfits)
	apply_dynamic_human_appearance(src, mob_spawn_path = selected_outfit, r_hand = /obj/item/staff)
	var/list/remains = string_list(list(
		selected_outfit,
		/obj/item/staff
	))
	AddElement(/datum/element/death_drops, remains)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SHOE)

	if(isnull(targeted_spell_path))
		targeted_spell_path = pick(targeted_spell_list)
	if(isnull(secondary_spell_path))
		secondary_spell_path = pick(secondary_spell_list)

	targeted_spell = new targeted_spell_path(src)
	targeted_spell.spell_requirements &= ~(SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_MIND)
	targeted_spell.Grant(src)
	ai_controller.set_blackboard_key(BB_WIZARD_TARGETED_SPELL, targeted_spell)

	secondary_spell = new secondary_spell_path(src)
	secondary_spell.spell_requirements &= ~(SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_MIND)
	secondary_spell.Grant(src)
	ai_controller.set_blackboard_key(BB_WIZARD_SECONDARY_SPELL, secondary_spell)

	blink_spell = new(src)
	blink_spell.spell_requirements &= ~(SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_MIND)
	blink_spell.outer_tele_radius = 3
	blink_spell.Grant(src)
	ai_controller.set_blackboard_key(BB_WIZARD_BLINK_SPELL, blink_spell)

/mob/living/basic/wizard/Destroy()
	QDEL_NULL(targeted_spell)
	QDEL_NULL(secondary_spell)
	QDEL_NULL(blink_spell)
	return ..()

/// Uses the colors and loadout of the original wizard simplemob
/mob/living/basic/wizard/classic
	selected_outfit = /obj/effect/mob_spawn/corpse/human/wizard
	targeted_spell_path = /datum/action/cooldown/spell/pointed/projectile/fireball
	secondary_spell_path = /datum/action/cooldown/spell/aoe/magic_missile
