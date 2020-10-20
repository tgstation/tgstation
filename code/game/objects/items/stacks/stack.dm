/* Stack type objects!
 * Contains:
 * 		Stacks
 * 		Recipe datum
 * 		Recipe list datum
 */

/*
 * Stacks
 */

/obj/item/stack
	icon = 'icons/obj/stack_objects.dmi'
	gender = PLURAL
	material_modifier = 0.05 //5%, so that a 50 sheet stack has the effect of 5k materials instead of 100k.
	max_integrity = 100
	var/list/datum/stack_recipe/recipes
	var/singular_name
	var/amount = 1
	var/max_amount = 50 //also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/is_cyborg = 0 // It's 1 if module is used by a cyborg, and uses its storage
	var/datum/robot_energy_storage/source
	var/cost = 1 // How much energy from storage it costs
	var/merge_type = null // This path and its children should merge with this stack, defaults to src.type
	var/full_w_class = WEIGHT_CLASS_NORMAL //The weight class the stack should have at amount > 2/3rds max_amount
	var/novariants = TRUE //Determines whether the item should update it's sprites based on amount.
	var/list/mats_per_unit //list that tells you how much is in a single unit.
	///Datum material type that this stack is made of
	var/material_type
	//NOTE: When adding grind_results, the amounts should be for an INDIVIDUAL ITEM - these amounts will be multiplied by the stack size in on_grind()
	var/obj/structure/table/tableVariant // we tables now (stores table variant to be built from this stack)

		// The following are all for medical treatment, they're here instead of /stack/medical because sticky tape can be used as a makeshift bandage or splint
	/// If set and this used as a splint for a broken bone wound, this is used as a multiplier for applicable slowdowns (lower = better) (also for speeding up burn recoveries)
	var/splint_factor
	/// How much blood flow this stack can absorb if used as a bandage on a cut wound, note that absorption is how much we lower the flow rate, not the raw amount of blood we suck up
	var/absorption_capacity
	/// How quickly we lower the blood flow on a cut wound we're bandaging. Expected lifetime of this bandage in ticks is thus absorption_capacity/absorption_rate, or until the cut heals, whichever comes first
	var/absorption_rate
	/// Amount of matter for RCD
	var/matter_amount = 0

/obj/item/stack/on_grind()
	for(var/i in 1 to grind_results.len) //This should only call if it's ground, so no need to check if grind_results exists
		grind_results[grind_results[i]] *= get_amount() //Gets the key at position i, then the reagent amount of that key, then multiplies it by stack size

/obj/item/stack/grind_requirements()
	if(is_cyborg)
		to_chat(usr, "<span class='warning'>[src] is electronically synthesized in your chassis and can't be ground up!</span>")
		return
	return TRUE

/obj/item/stack/Initialize(mapload, new_amount, merge = TRUE)
	if(new_amount != null)
		amount = new_amount
	while(amount > max_amount)
		amount -= max_amount
		new type(loc, max_amount, FALSE)
	if(!merge_type)
		merge_type = type
	if(custom_materials?.len)
		mats_per_unit = list()
		var/in_process_mat_list = custom_materials.Copy()
		for(var/i in custom_materials)
			mats_per_unit[SSmaterials.GetMaterialRef(i)] = in_process_mat_list[i]
			custom_materials[i] *= amount
	. = ..()
	if(merge)
		for(var/obj/item/stack/S in loc)
			if(S.merge_type == merge_type)
				INVOKE_ASYNC(src, .proc/merge, S)
	var/list/temp_recipes = get_main_recipes()
	recipes = temp_recipes.Copy()
	if(material_type)
		var/datum/material/M = SSmaterials.GetMaterialRef(material_type) //First/main material
		for(var/i in M.categories)
			switch(i)
				if(MAT_CATEGORY_BASE_RECIPES)
					var/list/temp = SSmaterials.base_stack_recipes.Copy()
					recipes += temp
				if(MAT_CATEGORY_RIGID)
					var/list/temp = SSmaterials.rigid_stack_recipes.Copy()
					recipes += temp
	update_weight()
	update_icon()

/obj/item/stack/proc/get_main_recipes()
	SHOULD_CALL_PARENT(TRUE)
	return list()//empty list

/obj/item/stack/proc/update_weight()
	if(amount <= (max_amount * (1/3)))
		w_class = clamp(full_w_class-2, WEIGHT_CLASS_TINY, full_w_class)
	else if (amount <= (max_amount * (2/3)))
		w_class = clamp(full_w_class-1, WEIGHT_CLASS_TINY, full_w_class)
	else
		w_class = full_w_class

/obj/item/stack/update_icon_state()
	if(novariants)
		return
	if(amount <= (max_amount * (1/3)))
		icon_state = initial(icon_state)
	else if (amount <= (max_amount * (2/3)))
		icon_state = "[initial(icon_state)]_2"
	else
		icon_state = "[initial(icon_state)]_3"

/obj/item/stack/examine(mob/user)
	. = ..()
	if (is_cyborg)
		if(singular_name)
			. += "There is enough energy for [get_amount()] [singular_name]\s."
		else
			. += "There is enough energy for [get_amount()]."
		return
	if(singular_name)
		if(get_amount()>1)
			. += "There are [get_amount()] [singular_name]\s in the stack."
		else
			. += "There is [get_amount()] [singular_name] in the stack."
	else if(get_amount()>1)
		. += "There are [get_amount()] in the stack."
	else
		. += "There is [get_amount()] in the stack."
	. += "<span class='notice'>Alt-click to take a custom amount.</span>"

/obj/item/stack/proc/get_amount()
	if(is_cyborg)
		. = round(source?.energy / cost)
	else
		. = (amount)

/**
  * Builds all recipes in a given recipe list and returns an association list containing them
  *
  * Arguments:
  * * recipe_to_iterate - The list of recipes we are using to build recipes
  */
/obj/item/stack/proc/recursively_build_recipes(list/recipe_to_iterate)
	var/list/L = list()
	for(var/recipe in recipe_to_iterate)
		if(istype(recipe, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/R = recipe
			L["[R.title]"] = recursively_build_recipes(R.recipes)
		if(istype(recipe, /datum/stack_recipe))
			var/datum/stack_recipe/R = recipe
			L["[R.title]"] = build_recipe(R)
	return L

/**
  * Returns a list of properties of a given recipe
  *
  * Arguments:
  * * R - The stack recipe we are using to get a list of properties
  */
/obj/item/stack/proc/build_recipe(datum/stack_recipe/R)
	return list(
		"res_amount" = R.res_amount,
		"max_res_amount" = R.max_res_amount,
		"req_amount" = R.req_amount,
		"ref" = "\ref[R]",
	)

/**
  * Checks if the recipe is valid to be used
  *
  * Arguments:
  * * R - The stack recipe we are checking if it is valid
  * * recipe_list - The list of recipes we are using to check the given recipe
  */
/obj/item/stack/proc/is_valid_recipe(datum/stack_recipe/R, list/recipe_list)
	for(var/S in recipe_list)
		if(S == R)
			return TRUE
		if(istype(S, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/L = S
			if(is_valid_recipe(R, L.recipes))
				return TRUE
	return FALSE

/obj/item/stack/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/stack/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Stack", name)
		ui.open()

/obj/item/stack/ui_data(mob/user)
	var/list/data = list()
	data["amount"] = get_amount()
	return data

/obj/item/stack/ui_static_data(mob/user)
	var/list/data = list()
	data["recipes"] = recursively_build_recipes(recipes)
	return data

/obj/item/stack/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("make")
			if(get_amount() < 1 && !is_cyborg)
				qdel(src)
				return
			var/datum/stack_recipe/R = locate(params["ref"])
			if(!is_valid_recipe(R, recipes)) //href exploit protection
				return
			var/multiplier = text2num(params["multiplier"])
			if(!multiplier || (multiplier <= 0)) //href exploit protection
				return
			if(!building_checks(R, multiplier))
				return
			if(R.time)
				var/adjusted_time = 0
				usr.visible_message("<span class='notice'>[usr] starts building \a [R.title].</span>", "<span class='notice'>You start building \a [R.title]...</span>")
				if(HAS_TRAIT(usr, R.trait_booster))
					adjusted_time = (R.time * R.trait_modifier)
				else
					adjusted_time = R.time
				if(!do_after(usr, adjusted_time, target = usr))
					return
				if(!building_checks(R, multiplier))
					return

			var/obj/O
			if(R.max_res_amount > 1) //Is it a stack?
				O = new R.result_type(usr.drop_location(), R.res_amount * multiplier)
			else if(ispath(R.result_type, /turf))
				var/turf/T = usr.drop_location()
				if(!isturf(T))
					return
				T.PlaceOnTop(R.result_type, flags = CHANGETURF_INHERIT_AIR)
			else
				O = new R.result_type(usr.drop_location())
			if(O)
				O.setDir(usr.dir)
			use(R.req_amount * multiplier)

			if(R.applies_mats && custom_materials?.len)
				var/list/used_materials = list()
				for(var/i in custom_materials)
					used_materials[SSmaterials.GetMaterialRef(i)] = R.req_amount / R.res_amount * (MINERAL_MATERIAL_AMOUNT / custom_materials.len)
				O.set_custom_materials(used_materials)

			if(istype(O, /obj/structure/windoor_assembly))
				var/obj/structure/windoor_assembly/W = O
				W.ini_dir = W.dir
			else if(istype(O, /obj/structure/window))
				var/obj/structure/window/W = O
				W.ini_dir = W.dir

			if(QDELETED(O))
				return //It's a stack and has already been merged

			if(isitem(O))
				usr.put_in_hands(O)
			O.add_fingerprint(usr)

			//BubbleWrap - so newly formed boxes are empty
			if(istype(O, /obj/item/storage))
				for (var/obj/item/I in O)
					qdel(I)
			//BubbleWrap END
			return TRUE

/obj/item/stack/vv_edit_var(vname, vval)
	if(vname == NAMEOF(src, amount))
		add(clamp(vval, 1-amount, max_amount - amount)) //there must always be one.
		return TRUE
	else if(vname == NAMEOF(src, max_amount))
		max_amount = max(vval, 1)
		add((max_amount < amount) ? (max_amount - amount) : 0) //update icon, weight, ect
		return TRUE
	return ..()

/obj/item/stack/proc/building_checks(datum/stack_recipe/R, multiplier)
	if (get_amount() < R.req_amount*multiplier)
		if (R.req_amount*multiplier>1)
			to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [R.req_amount*multiplier] [R.title]\s!</span>")
		else
			to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [R.title]!</span>")
		return FALSE
	var/turf/T = get_turf(usr)

	var/obj/D = R.result_type
	if(R.window_checks && !valid_window_location(T, initial(D.dir) == FULLTILE_WINDOW_DIR ? FULLTILE_WINDOW_DIR : usr.dir))
		to_chat(usr, "<span class='warning'>The [R.title] won't fit here!</span>")
		return FALSE
	if(R.one_per_turf && (locate(R.result_type) in T))
		to_chat(usr, "<span class='warning'>There is another [R.title] here!</span>")
		return FALSE
	if(R.on_floor)
		if(!isfloorturf(T))
			to_chat(usr, "<span class='warning'>\The [R.title] must be constructed on the floor!</span>")
			return FALSE
		for(var/obj/AM in T)
			if(istype(AM,/obj/structure/grille))
				continue
			if(istype(AM,/obj/structure/table))
				continue
			if(istype(AM,/obj/structure/window))
				var/obj/structure/window/W = AM
				if(!W.fulltile)
					continue
			if(AM.density)
				to_chat(usr, "<span class='warning'>Theres a [AM.name] here. You cant make a [R.title] here!</span>")
				return FALSE
	if(R.placement_checks)
		switch(R.placement_checks)
			if(STACK_CHECK_CARDINALS)
				var/turf/step
				for(var/direction in GLOB.cardinals)
					step = get_step(T, direction)
					if(locate(R.result_type) in step)
						to_chat(usr, "<span class='warning'>\The [R.title] must not be built directly adjacent to another!</span>")
						return FALSE
			if(STACK_CHECK_ADJACENT)
				if(locate(R.result_type) in range(1, T))
					to_chat(usr, "<span class='warning'>\The [R.title] must be constructed at least one tile away from others of its type!</span>")
					return FALSE
	return TRUE

/obj/item/stack/use(used, transfer = FALSE, check = TRUE) // return 0 = borked; return 1 = had enough
	if(check && zero_amount())
		return FALSE
	if (is_cyborg)
		return source.use_charge(used * cost)
	if (amount < used)
		return FALSE
	amount -= used
	if(check && zero_amount())
		return TRUE
	if(length(mats_per_unit))
		var/temp_materials = custom_materials.Copy()
		for(var/i in mats_per_unit)
			temp_materials[i] = mats_per_unit[i] * src.amount
		set_custom_materials(temp_materials)
	update_icon()
	update_weight()
	return TRUE

/obj/item/stack/tool_use_check(mob/living/user, amount)
	if(get_amount() < amount)
		if(singular_name)
			if(amount > 1)
				to_chat(user, "<span class='warning'>You need at least [amount] [singular_name]\s to do this!</span>")
			else
				to_chat(user, "<span class='warning'>You need at least [amount] [singular_name] to do this!</span>")
		else
			to_chat(user, "<span class='warning'>You need at least [amount] to do this!</span>")

		return FALSE

	return TRUE

/obj/item/stack/proc/zero_amount()
	if(is_cyborg)
		return source.energy < cost
	if(amount < 1)
		qdel(src)
		return TRUE
	return FALSE

/obj/item/stack/proc/add(amount)
	if (is_cyborg)
		source.add_charge(amount * cost)
	else
		src.amount += amount
	if(length(mats_per_unit))
		var/temp_materials = custom_materials.Copy()
		for(var/i in mats_per_unit)
			temp_materials[i] = mats_per_unit[i] * src.amount
		set_custom_materials(temp_materials)
	update_icon()
	update_weight()

/obj/item/stack/proc/merge(obj/item/stack/S) //Merge src into S, as much as possible
	if(QDELETED(S) || QDELETED(src) || S == src) //amusingly this can cause a stack to consume itself, let's not allow that.
		return
	var/transfer = get_amount()
	if(S.is_cyborg)
		transfer = min(transfer, round((S.source.max_energy - S.source.energy) / S.cost))
	else
		transfer = min(transfer, S.max_amount - S.amount)
	if(pulledby)
		pulledby.start_pulling(S)
	S.copy_evidences(src)
	use(transfer, TRUE)
	S.add(transfer)
	return transfer

/obj/item/stack/Crossed(atom/movable/AM)
	if(istype(AM, merge_type) && !AM.throwing)
		merge(AM)
	. = ..()

/obj/item/stack/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(istype(AM, merge_type))
		merge(AM)
	. = ..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/stack/attack_hand(mob/user)
	if(user.get_inactive_held_item() == src)
		if(zero_amount())
			return
		return change_stack(user,1)
	else
		. = ..()

/obj/item/stack/AltClick(mob/living/user)
	. = ..()
	if(isturf(loc)) // to prevent people that are alt clicking a tile to see its content from getting undesidered pop ups
		return
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	if(is_cyborg)
		return
	else
		if(zero_amount())
			return
		//get amount from user
		var/max = get_amount()
		var/stackmaterial = round(input(user,"How many sheets do you wish to take out of this stack? (Maximum  [max])") as null|num)
		max = get_amount()
		stackmaterial = min(max, stackmaterial)
		if(stackmaterial == null || stackmaterial <= 0 || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
			return
		else
			change_stack(user, stackmaterial)
			to_chat(user, "<span class='notice'>You take [stackmaterial] sheets out of the stack.</span>")

/obj/item/stack/proc/change_stack(mob/user, amount)
	if(!use(amount, TRUE, FALSE))
		return FALSE
	var/obj/item/stack/F = new type(user? user : drop_location(), amount, FALSE)
	. = F
	F.copy_evidences(src)
	if(user)
		if(!user.put_in_hands(F, merge_stacks = FALSE))
			F.forceMove(user.drop_location())
		add_fingerprint(user)
		F.add_fingerprint(user)
	zero_amount()

/obj/item/stack/attackby(obj/item/W, mob/user, params)
	if(istype(W, merge_type))
		var/obj/item/stack/S = W
		if(merge(S))
			to_chat(user, "<span class='notice'>Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s.</span>")
	else
		. = ..()

/obj/item/stack/proc/copy_evidences(obj/item/stack/from)
	add_blood_DNA(from.return_blood_DNA())
	add_fingerprint_list(from.return_fingerprints())
	add_hiddenprint_list(from.return_hiddenprints())
	fingerprintslast  = from.fingerprintslast
	//TODO bloody overlay

/obj/item/stack/microwave_act(obj/machinery/microwave/M)
	if(istype(M) && M.dirty < 100)
		M.dirty += amount

/*
 * Recipe datum
 */
/datum/stack_recipe
	var/title = "ERROR"
	var/result_type
	var/req_amount = 1
	var/res_amount = 1
	var/max_res_amount = 1
	var/time = 0
	var/one_per_turf = FALSE
	var/on_floor = FALSE
	var/window_checks = FALSE
	var/placement_checks = FALSE
	var/applies_mats = FALSE
	var/trait_booster = null
	var/trait_modifier = 1

/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1,time = 0, one_per_turf = FALSE, on_floor = FALSE, window_checks = FALSE, placement_checks = FALSE, applies_mats = FALSE, trait_booster = null, trait_modifier = 1)


	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_floor = on_floor
	src.window_checks = window_checks
	src.placement_checks = placement_checks
	src.applies_mats = applies_mats
	src.trait_booster = trait_booster
	src.trait_modifier = trait_modifier
/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes

/datum/stack_recipe_list/New(title, recipes)
	src.title = title
	src.recipes = recipes
