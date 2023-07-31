/obj/item/wrench
	name = "wrench"
	desc = "A wrench with common uses. Can be found in your hand."
	icon = 'icons/obj/tools.dmi'
	icon_state = "wrench"
	inhand_icon_state = "wrench"
	worn_icon_state = "wrench"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	demolition_mod = 1.25
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/ratchet.ogg'
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*1.5)
	drop_sound = 'sound/items/handling/wrench_drop.ogg'
	pickup_sound = 'sound/items/handling/wrench_pickup.ogg'

	attack_verb_continuous = list("bashes", "batters", "bludgeons", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "whack")
	tool_behaviour = TOOL_WRENCH
	toolspeed = 1
	armor_type = /datum/armor/item_wrench

/datum/armor/item_wrench
	fire = 50
	acid = 30

/obj/item/wrench/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = force, wound_bonus = wound_bonus, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/obj/item/wrench/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is beating [user.p_them()]self to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/weapons/genhit.ogg', 50, TRUE, -1)
	return BRUTELOSS

/obj/item/wrench/abductor
	name = "alien wrench"
	desc = "A polarized wrench. It causes anything placed between the jaws to turn."
	icon = 'icons/obj/antags/abductor.dmi'
	belt_icon_state = "wrench_alien"
	custom_materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/silver = SHEET_MATERIAL_AMOUNT*1.25, /datum/material/plasma =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/titanium =SHEET_MATERIAL_AMOUNT, /datum/material/diamond =SHEET_MATERIAL_AMOUNT)
	usesound = 'sound/effects/empulse.ogg'
	toolspeed = 0.1


/obj/item/wrench/medical
	name = "medical wrench"
	desc = "A medical wrench with common(medical?) uses. Can be found in your hand."
	icon_state = "wrench_medical"
	inhand_icon_state = "wrench_medical"
	force = 2 //MEDICAL
	throwforce = 4
	attack_verb_continuous = list("heals", "medicals", "taps", "pokes", "analyzes") //"cobbyed"
	attack_verb_simple = list("heal", "medical", "tap", "poke", "analyze")
	///var to hold the name of the person who suicided
	var/suicider

/obj/item/wrench/medical/examine(mob/user)
	. = ..()
	if(suicider)
		. += span_notice("For some reason, it reminds you of [suicider].")

/obj/item/wrench/medical/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is praying to the medical wrench to take [user.p_their()] soul. It looks like [user.p_theyre()] trying to commit suicide!"))
	user.Stun(100, ignore_canstun = TRUE)// Stun stops them from wandering off
	user.set_light_color(COLOR_VERY_SOFT_YELLOW)
	user.set_light(2)
	user.add_overlay(mutable_appearance('icons/mob/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER))
	playsound(loc, 'sound/effects/pray.ogg', 50, TRUE, -1)

	// Let the sound effect finish playing
	add_fingerprint(user)
	sleep(2 SECONDS)
	if(!user)
		return
	for(var/obj/item/suicide_wrench in user)
		user.dropItemToGround(suicide_wrench)
	suicider = user.real_name
	user.dust()
	return OXYLOSS

/obj/item/wrench/cyborg
	name = "hydraulic wrench"
	desc = "An advanced robotic wrench, powered by internal hydraulics. Twice as fast as the handheld version."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "wrench_cyborg"
	toolspeed = 0.5

/obj/item/wrench/combat
	name = "combat wrench"
	desc = "It's like a normal wrench but edgier. Can be found on the battlefield."
	icon_state = "wrench_combat"
	inhand_icon_state = "wrench_combat"
	belt_icon_state = "wrench_combat"
	attack_verb_continuous = list("devastates", "brutalizes", "commits a war crime against", "obliterates", "humiliates")
	attack_verb_simple = list("devastate", "brutalize", "commit a war crime against", "obliterate", "humiliate")
	tool_behaviour = null

/obj/item/wrench/combat/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/transforming, \
		force_on = 6, \
		throwforce_on = 8, \
		hitsound_on = hitsound, \
		w_class_on = WEIGHT_CLASS_NORMAL, \
		clumsy_check = FALSE, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Gives it wrench behaviors when active.
 */
/obj/item/wrench/combat/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	tool_behaviour = active ? TOOL_WRENCH : initial(tool_behaviour)
	if(user)
		balloon_alert(user, "[name] [active ? "active, woe!":"restrained"]")
	playsound(src, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 5, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/wrench/bolter
	name = "bolter wrench"
	desc = "A wrench designed to grab into airlock's bolting system and raise it regardless of the airlock's power status."
	icon_state = "bolter_wrench"
	inhand_icon_state = "bolter_wrench"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/wrench/giant_wrench
	name = "Big Slappy"
	desc = "A gigantic wrench made illegal because of its many incidents involving this tool."
	icon_state = "giant_wrench"
	icon = 'icons/obj/weapons/giant_wrench.dmi'
	inhand_icon_state = null
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = NONE
	toolspeed = 0.1
	force = 30
	throwforce = 20
	block_chance = 30
	throw_range = 2
	demolition_mod = 2
	armor_type = /datum/armor/giant_wrench
	resistance_flags = FIRE_PROOF
	wound_bonus = -10
	attack_verb_continuous = list("bonks", "bludgeons", "pounds")
	attack_verb_simple = list("bonks", "bludgeons", "pounds")
	usesound = 'sound/items/drill_use.ogg'
	drop_sound = 'sound/weapons/sonic_jackhammer.ogg'
	pickup_sound = 'sound/items/handling/crowbar_pickup.ogg'
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	block_sound = 'sound/weapons/sonic_jackhammer.ogg'

/datum/armor/giant_wrench
	acid = 30
	bomb = 100
	bullet = 30
	fire = 100
	laser = 30
	melee = 30

/obj/item/wrench/giant_wrench/Initialize(mapload)
	. = ..()
	transform = transform.Translate(-16, -16)
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)
	AddComponent(/datum/component/item_slowdown, /datum/movespeed_modifier/giant_wrench, TRUE)

/obj/item/wrench/giant_wrench/attack(mob/living/target_mob, mob/living/user)
	..()
	if(QDELETED(target_mob))
		return
	var/atom/throw_target = get_edge_target_turf(target_mob, get_dir(user, get_step_away(target_mob, user)))
	target_mob.throw_at(throw_target, 2, 2, user, gentle = TRUE)
	target_mob.Knockdown(2 SECONDS)
	user.adjustBruteLoss(force / 3)
	to_chat(user, span_danger("The weight of the Big Slappy recoils!"))
	log_combat(user, user, "recoiled Big Slappy into")
