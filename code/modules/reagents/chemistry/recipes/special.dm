GLOBAL_LIST_INIT(food_reagents, build_reagents_to_food()) //reagentid = related food types
GLOBAL_LIST_INIT(medicine_reagents, build_medicine_reagents())

#define VALID_RANDOM_RECIPE_REAGENT(chemical_flags) (chemical_flags & REAGENT_CAN_BE_SYNTHESIZED && !(chemical_flags & REAGENT_NO_RANDOM_RECIPE))

/proc/build_reagents_to_food()
	. = list()
	for (var/type in subtypesof(/obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/item = new type()
		for(var/datum/reagent/reagent as anything in item.list_reagents)
			var/chem_flags = initial(reagent.chemical_flags)
			if(!VALID_RANDOM_RECIPE_REAGENT(chem_flags))
				continue
			if (!.[reagent])
				.[reagent] = list()
			.[reagent] += type
		qdel(item)
	//dang plant snowflake
	for (var/type in subtypesof(/obj/item/seeds))
		var/obj/item/seeds/item = new type()
		for(var/datum/reagent/reagent as anything in item.reagents_add)
			var/chem_flags = initial(reagent.chemical_flags)
			if(!VALID_RANDOM_RECIPE_REAGENT(chem_flags))
				continue
			if (!.[reagent])
				.[reagent] = list()
			.[reagent] += type
		qdel(item)

///Just grab every craftable medicine you can think off
/proc/build_medicine_reagents()
	. = list()

	for(var/datum/reagent/reagent as anything in subtypesof(/datum/reagent/medicine))
		var/chem_flags = initial(reagent.chemical_flags)
		if(VALID_RANDOM_RECIPE_REAGENT(chem_flags))
			. += reagent

#define RNGCHEM_INPUT "input"
#define RNGCHEM_CATALYSTS "catalysts"
#define RNGCHEM_OUTPUT "output"

/datum/chemical_reaction/randomized

	//Increase default leniency because these are already hard enough
	optimal_ph_min = 1
	optimal_ph_max = 13
	temp_exponent_factor = 0
	ph_exponent_factor = 1
	H_ion_release = 0

	var/persistent = FALSE
	var/persistence_period = 7 //Will reset every x days
	var/created //creation timestamp

	var/randomize_container = FALSE
	var/list/possible_containers = list()

	var/randomize_req_temperature = TRUE
	var/min_temp = 1
	var/max_temp = 600
	///If the reaction can be exothermic or endothermic randomly too
	var/exo_or_endothermic = FALSE

	///If pH is randomised
	var/randomize_req_ph = FALSE
	///Lowest pH value possible
	var/min_ph = 0
	///Highest pH value possible
	var/max_ph = 14
	///How much the range can deviate, and also affects impure range
	var/inoptimal_range_ph = 3

	///If the impurity failure threshold is randomized between 0 - 0.4
	var/randomize_impurity_minimum = FALSE
	///If the impure/inverse/failure reagents are randomized
	var/randomize_impurity_reagents = FALSE

	var/randomize_inputs = TRUE
	var/min_input_reagent_amount = 1
	var/max_input_reagent_amount = 10
	var/min_input_reagents = 2
	var/max_input_reagents = 5
	var/list/possible_reagents = list()
	var/min_catalysts = 0
	var/max_catalysts = 2
	var/list/possible_catalysts = list()

	var/randomize_results = FALSE
	var/min_output_reagent_amount = 1
	var/max_output_reagent_amount = 5
	var/min_result_reagents = 1
	var/max_result_reagents = 1
	var/list/possible_results = list()

/datum/chemical_reaction/randomized/proc/GenerateRecipe()
	created = world.realtime
	if(randomize_container)
		required_container = pick(possible_containers)
	if(randomize_req_temperature)
		is_cold_recipe = pick(TRUE,FALSE)
		if(is_cold_recipe)
			required_temp = rand(min_temp+50, max_temp)
			optimal_temp = rand(min_temp+25, required_temp-10)
			overheat_temp = rand(min_temp, optimal_temp-10)
			if(overheat_temp >= 200) //Otherwise it can disappear when you're mixing and I don't want this to happen here
				overheat_temp = 200
			if(exo_or_endothermic)
				thermic_constant = (rand(-200, 200))
		else
			required_temp = rand(min_temp, max_temp-50)
			optimal_temp = rand(required_temp+10, max_temp-25)
			overheat_temp = rand(optimal_temp, max_temp+50)
			if(overheat_temp <= 400)
				overheat_temp = 400
			if(exo_or_endothermic)
				thermic_constant = (rand(-200, 200))

	if(randomize_req_ph)
		optimal_ph_min = min_ph + rand(0, inoptimal_range_ph)
		optimal_ph_max = max((max_ph + rand(0, inoptimal_range_ph)), (min_ph + 1)) //Always ensure we've a window of 1
		determin_ph_range = inoptimal_range_ph
		H_ion_release = (rand(0, 25)/100)// 0 - 0.25

	if(randomize_impurity_minimum)
		purity_min = (rand(0, 4)/10)

	if(randomize_impurity_reagents)
		for(var/rid in required_reagents)
			var/datum/reagent/R = GLOB.chemical_reagents_list[rid]
			R.inverse_chem = get_random_reagent_id()

	if(randomize_results)
		results = list()
		var/list/remaining_possible_results = GetPossibleReagents(RNGCHEM_OUTPUT)
		var/out_reagent_count = min(rand(min_result_reagents,max_result_reagents),remaining_possible_results.len)
		for(var/i in 1 to out_reagent_count)
			var/r_id = pick_n_take(remaining_possible_results)
			results[r_id] = rand(min_output_reagent_amount,max_output_reagent_amount)

	if(randomize_inputs)
		var/list/remaining_possible_reagents = GetPossibleReagents(RNGCHEM_INPUT)
		var/list/remaining_possible_catalysts = GetPossibleReagents(RNGCHEM_CATALYSTS)
		//We're going to assume we're not doing any weird partial reactions for now.
		for(var/reagent_type in results)
			remaining_possible_catalysts -= reagent_type
			remaining_possible_reagents -= reagent_type

		var/in_reagent_count = min(rand(min_input_reagents,max_input_reagents),remaining_possible_reagents.len)
		if(in_reagent_count <= 0)
			return FALSE

		required_reagents = list()
		for(var/i in 1 to in_reagent_count)
			var/r_id = pick_n_take(remaining_possible_reagents)
			required_reagents[r_id] = rand(min_input_reagent_amount,max_input_reagent_amount)
			remaining_possible_catalysts -= r_id //Can't have same reagents both as catalyst and reagent. Or can we ?

		required_catalysts = list()
		var/in_catalyst_count = min(rand(min_catalysts,max_catalysts),remaining_possible_catalysts.len)
		for(var/i in 1 to in_catalyst_count)
			var/r_id = pick_n_take(remaining_possible_catalysts)
			required_catalysts[r_id] = rand(min_input_reagent_amount,max_input_reagent_amount)

	return TRUE

/datum/chemical_reaction/randomized/proc/GetPossibleReagents(kind)
	switch(kind)
		if(RNGCHEM_INPUT)
			return possible_reagents.Copy()
		if(RNGCHEM_CATALYSTS)
			return possible_catalysts.Copy()
		if(RNGCHEM_OUTPUT)
			return possible_results.Copy()

/datum/chemical_reaction/randomized/proc/HasConflicts()
	for(var/x in required_reagents)
		for(var/datum/chemical_reaction/R in GLOB.chemical_reactions_list_reactant_index[x])
			if(chem_recipes_do_conflict(R,src))
				return TRUE
	return FALSE

/datum/chemical_reaction/randomized/proc/unwrap_reagent_list(list/textreagents)
	. = list()
	for(var/R in textreagents)
		var/pathR = text2path(R)
		if(!pathR)
			return null
		.[pathR] = textreagents[R]

/datum/chemical_reaction/randomized/proc/SaveOldRecipe()
	var/recipe_data = list()

	recipe_data["timestamp"] = created
	recipe_data["required_reagents"] = required_reagents
	recipe_data["required_catalysts"] = required_catalysts

	recipe_data["is_cold_recipe"] = is_cold_recipe
	recipe_data["required_temp"] = required_temp
	recipe_data["optimal_temp"] = optimal_temp
	recipe_data["overheat_temp"] = overheat_temp
	recipe_data["thermic_constant"] = thermic_constant

	recipe_data["optimal_ph_min"] = optimal_ph_min
	recipe_data["optimal_ph_max"] = optimal_ph_max
	recipe_data["determin_ph_range"] = determin_ph_range
	recipe_data["H_ion_release"] = H_ion_release

	recipe_data["purity_min"] = purity_min

	recipe_data["results"] = results
	recipe_data["required_container"] = required_container

	return recipe_data

/datum/chemical_reaction/randomized/proc/LoadOldRecipe(recipe_data)
	created = text2num(recipe_data["timestamp"])

	var/req_reag = unwrap_reagent_list(recipe_data["required_reagents"])
	if(!req_reag)
		return FALSE
	required_reagents = req_reag

	var/req_catalysts = unwrap_reagent_list(recipe_data["required_catalysts"])
	if(!req_catalysts)
		return FALSE
	required_catalysts = req_catalysts

	is_cold_recipe = recipe_data["is_cold_recipe"]
	required_temp = recipe_data["required_temp"]
	optimal_temp = recipe_data["optimal_temp"]
	overheat_temp = recipe_data["overheat_temp"]
	thermic_constant = recipe_data["thermic_constant"]

	optimal_ph_min = recipe_data["optimal_ph_min"]
	optimal_ph_max = recipe_data["optimal_ph_max"]
	determin_ph_range = recipe_data["determin_ph_range"]
	H_ion_release = recipe_data["H_ion_release"]

	purity_min = recipe_data["purity_min"]

	var/temp_results = unwrap_reagent_list(recipe_data["results"])
	if(!temp_results)
		return FALSE
	results = temp_results
	var/raw_container_path = recipe_data["required_container"]
	if(raw_container_path)
		var/containerpath = text2path(raw_container_path)
		if(!containerpath)
			return FALSE
		required_container = containerpath
	return TRUE

/datum/chemical_reaction/randomized/secret_sauce
	persistent = TRUE
	persistence_period = 7 //Reset every week
	randomize_container = TRUE
	possible_containers = list(/obj/item/reagent_containers/glass/bucket) //easy way to ensure no common conflicts
	randomize_req_temperature = TRUE
	results = list(/datum/reagent/consumable/secretsauce=1)

/datum/chemical_reaction/randomized/secret_sauce/GetPossibleReagents(kind)
	switch(kind)
		if(RNGCHEM_INPUT,RNGCHEM_CATALYSTS)
			var/food_reagent_ids = list()
			for(var/key in GLOB.food_reagents)
				food_reagent_ids += key
			return food_reagent_ids
	return ..()

///Random recipe for meme chem metalgen. Always requires wittel and resets every 3 days
/datum/chemical_reaction/randomized/metalgen
	persistent = TRUE
	persistence_period = 3 //Resets every three days. It's the ultimate meme and is best not worn out
	randomize_req_temperature = TRUE
	possible_catalysts = list(/datum/reagent/wittel)
	min_catalysts = 1
	max_catalysts = 1
	results = list(/datum/reagent/metalgen=20)

/datum/chemical_reaction/randomized/metalgen/GetPossibleReagents(kind)
	switch(kind)
		if(RNGCHEM_INPUT)
			return GLOB.medicine_reagents
	return ..()

/obj/item/paper/secretrecipe
	name = "old recipe"

	///List of possible recipes we could display
	var/list/possible_recipes = list(/datum/chemical_reaction/randomized/secret_sauce, /datum/chemical_reaction/randomized/metalgen)
	///The one we actually end up displaying
	var/recipe_id = null

/obj/item/paper/secretrecipe/Initialize(mapload)
	. = ..()

	recipe_id = pick(possible_recipes)

	if(SSpersistence.initialized)
		UpdateInfo()
	else
		SSticker.OnRoundstart(CALLBACK(src,.proc/UpdateInfo))

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

/obj/item/paper/secretrecipe/proc/UpdateInfo()
	var/datum/chemical_reaction/recipe = get_chemical_reaction(recipe_id)
	if(!recipe)
		info = "This recipe is illegible."
		return
	var/list/dat = list("<ul>")
	for(var/rid in recipe.required_reagents)
		var/datum/reagent/R = GLOB.chemical_reagents_list[rid]
		dat += "<li>[recipe.required_reagents[rid]]u of [R.name]</li>"
	dat += "</ul>"
	if(recipe.required_catalysts.len)
		dat += "With following present: <ul>"
		for(var/rid in recipe.required_catalysts)
			var/datum/reagent/R = GLOB.chemical_reagents_list[rid]
			dat += "<li>[recipe.required_catalysts[rid]]u of [R.name]</li>"
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
			dat += "<li> taking care of it's exothermic nature</li>"
		else if(recipe.thermic_constant < 0)
			dat += "<li> taking care of it's endothermic nature</li>"
	var/datum/chemical_reaction/randomized/random_recipe = recipe
	if(random_recipe)
		if(random_recipe.randomize_req_ph)
			dat += "<li> keeping your pH between [recipe.optimal_ph_min] and [recipe.optimal_ph_max]</li>"
		if(random_recipe.randomize_impurity_minimum)
			dat += "<li> and your purity above [recipe.purity_min]</li>"
	dat += "</ul>"
	dat += "."
	info = dat.Join("")
	update_appearance()

#undef VALID_RANDOM_RECIPE_REAGENT
