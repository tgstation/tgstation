<<<<<<< HEAD
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
	var/prod_coeff = 1

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
							"Dinnerware",
							"Imported"
							)

/obj/machinery/autolathe/New()
	..()
	materials = new /datum/material_container(src, list(MAT_METAL, MAT_GLASS))
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/autolathe(null)
	B.apply_default_parts(src)

	wires = new /datum/wires/autolathe(src)
	files = new /datum/research/autolathe(src)
	matching_designs = list()

/obj/item/weapon/circuitboard/machine/autolathe
	name = "circuit board (Autolathe)"
	build_path = /obj/machinery/autolathe
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 3,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

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

/obj/machinery/autolathe/deconstruction()
	materials.retrieve_all()

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
			default_deconstruction_crowbar(O)
			return 1
		else if(is_wire_tool(O))
			wires.interact(user)
			return 1

	if(user.a_intent == "harm") //so we can hit the machine
		return ..()

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
		return 1

	if(O.flags & HOLOGRAM)
		return 1

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
	return 1

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

			var/coeff = (is_stack ? 1 : prod_coeff) //stacks are unaffected by production coefficient
			var/metal_cost = being_built.materials[MAT_METAL]
			var/glass_cost = being_built.materials[MAT_GLASS]

			var/power = max(2000, (metal_cost+glass_cost)*multiplier/5)

			if((materials.amount(MAT_METAL) >= metal_cost*multiplier*coeff) && (materials.amount(MAT_GLASS) >= glass_cost*multiplier*coeff))
				busy = 1
				use_power(power)
				icon_state = "autolathe"
				flick("autolathe_n",src)
				spawn(32*coeff)
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
						var/list/materials_used = list(MAT_METAL=metal_cost*coeff, MAT_GLASS=glass_cost*coeff)
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
	var/T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
		T += MB.rating*75000
	materials.max_amount = T
	T=1.2
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T -= M.rating*0.2
	prod_coeff = min(1,max(0,T)) // Coeff going 1 -> 0,8 -> 0,6 -> 0,4

/obj/machinery/autolathe/proc/main_win(mob/user)
	var/dat = "<div class='statusDisplay'><h3>Autolathe Menu:</h3><br>"
	dat += materials_printout()

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
	dat += materials_printout()

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
	dat += materials_printout()

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

/obj/machinery/autolathe/proc/materials_printout()
	var/dat = "<b>Total amount:</b> [materials.total_amount] / [materials.max_amount] cm<sup>3</sup><br>"
	for(var/mat_id in materials.materials)
		var/datum/material/M = materials.materials[mat_id]
		dat += "<b>[M.name] amount:</b> [M.amount] cm<sup>3</sup><br>"
	return dat

/obj/machinery/autolathe/proc/can_build(datum/design/D)
	var/coeff = (ispath(D.build_path,/obj/item/stack) ? 1 : prod_coeff)

	if(D.materials[MAT_METAL] && (materials.amount(MAT_METAL) < (D.materials[MAT_METAL] * coeff)))
		return 0
	if(D.materials[MAT_GLASS] && (materials.amount(MAT_GLASS) < (D.materials[MAT_GLASS] * coeff)))
		return 0
	return 1

/obj/machinery/autolathe/proc/get_design_cost(datum/design/D)
	var/coeff = (ispath(D.build_path,/obj/item/stack) ? 1 : prod_coeff)
	var/dat
	if(D.materials[MAT_METAL])
		dat += "[D.materials[MAT_METAL] * coeff] metal "
	if(D.materials[MAT_GLASS])
		dat += "[D.materials[MAT_GLASS] * coeff] glass"
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
=======
#define AUTOLATHE_BUILD_TIME	0.5
#define AUTOLATHE_MAX_TIME		50 //5 seconds max, * time_coeff

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe
	name = "\improper Autolathe"
	desc = "Produces a large range of common items using metal and glass."
	icon_state = "autolathe"
	icon_state_open = "autolathe_t"
	nano_file = "autolathe.tmpl"
	density = 1

	design_types = list()

	start_end_anims = 1

	use_power = 1
	idle_power_usage = 50
	active_power_usage = 500

	build_time = AUTOLATHE_BUILD_TIME

	removable_designs = 0
	plastic_added = 0

	allowed_materials = list(
						MAT_IRON,
						MAT_GLASS
	)

	machine_flags = SCREWTOGGLE | CROWDESTROY | EMAGGABLE | WRENCHMOVE | FIXED2WORK

	research_flags = NANOTOUCH | TAKESMATIN | HASOUTPUT | IGNORE_CHEMS | HASMAT_OVER | FAB_RECYCLER

	light_color = LIGHT_COLOR_CYAN

	one_part_set_only = 0
	part_sets = list(
		"Tools"=list(
		new /obj/item/device/multitool(), \
		new /obj/item/weapon/weldingtool/empty(), \
		new /obj/item/weapon/crowbar(), \
		new /obj/item/weapon/screwdriver(), \
		new /obj/item/weapon/wirecutters(), \
		new /obj/item/weapon/wrench(), \
		new /obj/item/weapon/solder(),\
		new /obj/item/device/analyzer(), \
		new /obj/item/weapon/pickaxe/shovel/spade(), \
		new /obj/item/device/silicate_sprayer/empty(), \
		),
		"Containers"=list(
		new /obj/item/weapon/reagent_containers/glass/beaker(), \
		new /obj/item/weapon/reagent_containers/glass/beaker/large(), \
		new /obj/item/weapon/reagent_containers/glass/bucket(), \
		new /obj/item/weapon/reagent_containers/glass/beaker/vial(), \
		new /obj/item/weapon/reagent_containers/food/drinks/mug(), \
		),
		"Assemblies"=list(
		new /obj/item/device/assembly/igniter(), \
		new /obj/item/device/assembly/signaler(), \
		/*new /obj/item/device/assembly/infra(), \*/
		new /obj/item/device/assembly/timer(), \
		new /obj/item/device/assembly/voice(), \
		new /obj/item/device/assembly/prox_sensor(), \
		new /obj/item/device/assembly/speaker(), \
		new /obj/item/device/assembly/addition(), \
		new /obj/item/device/assembly/comparison(), \
		new /obj/item/device/assembly/randomizer(), \
		new /obj/item/device/assembly/read_write(), \
		new /obj/item/device/assembly/math(), \
		),
		"Stock_Parts"=list(
		new /obj/item/weapon/stock_parts/console_screen(), \
		new /obj/item/weapon/stock_parts/capacitor(), \
		new /obj/item/weapon/stock_parts/scanning_module(), \
		new /obj/item/weapon/stock_parts/manipulator(), \
		new /obj/item/weapon/stock_parts/micro_laser(), \
		new /obj/item/weapon/stock_parts/matter_bin(), \
		),
		"Medical"=list(
		new /obj/item/weapon/storage/pill_bottle(),\
		new /obj/item/weapon/reagent_containers/syringe(), \
		new /obj/item/weapon/scalpel(), \
		new /obj/item/weapon/circular_saw(), \
		new /obj/item/weapon/surgicaldrill(),\
		new /obj/item/weapon/retractor(),\
		new /obj/item/weapon/cautery(),\
		new /obj/item/weapon/hemostat(),\
		),
		"Ammunition"=list(
		new /obj/item/ammo_casing/shotgun/blank(), \
		new /obj/item/ammo_casing/shotgun/beanbag(), \
		new /obj/item/ammo_casing/shotgun/flare(), \
		new /obj/item/ammo_storage/speedloader/c38/empty(), \
		new /obj/item/ammo_storage/box/c38(), \
		),
		"Misc_Tools"=list(
		new /obj/item/device/flashlight(), \
		new /obj/item/weapon/extinguisher(), \
		new /obj/item/device/radio/headset(), \
		new /obj/item/device/radio/off(), \
		new /obj/item/weapon/kitchen/utensil/knife/large(), \
		new /obj/item/clothing/head/welding(), \
		new /obj/item/device/taperecorder(), \
		new /obj/item/weapon/chisel(), \
		new /obj/item/device/rcd/tile_painter(), \
		),
		"Misc_Other"=list(
		new /obj/item/weapon/rcd_ammo(), \
		new /obj/item/weapon/light/tube(), \
		new /obj/item/weapon/light/bulb(), \
		new /obj/item/ashtray/glass(), \
		new /obj/item/weapon/storage/pill_bottle/dice(),\
		new /obj/item/weapon/camera_assembly(), \
		new /obj/item/stack/sheet/glass/rglass(), \
		new /obj/item/stack/rods(), \
		),
		"Hidden_Items" = list(
		new /obj/item/weapon/gun/projectile/flamethrower/full(), \
		new /obj/item/ammo_storage/box/flare(), \
		new /obj/item/device/rcd/matter/engineering(), \
		new /obj/item/device/rcd/rpd(),\
		new /obj/item/device/rcd/matter/rsf(), \
		new /obj/item/device/radio/electropack(), \
		new /obj/item/weapon/weldingtool/largetank/empty(), \
		new /obj/item/weapon/handcuffs(), \
		new /obj/item/ammo_storage/box/a357(), \
		new /obj/item/ammo_casing/shotgun(), \
		new /obj/item/ammo_casing/shotgun/dart(), \
		)
	)

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/autolathe,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/get_construction_time_w_coeff(datum/design/part)
	return min(..(), (AUTOLATHE_MAX_TIME * time_coeff)) //we have set designs, so we can make them quickly

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/is_contraband(var/datum/design/part)
	if(part in part_sets["Hidden_Items"])
		return 1

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/update_hacked()
	if(screen == 51) screen = 11 //take the autolathe away from the contraband menu, since otherwise it can still print contraband until another category is selected
	/*if(hacked)
		part_sets["Items"] |= part_sets["Hidden Items"]
	else
		part_sets["Items"] -= part_sets["Hidden Items"]*/

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/attackby(obj/item/I, mob/user)
	if(..())
		return 1

	else if(I.materials)
		if(I.materials.getVolume() + src.materials.getVolume() > max_material_storage)
			to_chat(user, "\The [src]'s material bin is too full to recycle \the [I].")
			return 1
		else if(I.materials.getAmount(MAT_IRON) + I.materials.getAmount(MAT_GLASS) < I.materials.getVolume())
			to_chat(user, "\The [src] can only accept objects made out of metal and glass.")
			return 1
		else if(isrobot(user))
			if(isMoMMI(user))
				var/mob/living/silicon/robot/mommi/M = user
				if(M.is_in_modules(I))
					to_chat(user, "You cannot recycle your built in tools.")
					return 1
			else
				to_chat(user, "You cannot recycle your built in tools.")
				return 1

		if(user.drop_item(I, src))
			materials.removeFrom(I.materials)
			user.visible_message("[user] puts \the [I] into \the [src]'s recycling unit.",
								"You put \the [I] in \the [src]'s reycling unit.")
			qdel(I)
		return 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
