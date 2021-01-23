/***************** WELCOME TO MECHA.DM, ENJOY YOUR STAY *****************/

/**
 * Mechs are now (finally) vehicles, this means you can make them multicrew
 * They can also grant select ability buttons based on occupant bitflags
 *
 * Movement is handled through vehicle_move() which is called by relaymove
 * Clicking is done by way of signals registering to the entering mob
 * NOTE: MMIS are NOT mobs but instead contain a brain that is, so you need special checks
 * AI also has special checks becaus it gets in and out of the mech differently
 * Always call remove_occupant(mob) when leaving the mech so the mob is removed properly
 *
 * For multi-crew, you need to set how the occupants recieve ability bitflags corresponding to their status on the vehicle(i.e: driver, gunner etc)
 * Abilities can then be set to only apply for certain bitflags and are assigned as such automatically
 *
 * Clicks are wither translated into mech_melee_attack (see mech_melee_attack.dm)
 * Or are used to call action() on equipped gear
 * Cooldown for gear is on the mech because exploits
 */
/obj/vehicle/sealed/mecha
	name = "mecha"
	desc = "Exosuit"
	icon = 'icons/mecha/mecha.dmi'
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_1 = HEAR_1
	max_integrity = 300
	armor = list(MELEE = 20, BULLET = 10, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	movedelay = 1 SECONDS
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	COOLDOWN_DECLARE(mecha_bump_smash)
	light_system = MOVABLE_LIGHT
	light_on = FALSE
	light_range = 4
	///What direction will the mech face when entered/powered on? Defaults to South.
	var/dir_in = SOUTH
	///How much energy the mech will consume each time it moves. This variable is a backup for when leg actuators affect the energy drain.
	var/normal_step_energy_drain = 10
	///How much energy the mech will consume each time it moves. this is the current active energy consumed
	var/step_energy_drain = 10
	///How much energy we drain each time we mechpunch someone
	var/melee_energy_drain = 15
	///The minimum amount of energy charge consumed by leg overload
	var/overload_step_energy_drain_min = 100
	///chance to deflect the incoming projectiles, hits, or lesser the effect of ex_act.
	var/deflect_chance = 10
	///Modifiers for directional armor
	var/list/facing_modifiers = list(MECHA_FRONT_ARMOUR = 1.5, MECHA_SIDE_ARMOUR = 1, MECHA_BACK_ARMOUR = 0.5)
	///if we cant use our equipment(such as due to EMP)
	var/equipment_disabled = FALSE
	/// Keeps track of the mech's cell
	var/obj/item/stock_parts/cell/cell
	/// Keeps track of the mech's scanning module
	var/obj/item/stock_parts/scanning_module/scanmod
	/// Keeps track of the mech's capacitor
	var/obj/item/stock_parts/capacitor/capacitor
	///Whether the mechs maintenance protocols are on or off
	var/construction_state = MECHA_LOCKED
	///Contains flags for the mecha
	var/mecha_flags = ADDING_ACCESS_POSSIBLE | CANSTRAFE | IS_ENCLOSED | HAS_LIGHTS
	///Stores the DNA enzymes of a carbon so tht only they can access the mech
	var/dna_lock
	///Spark effects are handled by this datum
	var/datum/effect_system/spark_spread/spark_system = new
	///How powerful our lights are
	var/lights_power = 6
	///Just stop the mech from doing anything
	var/completely_disabled = FALSE
	///Whether this mech is allowed to move diagonally
	var/allow_diagonal_movement = FALSE
	///Whether or not the mech destroys walls by running into it.
	var/bumpsmash = FALSE

	///////////ATMOS
	///Whether we are currrently drawing from the internal tank
	var/use_internal_tank = FALSE
	///The setting of the valve on the internal tank
	var/internal_tank_valve = ONE_ATMOSPHERE
	///The internal air tank obj of the mech
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	///Internal air mix datum
	var/datum/gas_mixture/cabin_air
	///The connected air port, if we have one
	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port

	///Special version of the radio, which is unsellable
	var/obj/item/radio/mech/radio
	var/list/trackers = list()

	var/max_temperature = 25000
	///health percentage below which internal damage is possible
	var/internal_damage_threshold = 50
	///Bitflags for internal damage
	var/internal_damage = NONE

	///required access level for mecha operation
	var/list/operation_req_access = list()
	///required access to change internal components
	var/list/internals_req_access = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE)

	///Typepath for the wreckage it spawns when destroyed
	var/wreckage

	var/list/equipment = list()
	///Current active equipment
	var/obj/item/mecha_parts/mecha_equipment/selected
	///Maximum amount of equipment we can have
	var/max_equip = 3

	///Whether our steps are silent due to no gravity
	var/step_silent = FALSE
	///Sound played when the mech moves
	var/stepsound = 'sound/mecha/mechstep.ogg'
	///Sound played when the mech walks
	var/turnsound = 'sound/mecha/mechturn.ogg'

	///Cooldown duration between melee punches
	var/melee_cooldown = 10

	///TIme taken to leave the mech
	var/exit_delay = 2 SECONDS
	///Time you get slept for if you get forcible ejected by the mech exploding
	var/destruction_sleep_duration = 2 SECONDS
	///Whether outside viewers can see the pilot inside
	var/enclosed = TRUE
	///In case theres a different iconstate for AI/MMI pilot(currently only used for ripley)
	var/silicon_icon_state = null
	///Currently ejecting, and unable to do things
	var/is_currently_ejecting = FALSE

	var/datum/effect_system/smoke_spread/smoke_system = new

	////Action vars
	///Ref to any active thrusters we might have
	var/obj/item/mecha_parts/mecha_equipment/thrusters/active_thrusters

	///Bool for energy shield on/off
	var/defense_mode = FALSE

	///Bool for leg overload on/off
	var/leg_overload_mode = FALSE
	///Energy use modifier for leg overload
	var/leg_overload_coeff = 100

	//Bool for zoom on/off
	var/zoom_mode = FALSE

	///Remaining smoke charges
	var/smoke_charges = 5
	///Cooldown between using smoke
	var/smoke_cooldown = 10 SECONDS

	///Bool for if the mech is currently phasing
	var/phasing = FALSE
	///Power we use every time we phaze through something
	var/phasing_energy_drain = 200
	///icon_state for flick() when phazing
	var/phase_state = ""

	///Wether we are strafing
	var/strafe = FALSE

	///Cooldown length between bumpsmashes
	var/smashcooldown = 3

	///Bool for whether this mech can only be used on lavaland
	var/lavaland_only = FALSE


	hud_possible = list (DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_TRACK_HUD)

/obj/item/radio/mech //this has to go somewhere

/obj/vehicle/sealed/mecha/Initialize()
	. = ..()
	add_radio()
	add_cabin()
	if(enclosed)
		add_airtank()
		RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE , .proc/disconnect_air)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/play_stepsound)
	spark_system.set_up(2, 0, src)
	spark_system.attach(src)
	smoke_system.set_up(3, src)
	smoke_system.attach(src)
	add_cell()
	add_scanmod()
	add_capacitor()
	START_PROCESSING(SSobj, src)
	AddElement(/datum/element/point_of_interest)
	log_message("[src.name] created.", LOG_MECHA)
	GLOB.mechas_list += src //global mech list
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_mechhealth()
	diag_hud_set_mechcell()
	diag_hud_set_mechstat()
	update_icon()

/obj/mecha/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/atmos_sensitive)

/obj/vehicle/sealed/mecha/Destroy()
	for(var/M in occupants)
		var/mob/living/occupant = M
		if(isAI(occupant))
			occupant.gib() //No wreck, no AI to recover
		else
			occupant.forceMove(loc)
			occupant.SetSleeping(destruction_sleep_duration)
	if(LAZYLEN(equipment))
		for(var/E in equipment)
			var/obj/item/mecha_parts/mecha_equipment/equip = E
			equip.detach(loc)
			qdel(equip)
	QDEL_NULL(cell)
	QDEL_NULL(scanmod)
	QDEL_NULL(capacitor)
	QDEL_NULL(internal_tank)
	STOP_PROCESSING(SSobj, src)
	LAZYCLEARLIST(equipment)
	if(loc)
		loc.assume_air(cabin_air)
		air_update_turf(FALSE, FALSE)
	else
		qdel(cabin_air)
	cabin_air = null
	QDEL_NULL(spark_system)
	QDEL_NULL(smoke_system)

	GLOB.mechas_list -= src //global mech list
	return ..()

/obj/vehicle/sealed/mecha/update_icon_state()
	if((mecha_flags & SILICON_PILOT) && silicon_icon_state)
		icon_state = silicon_icon_state
	else if(LAZYLEN(occupants))
		icon_state = initial(icon_state)
	else
		icon_state = initial(icon_state)+ "-open"


/obj/vehicle/sealed/mecha/get_cell()
	return cell

/obj/vehicle/sealed/mecha/rust_heretic_act()
	take_damage(500,  BRUTE)

/obj/vehicle/sealed/mecha/proc/restore_equipment()
	equipment_disabled = FALSE
	for(var/occupant in occupants)
		var/mob/mob_occupant = occupant
		SEND_SOUND(mob_occupant, sound('sound/items/timer.ogg', volume=50))
		to_chat(mob_occupant, "<span=notice>Equipment control unit has been rebooted successfully.</span>")
		mob_occupant.update_mouse_pointer()

/obj/vehicle/sealed/mecha/CheckParts(list/parts_list)
	. = ..()
	cell = locate(/obj/item/stock_parts/cell) in contents
	scanmod = locate(/obj/item/stock_parts/scanning_module) in contents
	capacitor = locate(/obj/item/stock_parts/capacitor) in contents
	update_part_values()

/obj/vehicle/sealed/mecha/proc/update_part_values() ///Updates the values given by scanning module and capacitor tier, called when a part is removed or inserted.
	if(scanmod)
		normal_step_energy_drain = 20 - (5 * scanmod.rating) //10 is normal, so on lowest part its worse, on second its ok and on higher its real good up to 0 on best
		step_energy_drain = normal_step_energy_drain
	else
		normal_step_energy_drain = 500
		step_energy_drain = normal_step_energy_drain
	if(capacitor)
		armor = armor.modifyRating(energy = (capacitor.rating * 5)) //Each level of capacitor protects the mech against emp by 5%
	else //because we can still be hit without a cap, even if we can't move
		armor = armor.setRating(energy = 0)


////////////////////////
////// Helpers /////////
////////////////////////

/obj/vehicle/sealed/mecha/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank

///Adds a cell, for use in Map-spawned mechs, Nuke Ops mechs, and admin-spawned mechs. Mechs built by hand will replace this.
/obj/vehicle/sealed/mecha/proc/add_cell(obj/item/stock_parts/cell/C=null)
	QDEL_NULL(cell)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new /obj/item/stock_parts/cell/high/plus(src)

///Adds a scanning module, for use in Map-spawned mechs, Nuke Ops mechs, and admin-spawned mechs. Mechs built by hand will replace this.
/obj/vehicle/sealed/mecha/proc/add_scanmod(obj/item/stock_parts/scanning_module/sm=null)
	QDEL_NULL(scanmod)
	if(sm)
		sm.forceMove(src)
		scanmod = sm
		return
	scanmod = new /obj/item/stock_parts/scanning_module(src)

///Adds a capacitor, for use in Map-spawned mechs, Nuke Ops mechs, and admin-spawned mechs. Mechs built by hand will replace this.
/obj/vehicle/sealed/mecha/proc/add_capacitor(obj/item/stock_parts/capacitor/cap=null)
	QDEL_NULL(capacitor)
	if(cap)
		cap.forceMove(src)
		capacitor = cap
	else
		capacitor = new /obj/item/stock_parts/capacitor(src)

/obj/vehicle/sealed/mecha/proc/add_cabin()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.add_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
	cabin_air.gases[/datum/gas/oxygen][MOLES] = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.gases[/datum/gas/nitrogen][MOLES] = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	return cabin_air

/obj/vehicle/sealed/mecha/proc/add_radio()
	radio = new(src)
	radio.name = "[src] radio"
	radio.icon = icon
	radio.icon_state = icon_state
	radio.subspace_transmission = TRUE

/obj/vehicle/sealed/mecha/proc/can_use(mob/user)
	if(istype(user) && is_occupant(user))
		if(!user.incapacitated())
			return TRUE
	return FALSE

////////////////////////////////////////////////////////////////////////////////

/obj/vehicle/sealed/mecha/examine(mob/user)
	. = ..()
	var/integrity = obj_integrity*100/max_integrity
	switch(integrity)
		if(85 to 100)
			. += "It's fully intact."
		if(65 to 85)
			. += "It's slightly damaged."
		if(45 to 65)
			. += "It's badly damaged."
		if(25 to 45)
			. += "It's heavily damaged."
		else
			. += "It's falling apart."
	var/hide_weapon = locate(/obj/item/mecha_parts/concealed_weapon_bay) in contents
	var/hidden_weapon = hide_weapon ? (locate(/obj/item/mecha_parts/mecha_equipment/weapon) in equipment) : null
	var/list/visible_equipment = equipment - hidden_weapon
	if(visible_equipment.len)
		. += "It's equipped with:"
		for(var/obj/item/mecha_parts/mecha_equipment/ME in visible_equipment)
			. += "[icon2html(ME, user)] \A [ME]."
	if(enclosed)
		return
	if(mecha_flags & SILICON_PILOT)
		. += "[src] appears to be piloting itself..."
	else
		for(var/occupante in occupants)
			. += "You can see [occupante] inside."
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			for(var/held_item in H.held_items)
				if(!isgun(held_item))
					continue
				. += "<span class='warning'>It looks like you can hit the pilot directly if you target the center or above.</span>"
				break //in case user is holding two guns

//processing internal damage, temperature, air regulation, alert updates, lights power use.
/obj/vehicle/sealed/mecha/process(delta_time)
	var/internal_temp_regulation = 1

	if(internal_damage)
		if(internal_damage & MECHA_INT_FIRE)
			if(!(internal_damage & MECHA_INT_TEMP_CONTROL) && DT_PROB(2.5, delta_time))
				clearInternalDamage(MECHA_INT_FIRE)
			if(internal_tank)
				var/datum/gas_mixture/int_tank_air = internal_tank.return_air()
				if(int_tank_air.return_pressure() > internal_tank.maximum_pressure && !(internal_damage & MECHA_INT_TANK_BREACH))
					setInternalDamage(MECHA_INT_TANK_BREACH)
				if(int_tank_air && int_tank_air.return_volume() > 0) //heat the air_contents
					int_tank_air.temperature = min(6000+T0C, int_tank_air.temperature+rand(5,7.5)*delta_time)
			if(cabin_air && cabin_air.return_volume()>0)
				cabin_air.temperature = min(6000+T0C, cabin_air.return_temperature()+rand(5,7.5)*delta_time)
				if(cabin_air.return_temperature() > max_temperature/2)
					take_damage(delta_time*2/round(max_temperature/cabin_air.return_temperature(),0.1), BURN, 0, 0)

		if(internal_damage & MECHA_INT_TEMP_CONTROL)
			internal_temp_regulation = 0

		if(internal_damage & MECHA_INT_TANK_BREACH) //remove some air from internal tank
			if(internal_tank)
				var/datum/gas_mixture/int_tank_air = internal_tank.return_air()
				var/datum/gas_mixture/leaked_gas = int_tank_air.remove_ratio(DT_PROB_RATE(0.05, delta_time))
				if(loc)
					loc.assume_air(leaked_gas)
					air_update_turf(FALSE, FALSE)
				else
					qdel(leaked_gas)

		if(internal_damage & MECHA_INT_SHORT_CIRCUIT)
			if(get_charge())
				spark_system.start()
				cell.charge -= min(10 * delta_time, cell.charge)
				cell.maxcharge -= min(10 * delta_time, cell.maxcharge)

	if(internal_temp_regulation)
		if(cabin_air && cabin_air.return_volume() > 0)
			var/delta = cabin_air.temperature - T20C
			cabin_air.temperature -= clamp(round(delta / 8, 0.1), -5, 5) * delta_time

	if(internal_tank)
		var/datum/gas_mixture/tank_air = internal_tank.return_air()

		var/release_pressure = internal_tank_valve
		var/cabin_pressure = cabin_air.return_pressure()
		var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
		var/transfer_moles = 0
		if(pressure_delta > 0) //cabin pressure lower than release pressure
			if(tank_air.return_temperature() > 0)
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
				cabin_air.merge(removed)
		else if(pressure_delta < 0) //cabin pressure higher than release pressure
			var/datum/gas_mixture/t_air = return_air()
			pressure_delta = cabin_pressure - release_pressure
			if(t_air)
				pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
			if(pressure_delta > 0) //if location pressure is lower than cabin pressure
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
				if(t_air)
					t_air.merge(removed)
				else //just delete the cabin gas, we're in space or some shit
					qdel(removed)

	if(LAZYLEN(occupants))
		for(var/i in occupants)
			var/mob/living/occupant = i
			if(cell)
				var/cellcharge = cell.charge/cell.maxcharge
				switch(cellcharge)
					if(0.75 to INFINITY)
						occupant.clear_alert("charge")
					if(0.5 to 0.75)
						occupant.throw_alert("charge", /atom/movable/screen/alert/lowcell, 1)
					if(0.25 to 0.5)
						occupant.throw_alert("charge", /atom/movable/screen/alert/lowcell, 2)
					if(0.01 to 0.25)
						occupant.throw_alert("charge", /atom/movable/screen/alert/lowcell, 3)
					else
						occupant.throw_alert("charge", /atom/movable/screen/alert/emptycell)

			var/integrity = obj_integrity/max_integrity*100
			switch(integrity)
				if(30 to 45)
					occupant.throw_alert("mech damage", /atom/movable/screen/alert/low_mech_integrity, 1)
				if(15 to 35)
					occupant.throw_alert("mech damage", /atom/movable/screen/alert/low_mech_integrity, 2)
				if(-INFINITY to 15)
					occupant.throw_alert("mech damage", /atom/movable/screen/alert/low_mech_integrity, 3)
				else
					occupant.clear_alert("mech damage")
			var/atom/checking = occupant.loc
			// recursive check to handle all cases regarding very nested occupants,
			// such as brainmob inside brainitem inside MMI inside mecha
			while(!isnull(checking))
				if(isturf(checking))
					// hit a turf before hitting the mecha, seems like they have been moved out
					occupant.clear_alert("charge")
					occupant.clear_alert("mech damage")
					occupant = null
					break
				else if (checking == src)
					break  // all good
				checking = checking.loc

	if(mecha_flags & LIGHTS_ON)
		var/lights_energy_drain = 2
		use_power(lights_energy_drain*delta_time)

	for(var/b in occupants)
		var/mob/living/occupant = b
		if(!enclosed && occupant?.incapacitated()) //no sides mean it's easy to just sorta fall out if you're incapacitated.
			visible_message("<span class='warning'>[occupant] tumbles out of the cockpit!</span>")
			mob_exit(occupant)	//bye bye

//Diagnostic HUD updates
	diag_hud_set_mechhealth()
	diag_hud_set_mechcell()
	diag_hud_set_mechstat()

/obj/vehicle/sealed/mecha/fire_act() //Check if we should ignite the pilot of an open-canopy mech
	. = ..()
	if(LAZYLEN(occupants) && !enclosed && !(mecha_flags & SILICON_PILOT))
		for(var/M in occupants)
			var/mob/living/cookedalive = M
			if(cookedalive.fire_stacks < 5)
				cookedalive.adjust_fire_stacks(1)
				cookedalive.IgniteMob()

/obj/vehicle/sealed/mecha/proc/display_speech_bubble(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/list/speech_bubble_recipients = get_hearers_in_view(7,src)
	for(var/mob/M in speech_bubble_recipients)
		if(M.client)
			speech_bubble_recipients.Add(M.client)
	INVOKE_ASYNC(GLOBAL_PROC, /proc/flick_overlay, image('icons/mob/talk.dmi', src, "machine[say_test(speech_args[SPEECH_MESSAGE])]",MOB_LAYER+1), speech_bubble_recipients, 30)

////////////////////////////
///// Action processing ////
////////////////////////////

/obj/vehicle/sealed/mecha/proc/on_mouseclick(mob/user, atom/target, params)
	SIGNAL_HANDLER
	if(!locate(/turf) in list(target,target.loc)) // Prevents inventory from being drilled
		return
	if(completely_disabled)
		return
	if(is_currently_ejecting)
		return
	var/list/mouse_control = params2list(params)
	if(isAI(user) == !mouse_control["middle"])//BASICALLY if a human uses MMB, or an AI doesn't, then do nothing.
		return
	if(phasing)
		to_chat(occupants, "[icon2html(src, occupants)]<span class='warning'>Unable to interact with objects while phasing.</span>")
		return
	if(user.incapacitated())
		return
	if(construction_state)
		to_chat(occupants, "[icon2html(src, occupants)]<span class='warning'>Maintenance protocols in effect.</span>")
		return
	if(!get_charge())
		return
	if(src == target)
		return
	var/dir_to_target = get_dir(src,target)
	if(dir_to_target && !(dir_to_target & dir))//wrong direction
		return
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		target = pick(view(3,target))
		if(!target)
			return
	var/mob/living/L = user
	if(selected)
		if(!Adjacent(target) && (selected.range & MECHA_RANGED))
			if(HAS_TRAIT(L, TRAIT_PACIFISM) && selected.harmful)
				to_chat(L, "<span class='warning'>You don't want to harm other living beings!</span>")
				return
			INVOKE_ASYNC(selected, /obj/item/mecha_parts/mecha_equipment.proc/action, user, target, params)
			return
		if((selected.range & MECHA_MELEE) && Adjacent(target))
			if(isliving(target) && selected.harmful && HAS_TRAIT(L, TRAIT_PACIFISM))
				to_chat(L, "<span class='warning'>You don't want to harm other living beings!</span>")
				return
			INVOKE_ASYNC(selected, /obj/item/mecha_parts/mecha_equipment.proc/action, user, target, params)
			return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MELEE_ATTACK) || !istype(target, /atom) || !Adjacent(target))
		return
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		var/list/possible_targets = oview(1,src)
		if(!length(possible_targets))
			return
		target = pick(possible_targets)
	target.mech_melee_attack(src, user)
	TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MELEE_ATTACK, melee_cooldown)

/obj/vehicle/sealed/mecha/proc/on_middlemouseclick(mob/user, atom/target, params)
	if(isAI(user))
		on_mouseclick(user, target, params)

//////////////////////////////////
////////  Movement procs  ////////
//////////////////////////////////

///Plays the mech step sound effect. Split from movement procs so that other mechs (HONK) can override this one specific part.
/obj/vehicle/sealed/mecha/proc/play_stepsound()
	SIGNAL_HANDLER
	if(mecha_flags & QUIET_STEPS)
		return
	playsound(src, stepsound, 40, TRUE)

/obj/vehicle/sealed/mecha/proc/disconnect_air()
	SIGNAL_HANDLER
	if(internal_tank.disconnect()) // Something moved us and broke connection
		to_chat(occupants, "[icon2html(src, occupants)]<span class='warning'>Air port connection has been severed!</span>")
		log_message("Lost connection to gas port.", LOG_MECHA)

/obj/vehicle/sealed/mecha/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(.)
		return

	var/atom/movable/backup = get_spacemove_backup()
	if(backup)
		if(istype(backup) && movement_dir && !backup.anchored)
			if(backup.newtonian_move(turn(movement_dir, 180)))
				step_silent = TRUE
				if(return_drivers())
					to_chat(occupants, "[icon2html(src, occupants)]<span class='info'>The [src] push off [backup] to propel yourself.</span>")
		return TRUE

	if(active_thrusters?.thrust(movement_dir))
		step_silent = TRUE
		return TRUE
	return FALSE

/obj/vehicle/sealed/mecha/relaymove(mob/living/user, direction)
	if(canmove)
		vehicle_move(direction)
	return TRUE

/obj/vehicle/sealed/mecha/vehicle_move(direction, forcerotate = FALSE)
	if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
		return FALSE
	COOLDOWN_START(src, cooldown_vehicle_move, movedelay)
	if(completely_disabled)
		return FALSE
	if(!direction)
		return FALSE
	if(internal_tank?.connected_port)
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)]<span class='warning'>Unable to move while connected to the air system port!</span>")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE
	if(construction_state)
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)]<span class='danger'>Maintenance protocols in effect.</span>")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE

	if(!Process_Spacemove(direction))
		return FALSE
	if(zoom_mode)
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)]<span class='warning'>Unable to move while in zoom mode!</span>")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE
	if(!cell)
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)]<span class='warning'>Missing power cell.</span>")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE
	if(!scanmod || !capacitor)
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)]<span class='warning'>Missing [scanmod? "capacitor" : "scanning module"].</span>")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE
	if(!use_power(step_energy_drain))
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)]<span class='warning'>Insufficient power to move!</span>")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE
	if(lavaland_only && is_mining_level(z))
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)]<span class='warning'>Invalid Environment.</span>")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE

	var/olddir = dir

	if(internal_damage & MECHA_INT_CONTROL_LOST)
		direction = pick(GLOB.alldirs)

	//only mechs with diagonal movement may move diagonally
	if(!allow_diagonal_movement && ISDIAGONALDIR(direction))
		return TRUE

	var/keyheld = FALSE
	if(strafe)
		for(var/D in return_drivers())
			var/mob/driver = D
			if(driver.client?.keys_held["Alt"])
				keyheld = TRUE
				break

	//if we're not facing the way we're going rotate us
	if(dir != direction && !strafe || forcerotate || keyheld)
		if(dir != direction && !(mecha_flags & QUIET_TURNS) && !step_silent)
			playsound(src,turnsound,40,TRUE)
		setDir(direction)
		return TRUE

	set_glide_size(DELAY_TO_GLIDE_SIZE(movedelay))
	//Otherwise just walk normally
	. = step(src,direction, dir)

	if(strafe)
		setDir(olddir)


/obj/vehicle/sealed/mecha/Bump(atom/obstacle)
	if(phasing && get_charge() >= phasing_energy_drain && !throwing)
		if(phase_state)
			flick(phase_state, src)
		var/turf/destination = get_step(src,dir)
		var/area/destination_area = destination.loc
		if(destination_area.area_flags & NOTELEPORT)
			to_chat(occupants, "[icon2html(src, occupants)]<span class='warning'>A dull, universal force is preventing you from phasing here!</span>")
			spark_system.start()
		else
			forceMove(destination)//This is jank I hate it thanks, this should be done thrugh move not this dumb shit
		use_power(phasing_energy_drain)
		addtimer(VARSET_CALLBACK(src, movedelay, TRUE), movedelay*3)
		return
	. = ..()
	if(.) //mech was thrown/door/whatever
		return
	if(bumpsmash) //Need a pilot to push the PUNCH button.
		if(COOLDOWN_FINISHED(src, mecha_bump_smash))
			obstacle.mech_melee_attack(src)
			COOLDOWN_START(src, mecha_bump_smash, smashcooldown)
			if(!obstacle || obstacle.CanPass(src,get_step(src,dir)))
				step(src,dir)
	if(isobj(obstacle))
		var/obj/obj_obstacle = obstacle
		if(!obj_obstacle.anchored && obj_obstacle.move_resist <= move_force)
			step(obstacle, dir)
	else if(ismob(obstacle))
		var/mob/mob_obstacle = obstacle
		if(mob_obstacle.move_resist <= move_force)
			step(obstacle, dir)





///////////////////////////////////
////////  Internal damage  ////////
///////////////////////////////////

/obj/vehicle/sealed/mecha/proc/check_for_internal_damage(list/possible_int_damage,ignore_threshold=null)
	if(!islist(possible_int_damage) || !length(possible_int_damage))
		return
	if(prob(20))
		if(ignore_threshold || obj_integrity*100/max_integrity < internal_damage_threshold)
			for(var/T in possible_int_damage)
				if(internal_damage & T)
					possible_int_damage -= T
			if (length(possible_int_damage))
				var/int_dam_flag = pick(possible_int_damage)
				if(int_dam_flag)
					setInternalDamage(int_dam_flag)
	if(prob(5))
		if(ignore_threshold || obj_integrity*100/max_integrity < internal_damage_threshold)
			if(LAZYLEN(equipment))
				var/obj/item/mecha_parts/mecha_equipment/ME = pick(equipment)
				qdel(ME)

/obj/vehicle/sealed/mecha/proc/setInternalDamage(int_dam_flag)
	internal_damage |= int_dam_flag
	log_message("Internal damage of type [int_dam_flag].", LOG_MECHA)
	SEND_SOUND(occupants, sound('sound/machines/warning-buzzer.ogg',wait=0))
	diag_hud_set_mechstat()

/obj/vehicle/sealed/mecha/proc/clearInternalDamage(int_dam_flag)
	if(internal_damage & int_dam_flag)
		switch(int_dam_flag)
			if(MECHA_INT_TEMP_CONTROL)
				to_chat(occupants, "[icon2html(src, occupants)]<span class='boldnotice'>Life support system reactivated.</span>")
			if(MECHA_INT_FIRE)
				to_chat(occupants, "[icon2html(src, occupants)]<span class='boldnotice'>Internal fire extinguished.</span>")
			if(MECHA_INT_TANK_BREACH)
				to_chat(occupants, "[icon2html(src, occupants)]<span class='boldnotice'>Damaged internal tank has been sealed.</span>")
	internal_damage &= ~int_dam_flag
	diag_hud_set_mechstat()

/////////////////////////////////////
//////////// AI piloting ////////////
/////////////////////////////////////

/obj/vehicle/sealed/mecha/attack_ai(mob/living/silicon/ai/user)
	if(!isAI(user))
		return
	//Allows the Malf to scan a mech's status and loadout, helping it to decide if it is a worthy chariot.
	if(user.can_dominate_mechs)
		examine(user) //Get diagnostic information!
		for(var/obj/item/mecha_parts/mecha_tracking/B in trackers)
			to_chat(user, "<span class='danger'>Warning: Tracking Beacon detected. Enter at your own risk. Beacon Data:</span>")
			to_chat(user, "[B.get_mecha_info()]")
			break
		//Nothing like a big, red link to make the player feel powerful!
		to_chat(user, "<a href='?src=[REF(user)];ai_take_control=[REF(src)]'><span class='userdanger'>ASSUME DIRECT CONTROL?</span></a><br>")
	else
		examine(user)
		if(length(return_drivers()) > 0)
			to_chat(user, "<span class='warning'>This exosuit has a pilot and cannot be controlled.</span>")
			return
		var/can_control_mech = 0
		for(var/obj/item/mecha_parts/mecha_tracking/ai_control/A in trackers)
			can_control_mech = 1
			to_chat(user, "<span class='notice'>[icon2html(src, user)] Status of [name]:</span>\n[A.get_mecha_info()]")
			break
		if(!can_control_mech)
			to_chat(user, "<span class='warning'>You cannot control exosuits without AI control beacons installed.</span>")
			return
		to_chat(user, "<a href='?src=[REF(user)];ai_take_control=[REF(src)]'><span class='boldnotice'>Take control of exosuit?</span></a><br>")

/obj/vehicle/sealed/mecha/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	. = ..()
	if(!.)
		return

	//Transfer from core or card to mech. Proc is called by mech.
	switch(interaction)
		if(AI_TRANS_TO_CARD) //Upload AI from mech to AI card.
			if(!construction_state) //Mech must be in maint mode to allow carding.
				to_chat(user, "<span class='warning'>[name] must have maintenance protocols active in order to allow a transfer.</span>")
				return
			var/list/ai_pilots = list()
			for(var/mob/living/silicon/ai/aipilot in occupants)
				ai_pilots += aipilot
			if(!ai_pilots.len) //Mech does not have an AI for a pilot
				to_chat(user, "<span class='warning'>No AI detected in the [name] onboard computer.</span>")
				return
			if(ai_pilots.len > 1) //Input box for multiple AIs, but if there's only one we'll default to them.
				AI = input(user,"Which AI do you wish to card?", "AI Selection") as null|anything in sortList(ai_pilots)
			else
				AI = ai_pilots[1]
			if(!AI)
				return
			if(!(AI in occupants) || !user.Adjacent(src))
				return //User sat on the selection window and things changed.

			AI.ai_restore_power()//So the AI initially has power.
			AI.control_disabled = TRUE
			AI.radio_enabled = FALSE
			AI.disconnect_shell()
			remove_occupant(AI)
			mecha_flags  &= ~SILICON_PILOT
			AI.forceMove(card)
			card.AI = AI
			AI.controlled_mech = null
			AI.remote_control = null
			to_chat(AI, "<span class='notice'>You have been downloaded to a mobile storage device. Wireless connection offline.</span>")
			to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) removed from [name] and stored within local memory.")
			return

		if(AI_MECH_HACK) //Called by AIs on the mech
			AI.linked_core = new /obj/structure/ai_core/deactivated(AI.loc)
			if(AI.can_dominate_mechs && LAZYLEN(occupants)) //Oh, I am sorry, were you using that?
				to_chat(AI, "<span class='warning'>Occupants detected! Forced ejection initiated!</span>")
				to_chat(occupants, "<span class='danger'>You have been forcibly ejected!</span>")
				ejectall() //IT IS MINE, NOW. SUCK IT, RD!
				AI.can_shunt = FALSE //ONE AI ENTERS. NO AI LEAVES.

		if(AI_TRANS_FROM_CARD) //Using an AI card to upload to a mech.
			AI = card.AI
			if(!AI)
				to_chat(user, "<span class='warning'>There is no AI currently installed on this device.</span>")
				return
			if(AI.deployed_shell) //Recall AI if shelled so it can be checked for a client
				AI.disconnect_shell()
			if(AI.stat || !AI.client)
				to_chat(user, "<span class='warning'>[AI.name] is currently unresponsive, and cannot be uploaded.</span>")
				return
			if((LAZYLEN(occupants) >= max_occupants) || dna_lock) //Normal AIs cannot steal mechs!
				to_chat(user, "<span class='warning'>Access denied. [name] is [LAZYLEN(occupants) >= max_occupants ? "currently fully occupied" : "secured with a DNA lock"].</span>")
				return
			AI.control_disabled = FALSE
			AI.radio_enabled = TRUE
			to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
			card.AI = null
	ai_enter_mech(AI)

//Hack and From Card interactions share some code, so leave that here for both to use.
/obj/vehicle/sealed/mecha/proc/ai_enter_mech(mob/living/silicon/ai/AI)
	AI.ai_restore_power()
	mecha_flags |= SILICON_PILOT
	moved_inside(AI)
	AI.cancel_camera()
	AI.controlled_mech = src
	AI.remote_control = src
	to_chat(AI, AI.can_dominate_mechs ? "<span class='announce'>Takeover of [name] complete! You are now loaded onto the onboard computer. Do not attempt to leave the station sector!</span>" :\
		"<span class='notice'>You have been uploaded to a mech's onboard computer.</span>")
	to_chat(AI, "<span class='reallybig boldnotice'>Use Middle-Mouse to activate mech functions and equipment. Click normally for AI interactions.</span>")


///Handles an actual AI (simple_animal mecha pilot) entering the mech
/obj/vehicle/sealed/mecha/proc/aimob_enter_mech(mob/living/simple_animal/hostile/syndicate/mecha_pilot/pilot_mob)
	if(!pilot_mob?.Adjacent(src))
		return
	if(LAZYLEN(occupants))
		return
	LAZYSET(occupants, pilot_mob, NONE)
	pilot_mob.mecha = src
	pilot_mob.forceMove(src)
	update_icon()

///Handles an actual AI (simple_animal mecha pilot) exiting the mech
/obj/vehicle/sealed/mecha/proc/aimob_exit_mech(mob/living/simple_animal/hostile/syndicate/mecha_pilot/pilot_mob)
	LAZYREMOVE(occupants, pilot_mob)
	if(pilot_mob.mecha == src)
		pilot_mob.mecha = null
	pilot_mob.forceMove(get_turf(src))
	update_icon()


/////////////////////////////////////
////////  Atmospheric stuff  ////////
/////////////////////////////////////

/obj/vehicle/sealed/mecha/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	return ..()

/obj/vehicle/sealed/mecha/return_air()
	if(use_internal_tank)
		return cabin_air
	return ..()

/obj/vehicle/sealed/mecha/return_analyzable_air()
	return cabin_air

/obj/vehicle/sealed/mecha/proc/return_pressure()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		return t_air.return_pressure()

/obj/vehicle/sealed/mecha/return_temperature()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		return t_air.return_temperature()

/obj/vehicle/sealed/mecha/mob_try_enter(mob/M)
	if(!ishuman(M)) // no silicons or drones in mechas.
		return
	if(HAS_TRAIT(M, TRAIT_PRIMITIVE)) //no lavalizards either.
		to_chat(M, "<span class='warning'>The knowledge to use this device eludes you!</span>")
		return
	log_message("[M] tries to move into [src].", LOG_MECHA)
	if(dna_lock && M.has_dna())
		var/mob/living/carbon/entering_carbon = M
		if(entering_carbon.dna.unique_enzymes != dna_lock)
			to_chat(M, "<span class='warning'>Access denied. [name] is secured with a DNA lock.</span>")
			log_message("Permission denied (DNA LOCK).", LOG_MECHA)
			return
	if(!operation_allowed(M))
		to_chat(M, "<span class='warning'>Access denied. Insufficient operation keycodes.</span>")
		log_message("Permission denied (No keycode).", LOG_MECHA)
		return
	if(M.buckled)
		to_chat(M, "<span class='warning'>You are currently buckled and cannot move.</span>")
		log_message("Permission denied (Buckled).", LOG_MECHA)
		return
	if(M.has_buckled_mobs()) //mob attached to us
		to_chat(M, "<span class='warning'>You can't enter the exosuit with other creatures attached to you!</span>")
		log_message("Permission denied (Attached mobs).", LOG_MECHA)
		return

	visible_message("<span class='notice'>[M] starts to climb into [name].</span>")

	if(do_after(M, enter_delay, target = src))
		if(obj_integrity <= 0)
			to_chat(M, "<span class='warning'>You cannot get in the [name], it has been destroyed!</span>")
		else if(LAZYLEN(occupants) >= max_occupants)
			to_chat(M, "<span class='danger'>[occupants[occupants.len]] was faster! Try better next time, loser.</span>")//get the last one that hopped in
		else if(M.buckled)
			to_chat(M, "<span class='warning'>You can't enter the exosuit while buckled.</span>")
		else if(M.has_buckled_mobs())
			to_chat(M, "<span class='warning'>You can't enter the exosuit with other creatures attached to you!</span>")
		else
			moved_inside(M)
			return ..()
	else
		to_chat(M, "<span class='warning'>You stop entering the exosuit!</span>")


/obj/vehicle/sealed/mecha/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_eject)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_internals)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_cycle_equip)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_lights)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_view_stats)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/strafe)

/obj/vehicle/sealed/mecha/proc/moved_inside(mob/living/newoccupant)
	if(!(newoccupant?.client))
		return FALSE
	if(ishuman(newoccupant) && !Adjacent(newoccupant))
		return FALSE
	add_occupant(newoccupant)
	newoccupant.forceMove(src)
	newoccupant.update_mouse_pointer()
	add_fingerprint(newoccupant)
	log_message("[newoccupant] moved in as pilot.", LOG_MECHA)
	setDir(dir_in)
	playsound(src, 'sound/machines/windowdoor.ogg', 50, TRUE)
	if(!internal_damage)
		SEND_SOUND(newoccupant, sound('sound/mecha/nominal.ogg',volume=50))
	return TRUE

/obj/vehicle/sealed/mecha/proc/mmi_move_inside(obj/item/mmi/M, mob/user)
	if(!M.brain_check(user))
		return FALSE

	var/mob/living/brain/B = M.brainmob
	if(LAZYLEN(occupants) >= max_occupants)
		to_chat(user, "<span class='warning'>It's full!</span>")
		return FALSE
	if(dna_lock && (!B.stored_dna || (dna_lock != B.stored_dna.unique_enzymes)))
		to_chat(user, "<span class='warning'>Access denied. [name] is secured with a DNA lock.</span>")
		return FALSE

	visible_message("<span class='notice'>[user] starts to insert an MMI into [name].</span>")

	if(do_after(user, 40, target = src))
		if(LAZYLEN(occupants) < max_occupants)
			return mmi_moved_inside(M, user)
		else
			to_chat(user, "<span class='warning'>Maximum occupants detected!</span>")
	else
		to_chat(user, "<span class='notice'>You stop inserting the MMI.</span>")
	return FALSE

/obj/vehicle/sealed/mecha/proc/mmi_moved_inside(obj/item/mmi/M, mob/user)
	if(!(Adjacent(M) && Adjacent(user)))
		return FALSE
	if(!M.brain_check(user))
		return FALSE

	var/mob/living/brain/B = M.brainmob
	if(!user.transferItemToLoc(M, src))
		to_chat(user, "<span class='warning'>\the [M] is stuck to your hand, you cannot put it in \the [src]!</span>")
		return FALSE

	M.set_mecha(src)
	add_occupant(B)//Note this forcemoves the brain into the mech to allow relaymove
	mecha_flags |= SILICON_PILOT
	B.reset_perspective(src)
	B.remote_control = src
	B.update_mouse_pointer()
	setDir(dir_in)
	log_message("[M] moved in as pilot.", LOG_MECHA)
	if(!internal_damage)
		SEND_SOUND(M, sound('sound/mecha/nominal.ogg',volume=50))
	log_game("[key_name(user)] has put the MMI/posibrain of [key_name(B)] into [src] at [AREACOORD(src)]")
	return TRUE

/obj/vehicle/sealed/mecha/container_resist_act(mob/living/user)
	if(isAI(user))
		var/mob/living/silicon/ai/AI = user
		if(!AI.can_shunt)
			to_chat(AI, "<span class='notice'>You can't leave a mech after dominating it!.</span>")
			return FALSE
	to_chat(user, "<span class='notice'>You begin the ejection procedure. Equipment is disabled during this process. Hold still to finish ejecting.</span>")
	is_currently_ejecting = TRUE
	if(do_after(user, has_gravity() ? exit_delay : 0 , target = src))
		to_chat(user, "<span class='notice'>You exit the mech.</span>")
		mob_exit(user, TRUE)
	else
		to_chat(user, "<span class='notice'>You stop exiting the mech. Weapons are enabled again.</span>")
	is_currently_ejecting = FALSE

/obj/vehicle/sealed/mecha/proc/ejectall()
	for(var/ejectee in occupants)
		mob_exit(ejectee, TRUE, TRUE)

/obj/vehicle/sealed/mecha/mob_exit(mob/M, silent, forced)
	var/newloc = get_turf(src)
	var/atom/movable/mob_container
	if(ishuman(M))
		mob_container = M
	else if(isbrain(M))
		var/mob/living/brain/brain = M
		mob_container = brain.container
	else if(isAI(M))
		var/mob/living/silicon/ai/AI = M
		if(forced)//This should only happen if there are multiple AIs in a round, and at least one is Malf.
			AI.gib()  //If one Malf decides to steal a mech from another AI (even other Malfs!), they are destroyed, as they have nowhere to go when replaced.
			AI = null
			mecha_flags &= ~SILICON_PILOT
			return
		else
			if(!AI.linked_core)
				to_chat(AI, "<span class='userdanger'>Inactive core destroyed. Unable to return.</span>")
				AI.linked_core = null
				return
			to_chat(AI, "<span class='notice'>Returning to core...</span>")
			AI.controlled_mech = null
			AI.remote_control = null
			mob_container = AI
			newloc = get_turf(AI.linked_core)
			qdel(AI.linked_core)
	else
		return ..()
	var/mob/living/L = M
	mecha_flags  &= ~SILICON_PILOT
	if(mob_container.forceMove(newloc))//ejecting mob container
		log_message("[mob_container] moved out.", LOG_MECHA)
		L << browse(null, "window=exosuit")

		if(istype(mob_container, /obj/item/mmi))
			var/obj/item/mmi/mmi = mob_container
			if(mmi.brainmob)
				L.forceMove(mmi)
				L.reset_perspective()
				remove_occupant(L)
			mmi.set_mecha(null)
			mmi.update_icon()
		setDir(dir_in)
	return ..()


/obj/vehicle/sealed/mecha/add_occupant(mob/M, control_flags)
	RegisterSignal(M, COMSIG_LIVING_DEATH, .proc/mob_exit)
	RegisterSignal(M, COMSIG_MOB_CLICKON, .proc/on_mouseclick)
	RegisterSignal(M, COMSIG_MOB_MIDDLECLICKON, .proc/on_middlemouseclick) //For AIs
	RegisterSignal(M, COMSIG_MOB_SAY, .proc/display_speech_bubble)
	. = ..()
	update_icon()

/obj/vehicle/sealed/mecha/remove_occupant(mob/M)
	UnregisterSignal(M, COMSIG_LIVING_DEATH)
	UnregisterSignal(M, COMSIG_MOB_CLICKON)
	UnregisterSignal(M, COMSIG_MOB_MIDDLECLICKON)
	UnregisterSignal(M, COMSIG_MOB_SAY)
	M.clear_alert("charge")
	M.clear_alert("mech damage")
	if(M.client)
		M.update_mouse_pointer()
		M.client.view_size.resetToDefault()
		zoom_mode = 0
	. = ..()
	update_icon()

/////////////////////////
////// Access stuff /////
/////////////////////////

/obj/vehicle/sealed/mecha/proc/operation_allowed(mob/M)
	req_access = operation_req_access
	req_one_access = list()
	return allowed(M)

/obj/vehicle/sealed/mecha/proc/internals_access_allowed(mob/M)
	req_one_access = internals_req_access
	req_access = list()
	return allowed(M)


///////////////////////
///// Power stuff /////
///////////////////////

/obj/vehicle/sealed/mecha/proc/has_charge(amount)
	return (get_charge()>=amount)

/obj/vehicle/sealed/mecha/proc/get_charge()
	for(var/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/R in equipment)
		var/relay_charge = R.get_charge()
		if(relay_charge)
			return relay_charge
	if(cell)
		return max(0, cell.charge)

/obj/vehicle/sealed/mecha/proc/use_power(amount)
	if(get_charge() && cell.use(amount))
		return TRUE
	return FALSE

/obj/vehicle/sealed/mecha/proc/give_power(amount)
	if(!isnull(get_charge()))
		cell.give(amount)
		return TRUE
	return FALSE

///////////////////////
////// Ammo stuff /////
///////////////////////

/obj/vehicle/sealed/mecha/proc/ammo_resupply(obj/item/mecha_ammo/A, mob/user,fail_chat_override = FALSE)
	if(!A.rounds)
		if(!fail_chat_override)
			to_chat(user, "<span class='warning'>This box of ammo is empty!</span>")
		return FALSE
	var/ammo_needed
	var/found_gun
	for(var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun in equipment)
		ammo_needed = 0

		if(istype(gun, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic) && gun.ammo_type == A.ammo_type)
			found_gun = TRUE
			if(A.direct_load)
				ammo_needed = initial(gun.projectiles) - gun.projectiles
			else
				ammo_needed = gun.projectiles_cache_max - gun.projectiles_cache

			if(ammo_needed)
				if(ammo_needed < A.rounds)
					if(A.direct_load)
						gun.projectiles = gun.projectiles + ammo_needed
					else
						gun.projectiles_cache = gun.projectiles_cache + ammo_needed
					playsound(get_turf(user),A.load_audio,50,TRUE)
					to_chat(user, "<span class='notice'>You add [ammo_needed] [A.round_term][ammo_needed > 1?"s":""] to the [gun.name]</span>")
					A.rounds = A.rounds - ammo_needed
					if(A.custom_materials)
						A.set_custom_materials(A.custom_materials, A.rounds / initial(A.rounds))
					A.update_name()
					return TRUE

				else
					if(A.direct_load)
						gun.projectiles = gun.projectiles + A.rounds
					else
						gun.projectiles_cache = gun.projectiles_cache + A.rounds
					playsound(get_turf(user),A.load_audio,50,TRUE)
					to_chat(user, "<span class='notice'>You add [A.rounds] [A.round_term][A.rounds > 1?"s":""] to the [gun.name]</span>")
					A.rounds = 0
					A.set_custom_materials(list(/datum/material/iron=2000))
					A.update_name()
					return TRUE
	if(!fail_chat_override)
		if(found_gun)
			to_chat(user, "<span class='notice'>You can't fit any more ammo of this type!</span>")
		else
			to_chat(user, "<span class='notice'>None of the equipment on this exosuit can use this ammo!</span>")
	return FALSE
