/*
 * Oh god
 * What the fuck am I doing
 * I am not good with compueter
 */


/obj/machinery/portable_atmospherics/hydroponics/proc/adjust_nutrient(var/amount, var/bloody = 0)
	if(seed)
		if(seed.hematophage != bloody)
			return
	else
		if(bloody)
			return
	nutrilevel += amount

/obj/machinery/portable_atmospherics/hydroponics/proc/adjust_water(var/amount)
	waterlevel += amount
	// Water dilutes toxin level.
	if(amount > 0)
		toxins -= amount*4

//Process reagents being input into the tray.
/obj/machinery/portable_atmospherics/hydroponics/proc/process_reagents()
	if(reagents.total_volume <= 0 || mutation_level >= 25)
		if(mutation_level) //probably a way to not check this twice but meh
			mutate(min(mutation_level, 25)) //Lazy 25u cap to prevent cheesing the whole thing
			mutation_level = 0
			return
	else
		for(var/datum/reagent/A in reagents.reagent_list)
			A.on_plant_life(src)
			reagents.update_total()

		check_level_sanity()
		update_icon_after_process = 1

/*
 -----------------------------------  -----------------------------------  -----------------------------------
*/

/datum/reagent/nutriment/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)
	if(T.seed && !T.dead)
		T.health += 0.5

/datum/reagent/fertilizer/eznutrient/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)

/datum/reagent/water/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_water(1)

/datum/reagent/mutagen
	custom_plant_metabolism = 2
/datum/reagent/mutagen/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.mutation_level += 1*T.mutation_mod*custom_plant_metabolism

/datum/reagent/radium
	custom_plant_metabolism = 2
/datum/reagent/radium/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.mutation_level += 0.6*T.mutation_mod*custom_plant_metabolism
	T.toxins += 4
	if(T.seed && !T.dead)
		T.health -= 1.5
		if(prob(20))T.mutation_mod += 0.1 //ha ha

/datum/reagent/fertilizer/left4zed/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)
	if(T.seed && !T.dead)
		T.health -= 0.5
		if(prob(30)) T.mutation_mod += 0.2

/datum/reagent/diethylamine
	custom_plant_metabolism = 0.1
/datum/reagent/diethylamine/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	if(prob(100*custom_plant_metabolism)) T.pestlevel -= 1
	if(T.seed && !T.dead)
		T.health += 0.1
		if(prob(200*custom_plant_metabolism))
			T.affect_growth(1)
		if(!T.seed.immutable)
			var/chance
			chance = unmix(T.seed.lifespan, 15, 125)*200*custom_plant_metabolism
			if(prob(chance))
				T.check_for_divergence(1)
				T.seed.lifespan++
			chance = unmix(T.seed.lifespan, 15, 125)*200*custom_plant_metabolism
			if(prob(chance))
				T.check_for_divergence(1)
				T.seed.endurance++

/datum/reagent/fertilizer/robustharvest
	custom_plant_metabolism = 0.1
/datum/reagent/fertilizer/robustharvest/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.05)
	if(prob(25*custom_plant_metabolism)) T.weedlevel += 1
	if(T.seed && !T.dead && prob(25*custom_plant_metabolism)) T.pestlevel += 1
	if(T.seed && !T.dead && !T.seed.immutable)
		var/chance
		chance = unmix(T.seed.potency, 15, 150)*350*custom_plant_metabolism
		if(prob(chance))
			T.check_for_divergence(1)
			T.seed.potency++
		chance = unmix(T.seed.yield, 6, 2)*15*custom_plant_metabolism
		if(prob(chance))
			T.check_for_divergence(1)
			T.seed.yield--
		/*chance = unmix(T.seed.endurance, 90, 15)*200*custom_plant_metabolism
		if(prob(chance))
			T.check_for_divergence(1)
			T.seed.endurance--*/

/datum/reagent/toxin/plantbgone/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins += 6
	T.weedlevel -= 8
	if(T.seed && !T.dead)
		T.health -= 20
		T.mutation_mod += 0.1

/datum/reagent/clonexadone
	custom_plant_metabolism = 0.5
/datum/reagent/clonexadone/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins -= 5
	if(T.seed && !T.dead)
		T.health += 5
		var/datum/seed/S = T.seed
		var/deviation
		if(T.age > S.maturation)
			deviation = max(S.maturation-1, T.age-rand(7,10))
		else
			deviation = S.maturation/S.growth_stages
		T.age -= deviation
		T.skip_aging++
		T.force_update = 1

/datum/reagent/milk/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	T.adjust_water(0.9)

/datum/reagent/beer/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.25)
	T.adjust_water(0.7)

/datum/reagent/blood/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.5, bloody=1)
	T.adjust_water(0.7)

/datum/reagent/phosphorus/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	T.adjust_water(-0.5)
	T.weedlevel -= 2

/datum/reagent/sugar/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	T.weedlevel += 2
	T.pestlevel += 2

/datum/reagent/sodiumchloride/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_water(-3)
	T.adjust_nutrient(-0.3)
	T.toxins += 8
	T.weedlevel -= 2
	T.pestlevel -= 1
	if(T.seed && !T.dead)
		T.health -= 2

/datum/reagent/sodawater/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	T.adjust_water(1)
	if(T.seed && !T.dead)
		T.health += 0.1

/datum/reagent/ammonia/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)
	if(T.seed && !T.dead)
		T.health += 0.5

/datum/reagent/adminordrazine/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)
	T.adjust_water(1)
	T.weedlevel -= 5
	T.pestlevel -= 5
	T.toxins -= 5
	if(T.seed && !T.dead)
		T.health += 50

/datum/reagent/anti_toxin/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins -= 10
	if(T.seed && !T.dead)
		T.health += 1

/datum/reagent/toxin/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins += 10

/datum/reagent/fluorine/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_water(-0.5)
	T.toxins += 25
	T.weedlevel -= 4
	if(T.seed && !T.dead)
		T.health -= 2

/datum/reagent/chlorine/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_water(-0.5)
	T.toxins += 15
	T.weedlevel -= 3
	if(T.seed && !T.dead)
		T.health -= 1

/datum/reagent/sacid/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins += 10
	T.weedlevel -= 2
	if(T.seed && !T.dead)
		T.health -= 4

/datum/reagent/pacid/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins += 20
	T.weedlevel -= 4
	if(T.seed && !T.dead)
		T.health -= 8

/datum/reagent/cryoxadone/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins -= 3
	if(T.seed && !T.dead)
		T.health += 3

/*
	// Reagent information for process(), consider moving this to a controller along
	// with cycle information under 'mechanical concerns' at some point.
	var/global/list/toxic_reagents = list( //TODO
		"anti_toxin" =     -2,
		"toxin" =           2,
		"fluorine" =        2.5,
		"chlorine" =        1.5,
		"sacid" =           1.5,
		"pacid" =           3,
		"plantbgone" =      3,
		"cryoxadone" =     -3,
		"radium" =          2
		)
	var/global/list/nutrient_reagents = list(
		"milk" =            0.1,
		"beer" =            0.25,
		"phosphorus" =      0.1,
		"sugar" =           0.1,
		"sodawater" =       0.1,
		"ammonia" =         1,
		"diethylamine" =    2,
		"nutriment" =       1,
		"adminordrazine" =  1,
		"eznutrient" =      1,
		"robustharvest" =   1,
		"left4zed" =        1
		)
	var/global/list/weedkiller_reagents = list(
		"fluorine" =       4,
		"chlorine" =       3,
		"phosphorus" =     2,
		"sugar" =         -2,
		"sacid" =          2,
		"pacid" =          4,
		"plantbgone" =     8,
		"adminordrazine" = 5
		)
	var/global/list/pestkiller_reagents = list(
		"sugar" =         -2,
		"diethylamine" =   2,
		"adminordrazine" = 5
		)
	var/global/list/water_reagents = list(
		"water" =           1,
		"adminordrazine" =  1,
		"milk" =            0.9,
		"beer" =            0.7,
		"flourine" =       -0.5,
		"chlorine" =       -0.5,
		"phosphorus" =     -0.5,
		"water" =           1,
		"sodawater" =       1,
		)
	var/global/list/mutagenic_reagents = list(
		"radium" =  0.6,
		"mutagen" = 1
		)
	var/global/list/aging_reagents = list(
		"clonexadone" =  -2
		)
	var/global/list/growspeed_reagents = list( //TODO
		"radium" =  0.6,
		"mutagen" = 1
		)

	// Beneficial reagents have values for modifying health, yield_mod and mut_mod (in that order).
	var/global/list/beneficial_reagents = list(
		"beer" =           list( -0.05, 0,   0   ),
		"fluorine" =       list( -2,    0,   0   ),
		"chlorine" =       list( -1,    0,   0   ),
		"phosphorus" =     list( -0.75, 0,   0   ),
		"sodawater" =      list(  0.1,  0,   0   ),
		"sacid" =          list( -1,    0,   0   ),
		"pacid" =          list( -2,    0,   0   ),
		"plantbgone" =     list( -2,    0,   0.2 ),
		"cryoxadone" =     list(  3,    0,   0   ),
		"clonexadone" =    list(  5,    0,   0   ),
		"ammonia" =        list(  0.5,  0,   0   ),
		"diethylamine" =   list(  1,    0,   0   ),
		"nutriment" =      list(  0.5,  0,   0 	 ),
		"radium" =         list( -1.5,  0,   0.2 ),
		"adminordrazine" = list(  1,    1,   1   ),
		"robustharvest" =  list(  0,    0,   0   ),
		"left4zed" =       list( -0.1,  0,   2   )
		)

	//Stat-altering reagents have values for modifying: Endurance, Lifespan, Potency, Yield, Nutrient Consumption, in that order.
	//The stats listed here are only the base amount, the actual effect they have is later randomized and potentially affected by diminishing returns.
	var/global/list/stat_altering_reagents = list( //TODO
		"robustharvest" =  list( -0.4, -0,4,  1, 0, 0) ,
		"diethylamine"  =  list(  0.4,  0,4,  0, 0, 0)
		)
*/

/*
//Process reagents being input into the tray.
/obj/machinery/portable_atmospherics/hydroponics/proc/process_reagents()

	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/portable_atmospherics/hydroponics/proc/process_reagents() called tick#: [world.time]")

	//if(!reagents) return

	if(reagents.total_volume <= 0)
		//Now that we've absorbed all the things in the tray, it would be a good time to mutate if we've recently absorbed mutagenic reagents
		if(mutation_level)
			mutate(mutation_level)
			mutation_level = 0
		return

	reagents.trans_to(temp_chem_holder, min(reagents.total_volume,rand(1,3)))

	for(var/datum/reagent/R in temp_chem_holder.reagents.reagent_list)

		var/reagent_total = temp_chem_holder.reagents.get_reagent_amount(R.id)

		//Handle some general level adjustments.
		if(toxic_reagents[R.id])
			toxins += toxic_reagents[R.id]         * reagent_total
		if(weedkiller_reagents[R.id])
			weedlevel -= weedkiller_reagents[R.id] * reagent_total
		if(pestkiller_reagents[R.id])
			pestlevel -= pestkiller_reagents[R.id] * reagent_total

		// Mutagen is distinct from the previous types and instead causes mutations.
		if(mutagenic_reagents[R.id])
			mutation_level += reagent_total*mutagenic_reagents[R.id]+mutation_mod

		if(seed && !dead)
			// Beneficial reagents have a few impacts along with health buffs.
			if(beneficial_reagents[R.id])
				health       += beneficial_reagents[R.id][1] * reagent_total
				yield_mod    += beneficial_reagents[R.id][2] * reagent_total
				mutation_mod += beneficial_reagents[R.id][3] * reagent_total
			// Stat-altering reagents are bound to slight randomness as well as a diminishing returns formula.
			if(!seed.immutable && beneficial_reagents[R.id])
				seed.endurance += stat_altering_reagents[R.id][1] * reagent_total * rand(80,120)/100 * unmix(seed.endurance, 100, 125)
				seed.lifespan  += stat_altering_reagents[R.id][2] * reagent_total * rand(80,120)/100 * unmix(seed.lifespan, 100, 125)
				seed.potency   += stat_altering_reagents[R.id][3] * reagent_total * rand(80,120)/100 * unmix(seed.potency, 30, 100)
				if (seed.yield != -1)
					seed.yield += stat_altering_reagents[R.id][3] * reagent_total * rand(80,120)/100 * unmix(seed.yield, 3, 9)
			// Some reagents can directly modify the plant's age.
			if(aging_reagents[R.id])
				age += aging_reagents[R.id] * reagent_total
				force_update = 1

		// Handle nutrient refilling.
		if(nutrient_reagents[R.id]) //TODO BLOOD FOR THE BLOOD PLANT
			nutrilevel += nutrient_reagents[R.id]  * reagent_total

		// Handle water and water refilling.
		var/water_added = 0
		if(water_reagents[R.id])
			var/water_input = water_reagents[R.id] * reagent_total
			water_added += water_input
			waterlevel += water_input

		// Water dilutes toxin level.
		if(water_added > 0)
			toxins -= round(water_added/4)

	temp_chem_holder.reagents.clear_reagents()
	check_level_sanity()
	update_icon()
*/
