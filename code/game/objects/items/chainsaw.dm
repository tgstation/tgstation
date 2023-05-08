
// CHAINSAW
/obj/item/chainsaw
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon = 'icons/obj/weapons/chainsaw.dmi'
	icon_state = "chainsaw_off"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 13
	var/force_on = 24
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
	var/on = FALSE
	///The looping sound for our chainsaw when running
	var/datum/looping_sound/chainsaw/chainsaw_loop

/obj/item/chainsaw/Initialize(mapload)
	. = ..()
	chainsaw_loop = new(src)
	apply_components()

/obj/item/chainsaw/suicide_act(mob/living/carbon/user)
	if(on)
		user.visible_message(span_suicide("[user] begins to tear [user.p_their()] head off with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(src, 'sound/weapons/chainsawhit.ogg', 100, TRUE)
		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
		if(myhead)
			myhead.dismember()
	else
		user.visible_message(span_suicide("[user] smashes [src] into [user.p_their()] neck, destroying [user.p_their()] esophagus! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(src, 'sound/weapons/genhit1.ogg', 100, TRUE)
	return BRUTELOSS

/obj/item/chainsaw/attack_self(mob/user)
	on = !on
	to_chat(user, "As you pull the starting cord dangling from [src], [on ? "it begins to whirr." : "the chain stops moving."]")
	force = on ? force_on : initial(force)
	throwforce = on ? force_on : initial(force)
	icon_state = "chainsaw_[on ? "on" : "off"]"
	var/datum/component/butchering/butchering = src.GetComponent(/datum/component/butchering)
	butchering.butchering_enabled = on

	if(on)
		hitsound = 'sound/weapons/chainsawhit.ogg'
		chainsaw_loop.start()
	else
		hitsound = SFX_SWING_HIT
		chainsaw_loop.stop()

	toolspeed = on ? 0.5 : initial(toolspeed) //Turning it on halves the speed
	if(src == user.get_active_held_item()) //update inhands
		user.update_held_items()
	update_item_action_buttons()

/**
 * Handles adding components to the chainsaw. Added in Initialize()
 *
 * Applies components to the chainsaw. Added as a seperate proc to allow for
 * variance between subtypes
 */
/obj/item/chainsaw/proc/apply_components()
	AddComponent(/datum/component/butchering, \
		speed = 3 SECONDS, \
		effectiveness = 100, \
		bonus_modifier = 0, \
		butcher_sound = 'sound/weapons/chainsawhit.ogg', \
		disabled = TRUE, \
	)
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/chainsaw/doomslayer
	name = "THE GREAT COMMUNICATOR"
	desc = "<span class='warning'>VRRRRRRR!!!</span>"
	armour_penetration = 100
	force_on = 30

/obj/item/chainsaw/doomslayer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		owner.visible_message(span_danger("Ranged attacks just make [owner] angrier!"))
		playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)
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
		butcher_sound = 'sound/weapons/chainsawhit.ogg', \
		disabled = TRUE, \
	)

/datum/action/item_action/startchainsaw
	name = "Pull The Starting Cord"
