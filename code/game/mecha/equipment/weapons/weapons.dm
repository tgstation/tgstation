/obj/item/mecha_parts/mecha_equipment/weapon
	name = "mecha weapon"
	range = RANGED
	origin_tech = "materials=3;combat=3"
	var/projectile
	var/fire_sound
	var/projectiles_per_shot = 1
	var/variance = 0
	var/randomspread = 0 //use random spread for machineguns, instead of shotgun scatter
	var/projectile_delay = 0
	var/firing_effect_type = /obj/effect/overlay/temp/dir_setting/firing_effect	//the visual effect appearing when the weapon is fired.

/obj/item/mecha_parts/mecha_equipment/weapon/can_attach(obj/mecha/combat/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/proc/get_shot_amount()
	return projectiles_per_shot

/obj/item/mecha_parts/mecha_equipment/weapon/action(atom/target, params)
	if(!action_checks(target))
		return 0

	var/turf/curloc = get_turf(chassis)
	var/turf/targloc = get_turf(target)
	if (!targloc || !istype(targloc) || !curloc)
		return 0
	if (targloc == curloc)
		return 0

	set_ready_state(0)
	for(var/i=1 to get_shot_amount())
		var/obj/item/projectile/A = new projectile(curloc)
		A.firer = chassis.occupant
		A.original = target
		A.current = curloc
		if(!A.suppressed && firing_effect_type)
			PoolOrNew(firing_effect_type, list(get_turf(src), chassis.dir))


		var/spread = 0
		if(variance)
			if(randomspread)
				spread = round((rand() - 0.5) * variance)
			else
				spread = round((i / projectiles_per_shot - 0.5) * variance)
		A.preparePixelProjectile(target, targloc, chassis.occupant, params, spread)

		A.fire()
		playsound(chassis, fire_sound, 50, 1)

		sleep(max(0, projectile_delay))

	chassis.log_message("Fired from [src.name], targeting [target].")
	return 1


//Base energy weapon type
/obj/item/mecha_parts/mecha_equipment/weapon/energy
	name = "general energy weapon"
	firing_effect_type = /obj/effect/overlay/temp/dir_setting/firing_effect/energy

/obj/item/mecha_parts/mecha_equipment/weapon/energy/get_shot_amount()
	return min(round(chassis.cell.charge / energy_drain), projectiles_per_shot)

/obj/item/mecha_parts/mecha_equipment/weapon/energy/start_cooldown()
	set_ready_state(0)
	chassis.use_power(energy_drain*get_shot_amount())
	addtimer(CALLBACK(src, .proc/set_ready_state, 1), equip_cooldown)

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	equip_cooldown = 8
	name = "\improper CH-PS \"Immolator\" laser"
	desc = "A weapon for combat exosuits. Shoots basic lasers."
	icon_state = "mecha_laser"
	origin_tech = "magnets=3;combat=3;engineering=3"
	energy_drain = 30
	projectile = /obj/item/projectile/beam/laser
	fire_sound = 'sound/weapons/Laser.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	equip_cooldown = 15
	name = "\improper CH-LC \"Solaris\" laser cannon"
	desc = "A weapon for combat exosuits. Shoots heavy lasers."
	icon_state = "mecha_laser"
	origin_tech = "magnets=4;combat=4;engineering=3"
	energy_drain = 60
	projectile = /obj/item/projectile/beam/laser/heavylaser
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	equip_cooldown = 20
	name = "\improper MKIV ion heavy cannon"
	desc = "A weapon for combat exosuits. Shoots technology-disabling ion beams. Don't catch yourself in the blast!"
	icon_state = "mecha_ion"
	origin_tech = "materials=4;combat=5;magnets=4"
	energy_drain = 120
	projectile = /obj/item/projectile/ion
	fire_sound = 'sound/weapons/Laser.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	equip_cooldown = 30
	name = "eZ-13 MK2 heavy pulse rifle"
	desc = "A weapon for combat exosuits. Shoots powerful destructive blasts capable of demloishing obstacles."
	icon_state = "mecha_pulse"
	energy_drain = 120
	origin_tech = "materials=3;combat=6;powerstorage=4"
	projectile = /obj/item/projectile/beam/pulse/heavy
	fire_sound = 'sound/weapons/marauder.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
	equip_cooldown = 10
	name = "217-D Heavy Plasma Cutter"
	desc = "A device that shoots resonant plasma bursts at extreme velocity. The blasts are capable of crushing rock and demloishing solid obstacles."
	icon_state = "mecha_plasmacutter"
	item_state = "plasmacutter"
	energy_drain = 30
	origin_tech = "materials=3;plasmatech=4;engineering=3"
	projectile = /obj/item/projectile/plasma/adv/mech
	fire_sound = 'sound/weapons/plasma_cutter.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/can_attach(obj/mecha/working/M)
	if(..()) //combat mech
		return 1
	else if(M.equipment.len < M.max_equip && istype(M))
		return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	name = "\improper PBT \"Pacifier\" mounted taser"
	desc = "A weapon for combat exosuits. Shoots non-lethal stunning electrodes."
	icon_state = "mecha_taser"
	origin_tech = "combat=3"
	energy_drain = 20
	equip_cooldown = 8
	projectile = /obj/item/projectile/energy/electrode
	fire_sound = 'sound/weapons/Taser.ogg'


/obj/item/mecha_parts/mecha_equipment/weapon/honker
	name = "\improper HoNkER BlAsT 5000"
	desc = "Equipment for clown exosuits. Spreads fun and joy to everyone around. Honk!"
	icon_state = "mecha_honker"
	energy_drain = 200
	equip_cooldown = 150
	range = MELEE|RANGED

/obj/item/mecha_parts/mecha_equipment/weapon/honker/can_attach(obj/mecha/combat/honker/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/honker/action(target, params)
	if(!action_checks(target))
		return
	playsound(chassis, 'sound/items/AirHorn.ogg', 100, 1)
	chassis.occupant_message("<font color='red' size='5'>HONK</font>")
	for(var/mob/living/carbon/M in ohearers(6, chassis))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
				continue
		M << "<font color='red' size='7'>HONK</font>"
		M.SetSleeping(0)
		M.stuttering += 20
		M.adjustEarDamage(0, 30)
		M.Weaken(3)
		if(prob(30))
			M.Stun(10)
			M.Paralyse(4)
		else
			M.Jitter(500)

	log_message("Honked from [src.name]. HONK!")
	var/turf/T = get_turf(src)
	message_admins("[ADMIN_LOOKUPFLW(chassis.occupant)] used a Mecha Honker in [ADMIN_COORDJMP(T)]",0,1)
	log_game("[chassis.occupant.ckey]([chassis.occupant]) used a Mecha Honker in [COORD(T)]")
	return 1


//Base ballistic weapon type
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	name = "general ballisic weapon"
	fire_sound = 'sound/weapons/Gunshot.ogg'
	var/projectiles
	var/projectile_energy_cost

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/get_shot_amount()
	return min(projectiles, projectiles_per_shot)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action_checks(target)
	if(!..())
		return 0
	if(projectiles <= 0)
		return 0
	return 1

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/get_equip_info()
	return "[..()] \[[src.projectiles]\][(src.projectiles < initial(src.projectiles))?" - <a href='?src=\ref[src];rearm=1'>Rearm</a>":null]"


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/rearm()
	if(projectiles < initial(projectiles))
		var/projectiles_to_add = initial(projectiles) - projectiles
		while(chassis.get_charge() >= projectile_energy_cost && projectiles_to_add)
			projectiles++
			projectiles_to_add--
			chassis.use_power(projectile_energy_cost)
	send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
	log_message("Rearmed [src.name].")
	return 1


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/needs_rearm()
	. = !(projectiles > 0)



/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/Topic(href, href_list)
	..()
	if (href_list["rearm"])
		src.rearm()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action(atom/target)
	if(..())
		projectiles -= get_shot_amount()
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
		return 1


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	name = "\improper FNX-99 \"Hades\" Carbine"
	desc = "A weapon for combat exosuits. Shoots incendiary bullets."
	icon_state = "mecha_carbine"
	origin_tech = "materials=4;combat=4"
	equip_cooldown = 5
	projectile = /obj/item/projectile/bullet/incendiary/shell/dragonsbreath
	projectiles = 24
	projectile_energy_cost = 15

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/silenced
	name = "\improper S.H.H. \"Quietus\" Carbine"
	desc = "A weapon for combat exosuits. A mime invention, field tests have shown that targets cannot even scream before going down."
	fire_sound = "sound/weapons/Gunshot_silenced.ogg"
	icon_state = "mecha_mime"
	equip_cooldown = 30
	projectile = /obj/item/projectile/bullet/mime
	projectiles = 6
	projectile_energy_cost = 50

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	name = "\improper LBX AC 10 \"Scattershot\""
	desc = "A weapon for combat exosuits. Shoots a spread of pellets."
	icon_state = "mecha_scatter"
	origin_tech = "combat=4"
	equip_cooldown = 20
	projectile = /obj/item/projectile/bullet/midbullet
	projectiles = 40
	projectile_energy_cost = 25
	projectiles_per_shot = 4
	variance = 25

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	name = "\improper Ultra AC 2"
	desc = "A weapon for combat exosuits. Shoots a rapid, three shot burst."
	icon_state = "mecha_uac2"
	origin_tech = "combat=4"
	equip_cooldown = 10
	projectile = /obj/item/projectile/bullet/weakbullet3
	projectiles = 300
	projectile_energy_cost = 20
	projectiles_per_shot = 3
	variance = 6
	randomspread = 1
	projectile_delay = 2

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher
	var/missile_speed = 2
	var/missile_range = 30

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/action(target)
	if(!action_checks(target))
		return
	var/obj/O = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 50, 1)
	log_message("Launched a [O.name] from [name], targeting [target].")
	projectiles--
	proj_init(O)
	O.throw_at(target, missile_range, missile_speed, spin = 0)
	return 1

//used for projectile initilisation (priming flashbang) and additional logging
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/proc/proj_init(var/obj/O)
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/missile_rack
	name = "\improper SRM-8 missile rack"
	desc = "A weapon for combat exosuits. Shoots light explosive missiles."
	icon_state = "mecha_missilerack"
	origin_tech = "combat=5;materials=4;engineering=4"
	projectile = /obj/item/missile
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	projectiles = 8
	projectile_energy_cost = 1000
	equip_cooldown = 60

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/missile_rack/proj_init(var/obj/item/missile/M)
	M.primed = 1
	var/turf/T = get_turf(src)
	message_admins("[ADMIN_LOOKUP(chassis.occupant)] fired a [src] in [ADMIN_COORDJMP(T)]",0,1)
	log_game("[key_name(chassis.occupant)] fired a [src] [COORD(T)]")

/obj/item/missile
	icon = 'icons/obj/grenade.dmi'
	icon_state = "missile"
	var/primed = null
	throwforce = 15

/obj/item/missile/throw_impact(atom/hit_atom)
	if(primed)
		explosion(hit_atom, 0, 0, 2, 4, 0)
		qdel(src)
	else
		..()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang
	name = "\improper SGL-6 grenade launcher"
	desc = "A weapon for combat exosuits. Launches primed flashbangs."
	icon_state = "mecha_grenadelnchr"
	origin_tech = "combat=4;engineering=4"
	projectile = /obj/item/weapon/grenade/flashbang
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	projectiles = 6
	missile_speed = 1.5
	projectile_energy_cost = 800
	equip_cooldown = 60
	var/det_time = 20

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/proj_init(var/obj/item/weapon/grenade/flashbang/F)
	var/turf/T = get_turf(src)
	message_admins("[key_name(chassis.occupant, chassis.occupant.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[chassis.occupant]'>?</A>) fired a [src] in ([T.x],[T.y],[T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)",0,1)
	log_game("[key_name(chassis.occupant)] fired a [src] ([T.x],[T.y],[T.z])")
	addtimer(CALLBACK(F, /obj/item/weapon/grenade/flashbang.proc/prime), det_time)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/clusterbang //Because I am a heartless bastard -Sieve //Heartless? for making the poor man's honkblast? - Kaze
	name = "\improper SOB-3 grenade launcher"
	desc = "A weapon for combat exosuits. Launches primed clusterbangs. You monster."
	origin_tech = "combat=4;materials=4"
	projectiles = 3
	projectile = /obj/item/weapon/grenade/clusterbuster
	projectile_energy_cost = 1600 //getting off cheap seeing as this is 3 times the flashbangs held in the grenade launcher.
	equip_cooldown = 90

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar
	name = "banana mortar"
	desc = "Equipment for clown exosuits. Launches banana peels."
	icon_state = "mecha_bananamrtr"
	projectile = /obj/item/weapon/grown/bananapeel
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 20

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar/can_attach(obj/mecha/combat/honker/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar
	name = "mousetrap mortar"
	desc = "Equipment for clown exosuits. Launches armed mousetraps."
	icon_state = "mecha_mousetrapmrtr"
	projectile = /obj/item/device/assembly/mousetrap/armed
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 10

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar/can_attach(obj/mecha/combat/honker/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar/proj_init(var/obj/item/device/assembly/mousetrap/armed/M)
	M.secured = 1
