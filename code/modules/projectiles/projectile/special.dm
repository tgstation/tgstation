/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"


/obj/item/projectile/ion/on_hit(atom/target, blocked = 0)
	..()
	empulse(target, 1, 1)
	return 1


/obj/item/projectile/ion/weak

/obj/item/projectile/ion/weak/on_hit(atom/target, blocked = 0)
	..()
	empulse(target, 0, 0)
	return 1


/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50

/obj/item/projectile/bullet/gyro/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 0, 2)
	return 1

/obj/item/projectile/bullet/a40mm
	name ="40mm grenade"
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	damage = 60

/obj/item/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 0, 2, 1, 0, flame_range = 3)
	return 1

/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	var/temperature = 100


/obj/item/projectile/temp/on_hit(atom/target, blocked = 0)//These two could likely check temp protection on the mob
	..()
	if(isliving(target))
		var/mob/M = target
		M.bodytemperature = temperature
	return 1

/obj/item/projectile/temp/hot
	name = "heat beam"
	temperature = 400

/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	flag = "bullet"

/obj/item/projectile/meteor/Bump(atom/A, yes)
	if(!yes) //prevents multi bumps.
		return
	if(A == firer)
		loc = A.loc
		return
	A.ex_act(2)
	playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)
	for(var/mob/M in urange(10, src))
		if(!M.stat)
			shake_camera(M, 3, 1)
	qdel(src)

/obj/item/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

/obj/item/projectile/beam/mindflayer/on_hit(atom/target, blocked = 0)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.adjustBrainLoss(20)
		M.hallucination += 20

/obj/item/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 10
	damage_type = BRUTE
	flag = "bomb"
	range = 3
	var/splash = 0

/obj/item/projectile/kinetic/super
	damage = 11
	range = 4

/obj/item/projectile/kinetic/hyper
	damage = 12
	range = 5
	splash = 1

/obj/item/projectile/kinetic/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure < 50)
		name = "full strength kinetic force"
		damage *= 4
	..()

/obj/item/projectile/kinetic/on_range()
	new /obj/effect/kinetic_blast(src.loc)
	..()

/obj/item/projectile/kinetic/on_hit(atom/target)
	. = ..()
	var/turf/target_turf= get_turf(target)
	if(istype(target_turf, /turf/closed/mineral))
		var/turf/closed/mineral/M = target_turf
		M.gets_drilled(firer)
	new /obj/effect/kinetic_blast(target_turf)
	if(src.splash)
		for(var/turf/T in range(splash, target_turf))
			if(istype(T, /turf/closed/mineral))
				var/turf/closed/mineral/M = T
				M.gets_drilled(firer)


/obj/effect/kinetic_blast
	name = "kinetic explosion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/kinetic_blast/New()
	spawn(4)
		qdel(src)

/obj/item/projectile/beam/wormhole
	name = "bluespace beam"
	icon_state = "spark"
	hitsound = "sparks"
	damage = 3
	var/obj/item/weapon/gun/energy/wormhole_projector/gun
	color = "#33CCFF"

/obj/item/projectile/beam/wormhole/orange
	name = "orange bluespace beam"
	color = "#FF6600"

/obj/item/projectile/beam/wormhole/New(var/obj/item/ammo_casing/energy/wormhole/casing)
	if(casing)
		gun = casing.gun

/obj/item/ammo_casing/energy/wormhole/New(var/obj/item/weapon/gun/energy/wormhole_projector/wh)
	gun = wh

/obj/item/projectile/beam/wormhole/on_hit(atom/target)
	if(ismob(target))
		var/turf/portal_destination = pick(orange(6, src))
		do_teleport(target, portal_destination)
		return ..()
	if(!gun)
		qdel(src)
	gun.create_portal(src)

/obj/item/projectile/bullet/frag12
	name ="explosive slug"
	damage = 25
	weaken = 5

/obj/item/projectile/bullet/frag12/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 0, 1)
	return 1

/obj/item/projectile/plasma
	name = "plasma blast"
	icon_state = "plasmacutter"
	damage_type = BRUTE
	damage = 5
	range = 5

/obj/item/projectile/plasma/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	if(environment)
		var/pressure = environment.return_pressure()
		if(pressure < 60)
			name = "full strength plasma blast"
			damage *= 4
	..()

/obj/item/projectile/plasma/on_hit(atom/target)
	. = ..()
	if(istype(target, /turf/closed/mineral))
		var/turf/closed/mineral/M = target
		M.gets_drilled(firer)
		Range()
		if(range > 0)
			return -1

/obj/item/projectile/plasma/adv
	damage = 7
	range = 7

/obj/item/projectile/plasma/adv/mech
	damage = 10
	range = 8


/obj/item/projectile/beam/sell
	name = "export beam"
	icon_state = "xray"
	damage = 1 // Damage is used to detremine if we are performing an execution
	nodamage = 1
	eyeblur = 2
	var/obj/item/weapon/gun/energy/exporter/gun
	var/obj/docking_port/mobile/supply/supply
	var/selling = 0
	var/sell_log = ""

/obj/item/projectile/beam/sell/on_hit(atom/target, blocked = 0)
	. = ..()

	if(iscarbon(target) && blocked != 100)
		var/mob/living/carbon/C = target
		if(damage >= 5) // Execution? Sell victim's organs!
			for(var/o in C.internal_organs)
				var/obj/item/organ/O = o
				if(can_sell(O))
					O.Remove(C)
					sell(O)

			if(sell_log) // We actually sold something
				C << "<span class='userdanger'>\The [src] reaches deep inside your body, selling your insides!</span>"

		else if(!istype(gun) || gun.emagged) // Not execution, and overloaded? Sell victim's gear.
			for(var/slot_id in 1 to slots_amt) // Check all the slots
				var/obj/item/thing = C.get_item_by_slot(slot_id)
				if(!thing || !can_sell(thing))
					continue

				if(!C.unEquip(thing))
					continue

				sell(thing)

			if(sell_log)
				C << "<span class='userdanger'>\The [src] sells your gear!</span>"
		else
			target << "<span class='notice'>\The [src] dissipates harmlessly through your body.</span>"


	else if(isobj(target))
		var/obj/O = target
		if(!O.anchored)
			sell(target)

	stop_sell()


/obj/item/projectile/beam/sell/proc/start_sell()
	if(!supply)
		supply = SSshuttle.supply

	if(!supply.exports.len)
		supply.generate_exports()

	selling = 1

/obj/item/projectile/beam/sell/proc/sell(atom/movable/AM)
	if(!selling)
		start_sell()
	var/sold_atoms = supply.recursive_sell(AM, 1, 0, 1, (!istype(gun) || gun.emagged))
	if(sold_atoms)
		sell_log += sold_atoms

/obj/item/projectile/beam/sell/proc/can_sell(atom/movable/AM)
	if(!selling)
		start_sell()
	for(var/a in supply.exports)
		var/datum/export/E = a
		if(E.applies_to(AM, 1, (!istype(gun) || gun.emagged)))
			return TRUE

	return FALSE


/obj/item/projectile/beam/sell/proc/stop_sell()
	if(!selling)
		return 0

	var/points_change = 0
	var/msg = ""

	for(var/a in supply.exports)
		var/datum/export/E = a
		var/export_text = E.total_printout()
		if(!export_text)
			continue

		msg += export_text + "\n"
		points_change += E.total_cost
		E.export_end()

	if(msg && ismob(firer))
		msg += "Total: [points_change>=0 ? "+" : ""][points_change] credits."
		firer << "<span class='notice'>[msg]</span>"

	world << sell_log
	SSshuttle.points += points_change
	if(istype(gun) && gun.power_supply && points_change-200 > 0)
		gun.power_supply.use(min(points_change-200, gun.power_supply.charge))

	selling = 0