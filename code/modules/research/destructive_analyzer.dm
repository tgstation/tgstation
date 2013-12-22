//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/r_n_d/destructive_analyzer
	name = "Destructive Analyzer"
	icon_state = "d_analyzer"
	var/obj/item/weapon/loaded_item = null
	var/decon_mod = 1

/obj/machinery/r_n_d/destructive_analyzer/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/destructive_analyzer(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(src)
	RefreshParts()

/obj/machinery/r_n_d/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/S in src)
		T += S.rating * 0.1
	T = Clamp(T, 0, 1)
	decon_mod = T

/obj/machinery/r_n_d/destructive_analyzer/meteorhit()
	del(src)
	return

/obj/machinery/r_n_d/destructive_analyzer/proc/ConvertReqString2List(var/list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list


/obj/machinery/r_n_d/destructive_analyzer/attackby(var/obj/O as obj, var/mob/user as mob)
	if (shocked)
		shock(user,50)
	if (istype(O, /obj/item/weapon/screwdriver))
		if(linked_console)
			linked_console.linked_destroy = null
			linked_console = null
		default_deconstruction_screwdriver(user, "d_analyzer_t", "d_analyzer")
		return
	if (panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			default_deconstruction_crowbar()
			return 1
		else
			user << "\red You can't load the [src.name] while it's opened."
			return 1
	if (disabled)
		return
	if (!linked_console)
		user << "\red The protolathe must be linked to an R&D console first!"
		return
	if (busy)
		user << "\red The protolathe is busy right now."
		return
	if (istype(O, /obj/item) && !loaded_item)
		if(!O.origin_tech)
			user << "\red This doesn't seem to have a tech origin!"
			return
		var/list/temp_tech = ConvertReqString2List(O.origin_tech)
		if (temp_tech.len == 0)
			user << "\red You cannot deconstruct this item!"
			return
		if(O.reliability < 90 && O.crit_fail == 0)
			usr << "\red Item is neither reliable enough or broken enough to learn from."
			return
		busy = 1
		loaded_item = O
		user.drop_item()
		O.loc = src
		user << "\blue You add the [O.name] to the machine!"
		flick("d_analyzer_la", src)
		spawn(10)
			icon_state = "d_analyzer_l"
			busy = 0
	return

//For testing purposes only.
/*/obj/item/weapon/deconstruction_test
	name = "Test Item"
	desc = "WTF?"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "d20"
	g_amt = 5000
	m_amt = 5000
	origin_tech = "materials=5;plasmatech=5;syndicate=5;programming=9"*/
