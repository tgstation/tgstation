//the NON-stunbaton batons.
//this has the
//* police baton
//* telescopic baton
//* contractor baton

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

	var/cooldown = 40 // Default wait time until can stun again.
	var/knockdown_time_carbon = (1.5 SECONDS) // Knockdown length for carbons.
	var/stun_time_silicon = (5 SECONDS) // If enabled, how long do we stun silicons.
	var/stamina_damage = 55 // Do we deal stamina damage.
	var/affect_silicon = FALSE // Does it stun silicons.
	var/on_sound // "On" sound, played when switching between able to stun or not.
	var/on_stun_sound = 'sound/effects/woodhit.ogg' // Default path to sound for when we stun.
	var/stun_animation = TRUE // Do we animate the "hit" when stunning.
	var/on = TRUE // Are we on or off.

	var/on_icon_state // What is our sprite when turned on
	var/off_icon_state // What is our sprite when turned off
	var/on_inhand_icon_state // What is our in-hand sprite when turned on
	var/force_on // Damage when on - not stunning
	var/force_off // Damage when off - not stunning
	var/weight_class_on // What is the new size class when turned on

	wound_bonus = 15

// Description for trying to stun when still on cooldown.
/obj/item/melee/classic_baton/proc/get_wait_description()
	return

// Description for when turning their baton "on"
/obj/item/melee/classic_baton/proc/get_on_description()
	. = list()

	.["local_on"] = "<span class ='warning'>You extend the baton.</span>"
	.["local_off"] = "<span class ='notice'>You collapse the baton.</span>"

	return .

// Default message for stunning mob.
/obj/item/melee/classic_baton/proc/get_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] =  "<span class ='danger'>[user] knocks [target] down with [src]!</span>"
	.["local"] = "<span class ='userdanger'>[user] knocks you down with [src]!</span>"

	return .

// Default message for stunning a silicon.
/obj/item/melee/classic_baton/proc/get_silicon_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = "<span class='danger'>[user] pulses [target]'s sensors with the baton!</span>"
	.["local"] = "<span class='danger'>You pulse [target]'s sensors with the baton!</span>"

	return .

// Are we applying any special effects when we stun to carbon
/obj/item/melee/classic_baton/proc/additional_effects_carbon(mob/living/target, mob/living/user)
	return

// Are we applying any special effects when we stun to silicon
/obj/item/melee/classic_baton/proc/additional_effects_silicon(mob/living/target, mob/living/user)
	return

/obj/item/melee/classic_baton/attack_alt(mob/living/target, mob/living/user, params)
	. = ALT_ATTACK_CANCEL_ATTACK_CHAIN //right click never harmbatons
	if(!on)
		return
	if(cooldown_check > world.time)
		var/wait_desc = get_wait_description()
		if (wait_desc)
			to_chat(user, wait_desc)
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if (H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
			return
		if(check_martial_counter(H, user))
			return

	var/list/desc = get_stun_description(target, user)
	if(stun_animation)
		user.do_attack_animation(target)

	playsound(get_turf(src), on_stun_sound, 75, TRUE, -1)
	target.Knockdown(knockdown_time_carbon)
	target.apply_damage(stamina_damage, STAMINA, BODY_ZONE_CHEST)
	additional_effects_carbon(target, user)

	log_combat(user, target, "stunned", src)
	add_fingerprint(user)

	target.visible_message(desc["visible"], desc["local"])

	if(!iscarbon(user))
		target.LAssailant = null
	else
		target.LAssailant = user
	cooldown_check = world.time + cooldown

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

	user.visible_message("<span class='suicide'>[user] stuffs [src] up [user.p_their()] nose and presses the 'extend' button! It looks like [user.p_theyre()] trying to clear [user.p_their()] mind.</span>")
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
	affect_silicon = TRUE
	on_sound = 'sound/weapons/contractorbatonextend.ogg'
	on_stun_sound = 'sound/effects/contractorbatonhit.ogg'

	on_icon_state = "contractor_baton_1"
	off_icon_state = "contractor_baton_0"
	on_inhand_icon_state = "contractor_baton"
	force_on = 16
	force_off = 5
	weight_class_on = WEIGHT_CLASS_NORMAL

/obj/item/melee/classic_baton/telescopic/contractor_baton/get_wait_description()
	return "<span class='danger'>The baton is still charging!</span>"

/obj/item/melee/classic_baton/telescopic/contractor_baton/additional_effects_carbon(mob/living/target, mob/living/user)
	target.Jitter(20)
	target.stuttering += 20

/obj/item/melee/supermatter_sword
	name = "supermatter sword"
	desc = "In a station full of bad ideas, this might just be the worst."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "supermatter_sword"
	inhand_icon_state = "supermatter_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = null
	w_class = WEIGHT_CLASS_BULKY
	force = 0.001
	armour_penetration = 1000
	var/obj/machinery/power/supermatter_crystal/shard
	var/balanced = 1
	force_string = "INFINITE"
