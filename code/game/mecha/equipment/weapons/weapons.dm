/obj/item/mecha_parts/mecha_equipment/weapon
	name = "mecha weapon"
	range = RANGED
	origin_tech = "materials=3;combat=3"
	var/projectile
	var/fire_sound


/obj/item/mecha_parts/mecha_equipment/weapon/can_attach(var/obj/mecha/combat/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0


/obj/item/mecha_parts/mecha_equipment/weapon/energy
	name = "general energy weapon"

	action(target)
		if(!action_checks(target)) return
		var/turf/curloc = chassis.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return
		if (targloc == curloc)
			return
		set_ready_state(0)
		playsound(chassis, fire_sound, 50, 1)
		var/obj/item/projectile/A = new projectile(curloc)
		A.firer = chassis.occupant
		A.original = target
		A.current = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		chassis.use_power(energy_drain)
		A.process()
		chassis.log_message("Fired from [src.name], targeting [target].")
		do_after_cooldown()
		return


/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	equip_cooldown = 8
	name = "\improper CH-PS \"Immolator\" laser"
	icon_state = "mecha_laser"
	energy_drain = 30
	projectile = /obj/item/projectile/beam
	fire_sound = 'sound/weapons/Laser.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	equip_cooldown = 15
	name = "\improper CH-LC \"Solaris\" laser cannon"
	icon_state = "mecha_laser"
	energy_drain = 60
	projectile = /obj/item/projectile/beam/heavylaser
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	equip_cooldown = 40
	name = "\improper MKIV ion heavy cannon"
	icon_state = "mecha_ion"
	energy_drain = 120
	projectile = /obj/item/projectile/ion
	fire_sound = 'sound/weapons/Laser.ogg'


/obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	equip_cooldown = 30
	name = "eZ-13 MK2 heavy pulse rifle"
	icon_state = "mecha_pulse"
	energy_drain = 120
	origin_tech = "materials=3;combat=6;powerstorage=4"
	projectile = /obj/item/projectile/beam/pulse/heavy
	fire_sound = 'sound/weapons/marauder.ogg'


/obj/item/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"
	var/life = 20

	Bump(atom/A) //this is just awful
		A.bullet_act(src, def_zone)
		src.life -= 10
		if(ismob(A))
			var/mob/M = A
			if(istype(firer, /mob))
				M.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>[src]</b>"
				firer.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>[src]</b>"
				log_attack("<font color='red'>[firer] ([firer.ckey]) shot [M] ([M.ckey]) with a [src]</font>")
			else
				M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[M]/[M.ckey]</b> with a <b>[src]</b>"
				log_attack("<font color='red'>UNKNOWN shot [M] ([M.ckey]) with a [src]</font>")
		if(life <= 0)
			del(src)
		return

/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	name = "\improper PBT \"Pacifier\" mounted taser"
	icon_state = "mecha_taser"
	energy_drain = 20
	equip_cooldown = 8
	projectile = /obj/item/projectile/energy/electrode
	fire_sound = 'sound/weapons/Taser.ogg'


/obj/item/mecha_parts/mecha_equipment/weapon/honker
	name = "\improper HoNkER BlAsT 5000"
	icon_state = "mecha_honker"
	energy_drain = 200
	equip_cooldown = 150
	range = MELEE|RANGED
	construction_time = 500
	construction_cost = list("metal"=20000,"bananium"=10000)

	can_attach(obj/mecha/combat/honker/M as obj)
		if(..())
			if(istype(M))
				return 1
		return 0

	action(target)
		if(!chassis)
			return 0
		if(energy_drain && chassis.get_charge() < energy_drain)
			return 0
		if(!equip_ready)
			return 0

		playsound(chassis, 'sound/items/AirHorn.ogg', 100, 1)
		chassis.occupant_message("<font color='red' size='5'>HONK</font>")
		for(var/mob/living/carbon/M in ohearers(6, chassis))
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
					continue
			M << "<font color='red' size='7'>HONK</font>"
			M.sleeping = 0
			M.stuttering += 20
			M.ear_deaf += 30
			M.Weaken(3)
			if(prob(30))
				M.Stun(10)
				M.Paralyse(4)
			else
				M.make_jittery(500)
			/* //else the mousetraps are useless
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(isobj(H.shoes))
					var/thingy = H.shoes
					H.drop_from_inventory(H.shoes)
					walk_away(thingy,chassis,15,2)
					spawn(20)
						if(thingy)
							walk(thingy,0)
			*/
		chassis.use_power(energy_drain)
		log_message("Honked from [src.name]. HONK!")
		var/turf/T = get_turf(src)
		message_admins("[key_name(chassis.occupant, chassis.occupant.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[chassis.occupant]'>?</A>) used a Mecha Honker in ([T.x],[T.y],[T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)",0,1)
		log_game("[chassis.occupant.ckey]([chassis.occupant]) used a Mecha Honker in ([T.x],[T.y],[T.z])")
		do_after_cooldown()
		return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	name = "general ballisic weapon"
	var/projectiles
	var/projectile_energy_cost

	action_checks(atom/target)
		if(..())
			if(projectiles > 0)
				return 1
		return 0

	get_equip_info()
		return "[..()]\[[src.projectiles]\][(src.projectiles < initial(src.projectiles))?" - <a href='?src=\ref[src];rearm=1'>Rearm</a>":null]"

	proc/rearm()
		if(projectiles < initial(projectiles))
			var/projectiles_to_add = initial(projectiles) - projectiles
			while(chassis.get_charge() >= projectile_energy_cost && projectiles_to_add)
				projectiles++
				projectiles_to_add--
				chassis.use_power(projectile_energy_cost)
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
		log_message("Rearmed [src.name].")
		return

	Topic(href, href_list)
		..()
		if (href_list["rearm"])
			src.rearm()
		return


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	name = "\improper LBX AC 10 \"Scattershot\""
	icon_state = "mecha_scatter"
	equip_cooldown = 20
	projectile = /obj/item/projectile/bullet/midbullet
	fire_sound = 'sound/weapons/Gunshot.ogg'
	projectiles = 40
	projectile_energy_cost = 25
	var/projectiles_per_shot = 4
	var/deviation = 0.7

	action(atom/target)
		if(!action_checks(target)) return
		var/turf/curloc = get_turf(chassis)
		var/turf/targloc = get_turf(target)
		if(!curloc || !targloc) return
		var/target_x = targloc.x
		var/target_y = targloc.y
		var/target_z = targloc.z
		targloc = null
		for(var/i=1 to min(projectiles, projectiles_per_shot))
			var/dx = round(gaussian(0,deviation),1)
			var/dy = round(gaussian(0,deviation),1)
			targloc = locate(target_x+dx, target_y+dy, target_z)
			if(!targloc || targloc == curloc)
				break
			playsound(chassis, fire_sound, 80, 1)
			var/obj/item/projectile/A = new projectile(curloc)
			src.projectiles--
			A.firer = chassis.occupant
			A.original = target
			A.current = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			set_ready_state(0)
			A.process()
		log_message("Fired from [src.name], targeting [target].")
		do_after_cooldown()
		return



/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	name = "\improper Ultra AC 2"
	icon_state = "mecha_uac2"
	equip_cooldown = 10
	projectile = /obj/item/projectile/bullet/weakbullet
	fire_sound = 'sound/weapons/Gunshot.ogg'
	projectiles = 300
	projectile_energy_cost = 20
	var/projectiles_per_shot = 3
	var/deviation = 0.3

	action(atom/target)
		if(!action_checks(target)) return
		var/turf/targloc = get_turf(target)
		var/target_x = targloc.x
		var/target_y = targloc.y
		var/target_z = targloc.z
		targloc = null
		spawn	for(var/i=1 to min(projectiles, projectiles_per_shot))
			if(!chassis) break
			var/turf/curloc = get_turf(chassis)
			var/dx = round(gaussian(0,deviation),1)
			var/dy = round(gaussian(0,deviation),1)
			targloc = locate(target_x+dx, target_y+dy, target_z)
			if (!targloc || !curloc)
				continue
			if (targloc == curloc)
				continue

			playsound(chassis, fire_sound, 50, 1)
			var/obj/item/projectile/A = new projectile(curloc)
			src.projectiles--
			A.firer = chassis.occupant
			A.original = target
			A.current = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			A.process()
			sleep(2)
		set_ready_state(0)
		log_message("Fired from [src.name], targeting [target].")
		do_after_cooldown()
		return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	name = "\improper SRM-8 missile rack"
	icon_state = "mecha_missilerack"
	projectile = /obj/item/missile
	fire_sound = 'sound/effects/bang.ogg'
	projectiles = 8
	projectile_energy_cost = 1000
	equip_cooldown = 60
	var/missile_speed = 2
	var/missile_range = 30

	action(target)
		if(!action_checks(target)) return
		set_ready_state(0)
		var/obj/item/missile/M = new projectile(chassis.loc)
		M.primed = 1
		playsound(chassis, fire_sound, 50, 1)
		M.throw_at(target, missile_range, missile_speed)
		projectiles--
		log_message("Fired from [src.name], targeting [target].")
		var/turf/T = get_turf(src)
		message_admins("[key_name(chassis.occupant, chassis.occupant.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[chassis.occupant]'>?</A>) fired a [src] in ([T.x],[T.y],[T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)",0,1)
		log_game("[chassis.occupant.ckey]([chassis.occupant]) fired a [src] ([T.x],[T.y],[T.z])")
		do_after_cooldown()
		return


/obj/item/missile
	icon = 'icons/obj/grenade.dmi'
	icon_state = "missile"
	var/primed = null
	throwforce = 15

	throw_impact(atom/hit_atom)
		if(primed)
			explosion(hit_atom, 0, 0, 2, 4, 0)
			del(src)
		else
			..()
		return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	name = "\improper SGL-6 grenade launcher"
	icon_state = "mecha_grenadelnchr"
	projectile = /obj/item/weapon/grenade/flashbang
	fire_sound = 'sound/effects/bang.ogg'
	projectiles = 6
	missile_speed = 1.5
	projectile_energy_cost = 800
	equip_cooldown = 60
	var/det_time = 20

	action(target)
		if(!action_checks(target)) return
		set_ready_state(0)
		var/obj/item/weapon/grenade/flashbang/F = new projectile(chassis.loc)
		playsound(chassis, fire_sound, 50, 1)
		F.throw_at(target, missile_range, missile_speed)
		projectiles--
		log_message("Fired from [src.name], targeting [target].")
		var/turf/T = get_turf(src)
		message_admins("[key_name(chassis.occupant, chassis.occupant.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[chassis.occupant]'>?</A>) fired a [src] in ([T.x],[T.y],[T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)",0,1)
		log_game("[chassis.occupant.ckey]([chassis.occupant]) fired a [src] ([T.x],[T.y],[T.z])")
		spawn(det_time)
			F.prime()
		do_after_cooldown()
		return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang//Because I am a heartless bastard -Sieve //Heartless? for making the poor man's honkblast? - Kaze
	name = "\improper SOB-3 grenade launcher"
	projectiles = 3
	projectile = /obj/item/weapon/grenade/flashbang/clusterbang
	projectile_energy_cost = 1600 //getting off cheap seeing as this is 3 times the flashbangs held in the grenade launcher.
	equip_cooldown = 90
	construction_cost = list("metal"=20000,"gold"=10000,"uranium"=10000) //now as expensive as a Honkblast.

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar
	name = "banana mortar"
	icon_state = "mecha_bananamrtr"
	projectile = /obj/item/weapon/bananapeel
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 20
	construction_time = 300
	construction_cost = list("metal"=20000,"bananium"=5000)

	can_attach(obj/mecha/combat/honker/M as obj)
		if(..())
			if(istype(M))
				return 1
		return 0

	action(target)
		if(!action_checks(target)) return
		set_ready_state(0)
		var/obj/item/weapon/bananapeel/B = new projectile(chassis.loc)
		playsound(chassis, fire_sound, 60, 1)
		B.throw_at(target, missile_range, missile_speed)
		projectiles--
		log_message("Bananed from [src.name], targeting [target]. HONK!")
		do_after_cooldown()
		return


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar
	name = "mousetrap mortar"
	icon_state = "mecha_mousetrapmrtr"
	projectile = /obj/item/device/assembly/mousetrap
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 10
	construction_time = 300
	construction_cost = list("metal"=20000,"bananium"=5000)

	can_attach(obj/mecha/combat/honker/M as obj)
		if(..())
			if(istype(M))
				return 1
		return 0

	action(target)
		if(!action_checks(target)) return
		set_ready_state(0)
		var/obj/item/device/assembly/mousetrap/M = new projectile(chassis.loc)
		M.secured = 1
		playsound(chassis, fire_sound, 60, 1)
		M.throw_at(target, missile_range, missile_speed)
		projectiles--
		log_message("Launched a mouse-trap from [src.name], targeting [target]. HONK!")
		do_after_cooldown()
		return