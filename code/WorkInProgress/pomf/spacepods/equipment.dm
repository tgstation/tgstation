/obj/item/device/spacepod_equipment/weaponry/proc/fire_weapons()

	if(my_atom.next_firetime > world.time)
		usr << "<span class='warning'>Your weapons are recharging.</span>"
		return
	var/turf/firstloc
	var/turf/secondloc
	if(!my_atom.equipment_system || !my_atom.equipment_system.weapon_system)
		usr << "<span class='warning'>Missing equipment or weapons.</span>"
		my_atom.verbs -= text2path("[type]/proc/fire_weapons")
		return
	my_atom.battery.use(shot_cost)
	var/olddir
	for(var/i = 0; i < shots_per; i++)
		if(olddir != dir)
			switch(dir)
				if(NORTH)
					firstloc = get_step(src, NORTH)
					secondloc = get_step(firstloc,EAST)
				if(SOUTH)
					firstloc = get_turf(src)
					secondloc = get_step(firstloc,EAST)
				if(EAST)
					firstloc = get_turf(src)
					firstloc = get_step(firstloc, EAST)
					secondloc = get_step(firstloc,NORTH)
				if(WEST)
					firstloc = get_turf(src)
					secondloc = get_step(firstloc,NORTH)
		olddir = dir
		var/obj/item/projectile/projone = new projectile_type(firstloc)
		var/obj/item/projectile/projtwo = new projectile_type(secondloc)
		projone.starting = get_turf(src)
		projone.shot_from = src
		projone.firer = usr
		projone.def_zone = "chest"
		projtwo.starting = get_turf(src)
		projtwo.shot_from = src
		projtwo.firer = usr
		projtwo.def_zone = "chest"
		spawn()
			playsound(src, fire_sound, 50, 1)
			projone.dumbfire(dir)
			projtwo.dumbfire(dir)
		sleep(1)
	my_atom.next_firetime = world.time + fire_delay

/datum/spacepod/equipment
	var/obj/spacepod/my_atom
	var/obj/item/device/spacepod_equipment/weaponry/weapon_system // weapons system
	//var/obj/item/device/spacepod_equipment/engine/engine_system // engine system
	//var/obj/item/device/spacepod_equipment/shield/shield_system // shielding system

/datum/spacepod/equipment/New(var/obj/spacepod/SP)
	..()
	if(istype(SP))
		my_atom = SP

/obj/item/device/spacepod_equipment
	name = "equipment"
	var/obj/spacepod/my_atom
// base item for spacepod weapons

/obj/item/device/spacepod_equipment/weaponry
	name = "pod weapon"
	desc = "You shouldn't be seeing this"
	icon = 'icons/pods/ship.dmi'
	icon_state = "blank"
	var/projectile_type
	var/shot_cost = 0
	var/shots_per = 1
	var/fire_sound
	var/fire_delay = 10

/obj/item/device/spacepod_equipment/weaponry/taser
	name = "\improper taser system"
	desc = "A weak taser system for space pods, fires electrodes that shock upon impact."
	icon_state = "pod_taser"
	projectile_type = "/obj/item/projectile/energy/electrode"
	shot_cost = 10
	fire_sound = "sound/weapons/Taser.ogg"

/obj/item/device/spacepod_equipment/weaponry/taser/proc/fire_weapon_system()
	set category = "Spacepod"
	set name = "Fire Taser System"
	set desc = "Fire ze tasers!"
	set src = usr.loc

	fire_weapons()

/obj/item/device/spacepod_equipment/weaponry/taser/burst
	name = "\improper taser system"
	desc = "A weak taser system for space pods, this one fires 3 at a time."
	icon_state = "pod_b_taser"
	shot_cost = 20
	shots_per = 3

/obj/item/device/spacepod_equipment/weaponry/laser
	name = "\improper laser system"
	desc = "A weak laser system for space pods, fires concentrated bursts of energy"
	icon_state = "pod_w_laser"
	projectile_type = "/obj/item/projectile/beam"
	shot_cost = 15
	fire_sound = 'sound/weapons/Laser.ogg'
	fire_delay = 25

/obj/item/device/spacepod_equipment/weaponry/laser/proc/fire_weapon_system()
	set category = "Spacepod"
	set name = "Fire Laser System"
	set desc = "Fire ze lasers!"
	set src = usr.loc

	fire_weapons()