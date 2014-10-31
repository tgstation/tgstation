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

	research_flags = CONSOLECONTROL

/obj/machinery/r_n_d/destructive_analyzer/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/destructive_analyzer,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser
	)

	RefreshParts()

/obj/machinery/r_n_d/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/S in src)
		T += S.rating * 0.1
	T = between (0, T, 1)
	decon_mod = T

/obj/machinery/r_n_d/destructive_analyzer/meteorhit()
	del(src)
	return

/obj/machinery/r_n_d/destructive_analyzer/proc/ConvertReqString2List(var/list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/obj/machinery/r_n_d/destructive_analyzer/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(loaded_item)
		user << "<span class='rose'>You can't open the maintenance panel while an item is loaded!</span>"
		return -1
	return ..()

/obj/machinery/r_n_d/destructive_analyzer/crowbarDestroy(mob/user)
	if(..() == 1)
		if(loaded_item)
			loaded_item.loc = src.loc
		return 1
	return -1

/obj/machinery/r_n_d/destructive_analyzer/attackby(var/obj/O as obj, var/mob/user as mob)
	if(..())
		return 1
	if (istype(O, /obj/item) && !loaded_item)
		if(isrobot(user)) //Don't put your module items in there!
			if(isMoMMI(user))
				var/mob/living/silicon/robot/mommi/mommi = user
				if(mommi.is_in_modules(O,permit_sheets=1))
					user << "\red You cannot insert something that is part of you."
					return
			else
				return
		if(!O.origin_tech)
			user << "\red This doesn't seem to have a tech origin!"
			return
		var/list/temp_tech = ConvertReqString2List(O.origin_tech)
		if (temp_tech.len == 0)
			user << "\red You cannot deconstruct this item!"
			return
		/*if(O.reliability < 90 && O.crit_fail == 0)
			usr << "\red Item is neither reliable enough or broken enough to learn from."
			return*/
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
