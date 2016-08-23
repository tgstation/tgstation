/obj/item/weapon/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "A self recharging, ranged mining tool that does increased damage in low pressure. Capable of holding up to six slots worth of mod kits."
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

	var/max_mod_capacity = 6
	var/list/modkits = list()

/obj/item/weapon/gun/energy/kinetic_accelerator/examine(mob/user)
	..()
	for(var/A in modkits)
		var/obj/item/modkit/M = A
		user <<"<span class='notice'>There is a [M.name] mod installed.</span>"

/obj/item/weapon/gun/energy/kinetic_accelerator/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/weapon/crowbar))
		if(modkits.len)
			user << "<span class='notice'>You pry the modifications out.</span>"
			playsound(loc, 'sound/items/Crowbar.ogg', 100, 1)
			for(var/obj/item/modkit/M in modkits)
				M.uninstall(src)
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
			playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
			user.unEquip(MK)
			MK.install(src)
	else
		..()


/obj/item/weapon/gun/energy/kinetic_accelerator/proc/modify_projectile(obj/item/projectile/kinetic/K)
	for(var/obj/item/modkit/M in src)
		M.modify_projectile(K)

/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg
	holds_charge = TRUE
	unique_frequency = TRUE
	max_mod_capacity = 2

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

		var/turf/proj_turf = get_turf(BB)
		if(!istype(proj_turf, /turf))
			return
		var/datum/gas_mixture/environment = proj_turf.return_air()
		var/pressure = environment.return_pressure()
		if(pressure > 50)
			BB.name = "weakened [BB.name]"
			var/obj/item/projectile/kinetic/K = BB
			K.damage /= K.damage_divisor


//Projectiles
/obj/item/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 40
	damage_type = BRUTE
	flag = "bomb"
	range = 3
	var/damage_divisor = 4
	var/turf_aoe = FALSE
	var/mob_aoe = 0

/obj/item/projectile/kinetic/on_range()
	if(turf_aoe || mob_aoe)
		aoe_blast()
	PoolOrNew(/obj/effect/overlay/temp/kinetic_blast, loc)
	..()

/obj/item/projectile/kinetic/on_hit(atom/target)
	if(turf_aoe || mob_aoe)
		aoe_blast(target)
	var/turf/target_turf= get_turf(target)
	if(istype(target_turf, /turf/closed/mineral))
		var/turf/closed/mineral/M = target_turf
		M.gets_drilled(firer)
	PoolOrNew(/obj/effect/overlay/temp/kinetic_blast, target_turf)
	. = ..()

/obj/item/projectile/kinetic/proc/aoe_blast(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)
	PoolOrNew(/obj/effect/overlay/temp/explosion/fast, target_turf)
	if(turf_aoe)
		for(var/T in RANGE_TURFS(1, target_turf) - target_turf)
			if(istype(T, /turf/closed/mineral))
				var/turf/closed/mineral/M = T
				M.gets_drilled(firer)
	if(mob_aoe)
		for(var/mob/living/L in range(1, target_turf) - firer - target)
			var/armor = L.run_armor_check(def_zone, flag, "", "", armour_penetration)
			L.apply_damage(damage*mob_aoe, damage_type, def_zone, armor)
			L << "<span class='userdanger'>You're struck by a [name]!</span>"
			world << "hit [L]"


//Modkits
/obj/item/modkit
	name = "modification kit"
	desc = "An upgrade for kinetic accelerators."
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit"
	origin_tech = "programming=2;materials=2;magnets=4"
	var/cost = 2
	var/modifier = 1 //For use in any mod kit that has numerical modifiers

/obj/item/modkit/proc/install(obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	forceMove(KA)
	KA.modkits += src

/obj/item/modkit/proc/uninstall(obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	forceMove(get_turf(KA))
	KA.modkits -= src

/obj/item/modkit/proc/modify_projectile(obj/item/projectile/kinetic/K)


//Range
/obj/item/modkit/range
	name = "range increase"
	desc = "Increases the range of a kinetic accelerator when installed. Occupies two mod slots."
	modifier = 1

/obj/item/modkit/range/modify_projectile(obj/item/projectile/kinetic/K)
	K.range += modifier


//Damage
/obj/item/modkit/damage
	name = "damage increase"
	desc = "Increases the damage of kinetic accelerator when installed. Occupies two mod slots."
	modifier = 10

/obj/item/modkit/damage/modify_projectile(obj/item/projectile/kinetic/K)
	K.damage += modifier


//Cooldown
/obj/item/modkit/cooldown
	name = "cooldown decrease"
	desc = "Decreases the cooldown of a kinetic accelerator. Occupies two mod slots."
	modifier = 2.5

/obj/item/modkit/cooldown/install(obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	KA.overheat_time -= modifier
	..()

/obj/item/modkit/cooldown/uninstall(obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	KA.overheat_time += modifier
	..()


//AoE blasts
/obj/item/modkit/aoe/modify_projectile(obj/item/projectile/kinetic/K)
	K.name = "kinetic explosion"
	..()

/obj/item/modkit/aoe/turfs
	name = "mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock in an AoE. Occupies two mod slots."

/obj/item/modkit/aoe/turfs/modify_projectile(obj/item/projectile/kinetic/K)
	K.turf_aoe = TRUE
	..()

/obj/item/modkit/aoe/mobs
	name = "offensive explosion"
	desc = "Causes the kinetic accelerator to damage mobs in an AoE. Occupies two mod slots."
	modifier = 0.25

/obj/item/modkit/aoe/mobs/modify_projectile(obj/item/projectile/kinetic/K)
	K.mob_aoe += modifier
	..()


//Indoors
/obj/item/modkit/indoors
	name = "decrease pressure penalty"
	desc = "Increases the damage a kinetic accelerator does in a high pressure environment. Occupies three mod slots."
	modifier = 2
	cost = 3

/obj/item/modkit/indoors/modify_projectile(obj/item/projectile/kinetic/K)
	K.damage_divisor = Clamp(K.damage_divisor - modifier, 0, INFINITY)


//Trigger Guard
/obj/item/modkit/trigger_guard
	name = "modified trigger guard"
	desc = "Allows creatures normally incapable of firing guns to operate the weapon when installed. Occupies two mod slots."

/obj/item/modkit/trigger_guard/install(obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	KA.trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	..()

/obj/item/modkit/trigger_guard/uninstall(obj/item/weapon/gun/energy/kinetic_accelerator/KA)
	KA.trigger_guard = TRIGGER_GUARD_NORMAL
	..()