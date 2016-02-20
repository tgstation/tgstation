/obj/effect/fire_blast
	name = "fire blast"
	desc = "That looks hot."
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	density = 0
	unacidable = 1
	anchored = 1.0
	w_type=NOT_RECYCLABLE
	var/fire_damage = 0
	var/blast_age = 1


/obj/effect/fire_blast/New(turf/T, var/damage = 0, var/current_step = 0, var/age = 1, var/pressure = 0, var/blast_temperature = 0)
	..(T)
	icon_state = "[rand(1,3)]"

	blast_age = age

	if(damage)
		fire_damage = damage
	set_light(3)

	var/spread_start = 100
	pressure = round(pressure)
	var/spread_chance = 20
	var/adjusted_fire_damage = fire_damage

	switch(pressure)
		if(1000 to INFINITY)
			spread_start = 5
			spread_chance = 50
		if(800 to 999)
			spread_start = 6
			spread_chance = 40
			adjusted_fire_damage = fire_damage * 0.9
		if(600 to 799)
			spread_start = 7
			spread_chance = 30
			adjusted_fire_damage = fire_damage * 0.8
		if(400 to 599)
			spread_start = 8
			adjusted_fire_damage = fire_damage * 0.7
		if(300 to 399)
			spread_start = 9
			adjusted_fire_damage = fire_damage * 0.6
		if(150 to 299)
			spread_start = 10
			adjusted_fire_damage = fire_damage * 0.4
		if(0 to 149)
			adjusted_fire_damage = fire_damage * 0.25

	spawn()
		if(current_step >= spread_start && blast_age < 4)
			var/turf/TS = get_turf(src)
			for(var/turf/TU in range(1, TS))
				if(TU != get_turf(src))
					var/tilehasfire = 0
					var/obstructed = 0
					for(var/obj/effect/E in TU)
						if(istype(E, /obj/effect/fire_blast))
							tilehasfire = 1
					for(var/obj/machinery/door/D in TU)
						if(istype(D, /obj/machinery/door/airlock) || istype(D, /obj/machinery/door/mineral))
							if(D.density)
								obstructed = 1
					if(prob(spread_chance) && TS.Adjacent(TU) && !TU.density && !tilehasfire && !obstructed)
						new /obj/effect/fire_blast(TU, fire_damage, current_step, blast_age+1, pressure, blast_temperature)
				sleep(1)

	spawn()
		for(var/i = 1; i <= 5; i++)
			for(var/mob/living/L in get_turf(src))
				if(!istype(L, /mob/living/silicon)) //Silicons are immune to fire
					if(!istype(L, /mob/living/carbon))
						L.adjustFireLoss(adjusted_fire_damage * 2) //Deals double damage to non-carbon mobs
					else
						L.adjustFireLoss(adjusted_fire_damage)
					if(!L.on_fire)
						L.adjust_fire_stacks(0.5)
						L.IgniteMob()
			for(var/obj/O in T)
				if(istype(O, /obj/structure/reagent_dispensers/fueltank))
					var/obj/structure/reagent_dispensers/fueltank/F = O
					if(blast_temperature >= 561.15) //561.15 is welderfuel's autoignition temperature.
						F.explode()
				else if(O.autoignition_temperature)
					if(blast_temperature >= O.autoignition_temperature)
						O.ignite(blast_temperature)
			for(var/obj/effect/E in T)
				if(istype(E, /obj/effect/blob))
					var/obj/effect/blob/B = E
					B.health -= (adjusted_fire_damage/10)
					B.update_icon()
			var/turf/T2 = get_turf(src)
			T2.hotspot_expose((blast_temperature * 2) + 380,500)
			sleep(2)

		qdel(src)

/obj/effect/gas_puff
	name = "gas puff"
	desc = "A small puff of gas."
	icon = 'icons/effects/plasma.dmi'
	icon_state = null
	density = 0
	unacidable = 1
	anchored = 1.0
	w_type=NOT_RECYCLABLE

/obj/effect/gas_puff/New(turf/T, var/datum/gas_mixture/stored_gas = null, var/type_of_gas)
	..(T)

	if(type_of_gas)
		switch(type_of_gas)
			if("plasma")
				icon_state = "onturf-purple"
				name = "plasma puff"
				desc = "A small puff of plasma gas."
			if("N2O")
				icon_state = "sl_gas"
				name = "N2O puff"
				desc = "A small puff of nitrogen dioxide gas."
		update_icon()

	if(stored_gas)
		loc.assume_air(stored_gas)

	spawn()
		for(var/i = 1; i <= 5; i++)
			sleep(2)

		qdel(src)