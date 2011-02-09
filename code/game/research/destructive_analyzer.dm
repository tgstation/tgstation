/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed east/right of an R&D console to function.
*/
/obj/machinery/r_n_d/destructive_analyzer
	name = "Destructive Analyzer"
	icon_state = "d_analyzer"
	var
		obj/item/weapon/loaded_item = null
		busy = 0

	meteorhit()
		del(src)
		return

	attackby(var/obj/O as obj, var/mob/user as mob)
		if (!linked_console)
			user << "\red The protolathe must be linked to an R&D console first!"
			return
		if (busy)
			user << "\red The protolathe is busy right now."
			return
		if (istype(O, /obj/item/weapon) && !loaded_item)
			if(!O.origin_tech)
				user << "\red This doesn't seem to have a tech origin!"
				return
			if (O.origin_tech.len == 0)
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
/obj/item/weapon/deconstruction_test
	name = "Test Item"
	desc = "WTF?"
	icon = 'weapons.dmi'
	icon_state = "d20"
	g_amt = 5000
	m_amt = 5000
	origin_tech = list("materials" = 4, "plasmatech" = 2, "syndicate" = 5, "programming" = 9)