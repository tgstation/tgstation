
// CHAINSAW
/obj/item/chainsaw
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon = 'icons/obj/weapons/chainsaw.dmi'
	icon_state = "chainsaw"
	base_icon_state = "chainsaw"
	icon_angle = 180
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	force = 13
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 13
	throw_speed = 2
	throw_range = 4
	demolition_mod = 1.5
	custom_materials = list(/datum/material/iron= SHEET_MATERIAL_AMOUNT * 6.5)
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	hitsound = SFX_SWING_HIT
	sharpness = SHARP_EDGED
	actions_types = list(/datum/action/item_action/startchainsaw)
	tool_behaviour = TOOL_SAW
	toolspeed = 1.5 //Turn it on first you dork
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/alloy/plasteel =  SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass =  SHEET_MATERIAL_AMOUNT * 3)
	var/force_on = 24
	/// The looping sound for our chainsaw when running
	var/datum/looping_sound/chainsaw/chainsaw_loop
	/// How long it takes to behead someone with this chainsaw.
	var/behead_time = 15 SECONDS

/obj/item/chainsaw/Initialize(mapload)
	. = ..()
	chainsaw_loop = new(src)
	AddComponent( \
		/datum/component/transforming, \
		force_on = force_on, \
		throwforce_on = force_on, \
		throw_speed_on = throw_speed, \
		sharpness_on = SHARP_EDGED, \
		hitsound_on = 'sound/items/weapons/chainsawhit.ogg', \
		w_class_on = w_class, \
	)
	AddComponent(/datum/component/butchering, \
		speed = 3 SECONDS, \
		effectiveness = 100, \
		bonus_modifier = 0, \
		butcher_sound = 'sound/items/weapons/chainsawhit.ogg', \
		disabled = TRUE, \
	)
	AddElement(/datum/element/prosthetic_icon, "mounted", 180, TRUE)
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))
	RegisterSignal(src, COMSIG_ITEM_PRE_USED_AS_PROSTHETIC, PROC_REF(disable_twohanded_comp))
	RegisterSignal(src, COMSIG_ITEM_DROPPED_FROM_PROSTHETIC, PROC_REF(enable_twohanded_comp))

/obj/item/chainsaw/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	to_chat(user, span_notice("As you pull the starting cord dangling from [src], [active ? "it begins to whirr" : "the chain stops moving"]."))
	var/datum/component/butchering/butchering = GetComponent(/datum/component/butchering)
	butchering.butchering_enabled = active
	if (active)
		chainsaw_loop.start()
	else
		chainsaw_loop.stop()

	toolspeed = active ? 0.5 : initial(toolspeed)
	update_item_action_buttons()

	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/chainsaw/proc/disable_twohanded_comp()
	SIGNAL_HANDLER

	qdel(GetComponent(/datum/component/two_handed))

/obj/item/chainsaw/proc/enable_twohanded_comp()
	SIGNAL_HANDLER

	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/chainsaw/get_demolition_modifier(obj/target)
	return HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) ? demolition_mod : 0.8

/obj/item/chainsaw/suicide_act(mob/living/user)
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		user.visible_message(span_suicide("[user] smashes [src] into [user.p_their()] neck, destroying [user.p_their()] esophagus! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(src, 'sound/items/weapons/genhit1.ogg', 100, TRUE)
		return BRUTELOSS

	if (!iscarbon(user))
		user.visible_message(span_suicide("[user] begins to shred [user.p_themselves()] with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		return BRUTELOSS

	user.visible_message(span_suicide("[user] begins to tear [user.p_their()] head off with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
	if(!myhead)
		visible_message(span_suicide("[user] realises that [user.p_they()] cannot cut off [user.p_their()] head because [user.p_they()] [user.p_do()]n't have one!"))
		return SHAME

	playsound(src, 'sound/items/weapons/chainsawhit.ogg', 100, TRUE)
	if(myhead.dismember())
		return BRUTELOSS

	var/datum/wound/slash/crit_wound = new ()
	crit_wound.apply_wound(myhead)
	visible_message(span_suicide("[user] tries in vain to cut off [user.p_their()] head but perishes in the attempt!"))
	return BRUTELOSS

/obj/item/chainsaw/attack(mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return ..()

	if (target_mob.stat != DEAD)
		return ..()

	if (user.zone_selected != BODY_ZONE_HEAD)
		return ..()

	var/obj/item/bodypart/head = target_mob.get_bodypart(BODY_ZONE_HEAD)
	if (!head)
		return ..()

	playsound(src, 'sound/items/weapons/chainsawhit.ogg', vol = 100, vary = TRUE)
	target_mob.balloon_alert(user, "cutting off head...")

	if (!do_after(user, behead_time, target_mob, extra_checks = CALLBACK(src, PROC_REF(has_same_head), target_mob, head)))
		return TRUE

	if (head.dismember(silent = FALSE))
		playsound(src, 'sound/items/weapons/chainsawhit.ogg', vol = 100, vary = TRUE)
	else
		to_chat(user, span_warning("[target_mob]'s head is attached too firmly to cut off!"))

	return TRUE

/obj/item/chainsaw/proc/has_same_head(mob/living/target_mob, obj/item/bodypart/head)
	return target_mob.get_bodypart(BODY_ZONE_HEAD) == head

/**
 * Handles adding components to the chainsaw. Added in Initialize()
 *
 * Applies components to the chainsaw. Added as a separate proc to allow for
 * variance between subtypes
 */

/obj/item/chainsaw/doomslayer
	name = "THE GREAT COMMUNICATOR"
	desc = span_warning("VRRRRRRR!!!")
	armour_penetration = 100
	force_on = 30
	behead_time = 2 SECONDS

/obj/item/chainsaw/doomslayer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(attack_type == PROJECTILE_ATTACK)
		owner.visible_message(span_danger("Ranged attacks just make [owner] angrier!"))
		playsound(src, SFX_BULLET_MISS, 75, TRUE)
		return TRUE
	return FALSE

/obj/item/chainsaw/dual
	name = "double-ended chainsaw spear"
	desc = "A dangerous, crazy contraption that could fall apart from a slight breeze. WHAT WERE THEY THINKING?!"
	icon_state = "chainsawdual"
	base_icon_state = "chainsawdual"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	throw_range = 0
	force_on = 40
	armour_penetration = 20
	block_chance = 50
	block_sound = 'sound/items/weapons/parry.ogg'
	item_flags = SLOWS_WHILE_IN_HAND
	slowdown = 2
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 12.3,
		/datum/material/alloy/plasteel = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 6.3,
		/datum/material/plastic = SMALL_MATERIAL_AMOUNT * 2
	)

/obj/item/chainsaw/dual/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_HULK))
		to_chat(user, span_warning("You grip the weapon too hard and accidentally drop it!"))
		user.dropItemToGround(src, force=TRUE)
		return TRUE

/obj/item/chainsaw/dual/attack(mob/target, mob/living/carbon/human/user)
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return ..()

	if(prob(50))
		impale(user)
		return TRUE

	return ..()

/obj/item/chainsaw/dual/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	if(prob(50))
		INVOKE_ASYNC(src, PROC_REF(jedi_spin), user)

/obj/item/chainsaw/dual/proc/jedi_spin(mob/living/user)
	dance_rotate(user, CALLBACK(user, TYPE_PROC_REF(/mob, dance_flip)))

/obj/item/chainsaw/dual/proc/impale(mob/living/user)
	to_chat(user, span_warning("You horrifically tear yourself with [src]!"))
	user.take_bodypart_damage(45,check_armor = TRUE, wound_bonus = 20, sharpness = SHARP_EDGED)
	user.do_attack_animation(user)
	user.Stun(1 SECONDS)
	user.Knockdown(5 SECONDS)

/obj/item/chainsaw/dual/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(attack_type == PROJECTILE_ATTACK || attack_type == LEAP_ATTACK || attack_type == OVERWHELMING_ATTACK)
		final_block_chance = 0
	if(attack_type != PROJECTILE_ATTACK && prob(30))
		atom_destruction(MELEE)
		return FALSE

	return ..()

/obj/item/chainsaw/dual/atom_destruction(damage_flag)
	playsound(src, 'sound/effects/grillehit.ogg', 50)
	new /obj/item/chainsaw(drop_location())
	new /obj/item/chainsaw(drop_location())
	new /obj/item/restraints/handcuffs/cable(drop_location())
	if(isliving(loc))
		loc.balloon_alert(loc, "weapon broken!")
	return ..()

/datum/action/item_action/startchainsaw
	name = "Pull The Starting Cord"
