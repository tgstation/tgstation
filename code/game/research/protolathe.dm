/*
Protolathe

Similar to an autolathe, you load glass and metal sheets (but not other objects) into it to be used as raw materials for the stuff
it creates. All the menus and other manipulation commands are in the R&D console.

Note: Must be placed west/left of and R&D console to function.

*/
/obj/machinery/protolathe
	density = 1
	anchored = 1.0
	icon_state = "protolathe"
	var/busy = 0				//
	var/max_m_amount = 150000.0
	var/max_g_amount = 75000.0
	var/m_amount = 0.0
	var/g_amount = 0.0
	var/obj/machinery/computer/rdconsole/linked_console = null

/obj/machinery/protolathe/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (!linked_console)
		user << "\The protolathe must be linked to an R&D console first!"
		return 1
	if (!istype(O, /obj/item/stack))
		user << "\red You cannot insert this item into the protolathe!"
		return 1
	if (stat)
		return 1
	if (busy)
		user << "\red The protolathe is busy. Please wait for completion of previous operation."
		return 1
	if (src.m_amount + O.m_amt > max_m_amount)
		user << "\red The protolathe is full. Please remove metal from the protolathe in order to insert more."
		return 1
	if (src.g_amount + O.g_amt > max_g_amount)
		user << "\red The protolathe is full. Please remove glass from the protolathe in order to insert more."
		return 1
	if (O.m_amt == 0 && O.g_amt == 0)
		user << "\red This object does not contain significant amounts of metal or glass, or cannot be accepted by the protolathe due to size or hazardous materials."
		return 1

	var/amount = 1
	var/obj/item/stack/stack
	var/m_amt = O.m_amt
	var/g_amt = O.g_amt
	stack = O
	amount = stack.amount
	if (m_amt)
		amount = min(amount, round((max_m_amount-src.m_amount)/m_amt))
		flick("protolathe_o",src)//plays metal insertion animation
	if (g_amt)
		amount = min(amount, round((max_g_amount-src.g_amount)/g_amt))
		flick("protolathe_r",src)//plays glass insertion animation
	stack.use(amount)
	icon_state = "protolathe"
	busy = 1
	use_power(max(1000, (m_amt+g_amt)*amount/10))
	spawn(16)
		icon_state = "protolathe"
		flick("protolathe_o",src)
		src.m_amount += m_amt * amount
		src.g_amount += g_amt * amount
		if (O && O.loc == src)
			del(O)
		busy = 0
		src.updateUsrDialog()