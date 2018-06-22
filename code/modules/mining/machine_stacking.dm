/**********************Mineral stacking unit console**************************/

/obj/machinery/mineral/stacking_unit_console
	name = "stacking machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	desc = "Controls a stacking machine... in theory."
	density = FALSE
	circuit = /obj/item/circuitboard/machine/stacking_unit_console
	var/obj/machinery/mineral/stacking_machine/machine
	var/machinedir = SOUTHEAST

/obj/machinery/mineral/stacking_unit_console/Initialize()
	. = ..()
	machine = locate(/obj/machinery/mineral/stacking_machine, get_step(src, machinedir))
	if (machine)
		machine.CONSOLE = src

/obj/machinery/mineral/stacking_unit_console/ui_interact(mob/user)
	. = ..()

	if(!machine)
		to_chat(user, "<span class='notice'>[src] is not linked to a machine!</span>")
		return

	var/obj/item/stack/sheet/s
	var/dat

	dat += text("<b>Stacking unit console</b><br><br>")

	for(var/O in machine.stack_list)
		s = machine.stack_list[O]
		if(s.amount > 0)
			dat += text("[capitalize(s.name)]: [s.amount] <A href='?src=[REF(src)];release=[s.type]'>Release</A><br>")

	dat += text("<br>Stacking: [machine.stack_amt]<br><br>")

	user << browse(dat, "window=console_stacking_machine")

/obj/machinery/mineral/stacking_unit_console/multitool_act(mob/living/user, obj/item/I)
	if(istype(I, /obj/item/multitool))
		var/obj/item/multitool/M = I
		M.buffer = src
		to_chat(user, "<span class='notice'>You store linkage information in [I]'s buffer.</span>")
		return TRUE

/obj/machinery/mineral/stacking_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["release"])
		if(!(text2path(href_list["release"]) in machine.stack_list))
			return //someone tried to spawn materials by spoofing hrefs
		var/obj/item/stack/sheet/inp = machine.stack_list[text2path(href_list["release"])]
		var/obj/item/stack/sheet/out = new inp.type(null, inp.amount)
		inp.amount = 0
		machine.unload_mineral(out)

	src.updateUsrDialog()
	return


/**********************Mineral stacking unit**************************/


/obj/machinery/mineral/stacking_machine
	name = "stacking machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	desc = "A machine that automatically stacks acquired materials. Controlled by a nearby console."
	density = TRUE
	circuit = /obj/item/circuitboard/machine/stacking_machine
	var/obj/machinery/mineral/stacking_unit_console/CONSOLE
	var/stk_types = list()
	var/stk_amt   = list()
	var/stack_list[0] //Key: Type.  Value: Instance of type.
	var/stack_amt = 50; //ammount to stack before releassing
	input_dir = EAST
	output_dir = WEST

/obj/machinery/mineral/stacking_machine/Initialize()
	. = ..()
	proximity_monitor = new(src, 1)

/obj/machinery/mineral/stacking_machine/HasProximity(atom/movable/AM)
	if(istype(AM, /obj/item/stack/sheet) && AM.loc == get_step(src, input_dir))
		process_sheet(AM)

/obj/machinery/mineral/stacking_machine/multitool_act(mob/living/user, obj/item/I)
	if(istype(I, /obj/item/multitool))
		var/obj/item/multitool/M = I
		if(!istype(M.buffer, /obj/machinery/mineral/stacking_unit_console))
			to_chat(user, "<span class='warning'>The [I] has no linkage data in its buffer.</span>")
			return FALSE
		else
			CONSOLE = M.buffer
			CONSOLE.machine = src
			to_chat(user, "<span class='notice'>You link [src] to the console in [I]'s buffer.</span>")
			return TRUE

/obj/machinery/mineral/stacking_machine/proc/process_sheet(obj/item/stack/sheet/inp)
	if(!(inp.type in stack_list)) //It's the first of this sheet added
		var/obj/item/stack/sheet/s = new inp.type(src, 0)
		stack_list[inp.type] = s
	var/obj/item/stack/sheet/storage = stack_list[inp.type]
	storage.amount += inp.amount //Stack the sheets
	while(storage.amount > stack_amt) //Get rid of excessive stackage
		var/obj/item/stack/sheet/out = new inp.type(null, stack_amt)
		unload_mineral(out)
		storage.amount -= stack_amt
	qdel(inp) //Let the old sheet garbage collect
