/obj/item/mecha_parts/mecha_equipment/weapon
	name = "mecha weapon"
	range = MECHA_RANGED
	destroy_sound = 'sound/mecha/weapdestr.ogg'
	var/projectile
	var/fire_sound
	var/projectiles_per_shot = 1
	var/variance = 0
	var/randomspread = FALSE //use random spread for machineguns, instead of shotgun scatter
	var/projectile_delay = 0
	var/firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect //the visual effect appearing when the weapon is fired.
	var/kickback = TRUE //Will using this weapon in no grav push mecha back.
	mech_flags = EXOSUIT_MODULE_COMBAT

/obj/item/mecha_parts/mecha_equipment/weapon/can_attach(obj/vehicle/sealed/mecha/M)
	if(!..())
		return FALSE
	if(istype(M, /obj/vehicle/sealed/mecha/combat))
		return TRUE
	if((locate(/obj/item/mecha_parts/concealed_weapon_bay) in M.contents) && !(locate(/obj/item/mecha_parts/mecha_equipment/weapon) in M.equipment))
		return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/action(mob/source, atom/target, params)
	if(!action_checks(target))
		return FALSE
	var/newtonian_target = turn(chassis.dir,180)
	. = ..()//start the cooldown early because of sleeps
	for(var/i in 1 to projectiles_per_shot)
		if(energy_drain && !chassis.has_charge(energy_drain))//in case we run out of energy mid-burst, such as emp
			break
		var/spread = 0
		if(variance)
			if(randomspread)
				spread = round((rand() - 0.5) * variance)
			else
				spread = round((i / projectiles_per_shot - 0.5) * variance)

		var/obj/projectile/A = new projectile(get_turf(src))
		var/modifiers = params2list(params)
		A.firer = chassis
		A.preparePixelProjectile(target, source, modifiers, spread)

		A.fire()
		if(!A.suppressed && firing_effect_type)
			new firing_effect_type(get_turf(src), chassis.dir)
		playsound(chassis, fire_sound, 50, TRUE)

		sleep(max(0, projectile_delay))

		if(kickback)
			chassis.newtonian_move(newtonian_target)
	chassis.log_message("Fired from [name], targeting [target].", LOG_ATTACK)

//Base energy weapon type
/obj/item/mecha_parts/mecha_equipment/weapon/energy
	name = "general energy weapon"
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	equip_cooldown = 8
	name = "\improper CH-PS \"Immolator\" laser"
	desc = "A weapon for combat exosuits. Shoots basic lasers."
	icon_state = "mecha_laser"
	energy_drain = 30
	projectile = /obj/projectile/beam/laser
	fire_sound = 'sound/weapons/laser.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/disabler
	equip_cooldown = 8
	name = "\improper CH-DS \"Peacemaker\" disabler"
	desc = "A weapon for combat exosuits. Shoots basic disablers."
	icon_state = "mecha_disabler"
	energy_drain = 30
	projectile = /obj/projectile/beam/disabler
	fire_sound = 'sound/weapons/taser2.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	equip_cooldown = 15
	name = "\improper CH-LC \"Solaris\" laser cannon"
	desc = "A weapon for combat exosuits. Shoots heavy lasers."
	icon_state = "mecha_laser"
	energy_drain = 60
	projectile = /obj/projectile/beam/laser/heavylaser
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	equip_cooldown = 20
	name = "\improper MKIV ion heavy cannon"
	desc = "A weapon for combat exosuits. Shoots technology-disabling ion beams. Don't catch yourself in the blast!"
	icon_state = "mecha_ion"
	energy_drain = 120
	projectile = /obj/projectile/ion
	fire_sound = 'sound/weapons/laser.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla
	equip_cooldown = 35
	name = "\improper MKI Tesla Cannon"
	desc = "A weapon for combat exosuits. Fires bolts of electricity similar to the experimental tesla engine."
	icon_state = "mecha_ion"
	energy_drain = 500
	projectile = /obj/projectile/energy/tesla/cannon
	fire_sound = 'sound/magic/lightningbolt.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	equip_cooldown = 30
	name = "eZ-13 MK2 heavy pulse rifle"
	desc = "A weapon for combat exosuits. Shoots powerful destructive blasts capable of demolishing obstacles."
	icon_state = "mecha_pulse"
	energy_drain = 120
	projectile = /obj/projectile/beam/pulse/heavy
	fire_sound = 'sound/weapons/marauder.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
	equip_cooldown = 10
	name = "217-D Heavy Plasma Cutter"
	desc = "A device that shoots resonant plasma bursts at extreme velocity. The blasts are capable of crushing rock and demolishing solid obstacles."
	icon_state = "mecha_plasmacutter"
	inhand_icon_state = "plasmacutter"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	energy_drain = 30
	projectile = /obj/projectile/plasma/adv/mech
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/can_attach(obj/vehicle/sealed/mecha/M)
	if(..()) //combat mech
		return TRUE
	else if(LAZYLEN(M.equipment) < M.max_equip)
		return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	name = "\improper PBT \"Pacifier\" mounted taser"
	desc = "A weapon for combat exosuits. Shoots non-lethal stunning electrodes."
	icon_state = "mecha_taser"
	energy_drain = 20
	equip_cooldown = 8
	projectile = /obj/projectile/energy/electrode
	fire_sound = 'sound/weapons/taser.ogg'


/obj/item/mecha_parts/mecha_equipment/weapon/honker
	name = "\improper HoNkER BlAsT 5000"
	desc = "Equipment for clown exosuits. Spreads fun and joy to everyone around. Honk!"
	icon_state = "mecha_honker"
	energy_drain = 200
	equip_cooldown = 150
	range = MECHA_MELEE|MECHA_RANGED
	kickback = FALSE
	mech_flags = EXOSUIT_MODULE_HONK

/obj/item/mecha_parts/mecha_equipment/weapon/honker/can_attach(obj/vehicle/sealed/mecha/mecha)
	. = ..()
	if(!.)
		return
	if(!istype(mecha, /obj/vehicle/sealed/mecha/combat/honker))
		return FALSE


/obj/item/mecha_parts/mecha_equipment/weapon/honker/action(mob/source, atom/target, params)
	if(!action_checks(target))
		return
	playsound(chassis, 'sound/items/airhorn.ogg', 100, TRUE)
	to_chat(source, "[icon2html(src, source)]<font color='red' size='5'>HONK</font>")
	for(var/mob/living/carbon/M in ohearers(6, chassis))
		if(!M.can_hear())
			continue
		var/turf/turf_check = get_turf(M)
		if(isspaceturf(turf_check) && !turf_check.Adjacent(src)) //in space nobody can hear you honk.
			continue
		to_chat(M, "<font color='red' size='7'>HONK</font>")
		M.SetSleeping(0)
		M.stuttering += 20
		var/obj/item/organ/ears/ears = M.getorganslot(ORGAN_SLOT_EARS)
		if(ears)
			ears.adjustEarDamage(0, 30)
		M.Paralyze(60)
		if(prob(30))
			M.Stun(200)
			M.Unconscious(80)
		else
			M.Jitter(500)

	log_message("Honked from [src.name]. HONK!", LOG_MECHA)
	var/turf/T = get_turf(src)
	message_admins("[ADMIN_LOOKUPFLW(source)] used a Mecha Honker in [ADMIN_VERBOSEJMP(T)]")
	log_game("[key_name(source)] used a Mecha Honker in [AREACOORD(T)]")
	return ..()


//Base ballistic weapon type
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	name = "general ballistic weapon"
	fire_sound = 'sound/weapons/gun/smg/shot.ogg'
	var/projectiles
	var/projectiles_cache //ammo to be loaded in, if possible.
	var/projectiles_cache_max
	var/projectile_energy_cost
	var/disabledreload //For weapons with no cache (like the rockets) which are reloaded by hand
	var/ammo_type

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action_checks(target)
	if(!..())
		return FALSE
	if(projectiles <= 0)
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/get_equip_info()
	return "[..()] \[[src.projectiles][projectiles_cache_max &&!projectile_energy_cost?"/[projectiles_cache]":""]\][!disabledreload &&(src.projectiles < initial(src.projectiles))?" - <a href='?src=[REF(src)];rearm=1'>Rearm</a>":null]"


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/rearm()
	if(projectiles < initial(projectiles))
		var/projectiles_to_add = initial(projectiles) - projectiles

		if(projectile_energy_cost)
			while(chassis.get_charge() >= projectile_energy_cost && projectiles_to_add)
				projectiles++
				projectiles_to_add--
				chassis.use_power(projectile_energy_cost)

		else
			if(!projectiles_cache)
				return FALSE
			if(projectiles_to_add <= projectiles_cache)
				projectiles = projectiles + projectiles_to_add
				projectiles_cache = projectiles_cache - projectiles_to_add
			else
				projectiles = projectiles + projectiles_cache
				projectiles_cache = 0

		send_byjax(chassis.occupants,"exosuit.browser","[REF(src)]",src.get_equip_info())
		log_message("Rearmed [src.name].", LOG_MECHA)
		return TRUE


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/needs_rearm()
	. = !(projectiles > 0)



/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/Topic(href, href_list)
	..()
	if (href_list["rearm"])
		src.rearm()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action(mob/source, atom/target, params)
	if(..())
		projectiles -= projectiles_per_shot
		send_byjax(chassis.occupants,"exosuit.browser","[REF(src)]",src.get_equip_info())
		return ..()


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	name = "\improper FNX-99 \"Hades\" Carbine"
	desc = "A weapon for combat exosuits. Shoots incendiary bullets."
	icon_state = "mecha_carbine"
	equip_cooldown = 10
	projectile = /obj/projectile/bullet/incendiary/fnx99
	projectiles = 24
	projectiles_cache = 24
	projectiles_cache_max = 96
	harmful = TRUE
	ammo_type = "incendiary"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/silenced
	name = "\improper S.H.H. \"Quietus\" Carbine"
	desc = "A weapon for combat exosuits. A mime invention, field tests have shown that targets cannot even scream before going down."
	fire_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg'
	icon_state = "mecha_mime"
	equip_cooldown = 30
	projectile = /obj/projectile/bullet/mime
	projectiles = 6
	projectile_energy_cost = 50
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	name = "\improper LBX AC 10 \"Scattershot\""
	desc = "A weapon for combat exosuits. Shoots a spread of pellets."
	icon_state = "mecha_scatter"
	equip_cooldown = 20
	projectile = /obj/projectile/bullet/scattershot
	projectiles = 40
	projectiles_cache = 40
	projectiles_cache_max = 160
	projectiles_per_shot = 4
	variance = 25
	harmful = TRUE
	ammo_type = "scattershot"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	name = "\improper Ultra AC 2"
	desc = "A weapon for combat exosuits. Shoots a rapid, three shot burst."
	icon_state = "mecha_uac2"
	equip_cooldown = 10
	projectile = /obj/projectile/bullet/lmg
	projectiles = 300
	projectiles_cache = 300
	projectiles_cache_max = 1200
	projectiles_per_shot = 3
	variance = 6
	randomspread = 1
	projectile_delay = 2
	harmful = TRUE
	ammo_type = "lmg"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	name = "\improper SRM-8 missile rack"
	desc = "A weapon for combat exosuits. Launches light explosive missiles."
	icon_state = "mecha_missilerack"
	projectile = /obj/projectile/bullet/a84mm/he
	fire_sound = 'sound/weapons/gun/general/rocket_launch.ogg'
	projectiles = 8
	projectiles_cache = 0
	projectiles_cache_max = 0
	disabledreload = TRUE
	equip_cooldown = 60
	harmful = TRUE
	ammo_type = "missiles_he"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/breaching
	name = "\improper BRM-6 missile rack"
	desc = "A weapon for combat exosuits. Launches low-explosive breaching missiles designed to explode only when striking a sturdy target."
	icon_state = "mecha_missilerack_six"
	projectile = /obj/projectile/bullet/a84mm_br
	fire_sound = 'sound/weapons/gun/general/rocket_launch.ogg'
	projectiles = 6
	projectiles_cache = 0
	projectiles_cache_max = 0
	disabledreload = TRUE
	equip_cooldown = 60
	harmful = TRUE
	ammo_type = "missiles_br"


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher
	var/missile_speed = 2
	var/missile_range = 30
	var/diags_first = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/action(mob/source, atom/target, params)
	if(!action_checks(target))
		return
	var/obj/O = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 50, TRUE)
	log_message("Launched a [O.name] from [name], targeting [target].", LOG_MECHA)
	projectiles--
	proj_init(O, source)
	O.throw_at(target, missile_range, missile_speed, source, FALSE, diagonals_first = diags_first)
	return TRUE

//used for projectile initilisation (priming flashbang) and additional logging
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/proc/proj_init(obj/O, mob/user)
	return


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang
	name = "\improper SGL-6 grenade launcher"
	desc = "A weapon for combat exosuits. Launches primed flashbangs."
	icon_state = "mecha_grenadelnchr"
	projectile = /obj/item/grenade/flashbang
	fire_sound = 'sound/weapons/gun/general/grenade_launch.ogg'
	projectiles = 6
	projectiles_cache = 6
	projectiles_cache_max = 24
	missile_speed = 1.5
	equip_cooldown = 60
	var/det_time = 20
	ammo_type = "flashbang"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/proj_init(obj/item/grenade/flashbang/F, mob/user)
	var/turf/T = get_turf(src)
	message_admins("[ADMIN_LOOKUPFLW(user)] fired a [F] in [ADMIN_VERBOSEJMP(T)]")
	log_game("[key_name(user)] fired a [F] in [AREACOORD(T)]")
	addtimer(CALLBACK(F, /obj/item/grenade/flashbang.proc/detonate), det_time)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/clusterbang //Because I am a heartless bastard -Sieve //Heartless? for making the poor man's honkblast? - Kaze
	name = "\improper SOB-3 grenade launcher"
	desc = "A weapon for combat exosuits. Launches primed clusterbangs. You monster."
	projectiles = 3
	projectiles_cache = 0
	projectiles_cache_max = 0
	disabledreload = TRUE
	projectile = /obj/item/grenade/clusterbuster
	equip_cooldown = 90
	ammo_type = "clusterbang"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar
	name = "banana mortar"
	desc = "Equipment for clown exosuits. Launches banana peels."
	icon_state = "mecha_bananamrtr"
	projectile = /obj/item/grown/bananapeel
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 20
	mech_flags = EXOSUIT_MODULE_HONK

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar/can_attach(obj/vehicle/sealed/mecha/combat/honker/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar
	name = "mousetrap mortar"
	desc = "Equipment for clown exosuits. Launches armed mousetraps."
	icon_state = "mecha_mousetrapmrtr"
	projectile = /obj/item/assembly/mousetrap/armed
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 10
	mech_flags = EXOSUIT_MODULE_HONK

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar/can_attach(obj/vehicle/sealed/mecha/combat/honker/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar/proj_init(obj/item/assembly/mousetrap/armed/M)
	M.secured = 1


//Classic extending punching glove, but weaponised!
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove
	name = "\improper Oingo Boingo Punch-face"
	desc = "Equipment for clown exosuits. Delivers fun right to your face!"
	icon_state = "mecha_punching_glove"
	energy_drain = 250
	equip_cooldown = 20
	range = MECHA_MELEE|MECHA_RANGED
	missile_range = 5
	projectile = /obj/item/punching_glove
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 10
	projectile_energy_cost = 500
	harmful = TRUE
	diags_first = TRUE
	/// Damage done by the glove on contact. Also used to determine throw distance (damage / 5)
	var/punch_damage = 35
	/// TRUE - Can toggle between lethal and non-lethal || FALSE - Cannot toggle
	var/can_toggle_lethal = TRUE
	mech_flags = EXOSUIT_MODULE_HONK

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove/can_attach(obj/vehicle/sealed/mecha/combat/honker/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove/get_equip_info()
	if(!chassis)
		return

	if(can_toggle_lethal)
		return "[..()] &nbsp; <a href='?src=[REF(src)];lethalPunch=1'>[harmful?"Punch":"Pat"] mode</a>"
	else
		return ..()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove/Topic(href, href_list)
	..()
	if(href_list["lethalPunch"])
		harmful = !harmful
		if(!chassis)
			return
		if(harmful)
			to_chat(usr, "[icon2html(src, usr)]<span class='warning'>Lethal Fisting Enabled.</span>")
		else
			to_chat(usr, "[icon2html(src, usr)]<span class='warning'>Lethal Fisting Disabled.</span>")

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove/action(mob/source, atom/target, params)
	. = ..()
	if(.)
		to_chat(usr, "[icon2html(src, usr)]<font color='red' size='5'>HONK</font>")

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove/proj_init(obj/item/punching_glove/PG)
	if(!istype(PG))
		return

	if(harmful)
		PG.throwforce = punch_damage
	else
		PG.throwforce = 0

	chassis.Beam(PG, icon_state = "chain", time = missile_range * 20, maxdistance = missile_range + 2)

/obj/item/punching_glove
	name = "punching glove"
	desc = "INCOMING HONKS"
	throwforce = 35
	icon_state = "punching_glove"

/obj/item/punching_glove/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..())
		if(ismovable(hit_atom))
			var/atom/movable/AM = hit_atom
			AM.safe_throw_at(get_edge_target_turf(AM,get_dir(src, AM)), clamp(round(throwforce/5), 2, 20), 2) //Throws them equal to damage/5, with a min range of 2 and max range of 20
		qdel(src)

///dark honk weapons

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar/bombanana
	name = "bombanana mortar"
	desc = "Equipment for clown exosuits. Launches exploding banana peels."
	icon_state = "mecha_bananamrtr"
	projectile = /obj/item/grown/bananapeel/bombanana
	projectiles = 8
	projectile_energy_cost = 1000

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar/bombanana/can_attach(obj/vehicle/sealed/mecha/combat/honker/M)
	if(..())
		if(istype(M))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/tearstache
	name = "\improper HONKeR-6 grenade launcher"
	desc = "A weapon for combat exosuits. Launches primed tear-stache grenades."
	icon_state = "mecha_grenadelnchr"
	projectile = /obj/item/grenade/chem_grenade/teargas/moustache
	fire_sound = 'sound/weapons/gun/general/grenade_launch.ogg'
	projectiles = 6
	missile_speed = 1.5
	projectile_energy_cost = 800
	equip_cooldown = 60
	det_time = 20

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/tearstache/can_attach(obj/vehicle/sealed/mecha/combat/honker/M)
	if(..())
		if(istype(M))
			return TRUE
	return FALSE
