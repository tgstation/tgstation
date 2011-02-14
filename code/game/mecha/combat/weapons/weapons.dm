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
	chassis.log_append_to_last("[src.name] initialized.")
	return

/datum/mecha_weapon/proc/destroy()
	spawn
		del src
	return


/datum/mecha_weapon/proc/get_weapon_info()
	return src.name


/datum/mecha_weapon/proc/fire_checks(target) //general checks.
	if(!target)
		return 0
	if(!chassis)
		return 0
	if(energy_drain && chassis.cell.charge < energy_drain)
		return 0
	if(!weapon_ready)
		return 0
	return 1

/datum/mecha_weapon/proc/fire(target)
	return fire_checks(target)



/datum/mecha_weapon/missile_rack //TODO: move missile racks to ballistic class
	name = "SRM-8 Missile Rack"
	var/missiles = 8
	var/missile_speed = 2
	var/missile_range = 30
	var/missile_energy_cost = 1000
	weapon_cooldown = 60

	fire(target)
		if(!fire_checks(target) || missiles <=0) return
		weapon_ready = 0
		var/obj/item/missile/M = new /obj/item/missile(chassis.loc)
		M.primed = 1
		playsound(chassis, 'bang.ogg', 50, 1)
		M.throw_at(target, missile_range, missile_speed)
		missiles--
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Fired from [src.name], targeting [target].")
		return

	proc/rearm()
		if(missiles < initial(missiles))
			var/missiles_to_add = initial(missiles) - missiles
			while(chassis.cell.charge >= missile_energy_cost && missiles_to_add)
				missiles++
				missiles_to_add--
				chassis.cell.charge -= missile_energy_cost
		chassis.log_message("Rearmed [src.name].")
		return

	get_weapon_info()
		return "[src.name]\[[src.missiles]\][(src.missiles < initial(src.missiles))?" - <a href='?src=\ref[src];rearm=1'>Rearm</a>":null]"

	Topic(href, href_list)
		if (href_list["rearm"])
			src.rearm()
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

/datum/mecha_weapon/missile_rack/flashbang
	name = "SGL-6 Grenade Launcher"
	missiles = 6
	missile_speed = 1.5
	missile_energy_cost = 800
	weapon_cooldown = 60
	var/det_time = 20

	fire(target)
		if(!fire_checks(target) || missiles <=0) return
		weapon_ready = 0
		var/obj/item/weapon/flashbang/F = new /obj/item/weapon/flashbang(chassis.loc)
		playsound(chassis, 'bang.ogg', 50, 1)
		F.throw_at(target, missile_range, missile_speed)
		missiles--
		spawn(det_time)
			F.prime()
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Fired from [src.name], targeting [target].")
		return

/datum/mecha_weapon/laser
	weapon_cooldown = 10
	name = "CH-PS \"Immolator\" Laser"
	energy_drain = 30

	fire(target)
		if(!fire_checks(target)) return

		var/turf/curloc = chassis.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return
		if (targloc == curloc)
			return
		weapon_ready = 0
		playsound(chassis, 'Laser.ogg', 50, 1)
		var/obj/beam/a_laser/A = new /obj/beam/a_laser(curloc)
		A.current = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		chassis.cell.use(energy_drain)
		A.process()
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Fired from [src.name], targeting [target].")
		return


/datum/mecha_weapon/pulse
	weapon_cooldown = 30
	name = "eZ-13 mk2 Heavy pulse rifle"
	energy_drain = 120

	fire(target)
		if(!fire_checks(target)) return

		var/turf/curloc = chassis.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return
		if (targloc == curloc)
			return

		playsound(chassis, 'marauder.ogg', 50, 1)
		var/obj/beam/a_laser/A = new /obj/beam/a_laser/pulse_laser/heavy_pulse(curloc)
		A.current = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		weapon_ready = 0
		chassis.cell.use(energy_drain)
		A.process()
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Fired from [src.name], targeting [target].")
		return


/obj/beam/a_laser/pulse_laser/heavy_pulse
	name = "heavy pulse laser"
	icon_state = "u_laser"
	life = 20

	Bump(atom/A)
		A.bullet_act(PROJECTILE_PULSE)
		src.life -= 10
		return

/datum/mecha_weapon/taser
	weapon_cooldown = 10
	name = "PBT \"Pacifier\" Mounted Taser"
	energy_drain = 20
	weapon_cooldown = 7

	fire(target)
		if(!fire_checks(target)) return

		var/turf/curloc = chassis.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return
		if (targloc == curloc)
			return

		playsound(chassis, 'Laser.ogg', 50, 1)
		var/obj/bullet/electrode/A = new /obj/bullet/electrode(curloc)
		A.current = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		weapon_ready = 0
		chassis.cell.use(energy_drain)
		spawn()
			A.process()
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Fired from [src.name], targeting [target].")
		return

/datum/mecha_weapon/missile_rack/banana_mortar
	name = "Banana Mortar"
	missiles = 15
	missile_speed = 1.5
	missile_energy_cost = 100
	weapon_cooldown = 20

	fire(target)
		if(!fire_checks(target) || missiles <=0) return
		weapon_ready = 0
		var/obj/item/weapon/bananapeel/B = new /obj/item/weapon/bananapeel(chassis.loc)
		playsound(chassis, 'bikehorn.ogg', 60, 1)
		B.throw_at(target, missile_range, missile_speed)
		missiles--
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Bananed from [src.name], targeting [target]. HONK!")
		return


/datum/mecha_weapon/missile_rack/mousetrap_mortar
	name = "Mousetrap Mortar"
	missiles = 15
	missile_speed = 1.5
	missile_energy_cost = 100
	weapon_cooldown = 10

	fire(target)
		if(!fire_checks(target) || missiles <=0) return
		weapon_ready = 0
		var/obj/item/weapon/mousetrap/M = new /obj/item/weapon/mousetrap(chassis.loc)
		M.armed = 1
		playsound(chassis, 'bikehorn.ogg', 60, 1)
		M.throw_at(target, missile_range, missile_speed)
		missiles--
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Launched a mouse-trap from [src.name], targeting [target]. HONK!")
		return


/datum/mecha_weapon/honker
	weapon_cooldown = 10
	name = "HoNkER BlAsT 5000"
	energy_drain = 200
	weapon_cooldown = 150

	fire(target)
		if(!chassis)
			return 0
		if(energy_drain && chassis.cell.charge < energy_drain)
			return 0
		if(!weapon_ready)
			return 0
		weapon_ready = 0
		playsound(chassis, 'AirHorn.ogg', 100, 1)
		chassis.occupant_message("<font color='red' size='5'>HONK</font>")
		for(var/mob/living/carbon/M in ohearers(6, chassis))
			if(istype(M, /mob/living/carbon/human) && istype(M:ears, /obj/item/clothing/ears/earmuffs))
				continue
			M << "<font color='red' size='7'>HONK</font>"
			M.sleeping = 0
			M.stuttering += 20
			M.ear_deaf += 30
			M.weakened = 3
			if(prob(30))
				M.stunned = 10
				M.paralysis += 4
			else
				M.make_jittery(500)
			/* //else the mousetraps are useless
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(isobj(H.shoes))
					var/thingy = H.shoes
					H.drop_from_slot(H.shoes)
					walk_away(thingy,chassis,15,2)
					spawn(20)
						if(thingy)
							walk(thingy,0)
			*/
		chassis.cell.use(energy_drain)
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Honked from [src.name]. HONK!")
		return



/datum/mecha_weapon/ballistic
	name = "General Ballisic Weapon"
	var/projectiles
	var/projectile_energy_cost

	get_weapon_info()
		return "[src.name]\[[src.projectiles]\][(src.projectiles < initial(src.projectiles))?" - <a href='?src=\ref[src];rearm=1'>Rearm</a>":null]"

	proc/rearm()
		if(projectiles < initial(projectiles))
			var/projectiles_to_add = initial(projectiles) - projectiles
			while(chassis.cell.charge >= projectile_energy_cost && projectiles_to_add)
				projectiles++
				projectiles_to_add--
				chassis.cell.charge -= projectile_energy_cost
		chassis.log_message("Rearmed [src.name].")
		return

	Topic(href, href_list)
		if (href_list["rearm"])
			src.rearm()
		return


/datum/mecha_weapon/ballistic/scattershot
	name = "LBX AC 10 \"Scattershot\""
	weapon_cooldown = 20
	projectiles = 100
	projectile_energy_cost = 25
	var/projectiles_per_shot = 4
	var/deviation = 0.7

	fire(atom/target)
		if(!fire_checks(target) || projectiles <=0) return
		var/turf/curloc = get_turf(chassis)
		var/turf/targloc = get_turf(target)
		if(!curloc || !targloc) return
		var/target_x = targloc.x
		var/target_y = targloc.y
		var/target_z = targloc.z
		targloc = null
		for(var/i=1 to min(projectiles, projectiles_per_shot))
			targloc = locate(target_x+GaussRandRound(deviation,1),target_y+GaussRandRound(deviation,1),target_z)
			if(!targloc || targloc == curloc)
				break
			playsound(chassis, 'Gunshot.ogg', 80, 1)
			var/obj/bullet/A = new /obj/bullet(curloc)
			src.projectiles--
			A.current = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			weapon_ready = 0
			A.process()
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Fired from [src.name], targeting [target].")
		return



/datum/mecha_weapon/ballistic/lmg
	name = "Ultra AC 2"
	weapon_cooldown = 10
	projectiles = 300
	projectile_energy_cost = 20
	var/projectiles_per_shot = 3
	var/deviation = 0.3

	fire(atom/target)
		if(!fire_checks(target) || projectiles <=0) return
		var/turf/targloc = get_turf(target)
		var/target_x = targloc.x
		var/target_y = targloc.y
		var/target_z = targloc.z
		targloc = null
		spawn	for(var/i=1 to min(projectiles, projectiles_per_shot))
			if(!chassis) break
			var/turf/curloc = get_turf(chassis)
			targloc = locate(target_x+GaussRandRound(deviation,1),target_y+GaussRandRound(deviation,1),target_z)
			if (!targloc || !curloc)
				continue
			if (targloc == curloc)
				continue
			playsound(chassis, 'Gunshot.ogg', 50, 1)
			var/obj/bullet/weakbullet/A = new /obj/bullet/weakbullet(curloc)
			src.projectiles--
			A.current = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			A.process()
			sleep(2)
		weapon_ready = 0
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Fired from [src.name], targeting [target].")
		return