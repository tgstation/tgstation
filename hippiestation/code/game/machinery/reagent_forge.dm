/obj/machinery/reagent_forge
	name = "material forge"
	desc = "A bulky machine that can smelt practically any material in existence."
	icon = 'hippiestation/icons/obj/3x3.dmi'
	icon_state = "arc_forge"
	bound_width = 96
	bound_height = 96
	anchored = TRUE
	max_integrity = 1000
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 3000
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	circuit = null
	light_range = 5
	light_power = 1.5
	light_color = LIGHT_COLOR_FIRE
	var/datum/reagent/currently_forging//forge one mat at a time
	var/processing = FALSE
	var/efficiency = 1
	var/datum/techweb/stored_research


/obj/machinery/reagent_forge/Initialize()
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_REAGENT), 200000)
	stored_research = new /datum/techweb/specialized/autounlocking/reagent_forge


/obj/machinery/reagent_forge/attackby(obj/item/I, mob/user)

	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/sheet/mineral/reagent))
		var/obj/item/stack/sheet/mineral/reagent/R = I

		if(!in_range(src, R) || !user.Adjacent(src))
			return

		if(panel_open)
			to_chat(user, "<span class='warning'>You can't load the [src.name] while it's opened!</span>")
			return

		if(R.reagent_type)
			if(!currently_forging || !currently_forging.id)
				GET_COMPONENT(materials, /datum/component/material_container)
				if(R.amount <= 0)//this shouldn't exist
					to_chat(user, "<span class='warning'>The sheet crumbles away into dust, perhaps it was a fake one?</span>")
					qdel(R)
					return FALSE
				materials.insert_stack(R, R.amount)
				to_chat(user, "<span class='notice'>You add [R] to [src]</span>")
				currently_forging = new R.reagent_type.type
				return

			if(currently_forging && currently_forging.id && R.reagent_type.id == currently_forging.id)//preventing unnecessary references from being made
				GET_COMPONENT(materials, /datum/component/material_container)
				materials.insert_stack(R, R.amount)
				to_chat(user, "<span class='notice'>You add [R] to [src]</span>")
				return
			else
				to_chat(user, "<span class='notice'>[currently_forging] is currently being forged, either remove or use it before adding a different material</span>")//if null is currently being forged comes up i'm gonna scree
				return

	else
		to_chat(user, "<span class='alert'>[src] rejects the [I]</span>")


/obj/machinery/reagent_forge/proc/check_cost(materials, using)
	GET_COMPONENT(ourmaterials, /datum/component/material_container)

	if(ourmaterials.amount(MAT_REAGENT) <= 0)
		qdel(currently_forging)
		currently_forging = null
		return FALSE

	if(!materials)
		return FALSE

	if(materials*efficiency > ourmaterials.amount(MAT_REAGENT))
		return FALSE
	else
		if(using)
			var/list/materials_used = list(MAT_REAGENT=materials*efficiency)
			ourmaterials.use_amount(materials_used)
		return TRUE


/obj/machinery/reagent_forge/proc/create_product(datum/design/D, amount, mob/user)
	if(!loc)
		return FALSE

	for(var/i in 1 to amount)
		if(!check_cost(D.materials[MAT_REAGENT], TRUE))
			visible_message("<span class='warning'>The low material indicator flashes on [src]!</span>")
			playsound(src, 'sound/machines/buzz-two.ogg', 60, 0)
			return FALSE

		if(D.build_path)
			var/atom/A = new D.build_path(user.loc)
			if(currently_forging)
				if(istype(D, /datum/design/forge))
					var/obj/item/forged/F = A
					var/paths = subtypesof(/datum/reagent)
					for(var/path in paths)
						var/datum/reagent/RR = new path
						if(RR.id == currently_forging.id)
							F.reagent_type = RR
							F.assign_properties()
							break
						else
							qdel(RR)
		. = TRUE
	update_icon()
	return .


/obj/machinery/reagent_forge/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "chem_reagent_forge", name, 400, 570, master_ui, state)
		ui.open()


/obj/machinery/reagent_forge/ui_data(mob/user)
	var/list/listofrecipes = list()
	var/list/data = list()
	var/lowest_cost = 1

	for(var/V in stored_research.researched_designs)
		var/datum/design/forge/D = stored_research.researched_designs[V]
		var/md5name = md5(D.name)
		var/cost = D.materials[MAT_REAGENT]*efficiency
		if(!listofrecipes[md5name])
			listofrecipes[md5name] = list("name" = D.name, "category" = D.category[2], "cost" = cost)
			if(cost < lowest_cost)
				lowest_cost = cost
	sortList(listofrecipes)

	GET_COMPONENT(materials, /datum/component/material_container)
	data["recipes"] = listofrecipes
	data["currently_forging"] = currently_forging ? currently_forging : "Nothing"
	data["material_amount"] = materials.amount(MAT_REAGENT)
	data["can_afford"] = check_cost(lowest_cost, FALSE)
	return data


/obj/machinery/reagent_forge/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("Create")
			var/amount = 0
			amount = input("How many?", "How many would you like to forge?", 1) as null|num
			if(amount <= 0)
				return FALSE

			for(var/V in stored_research.researched_designs)
				var/datum/design/forge/D = stored_research.researched_designs[V]
				if(D.name == params["name"])
					create_product(D, amount, usr)
					return TRUE

		if("Dump")
			if(currently_forging)
				GET_COMPONENT(materials, /datum/component/material_container)
				var/amount = materials.amount(MAT_REAGENT)
				if(amount > 0)
					var/list/materials_used = list(MAT_REAGENT=amount)
					materials.use_amount(materials_used)
					var/obj/item/stack/sheet/mineral/reagent/RS = new(get_turf(usr))
					RS.amount = materials.amount2sheet(amount)
					var/paths = subtypesof(/datum/reagent)//one reference per stack

					for(var/path in paths)
						var/datum/reagent/RR = new path
						if(RR.id == currently_forging.id)
							RS.reagent_type = RR
							RS.name = "[RR.name] ingots"
							RS.singular_name = "[RR.name] ingot"
							RS.add_atom_colour(RR.color, FIXED_COLOUR_PRIORITY)
							to_chat(usr, "<span class='notice'>You remove the [RS.name] from [src]</span>")
							break
						else
							qdel(RR)
			qdel(currently_forging)
			currently_forging = null
			return TRUE

	return FALSE