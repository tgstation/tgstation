/obj/item/weapon/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "A self recharging, "
	icon_state = "kineticgun"
	item_state = "kineticgun"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic)
	cell_type = /obj/item/weapon/stock_parts/cell/emproof
	needs_permit = 0
	unique_rename = 1
	origin_tech = "combat=3;powerstorage=3;engineering=3"
	weapon_weight = WEAPON_LIGHT
	can_flashlight = 1
	flight_x_offset = 15
	flight_y_offset = 9
	var/overheat_time = 16
	var/holds_charge = FALSE
	var/unique_frequency = FALSE // modified by KA modkits
	var/overheat = FALSE

	var/list/max_mod_capacity = 2
	var/list/modkits = list()


/obj/item/weapon/gun/energy/kinetic_accelerator/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/weapon/crowbar))
		if(modkits.len)
			user << "<span class='notice'>You pry the modifications out.</span>"
			for(var/obj/item/modkit/M in modkits)
				M.forceMove(get_turf(user))
		else
			user << "<span class='notice'>There are no modifications currently installed.</span>"
	else if(istype(A, /obj/item/modkit))
		var/obj/item/modkit/MK = A
		var/current_mod_capacity = 0
		for(var/obj/item/modkit/M in modkits)
			current_mod_capacity += M.cost
		if((current_mod_capacity + MK.cost) > max_mod_capacity)
			user << "<span class='notice'>You don't have room to install this modkit. Use a crowbar to remove existing modkits.</span>"
			return
		else
			user << "<span class='notice'>You install the modkit.</span>"
			MK.install(src)
	else
		..()


/obj/item/weapon/gun/energy/kinetic_accelerator/proc/modify_projectile(obj/item/projectile/kinetic/K)
	for(var/obj/item/modkit/M in src)
		M.modify_projectile(K)

/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg
	holds_charge = TRUE
	unique_frequency = TRUE

/obj/item/weapon/gun/energy/kinetic_accelerator/hyper/cyborg
	holds_charge = TRUE
	unique_frequency = TRUE

/obj/item/weapon/gun/energy/kinetic_accelerator/New()
	. = ..()
	if(!holds_charge)
		empty()

/obj/item/weapon/gun/energy/kinetic_accelerator/shoot_live_shot()
	. = ..()
	attempt_reload()

/obj/item/weapon/gun/energy/kinetic_accelerator/equipped(mob/user)
	. = ..()
	if(!can_shoot())
		attempt_reload()

/obj/item/weapon/gun/energy/kinetic_accelerator/dropped()
	. = ..()
	if(!holds_charge)
		// Put it on a delay because moving item from slot to hand
		// calls dropped().
		sleep(1)
		if(!ismob(loc))
			empty()

/obj/item/weapon/gun/energy/kinetic_accelerator/proc/empty()
	power_supply.use(500)
	update_icon()

/obj/item/weapon/gun/energy/kinetic_accelerator/proc/attempt_reload()
	if(overheat)
		return
	overheat = TRUE

	var/carried = 0
	if(!unique_frequency)
		for(var/obj/item/weapon/gun/energy/kinetic_accelerator/K in \
			loc.GetAllContents())

			carried++

		carried = max(carried, 1)
	else
		carried = 1

	addtimer(src, "reload", overheat_time * carried)

/obj/item/weapon/gun/energy/kinetic_accelerator/emp_act(severity)
	return

/obj/item/weapon/gun/energy/kinetic_accelerator/proc/reload()
	power_supply.give(500)
	if(!suppressed)
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	else
		loc << "<span class='warning'>[src] silently charges up.<span>"
	update_icon()
	overheat = FALSE

/obj/item/weapon/gun/energy/kinetic_accelerator/update_icon()
	cut_overlays()
	if(!can_shoot())
		add_overlay("kineticgun_empty")

	if(F && can_flashlight)
		var/iconF = "flight"
		if(F.on)
			iconF = "flight_on"
		add_overlay(image(icon = icon, icon_state = iconF, pixel_x = flight_x_offset, pixel_y = flight_y_offset))










//Casing


/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/item/projectile/kinetic
	select_name = "kinetic"
	e_cost = 500
	fire_sound = 'sound/weapons/Kenetic_accel.ogg' // fine spelling there chap

/obj/item/ammo_casing/energy/kinetic/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	if(loc && istype(loc, /obj/item/weapon/gun/energy/kinetic_accelerator))
		var/obj/item/weapon/gun/energy/kinetic_accelerator/KA = loc
		KA.modify_projectile(BB)

/obj/item/ammo_casing/energy/kinetic/hyper
	projectile_type = /obj/item/projectile/kinetic/hyper



//Projectiles

/obj/item/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 10
	damage_type = BRUTE
	flag = "bomb"
	range = 3
	var/damage_multiplier = 4

/obj/item/projectile/kinetic/super
	damage = 11
	range = 4

/obj/item/projectile/kinetic/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure < 50)
		name = "full strength [name]"
		damage *= damage_multiplier
	..()

/obj/item/projectile/kinetic/on_range()
	PoolOrNew(/obj/effect/overlay/temp/kinetic_blast, loc)
	..()

/obj/item/projectile/kinetic/on_hit(atom/target)
	var/turf/target_turf= get_turf(target)
	if(istype(target_turf, /turf/closed/mineral))
		var/turf/closed/mineral/M = target_turf
		M.gets_drilled(firer)
	PoolOrNew(/obj/effect/overlay/temp/kinetic_blast, target_turf)
	. = ..()


//AoE

/obj/item/projectile/kinetic/hyper
	name = "kinetic explosion"
	damage = 10
	range = 3

/obj/item/projectile/kinetic/hyper/proc/aoe_blast(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)
	PoolOrNew(/obj/effect/overlay/temp/explosion/fast, target_turf)
	for(var/T in RANGE_TURFS(1, target_turf) - target_turf)
		if(istype(T, /turf/closed/mineral))
			var/turf/closed/mineral/M = T
			M.gets_drilled(firer)

/obj/item/projectile/kinetic/hyper/on_range()
	aoe_blast()
	..()

/obj/item/projectile/kinetic/hyper/on_hit(atom/target)
	aoe_blast(target)
	. = ..()





//Modkits

/obj/item/modkit
	name = "modification kit"
	desc = "An upgrade for kinetic accelerators.."
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit"
	origin_tech = "programming=2;materials=2;magnets=4"
	var/cost = 2

/obj/item/modkit/proc/install(obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	return

/obj/item/modkit/proc/modify_projectile(/obj/item/projectile/kinetic/K)
	return