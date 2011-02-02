/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/
/obj/machinery/circuit_imprinter
	name = "Circuit Imprinter"
	icon_state = "circuit_imprinter"
	density = 1
	anchored = 1
	flags = OPENCONTAINER
	var
		g_amount = 0
		const/max_g_amount = 75000.0
		busy = 0
		obj/machinery/computer/rdconsole/linked_console = null //Linked R&D Console

	New()
		var/datum/reagents/R = new/datum/reagents(100)		//Holder for the reagents used as materials.
		reagents = R
		R.my_atom = src


	blob_act()
		if (prob(50))
			del(src)

	meteorhit()
		del(src)
		return

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if (!linked_console)
			user << "\The [name] must be linked to an R&D console first!"
			return 1
		if (O.is_open_container())
			return 1
		if (!istype(O, /obj/item/stack))
			user << "\red You cannot insert this item into the [name]!"
			return 1
		if (stat)
			return 1
		if (busy)
			user << "\red The [name] is busy. Please wait for completion of previous operation."
			return 1
		if (src.g_amount + O.g_amt > max_g_amount)
			user << "\red The [name] is full. Please remove glass from the protolathe in order to insert more."
			return 1

		var/amount = 1
		var/obj/item/stack/stack
		var/g_amt = O.g_amt
		stack = O
		amount = stack.amount
		if (g_amt)
			amount = min(amount, round((max_g_amount-src.g_amount)/g_amt))
		stack.use(amount)
		busy = 1
		use_power(max(1000, (g_amt)*amount/10))
		spawn(16)
			src.g_amount += g_amt * amount
			if (O && O.loc == src)
				del(O)
			busy = 0
			src.updateUsrDialog()
			return
