/obj/item/gun/water
	name = "donksoft hyper-soaker"
	desc = "Harmless fun, unless you're allergic to water."
	icon = 'icons/obj/weapons/guns/water.dmi'
	icon_state = "water"
	inhand_icon_state = "water"
	w_class = WEIGHT_CLASS_NORMAL
	clumsy_check = 0 // we do a little trolling
	fire_sound = 'sound/effects/spray2.ogg'
	var/reagent_volume = 250
	var/transfer_volume = 10
	var/ammo_type = /obj/item/ammo_casing/reagent/water

/obj/item/gun/water/syndicate
	reagent_volume = 600
	transfer_volume = 30

/obj/item/gun/water/Initialize(mapload)
	. = ..()
	create_reagents(reagent_volume, REFILLABLE|DRAINABLE|AMOUNT_VISIBLE)

/// Pre-filled version
/obj/item/gun/water/full/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/water, reagent_volume)

/obj/item/gun/water/examine(mob/user)
	. = ..()
	. += "Alt-click to empty its contents onto the floor."

/obj/item/gun/water/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(istype(target, /obj/structure/reagent_dispensers))
		var/trans_amount = target.reagents.trans_to(src, reagent_volume)
		if(trans_amount)
			to_chat(user, span_notice("You refill [src] from [target]."))
	else if(target.is_refillable())
		var/trans_amount = reagents.trans_to(target, 10)
		if(trans_amount)
			to_chat(user, span_notice("You transfer [trans_amount] units to [target]."))

/obj/item/gun/water/can_shoot()
	return (reagents.total_volume > 1)

/obj/item/gun/water/recharge_newshot()
	chambered = new ammo_type(src)
	chambered.newshot(transfer_volume)

/obj/item/gun/water/process_chamber()
	chambered = null
	recharge_newshot()

/obj/item/gun/water/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread, cd_override)
	if(!chambered && can_shoot())
		process_chamber()	// If the gun was drained and then recharged, load a new shot.
	if(reagent_check())
		return
	return ..()

/obj/item/gun/water/process_burst(mob/living/user, atom/target, message, params, zone_override, sprd, randomized_gun_spread, randomized_bonus_spread, rand_spr, iteration)
	if(!chambered && can_shoot())
		process_chamber()	// If the gun was drained and then recharged, load a new shot.
	if(reagent_check())
		return
	return ..()

/obj/item/gun/water/proc/reagent_check()
	var/atom/starting_loc = loc
	if(QDELETED(src))
		return TRUE
	if(loc != starting_loc)
		reagents.clear_reagents()
		if(chambered)
			qdel(chambered)
			chambered = null
		return TRUE // the gun broke or moved so you didn't actually get to shoot it

// overlay for water levels
/obj/item/gun/water/update_overlays()
	. = ..()
	var/water_state = ROUND_UP(5 * reagents.total_volume / reagents.maximum_volume)
	if(!water_state)
		return .
	var/mutable_appearance/water_overlay = mutable_appearance(icon, "water-tank[water_state]")
	. += water_overlay
