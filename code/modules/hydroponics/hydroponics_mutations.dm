//The astrogator has a way with plants of every type.
//She nurtures alien veg'tables and cooks them when they're ripe!
//She had a Veged orchid once that ate the captain's cat.
//Then terrorized the ship's exec, until she squashed it flat!

//Mutates the plant overall (randomly).
/obj/machinery/portable_atmospherics/hydroponics/proc/mutate(var/severity)

	if(!severity) return

	// No seed? Try to mutate the weeds or pests in the tray, if any.
	if(!seed)
		//TODO
		return

	if(seed.immutable)
		return

	//Is the plant still a sapling? If so, try to mutate species, otherwise do something bad.
	if(age < 3)
		if(seed.mutants. && seed.mutants.len)
			if(prob(30))
				mutate_species()
				return
		var/mutation_type = pick_mut(severity, MUTCAT_BAD)
		apply_mut(mutation_type, severity)
		return

	var/mutation_type = pick_mut(severity)
	apply_mut(mutation_type, severity)

/obj/machinery/portable_atmospherics/hydroponics/proc/pick_mut(var/severity, var/mutation_category = "")

	var/datum/seed/S = seed
	if (!S) return

	//First we'll pick a CATEGORY of mutations to look from, for simplicity and to keep an even ratio of good things to bad things if more mutations are added.
	//This looks like shit, but it's a lot easier to read/change this way. Maybe. Promise. Hahaha. Shit.
	if(!mutation_category) //If we already have a category, use that instead.
		mutation_category = pick(\
			// What's going on with these numbers?
			// Effectively, the weight of each category is a linear function that increases with the potency of the mutation.
			// Most categories have an integer deducted from severity, this means that the chance for that mutation
			// is 0 below said severity (e.g. you won't get dangerous shit if you use less than 14u mutagen).
			15;								MUTCAT_GOOD, \
			Clamp(0.4*severity, 	0, 7);	MUTCAT_BAD, \
			Clamp(0.7*(severity-5), 0, 8); 	MUTCAT_WEIRD, \
			Clamp(severity-12, 		0, 7); 	MUTCAT_WEIRD2, \
			Clamp(severity-12, 		0, 14); MUTCAT_BAD2, \
			Clamp(severity-14,		0, 20); MUTCAT_DANGEROUS \
			)
	var/mutation_type
	//Now we'll pick a certain type of mutation from that category, special considerations in mind.
	switch(mutation_category)
		if(MUTCAT_GOOD)
			mutation_type = pick(\
			// What's going on with these numbers?
			// We want a different weight for the mutation depending on whether the plant already has it. For example, a non-glowey plant
			// will have a fair chance to toggle bio-luminiscence. However, if it already has bioluminiscence, then it will have a smaller
			// chance to toggle again, since then it would stop glowing, which is less fun and frustrating if you're trying to stack mutations.
			10;						"plusstat_potency", \
			S.yield == -1 ? 0 : 6;	"plusstat_yield",\
			3;						"plusstat_weed&toxins_tolerance",\
			5;						"plusstat_lifespan&endurance",\
			5;						"plusstat_production&maturation",\
			3;						"plusstat_heat&pressure_tolerance",\
			3;						"plusstat_light_tolerance", \
			3;						"plusstat_nutrient&water_consumption", \
			S.yield != -1 && !S.harvest_repeat ? 0.4 : 0;	"toggle_repeatharvest"
			)
		if(MUTCAT_WEIRD)
			mutation_type = pick(\
			S.biolum ? 10 : 0;			"biolum_changecolor",\
			S.biolum ? 1 : 10;			"trait_biolum",\
			S.juicy ? 0.5 : 5;			"trait_juicy", \
			S.juicy == 1 ? 10 : 2 ;		"trait_slippery", \
			S.thorny ? 0.2 : 5;			"trait_thorns",\
			S.parasite ? 0.2 : 5;		"trait_parasitic",\
			S.carnivorous ? 0.1 : 5;	"trait_carnivorous",\
			S.carnivorous == 1 ? 8 : 2;	"trait_carnivorous2",\
			S.ligneous ? 0.2 : 5;		"trait_ligneous"
			)
		if(MUTCAT_WEIRD2)
			mutation_type = pick(\
			4;					"chemical_exotic", \
			6;					"fruit_exotic", \
			2;					"change_appearance", \
			S.spread ? 0.1 : 1;	"trait_creepspread"
			)
		if(MUTCAT_BAD)
			mutation_type = pick(\
			3;	"tox_increase", \
			2;	"weed_increase", \
			2;	"pest_increase", \
			5;	"stunt_growth"
			)
		if(MUTCAT_BAD2)
			mutation_type = pick(\
			S.hematophage ? 0.2 : 5;	"trait_hematophage", \
			5;							"randomize_light", \
			5;							"randomize_temperature", \
			2;							"breathe_aliengas", \
			S.yield != -1 && S.harvest_repeat ? 2 : 0;	"toggle_repeatharvest",\
			)
		if(MUTCAT_DANGEROUS)
			mutation_type = pick(\
			4;						"spontaneous_creeper", \
			1;						"spontaneous_kudzu", \
			S.spread == 1 ? 5 : 1;	"trait_vinespread",
			S.stinging ? 0.2 : 4;	"trait_stinging", \
			1;						"exude_dangerousgas", \
			S.alter_temp ? 0.2 : 2;	"change_roomtemp"
			)
	return mutation_type

/obj/machinery/portable_atmospherics/hydroponics/proc/generic_mutation_message(var/text = "quivers!")
	visible_message("<span class='notice'>\The [seed.display_name] [text]</span>")

/obj/machinery/portable_atmospherics/hydroponics/proc/check_for_divergence(var/modified = 0)
	// We need to make sure we're not modifying one of the global seed datums.
	// If it's not in the global list, then no products of the line have been
	// harvested yet and it's safe to assume it's restricted to this tray.
	if(!isnull(plant_controller.seeds[seed.name]))
		seed = seed.diverge(modified)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_ratio(var/severity, var/list/softcaps, var/list/hardcaps, var/input)
	var/i = min(Ceiling(severity/5), 5)
	var/lerp_factor = (severity % 5) /5
	var/softcap = mix(softcaps[i], softcaps[i+1], lerp_factor)
	var/hardcap = mix(hardcaps[i], hardcaps[i+1], lerp_factor)
	return(unmix(input, softcap, hardcap))

/obj/machinery/portable_atmospherics/hydroponics/proc/apply_mut(var/mutation_type, var/severity)

	// Check if we should even bother working on the current seed datum.
	if(seed.immutable > 0) return

	check_for_divergence()

	//testing("Mutation Category: [mutation_category] - Mutation Type: [mutation_type]. Severity: [severity]. All category weights at this sev: GOOD=15/BAD=[Clamp(0.4*severity,0, 7)]/WEIRD=[Clamp(0.7*(severity-5),0,8)]/BIZZARE=[Clamp(severity-12,0,7)]/AWFUL=[Clamp(severity-12,0,14)]/DANGEROUS=[Clamp(severity-14,0,20)]")
	switch(mutation_type)
		if("code_explanation")
			// DEARIE ME, WHAT IS GOING ON HERE?
			// Each stat mutation will have a "soft cap" and a "hard cap" depending on how much mutagen is used. If the stat to mutate is bigger than the "soft cap",
			// the strength of the mutation will decrease. As that stat approaches the "hard cap", the strength of subsequent mutations will linearly decrease to 0.
			// Example: If the potency "soft cap" is 50, the "hard cap" is 75, and your plant has 60 potency, then the mutation will only be 60% of what is listed.

			// The actual caps depend on how much mutagen is used. The values below represent the caps at 0, 5, 10, 15, 20, and 25 mutagen respectively.
			var/list/softcap_values = list(5,  20, 50,  100, 150, 180)
			var/list/hardcap_values = list(35, 45, 100, 180, 250, 300)
			// Since the dose of mutagen can be any number, we're going to linearly interpolate between the closest values of those lists above to find the real caps.
			// This is the list index of the lower bound of the mutagen dosage. (i.e. for 12 mutagen, it would be 3, which represents 10). i+1 is the upper bound.
			var/i = min(Ceiling(severity/5), 5)
			// Now we have two values to linearly interpolate from. To feed the linear interpolation something, we'll use the remainder of the division above.
			var/lerp_factor = (severity % 5) /5
			// Finally, we use the linear interpolation function, and we'll have our final soft cap and hard cap.
			var/softcap = mix(softcap_values[i], softcap_values[i+1], lerp_factor)
			var/hardcap = mix(hardcap_values[i], hardcap_values[i+1], lerp_factor)
			// Excellent! Now we can check if the mutation's strength should be affected by these caps.
			// To do this, we use the unmix function, which returns a decimal number from 0 to 1.
			var/cap_ratio = unmix(seed.potency, softcap, hardcap)
			// Now that we have all the final modifiers, we can calculate the mutation's final strength.
			var/deviation = severity * (rand(50, 125)/100) * cap_ratio
			//Deviation per 10u Mutagen before cap: 5-12.5
			seed.potency = Clamp(seed.potency + deviation, 0, 200)
			generic_mutation_message("quivers!")

		if("plusstat_potency")
			var/list/softcap_values = list(5,  20, 50,  100, 150, 180)
			var/list/hardcap_values = list(35, 45, 100, 180, 250, 300)
			var/deviation = severity * (rand(50, 125)/100) * get_ratio(severity, softcap_values, hardcap_values, seed.potency)
			//Deviation per 10u Mutagen before cap: 5-12.5
			seed.potency = Clamp(seed.potency + deviation, 0, 200)
			generic_mutation_message("quivers!")

		if("plusstat_yield")
			if(seed.yield == -1)
				visible_message("<span class='notice'>\The [seed.display_name] twitches for a second, but nothing seems to happen...</span>")
				return
			var/list/softcap_values = list(2, 3, 6,  9,  12, 12)
			var/list/hardcap_values = list(4, 5, 10, 15, 17, 20)
			var/deviation = severity * (rand(6, 12)/100) * get_ratio(severity, softcap_values, hardcap_values, seed.yield)
			//Deviation per 10u Mutagen before cap: 0.6-1.2
			seed.yield = Clamp(seed.yield + deviation, 0, 16)
			generic_mutation_message("quivers!")

		if("plusstat_weed&toxins_tolerance")
			var/list/softcap_values = list(2, 3, 6,  9,  11, 11)
			var/list/hardcap_values = list(4, 5, 10, 12, 12, 12)
			var/deviation = severity * (rand(6, 12)/100) * get_ratio(severity, softcap_values, hardcap_values, seed.weed_tolerance)
			//Deviation per 10u Mutagen before cap: 0.6-1.2
			seed.weed_tolerance = Clamp(seed.weed_tolerance + deviation, 0, 11)

			softcap_values = list(2, 3, 6,  9,  11, 11)
			hardcap_values = list(4, 5, 10, 12, 12, 12)
			deviation = severity * (rand(6, 12)/100) * get_ratio(severity, softcap_values, hardcap_values, seed.toxins_tolerance)
			//Deviation per 10u Mutagen before cap: 0.6-1.2
			seed.toxins_tolerance = Clamp(seed.toxins_tolerance + deviation, 0, 11)
			generic_mutation_message("quivers!")

		if("plusstat_lifespan&endurance")
			var/list/softcap_values = list(2, 65, 80,  95,  110, 125)
			var/list/hardcap_values = list(4, 75, 100, 125, 150, 150)
			var/deviation = severity * (rand(50, 80)/100) * get_ratio(severity, softcap_values, hardcap_values, seed.lifespan)
			//Deviation per 10u Mutagen before cap: 5-8
			seed.lifespan = Clamp(seed.lifespan + deviation, 10, 125)

			softcap_values = list(2, 65, 80,  95,  110, 125)
			hardcap_values = list(4, 75, 100, 125, 150, 150)
			deviation = severity * (rand(30, 50)/100) * get_ratio(severity, softcap_values, hardcap_values, seed.endurance)
			//Deviation per 10u Mutagen before cap: 3-5
			seed.endurance = Clamp(seed.endurance + deviation, 10, 125)
			generic_mutation_message("quivers!")

		if("plusstat_production&maturation")
			var/list/softcap_values = list(10, 7.5, 5,  2.5,  2,    1)
			var/list/hardcap_values = list(5,  3.5, 2,  1,    0.75, 0)
			var/deviation = severity * (rand(4, 8)/100) * get_ratio(severity, softcap_values, hardcap_values, seed.production)
			//Deviation per 10u Mutagen before cap: 0.4-0.8
			seed.production = Clamp(seed.production - deviation, 1, 10)

			softcap_values = list(10, 7.5, 5,  2.5, 2,    1)
			hardcap_values = list(5,  3.5, 2,  1,   0.75, 0)
			deviation = severity * (rand(8, 12)/100) * get_ratio(severity, softcap_values, hardcap_values, seed.maturation)
			//Deviation per 10u Mutagen before cap: 0.8-1.2
			seed.maturation = Clamp(seed.maturation - deviation, 1, 30)
			generic_mutation_message("quivers!")

		if("plusstat_heat&pressure_tolerance")
			var/list/softcap_values = list(100, 150, 300, 450,  600,    900)
			var/list/hardcap_values = list(200, 300, 600, 900,    1200, 1200)
			var/deviation = severity * (rand(100, 250)/100) * get_ratio(severity, softcap_values, hardcap_values, seed.heat_tolerance)
			//Deviation per 10u Mutagen before cap: 10-25
			seed.heat_tolerance = Clamp(seed.heat_tolerance + deviation, 1, 800)

			softcap_values = list(20, 12.5, 5, 0, 0, 0)
			hardcap_values = list(15, 5,    0, 0, 0, 0)
			deviation = severity * (rand(20, 50)/100) * get_ratio(severity, softcap_values, hardcap_values, seed.lowkpa_tolerance)
			//Deviation per 10u Mutagen before cap: 2-5
			seed.lowkpa_tolerance = Clamp(seed.lowkpa_tolerance - deviation, 0, 80)

			softcap_values = list(20, 275, 350, 450, 500, 500)
			hardcap_values = list(15, 325, 450, 575, 575, 575)
			deviation = severity * (rand(200, 300)/100) * get_ratio(severity, softcap_values, hardcap_values, seed.highkpa_tolerance)
			//Deviation per 10u Mutagen before cap: 20-30
			seed.highkpa_tolerance = Clamp(seed.highkpa_tolerance + deviation, 110, 500)
			generic_mutation_message("quivers!")

		if("plusstat_light_tolerance")
			var/list/softcap_values = list(2, 5, 8,  9,  11, 11)
			var/list/hardcap_values = list(4, 7, 10, 12, 12, 12)
			var/deviation = severity * (rand(6, 12)/100) * get_ratio(severity, softcap_values, hardcap_values, seed.light_tolerance)
			//Deviation per 10u Mutagen before cap: 0.6-1.2
			seed.light_tolerance = Clamp(seed.light_tolerance + deviation, 0, 10)
			generic_mutation_message("quivers!")

		if("plusstat_nutrient&water_consumption")
			var/list/softcap_values = list(0.30, 0.25, 0.15, 0.05, 0, 0)
			var/list/hardcap_values = list(0.15, 0.10, 0.05, 0,    0, 0)
			var/deviation = severity * (rand(3, 7)/1000) * get_ratio(severity, softcap_values, hardcap_values, seed.nutrient_consumption)
			//Deviation per 10u Mutagen before cap: 0.03-0.07
			seed.nutrient_consumption = Clamp(seed.nutrient_consumption - deviation, 0, 1)

			softcap_values = list(4, 3,   1.5, 0.5, 0, 0)
			hardcap_values = list(2, 1.5, 0.5, 0,   0, 0)
			deviation = severity * (rand(6, 12)/100) * get_ratio(severity, softcap_values, hardcap_values, seed.water_consumption)
			//Deviation per 10u Mutagen before cap: 0.6-1.2
			seed.water_consumption = Clamp(seed.water_consumption - deviation, 0, 10)
			generic_mutation_message("quivers!")

		if("tox_increase")
			toxins += rand(50,80)
			generic_mutation_message("shudders!")
		if("weed_increase")
			weedlevel = max(4, weedlevel * 2)
			generic_mutation_message("shudders!")
		if("pest_increase")
			pestlevel = max(4, pestlevel * 2)
			generic_mutation_message("shudders!")
		if("stunt_growth")
			affect_growth(-rand(2,4))
			generic_mutation_message("droops idly...")

		if("randomize_light")
			seed.ideal_light = rand(2,10)
			generic_mutation_message("shakes!")

		if("randomize_temperature") //Variance so small that it can be fixed by just touching the thermostat, but I guarantee people will just apply a new enviro gene anyways
			seed.ideal_heat = rand(253,343)
			generic_mutation_message("shakes!")

		if("breathe_aliengas") //This is honestly awful and pretty unfun. It just guarantees that the user will have to apply a new enviro gene. But for now I'm leaving it in
			var/gas = pick("oxygen","nitrogen","plasma","carbon_dioxide")
			seed.consume_gasses[gas] = rand(3,9)
			generic_mutation_message("shakes!")

		if("exude_dangerousgas")
			var/gas = pick("nitrogen","plasma","carbon_dioxide")
			seed.exude_gasses[gas] = rand(3,9)
			generic_mutation_message("shakes!")

		if("change_roomtemp") //we'll see how this one works out
			if(!seed.alter_temp)
				seed.alter_temp = 1
				var/deviation = rand(severity*0.5,severity)*(prob(50) ? 3 : -3)
				seed.heat_tolerance = Clamp(seed.heat_tolerance + (deviation*0.8), 1, 800)
				seed.ideal_heat += deviation
			else
				seed.alter_temp = 0
			generic_mutation_message("shakes!")

		if("toggle_repeatharvest")
			seed.harvest_repeat = !seed.harvest_repeat
			if(seed.harvest_repeat)
				visible_message("<span class='notice'>\The [seed.display_name] roots deep and sprouts a bevy of new stalks!</span>")
			else
				visible_message("<span class='notice'>\The [seed.display_name] wilts away some of it's roots...</span>")

		if("trait_biolum")
			seed.biolum = !seed.biolum
			if(seed.biolum)
				visible_message("<span class='notice'>\The [seed.display_name] begins to glow!</span>")
				if(!seed.biolum_colour)
					seed.biolum_colour = "#[get_random_colour(1)]"
			else
				visible_message("<span class='notice'>\The [seed.display_name]'s glow dims...</span>")
			update_icon()

		if("biolum_changecolor")
			seed.biolum_colour = "#[get_random_colour(0,75,190)]"
			visible_message("<span class='notice'>\The [seed.display_name]'s glow <font color='[seed.biolum_colour]'>changes colour</font>!</span>")
			update_icon()

		if("spontaneous_creeper")
			visible_message("<span class='notice'>\The [seed.display_name] spasms visibly, shifting in the tray!</span>")
			spawn(20)
				if(src && seed)
					var/datum/seed/newseed = seed.diverge()
					newseed.spread = 1
					var/turf/T = get_turf(src)
					new /obj/effect/plantsegment(T, newseed)
					msg_admin_attack("a random chance hydroponics mutation has spawned limited growth creeper vines ([newseed.display_name]). <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a>")

		if("spontaneous_kudzu")
			visible_message("<span class='notice'>\The [seed.display_name] thrashes about, growing out of control!</span>")
			spawn(20)
				if(src && seed)
					var/datum/seed/newseed = seed.diverge()
					newseed.spread = 2
					var/turf/T = get_turf(src)
					new /obj/effect/plantsegment(T, newseed)
					msg_admin_attack("a random chance hydroponics mutation has spawned space vines ([newseed.display_name]). <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a>")

		if("change_appearance")
			seed.randomize_icon(change_packet=0)
			update_icon()
			visible_message("<span class='notice'>\The [seed.display_name] suddenly looks a little different.</span>")

		if("fruit_exotic")
			seed.products += pick(typesof(/obj/item/weapon/reagent_containers/food/snacks/grown)-/obj/item/weapon/reagent_containers/food/snacks/grown)
			visible_message("<span class='notice'>\The [seed.display_name] seems to be growing something weird.</span>")

		if("chemical_exotic")
			seed.add_random_chemical(severity)
			visible_message("<span class='notice'>\The [seed.display_name] develops a strange-looking gland...</span>")

		if("trait_hematophage")
			seed.hematophage = !seed.hematophage
			if(seed.hematophage)
				visible_message("<span class='notice'>\The [seed.display_name] shudders thirstily, turning red at the roots!</span>")
				nutrilevel = 1
			else
				visible_message("<span class='notice'>\The [seed.display_name]'s red roots slowly wash their color out...</span>")

		if("trait_creepspread")
			seed.spread = seed.spread ? 0 : 1
			generic_mutation_message("spasms visibly, shifting in the tray!")

		if("trait_vinespread")
			switch(seed.spread)
				if(0 to 1)
					seed.spread = 2
				if(2)
					seed.spread = 0
			generic_mutation_message("spasms visibly, shifting in the tray!")

		if("trait_teleporting")
			seed.teleporting = !seed.teleporting
			if(seed.teleporting)
				visible_message("<span class='notice'>\The [seed.display_name] wobbles unstably, glowing blue for a moment!</span>")
			else
				visible_message("<span class='notice'>\The [seed.display_name] slowly becomes spatial-temporally stable again.</span>")

		if("trait_ligneous")
			seed.ligneous = !seed.ligneous
			if(seed.ligneous)
				visible_message("<span class='notice'>\The [seed.display_name] seems to grow a cover of robust bark.</span>")
			else
				visible_message("<span class='notice'>\The [seed.display_name]'s bark slowly sheds away...</span>")

		if("trait_parasitic")
			seed.parasite = !seed.parasite
			if(seed.parasite)
				generic_mutation_message("shudders hungrily.")
			else
				generic_mutation_message("seems to mellow down...")

		if("trait_juicy")
			seed.juicy = seed.juicy ? 0 : 1
			generic_mutation_message("wobbles!")

		if("trait_slippery")
			switch(seed.juicy)
				if(0 to 1)
					seed.juicy = 2
				if(2)
					seed.juicy = 0
			generic_mutation_message("wobbles!")

		if("trait_thorns")
			seed.thorny = !seed.thorny
			if(seed.thorny)
				visible_message("<span class='notice'>\The [seed.display_name] spontaneously develops mean-looking thorns!</span>")
			else
				visible_message("<span class='notice'>\The [seed.display_name] sheds it's thorns away...</span>")

		if("trait_stinging")
			seed.stinging = !seed.stinging
			if(seed.stinging)
				visible_message("<span class='notice'>\The [seed.display_name] sprouts a coat of chemical stingers!</span>")
			else
				visible_message("<span class='notice'>\The [seed.display_name]'s stingers dry off and break...</span>")

		if("trait_carnivorous")
			seed.carnivorous = seed.carnivorous ? 0 : 1
			if(seed.carnivorous)
				generic_mutation_message("shudders hungrily.")
			else
				generic_mutation_message("seems to mellow down...")

		if("trait_carnivorous2")
			switch(seed.carnivorous)
				if(0 to 1)
					seed.carnivorous = 2
					generic_mutation_message("shudders hungrily.")
				if(2)
					seed.carnivorous = 0
					generic_mutation_message("seems to mellow down...")

		else
			error("Tried to apply a Hydroponics mutation, \"[mutation_type]\", which doesn't exist.")

	return
	//visible_message("<span class='notice'>\The [seed.display_name] quivers!</span>")

	/*//This looks like shit, but it's a lot easier to read/change this way.
	var/total_mutations = rand(1,1+degree)
	for(var/i = 0 to total_mutations)
		switch(rand(0,11))
			if(0) //Plant cancer!
				lifespan = max(0,lifespan-rand(1,5))
				endurance = max(0,endurance-rand(10,20))
				source_turf.visible_message("<span class='warning'>\The [display_name] withers rapidly!</span>")
			if(1)
				nutrient_consumption =      max(0,  min(5,   nutrient_consumption + rand(-(degree*0.1),(degree*0.1))))
				water_consumption =         max(0,  min(50,  water_consumption    + rand(-degree,degree)))
			if(2)
				ideal_heat =                max(70, min(800, ideal_heat           + (rand(-5,5)   * degree)))
				heat_tolerance =            max(70, min(800, heat_tolerance       + (rand(-5,5)   * degree)))
				lowkpa_tolerance =          max(0,  min(80,  lowkpa_tolerance     + (rand(-5,5)   * degree)))
				highkpa_tolerance =         max(110, min(500,highkpa_tolerance    + (rand(-5,5)   * degree)))
			if(3)
				ideal_light =               max(0,  min(30,  ideal_light          + (rand(-1,1)   * degree)))
				light_tolerance =           max(0,  min(10,  light_tolerance      + (rand(-2,2)   * degree)))
			if(4)
				toxins_tolerance =          max(0,  min(10,  weed_tolerance       + (rand(-2,2)   * degree)))//nice copypaste
			if(5)
				weed_tolerance  =           max(0,  min(10,  weed_tolerance       + (rand(-2,2)   * degree)))
				if(prob(degree*5))
					carnivorous =           max(0,  min(2,   carnivorous          + rand(-degree,degree)))
					if(carnivorous)
						source_turf.visible_message("<span class='notice'>\The [display_name] shudders hungrily.</span>")
			if(6)
				weed_tolerance  =           max(0,  min(10,  weed_tolerance       + (rand(-2,2)   * degree)))
				if(prob(degree*5))          parasite = !parasite

			if(7)
				lifespan =                  max(10, min(30,  lifespan             + (rand(-2,2)   * degree)))
				if(yield != -1) yield =     max(0,  min(10,  yield                + (rand(-2,2)   * degree)))
			if(8)
				endurance =                 max(10, min(100, endurance            + (rand(-5,5)   * degree)))
				production =                max(1,  min(10,  production           + (rand(-1,1)   * degree)))
				potency =                   max(0,  min(200, potency              + (rand(-20,20) * degree)))
				if(prob(degree*5))
					spread =                max(0,  min(2,   spread               + rand(-1,1)))
					source_turf.visible_message("<span class='notice'>\The [display_name] spasms visibly, shifting in the tray.</span>")
			if(9)
				maturation =                max(0,  min(30,  maturation      + (rand(-1,1)   * degree)))
				if(prob(degree*5))
					harvest_repeat = !harvest_repeat
			if(10)
				if(prob(degree*4))
					biolum = !biolum
					if(biolum)
						source_turf.visible_message("<span class='notice'>\The [display_name] begins to glow!</span>")
						if(prob(degree*4))
							biolum_colour = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
							source_turf.visible_message("<span class='notice'>\The [display_name]'s glow <font color='[biolum_colour]'>changes colour</font>!</span>")
					else
						source_turf.visible_message("<span class='notice'>\The [display_name]'s glow dims...</span>")
			if(11)
				if(prob(degree*2))
					flowers = !flowers
					if(flowers)
						source_turf.visible_message("<span class='notice'>\The [display_name] sprouts a bevy of flowers!</span>")
						if(prob(degree*2))
							flower_colour = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
						source_turf.visible_message("<span class='notice'>\The [display_name]'s flowers <font='[flower_colour]'>changes colour</font>!</span>")
					else
						source_turf.visible_message("<span class='notice'>\The [display_name]'s flowers wither and fall off.</span>")*/

//Returns a key corresponding to an entry in the global seed list.
/datum/seed/proc/get_mutant_variant()
	if(!mutants || !mutants.len || immutable > 0) return 0
	return pick(mutants)

/obj/machinery/portable_atmospherics/hydroponics/proc/mutate_species()
	var/previous_plant = seed.display_name
	var/newseed = seed.get_mutant_variant()

	if(!plant_controller.seeds.Find(newseed))
		return

	seed = plant_controller.seeds[newseed]

	dead = 0
	age = 1
	health = seed.endurance
	lastcycle = world.time
	harvest = 0
	weedlevel = 0 //Why is this here?
	sampled = 0

	update_icon()
	visible_message("<span class='alert'>The</span> <span class='info'>[previous_plant]</span> <span class='alert'>has suddenly mutated into</span> <span class='info'>[seed.display_name]!</span>")

#undef MUTCAT_GOOD
#undef MUTCAT_BAD
#undef MUTCAT_BAD2
#undef MUTCAT_DANGEROUS
#undef MUTCAT_WEIRD
#undef MUTCAT_WEIRD2
