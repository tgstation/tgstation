/obj/item/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon = 'icons/obj/guns/energy.dmi'

	///sound when inserting cell
	var/load_sound = 'sound/weapons/gun/general/magazine_insert_full.ogg'
	///sound when inserting an empty magazine
	var/load_empty_sound = "buzz-sigh.ogg"
	///volume of loading sound
	var/load_sound_volume = 40
	///whether loading sound should vary
	var/load_sound_vary = TRUE

	///Sound of ejecting a magazine
	var/eject_sound = 'sound/weapons/gun/general/magazine_remove_full.ogg'
	///sound of ejecting an empty magazine
	var/eject_empty_sound = 'sound/weapons/gun/general/magazine_remove_empty.ogg'
	///volume of ejecting a magazine
	var/eject_sound_volume = 40
	///whether eject sound should vary
	var/eject_sound_vary = TRUE

	///empty alarm sound (if enabled)
	var/empty_alarm_sound = 'sound/weapons/gun/general/empty_alarm.ogg'
	///empty alarm volume sound
	var/empty_alarm_volume = 70
	///whether empty alarm sound varies
	var/empty_alarm_vary = TRUE

	///Whether the gun alarms when empty or not.
	var/empty_alarm = FALSE
	///Whether the gun is currently alarmed to prevent it from spamming sounds
	var/alarmed = FALSE

	///Maximum cell charge an unloadable gun will accept; 1000 by default.
	var/max_accept = 1000
	///Where the cell can accept self-charging cells.
	var/self_charge_allowed = FALSE

	///Whether the gun's cell can be unloaded
	var/can_unload = FALSE
	///Time it takes to load in deciseconds
	var/load_time = 40
	///Time it takes to unload in deciseconds
	var/unload_time = 0

	var/obj/item/stock_parts/cell/cell //What type of power cell this uses
	var/cell_type = /obj/item/stock_parts/cell
	var/modifystate = 0
	var/list/ammo_type = list(/obj/item/ammo_casing/energy)
	var/select = 1 //The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.
	var/can_charge = TRUE //Can it be charged in a recharger?
	var/automatic_charge_overlays = TRUE	//Do we handle overlays with base update_icon()?
	var/charge_sections = 4
	ammo_x_offset = 2
	var/shaded_charge = FALSE //if this gun uses a stateful charge bar for more detail
	var/old_ratio = 0 // stores the gun's previous ammo "ratio" to see if it needs an updated icon
	var/selfcharge = 0
	var/charge_tick = 0
	var/charge_delay = 4
	var/use_cyborg_cell = FALSE //whether the gun's cell drains the cyborg user's cell to recharge
	var/dead_cell = FALSE //set to true so the gun is given an empty cell

	var/obj/item/cell_cartridge/cartridge //What type of power cell this uses
	var/cartridge_type = /obj/item/cell_cartridge
	var/uses_cartridge = FALSE //If this gun uses cell cartridges

/obj/item/gun/energy/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS))
		cell.use(round(cell.charge / severity))
		chambered = null //we empty the chamber
		recharge_newshot() //and try to charge a new shot
		update_icon()

/obj/item/gun/energy/get_cell()
	return cell

/obj/item/gun/energy/Initialize()
	. = ..()
	if(uses_cartridge)
		cartridge = new cartridge_type
		if(cell_type && !cartridge.cell)
			cartridge.cell = new cell_type(src)

		else
			cartridge.cell = new(src)
		cell = cartridge.cell

	else if(cell_type)
		cell = new cell_type(src)
	else
		cell = new(src)
	if(!dead_cell)
		cell.give(cell.maxcharge)
	update_ammo_types()
	recharge_newshot(TRUE)
	if(selfcharge)
		START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/gun/energy/proc/update_ammo_types()
	var/obj/item/ammo_casing/energy/shot
	for (var/i = 1, i <= ammo_type.len, i++)
		var/shottype = ammo_type[i]
		shot = new shottype(src)
		ammo_type[i] = shot
	shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay

/obj/item/gun/energy/Destroy()
	if (cell)
		QDEL_NULL(cell)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/energy/process()
	if(selfcharge && cell && cell.percent() < 100)
		charge_tick++
		if(charge_tick < charge_delay)
			return
		charge_tick = 0
		cell.give(100)
		if(!chambered) //if empty chamber we try to charge a new shot
			recharge_newshot(TRUE)
		update_icon()

/obj/item/gun/energy/attack_self(mob/living/user as mob)
	if(ammo_type.len > 1)
		select_fire(user)
		update_icon()

/obj/item/gun/energy/can_shoot()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	return !QDELETED(cell) ? (cell.charge >= shot.e_cost) : FALSE

/obj/item/gun/energy/recharge_newshot(no_cyborg_drain)
	if (!ammo_type || !cell)
		return
	if(use_cyborg_cell && !no_cyborg_drain)
		if(iscyborg(loc))
			var/mob/living/silicon/robot/R = loc
			if(R.cell)
				var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
				if(R.cell.use(shot.e_cost)) 		//Take power from the borg...
					cell.give(shot.e_cost)	//... to recharge the shot
	if(!chambered)
		var/obj/item/ammo_casing/energy/AC = ammo_type[select]
		if(cell.charge >= AC.e_cost) //if there's enough power in the cell cell...
			chambered = AC //...prepare a new shot based on the current ammo type selected
			if(!chambered.BB)
				chambered.newshot()

/obj/item/gun/energy/process_chamber()
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/energy/shot = chambered
		cell.use(shot.e_cost)//... drain the cell cell
	chambered = null //either way, released the prepared shot
	recharge_newshot() //try to charge a new shot

/obj/item/gun/energy/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(!chambered && can_shoot())
		process_chamber()	// If the gun was drained and then recharged, load a new shot.
	return ..()

/obj/item/gun/energy/process_burst(mob/living/user, atom/target, message = TRUE, params = null, zone_override="", sprd = 0, randomized_gun_spread = 0, randomized_bonus_spread = 0, rand_spr = 0, iteration = 0)
	if(!chambered && can_shoot())
		process_chamber()	// Ditto.
	return ..()

/obj/item/gun/energy/proc/select_fire(mob/living/user)
	select++
	if (select > ammo_type.len)
		select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if (shot.select_name)
		to_chat(user, "<span class='notice'>[src] is now set to [shot.select_name].</span>")
	chambered = null
	recharge_newshot(TRUE)
	update_icon(TRUE)
	return

/obj/item/gun/energy/update_icon(force_update, mob/user)
	if(QDELETED(src))
		return
	..()
	if(!automatic_charge_overlays)
		return
	var/charge = 0
	var/maxcharge = 1
	if(cell)
		charge = cell.charge
		maxcharge = cell.maxcharge
	var/ratio = CEILING(CLAMP(charge / maxcharge, 0, 1) * charge_sections, 1)
	if(ratio == old_ratio && !force_update)
		return
	old_ratio = ratio
	cut_overlays()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	var/iconState = "[icon_state]_charge"
	var/itemState = null
	if(!initial(item_state))
		itemState = icon_state
	if (modifystate)
		add_overlay("[icon_state]_[shot.select_name]")
		iconState += "_[shot.select_name]"
		if(itemState)
			itemState += "[shot.select_name]"
	if(charge < shot.e_cost)
		add_overlay("[icon_state]_empty")
	else
		if(!shaded_charge)
			var/mutable_appearance/charge_overlay = mutable_appearance(icon, iconState)
			for(var/i = ratio, i >= 1, i--)
				charge_overlay.pixel_x = ammo_x_offset * (i - 1)
				charge_overlay.pixel_y = ammo_y_offset * (i - 1)
				add_overlay(charge_overlay)
		else
			add_overlay("[icon_state]_charge[ratio]")
	if(itemState)
		itemState += "[ratio]"
		item_state = itemState
	if(user)
		user.update_inv_hands()

/obj/item/gun/energy/suicide_act(mob/living/user)
	if (istype(user) && can_shoot() && can_trigger_gun(user) && user.get_bodypart(BODY_ZONE_HEAD))
		user.visible_message("<span class='suicide'>[user] is putting the barrel of [src] in [user.p_their()] mouth.  It looks like [user.p_theyre()] trying to commit suicide!</span>")
		sleep(25)
		if(user.is_holding(src))
			user.visible_message("<span class='suicide'>[user] melts [user.p_their()] face off with [src]!</span>")
			playsound(loc, fire_sound, 50, TRUE, -1)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select]
			cell.use(shot.e_cost)
			update_icon()
			return(FIRELOSS)
		else
			user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
			return(OXYLOSS)
	else
		user.visible_message("<span class='suicide'>[user] is pretending to melt [user.p_their()] face off with [src]! It looks like [user.p_theyre()] trying to commit suicide!</b></span>")
		playsound(src, dry_fire_sound, 30, TRUE)
		return (OXYLOSS)


/obj/item/gun/energy/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("selfcharge")
			if(var_value)
				START_PROCESSING(SSobj, src)
			else
				STOP_PROCESSING(SSobj, src)
	. = ..()


/obj/item/gun/energy/ignition_effect(atom/A, mob/living/user)
	if(!can_shoot() || !ammo_type[select])
		if (!alarmed && empty_alarm)
			playsound(src, empty_alarm_sound, empty_alarm_volume, empty_alarm_vary)
			alarmed = TRUE
			update_icon()
		shoot_with_empty_chamber()
		. = ""
	else
		var/obj/item/ammo_casing/energy/E = ammo_type[select]
		var/obj/item/projectile/energy/BB = E.BB
		if(!BB)
			. = ""
		else if(BB.nodamage || !BB.damage || BB.damage_type == STAMINA)
			user.visible_message("<span class='danger'>[user] tries to light [user.p_their()] [A.name] with [src], but it doesn't do anything. Dumbass.</span>")
			playsound(user, E.fire_sound, 50, TRUE)
			playsound(user, BB.hitsound, 50, TRUE)
			cell.use(E.e_cost)
			. = ""
		else if(BB.damage_type != BURN)
			user.visible_message("<span class='danger'>[user] tries to light [user.p_their()] [A.name] with [src], but only succeeds in utterly destroying it. Dumbass.</span>")
			playsound(user, E.fire_sound, 50, TRUE)
			playsound(user, BB.hitsound, 50, TRUE)
			cell.use(E.e_cost)
			qdel(A)
			. = ""
		else
			playsound(user, E.fire_sound, 50, TRUE)
			playsound(user, BB.hitsound, 50, TRUE)
			cell.use(E.e_cost)
			. = "<span class='danger'>[user] casually lights their [A.name] with [src]. Damn.</span>"

/obj/item/gun/energy/afterattack()
	. = ..() //The gun actually firing
	postfire_empty_checks()

///postfire empty checks for sound alarms
/obj/item/gun/energy/proc/postfire_empty_checks()
	if (!can_shoot() || !ammo_type[select])
		if (!alarmed && empty_alarm)
			playsound(src, empty_alarm_sound, empty_alarm_volume, empty_alarm_vary)
			alarmed = TRUE
			update_icon()

/obj/item/gun/energy/proc/eject_cartridge(mob/user, display_message = TRUE, replace_cell = FALSE)
	if(!can_unload) //Sanity check
		return
	if(!cartridge) //Sanity check
		return
	var/obj/item/cell_cartridge/C = cartridge
	if(unload_time)
		to_chat(user, "<span class='warning'>You start ejecting \the [C]...</span>")
		if(!do_after(user, unload_time, target = user)) //Slight delay before the cell is unloaded; must stand still.
			to_chat(user, "<span class='warning'>You stop ejecting \the [C].</span>")
			return
	C.forceMove(drop_location())
	user.put_in_hands(C)
	C.update_icon()
	if(C.cell)
		if (C.cell.charge)
			playsound(src, load_sound, load_sound_volume, load_sound_vary)
		else
			playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
	else
		playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
	cell = null
	cartridge = null
	if (display_message)
		to_chat(user, "<span class='warning'>You pull [C] out of \the [src].</span>")
	update_icon(TRUE, user)

/obj/item/gun/energy/proc/load_cartridge(obj/item/cell_cartridge/C, mob/user)
	if(load_time)
		to_chat(user, "<span class='warning'>You start loading \the [C] into \the [src].</span>")
		if(!do_after(user, load_time, target = user)) //Slight delay before the cell is loaded; must stand still.
			to_chat(user, "<span class='warning'>You stop loading \the [C] into \the [src].</span>")
			return
	if(!user.transferItemToLoc(C, src))
		return
	cartridge = C
	var/obj/item/stock_parts/cell/power_cell
	power_cell = C.cell
	if(power_cell)
		cell = power_cell
		alarmed = FALSE
	playsound(src, load_sound, load_sound_volume, load_sound_vary)
	to_chat(user, "<span class='warning'>You install [C] in [src].</span>")
	update_icon(TRUE, user)
	return TRUE


//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/gun/energy/attack_hand(mob/user)
	if(!can_unload) //Only relevant for energy guns that can unload their cell
		return ..()
	if(can_charge && loc == user && user.is_holding(src) && cartridge)
		eject_cartridge(user)
		return
	return ..()


/obj/item/gun/energy/attackby(obj/item/W, mob/user, params)
	if(!can_charge || !can_unload)
		return ..()

	if(istype(W, /obj/item/cell_cartridge))
		var/obj/item/cell_cartridge/C
		C = W
		var/obj/item/stock_parts/cell/power_cell
		power_cell = C.cell

		if(power_cell)
			if(power_cell.self_recharge && !self_charge_allowed)
				to_chat(user, "<span class='warning'>[src] cannot accept self-recharging cells.</span>")
				return

			if(power_cell.maxcharge > max_accept) //Check that we're not trying to install anything crazy like a bluespace/quantum battery or whatever.
				to_chat(user, "<span class='warning'>[src] cannot accept cells with a higher capacity than [max_accept].</span>")
				return

		if(cartridge && C) //Where we remove the cell.
			eject_cartridge(user, TRUE, TRUE) //Remove the cell, then replace it.

		if(!cartridge && C)
			load_cartridge(C, user)

	else
		return ..()