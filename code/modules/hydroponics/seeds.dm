// ********************************************************
// Here's all the seeds (plants) that can be used in hydro
// ********************************************************

/obj/item/seeds
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed"				// Unknown plant seed - these shouldn't exist in-game.
	worn_icon_state = "seed"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	/// Name of plant when planted.
	var/plantname = "Plants"
	/// A type path. The thing that is created when the plant is harvested.
	var/obj/item/product
	///Describes the product on the product path.
	var/productdesc
	/// Used to update icons. Should match the name in the sprites unless all icon_* are overridden.
	var/species = ""
	///the file that stores the sprites of the growing plant from this seed.
	var/growing_icon = 'icons/obj/hydroponics/growing.dmi'
	/// Used to override grow icon (default is "[species]-grow"). You can use one grow icon for multiple closely related plants with it.
	var/icon_grow
	/// Used to override dead icon (default is "[species]-dead"). You can use one dead icon for multiple closely related plants with it.
	var/icon_dead
	/// Used to override harvest icon (default is "[species]-harvest"). If null, plant will use [icon_grow][growthstages].
	var/icon_harvest
	/// How long before the plant begins to take damage from age.
	var/lifespan = 25
	/// Amount of health the plant has.
	var/endurance = 15
	/// Used to determine which sprite to switch to when growing.
	var/maturation = 6
	/// Changes the amount of time needed for a plant to become harvestable.
	var/production = 6
	/// Amount of growns created per harvest. If is -1, the plant/shroom/weed is never meant to be harvested.
	var/yield = 3
	/// The 'power' of a plant. Generally effects the amount of reagent in a plant, also used in other ways.
	var/potency = 10
	/// Amount of growth sprites the plant has.
	var/growthstages = 6
	// Chance that a plant will mutate in each stage of it's life.
	var/instability = 5
	/// How rare the plant is. Used for giving points to cargo when shipping off to CentCom.
	var/rarity = 0
	/// The type of plants that this plant can mutate into.
	var/list/mutatelist
	/// Plant genes are stored here, see plant_genes.dm for more info.
	var/list/genes = list()
	/// A list of reagents to add to product.
	var/list/reagents_add
	// Format: "reagent_id" = potency multiplier
	// Stronger reagents must always come first to avoid being displaced by weaker ones.
	// Total amount of any reagent in plant is calculated by formula: max(round(potency * multiplier), 1)
	///If the chance below passes, then this many weeds sprout during growth
	var/weed_rate = 1
	///Percentage chance per tray update to grow weeds
	var/weed_chance = 5
	///Determines if the plant has had a graft removed or not.
	var/grafted = FALSE
	///Type-path of trait to be applied when grafting a plant.
	var/graft_gene

/obj/item/seeds/Initialize(mapload, nogenes = 0)
	. = ..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)

	if(!icon_grow)
		icon_grow = "[species]-grow"

	if(!icon_dead)
		icon_dead = "[species]-dead"

	if(!icon_harvest && !get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism) && yield != -1)
		icon_harvest = "[species]-harvest"

	if(!nogenes) // not used on Copy()
		genes += new /datum/plant_gene/core/lifespan(lifespan)
		genes += new /datum/plant_gene/core/endurance(endurance)
		genes += new /datum/plant_gene/core/weed_rate(weed_rate)
		genes += new /datum/plant_gene/core/weed_chance(weed_chance)
		if(yield != -1)
			genes += new /datum/plant_gene/core/yield(yield)
			genes += new /datum/plant_gene/core/production(production)
		if(potency != -1)
			genes += new /datum/plant_gene/core/potency(potency)
			genes += new /datum/plant_gene/core/instability(instability)

		for(var/p in genes)
			if(ispath(p))
				genes -= p
				genes += new p

		for(var/reag_id in reagents_add)
			genes += new /datum/plant_gene/reagent(reag_id, reagents_add[reag_id])
		reagents_from_genes() //quality coding

/obj/item/seeds/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Use a pen on it to rename it or change its description.</span>"
	if(reagents_add && user.can_see_reagents())
		. += "<span class='notice'>- Plant Reagents -</span>"
		for(var/datum/plant_gene/reagent/G in genes)
			. += "<span class='notice'>- [G.get_name()] -</span>"

/obj/item/seeds/proc/Copy()
	var/obj/item/seeds/S = new type(null, 1)
	// Copy all the stats
	S.lifespan = lifespan
	S.endurance = endurance
	S.maturation = maturation
	S.production = production
	S.yield = yield
	S.potency = potency
	S.instability = instability
	S.weed_rate = weed_rate
	S.weed_chance = weed_chance
	S.name = name
	S.plantname = plantname
	S.desc = desc
	S.productdesc = productdesc
	S.genes = list()
	for(var/g in genes)
		var/datum/plant_gene/G = g
		S.genes += G.Copy()
	S.reagents_add = reagents_add.Copy() // Faster than grabbing the list from genes.
	return S

/obj/item/seeds/proc/get_gene(typepath)
	return (locate(typepath) in genes)

/obj/item/seeds/proc/reagents_from_genes()
	reagents_add = list()
	for(var/datum/plant_gene/reagent/R in genes)
		reagents_add[R.reagent_id] = R.rate

///This proc adds a mutability_flag to a gene
/obj/item/seeds/proc/set_mutability(typepath, mutability)
	var/datum/plant_gene/g = get_gene(typepath)
	if(g)
		g.mutability_flags |=  mutability

///This proc removes a mutability_flag from a gene
/obj/item/seeds/proc/unset_mutability(typepath, mutability)
	var/datum/plant_gene/g = get_gene(typepath)
	if(g)
		g.mutability_flags &=  ~mutability

/obj/item/seeds/proc/mutate(lifemut = 2, endmut = 5, productmut = 1, yieldmut = 2, potmut = 25, wrmut = 2, wcmut = 5, traitmut = 0, stabmut = 3)
	adjust_lifespan(rand(-lifemut,lifemut))
	adjust_endurance(rand(-endmut,endmut))
	adjust_production(rand(-productmut,productmut))
	adjust_yield(rand(-yieldmut,yieldmut))
	adjust_potency(rand(-potmut,potmut))
	adjust_instability(rand(-stabmut,stabmut))
	adjust_weed_rate(rand(-wrmut, wrmut))
	adjust_weed_chance(rand(-wcmut, wcmut))
	if(prob(traitmut))
		if(prob(50))
			add_random_traits(1, 1)
		else
			add_random_reagents(1, 1)



/obj/item/seeds/bullet_act(obj/projectile/Proj) //Works with the Somatoray to modify plant variables.
	if(istype(Proj, /obj/projectile/energy/florayield))
		var/rating = 1
		if(istype(loc, /obj/machinery/hydroponics))
			var/obj/machinery/hydroponics/H = loc
			rating = H.rating

		if(yield == 0)//Oh god don't divide by zero you'll doom us all.
			adjust_yield(1 * rating)
		else if(prob(1/(yield * yield) * 100))//This formula gives you diminishing returns based on yield. 100% with 1 yield, decreasing to 25%, 11%, 6, 4, 2...
			adjust_yield(1 * rating)
	else
		return ..()


// Harvest procs
/obj/item/seeds/proc/getYield()
	var/return_yield = yield

	var/obj/machinery/hydroponics/parent = loc
	if(istype(loc, /obj/machinery/hydroponics))
		if(parent.yieldmod == 0)
			return_yield = min(return_yield, 1)//1 if above zero, 0 otherwise
		else
			return_yield *= (parent.yieldmod)

	return return_yield


/obj/item/seeds/proc/harvest(mob/user)
	///Reference to the tray/soil the seeds are planted in.
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	///Count used for creating the correct amount of results to the harvest.
	var/t_amount = 0
	///List of plants all harvested from the same batch.
	var/list/result = list()
	///Tile of the harvester to deposit the growables.
	var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc //needed for TK
	///Name of the grown products.
	var/product_name
	///The Number of products produced by the plant, typically the yield. Modified by Densified Chemicals.
	var/product_count = getYield()
	if(get_gene(/datum/plant_gene/trait/maxchem))
		product_count = clamp(round(product_count/2),0,5)
	while(t_amount < product_count)
		var/obj/item/reagent_containers/food/snacks/grown/t_prod
		if(instability >= 30 && prob(instability/3) && mutatelist.len)
			var/obj/item/seeds/new_prod = pick(mutatelist)
			t_prod = initial(new_prod.product)
			if(t_prod)
				t_prod = new t_prod(output_loc, src)
				t_prod.seed.instability = instability/2
		else
			t_prod = new product(output_loc, src)
		if(parent.myseed.plantname != initial(parent.myseed.plantname))
			t_prod.name = lowertext(parent.myseed.plantname)
		if(productdesc)
			t_prod.desc = productdesc
		t_prod.seed.name = parent.myseed.name
		t_prod.seed.desc = parent.myseed.desc
		t_prod.seed.plantname = parent.myseed.plantname
		result.Add(t_prod) // User gets a consumable
		if(!t_prod)
			return
		t_amount++
		product_name = parent.myseed.plantname
	if(getYield() >= 1)
		SSblackbox.record_feedback("tally", "food_harvested", getYield(), product_name)
	parent.update_tray(user)

	return result

/**
  * This is where plant chemical products are handled.
  *
  * Individually, the formula for individual amounts of chemicals is Potency * the chemical production %, rounded to the fullest 1.
  * Specific chem handling is also handled here, like bloodtype, food taste within nutriment, and the auto-distilling trait.
  */
/obj/item/seeds/proc/prepare_result(var/obj/item/T)
	if(!T.reagents)
		CRASH("[T] has no reagents.")
	var/reagent_max = 0
	for(var/rid in reagents_add)
		reagent_max += reagents_add[rid]
	if(istype(T, /obj/item/reagent_containers/food/snacks/grown))
		var/obj/item/reagent_containers/food/snacks/grown/grown_edible = T
		for(var/rid in reagents_add)
			var/reagent_overflow_mod = reagents_add[rid]
			if(reagent_max > 1)
				reagent_overflow_mod = (reagents_add[rid]/ reagent_max)
			var/edible_vol = grown_edible.reagents ? grown_edible.reagents.maximum_volume : 0
			var/amount = max(1, round((edible_vol)*(potency/100) * reagent_overflow_mod, 1)) //the plant will always have at least 1u of each of the reagents in its reagent production traits
			var/list/data
			if(rid == /datum/reagent/blood) // Hack to make blood in plants always O-
				data = list("blood_type" = "O-")
			if(rid == /datum/reagent/consumable/nutriment || rid == /datum/reagent/consumable/nutriment/vitamin)
				data = grown_edible.tastes // apple tastes of apple.
				//Handles the distillary trait, swaps nutriment and vitamins for that species brewable if it exists.
				if(get_gene(/datum/plant_gene/trait/brewing) && grown_edible.distill_reagent)
					T.reagents.add_reagent(grown_edible.distill_reagent, amount/2)
					continue
			T.reagents.add_reagent(rid, amount, data)


/// Setters procs ///

/**
  * Adjusts seed yield up or down according to adjustamt. (Max 10)
  */
/obj/item/seeds/proc/adjust_yield(adjustamt)
	if(yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		yield = clamp(yield + adjustamt, 0, 10)

		if(yield <= 0 && get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
			yield = 1 // Mushrooms always have a minimum yield of 1.
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/yield)
		if(C)
			C.value = yield

/**
  * Adjusts seed lifespan up or down according to adjustamt. (Max 100)
  */
/obj/item/seeds/proc/adjust_lifespan(adjustamt)
	lifespan = clamp(lifespan + adjustamt, 10, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/lifespan)
	if(C)
		C.value = lifespan

/**
  * Adjusts seed endurance up or down according to adjustamt. (Max 100)
  */
/obj/item/seeds/proc/adjust_endurance(adjustamt)
	endurance = clamp(endurance + adjustamt, 10, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/endurance)
	if(C)
		C.value = endurance

/**
  * Adjusts seed production seed up or down according to adjustamt. (Max 10)
  */
/obj/item/seeds/proc/adjust_production(adjustamt)
	if(yield != -1)
		production = clamp(production + adjustamt, 1, 10)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/production)
		if(C)
			C.value = production

/**
  * Adjusts seed potency up or down according to adjustamt. (Max 100)
  */
/obj/item/seeds/proc/adjust_potency(adjustamt)
	if(potency != -1)
		potency = clamp(potency + adjustamt, 0, 100)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/potency)
		if(C)
			C.value = potency

/**
  * Adjusts seed instability up or down according to adjustamt. (Max 100)
  */
/obj/item/seeds/proc/adjust_instability(adjustamt)
	if(instability == -1)
		return
	instability = clamp(instability + adjustamt, 0, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/instability)
	if(C)
		C.value = instability

/**
  * Adjusts seed weed grwoth speed up or down according to adjustamt. (Max 10)
  */
/obj/item/seeds/proc/adjust_weed_rate(adjustamt)
	weed_rate = clamp(weed_rate + adjustamt, 0, 10)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_rate)
	if(C)
		C.value = weed_rate

/**
  * Adjusts seed weed chance up or down according to adjustamt. (Max 67%)
  */
/obj/item/seeds/proc/adjust_weed_chance(adjustamt)
	weed_chance = clamp(weed_chance + adjustamt, 0, 67)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_chance)
	if(C)
		C.value = weed_chance

//Directly setting stats

/**
  * Sets the plant's yield stat to the value of adjustamt. (Max 10)
  */
/obj/item/seeds/proc/set_yield(adjustamt)
	if(yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		yield = clamp(adjustamt, 0, 10)

		if(yield <= 0 && get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
			yield = 1 // Mushrooms always have a minimum yield of 1.
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/yield)
		if(C)
			C.value = yield

/**
  * Sets the plant's lifespan stat to the value of adjustamt. (Max 100)
  */
/obj/item/seeds/proc/set_lifespan(adjustamt)
	lifespan = clamp(adjustamt, 10, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/lifespan)
	if(C)
		C.value = lifespan

/**
  * Sets the plant's endurance stat to the value of adjustamt. (Max 100)
  */
/obj/item/seeds/proc/set_endurance(adjustamt)
	endurance = clamp(adjustamt, 10, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/endurance)
	if(C)
		C.value = endurance

/**
  * Sets the plant's production stat to the value of adjustamt. (Max 10)
  */
/obj/item/seeds/proc/set_production(adjustamt)
	if(yield != -1)
		production = clamp(adjustamt, 1, 10)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/production)
		if(C)
			C.value = production

/**
  * Sets the plant's potency stat to the value of adjustamt. (Max 100)
  */
/obj/item/seeds/proc/set_potency(adjustamt)
	if(potency != -1)
		potency = clamp(adjustamt, 0, 100)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/potency)
		if(C)
			C.value = potency

/**
  * Sets the plant's instability stat to the value of adjustamt. (Max 100)
  */
/obj/item/seeds/proc/set_instability(adjustamt)
	if(instability == -1)
		return
	instability = clamp(adjustamt, 0, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/instability)
	if(C)
		C.value = instability

/**
  * Sets the plant's weed production rate to the value of adjustamt. (Max 10)
  */
/obj/item/seeds/proc/set_weed_rate(adjustamt)
	weed_rate = clamp(adjustamt, 0, 10)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_rate)
	if(C)
		C.value = weed_rate

/**
  * Sets the plant's weed growth percentage to the value of adjustamt. (Max 67%)
  */
/obj/item/seeds/proc/set_weed_chance(adjustamt)
	weed_chance = clamp(adjustamt, 0, 67)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_chance)
	if(C)
		C.value = weed_chance


/obj/item/seeds/proc/get_analyzer_text()  //in case seeds have something special to tell to the analyzer
	var/text = ""
	if(!get_gene(/datum/plant_gene/trait/plant_type/weed_hardy) && !get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism) && !get_gene(/datum/plant_gene/trait/plant_type/alien_properties))
		text += "- Plant type: Normal plant\n"
	if(get_gene(/datum/plant_gene/trait/plant_type/weed_hardy))
		text += "- Plant type: Weed. Can grow in nutrient-poor soil.\n"
	if(get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
		text += "- Plant type: Mushroom. Can grow in dry soil.\n"
	if(get_gene(/datum/plant_gene/trait/plant_type/alien_properties))
		text += "- Plant type: <span class='warning'>UNKNOWN</span> \n"
	if(potency != -1)
		text += "- Potency: [potency]\n"
	if(yield != -1)
		text += "- Yield: [yield]\n"
	text += "- Maturation speed: [maturation]\n"
	if(yield != -1)
		text += "- Production speed: [production]\n"
	text += "- Endurance: [endurance]\n"
	text += "- Lifespan: [lifespan]\n"
	text += "- Instability: [instability]\n"
	text += "- Weed Growth Rate: [weed_rate]\n"
	text += "- Weed Vulnerability: [weed_chance]\n"
	if(rarity)
		text += "- Species Discovery Value: [rarity]\n"
	var/all_traits = ""
	for(var/datum/plant_gene/trait/traits in genes)
		if(istype(traits, /datum/plant_gene/trait/plant_type))
			continue
		all_traits += " [traits.get_name()]"
	text += "- Plant Traits:[all_traits]\n"
	text += "*---------*"
	return text

/obj/item/seeds/proc/on_chem_reaction(datum/reagents/S)  //in case seeds have some special interaction with special chems
	return

/obj/item/seeds/attackby(obj/item/O, mob/user, params)
	if (istype(O, /obj/item/plant_analyzer))
		to_chat(user, "<span class='info'>*---------*\n This is \a <span class='name'>[src]</span>.</span>")
		var/text
		var/obj/item/plant_analyzer/P_analyzer = O
		if(P_analyzer.scan_mode == PLANT_SCANMODE_STATS)
			text = get_analyzer_text()
			if(text)
				to_chat(user, "<span class='notice'>[text]</span>")
		if(reagents_add && P_analyzer.scan_mode == PLANT_SCANMODE_CHEMICALS)
			to_chat(user, "<span class='notice'>- Plant Reagents -</span>")
			to_chat(user, "<span class='notice'>*---------*</span>")
			for(var/datum/plant_gene/reagent/G in genes)
				to_chat(user, "<span class='notice'>- [G.get_name()] -</span>")
			to_chat(user, "<span class='notice'>*---------*</span>")


		return

	if(istype(O, /obj/item/pen))
		var/choice = input("What would you like to change?") in list("Plant Name", "Seed Description", "Product Description", "Cancel")
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		switch(choice)
			if("Plant Name")
				var/newplantname = reject_bad_text(stripped_input(user, "Write a new plant name:", name, plantname))
				if(!user.canUseTopic(src, BE_CLOSE))
					return
				if (length(newplantname) > 20)
					to_chat(user, "<span class='warning'>That name is too long!</span>")
					return
				if(!newplantname)
					to_chat(user, "<span class='warning'>That name is invalid.</span>")
					return
				else
					name = "[lowertext(newplantname)]"
					plantname = newplantname
			if("Seed Description")
				var/newdesc = stripped_input(user, "Write a new description:", name, desc)
				if(!user.canUseTopic(src, BE_CLOSE))
					return
				if (length(newdesc) > 180)
					to_chat(user, "<span class='warning'>That description is too long!</span>")
					return
				if(!newdesc)
					to_chat(user, "<span class='warning'>That description is invalid.</span>")
					return
				else
					desc = newdesc
			if("Product Description")
				if(product && !productdesc)
					productdesc = initial(product.desc)
				var/newproductdesc = stripped_input(user, "Write a new description:", name, productdesc)
				if(!user.canUseTopic(src, BE_CLOSE))
					return
				if (length(newproductdesc) > 180)
					to_chat(user, "<span class='warning'>That description is too long!</span>")
					return
				if(!newproductdesc)
					to_chat(user, "<span class='warning'>That description is invalid.</span>")
					return
				else
					productdesc = newproductdesc
			else
				return

	..() // Fallthrough to item/attackby() so that bags can pick seeds up

/obj/item/seeds/proc/randomize_stats()
	set_lifespan(rand(25, 60))
	set_endurance(rand(15, 35))
	set_production(rand(2, 10))
	set_yield(rand(1, 10))
	set_potency(rand(10, 35))
	set_weed_rate(rand(1, 10))
	set_weed_chance(rand(5, 100))
	maturation = rand(6, 12)

/obj/item/seeds/proc/add_random_reagents(lower = 0, upper = 2)
	var/amount_random_reagents = rand(lower, upper)
	for(var/i in 1 to amount_random_reagents)
		var/random_amount = rand(4, 15) * 0.01 // this must be multiplied by 0.01, otherwise, it will not properly associate
		var/datum/plant_gene/reagent/R = new(get_random_reagent_id(), random_amount)
		if(R.can_add(src))
			genes += R
		else
			qdel(R)
	reagents_from_genes()

/obj/item/seeds/proc/add_random_traits(lower = 0, upper = 2)
	var/amount_random_traits = rand(lower, upper)
	for(var/i in 1 to amount_random_traits)
		var/random_trait = pick((subtypesof(/datum/plant_gene/trait)-typesof(/datum/plant_gene/trait/plant_type)))
		var/datum/plant_gene/trait/T = new random_trait
		if(T.can_add(src))
			genes += T
		else
			qdel(T)

/obj/item/seeds/proc/add_random_plant_type(normal_plant_chance = 75)
	if(prob(normal_plant_chance))
		var/random_plant_type = pick(subtypesof(/datum/plant_gene/trait/plant_type))
		var/datum/plant_gene/trait/plant_type/P = new random_plant_type
		if(P.can_add(src))
			genes += P
		else
			qdel(P)

/obj/item/seeds/proc/remove_random_reagents(lower = 0, upper = 2)
	var/amount_random_reagents = rand(lower, upper)
	for(var/i in 1 to amount_random_reagents)
		var/datum/reagent/chemical = pick(reagents_add)
		qdel(chemical)

/**
  * Creates a graft from this plant.
  *
  * Creates a new graft from this plant.
  * Sets the grafts trait to this plants graftable trait.
  * Gives the graft a reference to this plant.
  * Copies all the relevant stats from this plant to the graft.
  * Returns the created graft.
  */
/obj/item/seeds/proc/create_graft()
	var/obj/item/graft/snip = new(loc, graft_gene)
	snip.parent_seed = src
	snip.parent_name = plantname
	snip.name += "([plantname])"

	// Copy over stats so the graft can outlive its parent.
	snip.lifespan = lifespan
	snip.endurance = endurance
	snip.production = production
	snip.weed_rate = weed_rate
	snip.weed_chance = weed_chance
	snip.yield = yield

	return snip

/**
  * Applies a graft to this plant.
  *
  * Adds the graft trait to this plant if possible.
  * Increases plant stats by 2/3 of the grafts stats to a maximum of 100 (10 for yield).
  * Returns [TRUE]
  *
  * Arguments:
  * - [snip][/obj/item/graft]: The graft being used applied to this plant.
  */
/obj/item/seeds/proc/apply_graft(obj/item/graft/snip)
	var/datum/plant_gene/trait/new_trait = snip.stored_trait
	if(new_trait?.can_add(src))
		genes += new_trait.Copy()

	// Adjust stats based on graft stats.
	src.lifespan	= round(clamp(max(src.lifespan,		(src.lifespan	+(2/3)*(snip.lifespan	-src.lifespan)		)),0,100))
	src.endurance	= round(clamp(max(src.endurance,	(src.endurance	+(2/3)*(snip.endurance	-src.endurance)		)),0,100))
	src.production	= round(clamp(max(src.production,	(src.production	+(2/3)*(snip.production	-src.production)	)),0,100))
	src.weed_rate	= round(clamp(max(src.weed_rate,	(src.weed_rate	+(2/3)*(snip.weed_rate	-src.weed_rate)		)),0,100))
	src.weed_chance	= round(clamp(max(src.weed_chance,	(src.weed_chance+(2/3)*(snip.weed_chance-src.weed_chance)	)),0,100))
	src.yield		= round(clamp(max(src.yield,		(src.yield		+(2/3)*(snip.yield		-src.yield)			)),0,10	))

	return TRUE
