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
	w_class = WEIGHT_CLASS_BULKY // Balance thing, but lets just say it
	force = 3
	trigger_guard = TRIGGER_GUARD_NORMAL
	antimagic_flags = NONE
	can_hold_up = FALSE

	/// How much gold reagent we have in reserves. Affects the length of the Midas Blight debuff.
	var/gold_reagent = 1 SECONDS

/obj/item/gun/magic/midas_hand/examine(mob/user)
	. = ..()
	. += span_notice("Your next shot will inflict [min(30 SECONDS, round(gold_reagent, 0.1)) / 10] seconds of Midas Blight.")
	. += span_notice("Right-Click on enemies to drain gold from their bloodstreams to reload [src].")
	. += span_notice("[src] can be reloaded using gold coins in a pinch.")

/obj/item/gun/magic/midas_hand/shoot_with_empty_chamber(mob/living/user)
	. = ..()
	balloon_alert(user, "not enough gold")

// Siphon gold from a victim, recharging our gun & removing their Midas Blight debuff in the process.
/obj/item/gun/magic/midas_hand/afterattack_secondary(mob/living/victim, mob/living/user, proximity_flag, click_parameters)
	if(!isliving(victim) || !IN_GIVEN_RANGE(user, victim, GUNPOINT_SHOOTER_STRAY_RANGE))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!victim.reagents)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!victim.reagents.has_reagent(/datum/reagent/gold, check_subtypes = TRUE))
		balloon_alert(user, "no gold in bloodstream")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/gold_beam = user.Beam(victim, icon_state="drain_gold")
	if(!do_after(user, 1 SECONDS, victim))
		qdel(gold_beam)
		balloon_alert(user, "link broken")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	handle_gold_charges(user, victim.reagents.get_reagent_amount(/datum/reagent/gold, include_subtypes = TRUE))
	victim.reagents.remove_all_type(/datum/reagent/gold, victim.reagents.get_reagent_amount(/datum/reagent/gold, include_subtypes = TRUE))
	victim.remove_status_effect(/datum/status_effect/midas_blight)
	qdel(gold_beam)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

// If we botch a shot, we have to start over again by inserting gold coins into the gun. Can only be done if it has no charges or gold.
/obj/item/gun/magic/midas_hand/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(charges || gold_reagent)
		balloon_alert(user, "already loaded")
		return
	if(istype(I, /obj/item/coin/gold))
		handle_gold_charges(user, 10)
		qdel(I)

/// Handles recharging & inserting gold amount
/obj/item/gun/magic/midas_hand/proc/handle_gold_charges(user, gold_amount)
	gold_reagent += gold_amount
	balloon_alert(user, "siphoned [gold_amount]u gold")
	if(!charges)
		instant_recharge()

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
	color = "#FFD700"
	/// The gold charge in this pellet
	var/gold_charge = 0


/obj/projectile/magic/midas_round/fire(setAngle)
	/// Transfer the gold energy to our bullet
	var/obj/item/gun/magic/midas_hand/my_gun = fired_from
	gold_charge = my_gun.gold_reagent
	my_gun.gold_reagent = 0
	..()

// Gives human targets Midas Blight.
/obj/projectile/magic/midas_round/on_hit(atom/target)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/my_guy = target
		my_guy.apply_status_effect(/datum/status_effect/midas_blight, min(30 SECONDS, round(gold_charge, 0.1))) // 100u gives 10 seconds
		return

