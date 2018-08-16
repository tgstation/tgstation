#define AUTOYLATHE_MAIN_MENU       1
#define AUTOYLATHE_CATEGORY_MENU   2
#define AUTOYLATHE_SEARCH_MENU     3

/obj/machinery/autoylathe
	name = "autoylathe"
	desc = "It produces items using plastic, metal and glass."
	icon_state = "autolathe"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/autoylathe
	var/hacked = FALSE
	var/disabled = FALSE
	var/shocked = FALSE
	var/busy = FALSE
	var/prod_coeff = 1
	var/datum/design/being_built
	var/datum/techweb/stored_research
	var/list/datum/design/matching_designs
	var/selected_category
	var/screen = 1
	var/list/categories = list(
							"Toys",
							"Figurines",
							"Pistols",
							"Rifles",
							"Heavy",
							"Melee",
							"Armor",
							"Adult",
							"Misc",
							"Imported"
							)

/obj/machinery/autoylathe/Initialize()
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_PLASTIC), 0, TRUE, null, null, CALLBACK(src, .proc/AfterMaterialInsert))

	wires = new /datum/wires/autoylathe(src)
	stored_research = new /datum/techweb/specialized/autounlocking/autoylathe
	matching_designs = list()

/obj/machinery/autoylathe/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/autoylathe/interact(mob/user)
	if(!is_operational())
		return

	if(shocked && !(stat & NOPOWER))
		shock(user,50)

	var/dat

	switch(screen)
		if(AUTOYLATHE_MAIN_MENU)
			dat = main_win(user)
		if(AUTOYLATHE_CATEGORY_MENU)
			dat = category_win(user,selected_category)
		if(AUTOYLATHE_SEARCH_MENU)
			dat = search_win(user)

	var/datum/browser/popup = new(user, "Autoylathe", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/autoylathe/on_deconstruction()
	GET_COMPONENT(materials, /datum/component/material_container)
	materials.retrieve_all()

/obj/machinery/autoylathe/attackby(obj/item/O, mob/user, params)
	if (busy)
		to_chat(user, "<span class=\"alert\">The autoylathe is busy. Please wait for completion of previous operation.</span>")
		return TRUE

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", O))
		updateUsrDialog()
		return TRUE

	if(exchange_parts(user, O))
		return TRUE

	if(default_deconstruction_crowbar(O))
		return TRUE

	if(panel_open && is_wire_tool(O))
		wires.interact(user)
		return TRUE

	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()

	if(stat)
		return TRUE

	if(istype(O, /obj/item/disk/design_disk))
		user.visible_message("[user] begins to load \the [O] in \the [src]...",
			"You begin to load a design from \the [O]...",
			"You hear the chatter of a floppy drive.")
		busy = TRUE
		var/obj/item/disk/design_disk/D = O
		if(do_after(user, 14.4, target = src))
			for(var/B in D.blueprints)
				if(B)
					stored_research.add_design(B)
		busy = FALSE
		return TRUE

	return ..()

/obj/machinery/autoylathe/proc/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	if(ispath(type_inserted, /obj/item/stack/ore/bluespace_crystal))
		use_power(amount_inserted / 10)
	else
		switch(id_inserted)
			if (MAT_METAL)
				flick("autolathe_o",src)//plays metal insertion animation
			if (MAT_GLASS)
				flick("autolathe_r",src)//plays glass insertion animation
			if (MAT_PLASTIC)
				flick("autolathe_o",src)//plays metal insertion animation
		use_power(amount_inserted / 10)
	updateUsrDialog()

/obj/machinery/autoylathe/Topic(href, href_list)
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

			/////////////////

			var/coeff = (is_stack ? 1 : prod_coeff) //stacks are unaffected by production coefficient
			var/metal_cost = being_built.materials[MAT_METAL]
			var/glass_cost = being_built.materials[MAT_GLASS]
			var/plastic_cost = being_built.materials[MAT_PLASTIC]
			var/power = max(2000, (metal_cost+glass_cost+plastic_cost)*multiplier/5)

			GET_COMPONENT(materials, /datum/component/material_container)
			if((materials.amount(MAT_METAL) >= metal_cost*multiplier*coeff) && (materials.amount(MAT_GLASS) >= glass_cost*multiplier*coeff) && (materials.amount(MAT_PLASTIC) >= plastic_cost*multiplier*coeff))
				busy = TRUE
				use_power(power)
				icon_state = "autolathe_n"
				var/time = is_stack ? 32 : 32*coeff*multiplier
				addtimer(CALLBACK(src, .proc/make_item, power, metal_cost, glass_cost, plastic_cost, multiplier, coeff, is_stack), time)

		if(href_list["search"])
			matching_designs.Cut()

			for(var/v in stored_research.researched_designs)
				var/datum/design/D = stored_research.researched_designs[v]
				if(findtext(D.name,href_list["to_search"]))
					matching_designs.Add(D)
			updateUsrDialog()
	else
		to_chat(usr, "<span class=\"alert\">The autoylathe is busy. Please wait for completion of previous operation.</span>")

	updateUsrDialog()

	return

/obj/machinery/autoylathe/proc/make_item(power, metal_cost, glass_cost, plastic_cost, multiplier, coeff, is_stack)
	GET_COMPONENT(materials, /datum/component/material_container)
	var/atom/A = drop_location()
	use_power(power)
	var/list/materials_used = list(MAT_METAL=metal_cost*coeff*multiplier, MAT_GLASS=glass_cost*coeff*multiplier, MAT_PLASTIC=plastic_cost*coeff*multiplier)
	materials.use_amount(materials_used)

	if(is_stack)
		var/obj/item/stack/N = new being_built.build_path(A, multiplier)
		N.update_icon()
		N.autoylathe_crafted(src)
	else
		for(var/i=1, i<=multiplier, i++)
			var/obj/item/new_item = new being_built.build_path(A)
			for(var/mat in materials_used)
				new_item.materials[mat] = materials_used[mat] / multiplier
			new_item.autoylathe_crafted(src)
	icon_state = "autolathe"
	busy = FALSE
	updateDialog()

/obj/machinery/autoylathe/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/matter_bin/MB in component_parts)
		T += MB.rating*75000
	GET_COMPONENT(materials, /datum/component/material_container)
	materials.max_amount = T
	T=1.2
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T -= M.rating*0.2
	prod_coeff = CLAMP(T,1,0) // Coeff going 1 -> 0,8 -> 0,6 -> 0,4

/obj/machinery/autoylathe/proc/main_win(mob/user)
	var/dat = "<div class='statusDisplay'><h3>Autoylathe Menu:</h3><br>"
	dat += materials_printout()

	dat += "<form name='search' action='?src=[REF(src)]'>\
	<input type='hidden' name='src' value='[REF(src)]'>\
	<input type='hidden' name='search' value='to_search'>\
	<input type='hidden' name='menu' value='[AUTOYLATHE_SEARCH_MENU]'>\
	<input type='text' name='to_search'>\
	<input type='submit' value='Search'>\
	</form><hr>"

	var/line_length = 1
	dat += "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(line_length > 2)
			dat += "</tr><tr>"
			line_length = 1

		dat += "<td><A href='?src=[REF(src)];category=[C];menu=[AUTOYLATHE_CATEGORY_MENU]'>[C]</A></td>"
		line_length++

	dat += "</tr></table></div>"
	return dat

/obj/machinery/autoylathe/proc/category_win(mob/user,selected_category)
	var/dat = "<A href='?src=[REF(src)];menu=[AUTOYLATHE_MAIN_MENU]'>Return to main menu</A>"
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
			var/max_multiplier = min(D.maxstack, D.materials[MAT_METAL] ?round(materials.amount(MAT_METAL)/D.materials[MAT_METAL]):INFINITY,D.materials[MAT_GLASS] ?round(materials.amount(MAT_GLASS)/D.materials[MAT_GLASS]):INFINITY,D.materials[MAT_PLASTIC] ?round(materials.amount(MAT_PLASTIC)/D.materials[MAT_PLASTIC]):INFINITY)
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

/obj/machinery/autoylathe/proc/search_win(mob/user)
	var/dat = "<A href='?src=[REF(src)];menu=[AUTOYLATHE_MAIN_MENU]'>Return to main menu</A>"
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
			var/max_multiplier = min(D.maxstack, D.materials[MAT_METAL] ?round(materials.amount(MAT_METAL)/D.materials[MAT_METAL]):INFINITY,D.materials[MAT_GLASS] ?round(materials.amount(MAT_GLASS)/D.materials[MAT_GLASS]):INFINITY,D.materials[MAT_PLASTIC] ?round(materials.amount(MAT_PLASTIC)/D.materials[MAT_PLASTIC]):INFINITY)
			if (max_multiplier>10 && !disabled)
				dat += " <a href='?src=[REF(src)];make=[D.id];multiplier=10'>x10</a>"
			if (max_multiplier>25 && !disabled)
				dat += " <a href='?src=[REF(src)];make=[D.id];multiplier=25'>x25</a>"
			if(max_multiplier > 0 && !disabled)
				dat += " <a href='?src=[REF(src)];make=[D.id];multiplier=[max_multiplier]'>x[max_multiplier]</a>"

		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	return dat

/obj/machinery/autoylathe/proc/materials_printout()
	GET_COMPONENT(materials, /datum/component/material_container)
	var/dat = "<b>Total amount:</b> [materials.total_amount] / [materials.max_amount] cm<sup>3</sup><br>"
	for(var/mat_id in materials.materials)
		var/datum/material/M = materials.materials[mat_id]
		dat += "<b>[M.name] amount:</b> [M.amount] cm<sup>3</sup><br>"
	return dat

/obj/machinery/autoylathe/proc/can_build(datum/design/D, amount = 1)
	if(D.make_reagents.len)
		return FALSE

	var/coeff = (ispath(D.build_path, /obj/item/stack) ? 1 : prod_coeff)

	GET_COMPONENT(materials, /datum/component/material_container)
	if(D.materials[MAT_METAL] && (materials.amount(MAT_METAL) < (D.materials[MAT_METAL] * coeff * amount)))
		return FALSE
	if(D.materials[MAT_GLASS] && (materials.amount(MAT_GLASS) < (D.materials[MAT_GLASS] * coeff * amount)))
		return FALSE
	if(D.materials[MAT_PLASTIC] && (materials.amount(MAT_PLASTIC) < (D.materials[MAT_PLASTIC] * coeff * amount)))
		return FALSE
	return TRUE

/obj/machinery/autoylathe/proc/get_design_cost(datum/design/D)
	var/coeff = (ispath(D.build_path, /obj/item/stack) ? 1 : prod_coeff)
	var/dat
	if(D.materials[MAT_METAL])
		dat += "[D.materials[MAT_METAL] * coeff] metal "
	if(D.materials[MAT_GLASS])
		dat += "[D.materials[MAT_GLASS] * coeff] glass "
	if(D.materials[MAT_PLASTIC])
		dat += "[D.materials[MAT_PLASTIC] * coeff] plastic"
	return dat

/obj/machinery/autoylathe/proc/reset(wire)
	switch(wire)
		if(WIRE_HACK)
			if(!wires.is_cut(wire))
				adjust_hacked(FALSE)
		if(WIRE_SHOCK)
			if(!wires.is_cut(wire))
				shocked = FALSE
		if(WIRE_DISABLE)
			if(!wires.is_cut(wire))
				disabled = FALSE

/obj/machinery/autoylathe/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7, TRUE))
		return TRUE
	else
		return FALSE

/obj/machinery/autoylathe/proc/adjust_hacked(state)
	hacked = state
	for(var/id in SSresearch.techweb_designs)
		var/datum/design/D = SSresearch.techweb_designs[id]
		if((D.build_type & AUTOYLATHE) && ("hacked" in D.category))
			if(hacked)
				stored_research.add_design(D)
			else
				stored_research.remove_design(D)

/obj/machinery/autoylathe/hacked/Initialize()
	. = ..()
	adjust_hacked(TRUE)

//Called when the object is constructed by an autoylathe
//Has a reference to the autoylathe so you can do !!FUN!! things with hacked lathes
/obj/item/proc/autoylathe_crafted(obj/machinery/autoylathe/A)
	return
