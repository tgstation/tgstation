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
		ANTI_TOXIN =     -2,
		TOXIN =           2,
		FLUORINE =        2.5,
		CHLORINE =        1.5,
		SACID =           1.5,
		PACID =           3,
		PLANTBGONE =      3,
		CRYOXADONE =     -3,
		RADIUM =          2
		)
	var/global/list/nutrient_reagents = list(
		MILK =            0.1,
		BEER =            0.25,
		PHOSPHORUS =      0.1,
		SUGAR =           0.1,
		SODAWATER =       0.1,
		AMMONIA =         1,
		DIETHYLAMINE =    2,
		NUTRIMENT =       1,
		ADMINORDRAZINE =  1,
		EZNUTRIENT =      1,
		ROBUSTHARVEST =   1,
		LEFT4ZED =        1
		)
	var/global/list/weedkiller_reagents = list(
		FLUORINE =       4,
		CHLORINE =       3,
		PHOSPHORUS =     2,
		SUGAR =         -2,
		SACID =          2,
		PACID =          4,
		PLANTBGONE =     8,
		ADMINORDRAZINE = 5
		)
	var/global/list/pestkiller_reagents = list(
		SUGAR =         -2,
		DIETHYLAMINE =   2,
		ADMINORDRAZINE = 5
		)
	var/global/list/water_reagents = list(
		WATER =           1,
		ADMINORDRAZINE =  1,
		MILK =            0.9,
		BEER =            0.7,
		"flourine" =       -0.5,
		CHLORINE =       -0.5,
		PHOSPHORUS =     -0.5,
		WATER =           1,
		SODAWATER =       1,
		)
	var/global/list/mutagenic_reagents = list(
		RADIUM =  0.6,
		MUTAGEN = 1
		)
	var/global/list/aging_reagents = list(
		CLONEXADONE =  -2
		)
	var/global/list/growspeed_reagents = list( //TODO
		RADIUM =  0.6,
		MUTAGEN = 1
		)

	// Beneficial reagents have values for modifying health, yield_mod and mut_mod (in that order).
	var/global/list/beneficial_reagents = list(
		BEER =           list( -0.05, 0,   0   ),
		FLUORINE =       list( -2,    0,   0   ),
		CHLORINE =       list( -1,    0,   0   ),
		PHOSPHORUS =     list( -0.75, 0,   0   ),
		SODAWATER =      list(  0.1,  0,   0   ),
		SACID =          list( -1,    0,   0   ),
		PACID =          list( -2,    0,   0   ),
		PLANTBGONE =     list( -2,    0,   0.2 ),
		CRYOXADONE =     list(  3,    0,   0   ),
		CLONEXADONE =    list(  5,    0,   0   ),
		AMMONIA =        list(  0.5,  0,   0   ),
		DIETHYLAMINE =   list(  1,    0,   0   ),
		NUTRIMENT =      list(  0.5,  0,   0 	 ),
		RADIUM =         list( -1.5,  0,   0.2 ),
		ADMINORDRAZINE = list(  1,    1,   1   ),
		ROBUSTHARVEST =  list(  0,    0,   0   ),
		LEFT4ZED =       list( -0.1,  0,   2   )
		)

	//Stat-altering reagents have values for modifying: Endurance, Lifespan, Potency, Yield, Nutrient Consumption, in that order.
	//The stats listed here are only the base amount, the actual effect they have is later randomized and potentially affected by diminishing returns.
	var/global/list/stat_altering_reagents = list( //TODO
		ROBUSTHARVEST =  list( -0.4, -0,4,  1, 0, 0) ,
		DIETHYLAMINE  =  list(  0.4,  0,4,  0, 0, 0)
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
