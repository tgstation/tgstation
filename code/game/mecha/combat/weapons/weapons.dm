/datum/mecha_weapon
	var/name = "mecha weapon"
	var/weapon_cooldown = 0
	var/weapon_ready = 1
	var/energy_drain = 0
	var/obj/mecha/combat/chassis = null


/datum/mecha_weapon/New(mecha)
	if(!istype(mecha, /obj/mecha/combat))
		return
	src.chassis = mecha
	return

/datum/mecha_weapon/proc/fire(target) //general checks.
	if(!target)
		return 0
	if(!chassis)
		return 0
	if(energy_drain && chassis.cell.charge < energy_drain)
		return 0
	if(!weapon_ready)
		return 0
	return 1



/datum/mecha_weapon/missile_rack
	name = "SRM-8 Missile Rack"
	var/missiles = 8
	var/missile_speed = 2
	var/missile_range = 30
	var/missile_energy_cost = 1000
	weapon_cooldown = 60

	fire(target)
		if(!..() || missiles <=0) return
		var/obj/item/missile/M = new /obj/item/missile(chassis.loc)
		M.primed = 1
		M.throw_at(target, missile_range, missile_speed)
		weapon_ready = 0
		missiles--
		spawn(weapon_cooldown)
			weapon_ready = 1
		return

	proc/rearm()
		if(missiles < initial(missiles))
			var/missiles_to_add = initial(missiles) - missiles
			while(chassis.cell.charge >= missile_energy_cost && missiles_to_add)
				missiles++
				missiles_to_add--
				chassis.cell.charge -= missile_energy_cost
		return


/obj/item/missile
	icon = 'grenade.dmi'
	icon_state = "flashbang"
	var/primed = null
	throwforce = 15

	throw_impact(atom/hit_atom)
		if(primed)
			explosion(hit_atom, 0, 0, 2, 4)
			del(src)
		else
			..()
		return


/datum/mecha_weapon/laser
	weapon_cooldown = 10
	name = "CH-PS \"Immolator\" Laser"
	energy_drain = 20

	fire(target)
		if(!..()) return

		var/turf/curloc = chassis.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return
		if (targloc == curloc)
			return

		playsound(chassis, 'Laser.ogg', 50, 1)
		var/obj/beam/a_laser/A = new /obj/beam/a_laser(curloc)
		A.current = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		weapon_ready = 0
		chassis.cell.use(energy_drain)
		spawn()
			A.process()
		spawn(weapon_cooldown)
			weapon_ready = 1

		return



/datum/mecha_weapon/pulse
	weapon_cooldown = 50
	name = "eZ-13 mk2 Heavy pulse rifle"
	energy_drain = 50

	fire(target)
		if(!..()) return

		var/turf/curloc = chassis.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return
		if (targloc == curloc)
			return

		playsound(chassis, 'marauder.ogg', 50, 1)
		var/obj/beam/a_laser/A = new /obj/beam/a_laser/pulse_laser(curloc)
		A.current = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		weapon_ready = 0
		chassis.cell.use(energy_drain)
		spawn()
			A.process()
		spawn(weapon_cooldown)
			weapon_ready = 1

		return

/*
/datum/mecha_weapon/scattershot
	name = "Scuttershot"
	var/missiles = 8
	var/missile_speed = 2
	var/missile_range = 30
	var/missile_energy_cost = 1000
	weapon_cooldown = 60

	fire(target)
		if(!..() || missiles <=0) return
		var/obj/item/missile/M = new /obj/item/missile(chassis.loc)
		M.primed = 1
		M.throw_at(target, missile_range, missile_speed)
		weapon_ready = 0
		missiles--
		spawn(weapon_cooldown)
			weapon_ready = 1
		return

	proc/rearm()
		if(missiles < initial(missiles))
			var/missiles_to_add = initial(missiles) - missiles
			while(chassis.cell.charge >= missile_energy_cost && missiles_to_add)
				missiles++
				missiles_to_add--
				chassis.cell.charge -= missile_energy_cost
		return
*/
