#define AUTOLATHE_MAIN_MENU       1
#define AUTOLATHE_CATEGORY_MENU   2
#define AUTOLATHE_SEARCH_MENU     3

/obj/machinery/autolathe
	name = "autolathe"
	desc = "It produces items using metal and glass."
	icon_state = "autolathe"
	density = 1

	var/operating = 0
	anchored = 1
	var/list/L = list()
	var/list/LL = list()
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/hack_wire
	var/disable_wire
	var/shock_wire
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100
	var/busy = 0
	var/prod_coeff

	var/datum/design/being_built
	var/datum/research/files
	var/list/datum/design/matching_designs
	var/selected_category
	var/screen = 1

	var/datum/material_container/materials

	var/list/categories = list(
							"Tools",
							"Electronics",
							"Construction",
							"T-Comm",
							"Security",
							"Machinery",
							"Medical",
							"Misc",
							"Imported"
							)

/obj/machinery/autolathe/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/autolathe(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	materials = new /datum/material_container(src, list(MAT_METAL=1, MAT_GLASS=1))
	RefreshParts()

	wires = new /datum/wires/autolathe(src)
	files = new /datum/research/autolathe(src)
	matching_designs = list()

/obj/machinery/autolathe/Destroy()
	qdel(wires)
	wires = null
	qdel(materials)
	materials = null
	return ..()

/obj/machinery/autolathe/interact(mob/user)
	if(!is_operational())
		return

	if(shocked && !(stat & NOPOWER))
		shock(user,50)

	var/dat

	switch(screen)
		if(AUTOLATHE_MAIN_MENU)
			dat = main_win(user)
		if(AUTOLATHE_CATEGORY_MENU)
			dat = category_win(user,selected_category)
		if(AUTOLATHE_SEARCH_MENU)
			dat = search_win(user)

	var/datum/browser/popup = new(user, "autolathe", name, 400, 500)
	popup.set_content(dat)
	popup.open()

	return

/obj/machinery/autolathe/attackby(obj/item/O, mob/user, params)
	if (busy)
		user << "<span class=\"alert\">The autolathe is busy. Please wait for completion of previous operation.</span>"
		return 1

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", O))
		updateUsrDialog()
		return

	if(exchange_parts(user, O))
		return

	if(panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			materials.retrieve_all()
			default_deconstruction_crowbar(O)
			return 1
		else if(is_wire_tool(O))
			wires.interact(user)
			return 1
	if(stat)
		return 1

	if(istype(O, /obj/item/weapon/disk/design_disk))
		user.visible_message("[user] begins to load \the [O] in \the [src]...",
			"You begin to load a design from \the [O]...",
			"You hear the chatter of a floppy drive.")
		busy = 1
		var/obj/item/weapon/disk/design_disk/D = O
		if(do_after(user, 14.4, target = src))
			files.AddDesign2Known(D.blueprint)

		busy = 0
		return

	var/material_amount = materials.get_item_material_amount(O)
	if(!material_amount)
		user << "<span class='warning'>This object does not contain sufficient amounts of metal or glass to be accepted by the autolathe.</span>"
		return 1
	if(!materials.has_space(material_amount))
		user << "<span class='warning'>The autolathe is full. Please remove metal or glass from the autolathe in order to insert more.</span>"
		return 1
	if(!user.unEquip(O))
		user << "<span class='warning'>\The [O] is stuck to you and cannot be placed into the autolathe.</span>"
		return 1

	busy = 1
	var/inserted = materials.insert_item(O)
	if(inserted)
		if(istype(O,/obj/item/stack))
			if (O.materials[MAT_METAL])
				flick("autolathe_o",src)//plays metal insertion animation
			if (O.materials[MAT_GLASS])
				flick("autolathe_r",src)//plays glass insertion animation
			user << "<span class='notice'>You insert [inserted] sheet[inserted>1 ? "s" : ""] to the autolathe.</span>"
			use_power(inserted*100)
		else
			user << "<span class='notice'>You insert a material total of [inserted] to the autolathe.</span>"
			use_power(max(500,inserted/10))
			qdel(O)
	busy = 0
	src.updateUsrDialog()

/obj/machinery/autolathe/Topic(href, href_list)
	if(..())
		return
	if (!busy)
		if(href_list["menu"])
			screen = text2num(href_list["menu"])

		if(href_list["category"])
			selected_category = href_list["category"]

		if(href_list["make"])

			var/turf/T = loc

			/////////////////
			//href protection
			being_built = files.FindDesignByID(href_list["make"]) //check if it's a valid design
			if(!being_built)
				return

			//multiplier checks : only stacks can have one and its value is 1, 10 ,25 or max_multiplier
			var/multiplier = text2num(href_list["multiplier"])
			var/max_multiplier = min(being_built.maxstack, being_built.materials[MAT_METAL] ?round(materials.amount(MAT_METAL)/being_built.materials[MAT_METAL]):INFINITY,being_built.materials[MAT_GLASS]?round(materials.amount(MAT_GLASS)/being_built.materials[MAT_GLASS]):INFINITY)
			var/is_stack = ispath(being_built.build_path, /obj/item/stack)

			if(!is_stack && (multiplier > 1))
				return
			if (!(multiplier in list(1,10,25,max_multiplier))) //"enough materials ?" is checked further down
				return
			/////////////////

			var/coeff = (is_stack ? 1 : 2 ** prod_coeff) //stacks are unaffected by production coefficient
			var/metal_cost = being_built.materials[MAT_METAL]
			var/glass_cost = being_built.materials[MAT_GLASS]

			var/power = max(2000, (metal_cost+glass_cost)*multiplier/5)

			if((materials.amount(MAT_METAL) >= metal_cost*multiplier/coeff) && (materials.amount(MAT_GLASS) >= glass_cost*multiplier/coeff))
				busy = 1
				use_power(power)
				icon_state = "autolathe"
				flick("autolathe_n",src)
				spawn(32/coeff)
					use_power(power)
					if(is_stack)
						var/list/materials_used = list(MAT_METAL=metal_cost*multiplier, MAT_GLASS=glass_cost*multiplier)
						materials.use_amount(materials_used)

						var/obj/item/stack/N = new being_built.build_path(T, multiplier)
						N.update_icon()
						N.autolathe_crafted(src)

						for(var/obj/item/stack/S in T.contents - N)
							if(istype(S, N.merge_type))
								N.merge(S)
					else
						var/list/materials_used = list(MAT_METAL=metal_cost/coeff, MAT_GLASS=glass_cost/coeff)
						materials.use_amount(materials_used)
						var/obj/item/new_item = new being_built.build_path(T)
						new_item.materials = materials_used.Copy()
						new_item.autolathe_crafted(src)
					busy = 0
					src.updateUsrDialog()

		if(href_list["search"])
			matching_designs.Cut()

			for(var/v in files.known_designs)
				var/datum/design/D = files.known_designs[v]
				if(findtext(D.name,href_list["to_search"]))
					matching_designs.Add(D)
	else
		usr << "<span class=\"alert\">The autolathe is busy. Please wait for completion of previous operation.</span>"

	src.updateUsrDialog()

	return

/obj/machinery/autolathe/RefreshParts()
	var/tot_rating = 0
	prod_coeff = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
		tot_rating += MB.rating
	tot_rating *= 25000
	materials.max_amount = tot_rating * 3
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		prod_coeff += M.rating - 1

/obj/machinery/autolathe/proc/main_win(mob/user)
	var/dat = "<div class='statusDisplay'><h3>Autolathe Menu:</h3><br>"
	dat += "<b>Total amount:</b> [materials.total_amount] / [materials.max_amount] cm<sup>3</sup><br>"
	dat += "<b>Metal amount:</b> [materials.amount(MAT_METAL)] cm<sup>3</sup><br>"
	dat += "<b>Glass amount:</b> [materials.amount(MAT_GLASS)] cm<sup>3</sup><br>"

	dat += "<form name='search' action='?src=\ref[src]'>\
	<input type='hidden' name='src' value='\ref[src]'>\
	<input type='hidden' name='search' value='to_search'>\
	<input type='hidden' name='menu' value='[AUTOLATHE_SEARCH_MENU]'>\
	<input type='text' name='to_search'>\
	<input type='submit' value='Search'>\
	</form><hr>"

	var/line_length = 1
	dat += "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(line_length > 2)
			dat += "</tr><tr>"
			line_length = 1

		dat += "<td><A href='?src=\ref[src];category=[C];menu=[AUTOLATHE_CATEGORY_MENU]'>[C]</A></td>"
		line_length++

	dat += "</tr></table></div>"
	return dat

/obj/machinery/autolathe/proc/category_win(mob/user,selected_category)
	var/dat = "<A href='?src=\ref[src];menu=[AUTOLATHE_MAIN_MENU]'>Return to main menu</A>"
	dat += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3><br>"
	dat += "<b>Total amount:</b> [materials.total_amount] / [materials.max_amount] cm<sup>3</sup><br>"
	dat += "<b>Metal amount:</b> [materials.amount(MAT_METAL)] cm<sup>3</sup><br>"
	dat += "<b>Glass amount:</b> [materials.amount(MAT_GLASS)] cm<sup>3</sup><br>"

	for(var/v in files.known_designs)
		var/datum/design/D = files.known_designs[v]
		if(!(selected_category in D.category))
			continue

		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[D.name]</span>"
		else
			dat += "<a href='?src=\ref[src];make=[D.id];multiplier=1'>[D.name]</a>"

		if(ispath(D.build_path, /obj/item/stack))
			var/max_multiplier = min(D.maxstack, D.materials[MAT_METAL] ?round(materials.amount(MAT_METAL)/D.materials[MAT_METAL]):INFINITY,D.materials[MAT_GLASS]?round(materials.amount(MAT_GLASS)/D.materials[MAT_GLASS]):INFINITY)
			if (max_multiplier>10 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=10'>x10</a>"
			if (max_multiplier>25 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=25'>x25</a>"
			if(max_multiplier > 0 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=[max_multiplier]'>x[max_multiplier]</a>"

		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	return dat

/obj/machinery/autolathe/proc/search_win(mob/user)
	var/dat = "<A href='?src=\ref[src];menu=[AUTOLATHE_MAIN_MENU]'>Return to main menu</A>"
	dat += "<div class='statusDisplay'><h3>Search results:</h3><br>"
	dat += "<b>Total amount:</b> [materials.total_amount] / [materials.max_amount] cm<sup>3</sup><br>"
	dat += "<b>Metal amount:</b> [materials.amount(MAT_METAL)] cm<sup>3</sup><br>"
	dat += "<b>Glass amount:</b> [materials.amount(MAT_GLASS)] cm<sup>3</sup><br>"

	for(var/v in matching_designs)
		var/datum/design/D = v
		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[D.name]</span>"
		else
			dat += "<a href='?src=\ref[src];make=[D.id];multiplier=1'>[D.name]</a>"

		if(ispath(D.build_path, /obj/item/stack))
			var/max_multiplier = min(D.maxstack, D.materials[MAT_METAL] ?round(materials.amount(MAT_METAL)/D.materials[MAT_METAL]):INFINITY,D.materials[MAT_GLASS]?round(materials.amount(MAT_GLASS)/D.materials[MAT_GLASS]):INFINITY)
			if (max_multiplier>10 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=10'>x10</a>"
			if (max_multiplier>25 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=25'>x25</a>"
			if(max_multiplier > 0 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=[max_multiplier]'>x[max_multiplier]</a>"

		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	return dat

/obj/machinery/autolathe/proc/can_build(datum/design/D)
	var/coeff = (ispath(D.build_path,/obj/item/stack) ? 1 : 2 ** prod_coeff)

	if(D.materials[MAT_METAL] && (materials.amount(MAT_METAL) < (D.materials[MAT_METAL] / coeff)))
		return 0
	if(D.materials[MAT_GLASS] && (materials.amount(MAT_GLASS) < (D.materials[MAT_GLASS] / coeff)))
		return 0
	return 1

/obj/machinery/autolathe/proc/get_design_cost(datum/design/D)
	var/coeff = (ispath(D.build_path,/obj/item/stack) ? 1 : 2 ** prod_coeff)
	var/dat
	if(D.materials[MAT_METAL])
		dat += "[D.materials[MAT_METAL] / coeff] metal "
	if(D.materials[MAT_GLASS])
		dat += "[D.materials[MAT_GLASS] / coeff] glass"
	return dat

/obj/machinery/autolathe/proc/reset(wire)
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

/obj/machinery/autolathe/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0

/obj/machinery/autolathe/proc/adjust_hacked(state)
	hacked = state
	for(var/datum/design/D in files.possible_designs)
		if((D.build_type & AUTOLATHE) && ("hacked" in D.category))
			if(hacked)
				files.AddDesign2Known(D)
			else
				files.known_designs -= D.id

//Called when the object is constructed by an autolathe
//Has a reference to the autolathe so you can do !!FUN!! things with hacked lathes
/obj/item/proc/autolathe_crafted(obj/machinery/autolathe/A)
	return
