#define DUALWIELD_PENALTY_EXTRA_MULTIPLIER 1.4

// Master file for cell loadable energy guns. PROCS ONLY YOU MONKEYS!
// This file is a copy/paste of _energy.dm with extensive modification.

/obj/item/gun/microfusion
	name = "prototype detatchable cell energy projection aparatus"
	desc = "The coders have obviously failed to realise this is broken."
	icon = 'modular_skyrat/modules/microfusion/icons/microfusion_gun40x32.dmi'
	icon_state = "mcr01"
	inhand_icon_state = "mcr01"
	lefthand_file = 'modular_skyrat/modules/microfusion/icons/guns_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/microfusion/icons/guns_righthand.dmi'
	can_bayonet = FALSE
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	obj_flags = UNIQUE_RENAME
	ammo_x_offset = 2

	/// What type of power cell this uses
	var/obj/item/stock_parts/cell/microfusion/cell
	/// The cell we will spawn with
	var/cell_type = /obj/item/stock_parts/cell/microfusion
	/// The cell type we check when inserting a cell
	var/base_cell_type = /obj/item/stock_parts/cell/microfusion
	/// If the weapon has custom icons for individual ammo types it can switch between. ie disabler beams, taser, laser/lethals, ect.
	var/modifystate = FALSE
	/// How many charge sections do we have?
	var/charge_sections = 4
	/// if this gun uses a stateful charge bar for more detail
	var/shaded_charge = FALSE
	/// Should we give an overlay to empty guns?
	var/display_empty = TRUE
	/// whether the gun's cell drains the cyborg user's cell to recharge
	var/dead_cell = FALSE

	// MICROFUSION SPECIFIC VARS

	/// The microfusion lens used for generating the beams.
	var/obj/item/ammo_casing/energy/laser/microfusion/microfusion_lens
	/// The sound played when you insert a cell.
	var/sound_cell_insert = 'modular_skyrat/modules/microfusion/sound/mag_insert.ogg'
	/// Should the insertion sound played vary?
	var/sound_cell_insert_vary = TRUE
	/// The volume at which we will play the insertion sound.
	var/sound_cell_insert_volume = 50
	/// The sound played when you remove a cell.
	var/sound_cell_remove = 'modular_skyrat/modules/microfusion/sound/mag_insert.ogg'
	/// Should the removal sound played vary?
	var/sound_cell_remove_vary = TRUE
	/// The volume at which we will play the removal sound.
	var/sound_cell_remove_volume = 50
	/// A list of attached upgrades
	var/list/attachments = list()
	/// The starting phase emitter in this weapon.
	var/phase_emitter_type = /obj/item/microfusion_phase_emitter
	/// The base emitter type that we check when putting a new emitter in.
	var/base_phase_emitter_type = /obj/item/microfusion_phase_emitter
	/// The phase emitter that this gun currently has.
	var/obj/item/microfusion_phase_emitter/phase_emitter
	/// The amount of heat produced per shot
	var/heat_per_shot = 100
	/// The heat dissipation bonus granted by the weapon.
	var/heat_dissipation_bonus = 0
	/// What slots does this gun have?
	var/attachment_slots = list(GUN_SLOT_BARREL, GUN_SLOT_UNDERBARREL, GUN_SLOT_RAIL, GUN_SLOT_UNIQUE, GUN_SLOT_CAMO)
	/// Our base firedelay.
	var/base_fire_delay = 0
	/// Do we use more power because of attachments?
	var/extra_power_usage = 0
	/// Spread from attachments.
	var/attachment_spread = 0
	/// Recoil from attachments.
	var/attachment_recoil = 0

/obj/item/gun/microfusion/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS))
		cell.use(round(cell.charge / severity))
		chambered = null //we empty the chamber
		recharge_newshot() //and try to charge a new shot
		update_appearance()

/obj/item/gun/microfusion/get_cell()
	return cell

/obj/item/gun/microfusion/Initialize(mapload)
	. = ..()
	if(cell_type)
		cell = new cell_type(src)
	else
		cell = new(src)
	cell.parent_gun = src
	cell.chargerate = 300
	if(!dead_cell)
		cell.give(cell.maxcharge)
	if(phase_emitter_type)
		phase_emitter = new phase_emitter_type(src)
	else
		phase_emitter = new(src)
	phase_emitter.parent_gun = src
	update_microfusion_lens()
	recharge_newshot(TRUE)
	AddElement(/datum/element/update_icon_updates_onmob)
	update_appearance()
	AddComponent(/datum/component/ammo_hud)
	RegisterSignal(src, COMSIG_ITEM_RECHARGED, PROC_REF(instant_recharge))
	base_fire_delay = fire_delay
	START_PROCESSING(SSobj, src)

/obj/item/gun/microfusion/give_gun_safeties()
	AddComponent(/datum/component/gun_safety)

/obj/item/gun/microfusion/add_weapon_description()
	AddElement(/datum/element/weapon_description, attached_proc = PROC_REF(add_notes_energy))

/obj/item/gun/microfusion/add_seclight_point()
	return

/obj/item/gun/microfusion/Destroy()
	if(microfusion_lens)
		QDEL_NULL(microfusion_lens)
	if(cell)
		cell.parent_gun = null
		QDEL_NULL(cell)
	if(attachments.len)
		for(var/obj/item/iterating_item in attachments)
			qdel(iterating_item)
		attachments = null
	if(phase_emitter)
		QDEL_NULL(phase_emitter)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/microfusion/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == cell)
		cell = null
		update_appearance()
	else if(gone == phase_emitter)
		phase_emitter = null
		update_appearance()

/obj/item/gun/microfusion/can_shoot()
	return !QDELETED(cell) ? (cell.charge >= microfusion_lens.e_cost) : FALSE

/obj/item/gun/microfusion/recharge_newshot()
	if (!microfusion_lens || !cell || !phase_emitter)
		return
	chambered = microfusion_lens
	if(!chambered.loaded_projectile)
		chambered.newshot()

/obj/item/gun/microfusion/handle_chamber()
	if(chambered && !chambered.loaded_projectile && cell) //if loaded_projectile is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/energy/shot = chambered
		cell.use(shot.e_cost + extra_power_usage)//... drain the cell
	chambered = null //either way, released the prepared shot
	recharge_newshot() //try to charge a new shot

/obj/item/gun/microfusion/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(!chambered && can_shoot())
		process_chamber() // If the gun was drained and then recharged, load a new shot.
	return ..()

/obj/item/gun/microfusion/process(seconds_per_tick)
	for(var/obj/item/microfusion_gun_attachment/attached as anything in attachments)
		attached.process_attachment(src, seconds_per_tick)

/obj/item/gun/microfusion/update_icon_state()
	var/skip_inhand = initial(inhand_icon_state) //only build if we aren't using a preset inhand icon
	var/skip_worn_icon = initial(worn_icon_state) //only build if we aren't using a preset worn icon

	if(skip_inhand && skip_worn_icon) //if we don't have either, don't do the math.
		return ..()

	var/ratio = get_charge_ratio()
	var/temp_icon_to_use = initial(icon_state)
	if(modifystate)
		temp_icon_to_use += "[microfusion_lens.select_name]"

	temp_icon_to_use += "[ratio]"
	if(!skip_inhand)
		inhand_icon_state = temp_icon_to_use
	if(!skip_worn_icon)
		worn_icon_state = temp_icon_to_use
	return ..()

/obj/item/gun/microfusion/update_overlays()
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_AMMO_HUD) //update the ammo hud since it's heavily dependent on the gun's state
	if(!phase_emitter)
		. += "[icon_state]_phase_emitter_missing"
	else if(phase_emitter.damaged)
		. += "[icon_state]_phase_emitter_damaged"
	else if(cell)
		var/ratio = get_charge_ratio()
		if(ratio == 0 && display_empty)
			. += "[icon_state]_empty"
		else if(shaded_charge)
			. += "[icon_state]_charge[ratio]_[phase_emitter.icon_state]"
	else
		. += "[icon_state]_phase_emitter_missing"


	for(var/obj/item/microfusion_gun_attachment/microfusion_gun_attachment in attachments)
		. += "[icon_state]_[microfusion_gun_attachment.attachment_overlay_icon_state]"


/obj/item/gun/microfusion/ignition_effect(atom/to_ignite, mob/living/user)
	if(!can_shoot() || !microfusion_lens)
		shoot_with_empty_chamber()
		. = ""
	else
		var/obj/projectile/energy/loaded_projectile = microfusion_lens.loaded_projectile
		if(!loaded_projectile)
			. = ""
		else if(!loaded_projectile.damage || loaded_projectile.damage_type == STAMINA)
			user.visible_message(span_danger("[user] tries to light [to_ignite.loc == user ? "[user.p_their()] [to_ignite.name]" : to_ignite] with [src], but it doesn't do anything. Dumbass."))
			playsound(user, microfusion_lens.fire_sound, 50, TRUE)
			playsound(user, loaded_projectile.hitsound, 50, TRUE)
			cell.use(microfusion_lens.e_cost)
			. = ""
		else if(loaded_projectile.damage_type != BURN)
			user.visible_message(span_danger("[user] tries to light [to_ignite.loc == user ? "[user.p_their()] [to_ignite.name]" : to_ignite] with [src], but only succeeds in utterly destroying it. Dumbass."))
			playsound(user, microfusion_lens.fire_sound, 50, TRUE)
			playsound(user, loaded_projectile.hitsound, 50, TRUE)
			cell.use(microfusion_lens.e_cost)
			qdel(to_ignite)
			. = ""
		else
			playsound(user, microfusion_lens.fire_sound, 50, TRUE)
			playsound(user, loaded_projectile.hitsound, 50, TRUE)
			cell.use(microfusion_lens.e_cost)
			. = span_danger("[user] casually lights [to_ignite.loc == user ? "[user.p_their()] [to_ignite.name]" : to_ignite] with [src]. Damn.")

/obj/item/gun/microfusion/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if (.)
		return
	if(istype(attacking_item, base_cell_type))
		insert_cell(user, attacking_item)
	if(istype(attacking_item, /obj/item/microfusion_gun_attachment))
		add_attachment(attacking_item, user)
	if(istype(attacking_item, base_phase_emitter_type))
		insert_emitter(attacking_item, user)

/obj/item/gun/microfusion/process_chamber(empty_chamber, from_firing, chamber_next_round)
	. = ..()
	if(!cell?.stabilised && prob(40))
		do_sparks(2, FALSE, src) //Microfusion guns create sparks!

/obj/item/gun/microfusion/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.is_holding(src) && cell)
		eject_cell(user)
		return
	return ..()

/obj/item/gun/microfusion/crowbar_act(mob/living/user, obj/item/tool)
	if(!phase_emitter)
		balloon_alert(user, "no phase emitter!")
		return
	playsound(src, 'sound/items/crowbar.ogg', 70, TRUE)
	remove_emitter()

/obj/item/gun/microfusion/AltClick(mob/user)
	. = ..()
	if(can_interact(user))
		var/obj/item/microfusion_gun_attachment/to_remove = input(user, "Please select what part you'd like to remove.", "Remove attachment")  as null|obj in sort_names(attachments)
		if(!to_remove)
			return
		remove_attachment(to_remove, user)

/obj/item/gun/microfusion/proc/remove_all_attachments()
	if(attachments.len)
		for(var/obj/item/microfusion_gun_attachment/attachment in attachments)
			attachment.remove_attachment(src)
			attachment.forceMove(get_turf(src))
			attachments -= attachment
		update_appearance()

/obj/item/gun/microfusion/examine(mob/user)
	. = ..()
	if(attachments.len)
		for(var/obj/item/microfusion_gun_attachment/microfusion_gun_attachment in attachments)
			. += span_notice("It has a [microfusion_gun_attachment.name] installed.")
		. += span_notice("<b>Alt+click</b> it to remove an upgrade.")
	if(phase_emitter)
		. += span_notice("It has a [phase_emitter.name] installed, at <b>[phase_emitter.get_heat_percent()]%</b> heat capacity.")
		. += span_notice("The [phase_emitter.name] is at <b>[phase_emitter.integrity]%</b> integrity.")
		. += span_notice("The [phase_emitter.name] will thermal throttle at <b>[phase_emitter.throttle_percentage]%</b> heat capacity.")
		. += span_notice("Use a crowbar to remove the phase emitter.")
	else
		. += span_danger("It does not have a phase emitter installed!")

	if(cell)
		. += span_notice("It has a [cell.name] installed, with a capacity of <b>[cell.charge]/[cell.maxcharge] MF</b>.")

/obj/item/gun/microfusion/suicide_act(mob/living/user)
	if (istype(user) && can_shoot() && can_trigger_gun(user) && user.get_bodypart(BODY_ZONE_HEAD))
		user.visible_message(span_suicide("[user] is putting the barrel of [src] in [user.p_their()] mouth. It looks like [user.p_theyre()] trying to commit suicide!"))
		sleep(2.5 SECONDS)
		if(user.is_holding(src))
			user.visible_message(span_suicide("[user] melts [user.p_their()] face off with [src]!"))
			playsound(loc, fire_sound, 50, TRUE, -1)
			cell.use(microfusion_lens.e_cost)
			update_appearance()
			return(FIRELOSS)
		else
			user.visible_message(span_suicide("[user] panics and starts choking to death!"))
			return(OXYLOSS)
	else
		user.visible_message(span_suicide("[user] is pretending to melt [user.p_their()] face off with [src]! It looks like [user.p_theyre()] trying to commit suicide!</b>"))
		playsound(src, dry_fire_sound, 30, TRUE)
		return (OXYLOSS)

// To maintain modularity, I am moving this proc override here.
/obj/item/gun/microfusion/fire_gun(atom/target, mob/living/user, flag, params)

	// check to see if the emitter prevents us from firing before anything else
	var/attempted_shot = process_emitter()
	if(attempted_shot != SHOT_SUCCESS)
		if(attempted_shot)
			balloon_alert(user, attempted_shot)
		return

	. = ..()

// To maintain modularity, I am moving this proc override here.
/obj/item/gun/microfusion/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	var/base_bonus_spread = 0
	if(user)
		var/list/bonus_spread_values = list(base_bonus_spread, bonus_spread)
		SEND_SIGNAL(user, COMSIG_MOB_FIRED_GUN, src, target, params, zone_override, bonus_spread_values)
		base_bonus_spread = bonus_spread_values[MIN_BONUS_SPREAD_INDEX]
		bonus_spread = bonus_spread_values[MAX_BONUS_SPREAD_INDEX]

	SEND_SIGNAL(src, COMSIG_GUN_FIRED, user, target, params, zone_override)

	add_fingerprint(user)

	if(semicd)
		return

	//Vary by at least this much
	var/randomized_bonus_spread = rand(base_bonus_spread, bonus_spread)
	var/randomized_gun_spread = spread ? rand(0, spread) : 0
	var/total_random_spread = max(0, randomized_bonus_spread + randomized_gun_spread)
	var/burst_spread_mult = rand()

	var/modified_delay = fire_delay
	if(phase_emitter)
		modified_delay = phase_emitter.fire_delay
	if(user && HAS_TRAIT(user, TRAIT_DOUBLE_TAP))
		modified_delay = ROUND_UP(fire_delay * 0.5)

	if(burst_size > 1)
		firing_burst = TRUE
		for(var/i = 1 to burst_size)
			addtimer(CALLBACK(src, PROC_REF(process_burst), user, target, message, params, zone_override, total_random_spread, burst_spread_mult, i), modified_delay * (i - 1))
	else
		if(chambered)
			if(HAS_TRAIT(user, TRAIT_PACIFISM)) // If the user has the pacifist trait, then they won't be able to fire [src] if the round chambered inside of [src] is lethal.
				if(chambered.harmful) // Is the bullet chambered harmful?
					balloon_alert(user, "lethally chambered!")
					return
			var/calculated_spread = round((rand(0, 1) - 0.5) * DUALWIELD_PENALTY_EXTRA_MULTIPLIER * total_random_spread)
			before_firing(target,user)
			process_microfusion()
			if(!chambered.fire_casing(target, user, params, , suppressed, zone_override, calculated_spread, src))
				shoot_with_empty_chamber(user)
				return
			else
				if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
					shoot_live_shot(user, 1, target, message)
				else
					shoot_live_shot(user, 0, target, message)
		else
			shoot_with_empty_chamber(user)
			return
		process_chamber()
		update_appearance()
		semicd = TRUE
		var/fire_delay_to_add = 0
		if(phase_emitter)
			fire_delay_to_add = phase_emitter.fire_delay
		addtimer(CALLBACK(src, PROC_REF(reset_semicd)), fire_delay + fire_delay_to_add)

	if(user)
		user.update_held_items()
	SSblackbox.record_feedback("tally", "gun_fired", 1, type)

	SEND_SIGNAL(src, COMSIG_UPDATE_AMMO_HUD)

	return TRUE

// Same goes for this!
/obj/item/gun/microfusion/process_burst(
		mob/living/user,
		atom/target,
		message = TRUE,
		params = null,
		zone_override = "",
		random_spread = 0,
		burst_spread_mult = 0,
		iteration = 0,
	)

	if(!user || !firing_burst)
		firing_burst = FALSE
		return FALSE
	if(!can_shoot())
		firing_burst = FALSE
		return FALSE
	if(!chambered)
		process_chamber() // Ditto.
	if(!issilicon(user))
		if(iteration > 1 && !(user.is_holding(src))) //for burst firing
			firing_burst = FALSE
			return FALSE
	if(chambered?.loaded_projectile)
		if(HAS_TRAIT(user, TRAIT_PACIFISM)) // If the user has the pacifist trait, then they won't be able to fire [src] if the round chambered inside of [src] is lethal.
			if(chambered.harmful) // Is the bullet chambered harmful?
				balloon_alert(user, "lethally chambered!")
				return
		var/calculated_spread
		if(randomspread)
			calculated_spread = round((rand(0, 1) - 0.5) * DUALWIELD_PENALTY_EXTRA_MULTIPLIER * (random_spread))
		else //Smart spread
			calculated_spread = round((((burst_spread_mult/burst_size) * iteration) - (0.5 + (burst_spread_mult * 0.25))) * (random_spread))
		before_firing(target,user)
		process_microfusion()
		if(!chambered.fire_casing(target, user, params, ,suppressed, zone_override, calculated_spread, src))
			shoot_with_empty_chamber(user)
			firing_burst = FALSE
			return FALSE
		else
			if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
				shoot_live_shot(user, 1, target, message)
			else
				shoot_live_shot(user, 0, target, message)
			if (iteration >= burst_size)
				firing_burst = FALSE
	else
		shoot_with_empty_chamber(user)
		firing_burst = FALSE
		return FALSE
	process_chamber()
	update_appearance()
	SEND_SIGNAL(src, COMSIG_UPDATE_AMMO_HUD)
	return TRUE

/obj/item/gun/microfusion/shoot_live_shot(mob/living/user, pointblank, atom/pbtarget, message)
	if(recoil)
		shake_camera(user, recoil + 1, recoil)

	var/sound_freq_to_add = 0

	if(phase_emitter && phase_emitter.sound_freq > 1)
		sound_freq_to_add = phase_emitter.sound_freq

	if(suppressed)
		playsound(user, suppressed_sound, suppressed_volume, vary_fire_sound, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, frequency = sound_freq_to_add, falloff_distance = 0)
	else
		playsound(user, fire_sound, fire_sound_volume, vary_fire_sound, frequency = sound_freq_to_add)
		if(message)
			if(pointblank)
				user.visible_message(span_danger("[user] fires [src] point blank at [pbtarget]!"), \
								span_danger("You fire [src] point blank at [pbtarget]!"), \
								span_hear("You hear a gunshot!"), COMBAT_MESSAGE_RANGE, pbtarget)
				to_chat(pbtarget, span_userdanger("[user] fires [src] point blank at you!"))
				if(pb_knockback > 0 && ismob(pbtarget))
					var/mob/PBT = pbtarget
					var/atom/throw_target = get_edge_target_turf(PBT, user.dir)
					PBT.throw_at(throw_target, pb_knockback, 2)
			else
				user.visible_message(span_danger("[user] fires [src]!"), \
								span_danger("You fire [src]!"), \
								span_hear("You hear a gunshot!"), COMBAT_MESSAGE_RANGE)
	if(user.resting)
		user.Immobilize(20, TRUE)

	phase_emitter.add_heat(heat_per_shot)

	if(phase_emitter.current_heat > phase_emitter.max_heat)
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			var/obj/item/bodypart/affecting = human.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
			if(affecting?.receive_damage( 0, 5 )) // 1 burn damage
				to_chat(user, span_warning("[src] burns your hand, it's too hot!"))

/obj/item/gun/microfusion/proc/process_microfusion()
	if(attachments.len)
		for(var/obj/item/microfusion_gun_attachment/attachment in attachments)
			attachment.process_fire(src, chambered)
	return TRUE

/obj/item/gun/microfusion/proc/process_emitter()
	if(!phase_emitter)
		return SHOT_FAILURE_NO_EMITTER
	var/phase_emitter_process = phase_emitter.check_emitter()
	if(phase_emitter_process != SHOT_SUCCESS)
		return phase_emitter_process
	return SHOT_SUCCESS

/obj/item/gun/microfusion/proc/instant_recharge()
	SIGNAL_HANDLER
	if(!cell)
		return
	cell.charge = cell.maxcharge
	recharge_newshot()
	update_appearance()

///Used by update_icon_state() and update_overlays()
/obj/item/gun/microfusion/proc/get_charge_ratio()
	return can_shoot() ? CEILING(clamp(cell.charge / cell.maxcharge, 0, 1) * charge_sections, 1) : 0
	// Sets the ratio to 0 if the gun doesn't have enough charge to fire, or if its power cell is removed.

/**
 *
 * Outputs type-specific weapon stats for energy-based firearms based on its firing modes
 * and the stats of those firing modes. Esoteric firing modes like ion are currently not supported
 * but can be added easily
 *
 */
/obj/item/gun/microfusion/proc/add_notes_energy()
	var/list/readout = list()
	// Make sure there is something to actually retrieve
	if(!microfusion_lens)
		return
	var/obj/projectile/exam_proj
	readout += "Our heroic interns have shown that one can theoretically stay standing after..."
	exam_proj = initial(microfusion_lens?.projectile_type)

	if(!istype(exam_proj))
		return readout.Join("\n")

	if(exam_proj.damage > 0) // Don't divide by 0!!!!!
		readout += "[span_warning("[HITS_TO_CRIT(exam_proj.damage * microfusion_lens.pellets)] shot\s")] on [span_warning("[microfusion_lens.select_name]")] mode before collapsing from [exam_proj.damage_type == STAMINA ? "immense pain" : "their wounds"]."
		if(exam_proj.stamina > 0) // In case a projectile does damage AND stamina damage (Energy Crossbow)
			readout += "[span_warning("[HITS_TO_CRIT(exam_proj.stamina * microfusion_lens.pellets)] shot\s")] on [span_warning("[microfusion_lens.select_name]")] mode before collapsing from immense pain."
	else
		readout += "a theoretically infinite number of shots on [span_warning("[microfusion_lens.select_name]")] mode."

	return readout.Join("\n") // Sending over the singular string, rather than the whole list

/obj/item/gun/microfusion/proc/update_microfusion_lens()
	if(!microfusion_lens)
		microfusion_lens = new(src)
	fire_sound = microfusion_lens.fire_sound
	fire_sound_volume = microfusion_lens.fire_sound_volume
	fire_delay = microfusion_lens.delay

// Cell, emitter and upgrade interactions

/obj/item/gun/microfusion/proc/remove_emitter(mob/user)
	playsound(src, sound_cell_insert, 50, TRUE)
	phase_emitter.forceMove(get_turf(src))
	if(user)
		user.put_in_hands(phase_emitter)
		balloon_alert(user, "removed phase emitter")
	phase_emitter.parent_gun = null
	phase_emitter = null
	update_appearance()

/obj/item/gun/microfusion/proc/insert_emitter(obj/item/microfusion_phase_emitter/inserting_phase_emitter, mob/living/user)
	if(phase_emitter)
		balloon_alert(user, "already one installed!")
		return FALSE
	balloon_alert(user, "inserted phase emitter")
	playsound(src, sound_cell_remove, 50, TRUE)
	inserting_phase_emitter.forceMove(src)
	phase_emitter = inserting_phase_emitter
	phase_emitter.parent_gun = src
	update_appearance()


/// Try to insert the cell into the gun, if successful, return TRUE
/obj/item/gun/microfusion/proc/insert_cell(mob/user, obj/item/stock_parts/cell/microfusion/inserting_cell, display_message = TRUE)
	var/hotswap = FALSE
	if(cell)
		hotswap = TRUE
	var/obj/item/stock_parts/cell/old_cell = cell
	if(inserting_cell.charge)
		balloon_alert(user, "can't insert a charged cell!")
		return FALSE
	if(display_message)
		balloon_alert(user, "cell inserted")
	if(hotswap)
		eject_cell(user, FALSE, FALSE)
	if(sound_cell_insert)
		playsound(src, sound_cell_insert, sound_cell_insert_volume, sound_cell_insert_vary)
	cell = inserting_cell
	inserting_cell.forceMove(src)
	inserting_cell.inserted_into_weapon()
	cell.parent_gun = src
	if(old_cell)
		user.put_in_hands(old_cell)
	recharge_newshot()
	update_appearance()
	return TRUE

/// Ejecting a cell.
/obj/item/gun/microfusion/proc/eject_cell(mob/user, display_message = TRUE, put_in_hands = TRUE)
	var/obj/item/stock_parts/cell/microfusion/old_cell = cell
	old_cell.forceMove(get_turf(src))
	old_cell.cell_removal_discharge()
	if(user)
		if(put_in_hands)
			user.put_in_hands(old_cell)
		if(display_message)
			balloon_alert(user, "cell removed")
	if(sound_cell_remove)
		playsound(src, sound_cell_remove, sound_cell_remove_volume, sound_cell_remove_vary)
	old_cell.update_appearance()
	old_cell.parent_gun = null
	cell = null
	update_appearance()

/// Attatching an upgrade.
/obj/item/gun/microfusion/proc/add_attachment(obj/item/microfusion_gun_attachment/microfusion_gun_attachment, mob/living/user)
	if(is_type_in_list(microfusion_gun_attachment, attachments))
		balloon_alert(user, "already has one!")
		return FALSE
	if(!(microfusion_gun_attachment.slot in attachment_slots))
		balloon_alert(user, "can't install!")
		return FALSE
	for(var/obj/item/microfusion_gun_attachment/iterating_attachment in attachments)
		if(is_type_in_list(microfusion_gun_attachment, iterating_attachment.incompatible_attachments))
			balloon_alert(user, "not compatible with [iterating_attachment]!")
			return FALSE
		if(iterating_attachment.slot != GUN_SLOT_UNIQUE && iterating_attachment.slot == microfusion_gun_attachment.slot)
			balloon_alert(user, "slot full!")
			return FALSE
	attachments += microfusion_gun_attachment
	microfusion_gun_attachment.forceMove(src)
	microfusion_gun_attachment.run_attachment(src)
	balloon_alert(user, "installed attachment")
	playsound(src, 'sound/effects/structure_stress/pop2.ogg', 70, TRUE)
	return TRUE

/obj/item/gun/microfusion/proc/remove_attachment(obj/item/microfusion_gun_attachment/microfusion_gun_attachment, mob/living/user)
	balloon_alert(user, "removed attachment")
	playsound(src, 'sound/items/screwdriver.ogg', 70)
	microfusion_gun_attachment.forceMove(get_turf(src))
	attachments -= microfusion_gun_attachment
	microfusion_gun_attachment.remove_attachment(src)
	user?.put_in_hands(microfusion_gun_attachment)
	update_appearance()

// UI CONTROL

/obj/item/gun/microfusion/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MicrofusionGunControl")
		ui.open()

/obj/item/gun/microfusion/ui_data(mob/user)
	var/list/data = list()

	data["gun_name"] = name
	data["gun_desc"] = desc
	data["gun_heat_dissipation"] = heat_dissipation_bonus

	if(phase_emitter)
		data["has_emitter"] = TRUE
		data["phase_emitter_data"] = list(
			"type" = capitalize(phase_emitter.name),
			"integrity" = phase_emitter.integrity,
			"current_heat" = phase_emitter.current_heat,
			"throttle_percentage" = phase_emitter.throttle_percentage,
			"heat_dissipation_per_tick" = phase_emitter.heat_dissipation_per_tick,
			"max_heat" = phase_emitter.max_heat,
			"damaged" = phase_emitter.damaged,
			"hacked" = phase_emitter.hacked,
			"heat_percent" = phase_emitter.get_heat_percent(),
			"process_time" = phase_emitter.fire_delay,
			"cooling_system" = phase_emitter.cooling_system,
			"cooling_system_rate" = phase_emitter.cooling_system_rate,
		)
	else
		data["has_emitter"] = FALSE

	if(cell)
		var/list/attachments = list()
		for(var/obj/item/microfusion_cell_attachment/attachment in cell.attachments)
			attachments += attachment.name
		data["has_cell"] = TRUE
		data["cell_data"] = list(
			"type" = capitalize(cell.name),
			"charge" = cell.charge,
			"max_charge" = cell.maxcharge,
			"status" = cell.meltdown,
			"attachments" = attachments,
		)
	else
		data["has_cell"] = FALSE



	if(attachments.len)
		data["has_attachments"] = TRUE
		data["attachments"] = list()
		for(var/obj/item/microfusion_gun_attachment/attachment in attachments)
			var/list/attachment_functions = attachment.get_modify_data()
			var/has_modifications = FALSE
			if(attachment_functions?.len > 0)
				has_modifications = TRUE
			data["attachments"] += list(list(
				"name" = uppertext(attachment.name),
				"desc" = attachment.desc,
				"slot" = capitalize(attachment.slot),
				"information" = attachment.get_information_data(),
				"has_modifications" = has_modifications,
				"modify" = attachment_functions,
				"ref" = REF(attachment),
			))

	else
		data["has_attachments"] = FALSE

	return data

/obj/item/gun/microfusion/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject_cell")
			if(!cell)
				return
			eject_cell(usr)
		if("overclock_emitter")
			if(!phase_emitter)
				return
			if(!phase_emitter.hacked)
				return
			phase_emitter.set_overclock(usr)
		if("eject_emitter")
			if(!phase_emitter)
				return
			remove_emitter(usr)
		if("remove_attachment")
			var/obj/item/microfusion_gun_attachment/to_remove = locate(params["attachment_ref"]) in src
			if(!to_remove)
				return
			remove_attachment(to_remove, usr)
		if("modify_attachment")
			var/obj/item/microfusion_gun_attachment/to_modify = locate(params["attachment_ref"]) in src
			if(!to_modify)
				return
			to_modify.run_modify_data(params["modify_ref"], usr, src)
		if("toggle_cooling_system")
			if(!phase_emitter)
				return
			phase_emitter.toggle_cooling_system(usr)

/// Recalculates the spread, based on attachment-provided values.
/obj/item/gun/microfusion/proc/recalculate_spread()
	spread = max(0, attachment_spread)

/// Recalculates the recoil, based on attachment-provided values.
/obj/item/gun/microfusion/proc/recalculate_recoil()
	recoil = max(0, attachment_recoil)
