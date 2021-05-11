
// CHAINSAW
/obj/item/chainsaw
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon_state = "chainsaw_off"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 13
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 13
	throw_speed = 2
	throw_range = 4
	custom_materials = list(/datum/material/iron=13000)
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	hitsound = "swing_hit"
	sharpness = SHARP_EDGED
	actions_types = list(/datum/action/item_action/startchainsaw)
	tool_behaviour = TOOL_SAW
	toolspeed = 0.5
	// used as a component arg for how much force the chainsaw has while on
	var/force_on = 24
	var/wielded = FALSE // track wielded status on item

/obj/item/chainsaw/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)
	//some clarified arguments
	var/speed = 3 SECONDS
	var/effectiveness = 100
	var/bonus_modifier = 0
	var/butcher_sound = 'sound/effects/butcher.ogg'
	var/can_be_blunt = TRUE
	var/butchering_enabled = FALSE
	var/enable_butchering_signals = list(COMSIG_TWOHANDED_WIELD)
	var/disable_butchering_signals = list(COMSIG_TWOHANDED_UNWIELD)
	AddComponent(\
		/datum/component/butchering,\
		speed,\
		effectiveness,\
		bonus_modifier,\
		butcher_sound,\
		can_be_blunt,\
		butchering_enabled,\
		enable_butchering_signals,\
		disable_butchering_signals\
	)
	//same here for twohands
	var/require_twohands = TRUE
	var/unwieldsound = null
	var/wieldsound = null
	var/attacksound = 'sound/weapons/chainsawhit.ogg'
	var/force_multiplier = 0
	var/force_wielded = force_on
	var/force_unwielded = 13
	var/icon_wielded = "chainsaw_on"
	AddComponent(
		/datum/component/two_handed,\
		require_twohands,\
		unwieldsound,\
		wieldsound,\
		attacksound,\
		force_multiplier,\
		force_wielded,\
		force_unwielded,\
		icon_wielded\
	)

/// triggered on wield of two handed item
/obj/item/chainsaw/proc/on_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	to_chat(user, "As you pull the starting cord dangling from [src], it begins to whirr.")
	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/chainsaw/proc/on_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	to_chat(user, "As you pull the starting cord dangling from [src], the chain stops moving.")
	wielded = FALSE

/obj/item/chainsaw/suicide_act(mob/living/carbon/user)
	if(wielded)
		user.visible_message("<span class='suicide'>[user] begins to tear [user.p_their()] head off with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		playsound(src, 'sound/weapons/chainsawhit.ogg', 100, TRUE)
		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
		if(myhead)
			myhead.dismember()
	else
		user.visible_message("<span class='suicide'>[user] smashes [src] into [user.p_their()] neck, destroying [user.p_their()] esophagus! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		playsound(src, 'sound/weapons/genhit1.ogg', 100, TRUE)
	return(BRUTELOSS)

/obj/item/chainsaw/doomslayer
	name = "THE GREAT COMMUNICATOR"
	desc = "<span class='warning'>VRRRRRRR!!!</span>"
	armour_penetration = 100
	force_on = 30

/obj/item/chainsaw/doomslayer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		owner.visible_message("<span class='danger'>Ranged attacks just make [owner] angrier!</span>")
		playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)
		return TRUE
	return FALSE
