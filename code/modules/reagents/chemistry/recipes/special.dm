#define RNGCHEM_INPUT "input"
#define RNGCHEM_CATALYSTS "catalysts"

#define VALID_RANDOM_RECIPE_REAGENT(chemical_flags) (chemical_flags & REAGENT_CAN_BE_SYNTHESIZED && !(chemical_flags & REAGENT_NO_RANDOM_RECIPE))

/datum/chemical_reaction/randomized
	abstract_type = /datum/chemical_reaction/randomized

	//Increase default leniency because these are already hard enough
	optimal_ph_min = 1
	optimal_ph_max = 13
	temp_exponent_factor = 0
	ph_exponent_factor = 1
	H_ion_release = 0

	//Will reset every x days
	var/persistence_period = 7
	///creation timestamp
	var/created
	///How much the range can deviate, and also affects impure range
	var/suboptimal_range_ph = 3
	///Minimum required temperature for random range
	var/min_temp = 1
	///Maximum required temperature for random range
	var/max_temp = 600
	///Minimum random volume of input reagent
	var/min_input_reagent_amount = 1
	///Maximum random volume of input reagent
	var/max_input_reagent_amount = 10
	///Minimum number of random required reagents to select from GetPossibleReagents(RNGCHEM_INPUT)
	var/min_input_reagents = 2
	///Maximum number of random reagents to select from GetPossibleReagents(RNGCHEM_INPUT)
	var/max_input_reagents = 5
	///Minimum number of random catalyst reagents to select from GetPossibleReagents(RNGCHEM_CATALYST)
	var/min_catalysts = 0
	///Maximum number of random catalyst reagents to select from GetPossibleReagents(RNGCHEM_CATALYST)
	var/max_catalysts = 2
	///Random list of posible containers to select
	var/list/possible_containers

/datum/chemical_reaction/randomized/New(recipe_data)
	. = ..()

	//creation time, decides if we are random generating or not
	created = recipe_data ? text2num(recipe_data["timestamp"]) : world.realtime
	if(daysSince(created) > persistence_period)
		created = world.realtime
		recipe_data = null

	//all reagents
	if(recipe_data)
		required_reagents = unwrap_reagent_list(recipe_data["required_reagents"])
		if(!required_reagents)
			qdel(src)
			return
		required_catalysts = unwrap_reagent_list(recipe_data["required_catalysts"])
		if(!required_catalysts)
			qdel(src)
			return
		results = unwrap_reagent_list(recipe_data["results"])
		if(!results)
			qdel(src)
			return
	else
		var/list/remaining_possible_reagents = GetPossibleReagents(RNGCHEM_INPUT)
		var/list/remaining_possible_catalysts = GetPossibleReagents(RNGCHEM_CATALYSTS)
		//We're going to assume we're not doing any weird partial reactions for now.
		for(var/reagent_type in results)
			remaining_possible_catalysts -= reagent_type
			remaining_possible_reagents -= reagent_type

		var/in_reagent_count = min(rand(min_input_reagents, max_input_reagents),remaining_possible_reagents.len)
		if(in_reagent_count <= 0)
			qdel(src)
			return

		required_reagents = list()
		for(var/i in 1 to in_reagent_count)
			var/r_id = pick_n_take(remaining_possible_reagents)
			required_reagents[r_id] = rand(min_input_reagent_amount,max_input_reagent_amount)
			remaining_possible_catalysts -= r_id //Can't have same reagents both as catalyst and reagent. Or can we ?

		required_catalysts = list()
		var/in_catalyst_count = min(rand(min_catalysts,max_catalysts),remaining_possible_catalysts.len)
		for(var/i in 1 to in_catalyst_count)
			required_catalysts[pick_n_take(remaining_possible_catalysts)] = rand(min_input_reagent_amount,max_input_reagent_amount)

	//temperature
	if(recipe_data)
		is_cold_recipe = recipe_data["is_cold_recipe"]
		required_temp = recipe_data["required_temp"]
		optimal_temp = recipe_data["optimal_temp"]
		overheat_temp = recipe_data["overheat_temp"]
		thermic_constant = recipe_data["thermic_constant"]
	else
		is_cold_recipe = pick(TRUE, FALSE)
		if(is_cold_recipe)
			required_temp = rand(min_temp + 50, max_temp)
			optimal_temp = rand(min_temp + 25, required_temp - 10)
			overheat_temp = rand(min_temp, optimal_temp - 10)
			if(overheat_temp >= 200) //Otherwise it can disappear when you're mixing and I don't want this to happen here
				overheat_temp = 200
		else
			required_temp = rand(min_temp, max_temp - 50)
			optimal_temp = rand(required_temp + 10, max_temp - 25)
			overheat_temp = rand(optimal_temp, max_temp + 50)
			if(overheat_temp <= 400)
				overheat_temp = 400

	//ph
	if(recipe_data)
		optimal_ph_min = recipe_data["optimal_ph_min"]
		optimal_ph_max = recipe_data["optimal_ph_max"]
		determin_ph_range = recipe_data["determin_ph_range"]
		H_ion_release = recipe_data["H_ion_release"]
	else
		optimal_ph_min = CHEMICAL_MIN_PH + rand(0, suboptimal_range_ph)
		optimal_ph_max = max((CHEMICAL_MAX_PH + rand(0, suboptimal_range_ph)), (CHEMICAL_MIN_PH + 1)) //Always ensure we've a window of 1
		determin_ph_range = suboptimal_range_ph
		H_ion_release = (rand(0, 25) / 100)// 0 - 0.25

	//purity
	purity_min = recipe_data ? recipe_data["purity_min"] : (rand(0, 4) / 10)

	//container
	if(recipe_data)
		var/container = recipe_data["required_container"]
		if(container)
			container = text2path(container)
			if(!container)
				qdel(src)
				return
			required_container = container
	else if(length(possible_containers))
		required_container = pick(possible_containers)

/**
 * Returns the reagents to select for randomizing
 * Arguments
 *
 * * kind - see above defines
*/
/datum/chemical_reaction/randomized/proc/GetPossibleReagents(kind)
	PROTECTED_PROC(TRUE)

	return list()

/**
 * Converts a list of text reagent paths into actual reagents
 * Arguments
 *
 * * list/textreagents - the list reagents
*/
/datum/chemical_reaction/randomized/proc/unwrap_reagent_list(list/textreagents)
	PRIVATE_PROC(TRUE)

	. = list()
	for(var/R in textreagents)
		var/pathR = text2path(R)
		if(!pathR)
			return null
		.[pathR] = textreagents[R]

/datum/chemical_reaction/randomized/secret_sauce
	persistence_period = 7 //Reset every week
	possible_containers = list(/obj/item/reagent_containers/cup/bucket) //easy way to ensure no common conflicts
	results = list(/datum/reagent/consumable/secretsauce = 1)

/datum/chemical_reaction/randomized/secret_sauce/GetPossibleReagents(kind)
	switch(kind)
		if(RNGCHEM_INPUT,RNGCHEM_CATALYSTS)
			var/food_reagent_ids = list()
			for(var/datum/reagent/consumable/food as anything in valid_subtypesof(/datum/reagent/consumable))
				var/chemical_flags = food::chemical_flags
				if(VALID_RANDOM_RECIPE_REAGENT(chemical_flags))
					food_reagent_ids += food
			return food_reagent_ids
	return ..()

///Random recipe for meme chem metalgen. Always requires wittel and resets every 3 days
/datum/chemical_reaction/randomized/metalgen
	persistence_period = 3 //Resets every three days. It's the ultimate meme and is best not worn out
	min_catalysts = 1
	max_catalysts = 1
	results = list(/datum/reagent/metalgen = 20)

/datum/chemical_reaction/randomized/metalgen/GetPossibleReagents(kind)
	switch(kind)
		if(RNGCHEM_INPUT)
			var/list/possible_ingredients = list()
			for(var/datum/reagent/medicine/compound as anything in valid_subtypesof(/datum/reagent/medicine))
				var/chemical_flags = compound::chemical_flags
				if(VALID_RANDOM_RECIPE_REAGENT(chemical_flags))
					possible_ingredients += compound
			return possible_ingredients

		if(RNGCHEM_CATALYSTS)
			return list(/datum/reagent/wittel)

///Random recipe that turns stuff into ROCKS
/datum/chemical_reaction/randomized/petrifium
	persistence_period = 7
	results = list(/datum/reagent/metalgen/petrifium = 20)

/datum/chemical_reaction/randomized/petrifium/GetPossibleReagents(kind)
	var/list/possible_ingredients = list()
	for(var/datum/reagent/reagent as anything in valid_subtypesof(/datum/reagent))
		var/chemical_flags = reagent::chemical_flags
		if(VALID_RANDOM_RECIPE_REAGENT(chemical_flags))
			possible_ingredients += reagent
	return possible_ingredients

/obj/item/paper/secretrecipe
	name = "Old Recipe"
	/// The recipes we can spawn with
	var/list/possible_recipes = list(/datum/chemical_reaction/randomized/metalgen, /datum/chemical_reaction/randomized/secret_sauce)

/obj/item/paper/secretrecipe/Initialize(mapload)
	. = ..()

	if(SSpersistence.initialized)
		UpdateInfo()
	else
		SSticker.OnRoundstart(CALLBACK(src, PROC_REF(UpdateInfo)))

/obj/item/paper/secretrecipe/ui_static_data(mob/living/user)
	. = ..()
	if(!istype(user) || user.stat == DEAD)
		.["text"] = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, \
		sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. \
		Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris \
		nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in \
		reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla \
		pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa \
		qui officia deserunt mollit anim id est laborum."

///Updates the paper info
/obj/item/paper/secretrecipe/proc/UpdateInfo()
	PRIVATE_PROC(TRUE)

	var/datum/chemical_reaction/recipe = GLOB.chemical_reactions_list[pick(possible_recipes)]
	if(!recipe)
		add_raw_text("This recipe is illegible.")
		update_appearance()
		return
	var/list/dat = list("<ul>")
	for(var/datum/reagent/R as anything in recipe.required_reagents)
		dat += "<li>[recipe.required_reagents[R]]u of [R::name]</li>"
	dat += "</ul>"
	if(recipe.required_catalysts.len)
		dat += "With following present: <ul>"
		for(var/datum/reagent/R as anything in recipe.required_catalysts)
			dat += "<li>[recipe.required_catalysts[R]]u of [R::name]</li>"
		dat += "</ul>"
	dat += "</ul>Mix slowly<ul>"
	if(recipe.required_container)
		var/obj/item/I = recipe.required_container
		dat += "<li> in a [initial(I.name)]</li>"
	if(recipe.required_temp != 0)
		if(recipe.is_cold_recipe)
			dat += " <li>cooling it below [recipe.required_temp] degrees"
			dat += " but not below [recipe.overheat_temp] degrees</li>"
		else
			dat += " <li>heating it above [recipe.required_temp] degrees"
			dat += " but not above [recipe.overheat_temp] degrees"
		if(recipe.thermic_constant > 0)
			dat += "<li> taking care of its exothermic nature</li>"
		else if(recipe.thermic_constant < 0)
			dat += "<li> taking care of its endothermic nature</li>"
	var/datum/chemical_reaction/randomized/random_recipe = recipe
	if(random_recipe)
		dat += "<li> keeping your pH between [recipe.optimal_ph_min] and [recipe.optimal_ph_max]</li>"
		dat += "<li> and your purity above [recipe.purity_min]</li>"
	dat += "</ul>"
	dat += "."
	add_raw_text(dat.Join(""))
	update_appearance()

/// Paper that spawns a recipe for the petrification serum
/obj/item/paper/secretrecipe/petrifium
	name = "paper" //gets affixed by rock
	possible_recipes = list(/datum/chemical_reaction/randomized/petrifium)

/obj/item/paper/secretrecipe/petrifium/Initialize(mapload)
	. = ..()

	metal_morph(src, /datum/material/rock)

/// Recipe that always has metalgen
/obj/item/paper/secretrecipe/metalgen
	name = "paper" //gets affixed by uranium
	possible_recipes = list(/datum/chemical_reaction/randomized/metalgen)

/obj/item/paper/secretrecipe/metalgen/Initialize(mapload)
	. = ..()

	metal_morph(src, /datum/material/uranium)

#undef RNGCHEM_INPUT
#undef RNGCHEM_CATALYSTS
#undef VALID_RANDOM_RECIPE_REAGENT
