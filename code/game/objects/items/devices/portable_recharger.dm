/obj/item/portable_recharger
	name = "backpack recharger"
	icon = 'icons/obj/rechargers.dmi'
	icon_state = "backcharger"
	base_icon_state = "backcharger"
	desc = "A portable backpack charging dock for energy based weaponry, PDAs, and other devices."
	inhand_icon_state = "backcharger"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_BULKY
	///Our power cell
	var/obj/item/stock_parts/cell/cell
	///What item is being charged currently?
	var/obj/item/charging = null
	///Did we put power into "charging" last process()?
	var/using_power = FALSE
	///Did we finish recharging the currently inserted item?
	var/finished_recharging = FALSE
	///The sound that it makes while charging
	var/datum/looping_sound/recharger/soundloop
	///Was it hit?
	var/hit = FALSE
	///What is the chance of it malfunctioning when shot or EMP'd?
	var/malf_chance = 5

	var/static/list/allowed_devices = typecacheof(list(
		/obj/item/gun/energy,
		/obj/item/melee/baton/security,
		/obj/item/ammo_box/magazine/recharge,
		/obj/item/modular_computer,
	))

/obj/item/portable_recharger/get_cell()
	return cell

/obj/item/portable_recharger/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/drag_pickup)
	soundloop = new(src)
	update_appearance()

/obj/item/portable_recharger/loaded/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/cell/high(src)

/obj/item/portable_recharger/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/item/portable_recharger/equipped(mob/user, slot, initial)
	. = ..()
	if(slot & (ITEM_SLOT_BACK|ITEM_SLOT_BELT))
		RegisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(on_attacked))
	else
		UnregisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS)
		return

/obj/item/portable_recharger/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS)

/obj/item/portable_recharger/CheckParts(list/parts_list)
	..()
	cell = locate(/obj/item/stock_parts/cell) in contents

/obj/item/portable_recharger/examine(mob/user)
	. = ..()
	if(hit)
		. += span_boldwarning("ITS GONNA EXPLODE!!")
	else
		. += span_danger("<b>DANGER:</b> Damaging the portable charger or putting it under EMP may result in explosion!")

	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return

	var/cell_charge = cell.percent()

	if(cell)
		. += span_notice("The recharger [cell] has [cell_charge]% charge left.")

	if(charging)
		. += {"[span_notice("\The [src] contains:")]
		[span_notice("- \A [charging].")]"}

	var/status_display_message_shown = FALSE
	if(using_power)
		status_display_message_shown = TRUE
		. += span_notice("The status display reads:")

	if(isnull(charging))
		return
	if(!status_display_message_shown)
		. += span_notice("The status display reads:")

	var/obj/item/stock_parts/cell/charging_cell = charging.get_cell()
	if(charging_cell)
		. += span_notice("- \The [charging]'s cell is at <b>[charging_cell.percent()]%</b>.")
		return
	if(istype(charging, /obj/item/ammo_box/magazine/recharge))
		var/obj/item/ammo_box/magazine/recharge/power_pack = charging
		. += span_notice("- \The [charging]'s cell is at <b>[PERCENT(power_pack.stored_ammo.len/power_pack.max_ammo)]%</b>.")
		return
	. += span_notice("- \The [charging] is not reporting a power level.")

/obj/item/portable_recharger/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(is_type_in_typecache(arrived, allowed_devices))
		charging = arrived
		START_PROCESSING(SSmachines, src)
		finished_recharging = FALSE
		using_power = TRUE
		soundloop.start()
		update_appearance()
	return ..()

/obj/item/portable_recharger/Exited(atom/movable/gone, direction)
	if(gone == charging)
		if(!QDELING(charging))
			charging.update_appearance()
		charging = null
		using_power = FALSE
		soundloop.stop()
		update_appearance()
	if(gone == cell)
		cell = null
	return ..()

/obj/item/portable_recharger/attackby(obj/item/attacking_item, mob/user, params)
	if(hit)
		return

	if(istype(attacking_item, /obj/item/stock_parts/cell))
		if(cell)
			balloon_alert(user, "already loaded!")
		else
			if(!user.transferItemToLoc(attacking_item, src))
				return TRUE
			cell = attacking_item
			balloon_alert(user, "installed")

	if(isnull(cell))
		balloon_alert(user, "no cell!")
		return ..()

	if(!is_type_in_typecache(attacking_item, allowed_devices))
		return ..()

	if(charging)
		return TRUE

	if(!cell.charge)
		balloon_alert(user, "no charge!")
		return TRUE

	if(istype(attacking_item, /obj/item/gun/energy))
		var/obj/item/gun/energy/energy_gun = attacking_item
		if(!energy_gun.can_charge)
			balloon_alert(user, "not rechargable!")
			return TRUE
	user.transferItemToLoc(attacking_item, src)
	return TRUE

/obj/item/portable_recharger/screwdriver_act(mob/living/user, obj/item/tool)
	if(!cell || charging || hit)
		return FALSE

	if(do_after(user, 3 SECONDS, target = src))
		cell.update_appearance()
		cell.forceMove(get_turf(src))
		balloon_alert(user, "removed [cell]")
		cell = null
		tool.play_tool_sound(src, 50)
		return TRUE
	return FALSE

/obj/item/portable_recharger/attack_hand(mob/user, list/modifiers)
	if(loc == user)
		if(user.get_slot_by_item(src) & slot_flags)
			take_charging_out(user)
		else
			balloon_alert(user, "equip it first!")
		return TRUE

	add_fingerprint(user)
	return ..()

///Takes charging item out if there is one
/obj/item/portable_recharger/proc/take_charging_out(mob/user)
	if(isnull(charging) || user.put_in_hands(charging))
		return
	charging.forceMove(drop_location())

/obj/item/portable_recharger/attack_tk(mob/user)
	if(isnull(charging))
		return
	charging.forceMove(drop_location())
	return COMPONENT_CANCEL_ATTACK_CHAIN

///Blows up the cell in it
/obj/item/portable_recharger/proc/detonate()
	if(!cell)
		return

	cell.explode()

	charging?.forceMove(drop_location())
	qdel(src)

///Makes the recharger blow up after some time
/obj/item/portable_recharger/proc/malfunction/(mob/living/carbon/user, atom/movable/hitby)
	if(!cell || hit)
		return

	if(hitby)
		user.log_message("[src] power cell detonated by a projectile ([hitby])", LOG_GAME)
	else
		user.log_message("[src] power cell detonated by a EMP", LOG_GAME)

	user.audible_message(span_danger("[src] on [user] starts to fuss and blare alarms violently!"))
	to_chat(user, span_userdanger("[src] starts to heat up!"))
	playsound(src, 'sound/effects/fuse.ogg', 80, TRUE)
	playsound(src, 'sound/machines/terminal_alert.ogg', 40, FALSE)
	hit = TRUE
	addtimer(CALLBACK(src, PROC_REF(detonate)), 5 SECONDS)
	soundloop.stop()
	update_appearance()

///Calls in when COMSIG_HUMAN_CHECK_SHIELDS signal fires.
///So this happens when the user gets attacked.
/obj/item/portable_recharger/proc/on_attacked(
	mob/living/carbon/user,
	atom/movable/hitby,
	damage = 0,
	attack_text = "the attack",
	attack_type = MELEE_ATTACK,
	armour_penetration = 0,
	damage_type = BRUTE,
)
	SIGNAL_HANDLER

	if((damage > 10) && (attack_type == PROJECTILE_ATTACK) && (damage_type != STAMINA) && (prob(malf_chance)))
		malfunction(user, hitby)

/obj/item/portable_recharger/process(seconds_per_tick)
	using_power = FALSE
	if(isnull(charging))
		return PROCESS_KILL
	var/obj/item/stock_parts/cell/charging_cell = charging.get_cell()
	if(charging_cell)
		if(charging_cell.charge < charging_cell.maxcharge)
			charging_cell.give(charging_cell.chargerate * seconds_per_tick / 2)
			cell.use(charging_cell.charge * seconds_per_tick / 2)
			using_power = TRUE
		update_appearance()

	if(istype(charging, /obj/item/ammo_box/magazine/recharge)) //if you add any more snowflake ones, make sure to update the examine messages too.
		var/obj/item/ammo_box/magazine/recharge/power_pack = charging
		if(power_pack.stored_ammo.len < power_pack.max_ammo)
			power_pack.stored_ammo += new power_pack.ammo_type(power_pack)
			cell.use(charging_cell.charge)
			using_power = TRUE
		update_appearance()
		return
	if(!using_power && !finished_recharging) //Inserted thing is at max charge/ammo, notify those around us
		finished_recharging = TRUE
		playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
		say("[charging] has finished recharging!")

/obj/item/portable_recharger/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_CONTENTS)
		return

	if(ishuman(loc))
		var/mob/living/carbon/human/holder = loc
		if(prob(malf_chance) || !EMP_PROTECT_SELF)
			malfunction(holder)
			return

	cell?.emp_act(severity)

	if(istype(charging, /obj/item/gun/energy))
		var/obj/item/gun/energy/energy_gun = charging
		energy_gun?.cell.emp_act(severity)

	else if(istype(charging, /obj/item/melee/baton/security))
		var/obj/item/melee/baton/security/batong = charging
		batong?.cell.charge = 0

/obj/item/portable_recharger/update_overlays()
	. = ..()

	var/icon_to_use = "[base_icon_state]-[isnull(charging) ? "empty" : (using_power ? "charging" : "full")]"
	if(hit)
		. += mutable_appearance(icon, "[base_icon_state]-hit", alpha = src.alpha)
		. += emissive_appearance(icon, "[base_icon_state]-hit", src, alpha = src.alpha)
		return
	. += mutable_appearance(icon, icon_to_use, alpha = src.alpha)
	. += emissive_appearance(icon, icon_to_use, src, alpha = src.alpha)

/obj/item/portable_recharger/belt
	name = "belt recharger"
	icon_state = "beltcharger"
	base_icon_state = "beltcharger"
	desc = "A portable belt charging dock for energy based weaponry, PDAs, and other devices. Due its design its slightly more volatile."
	inhand_icon_state = "beltcharger"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	malf_chance = 10 //More convient to wear, but riskier

/obj/item/portable_recharger/belt/loaded/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/cell/high(src)

/obj/item/portable_recharger/belt/badass
	name = "badass belt recharger"
	icon_state = "badasscharger"
	base_icon_state = "badasscharger"
	desc = "A portable belt charging dock for energy based weaponry, PDAs, and other devices. This one will allow you to spin your guns."
	inhand_icon_state = "badasscharger"
	alternate_worn_layer = UNDER_SUIT_LAYER

/obj/item/portable_recharger/belt/badass/equipped(mob/user, slot, initial)
	. = ..()
	ADD_TRAIT(user, TRAIT_GUNFLIP, CLOTHING_TRAIT)

/obj/item/portable_recharger/belt/badass/dropped(mob/user, silent)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_GUNFLIP, CLOTHING_TRAIT)

/obj/item/portable_recharger/belt/badass/loaded/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/cell/high(src)
