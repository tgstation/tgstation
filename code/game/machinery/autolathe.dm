#define AUTOLATHE_MAIN_MENU       1
#define AUTOLATHE_CATEGORY_MENU   2
#define AUTOLATHE_SEARCH_MENU     3

/obj/machinery/autolathe
	name = "autolathe"
	desc = "It produces items using metal and glass."
	icon_state = "autolathe"
	density = 1

	var/m_amount = 0.0
	var/max_m_amount = 150000.0

	var/g_amount = 0.0
	var/max_g_amount = 75000.0

	var/operating = 0.0
	anchored = 1.0
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
	var/datum/wires/autolathe/wires = null

	var/datum/design/being_built
	var/datum/research/files
	var/list/datum/design/matching_designs
	var/selected_category
	var/screen = 1

	var/list/categories = list(
							"Tools",
							"Electronics",
							"Construction",
							"T-Comm",
							"Security",
							"Medical",
							"Misc"
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
	RefreshParts()

	wires = new(src)
	files = new /datum/research/autolathe(src)
	matching_designs = list()

/obj/machinery/autolathe/interact(mob/user)
	if(!is_operational())
		return

	if(shocked && !(stat & NOPOWER))
		shock(user,50)

	var/dat

	if(panel_open)
		dat = wires.GetInteractWindow()

	else
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

	if (panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			if(m_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal(src.loc)
				G.amount = round(m_amount / MINERAL_MATERIAL_AMOUNT)
			if(g_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(src.loc)
				G.amount = round(g_amount / MINERAL_MATERIAL_AMOUNT)
			default_deconstruction_crowbar(O)
			return 1
		else
			attack_hand(user)
			return 1
	if (stat)
		return 1

	if (src.m_amount + O.m_amt > max_m_amount)
		user << "<span class='warning'>The autolathe is full. Please remove metal from the autolathe in order to insert more.</span>"
		return 1
	if (src.g_amount + O.g_amt > max_g_amount)
		user << "<span class='warning'>The autolathe is full. Please remove glass from the autolathe in order to insert more.</span>"
		return 1
	if (!O.m_amt && !O.g_amt)
		user << "<span class='warning'>This object does not contain sufficient amounts of metal or glass to be accepted by the autolathe.</span>"
		return 1
	if(!user.unEquip(O))
		user << "<span class='warning'>\The [O] is stuck to you and cannot be placed into the autolathe.</span>"
		return 1

	var/amount = 1
	var/obj/item/stack/stack
	var/m_amt = O.m_amt
	var/g_amt = O.g_amt
	if (istype(O, /obj/item/stack))
		stack = O
		amount = stack.amount
		if (m_amt)
			amount = min(amount, round((max_m_amount-src.m_amount)/m_amt))
			flick("autolathe_o",src)//plays metal insertion animation
		if (g_amt)
			amount = min(amount, round((max_g_amount-src.g_amount)/g_amt))
			flick("autolathe_r",src)//plays glass insertion animation
		stack.use(amount)
	else
		if(!user.unEquip(O))
			user << "<span class='warning'>/the [O] is stuck to your hand, you can't put it in \the [src]!</span>"
		O.loc = src
	icon_state = "autolathe"
	busy = 1
	use_power(max(1000, (m_amt+g_amt)*amount/10))
	src.m_amount += m_amt * amount
	src.g_amount += g_amt * amount
	user << "<span class='notice'>You insert [amount] sheet[amount>1 ? "s" : ""] to the autolathe.</span>"
	if (O && O.loc == src)
		qdel(O)
	busy = 0
	src.updateUsrDialog()

/obj/machinery/autolathe/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/autolathe/attack_hand(mob/user)
	if(..(user, 0))
		return
	interact(user)

/obj/machinery/autolathe/Topic(href, href_list)
	if(..())
		return
	if (!busy)
		if(href_list["menu"])
			screen = text2num(href_list["menu"])

		if(href_list["category"])
			selected_category = href_list["category"]

		if(href_list["make"])

			var/turf/T = get_step(src.loc, get_dir(src,usr))

			/////////////////
			//href protection
			being_built = files.FindDesignByID(href_list["make"]) //check if it's a valid design
			if(!being_built)
				return

			//multiplier checks : only stacks can have one and its value is 1, 10 ,25 or max_multiplier
			var/multiplier = text2num(href_list["multiplier"])
			var/max_multiplier = min(50, being_built.materials["$metal"] ?round(m_amount/being_built.materials["$metal"]):INFINITY,being_built.materials["$glass"]?round(g_amount/being_built.materials["$glass"]):INFINITY)
			var/is_stack = ispath(being_built.build_path, /obj/item/stack)

			if(!is_stack && (multiplier > 1))
				return
			if (!(multiplier in list(1,10,25,max_multiplier))) //"enough materials ?" is checked further down
				return
			/////////////////

			var/coeff = (is_stack ? 1 : 2 ** prod_coeff) //stacks are unaffected by production coefficient
			var/metal_cost = being_built.materials["$metal"]
			var/glass_cost = being_built.materials["$glass"]

			var/power = max(2000, (metal_cost+glass_cost)*multiplier/5)

			if((m_amount >= metal_cost*multiplier/coeff) && (g_amount >= glass_cost*multiplier/coeff))
				busy = 1
				use_power(power)
				icon_state = "autolathe"
				flick("autolathe_n",src)
				spawn(32/coeff)
					use_power(power)
					if(is_stack)
						m_amount -= metal_cost*multiplier
						g_amount -= glass_cost*multiplier

						for(var/obj/item/stack/S in T)
							if(multiplier <= 0)
								break
							if(S.amount >= S.max_amount)
								continue
							var/to_transfer = S.max_amount - S.amount
							if(to_transfer < multiplier)
								S.amount += to_transfer
								multiplier -= to_transfer
								S.update_icon()
								continue
							else
								S.amount += multiplier
								multiplier = 0
								S.update_icon()
								break
						if(multiplier)
							var/obj/item/stack/N = new being_built.build_path(T)
							N.amount = multiplier
							N.update_icon()
					else
						m_amount -= metal_cost/coeff
						g_amount -= glass_cost/coeff
						var/obj/item/new_item = new being_built.build_path(T)
						new_item.m_amt /= coeff
						new_item.g_amt /= coeff
					if(m_amount < 0)
						m_amount = 0
					if(g_amount < 0)
						g_amount = 0
					busy = 0
					src.updateUsrDialog()

		if(href_list["search"])
			matching_designs.Cut()

			for(var/datum/design/D in files.known_designs)
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
	max_m_amount = tot_rating * 2
	max_g_amount = tot_rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		prod_coeff += M.rating - 1

/obj/machinery/autolathe/proc/main_win(mob/user)
	var/dat = "<div class='statusDisplay'><h3>Autolathe Menu:</h3><br>"
	dat += "<b>Metal amount:</b> [src.m_amount] / [max_m_amount] cm<sup>3</sup><br>"
	dat += "<b>Glass amount:</b> [src.g_amount] / [max_g_amount] cm<sup>3</sup>"

	dat += "<form name='search' action='?src=\ref[src]'> \
	<input type='hidden' name='src' value='\ref[src]'> \
	<input type='hidden' name='search' value='to_search'> \
	<input type='hidden' name='menu' value='[AUTOLATHE_SEARCH_MENU]'> \
	<input type='text' name='to_search'> \
	<input type='submit' value='Search'> \
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

/obj/machinery/autolathe/proc/category_win(mob/user,var/selected_category)
	var/dat = "<A href='?src=\ref[src];menu=[AUTOLATHE_MAIN_MENU]'>Return to main menu</A>"
	dat += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3><br>"
	dat += "<b>Metal amount:</b> [src.m_amount] / [max_m_amount] cm<sup>3</sup><br>"
	dat += "<b>Glass amount:</b> [src.g_amount] / [max_g_amount] cm<sup>3</sup><hr>"

	for(var/datum/design/D in files.known_designs)
		if(!(selected_category in D.category))
			continue

		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[D.name]</span>"
		else
			dat += "<a href='?src=\ref[src];make=[D.id];multiplier=1'>[D.name]</a>"

		if(ispath(D.build_path, /obj/item/stack))
			var/max_multiplier = min(50, D.materials["$metal"] ?round(m_amount/D.materials["$metal"]):INFINITY,D.materials["$glass"]?round(g_amount/D.materials["$glass"]):INFINITY)
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
	dat += "<b>Metal amount:</b> [src.m_amount] / [max_m_amount] cm<sup>3</sup><br>"
	dat += "<b>Glass amount:</b> [src.g_amount] / [max_g_amount] cm<sup>3</sup><hr>"

	for(var/datum/design/D in matching_designs)
		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[D.name]</span>"
		else
			dat += "<a href='?src=\ref[src];make=[D.id];multiplier=1'>[D.name]</a>"

		if(ispath(D.build_path, /obj/item/stack))
			var/max_multiplier = min(50, D.materials["$metal"] ?round(m_amount/D.materials["$metal"]):INFINITY,D.materials["$glass"]?round(g_amount/D.materials["$glass"]):INFINITY)
			if (max_multiplier>10 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=10'>x10</a>"
			if (max_multiplier>25 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=25'>x25</a>"
			if(max_multiplier > 0 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=[max_multiplier]'>x[max_multiplier]</a>"

		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	return dat

/obj/machinery/autolathe/proc/can_build(var/datum/design/D)
	var/coeff = (ispath(D.build_path,/obj/item/stack) ? 1 : 2 ** prod_coeff)

	if(D.materials["$metal"] && (m_amount < (D.materials["$metal"] / coeff)))
		return 0
	if(D.materials["$glass"] && (g_amount < (D.materials["$glass"] / coeff)))
		return 0
	return 1

/obj/machinery/autolathe/proc/get_design_cost(var/datum/design/D)
	var/coeff = (ispath(D.build_path,/obj/item/stack) ? 1 : 2 ** prod_coeff)
	var/dat
	if(D.materials["$metal"])
		dat += "[D.materials["$metal"] / coeff] metal "
	if(D.materials["$glass"])
		dat += "[D.materials["$glass"] / coeff] glass"
	return dat

/obj/machinery/autolathe/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0

/obj/machinery/autolathe/proc/adjust_hacked(var/hack)
	hacked = hack

	if(hack)
		for(var/datum/design/D in files.possible_designs)
			if((D.build_type & 4) && ("hacked" in D.category))
				files.known_designs += D
	else
		for(var/datum/design/D in files.known_designs)
			if("hacked" in D.category)
				files.known_designs -= D
