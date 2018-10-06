/obj/machinery/autolathe/drobelathe
	name = "Autodrobe"
	desc = "It produces clothing using tiny internalized sweatshops."
	icon_state = "autodrobe"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/autolathe
	layer = BELOW_OBJ_LAYER
	machine_name = "autodrobe"
	material_requirements = list(MAT_CLOTH, MAT_DURATHREAD, MAT_LEATHER, MAT_DYE, MAT_PLASTIC)

	categories = list(
							"Colored Jumpsuits",
							"Departmental Uniforms",
							"Hatwear",
							"Masks",
							"Backpacks",
							"Footwear",
							"Gloves",
							"External Wear",
							"Belts",
							"Miscellaneous",
							"Imported"
							)

/obj/machinery/autolathe/drobelathe/Initialize()
	. = ..()
	wires = new /datum/wires/autolathe(src)
	stored_research = new /datum/techweb/specialized/autounlocking/drobelathe
	matching_designs = list()

/obj/machinery/autolathe/drobelathe/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	flick("[machine_name]_o",src)
	use_power(min(1000, amount_inserted / 100))
	updateUsrDialog()

/obj/machinery/autolathe/drobelathe/Topic(href, href_list)
	if(..())
		return
	if (!busy)
		if(href_list["menu"])
			screen = text2num(href_list["menu"])
			updateUsrDialog()

		if(href_list["category"])
			selected_category = href_list["category"]
			updateUsrDialog()

		if(href_list["make"])

			/////////////////
			//href protection
			being_built = stored_research.isDesignResearchedID(href_list["make"])
			if(!being_built)
				return

			var/multiplier = text2num(href_list["multiplier"])
			var/is_stack = ispath(being_built.build_path, /obj/item/stack)
			multiplier = CLAMP(multiplier,1,50)

			/////////////////

			var/coeff = (is_stack ? 1 : prod_coeff) //stacks are unaffected by production coefficient
			var/cloth_cost = being_built.materials[MAT_CLOTH]
			var/durathread_cost = being_built.materials[MAT_DURATHREAD]
			var/leather_cost = being_built.materials[MAT_LEATHER]
			var/dye_cost = being_built.materials[MAT_DYE]
			var/plastic_cost = being_built.materials[MAT_PLASTIC]

			var/power = max(2000, (cloth_cost+durathread_cost+leather_cost+dye_cost+plastic_cost)*multiplier/5)

			GET_COMPONENT(materials, /datum/component/material_container)
			if((materials.amount(MAT_CLOTH) >= cloth_cost*multiplier*coeff) && (materials.amount(MAT_DURATHREAD) >= durathread_cost*multiplier*coeff) && (materials.amount(MAT_LEATHER) >= leather_cost*multiplier*coeff) &&  (materials.amount(MAT_DYE) >= dye_cost*multiplier*coeff) &&  (materials.amount(MAT_PLASTIC) >= plastic_cost*multiplier*coeff))
				busy = TRUE
				use_power(power)
				icon_state = "[machine_name]_n"
				var/time = is_stack ? 32 : 32*coeff*multiplier
				addtimer(CALLBACK(src, .proc/make_clothing, power, cloth_cost, durathread_cost, leather_cost, dye_cost, plastic_cost, multiplier, coeff, is_stack), time)

		if(href_list["search"])
			matching_designs.Cut()

			for(var/v in stored_research.researched_designs)
				var/datum/design/D = stored_research.researched_designs[v]
				if(findtext(D.name,href_list["to_search"]))
					matching_designs.Add(D)
			updateUsrDialog()
	else
		to_chat(usr, "<span class=\"alert\">The [machine_name] is busy. Please wait for completion of previous operation.</span>")

	updateUsrDialog()

	return

/obj/machinery/autolathe/drobelathe/proc/make_clothing(power, cloth_cost, durathread_cost, leather_cost, dye_cost, plastic_cost, multiplier, coeff, is_stack)
	GET_COMPONENT(materials, /datum/component/material_container)
	var/atom/A = drop_location()
	use_power(power)
	var/list/materials_used = list(MAT_CLOTH=cloth_cost*coeff*multiplier, MAT_DURATHREAD=durathread_cost*coeff*multiplier, MAT_LEATHER=leather_cost*coeff*multiplier, MAT_DYE=dye_cost*coeff*multiplier, MAT_PLASTIC=plastic_cost*coeff*multiplier,)
	materials.use_amount(materials_used)

	if(is_stack)
		var/obj/item/stack/N = new being_built.build_path(A, multiplier)
		N.update_icon()
		N.autolathe_crafted(src)
	else
		for(var/i=1, i<=multiplier, i++)
			var/obj/item/new_item = new being_built.build_path(A)
			new_item.materials = new_item.materials.Copy()
			for(var/mat in materials_used)
				new_item.materials[mat] = materials_used[mat] / multiplier
			new_item.autolathe_crafted(src)
	icon_state = "[machine_name]"
	busy = FALSE
	updateDialog()

/obj/machinery/autolathe/drobelathe/category_win(mob/user,selected_category)
	var/dat = "<A href='?src=[REF(src)];menu=[AUTOLATHE_MAIN_MENU]'>Return to main menu</A>"
	dat += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3><br>"
	dat += materials_printout()

	for(var/v in stored_research.researched_designs)
		var/datum/design/D = stored_research.researched_designs[v]
		if(!(selected_category in D.category))
			continue

		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[D.name]</span>"
		else
			dat += "<a href='?src=[REF(src)];make=[D.id];multiplier=1'>[D.name]</a>"

		if(ispath(D.build_path, /obj/item/stack))
			GET_COMPONENT(materials, /datum/component/material_container)
			var/max_multiplier = min(D.maxstack, D.materials[MAT_CLOTH] ?round(materials.amount(MAT_CLOTH)/D.materials[MAT_CLOTH]):INFINITY,D.materials[MAT_DURATHREAD]?round(materials.amount(MAT_DURATHREAD)/D.materials[MAT_DURATHREAD]):INFINITY,D.materials[MAT_LEATHER]?round(materials.amount(MAT_LEATHER)/D.materials[MAT_LEATHER]):INFINITY,D.materials[MAT_DYE]?round(materials.amount(MAT_DYE)/D.materials[MAT_DYE]):INFINITY,D.materials[MAT_PLASTIC]?round(materials.amount(MAT_PLASTIC)/D.materials[MAT_PLASTIC]):INFINITY)
			if (max_multiplier>10 && !disabled)
				dat += " <a href='?src=[REF(src)];make=[D.id];multiplier=10'>x10</a>"
			if (max_multiplier>25 && !disabled)
				dat += " <a href='?src=[REF(src)];make=[D.id];multiplier=25'>x25</a>"
			if(max_multiplier > 0 && !disabled)
				dat += " <a href='?src=[REF(src)];make=[D.id];multiplier=[max_multiplier]'>x[max_multiplier]</a>"
		else
			if(!disabled && can_build(D, 5))
				dat += " <a href='?src=[REF(src)];make=[D.id];multiplier=5'>x5</a>"
			if(!disabled && can_build(D, 10))
				dat += " <a href='?src=[REF(src)];make=[D.id];multiplier=10'>x10</a>"

		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	return dat

/obj/machinery/autolathe/drobelathe/search_win(mob/user)
	var/dat = "<A href='?src=[REF(src)];menu=[AUTOLATHE_MAIN_MENU]'>Return to main menu</A>"
	dat += "<div class='statusDisplay'><h3>Search results:</h3><br>"
	dat += materials_printout()

	for(var/v in matching_designs)
		var/datum/design/D = v
		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[D.name]</span>"
		else
			dat += "<a href='?src=[REF(src)];make=[D.id];multiplier=1'>[D.name]</a>"

		if(ispath(D.build_path, /obj/item/stack))
			GET_COMPONENT(materials, /datum/component/material_container)
			var/max_multiplier = min(D.maxstack, D.materials[MAT_CLOTH] ?round(materials.amount(MAT_CLOTH)/D.materials[MAT_CLOTH]):INFINITY,D.materials[MAT_DURATHREAD]?round(materials.amount(MAT_DURATHREAD)/D.materials[MAT_DURATHREAD]):INFINITY,D.materials[MAT_LEATHER]?round(materials.amount(MAT_LEATHER)/D.materials[MAT_LEATHER]):INFINITY,D.materials[MAT_DYE]?round(materials.amount(MAT_DYE)/D.materials[MAT_DYE]):INFINITY,D.materials[MAT_PLASTIC]?round(materials.amount(MAT_PLASTIC)/D.materials[MAT_PLASTIC]):INFINITY)
			if (max_multiplier>10 && !disabled)
				dat += " <a href='?src=[REF(src)];make=[D.id];multiplier=10'>x10</a>"
			if (max_multiplier>25 && !disabled)
				dat += " <a href='?src=[REF(src)];make=[D.id];multiplier=25'>x25</a>"
			if(max_multiplier > 0 && !disabled)
				dat += " <a href='?src=[REF(src)];make=[D.id];multiplier=[max_multiplier]'>x[max_multiplier]</a>"

		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	return dat

/obj/machinery/autolathe/drobelathe/can_build(datum/design/D, amount = 1)
	if(D.make_reagents.len)
		return FALSE

	var/coeff = (ispath(D.build_path, /obj/item/stack) ? 1 : prod_coeff)

	GET_COMPONENT(materials, /datum/component/material_container)
	if(D.materials[MAT_CLOTH] && (materials.amount(MAT_CLOTH) < (D.materials[MAT_CLOTH] * coeff * amount)))
		return FALSE
	if(D.materials[MAT_DURATHREAD] && (materials.amount(MAT_DURATHREAD) < (D.materials[MAT_DURATHREAD] * coeff * amount)))
		return FALSE
	if(D.materials[MAT_LEATHER] && (materials.amount(MAT_LEATHER) < (D.materials[MAT_LEATHER] * coeff * amount)))
		return FALSE
	if(D.materials[MAT_DYE] && (materials.amount(MAT_DYE) < (D.materials[MAT_DYE] * coeff * amount)))
		return FALSE
	if(D.materials[MAT_PLASTIC] && (materials.amount(MAT_PLASTIC) < (D.materials[MAT_PLASTIC] * coeff * amount)))
		return FALSE
	return TRUE

/obj/machinery/autolathe/drobelathe/get_design_cost(datum/design/D)
	var/coeff = (ispath(D.build_path, /obj/item/stack) ? 1 : prod_coeff)
	var/dat
	if(D.materials[MAT_CLOTH])
		dat += "[D.materials[MAT_CLOTH] * coeff] Cloth"
	if(D.materials[MAT_DURATHREAD])
		dat += "[D.materials[MAT_DURATHREAD] * coeff] Durathread"
	if(D.materials[MAT_LEATHER])
		dat += "[D.materials[MAT_LEATHER] * coeff] Leather"
	if(D.materials[MAT_DYE])
		dat += "[D.materials[MAT_DYE] * coeff] Dye"
	if(D.materials[MAT_PLASTIC])
		dat += "[D.materials[MAT_PLASTIC] * coeff] Plastic"
	return dat

/obj/machinery/autolathe/drobelathe/adjust_hacked(state)
	hacked = state
	for(var/id in SSresearch.techweb_designs)
		var/datum/design/D = SSresearch.techweb_designs[id]
		if((D.build_type & DROBELATHE) && ("hacked" in D.category))
			if(hacked)
				stored_research.add_design(D)
			else
				stored_research.remove_design(D)

/obj/machinery/autolathe/drobelathe/hacked/Initialize()
	. = ..()
	adjust_hacked(TRUE)
