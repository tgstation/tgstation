var/global/list/seed_types = list()       // A list of all seed data.
var/global/list/gene_tag_masks = list()   // Gene obfuscation for delicious trial and error goodness.

// Predefined/roundstart varieties use a string key to make it
// easier to grab the new variety when mutating. Post-roundstart
// and mutant varieties use their uid converted to a string instead.
// Looks like shit but it's sort of necessary.

proc/populate_seed_list()

	// Populate the global seed datum list.
	for(var/type in typesof(/datum/seed)-/datum/seed)
		var/datum/seed/S = new type
		seed_types[S.name] = S
		S.uid = "[seed_types.len]"
		S.roundstart = 1

	// Make sure any seed packets that were mapped in are updated
	// correctly (since the seed datums did not exist a tick ago).
	for(var/obj/item/seeds/S in world)
		S.update_seed()

	//Might as well mask the gene types while we're at it.
	var/list/gene_tags = list("products","consumption","environment","resistance","vigour","flowers")
	var/list/used_masks = list()

	while(gene_tags && gene_tags.len)
		var/gene_tag = pick(gene_tags)
		var/gene_mask = "[num2hex(rand(0,255))]"

		while(gene_mask in used_masks)
			gene_mask = "[num2hex(rand(0,255))]"

		used_masks += gene_mask
		gene_tags -= gene_tag
		gene_tag_masks[gene_tag] = gene_mask

/datum/plantgene
	var/genetype    // Label used when applying trait.
	var/list/values // Values to copy into the target seed datum.

/datum/seed

	//Tracking.
	var/uid                        // Unique identifier.
	var/name                       // Index for global list.
	var/seed_name                  // Plant name for seed packet.
	var/seed_noun = "seeds"        // Descriptor for packet.
	var/display_name               // Prettier name.
	var/roundstart                 // If set, seed will not display variety number.

	// Output.
	var/list/products              // Possible fruit/other product paths.
	var/list/mutants               // Possible predefined mutant varieties, if any.
	var/list/chems                 // Chemicals that plant produces in products/injects into victim.
	var/list/consume_gasses        // The plant will absorb these gasses during its life.
	var/list/exude_gasses          // The plant will exude these gasses during its life.

	//Tolerances.
	var/requires_nutrients = 1      // The plant can starve.
	var/nutrient_consumption = 0.25 // Plant eats this much per tick.
	var/requires_water = 1          // The plant can become dehydrated.
	var/water_consumption = 3       // Plant drinks this much per tick.
	var/ideal_heat = 293            // Preferred temperature in Kelvin.
	var/heat_tolerance = 20         // Departure from ideal that is survivable.
	var/ideal_light = 8             // Preferred light level in luminosity.
	var/light_tolerance = 5         // Departure from ideal that is survivable.
	var/toxins_tolerance = 5        // Resistance to poison.
	var/lowkpa_tolerance = 25       // Low pressure capacity.
	var/highkpa_tolerance = 200     // High pressure capacity.
	var/pest_tolerance = 5          // Threshold for pests to impact health.
	var/weed_tolerance = 5          // Threshold for weeds to impact health.

	//General traits.
	var/endurance = 100             // Maximum plant HP when growing.
	var/yield = 0                   // Amount of product.
	var/lifespan = 0                // Time before the plant dies.
	var/maturation = 0              // Time taken before the plant is mature.
	var/production = 0              // Time before harvesting can be undertaken again.
	var/growth_stages = 6           // Number of stages the plant passes through before it is mature.
	var/harvest_repeat = 0          // If 1, this plant will fruit repeatedly..
	var/potency = 1                 // General purpose plant strength value.
	var/spread = 0                  // 0 limits plant to tray, 1 = creepers, 2 = vines.
	var/carnivorous = 0             // 0 = none, 1 = eat pests in tray, 2 = eat living things  (when a vine).
	var/parasite = 0                // 0 = no, 1 = gain health from weed level.
	var/immutable = 0                // If set, plant will never mutate. If -1, plant is  highly mutable.
	var/alter_temp                  // If set, the plant will periodically alter local temp by this amount.

	// Cosmetics.
	var/plant_icon                  // Icon to use for the plant growing in the tray.
	var/product_icon                // Base to use for fruit coming from this plant (if a vine).
	var/product_colour              // Colour to apply to product base (if a vine).
	var/packet_icon = "seed"        // Icon to use for physical seed packet item.
	var/biolum                      // Plant is bioluminescent.
	var/biolum_colour               // The colour of the plant's radiance.
	var/flowers                     // Plant has a flower overlay.
	var/flower_icon = "vine_fruit"  // Which overlay to use.
	var/flower_colour               // Which colour to use.

//Creates a random seed. MAKE SURE THE LINE HAS DIVERGED BEFORE THIS IS CALLED.
/datum/seed/proc/randomize()

	roundstart = 0
	seed_name = "strange plant"     // TODO: name generator.
	display_name = "strange plants" // TODO: name generator.

	seed_noun = pick("spores","nodes","cuttings","seeds")
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/generic_fruit)
	potency = rand(5,30)

	//TODO: Finish generalizing the product icons so this can be randomized.
	packet_icon = "seed-berry"
	plant_icon = "berry"
	if(prob(20))
		harvest_repeat = 1

	if(prob(5))
		consume_gasses = list()
		var/gas = pick("oxygen","nitrogen","plasma","carbon_dioxide")
		consume_gasses[gas] = rand(3,9)

	if(prob(5))
		exude_gasses = list()
		var/gas = pick("oxygen","nitrogen","plasma","carbon_dioxide")
		exude_gasses[gas] = rand(3,9)

	chems = list()
	if(prob(80))
		chems["nutriment"] = list(rand(1,10),rand(10,20))

	var/additional_chems = rand(0,5)

	var/list/possible_chems = list(
		"bicaridine",
		"hyperzine",
		"cryoxadone",
		"blood",
		"water",
		"potassium",
		"plasticide",
		"slimetoxin",
		"aslimetoxin",
		"inaprovaline",
		"space_drugs",
		"paroxetine",
		"mercury",
		"sugar",
		"radium",
		"ryetalyn",
		"alkysine",
		"thermite",
		"tramadol",
		"cryptobiolin",
		"dermaline",
		"dexalin",
		"plasma",
		"synaptizine",
		"impedrezene",
		"hyronalin",
		"peridaxon",
		"toxin",
		"rezadone",
		"ethylredoxrazine",
		"slimejelly",
		"cyanide",
		"mindbreaker",
		"stoxin"
		)

	for(var/x=1;x<=additional_chems;x++)
		if(!possible_chems.len)
			break
		var/new_chem = pick(possible_chems)
		possible_chems -= new_chem
		chems[new_chem] = list(rand(1,10),rand(10,20))

	if(prob(90))
		requires_nutrients = 1
		nutrient_consumption = rand(100)*0.1
	else
		requires_nutrients = 0

	if(prob(90))
		requires_water = 1
		water_consumption = rand(10)
	else
		requires_water = 0

	ideal_heat =       rand(100,400)
	heat_tolerance =   rand(10,30)
	ideal_light =      rand(2,10)
	light_tolerance =  rand(2,7)
	toxins_tolerance = rand(2,7)
	pest_tolerance =   rand(2,7)
	weed_tolerance =   rand(2,7)
	lowkpa_tolerance = rand(10,50)
	highkpa_tolerance = rand(100,300)

	if(prob(5))
		alter_temp = rand(-5,5)

	if(prob(1))
		immutable = -1

	var/carnivore_prob = rand(100)
	if(carnivore_prob < 5)
		carnivorous = 2
	else if(carnivore_prob < 10)
		carnivorous = 1

	if(prob(10))
		parasite = 1

	var/vine_prob = rand(100)
	if(vine_prob < 5)
		spread = 2
	else if(vine_prob < 10)
		spread = 1

	if(prob(5))
		biolum = 1
		biolum_colour = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"

	endurance = rand(60,100)
	yield = rand(3,15)
	maturation = rand(5,15)
	production = maturation + rand(2,5)
	lifespan = production + rand(5,10)

//Returns a key corresponding to an entry in the global seed list.
/datum/seed/proc/get_mutant_variant()
	if(!mutants || !mutants.len || immutable > 0) return 0
	return pick(mutants)

//Mutates the plant overall (randomly).
/datum/seed/proc/mutate(var/degree,var/turf/source_turf)

	if(!degree || immutable > 0) return

	source_turf.visible_message("\blue \The [display_name] quivers!")

	//This looks like shit, but it's a lot easier to read/change this way.
	var/total_mutations = rand(1,1+degree)
	for(var/i = 0;i<total_mutations;i++)
		switch(rand(0,11))
			if(0) //Plant cancer!
				lifespan = max(0,lifespan-rand(1,5))
				endurance = max(0,endurance-rand(10,20))
				source_turf.visible_message("\red \The [display_name] withers rapidly!")
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
				toxins_tolerance =          max(0,  min(10,  weed_tolerance       + (rand(-2,2)   * degree)))
			if(5)
				weed_tolerance  =           max(0,  min(10,  weed_tolerance       + (rand(-2,2)   * degree)))
				if(prob(degree*5))
					carnivorous =           max(0,  min(2,   carnivorous          + rand(-degree,degree)))
					if(carnivorous)
						source_turf.visible_message("\blue \The [display_name] shudders hungrily.")
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
					source_turf.visible_message("\blue \The [display_name] spasms visibly, shifting in the tray.")
			if(9)
				maturation =                max(0,  min(30,  maturation      + (rand(-1,1)   * degree)))
				if(prob(degree*5))
					harvest_repeat = !harvest_repeat
			if(10)
				if(prob(degree*2))
					biolum = !biolum
					if(biolum)
						source_turf.visible_message("\blue \The [display_name] begins to glow!")
						if(prob(degree*2))
							biolum_colour = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
							source_turf.visible_message("\blue \The [display_name]'s glow <font=[biolum_colour]>changes colour</font>!")
					else
						source_turf.visible_message("\blue \The [display_name]'s glow dims...")
			if(11)
				if(prob(degree*2))
					flowers = !flowers
					if(flowers)
						source_turf.visible_message("\blue \The [display_name] sprouts a bevy of flowers!")
						if(prob(degree*2))
							flower_colour = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
						source_turf.visible_message("\blue \The [display_name]'s flowers <font=[flower_colour]>changes colour</font>!")
					else
						source_turf.visible_message("\blue \The [display_name]'s flowers wither and fall off.")
	return

//Mutates a specific trait/set of traits.
/datum/seed/proc/apply_gene(var/datum/plantgene/gene)

	if(!gene || !gene.values || immutable > 0) return

	switch(gene.genetype)

		//Splicing products has some detrimental effects on yield and lifespan.
		if("products")

			if(gene.values.len < 6) return

			if(yield > 0)     yield =     max(1,round(yield*0.85))
			if(endurance > 0) endurance = max(1,round(endurance*0.85))
			if(lifespan > 0)  lifespan =  max(1,round(lifespan*0.85))

			if(!products) products = list()
			products |= gene.values[1]

			if(!chems) chems = list()

			var/list/gene_value = gene.values[2]
			for(var/rid in gene_value)

				var/list/gene_chem = gene_value[rid]

				if(chems[rid])

					var/list/chem_value = chems[rid]

					chems[rid][1] = max(1,round((gene_chem[1] + chem_value[1])/2))

					if(gene_chem.len > 1)
						if(chem_value > 1)
							chems[rid][2] = max(1,round((gene_chem[2] + chem_value[2])/2))
						else
							chems[rid][2] = gene_chem[2]

				else
					var/list/new_chem = gene_chem[rid]
					chems[rid] = new_chem.Copy()

			var/list/new_gasses = gene.values[3]
			if(istype(new_gasses))
				if(!exude_gasses) exude_gasses = list()
				exude_gasses |= new_gasses
				for(var/gas in exude_gasses)
					exude_gasses[gas] = max(1,round(exude_gasses[gas]*0.8))

			alter_temp =           gene.values[4]
			potency =              gene.values[5]
			harvest_repeat =       gene.values[6]

		if("consumption")

			if(gene.values.len < 7) return

			consume_gasses =       gene.values[1]
			requires_nutrients =   gene.values[2]
			nutrient_consumption = gene.values[3]
			requires_water =       gene.values[4]
			water_consumption =    gene.values[5]
			carnivorous =          gene.values[6]
			parasite =             gene.values[7]

		if("environment")

			if(gene.values.len < 6) return

			ideal_heat =           gene.values[1]
			heat_tolerance =       gene.values[2]
			ideal_light =          gene.values[3]
			light_tolerance =      gene.values[4]
			lowkpa_tolerance  =    gene.values[5]
			highkpa_tolerance =    gene.values[6]

		if("resistance")

			if(gene.values.len < 3) return

			toxins_tolerance =     gene.values[1]
			pest_tolerance =       gene.values[2]
			weed_tolerance =       gene.values[3]

		if("vigour")

			if(gene.values.len < 6) return

			endurance =            gene.values[1]
			yield =                gene.values[2]
			lifespan =             gene.values[3]
			spread =               gene.values[4]
			maturation =           gene.values[5]
			production =           gene.values[6]

		if("flowers")

			if(gene.values.len < 7) return

			product_icon =         gene.values[1]
			product_colour =       gene.values[2]
			biolum =               gene.values[3]
			biolum_colour =        gene.values[4]
			flowers =              gene.values[5]
			flower_icon =          gene.values[6]
			flower_colour =        gene.values[7]

//Returns a list of the desired trait values.
/datum/seed/proc/get_gene(var/genetype)

	if(!genetype) return 0

	var/datum/plantgene/P = new()
	P.genetype = genetype

	switch(genetype)
		if("products")
			P.values = list(
				(products             ? products             : 0),
				(chems                ? chems                : 0),
				(exude_gasses         ? exude_gasses         : 0),
				(alter_temp           ? alter_temp           : 0),
				(potency              ? potency              : 0),
				(harvest_repeat       ? harvest_repeat       : 0)
				)

		if("consumption")
			P.values = list(
				(consume_gasses       ? consume_gasses       : 0),
				(requires_nutrients   ? requires_nutrients   : 0),
				(nutrient_consumption ? nutrient_consumption : 0),
				(requires_water       ? requires_water       : 0),
				(water_consumption    ? water_consumption    : 0),
				(carnivorous          ? carnivorous          : 0),
				(parasite             ? parasite             : 0)
				)

		if("environment")
			P.values = list(
				(ideal_heat           ? ideal_heat           : 0),
				(heat_tolerance       ? heat_tolerance       : 0),
				(ideal_light          ? ideal_light          : 0),
				(light_tolerance      ? light_tolerance      : 0),
				(lowkpa_tolerance     ? lowkpa_tolerance     : 0),
				(highkpa_tolerance    ? highkpa_tolerance    : 0)
				)

		if("resistance")
			P.values = list(
				(toxins_tolerance     ? toxins_tolerance     : 0),
				(pest_tolerance       ? pest_tolerance       : 0),
				(weed_tolerance       ? weed_tolerance       : 0)
				)

		if("vigour")
			P.values = list(
				(endurance            ? endurance            : 0),
				(yield                ? yield                : 0),
				(lifespan             ? lifespan             : 0),
				(spread               ? spread               : 0),
				(maturation           ? maturation           : 0),
				(production           ? production           : 0)
				)

		if("flowers")
			P.values = list(
				(product_icon         ? product_icon         : 0),
				(product_colour       ? product_colour       : 0),
				(biolum               ? biolum               : 0),
				(biolum_colour        ? biolum_colour        : 0),
				(flowers              ? flowers              : 0),
				(flower_icon          ? flower_icon          : 0),
				(flower_colour        ? flower_colour        : 0)
				)

	return (P ? P : 0)

//Place the plant products at the feet of the user.
/datum/seed/proc/harvest(var/mob/user,var/yield_mod,var/harvest_sample)
	if(!user)
		return

	var/got_product
	if(!isnull(products) && products.len && yield > 0)
		got_product = 1

	if(!got_product && !harvest_sample)
		user << "\red You fail to harvest anything useful."
	else
		user << "You [harvest_sample ? "take a sample" : "harvest"] from the [display_name]."

		//This may be a new line. Update the global if it is.
		if(name == "new line" || !(name in seed_types))
			uid = seed_types.len + 1
			name = "[uid]"
			seed_types[name] = src

		if(harvest_sample)
			var/obj/item/seeds/seeds = new(get_turf(user))
			seeds.seed_type = name
			seeds.update_seed()
			return

		var/total_yield = 0
		if(yield > -1)
			if(isnull(yield_mod) || yield_mod < 1)
				yield_mod = 0
				total_yield = yield
			else
				total_yield = yield + rand(yield_mod)
			total_yield = max(1,total_yield)

		currently_querying = list()
		for(var/i = 0;i<total_yield;i++)
			var/product_type = pick(products)
			var/obj/item/product = new product_type(get_turf(user))

			//Handle spawning in living, mobile products (like dionaea).
			if(istype(product,/mob/living))

				product.visible_message("\blue The pod disgorges [product]!")
				handle_living_product(product)

			// Make sure the product is inheriting the correct seed type reference.
			else if(istype(product,/obj/item/weapon/reagent_containers/food/snacks/grown))
				var/obj/item/weapon/reagent_containers/food/snacks/grown/current_product = product
				current_product.plantname = name
			else if(istype(product,/obj/item/weapon/grown))
				var/obj/item/weapon/grown/current_product = product
				current_product.plantname = name


// When the seed in this machine mutates/is modified, the tray seed value
// is set to a new datum copied from the original. This datum won't actually
// be put into the global datum list until the product is harvested, though.
/datum/seed/proc/diverge(var/modified)

	if(immutable > 0) return

	//Set up some basic information.
	var/datum/seed/new_seed = new
	new_seed.name = "new line"
	new_seed.uid = 0
	new_seed.roundstart = 0

	//Copy over everything else.
	if(products)       new_seed.products = products.Copy()
	if(mutants)        new_seed.mutants = mutants.Copy()
	if(chems)          new_seed.chems = chems.Copy()
	if(consume_gasses) new_seed.consume_gasses = consume_gasses.Copy()
	if(exude_gasses)   new_seed.exude_gasses = exude_gasses.Copy()

	new_seed.seed_name =            "[(roundstart ? "[(modified ? "modified" : "mutant")] " : "")][seed_name]"
	new_seed.display_name =         "[(roundstart ? "[(modified ? "modified" : "mutant")] " : "")][display_name]"
	new_seed.seed_noun =            seed_noun

	new_seed.requires_nutrients =   requires_nutrients
	new_seed.nutrient_consumption = nutrient_consumption
	new_seed.requires_water =       requires_water
	new_seed.water_consumption =    water_consumption
	new_seed.ideal_heat =           ideal_heat
	new_seed.heat_tolerance =       heat_tolerance
	new_seed.ideal_light =          ideal_light
	new_seed.light_tolerance =      light_tolerance
	new_seed.toxins_tolerance =     toxins_tolerance
	new_seed.lowkpa_tolerance =     lowkpa_tolerance
	new_seed.highkpa_tolerance =    highkpa_tolerance
	new_seed.pest_tolerance =       pest_tolerance
	new_seed.weed_tolerance =       weed_tolerance
	new_seed.endurance =            endurance
	new_seed.yield =                yield
	new_seed.lifespan =             lifespan
	new_seed.maturation =           maturation
	new_seed.production =           production
	new_seed.growth_stages =        growth_stages
	new_seed.harvest_repeat =       harvest_repeat
	new_seed.potency =              potency
	new_seed.spread =               spread
	new_seed.carnivorous =          carnivorous
	new_seed.parasite =             parasite
	new_seed.plant_icon =           plant_icon
	new_seed.product_icon =         product_icon
	new_seed.product_colour =       product_colour
	new_seed.packet_icon =          packet_icon
	new_seed.biolum =               biolum
	new_seed.biolum_colour =        biolum_colour
	new_seed.flowers =              flowers
	new_seed.flower_icon =          flower_icon
	new_seed.alter_temp = 			alter_temp

	return new_seed

// Actual roundstart seed types after this point.
// Chili plants/variants.
/datum/seed/chili

	name = "chili"
	seed_name = "chili"
	display_name = "chili plants"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/chili)
	chems = list("capsaicin" = list(3,5), "nutriment" = list(1,25))
	mutants = list("icechili")
	packet_icon = "seed-chili"
	plant_icon = "chili"
	harvest_repeat = 1

	lifespan = 20
	maturation = 5
	production = 5
	yield = 4
	potency = 20

/datum/seed/chili/ice
	name = "icechili"
	seed_name = "ice pepper"
	display_name = "ice-pepper plants"
	mutants = null
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper)
	chems = list("frostoil" = list(3,5), "nutriment" = list(1,50))
	packet_icon = "seed-icepepper"
	plant_icon = "chiliice"

	maturation = 4
	production = 4

// Berry plants/variants.
/datum/seed/berry
	name = "berries"
	seed_name = "berry"
	display_name = "berry bush"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/berries)
	mutants = list("glowberries","poisonberries")
	packet_icon = "seed-berry"
	plant_icon = "berry"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,10))

	lifespan = 20
	maturation = 5
	production = 5
	yield = 2
	potency = 10

/datum/seed/berry/glow
	name = "glowberries"
	seed_name = "glowberry"
	display_name = "glowberry bush"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries)
	mutants = null
	packet_icon = "seed-glowberry"
	plant_icon = "glowberry"
	chems = list("nutriment" = list(1,10), "uranium" = list(3,5))

	lifespan = 30
	maturation = 5
	production = 5
	yield = 2
	potency = 10

/datum/seed/berry/poison
	name = "poisonberries"
	seed_name = "poison berry"
	display_name = "poison berry bush"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries)
	mutants = list("deathberries")
	packet_icon = "seed-poisonberry"
	plant_icon = "poisonberry"
	chems = list("nutriment" = list(1), "toxin" = list(3,5))

/datum/seed/berry/poison/death
	name = "deathberries"
	seed_name = "death berry"
	display_name = "death berry bush"
	mutants = null
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/deathberries)
	packet_icon = "seed-deathberry"
	plant_icon = "deathberry"
	chems = list("nutriment" = list(1), "toxin" = list(3,3), "lexorin" = list(1,5))

	yield = 3
	potency = 50

// Nettles/variants.
/datum/seed/nettle
	name = "nettle"
	seed_name = "nettle"
	display_name = "nettles"
	products = list(/obj/item/weapon/grown/nettle)
	mutants = list("deathnettle")
	packet_icon = "seed-nettle"
	plant_icon = "nettle"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,50), "sacid" = list(0,1))
	lifespan = 30
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	growth_stages = 5

/datum/seed/nettle/death
	name = "deathnettle"
	seed_name = "death nettle"
	display_name = "death nettles"
	products = list(/obj/item/weapon/grown/deathnettle)
	mutants = null
	packet_icon = "seed-deathnettle"
	plant_icon = "deathnettle"
	chems = list("nutriment" = list(1,50), "pacid" = list(0,1))

	maturation = 8
	yield = 2

//Tomatoes/variants.
/datum/seed/tomato
	name = "tomato"
	seed_name = "tomato"
	display_name = "tomato plant"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tomato)
	mutants = list("bluetomato","bloodtomato")
	packet_icon = "seed-tomato"
	plant_icon = "tomato"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,10))

	lifespan = 25
	maturation = 8
	production = 6
	yield = 2
	potency = 10

/datum/seed/tomato/blood
	name = "bloodtomato"
	seed_name = "blood tomato"
	display_name = "blood tomato plant"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato)
	mutants = list("killer")
	packet_icon = "seed-bloodtomato"
	plant_icon = "bloodtomato"
	chems = list("nutriment" = list(1,10), "blood" = list(1,5))

	yield = 3

/datum/seed/tomato/killer
	name = "killertomato"
	seed_name = "killer tomato"
	display_name = "killer tomato plant"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato)
	mutants = null
	packet_icon = "seed-killertomato"
	plant_icon = "killertomato"

	yield = 2
	growth_stages = 2

/datum/seed/tomato/blue
	name = "bluetomato"
	seed_name = "blue tomato"
	display_name = "blue tomato plant"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato)
	mutants = list("bluespacetomato")
	packet_icon = "seed-bluetomato"
	plant_icon = "bluetomato"
	chems = list("nutriment" = list(1,20), "lube" = list(1,5))

/datum/seed/tomato/blue/teleport
	name = "bluespacetomato"
	seed_name = "bluespace tomato"
	display_name = "bluespace tomato plant"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato)
	mutants = null
	packet_icon = "seed-bluespacetomato"
	plant_icon = "bluespacetomato"
	chems = list("nutriment" = list(1,20), "singulo" = list(1,5))

//Eggplants/varieties.
/datum/seed/eggplant
	name = "eggplant"
	seed_name = "eggplant"
	display_name = "eggplants"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant)
	mutants = list("realeggplant")
	packet_icon = "seed-eggplant"
	plant_icon = "eggplant"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,10))

	lifespan = 25
	maturation = 6
	production = 6
	yield = 2
	potency = 20

/datum/seed/eggplant/eggs
	name = "realeggplant"
	seed_name = "egg-plant"
	display_name = "egg-plants"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	mutants = null
	packet_icon = "seed-eggy"
	plant_icon = "eggy"

	lifespan = 75
	production = 12

//Apples/varieties.

/datum/seed/apple
	name = "apple"
	seed_name = "apple"
	display_name = "apple tree"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/apple)
	mutants = list("poisonapple","goldapple")
	packet_icon = "seed-apple"
	plant_icon = "apple"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,10))

	lifespan = 55
	maturation = 6
	production = 6
	yield = 5
	potency = 10

/datum/seed/apple/poison
	name = "poisonapple"
	mutants = null
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned)
	chems = list("cyanide" = list(1,5))

/datum/seed/apple/gold
	name = "goldapple"
	seed_name = "golden apple"
	display_name = "gold apple tree"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple)
	mutants = null
	packet_icon = "seed-goldapple"
	plant_icon = "goldapple"
	chems = list("nutriment" = list(1,10), "gold" = list(1,5))

	maturation = 10
	production = 10
	yield = 3

//Ambrosia/varieties.
/datum/seed/ambrosia
	name = "ambrosia"
	seed_name = "ambrosia vulgaris"
	display_name = "ambrosia vulgaris"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris)
	mutants = list("ambrosiadeus")
	packet_icon = "seed-ambrosiavulgaris"
	plant_icon = "ambrosiavulgaris"
	harvest_repeat = 1
	chems = list("nutriment" = list(1), "space_drugs" = list(1,8), "kelotane" = list(1,8,1), "bicaridine" = list(1,10,1), "toxin" = list(1,10))

	lifespan = 60
	maturation = 6
	production = 6
	yield = 6
	potency = 5

/datum/seed/ambrosia/cruciatus
	name = "ambrosiacruciatus"
	seed_name = "ambrosia vulgaris"
	packet_icon = "seed-ambrosiavulgaris"
	plant_icon = "ambrosiavulgaris"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/cruciatus)
	mutants = null
	lifespan = 60
	endurance = 25
	maturation = 6
	production = 6
	yield = 6
	potency = 5

/datum/seed/ambrosia/deus
	name = "ambrosiadeus"
	seed_name = "ambrosia deus"
	display_name = "ambrosia deus"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus)
	mutants = null
	packet_icon = "seed-ambrosiadeus"
	plant_icon = "ambrosiadeus"
	chems = list("nutriment" = list(1), "bicaridine" = list(1,8), "synaptizine" = list(1,8,1), "hyperzine" = list(1,10,1), "space_drugs" = list(1,10))

//Mushrooms/varieties.
/datum/seed/mushroom
	name = "mushrooms"
	seed_name = "chanterelle"
	seed_noun = "spores"
	display_name = "chanterelle mushrooms"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle)
	mutants = list("reishi","amanita","plumphelmet")
	packet_icon = "mycelium-chanter"
	plant_icon = "chanter"
	chems = list("nutriment" = list(1,25))

	lifespan = 35
	maturation = 7
	production = 1
	yield = 5
	potency = 1
	growth_stages = 3

/datum/seed/mushroom/mold
	name = "mold"
	seed_name = "brown mold"
	display_name = "brown mold"
	products = null
	mutants = null
	//mutants = list("wallrot") //TBD.
	plant_icon = "mold"

	lifespan = 50
	maturation = 10
	yield = -1

/datum/seed/mushroom/plump
	name = "plumphelmet"
	seed_name = "plump helmet"
	display_name = "plump helmet mushrooms"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet)
	mutants = list("walkingmushroom","towercap")
	packet_icon = "mycelium-plump"
	plant_icon = "plump"
	chems = list("nutriment" = list(2,10))

	lifespan = 25
	maturation = 8
	yield = 4
	potency = 0

/datum/seed/mushroom/hallucinogenic
	name = "reishi"
	seed_name = "reishi"
	display_name = "reishi"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi)
	mutants = list("libertycap","glowshroom")
	packet_icon = "mycelium-reishi"
	plant_icon = "reishi"
	chems = list("nutriment" = list(1,50), "psilocybin" = list(3,5))

	maturation = 10
	production = 5
	yield = 4
	potency = 15
	growth_stages = 4

/datum/seed/mushroom/hallucinogenic/strong
	name = "libertycap"
	seed_name = "liberty cap"
	display_name = "liberty cap mushrooms"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap)
	mutants = null
	packet_icon = "mycelium-liberty"
	plant_icon = "liberty"
	chems = list("nutriment" = list(1), "stoxin" = list(3,3), "space_drugs" = list(1,25))

	lifespan = 25
	production = 1
	potency = 15
	growth_stages = 3

/datum/seed/mushroom/poison
	name = "amanita"
	seed_name = "fly amanita"
	display_name = "fly amanita mushrooms"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita)
	mutants = list("destroyingangel","plastic")
	packet_icon = "mycelium-amanita"
	plant_icon = "amanita"
	chems = list("nutriment" = list(1), "amatoxin" = list(3,3), "psilocybin" = list(1,25))

	lifespan = 50
	maturation = 10
	production = 5
	yield = 4
	potency = 10

/datum/seed/mushroom/poison/death
	name = "destroyingangel"
	seed_name = "destroying angel"
	display_name = "destroying angel mushrooms"
	mutants = null
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel)
	packet_icon = "mycelium-angel"
	plant_icon = "angel"
	chems = list("nutriment" = list(1,50), "amatoxin" = list(13,3), "psilocybin" = list(1,25))

	maturation = 12
	yield = 2
	potency = 35

/datum/seed/mushroom/towercap
	name = "towercap"
	seed_name = "tower cap"
	display_name = "tower caps"
	mutants = null
	products = list(/obj/item/weapon/grown/log)
	packet_icon = "mycelium-tower"
	plant_icon = "towercap"

	lifespan = 80
	maturation = 15

/datum/seed/mushroom/glowshroom
	name = "glowshroom"
	seed_name = "glowshroom"
	display_name = "glowshrooms"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom)
	mutants = null
	packet_icon = "mycelium-glowshroom"
	plant_icon = "glowshroom"
	chems = list("radium" = list(1,20))

	lifespan = 120
	maturation = 15
	yield = 3
	potency = 30
	growth_stages = 4
	biolum = 1
	biolum_colour = "#006622"

/datum/seed/mushroom/walking
	name = "walkingmushroom"
	seed_name = "walking mushroom"
	display_name = "walking mushrooms"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom)
	mutants = null
	packet_icon = "mycelium-walkingmushroom"
	plant_icon = "walkingmushroom"
	chems = list("nutriment" = list(2,10))

	lifespan = 30
	maturation = 5
	yield = 1
	potency = 0
	growth_stages = 3

/datum/seed/mushroom/plastic
	name = "plastic"
	seed_name = "plastellium"
	display_name = "plastellium"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/plastellium)
	mutants = null
	packet_icon = "mycelium-plast"
	plant_icon = "plastellium"
	chems = list("plasticide" = list(1,10))

	lifespan = 15
	maturation = 5
	production = 6
	yield = 6
	potency = 20

//Flowers/varieties
/datum/seed/flower
	name = "harebells"
	seed_name = "harebell"
	display_name = "harebells"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/harebell)
	packet_icon = "seed-harebell"
	plant_icon = "harebell"
	chems = list("nutriment" = list(1,20))

	lifespan = 100
	maturation = 7
	production = 1
	yield = 2
	growth_stages = 4

/datum/seed/flower/poppy
	name = "poppies"
	seed_name = "poppy"
	display_name = "poppies"
	packet_icon = "seed-poppy"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/poppy)
	plant_icon = "poppy"
	chems = list("nutriment" = list(1,20), "bicaridine" = list(1,10))

	lifespan = 25
	potency = 20
	maturation = 8
	production = 6
	yield = 6
	growth_stages = 3
	plant_icon = ""

/datum/seed/flower/sunflower
	name = "sunflowers"
	seed_name = "sunflower"
	display_name = "sunflowers"
	packet_icon = "seed-sunflower"
	products = list(/obj/item/weapon/grown/sunflower)
	plant_icon = "sunflower"

	lifespan = 25
	maturation = 6
	growth_stages = 3

//Grapes/varieties
/datum/seed/grapes
	name = "grapes"
	seed_name = "grape"
	display_name = "grapevines"
	packet_icon = "seed-grapes"
	mutants = list("greengrapes")
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/grapes)
	plant_icon = "grape"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,10), "sugar" = list(1,5))

	lifespan = 50
	maturation = 3
	production = 5
	yield = 4
	potency = 10

/datum/seed/grapes/green
	name = "greengrapes"
	seed_name = "green grape"
	display_name = "green grapevines"
	packet_icon = "seed-greengrapes"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes)
	mutants = null
	plant_icon = "greengrape"
	chems = list("nutriment" = list(1,10), "kelotane" = list(3,5))

//Everything else
/datum/seed/peanuts
	name = "peanut"
	seed_name = "peanut"
	display_name = "peanut vines"
	packet_icon = "seed-peanut"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/peanut)
	plant_icon = "peanut"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,10))

	lifespan = 55
	maturation = 6
	production = 6
	yield = 6
	potency = 10

/datum/seed/cabbage
	name = "cabbage"
	seed_name = "cabbage"
	display_name = "cabbages"
	packet_icon = "seed-cabbage"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage)
	plant_icon = "cabbage"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,10))

	lifespan = 50
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	growth_stages = 1

/datum/seed/shand
	name = "shand"
	seed_name = "S'randar's hand"
	display_name = "S'randar's hand leaves"
	packet_icon = "seed-shand"
	products = list(/obj/item/stack/medical/bruise_pack/tajaran)
	plant_icon = "shand"
	chems = list("bicaridine" = list(0,10))

	lifespan = 50
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	growth_stages = 3

/datum/seed/mtear
	name = "mtear"
	seed_name = "Messa's tear"
	display_name = "Messa's tear leaves"
	packet_icon = "seed-mtear"
	products = list(/obj/item/stack/medical/ointment/tajaran)
	plant_icon = "mtear"
	chems = list("honey" = list(1,10), "kelotane" = list(3,5))

	lifespan = 50
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	growth_stages = 3

/datum/seed/banana
	name = "banana"
	seed_name = "banana"
	display_name = "banana tree"
	packet_icon = "seed-banana"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	plant_icon = "banana"
	harvest_repeat = 1
	chems = list("banana" = list(1,10))

	lifespan = 50
	maturation = 6
	production = 6
	yield = 3

/datum/seed/corn
	name = "corn"
	seed_name = "corn"
	display_name = "ears of corn"
	packet_icon = "seed-corn"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/corn)
	plant_icon = "corn"
	chems = list("nutriment" = list(1,10))

	lifespan = 25
	maturation = 8
	production = 6
	yield = 3
	potency = 20
	growth_stages = 3

/datum/seed/potato
	name = "potato"
	seed_name = "potato"
	display_name = "potatoes"
	packet_icon = "seed-potato"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	plant_icon = "potato"
	chems = list("nutriment" = list(1,10))

	lifespan = 30
	maturation = 10
	production = 1
	yield = 4
	potency = 10
	growth_stages = 4

/datum/seed/soybean
	name = "soybean"
	seed_name = "soybean"
	display_name = "soybeans"
	packet_icon = "seed-soybean"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans)
	plant_icon = "soybean"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,20))

	lifespan = 25
	maturation = 4
	production = 4
	yield = 3
	potency = 5

/datum/seed/wheat
	name = "wheat"
	seed_name = "wheat"
	display_name = "wheat stalks"
	packet_icon = "seed-wheat"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/wheat)
	plant_icon = "wheat"
	chems = list("nutriment" = list(1,25))

	lifespan = 25
	maturation = 6
	production = 1
	yield = 4
	potency = 5

/datum/seed/rice
	name = "rice"
	seed_name = "rice"
	display_name = "rice stalks"
	packet_icon = "seed-rice"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk)
	plant_icon = "rice"
	chems = list("nutriment" = list(1,25))

	lifespan = 25
	maturation = 6
	production = 1
	yield = 4
	potency = 5
	growth_stages = 4

/datum/seed/carrots
	name = "carrot"
	seed_name = "carrot"
	display_name = "carrots"
	packet_icon = "seed-carrot"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/carrot)
	plant_icon = "carrot"
	chems = list("nutriment" = list(1,20), "imidazoline" = list(3,5))

	lifespan = 25
	maturation = 10
	production = 1
	yield = 5
	potency = 10
	growth_stages = 3

/datum/seed/weeds
	name = "weeds"
	seed_name = "weed"
	display_name = "weeds"
	packet_icon = "seed-ambrosiavulgaris"
	plant_icon = "weeds"

	lifespan = 100
	maturation = 5
	production = 1
	yield = -1
	potency = -1
	growth_stages = 4
	immutable = -1

/datum/seed/whitebeets
	name = "whitebeet"
	seed_name = "white-beet"
	display_name = "white-beets"
	packet_icon = "seed-whitebeet"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet)
	plant_icon = "whitebeet"
	chems = list("nutriment" = list(0,20), "sugar" = list(1,5))

	lifespan = 60
	maturation = 6
	production = 6
	yield = 6
	potency = 10

/datum/seed/sugarcane
	name = "sugarcane"
	seed_name = "sugarcane"
	display_name = "sugarcanes"
	packet_icon = "seed-sugarcane"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane)
	plant_icon = "sugarcane"
	harvest_repeat = 1
	chems = list("sugar" = list(4,5))

	lifespan = 60
	maturation = 3
	production = 6
	yield = 4
	potency = 10
	growth_stages = 3

/datum/seed/watermelon
	name = "watermelon"
	seed_name = "watermelon"
	display_name = "watermelon vine"
	packet_icon = "seed-watermelon"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon)
	plant_icon = "watermelon"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,6))

	lifespan = 50
	maturation = 6
	production = 6
	yield = 3
	potency = 1

/datum/seed/pumpkin
	name = "pumpkin"
	seed_name = "pumpkin"
	display_name = "pumpkin vine"
	packet_icon = "seed-pumpkin"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin)
	plant_icon = "pumpkin"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,6))

	lifespan = 50
	maturation = 6
	production = 6
	yield = 3
	potency = 10
	growth_stages = 3

/datum/seed/lime
	name = "lime"
	seed_name = "lime"
	display_name = "lime trees"
	packet_icon = "seed-lime"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/lime)
	plant_icon = "lime"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,20))

	lifespan = 55
	maturation = 6
	production = 6
	yield = 4
	potency = 15

/datum/seed/lemon
	name = "lemon"
	seed_name = "lemon"
	display_name = "lemon trees"
	packet_icon = "seed-lemon"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/lemon)
	plant_icon = "lemon"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,20))

	lifespan = 55
	maturation = 6
	production = 6
	yield = 4
	potency = 10

/datum/seed/orange
	name = "orange"
	seed_name = "orange"
	display_name = "orange trees"
	packet_icon = "seed-orange"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/orange)
	plant_icon = "orange"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,20))

	lifespan = 60
	maturation = 6
	production = 6
	yield = 5
	potency = 1

/datum/seed/grass
	name = "grass"
	seed_name = "grass"
	display_name = "grass"
	packet_icon = "seed-grass"
	products = list(/obj/item/stack/tile/grass)
	plant_icon = "grass"
	harvest_repeat = 1

	lifespan = 60
	maturation = 2
	production = 5
	yield = 5
	growth_stages = 2

/datum/seed/cocoa
	name = "cocoa"
	seed_name = "cacao"
	display_name = "cacao tree"
	packet_icon = "seed-cocoapod"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod)
	plant_icon = "cocoapod"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,10), "coco" = list(4,5))

	lifespan = 20
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	growth_stages = 5

/datum/seed/cherries
	name = "cherry"
	seed_name = "cherry"
	seed_noun = "pits"
	display_name = "cherry tree"
	packet_icon = "seed-cherry"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cherries)
	plant_icon = "cherry"
	harvest_repeat = 1
	chems = list("nutriment" = list(1,15), "sugar" = list(1,15))

	lifespan = 35
	maturation = 5
	production = 5
	yield = 3
	potency = 10
	growth_stages = 5

/datum/seed/kudzu
	name = "kudzu"
	seed_name = "kudzu"
	display_name = "kudzu vines"
	packet_icon = "seed-kudzu"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod)
	plant_icon = "kudzu"
	product_colour = "#96D278"
	chems = list("nutriment" = list(1,50), "anti_toxin" = list(1,25))

	lifespan = 20
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	growth_stages = 4
	spread = 2

/datum/seed/diona
	name = "diona"
	seed_name = "diona"
	seed_noun = "nodes"
	display_name = "replicant pods"
	packet_icon = "seed-replicapod"
	products = list(/mob/living/carbon/monkey/diona)
	plant_icon = "replicapod"
	product_requires_player = 1
	immutable = 1

	lifespan = 50
	endurance = 8
	maturation = 5
	production = 10
	yield = 1
	potency = 30

/datum/seed/clown
	name = "clown"
	seed_name = "clown"
	seed_noun = "pods"
	display_name = "laughing clowns"
	packet_icon = "seed-replicapod"
	products = list(/mob/living/simple_animal/hostile/retaliate/clown)
	plant_icon = "replicapod"
	product_requires_player = 1

	lifespan = 100
	endurance = 8
	maturation = 1
	production = 1
	yield = 10
	potency = 30

/datum/seed/test
	name = "test"
	seed_name = "testing"
	seed_noun = "data"
	display_name = "runtimes"
	packet_icon = "seed-replicapod"
	products = list(/mob/living/simple_animal/cat/Runtime)
	plant_icon = "replicapod"

	requires_nutrients = 0
	nutrient_consumption = 0
	requires_water = 0
	water_consumption = 0
	pest_tolerance = 11
	weed_tolerance = 11
	lifespan = 1000
	endurance = 100
	maturation = 1
	production = 1
	yield = 1
	potency = 1