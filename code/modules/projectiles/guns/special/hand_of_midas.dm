// Hand of Midas

/obj/item/gun/magic/midas_hand
	name = "The Hand of Midas"
	desc = "An ancient Egyptian matchlock pistol imbued with the powers of the Greek King Midas. Don't question the cultural or religious implications of this."
	ammo_type = /obj/item/ammo_casing/magic/midas_round
	icon_state = "midas_hand"
	inhand_icon_state = "gun"
	worn_icon_state = "gun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	fire_sound = 'sound/weapons/gun/rifle/shot.ogg'
	pinless = TRUE
	max_charges = 1
	can_charge = FALSE
	item_flags = NEEDS_PERMIT
	w_class = WEIGHT_CLASS_BULKY // Should fit on a belt.
	force = 3
	trigger_guard = TRIGGER_GUARD_NORMAL
	antimagic_flags = NONE
	can_hold_up = FALSE

	/// The length of the Midas Blight debuff, dependant on the amount of gold reagent we've sucked up.
	var/gold_timer = 3 SECONDS
	/// The range that we can suck gold out of people's bodies
	var/gold_suck_range = 2

/obj/item/gun/magic/midas_hand/examine(mob/user)
	. = ..()
	var/gold_time_converted = gold_time_convert()
	. += span_notice("Your next shot will inflict [gold_time_converted] second[gold_time_converted == 1 ? "" : "s"] of Midas Blight.")
	. += span_notice("Right-Click on enemies to drain gold from their bloodstreams to reload [src].")
	. += span_notice("[src] can be reloaded using gold coins in a pinch.")

/obj/item/gun/magic/midas_hand/shoot_with_empty_chamber(mob/living/user)
	. = ..()
	balloon_alert(user, "not enough gold")

// Siphon gold from a victim, recharging our gun & removing their Midas Blight debuff in the process.
/obj/item/gun/magic/midas_hand/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return ITEM_INTERACT_BLOCKING
	return suck_gold(interacting_with, user)

/obj/item/gun/magic/midas_hand/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with) || !IN_GIVEN_RANGE(user, interacting_with, gold_suck_range))
		return ITEM_INTERACT_BLOCKING
	return suck_gold(interacting_with, user)

/obj/item/gun/magic/midas_hand/proc/suck_gold(mob/living/victim, mob/living/user)
	if(victim == user)
		balloon_alert(user, "can't siphon from self!")
		return ITEM_INTERACT_BLOCKING
	if(!victim.reagents)
		return ITEM_INTERACT_BLOCKING
	var/gold_amount = victim.reagents.get_reagent_amount(/datum/reagent/gold, type_check = REAGENT_SUB_TYPE)
	if(!gold_amount)
		balloon_alert(user, "no gold in bloodstream!")
		return ITEM_INTERACT_BLOCKING
	var/gold_beam = user.Beam(victim, icon_state = "drain_gold")
	if(!do_after(
		user = user,
		delay = 1 SECONDS,
		target = victim,
		timed_action_flags = (IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE),
		extra_checks = CALLBACK(src, PROC_REF(check_gold_range), user, victim),
	))
		qdel(gold_beam)
		balloon_alert(user, "link broken!")
		return ITEM_INTERACT_BLOCKING
	handle_gold_charges(user, gold_amount)
	victim.reagents.remove_reagent(/datum/reagent/gold, gold_amount, include_subtypes = TRUE)
	victim.remove_status_effect(/datum/status_effect/midas_blight)
	qdel(gold_beam)
	return ITEM_INTERACT_SUCCESS

// If we botch a shot, we have to start over again by inserting gold coins into the gun. Can only be done if it has no charges or gold.
/obj/item/gun/magic/midas_hand/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(charges || gold_timer)
		balloon_alert(user, "already loaded")
		return
	if(istype(I, /obj/item/coin/gold))
		handle_gold_charges(user, 1.5 SECONDS)
		qdel(I)

/// Handles recharging & inserting gold amount
/obj/item/gun/magic/midas_hand/proc/handle_gold_charges(user, gold_amount)
	gold_timer += gold_amount
	var/gold_time_converted = gold_time_convert()
	balloon_alert(user, "[gold_time_converted] second[gold_time_converted == 1 ? "" : "s"]")
	if(!charges)
		instant_recharge()

/// Converts our gold_timer to time in seconds, for various ballons/examines
/obj/item/gun/magic/midas_hand/proc/gold_time_convert()
	return min(30 SECONDS, round(gold_timer, 0.2)) / 10

/// Checks our range to the person we're sucking gold out of. Double the initial range, so you need to get in close to start.
/obj/item/gun/magic/midas_hand/proc/check_gold_range(mob/living/user, mob/living/victim)
	return IN_GIVEN_RANGE(user, victim, gold_suck_range*2)

/obj/item/ammo_casing/magic/midas_round
	projectile_type = /obj/projectile/magic/midas_round


/obj/projectile/magic/midas_round
	name = "gold pellet"
	desc = "A typical flintlock ball, save for the fact it's made of cursed Egyptian gold."
	damage_type = BRUTE
	damage = 10
	stamina = 20
	armour_penetration = 50
	hitsound = 'sound/effects/coin2.ogg'
	icon_state = "pellet"
	color = COLOR_GOLD
	/// The gold charge in this pellet
	var/gold_charge = 0


/obj/projectile/magic/midas_round/fire(setAngle)
	/// Transfer the gold energy to our bullet
	var/obj/item/gun/magic/midas_hand/my_gun = fired_from
	gold_charge = my_gun.gold_timer
	my_gun.gold_timer = 0
	..()

// Gives human targets Midas Blight.
/obj/projectile/magic/midas_round/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/my_guy = target
		if(isskeleton(my_guy)) // No cheap farming
			return
		my_guy.apply_status_effect(/datum/status_effect/midas_blight, min(30 SECONDS, round(gold_charge, 0.2))) // 100u gives 10 seconds
		return

/obj/item/gun/magic/midas_hand/suicide_act(mob/living/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/victim = user
	victim.visible_message(span_suicide("[victim] holds the barrel of [src] to [victim.p_their()] head, lighting the fuse. It looks like [user.p_theyre()] trying to commit suicide!"))
	if(!do_after(victim, 1.5 SECONDS))
		return
	playsound(src, 'sound/weapons/gun/rifle/shot.ogg', 75, TRUE)
	to_chat(victim, span_danger("You don't even have the time to register the gunshot by the time your body has completely converted into a golden statue."))
	var/newcolors = list(rgb(206, 164, 50), rgb(146, 146, 139), rgb(28,28,28), rgb(0,0,0))
	victim.petrify(statue_timer = INFINITY, save_brain = FALSE, colorlist = newcolors)
	playsound(victim, 'sound/effects/coin2.ogg', 75, TRUE)
	charges = 0
	gold_timer = 0
	return OXYLOSS
