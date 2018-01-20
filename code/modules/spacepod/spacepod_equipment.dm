/obj/item/device/spacepod_equipment
	name = "equipment"
	var/obj/vehicle/sealed/spacepod/my_atom
	var/size = POD_EQUIPMENT_SMALL
	var/slot
	var/occupant_mod = 0	// so any module can modify occupancy
	var/list/storage_mod = list("slots" = 0, "w_class" = 0)		// so any module can modify storage slots
	var/syndicate = FALSE
	var/power_use = 0

/obj/item/device/spacepod_equipment/proc/added(mob/user) // So that you can unload cargo when you remove the module
	my_atom.update_icon()

/obj/item/device/spacepod_equipment/proc/removed(mob/user) // So that you can unload cargo when you remove the module
	my_atom.update_icon()

/obj/item/device/spacepod_equipment/proc/on_power_loss()
	return


/obj/item/device/spacepod_equipment/action
	var/datum/action/vehicle/spacepod/equipment/action_type

/obj/item/device/spacepod_equipment/action/added(mob/user)
	. = ..()
	my_atom.initialize_controller_action_type(action_type, VEHICLE_CONTROL_PERMISSION)

/obj/item/device/spacepod_equipment/action/removed(mob/user)
	. = ..()
	my_atom.remove_controller_actions(action_type)

/obj/item/device/spacepod_equipment/action/proc/action_trigger(mob/owner)
	return

/*
///////////////////////////////////////
/////////Weapon System///////////////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/weaponry
	name = "pod weapon"
	desc = "You shouldn't be seeing this"
	icon = 'icons/obj/spacepod.dmi'
	icon_state = "blank"
	slot = POD_EQUIPMENT_WEAPON
	var/obj/item/projectile/projectile_type
	var/shot_cost = 0
	var/shots_per = 1
	var/fire_sound
	var/fire_delay = 15
	var/overlay_icon

/obj/item/device/spacepod_equipment/weaponry/disabler
	name = "disabler system"
	desc = "A weak disabler system for space pods, fires disabler beams."
	icon_state = "weapon_taser"
	projectile_type = /obj/item/projectile/beam/disabler
	shot_cost = 400
	fire_sound = 'sound/weapons/taser2.ogg'
	overlay_icon = "pod_weapon_disabler"

/obj/item/device/spacepod_equipment/weaponry/burst_disabler
	name = "burst disabler system"
	desc = "A weak disabler system for space pods, this one fires 3 at a time."
	icon_state = "weapon_burst_taser"
	projectile_type = /obj/item/projectile/beam/disabler
	shot_cost = 1200
	shots_per = 3
	fire_sound = 'sound/weapons/taser2.ogg'
	fire_delay = 30
	overlay_icon = "pod_weapon_disabler"

/obj/item/device/spacepod_equipment/weaponry/laser
	name = "laser system"
	desc = "A weak laser system for space pods, fires concentrated bursts of energy."
	icon_state = "weapon_laser"
	projectile_type = /obj/item/projectile/beam
	shot_cost = 600
	fire_sound = 'sound/weapons/Laser.ogg'
	overlay_icon = "pod_weapon_laser"

// MINING LASERS
/obj/item/device/spacepod_equipment/weaponry/basic_pod_ka
	name = "weak kinetic accelerator"
	desc = "A weak kinetic accelerator for space pods, fires bursts of energy that cut through rock."
	icon = 'goon/icons/pods/ship.dmi'
	icon_state = "pod_taser"
	projectile_type = /obj/item/projectile/kinetic/pod
	shot_cost = 300
	fire_delay = 14
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'

/obj/item/device/spacepod_equipment/weaponry/pod_ka
	name = "kinetic accelerator system"
	desc = "A kinetic accelerator system for space pods, fires bursts of energy that cut through rock."
	icon = 'goon/icons/pods/ship.dmi'
	icon_state = "pod_m_laser"
	projectile_type = /obj/item/projectile/kinetic/pod/regular
	shot_cost = 250
	fire_delay = 10
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'

/obj/item/device/spacepod_equipment/weaponry/plasma_cutter
	name = "plasma cutter system"
	desc = "A plasma cutter system for space pods. It is capable of expelling concentrated plasma bursts to mine or cut off xeno limbs!"
	icon = 'goon/icons/pods/ship.dmi'
	icon_state = "pod_p_cutter"
	projectile_type = /obj/item/projectile/plasma
	shot_cost = 250
	fire_delay = 10
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	overlay_icon = "pod_weapon_plasma"

/obj/item/device/spacepod_equipment/weaponry/plasma_cutter/adv
	name = "enhanced plasma cutter system"
	desc = "An enhanced plasma cutter system for space pods. It is capable of expelling concentrated plasma bursts to mine or cut off xeno faces!"
	icon_state = "pod_ap_cutter"
	projectile_type = /obj/item/projectile/plasma/adv
	shot_cost = 200
	fire_delay = 8

/obj/item/device/spacepod_equipment/weaponry/proc/fire_weapons(mob/user)
	if(my_atom.next_firetime > world.time)
		to_chat(user, "<span class='warning'>Your weapons are recharging.</span>")
		return
	var/turf/firstloc
	var/turf/secondloc
	if(!my_atom.cell.use(shot_cost))
		to_chat(user, "<span class='warning'>Insufficient charge to fire the weapons</span>")
		return
	var/olddir
	for(var/i in 0 to shots_per-1)
		if(olddir != my_atom.dir)
			switch(my_atom.dir)
				if(NORTH)
					firstloc = get_step(my_atom, NORTH)
					secondloc = get_step(firstloc,EAST)
				if(SOUTH)
					firstloc = get_turf(my_atom)
					secondloc = get_step(firstloc,EAST)
				if(EAST)
					firstloc = get_step(my_atom, EAST)
					secondloc = get_step(firstloc,NORTH)
				if(WEST)
					firstloc = get_turf(my_atom)
					secondloc = get_step(firstloc,NORTH)
		olddir = dir
		var/obj/item/projectile/projone = new projectile_type(firstloc)
		var/obj/item/projectile/projtwo = new projectile_type(secondloc)
		projone.starting = get_turf(my_atom)
		projone.firer = user
		projone.def_zone = "chest"
		projtwo.starting = get_turf(my_atom)
		projtwo.firer = user
		projtwo.def_zone = "chest"
		INVOKE_ASYNC(src, .proc/do_fire, projone, projtwo)
	my_atom.next_firetime = world.time + fire_delay
	var/mob/pilot = my_atom.get_driver()
	log_attack("The spacepod \[name: [my_atom.name], [pilot ? "pilot: [pilot.name], ckey: [pilot.ckey]" : "no pilot?"])\], fired the [name].")

/obj/item/device/spacepod_equipment/weaponry/proc/do_fire(obj/item/projectile/projone, obj/item/projectile/projtwo)
	playsound(src, fire_sound, 50, 1)
	var/angle_to_fire = dir2angle(my_atom.dir)
	projone.fire(angle_to_fire)
	projtwo.fire(angle_to_fire)


/*
///////////////////////////////////////
/////////Misc. System///////////////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/misc
	name = "pod misc"
	desc = "You shouldn't be seeing this"
	icon = 'goon/icons/pods/ship.dmi'
	icon_state = "blank"
	var/enabled = TRUE

/obj/item/device/spacepod_equipment/misc/tracker
	name = "\improper spacepod tracking system"
	desc = "A tracking device for spacepods."
	icon_state = "pod_locator"
	size = POD_EQUIPMENT_SMALL

/obj/item/device/spacepod_equipment/misc/tracker/screwdriver_act(mob/user, obj/item/tool)
	enabled = !enabled
	to_chat(user, "<span class='notice'>You [enabled ? "enable" : "disable"] the tracker.</span>")

/*
///////////////////////////////////////
/////////Cargo System//////////////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/cargo
	name = "pod cargo"
	desc = "You shouldn't be seeing this"
	icon = 'icons/obj/spacepod.dmi'
	icon_state = "cargo_blank"
	size = POD_EQUIPMENT_LARGE
	var/obj/storage = null

/obj/item/device/spacepod_equipment/cargo/proc/passover(obj/item/I)
	return

/obj/item/device/spacepod_equipment/cargo/proc/unload() // called by unload verb
	if(storage)
		storage.forceMove(get_turf(my_atom))
		storage = null

/obj/item/device/spacepod_equipment/cargo/removed(mob/user) // called when system removed
	. = ..()
	unload()

// Ore System
/obj/item/device/spacepod_equipment/cargo/ore
	name = "spacepod ore scoop system"
	desc = "An ore storage system for spacepods. Scoops up any ore you drive over. Requires a loaded ore box."
	icon_state = "cargo_ore"

/obj/item/device/spacepod_equipment/cargo/ore/passover(obj/item/I)
	if(storage && istype(I,/obj/item/ore))
		I.forceMove(storage)

// Crate System
/obj/item/device/spacepod_equipment/cargo/crate
	name = "spacepod crate storage system"
	desc = "A heavy duty storage system for spacepods. Holds one crate."
	icon_state = "cargo_crate"

/*
///////////////////////////////////////
/////////Secondary Cargo System////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/sec_cargo
	name = "secondary cargo"
	desc = "you shouldn't be seeing this"
	icon = 'icons/obj/spacepod.dmi'
	icon_state = "blank"
	size = POD_EQUIPMENT_MEDIUM

// Passenger Seat
/obj/item/device/spacepod_equipment/sec_cargo/chair
	name = "passenger seat"
	desc = "A passenger seat for a spacepod."
	icon_state = "sec_cargo_chair"
	occupant_mod = 1

/obj/item/device/spacepod_equipment/sec_cargo/back_seat
	name = "dual passenger seat"
	desc = "A passenger seat for a spacepod. It fits 2!"
	icon_state = "sec_cargo_chair"
	occupant_mod = 2

// Loot Box
/obj/item/device/spacepod_equipment/sec_cargo/loot_box
	name = "loot box"
	desc = "A small compartment to store valuables."
	icon_state = "sec_cargo_loot"
	storage_mod = list("slots" = 7, "w_class" = 14)




/*
///////////////////////////////////////
/////////Lock System///////////////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/lock
	name = "pod lock"
	desc = "You shouldn't be seeing this"
	icon = 'icons/obj/spacepod.dmi'
	icon_state = "blank"
	slot = POD_EQUIPMENT_LOCK
	var/mode = 0
	var/id = null

// Key and Tumbler System
/obj/item/device/spacepod_equipment/lock/keyed
	name = "spacepod tumbler lock"
	desc = "A locking system to stop podjacking. This version uses a standalone key."
	icon_state = "lock_tumbler"
	var/static/id_source = 0

/obj/item/device/spacepod_equipment/lock/keyed/Initialize()
	. = ..()
	if(!id)
		id = ++id_source

// The key
/obj/item/device/spacepod_key
	name = "spacepod key"
	desc = "A key for a spacepod lock."
	icon = 'icons/obj/spacepod.dmi'
	icon_state = "podkey"
	w_class = WEIGHT_CLASS_TINY
	var/id = 0

// Key - Lock Interactions
/obj/item/device/spacepod_equipment/lock/keyed/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/device/spacepod_key))
		var/obj/item/device/spacepod_key/key = I
		if(!key.id)
			key.id = id
			to_chat(user, "<span class='notice'>You grind the blank key to fit the lock.</span>")
		else
			to_chat(user, "<span class='warning'>This key is already ground!</span>")
	else
		..()



////////////////////////
//// SYNDICATE SHIT ////
////////////////////////


/obj/item/device/spacepod_equipment/action/cloaker
	name = "syndicate cloaker"
	icon = 'icons/obj/spacepod.dmi'
	icon_state = "blank"
	slot = POD_EQUIPMENT_SYNDIE
	syndicate = TRUE
	action_type = /datum/action/vehicle/spacepod/equipment/cloaker
	var/active = FALSE

/obj/item/device/spacepod_equipment/action/cloaker/on_power_loss()
	my_atom.message_to_riders("<span class='warning'>\The [src] has lost power!</span>")
	animate(my_atom, alpha = 255, time = 12.5)

/obj/item/device/spacepod_equipment/action/cloaker/action_trigger(mob/owner)
	active = !active
	if(!my_atom.cell || my_atom.cell.charge < 25)
		active = FALSE
		power_use = 0
		to_chat(owner, "<span class='warning'>Not enough power for the spacepod cloaker!")
	else if(owner)
		to_chat(owner, "<span class='notice'>You turn the spacepod cloaker [active ? "on" : "off"]")

	if(active)
		animate(my_atom, alpha = 25, time = 15)
		power_use = 25
	else
		animate(my_atom, alpha = 255, time = 15)
		power_use = 0

///////////////////
//// THRUSTERS ////
///////////////////

/obj/item/device/spacepod_equipment/thruster
	name = "mk1 ion engine"
	desc = "A basic ion engine for a spacepod. Moderate speed."
	slot = POD_EQUIPMENT_THRUSTER
	icon = 'goon/icons/pods/pod_parts.dmi'
	icon_state = "pod_vtec"
	var/move_delay = 1.5
	var/power_on_move = 1
	var/pressure_sensitive = TRUE
	var/max_pressure = (ONE_ATMOSPHERE * 0.45)

///
/obj/item/device/lock_buster
	name = "pod lock buster"
	desc = "Destroys a podlock in mere seconds once applied. Waranty void if used."
	icon_state = "lock_buster_off"
	var/on = FALSE

/obj/item/device/lock_buster/attack_self(mob/user)
	on = !on
	if(on)
		icon_state = "lock_buster_on"
	else
		icon_state = "lock_buster_off"
	to_chat(user, "<span class='notice'>You turn the [src] [on ? "on" : "off"].</span>")