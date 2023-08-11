/obj/item/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon = 'icons/obj/weapons/guns/energy.dmi'

	/// What type of power cell this uses
	var/obj/item/stock_parts/cell/cell
	var/cell_type = /obj/item/stock_parts/cell
	///if the weapon has custom icons for individual ammo types it can switch between. ie disabler beams, taser, laser/lethals, ect.
	var/modifystate = FALSE
	var/list/ammo_type = list(/obj/item/ammo_casing/energy)
	///The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.
	var/select = 1
	///If the user can select the firemode through attack_self.
	var/can_select = TRUE
	///Can it be charged in a recharger?
	var/can_charge = TRUE
	///Do we handle overlays with base update_icon()?
	var/automatic_charge_overlays = TRUE
	var/charge_sections = 4
	ammo_x_offset = 2
	///if this gun uses a stateful charge bar for more detail
	var/shaded_charge = FALSE
	///If this gun has a "this is loaded with X" overlay alongside chargebars and such
	var/single_shot_type_overlay = TRUE
	///Should we give an overlay to empty guns?
	var/display_empty = TRUE
	var/selfcharge = 0
	var/charge_timer = 0
	var/charge_delay = 8
	///whether the gun's cell drains the cyborg user's cell to recharge
	var/use_cyborg_cell = FALSE
	///set to true so the gun is given an empty cell
	var/dead_cell = FALSE

/obj/item/gun/energy/fire_sounds()
	// What frequency the energy gun's sound will make
	var/frequency_to_use

	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	// What percentage of the full battery a shot will expend
	var/shot_cost_percent = round(clamp(shot.e_cost / cell.maxcharge, 0, 1) * 100)
	// Ignore this on oversized/infinite cells or ammo without cost
	if(shot_cost_percent > 0)
		// The total amount of shots the fully charged energy gun can fire before running out
		var/max_shots = round(100/shot_cost_percent)
		// How many shots left before the energy gun's current battery runs out of energy
		var/shots_left = round((round(clamp(cell.charge / cell.maxcharge, 0, 1) * 100))/shot_cost_percent)
		frequency_to_use = sin((90/max_shots) * shots_left)

	if(suppressed)
		playsound(src, suppressed_sound, suppressed_volume, vary_fire_sound, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0, frequency = frequency_to_use)
	else
		playsound(src, fire_sound, fire_sound_volume, vary_fire_sound, frequency = frequency_to_use)

/obj/item/gun/energy/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS))
		cell.use(round(cell.charge / severity))
		chambered = null //we empty the chamber
		recharge_newshot() //and try to charge a new shot
		update_appearance()

/obj/item/gun/energy/get_cell()
	return cell

/obj/item/gun/energy/Initialize(mapload)
	. = ..()
	if(cell_type)
		cell = new cell_type(src)
	else
		cell = new(src)
	if(!dead_cell)
		cell.give(cell.maxcharge)
	update_ammo_types()
	recharge_newshot(TRUE)
	if(selfcharge)
		START_PROCESSING(SSobj, src)
	update_appearance()
	RegisterSignal(src, COMSIG_ITEM_RECHARGED, PROC_REF(instant_recharge))
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/energy/add_weapon_description()
	AddElement(/datum/element/weapon_description, attached_proc = PROC_REF(add_notes_energy))

/**
 *
 * Outputs type-specific weapon stats for energy-based firearms based on its firing modes
 * and the stats of those firing modes. Esoteric firing modes like ion are currently not supported
 * but can be added easily
 *
 */
/obj/item/gun/energy/proc/add_notes_energy()
	var/list/readout = list()
	// Make sure there is something to actually retrieve
	if(!ammo_type.len)
		return
	var/obj/projectile/exam_proj
	readout += "\nStandard models of this projectile weapon have [span_warning("[ammo_type.len] mode\s")]."
	readout += "Our heroic interns have shown that one can theoretically stay standing after..."
	if(projectile_damage_multiplier <= 0)
		readout += "a theoretically infinite number of shots on [span_warning("every")] mode due to esoteric or nonexistent offensive potential."
		return readout.Join("\n") // Sending over the singular string, rather than the whole list
	for(var/obj/item/ammo_casing/energy/for_ammo as anything in ammo_type)
		exam_proj = for_ammo.projectile_type
		if(!ispath(exam_proj))
			continue
		if(initial(exam_proj.damage) > 0) // Don't divide by 0!!!!!
			readout += "[span_warning("[HITS_TO_CRIT((initial(exam_proj.damage) * projectile_damage_multiplier) * for_ammo.pellets)] shot\s")] on [span_warning("[for_ammo.select_name]")] mode before collapsing from [initial(exam_proj.damage_type) == STAMINA ? "immense pain" : "their wounds"]."
			if(initial(exam_proj.stamina) > 0) // In case a projectile does damage AND stamina damage (Energy Crossbow)
				readout += "[span_warning("[HITS_TO_CRIT((initial(exam_proj.stamina) * projectile_damage_multiplier) * for_ammo.pellets)] shot\s")] on [span_warning("[for_ammo.select_name]")] mode before collapsing from immense pain."
		else
			readout += "a theoretically infinite number of shots on [span_warning("[for_ammo.select_name]")] mode."

	return readout.Join("\n") // Sending over the singular string, rather than the whole list

/obj/item/gun/energy/proc/update_ammo_types()
	var/obj/item/ammo_casing/energy/shot
	for (var/i in 1 to ammo_type.len)
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

	// Intentional cast.
	// Sometimes ammo_type has paths, sometimes it has atom.
	for (var/atom/item in ammo_type)
		qdel(item)
	ammo_type = null

	return ..()

/obj/item/gun/energy/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
		update_appearance()
	return ..()

/obj/item/gun/energy/process(seconds_per_tick)
	if(selfcharge && cell && cell.percent() < 100)
		charge_timer += seconds_per_tick
		if(charge_timer < charge_delay)
			return
		charge_timer = 0
		cell.give(100)
		if(!chambered) //if empty chamber we try to charge a new shot
			recharge_newshot(TRUE)
		update_appearance()

/obj/item/gun/energy/attack_self(mob/living/user as mob)
	if(ammo_type.len > 1 && can_select)
		select_fire(user)
	return ..()

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
				if(R.cell.use(shot.e_cost)) //Take power from the borg...
					cell.give(shot.e_cost) //... to recharge the shot
	if(!chambered)
		var/obj/item/ammo_casing/energy/AC = ammo_type[select]
		if(cell.charge >= AC.e_cost) //if there's enough power in the cell cell...
			chambered = AC //...prepare a new shot based on the current ammo type selected
			if(!chambered.loaded_projectile)
				chambered.newshot()

/obj/item/gun/energy/handle_chamber()
	if(chambered && !chambered.loaded_projectile) //if loaded_projectile is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/energy/shot = chambered
		cell.use(shot.e_cost)//... drain the cell cell
	chambered = null //either way, released the prepared shot
	recharge_newshot() //try to charge a new shot

/obj/item/gun/energy/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(!chambered && can_shoot())
		process_chamber() // If the gun was drained and then recharged, load a new shot.
	return ..()

/obj/item/gun/energy/process_burst(mob/living/user, atom/target, message = TRUE, params = null, zone_override="", randomized_gun_spread = 0, randomized_bonus_spread = 0, rand_spr = 0, iteration = 0)
	if(!chambered && can_shoot())
		process_chamber() // Ditto.
	return ..()

/obj/item/gun/energy/proc/select_fire(mob/living/user)
	select++
	if (select > ammo_type.len)
		select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if (shot.select_name && user)
		balloon_alert(user, "set to [shot.select_name]")
	chambered = null
	recharge_newshot(TRUE)
	update_appearance()

/obj/item/gun/energy/update_icon_state()
	var/skip_inhand = initial(inhand_icon_state) //only build if we aren't using a preset inhand icon
	var/skip_worn_icon = initial(worn_icon_state) //only build if we aren't using a preset worn icon

	if(skip_inhand && skip_worn_icon) //if we don't have either, don't do the math.
		return ..()

	var/ratio = get_charge_ratio()
	var/temp_icon_to_use = initial(icon_state)
	if(modifystate)
		var/obj/item/ammo_casing/energy/shot = ammo_type[select]
		temp_icon_to_use += "[shot.select_name]"

	temp_icon_to_use += "[ratio]"
	if(!skip_inhand)
		inhand_icon_state = temp_icon_to_use
	if(!skip_worn_icon)
		worn_icon_state = temp_icon_to_use
	return ..()


/obj/item/gun/energy/update_overlays()
	. = ..()
	if(!automatic_charge_overlays)
		return

	var/overlay_icon_state = "[icon_state]_charge"
	if(modifystate)
		var/obj/item/ammo_casing/energy/shot = ammo_type[select]
		if(single_shot_type_overlay)
			. += "[icon_state]_[initial(shot.select_name)]"
		overlay_icon_state += "_[initial(shot.select_name)]"

	var/ratio = get_charge_ratio()
	if(ratio == 0 && display_empty)
		. += "[icon_state]_empty"
		return
	if(shaded_charge)
		. += "[icon_state]_charge[ratio]"
		return
	var/mutable_appearance/charge_overlay = mutable_appearance(icon, overlay_icon_state)
	for(var/i = ratio, i >= 1, i--)
		charge_overlay.pixel_x = ammo_x_offset * (i - 1)
		charge_overlay.pixel_y = ammo_y_offset * (i - 1)
		. += new /mutable_appearance(charge_overlay)


///Used by update_icon_state() and update_overlays()
/obj/item/gun/energy/proc/get_charge_ratio()
	return can_shoot() ? CEILING(clamp(cell.charge / cell.maxcharge, 0, 1) * charge_sections, 1) : 0
	// Sets the ratio to 0 if the gun doesn't have enough charge to fire, or if its power cell is removed.

/obj/item/gun/energy/suicide_act(mob/living/user)
	if(istype(user) && can_shoot() && can_trigger_gun(user) && user.get_bodypart(BODY_ZONE_HEAD))
		user.visible_message(span_suicide("[user] is putting the barrel of [src] in [user.p_their()] mouth. It looks like [user.p_theyre()] trying to commit suicide!"))
		sleep(2.5 SECONDS)
		if(user.is_holding(src))
			user.visible_message(span_suicide("[user] melts [user.p_their()] face off with [src]!"))
			playsound(loc, fire_sound, 50, TRUE, -1)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select]
			cell.use(shot.e_cost)
			update_appearance()
			return FIRELOSS
		else
			user.visible_message(span_suicide("[user] panics and starts choking to death!"))
			return OXYLOSS
	else
		user.visible_message(span_suicide("[user] is pretending to melt [user.p_their()] face off with [src]! It looks like [user.p_theyre()] trying to commit suicide!</b>"))
		playsound(src, dry_fire_sound, 30, TRUE)
		return OXYLOSS

/obj/item/gun/energy/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, selfcharge))
			if(var_value)
				START_PROCESSING(SSobj, src)
			else
				STOP_PROCESSING(SSobj, src)
	. = ..()


/obj/item/gun/energy/ignition_effect(atom/A, mob/living/user)
	if(!can_shoot() || !ammo_type[select])
		shoot_with_empty_chamber()
		. = ""
	else
		var/obj/item/ammo_casing/energy/E = ammo_type[select]
		var/obj/projectile/energy/loaded_projectile = E.loaded_projectile
		if(!loaded_projectile)
			. = ""
		else if(loaded_projectile.damage <= 0 || loaded_projectile.damage_type == STAMINA)
			user.visible_message(span_danger("[user] tries to light [A.loc == user ? "[user.p_their()] [A.name]" : A] with [src], but it doesn't do anything. Dumbass."))
			playsound(user, E.fire_sound, 50, TRUE)
			playsound(user, loaded_projectile.hitsound, 50, TRUE)
			cell.use(E.e_cost)
			. = ""
		else if(loaded_projectile.damage_type != BURN)
			user.visible_message(span_danger("[user] tries to light [A.loc == user ? "[user.p_their()] [A.name]" : A] with [src], but only succeeds in utterly destroying it. Dumbass."))
			playsound(user, E.fire_sound, 50, TRUE)
			playsound(user, loaded_projectile.hitsound, 50, TRUE)
			cell.use(E.e_cost)
			qdel(A)
			. = ""
		else
			playsound(user, E.fire_sound, 50, TRUE)
			playsound(user, loaded_projectile.hitsound, 50, TRUE)
			cell.use(E.e_cost)
			. = span_danger("[user] casually lights [A.loc == user ? "[user.p_their()] [A.name]" : A] with [src]. Damn.")

/obj/item/gun/energy/proc/instant_recharge()
	SIGNAL_HANDLER
	if(!cell)
		return
	cell.charge = cell.maxcharge
	recharge_newshot(no_cyborg_drain = TRUE)
	update_appearance()
