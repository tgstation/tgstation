/mob/living/basic/eyeball
	name = "eyeball"
	desc = "An odd looking creature, it won't stop staring..."
	icon = 'icons/mob/simple/carp.dmi'
	icon_state = "eyeball"
	icon_living = "eyeball"
	icon_gib = ""
	gender = NEUTER
	gold_core_spawnable = HOSTILE_SPAWN
	basic_mob_flags = DEL_ON_DEATH
	gender = NEUTER
	mob_biotypes = MOB_ORGANIC

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"

	maxHealth = 30
	health = 30
	obj_damage = 10
	melee_damage_lower = 8
	melee_damage_upper = 12

	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	faction = list(FACTION_SPOOKY)
	speak_emote = list("telepathically cries")

	habitable_atmos = null
	minimum_survivable_temperature = T0C
	maximum_survivable_temperature = T0C + 1500
	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS

	lighting_cutoff_red = 40
	lighting_cutoff_green = 20
	lighting_cutoff_blue = 30

	ai_controller = /datum/ai_controller/basic_controller/eyeball
	///how much we will heal eyes
	var/healing_factor = 3
	/// is this eyeball crying?
	var/crying = FALSE
	/// the crying overlay we add when is hit
	var/mutable_appearance/on_hit_overlay

	///cooldown to heal eyes
	COOLDOWN_DECLARE(eye_healing)

/mob/living/basic/eyeball/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/spell/pointed/death_glare = BB_GLARE_ABILITY
	)
	grant_actions_by_list(innate_actions)

	AddElement(/datum/element/simple_flying)
	var/list/food_types = string_list(list(/obj/item/food/grown/carrot))
	AddComponent(/datum/component/tameable, food_types = food_types, tame_chance = 100)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	on_hit_overlay = mutable_appearance(icon, "[icon_state]_crying")

/mob/living/basic/eyeball/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()
	if(!.)
		return

	if(!proximity_flag)
		return

	if(istype(attack_target, /obj/item/food/grown/carrot))
		adjustBruteLoss(-5)
		to_chat(src, span_warning("You eat [attack_target]! It restores some health!"))
		qdel(attack_target)
		return TRUE

/mob/living/basic/eyeball/attackby(obj/item/weapon, mob/living/carbon/human/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!weapon.force && !user.combat_mode)
		return
	if(crying)
		return
	change_crying_state()
	addtimer(CALLBACK(src, PROC_REF(change_crying_state)), 10 SECONDS) //cry for 10 seconds then remove

/mob/living/basic/eyeball/proc/change_crying_state()
	crying = !crying
	if(crying)
		add_overlay(on_hit_overlay)
		return
	cut_overlay(on_hit_overlay)


/mob/living/basic/eyeball/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(target))
		return TRUE
	var/mob/living/carbon/human_target = target
	var/obj/item/organ/eyes/eyes = human_target.get_organ_slot(ORGAN_SLOT_EYES)
	if(isnull(eyes) || eyes.damage < 10)
		return TRUE
	heal_eye_damage(human_target, eyes)
	return FALSE

/mob/living/basic/eyeball/proc/heal_eye_damage(mob/living/target, obj/item/organ/eyes/eyes)
	if(!COOLDOWN_FINISHED(src, eye_healing))
		return
	to_chat(target, span_warning("[src] seems to be healing your [eyes.zone]!"))
	eyes.apply_organ_damage(-1 * healing_factor)
	new /obj/effect/temp_visual/heal(get_turf(target), COLOR_HEALING_CYAN)
	befriend(target)
	COOLDOWN_START(src, eye_healing, 15 SECONDS)

/mob/living/basic/eyeball/tamed(mob/living/tamer, atom/food)
	spin(spintime = 2 SECONDS, speed = 1)
	//become passive to the humens
	faction |= tamer.faction
