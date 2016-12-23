/obj/mecha/combat/sec_ripley
	desc = "Autonomous Power Security Unit. This newer model is refitted with powerful armour against the dangers of the criminal scum."
	name = "\improper APSU \"Security Ripley\""
	icon = 'icons/mecha/white_only.dmi'
	icon_state = "sec_ripley"
	step_in = 6
	max_temperature = 20000
	obj_integrity = 240
	max_integrity = 240
	lights_power = 10
	deflect_chance = 15
	facing_modifiers = list(FRONT_ARMOUR = 2.5, SIDE_ARMOUR = 0.5, BACK_ARMOUR = 0.25)
	armor = list(melee = 35, bullet = 30, laser = 15, energy = 15, bomb = 40, bio = 0, rad = 0, fire = 100, acid = 100)
	max_equip = 3
	force = 15
	wreckage = /obj/structure/mecha_wreckage/sec_ripley

/obj/structure/mecha_wreckage/sec_ripley
	name = "\improper Security Ripley wreckage"
	icon = 'icons/mecha/white_only.dmi'
	icon_state = "sec_ripley-broken"


/obj/mecha/combat/sec_ripley/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser/T = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	var/obj/item/mecha_parts/mecha_equipment/pepper/P = new /obj/item/mecha_parts/mecha_equipment/pepper
	var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/F = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang
	T.attach(src)
	P.attach(src)
	F.attach(src)
	return


/obj/item/mecha_parts/mecha_equipment/pepper
	name = "exosuit pepper spray"
	desc = "Equipment for security exosuits. A rapid-firing high capacity pepper spray."
	icon = 'icons/mecha/white_only.dmi'
	icon_state = "mecha_pepper"
	equip_cooldown = 5
	energy_drain = 0
	var/spray_range = 4 //the range of tiles the sprayer will reach when in spray mode.
	var/amount_per_transfer_from_this = 5
	range = MELEE|RANGED



/obj/item/mecha_parts/mecha_equipment/pepper/New()
	create_reagents(1000)
	reagents.add_reagent("condensedcapsaicin", 1000)
	START_PROCESSING(SSobj, src)
	..()
	return

/obj/item/mecha_parts/mecha_equipment/pepper/action(atom/A) //copypasted from extinguisher. TODO: Rewrite from scratch.
	if(!action_checks(A) || get_dist(chassis, A)>3)
		return

	if(istype(A, /obj/structure/reagent_dispensers/peppertank) && get_dist(chassis,A) <= 1)
		var/obj/structure/reagent_dispensers/peppertank/PT = A
		PT.reagents.trans_to(src, 1000)
		occupant_message("<span class='notice'>Pepper spray refilled.</span>")
		playsound(chassis, 'sound/effects/refill.ogg', 50, 1, -6)
	else
		var/direction = get_dir(chassis,A)
		var/turf/T1 = get_turf(A)
		var/turf/T2 = get_step(A,turn(direction, 90))
		var/turf/T3 = get_step(A,turn(direction, -90))
		var/list/the_targets = list(T1,T2,T3)
		for(var/a=0, a<5, a++)
			var/turf/my_target = pick(the_targets)
			var/range = max(min(spray_range, get_dist(src, my_target)), 4)
			var/obj/effect/decal/chempuff/D = new /obj/effect/decal/chempuff(get_turf(src))
			D.create_reagents(amount_per_transfer_from_this)
			var/puff_reagent_left = range //how many turf, mob or dense objet we can react with before we consider the chem puff consumed
			reagents.trans_to(D, amount_per_transfer_from_this, 1/range)
			D.color = mix_color_from_reagents(D.reagents.reagent_list)
			var/wait_step = max(round(2+3/range), 2)
			spawn(0)
				var/range_left = range
				for(var/i=0, i<range, i++)
					range_left--
					step_towards(D,my_target)
					sleep(wait_step)

					for(var/atom/T in get_turf(D))
						if(T == D || T.invisibility) //we ignore the puff itself and stuff below the floor
							continue
						if(puff_reagent_left <= 0)
							break

						D.reagents.reaction(T, VAPOR)
						if(ismob(T))
							puff_reagent_left -= 1

					if(puff_reagent_left > 0 && (!range_left))
						D.reagents.reaction(get_turf(D), VAPOR)
						puff_reagent_left -= 1

					if(puff_reagent_left <= 0) // we used all the puff so we delete it.
						qdel(D)
						return
				qdel(D)
	return 1

/obj/item/mecha_parts/mecha_equipment/pepper/get_equip_info()
	return "[..()] \[[src.reagents.total_volume]\]"

/obj/item/mecha_parts/mecha_equipment/pepper/on_reagent_change()
	return

/obj/item/mecha_parts/mecha_equipment/pepper/can_attach(obj/mecha/combat/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/pepper/process()
	if(reagents.total_volume >= reagents.maximum_volume || !chassis.has_charge(energy_drain))
		return
	reagents.add_reagent("condensedcapsaicin", 25)
	chassis.use_power(25)
	update_equip_info()

/*/obj/vehicle/secway/New()
	var/first = TRUE
	if(first == TRUE)
		var/obj/mecha/combat/sec_ripley/SR = new /obj/mecha/combat/sec_ripley
		SR.loc = src.loc
		qdel(src)
		first = FALSE
	return

/turf/open/floor/plasteel/red/side/New()
	var/first = TRUE
	if(src.x == 125 && src.y == 173 && src.z == 1 && first == TRUE)
		qdel(src)
		var/turf/open/floor/mech_bay_recharge_floor/rf = PoolOrNew(/turf/open/floor/mech_bay_recharge_floor, src)
		var/obj/machinery/computer/mech_bay_power_console/C = new /obj/machinery/computer/mech_bay_power_console
		C.x = 126
		C.y = 173
		C.z = 1
		var/obj/machinery/mech_bay_recharge_port/P = new /obj/machinery/mech_bay_recharge_port
		P.x = 124
		P.y = 173
		P.z = 1
		P.recharging_turf = rf
		first = FALSE
	else
		..()*/