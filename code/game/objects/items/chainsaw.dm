
// CHAINSAW
/obj/item/chainsaw
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon = 'icons/obj/weapons/chainsaw.dmi'
	icon_state = "chainsaw"
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
	var/force_on = 24
	/// The looping sound for our chainsaw when running
	var/datum/looping_sound/chainsaw/chainsaw_loop
	/// How long it takes to behead someone with this chainsaw.
	var/behead_time = 15 SECONDS

/obj/item/chainsaw/Initialize(mapload)
	. = ..()
	chainsaw_loop = new(src)
	apply_components()
	AddComponent( \
		/datum/component/transforming, \
		force_on = force_on, \
		throwforce_on = force_on, \
		throw_speed_on = throw_speed, \
		sharpness_on = SHARP_EDGED, \
		hitsound_on = 'sound/items/weapons/chainsawhit.ogg', \
		w_class_on = w_class, \
	)

	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/chainsaw/proc/apply_components()
	AddComponent(/datum/component/butchering, \
		speed = 3 SECONDS, \
		effectiveness = 100, \
		bonus_modifier = 0, \
		butcher_sound = 'sound/items/weapons/chainsawhit.ogg', \
		disabled = TRUE, \
	)
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

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

/obj/item/chainsaw/suicide_act(mob/living/carbon/user)
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		user.visible_message(span_suicide("[user] smashes [src] into [user.p_their()] neck, destroying [user.p_their()] esophagus! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(src, 'sound/items/weapons/genhit1.ogg', 100, TRUE)
		return BRUTELOSS

	user.visible_message(span_suicide("[user] begins to tear [user.p_their()] head off with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src, 'sound/items/weapons/chainsawhit.ogg', 100, TRUE)
	var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
	if(myhead)
		myhead.dismember()
	return BRUTELOSS

/obj/item/chainsaw/attack(mob/living/target_mob, mob/living/user, params)
	if (target_mob.stat != DEAD)
		return ..()

	if (user.zone_selected != BODY_ZONE_HEAD)
		return ..()

	var/obj/item/bodypart/head = target_mob.get_bodypart(BODY_ZONE_HEAD)
	if (isnull(head))
		return ..()

	playsound(user, 'sound/items/weapons/slice.ogg', vol = 80, vary = TRUE)

	target_mob.balloon_alert(user, "cutting off head...")
	if (!do_after(user, behead_time, target_mob, extra_checks = CALLBACK(src, PROC_REF(has_same_head), target_mob, head)))
		return TRUE

	head.dismember(silent = FALSE)
	user.put_in_hands(head)

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

/obj/item/chainsaw/mounted_chainsaw
	name = "mounted chainsaw"
	desc = "A chainsaw that has replaced your arm."
	inhand_icon_state = "mounted_chainsaw"
	item_flags = ABSTRACT | DROPDEL
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	toolspeed = 1

/obj/item/chainsaw/mounted_chainsaw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/chainsaw/mounted_chainsaw/Destroy()
	var/obj/item/bodypart/part
	new /obj/item/chainsaw(get_turf(src))
	if(iscarbon(loc))
		var/mob/living/carbon/holder = loc
		var/index = holder.get_held_index_of_item(src)
		if(index)
			part = holder.hand_bodyparts[index]
	. = ..()
	if(part)
		part.drop_limb()

/obj/item/chainsaw/mounted_chainsaw/apply_components()
	AddComponent(/datum/component/butchering, \
		speed = 3 SECONDS, \
		effectiveness = 100, \
		bonus_modifier = 0, \
		butcher_sound = 'sound/items/weapons/chainsawhit.ogg', \
		disabled = TRUE, \
	)

/datum/action/item_action/startchainsaw
	name = "Pull The Starting Cord"
