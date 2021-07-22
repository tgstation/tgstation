
/obj/item/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum. Left click to stun, right click to harm."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "classic_baton"
	inhand_icon_state = "classic_baton"
	worn_icon_state = "classic_baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 12 //9 hit crit
	w_class = WEIGHT_CLASS_NORMAL

	var/cooldown_check = 0 // Used interally, you don't want to modify

	/// Default wait time until can stun again.
	var/cooldown = (4 SECONDS)
	/// The length of the knockdown applied to a struck living, non-cyborg mob.
	var/knockdown_time = (1.5 SECONDS)
	/// If affect_cyborg is TRUE, this is how long we stun cyborgs for on a hit.
	var/stun_time_cyborg = (5 SECONDS)
	/// How much stamina damage we deal on a successful hit against a living, non-cyborg mob.
	var/stamina_damage = 55
	/// Can we stun cyborgs?
	var/affect_cyborg = FALSE
	/// "On" sound, played when switching between able to stun or not.
	var/on_sound
	/// The path of the default sound to play when we stun something.
	var/on_stun_sound = 'sound/effects/woodhit.ogg'
	/// Do we animate the "hit" when stunning something?
	var/stun_animation = TRUE
	/// Are we on or off?
	var/on = TRUE

	var/on_icon_state // What is our sprite when turned on
	var/off_icon_state // What is our sprite when turned off
	var/on_inhand_icon_state // What is our in-hand sprite when turned on
	var/force_on // Damage when on - not stunning
	var/force_off // Damage when off - not stunning
	var/weight_class_on // What is the new size class when turned on

	wound_bonus = 15

/obj/item/melee/classic_baton/Initialize()
	. = ..()
	// Adding an extra break for the sake of presentation
	if(stamina_damage != 0)
		offensive_notes = "\nVarious interviewed security forces report being able to beat criminals into exhaustion with only [span_warning("[round(100 / stamina_damage, 0.1)] hit\s!")]"

/// Description for trying to stun when still on cooldown.
/obj/item/melee/classic_baton/proc/get_wait_description()
	return

/// Description for when turning the baton "on".
/obj/item/melee/classic_baton/proc/get_on_description()
	. = list()

	.["local_on"] = "<span class ='warning'>You extend the baton.</span>"
	.["local_off"] = "<span class ='notice'>You collapse the baton.</span>"

	return .

/// Default message for stunning a living, non-cyborg mob.
/obj/item/melee/classic_baton/proc/get_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] =  "<span class ='danger'>[user] knocks [target] down with [src]!</span>"
	.["local"] = "<span class ='userdanger'>[user] knocks you down with [src]!</span>"

	return .

/// Default message for stunning a cyborg.
/obj/item/melee/classic_baton/proc/get_cyborg_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = span_danger("[user] pulses [target]'s sensors with the baton!")
	.["local"] = span_danger("You pulse [target]'s sensors with the baton!")

	return .

/// Default message for trying to stun a cyborg with a baton that can't stun cyborgs.
/obj/item/melee/classic_baton/proc/get_unga_dunga_cyborg_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = "<span class='danger'>[user] tries to knock down [target] with [src], and predictably fails!</span>" //look at this duuuuuude
	.["local"] = "<span class='userdanger'>[target] tries to... knock you down with [src]?</span>" //look at the top of his head!

	return .

/// Contains any special effects that we apply to living, non-cyborg mobs we stun. Does not include applying a knockdown, dealing stamina damage, etc.
/obj/item/melee/classic_baton/proc/additional_effects_non_cyborg(mob/living/target, mob/living/user)
	return

/// Contains any special effects that we apply to cyborgs we stun. Does not include flashing the cyborg's screen, hardstunning them, etc.
/obj/item/melee/classic_baton/proc/additional_effects_cyborg(mob/living/target, mob/living/user)
	return

/obj/item/melee/classic_baton/attack(mob/living/target, mob/living/user, params)
	if(!on)
		return ..()

	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		user.visible_message("<span class ='userdanger'>You accidentally hit yourself over the head with [src]!</span>", "<span class='danger'>[user] accidentally hits [user.p_them()]self over the head with [src]! What a doofus!</span>")

		if(iscyborg(user))
			if(affect_cyborg)
				user.flash_act(affect_silicon = TRUE)
				user.Paralyze(stun_time_cyborg * force)
				additional_effects_cyborg(user, user) // user is the target here
				playsound(get_turf(src), on_stun_sound, 100, TRUE, -1)
			else
				playsound(get_turf(src), 'sound/effects/bang.ogg', 10, TRUE)
		else
			user.Paralyze(knockdown_time * force)
			user.apply_damage(stamina_damage, STAMINA, BODY_ZONE_HEAD)
			additional_effects_non_cyborg(user, user) // user is the target here
			playsound(get_turf(src), on_stun_sound, 75, TRUE, -1)

		user.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)

		log_combat(user, target, "accidentally stun attacked [user.p_them()]self due to their clumsiness", src)
		if(stun_animation)
			user.do_attack_animation(user)
		return
	if(!isliving(target))
		return
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		..()
		return
	if(cooldown_check > world.time)
		var/wait_desc = get_wait_description()
		if (wait_desc)
			to_chat(user, wait_desc)
		return
	if(ishuman(target))
		var/mob/living/carbon/human/blocking_target = target
		if(blocking_target.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
			return
		if(blocking_target.check_block())
			blocking_target.visible_message(
				span_danger("[blocking_target.name] blocks [src] and twists [user]'s arm behind [user.p_their()] back!"),
				span_userdanger("You block the attack!")
			)
			user.Stun(40)
			return

	var/list/desc = get_stun_description(target, user)

	if(iscyborg(target))
		if(affect_cyborg)
			desc = get_cyborg_stun_description(target, user)

			target.flash_act(affect_silicon = TRUE)
			target.Paralyze(stun_time_cyborg)
			additional_effects_cyborg(target, user)

			playsound(get_turf(src), on_stun_sound, 75, TRUE, -1)
		else
			desc = get_unga_dunga_cyborg_stun_description(target, user)

			playsound(get_turf(src), 'sound/effects/bang.ogg', 10, TRUE) //bonk
	else
		target.Knockdown(knockdown_time)
		target.apply_damage(stamina_damage, STAMINA)
		additional_effects_non_cyborg(target, user)

		playsound(get_turf(src), on_stun_sound, 75, TRUE, -1)

	target.visible_message(desc["visible"], desc["local"])
	log_combat(user, target, "stun attacked", src)
	if(stun_animation)
		user.do_attack_animation(target)

	if(!iscarbon(user))
		target.LAssailant = null
	else
		target.LAssailant = WEAKREF(user)
	cooldown_check = world.time + cooldown
	return


/obj/item/conversion_kit
	name = "conversion kit"
	desc = "A strange box containing wood working tools and an instruction paper to turn stun batons into something else."
	icon = 'icons/obj/storage.dmi'
	icon_state = "uk"
	custom_price = PAYCHECK_HARD * 4.5

/obj/item/melee/classic_baton/telescopic
	name = "telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "telebaton_0"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	inhand_icon_state = null
	worn_icon_state = "tele_baton"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NONE
	force = 0
	on = FALSE
	on_sound = 'sound/weapons/batonextend.ogg'

	on_icon_state = "telebaton_1"
	off_icon_state = "telebaton_0"
	on_inhand_icon_state = "nullrod"
	force_on = 10
	force_off = 0
	weight_class_on = WEIGHT_CLASS_BULKY
	bare_wound_bonus = 5

/obj/item/melee/classic_baton/telescopic/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/brain/B = H.getorgan(/obj/item/organ/brain)

	user.visible_message(span_suicide("[user] stuffs [src] up [user.p_their()] nose and presses the 'extend' button! It looks like [user.p_theyre()] trying to clear [user.p_their()] mind."))
	if(!on)
		src.attack_self(user)
	else
		playsound(src, on_sound, 50, TRUE)
		add_fingerprint(user)
	sleep(3)
	if (!QDELETED(H))
		if(!QDELETED(B))
			H.internal_organs -= B
			qdel(B)
		new /obj/effect/gibspawner/generic(H.drop_location(), H)
		return (BRUTELOSS)

/obj/item/melee/classic_baton/telescopic/attack_self(mob/user)
	on = !on
	var/list/desc = get_on_description()

	if(on)
		to_chat(user, desc["local_on"])
		icon_state = on_icon_state
		inhand_icon_state = on_inhand_icon_state
		w_class = weight_class_on
		force = force_on
		attack_verb_continuous = list("smacks", "strikes", "cracks", "beats")
		attack_verb_simple = list("smack", "strike", "crack", "beat")
	else
		to_chat(user, desc["local_off"])
		icon_state = off_icon_state
		inhand_icon_state = null //no sprite for concealment even when in hand
		slot_flags = ITEM_SLOT_BELT
		w_class = WEIGHT_CLASS_SMALL
		force = force_off
		attack_verb_continuous = list("hits", "pokes")
		attack_verb_simple = list("hit", "poke")

	playsound(src.loc, on_sound, 50, TRUE)
	add_fingerprint(user)

/obj/item/melee/classic_baton/telescopic/contractor_baton
	name = "contractor baton"
	desc = "A compact, specialised baton assigned to Syndicate contractors. Applies light electrical shocks to targets."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "contractor_baton_0"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	inhand_icon_state = null
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NONE
	force = 5

	cooldown = 25
	stamina_damage = 85
	affect_cyborg = TRUE
	on_sound = 'sound/weapons/contractorbatonextend.ogg'
	on_stun_sound = 'sound/effects/contractorbatonhit.ogg'

	on_icon_state = "contractor_baton_1"
	off_icon_state = "contractor_baton_0"
	on_inhand_icon_state = "contractor_baton"
	force_on = 16
	force_off = 5
	weight_class_on = WEIGHT_CLASS_NORMAL

/obj/item/melee/classic_baton/telescopic/contractor_baton/get_wait_description()
	return span_danger("The baton is still charging!")

/obj/item/melee/classic_baton/telescopic/contractor_baton/additional_effects_non_cyborg(mob/living/target, mob/living/user)
	target.Jitter(20)
	target.stuttering += 20
