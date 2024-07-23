/*
 * BATTERING RAM
 *
 * KNOCK-KNOCK, its Justice!
 */
/obj/item/batteringram
	icon = 'icons/obj/weapons/fireaxe.dmi'
	icon_state = "battering_ram0"
	base_icon_state = "battering_ram"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	name = "battering ram"
	desc = "An extremely heavy and unwieldy hunk of metal used to break down airlocks. Why would anyone ram a sliding airlock?"

	w_class = WEIGHT_CLASS_HUGE
	item_flags = SLOWS_WHILE_IN_HAND | IMMUTABLE_SLOW
	slot_flags = ITEM_SLOT_BACK
	obj_flags = CONDUCTS_ELECTRICITY
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/item_batteringram

	demolition_mod = 3 // 9 hits to down a airlock
	wound_bonus = 20 // RIP bones
	bare_wound_bonus = 0
	throwforce = 14

	slowdown = 1
	drag_slowdown = 1.5 // So you cannot circumvent the slowdown
	throw_range = 2

	attack_verb_continuous = list("slams", "breaks", "demolishes", "rams", "batters", "breaches")
	attack_verb_simple = list("slam", "break", "demolish", "ram", "batter", "breach")

	hitsound = 'sound/effects/bang.ogg'
	pickup_sound = 'sound/items/handling/heavy_pickup.ogg'
	drop_sound = 'sound/items/handling/heavy_drop.ogg'

	/// How much damage to do unwielded
	var/force_unwielded = 5
	/// How much damage to do wielded
	var/force_wielded = 20
	/// Is it being swung?
	var/swung = FALSE

/datum/armor/item_batteringram
	fire = 100
	bomb = 100
	acid = 30

/obj/item/batteringram/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded, require_twohands = TRUE, icon_wielded="[base_icon_state]1")

/obj/item/batteringram/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/batteringram/pre_attack(atom/A, mob/living/user, params)
	if(swung)
		balloon_alert(user, "swinging!")
		return TRUE
	if(!isturf(A) && !istype(A, /obj/structure/fireaxecabinet/batteringram))
		swung = TRUE
		visible_message(span_warning("[user] swings [src] back for a blow into [A]!"))
		playsound(user, 'sound/weapons/throw.ogg', 50, TRUE)
		if(!do_after(user, 0.5 SECONDS, A))
			balloon_alert(user, "interrupted!")
			swung = FALSE
			return TRUE

		swung = FALSE
	return ..()

/obj/item/batteringram/attack(mob/living/target_mob, mob/living/user, params)
	. = ..()
	if(!target_mob.anchored && target_mob.body_position == STANDING_UP)
		var/no_gravity = FALSE
		if(!has_gravity()) // Should've learned physics
			var/user_throwtarget = get_step(user, get_dir(target_mob, user))
			user.safe_throw_at(user_throwtarget, 1, 1, force = MOVE_FORCE_STRONG)
			no_gravity = TRUE
		var/throwtarget = get_step(target_mob, get_dir(user, target_mob))
		target_mob.safe_throw_at(throwtarget, 1, 1, force = MOVE_FORCE_STRONG, spin = no_gravity)

/obj/item/batteringram/afterattack(atom/target, mob/user, click_parameters)
	. = ..()
	var/mob/living/living_user = user

	if(!isliving(target))
		if(istype(target, /obj/machinery/door))
			if(!target.density && target.get_integrity() != 0)
				living_user.Knockdown(3 SECONDS)
				living_user.safe_throw_at(target, 1, 1, force = MOVE_FORCE_STRONG, spin = FALSE)

				to_chat(living_user, span_userdanger("You try to [pick(attack_verb_simple)] [target], but its open and you fall in it!"))
				visible_message(span_warning("[living_user] falls into open [target]!"))
				playsound(living_user, 'sound/weapons/thudswoosh.ogg', 100)
				return

		playsound(target, hitsound, 100, TRUE)
		for(var/mob/bystanders in urange(2, target)) // BLAM BLAM
			if(!bystanders.stat && !isAI(bystanders))
				shake_camera(bystanders, 1, 0.5)

	if((HAS_TRAIT(living_user, TRAIT_CLUMSY)) && prob(30)) // https://tenor.com/view/police-raid-fall-out-funny-gif-9719355
		var/throwtarget = get_step(living_user, get_dir(target, living_user))
		living_user.Knockdown(3 SECONDS)
		living_user.safe_throw_at(throwtarget, 1, 1, force = MOVE_FORCE_STRONG)

		to_chat(living_user, span_userdanger("You [pick(attack_verb_simple)] [target], but slip due inertia!"))
		visible_message(span_warning("[living_user] slips backwards!"))
		playsound(living_user, 'sound/misc/slip.ogg', 100)

/obj/item/batteringram/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] [pick(attack_verb_continuous)] [user.p_them()]self open! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(user, hitsound, 100, ignore_walls = FALSE)
	return BRUTELOSS
