/**********************Mineral stacking unit console**************************/

/obj/machinery/mineral/stacking_unit_console
	name = "stacking machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/stacking_machine/machine = null
	var/machinedir = SOUTHEAST

/obj/machinery/mineral/stacking_unit_console/New()
	..()
	spawn(7)
		src.machine = locate(/obj/machinery/mineral/stacking_machine, get_step(src, machinedir))
		if (machine)
			machine.CONSOLE = src
		else
			del(src)

/obj/machinery/mineral/stacking_unit_console/process()
	updateDialog()

/obj/machinery/mineral/stacking_unit_console/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/machinery/mineral/stacking_unit_console/interact(mob/user)
	user.set_machine(src)

	var/dat

	dat += text("<b>Stacking unit console</b><br><br>")

	for(var/typepath in machine.stacks)
		var/obj/item/stack/stack=machine.stacks[typepath]
		if(stack.amount)
			dat += "[stack.name]: [stack.amount] <A href='?src=\ref[src];release=[typepath] '>Release</A><br>"

	dat += text("<br>Stacking: [machine.stack_amt]<br><br>")

	user << browse("[dat]", "window=console_stacking_machine")
	onclose(user, "console_stacking_machine")

/obj/machinery/mineral/stacking_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["release"])
		var/typepath = href_list["release"]
		if(typepath in machine.stacks)
			var/obj/item/stack/stack=machine.stacks[typepath]
			if (stack.amount > 0)
				var/obj/item/stack/stacked=new typepath
				stacked.amount=stack.amount
				stacked.loc=machine.output.loc
				stack.amount = 0
				if(stack.amount==0)
					machine.stacks.Remove(typepath)
				else
					machine.stacks[typepath]=stack
	src.updateUsrDialog()
	return


/**********************Mineral stacking unit**************************/


/obj/machinery/mineral/stacking_machine
	name = "stacking machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/stacking_unit_console/CONSOLE
	var/stk_types = list()
	var/stk_amt   = list()
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null

	var/list/stacks=list()

	var/stack_amt = 50 //amount to stack before releassing

/obj/machinery/mineral/stacking_machine/New()
	..()
	spawn( 5 )
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if(src.input) break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(src.output) break
		processing_objects.Add(src)
		return
	return

/obj/machinery/mineral/stacking_machine/process()
	if (src.output && src.input)
		var/obj/item/O
		var/obj/item/stack/stack
		var/limit=10
		while (locate(/obj/item, input.loc) && limit > 0)
			O = locate(/obj/item, input.loc)
			limit--
			if (istype(O,/obj/item/stack))
				if(!("[O.type]" in stacks))
					stack=new O.type
					stack.amount=O:amount
				else
					stack=stacks["[O.type]"]
					stack.amount += O:amount
				stacks["[O.type]"]=stack
				qdel(O)
				continue
			//if (istype(O,/obj/item/weapon/ore/slag))
			//	qdel(O)
			//	continue
			O.loc = src.output.loc
		for(var/typepath in stacks)
			stack=stacks[typepath]
			if(stack.amount >= stack_amt)
				var/obj/item/stack/stacked=new stack.type
				stacked.amount=stack_amt
				stacked.loc=output.loc
				stack.amount -= stack_amt
				if(stack.amount==0)
					stacks.Remove(typepath)
				else
					stacks[typepath]=stack
				return
	return
