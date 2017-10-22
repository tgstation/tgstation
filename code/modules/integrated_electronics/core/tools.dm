#define WIRE		"wire"
#define WIRING		"wiring"
#define UNWIRE		"unwire"
#define UNWIRING	"unwiring"


/obj/item/device/integrated_electronics/wirer
	name = "circuit wirer"
	desc = "It's a small wiring tool, with a wire roll, electric soldering iron, wire cutter, and more in one package. \
	The wires used are generally useful for small electronics, such as circuitboards and breadboards, as opposed to larger wires \
	used for power or data transmission."
	icon = 'icons/obj/electronic_assemblies.dmi'
	icon_state = "wirer-wire"
	item_state = "wirer"
	flags = CONDUCT
	w_class = 2
	var/datum/integrated_io/selected_io = null
	var/mode = WIRE

/obj/item/device/integrated_electronics/wirer/update_icon()
	icon_state = "wirer-[mode]"

/obj/item/device/integrated_electronics/wirer/proc/wire(var/datum/integrated_io/io, mob/user)
	if(!io.holder.assembly)
		to_chat(user, "<span class='warning'>\The [io.holder] needs to be secured inside an assembly first.</span>")
		return
	if(mode == WIRE)
		selected_io = io
		to_chat(user, "<span class='notice'>You attach a data wire to \the [selected_io.holder]'s [selected_io.name] data channel.</span>")
		mode = WIRING
		update_icon()
	else if(mode == WIRING)
		if(io == selected_io)
			to_chat(user, "<span class='warning'>Wiring \the [selected_io.holder]'s [selected_io.name] into itself is rather pointless.</span>")
			return
		if(io.io_type != selected_io.io_type)
			to_chat(user, "<span class='warning'>Those two types of channels are incompatable.  The first is a [selected_io.io_type], \
			while the second is a [io.io_type].</span>")
			return
		if(io.holder.assembly && io.holder.assembly != selected_io.holder.assembly)
			to_chat(user, "<span class='warning'>Both \the [io.holder] and \the [selected_io.holder] need to be inside the same assembly.</span>")
			return
		selected_io.linked |= io
		io.linked |= selected_io

		to_chat(user, "<span class='notice'>You connect \the [selected_io.holder]'s [selected_io.name] to \the [io.holder]'s [io.name].</span>")
		mode = WIRE
		update_icon()
		selected_io.holder.interact(user) // This is to update the UI.
		selected_io = null

	else if(mode == UNWIRE)
		selected_io = io
		if(!io.linked.len)
			to_chat(user, "<span class='warning'>There is nothing connected to \the [selected_io] data channel.</span>")
			selected_io = null
			return
		to_chat(user, "<span class='notice'>You prepare to detach a data wire from \the [selected_io.holder]'s [selected_io.name] data channel.</span>")
		mode = UNWIRING
		update_icon()
		return

	else if(mode == UNWIRING)
		if(io == selected_io)
			to_chat(user, "<span class='warning'>You can't wire a pin into each other, so unwiring \the [selected_io.holder] from \
			the same pin is rather moot.</span>")
			return
		if(selected_io in io.linked)
			io.linked.Remove(selected_io)
			selected_io.linked.Remove(io)
			to_chat(user, "<span class='notice'>You disconnect \the [selected_io.holder]'s [selected_io.name] from \
			\the [io.holder]'s [io.name].</span>")
			selected_io.holder.interact(user) // This is to update the UI.
			selected_io = null
			mode = UNWIRE
			update_icon()
		else
			to_chat(user, "<span class='warning'>\The [selected_io.holder]'s [selected_io.name] and \the [io.holder]'s \
			[io.name] are not connected.</span>")
			return
	return

/obj/item/device/integrated_electronics/wirer/attack_self(mob/user)
	switch(mode)
		if(WIRE)
			mode = UNWIRE
		if(WIRING)
			if(selected_io)
				to_chat(user, "<span class='notice'>You decide not to wire the data channel.</span>")
			selected_io = null
			mode = WIRE
		if(UNWIRE)
			mode = WIRE
		if(UNWIRING)
			if(selected_io)
				to_chat(user, "<span class='notice'>You decide not to disconnect the data channel.</span>")
			selected_io = null
			mode = UNWIRE
	update_icon()
	to_chat(user, "<span class='notice'>You set \the [src] to [mode].</span>")

#undef WIRE
#undef WIRING
#undef UNWIRE
#undef UNWIRING

/obj/item/device/integrated_electronics/debugger
	name = "circuit debugger"
	desc = "This small tool allows one working with custom machinery to directly set data to a specific pin, useful for writing \
	settings to specific circuits, or for debugging purposes.  It can also pulse activation pins."
	icon = 'icons/obj/electronic_assemblies.dmi'
	icon_state = "debugger"
	flags = CONDUCT
	w_class = 2
	var/data_to_write = null
	var/accepting_refs = 0

/obj/item/device/integrated_electronics/debugger/attack_self(mob/user)
	var/type_to_use = input("Please choose a type to use.","[src] type setting") as null|anything in list("string","number","ref", "null")
	if(!CanInteract(user, physical_state))
		return

	var/new_data = null
	switch(type_to_use)
		if("string")
			accepting_refs = 0
			new_data = input("Now type in a string.","[src] string writing") as null|text
			if(istext(new_data) && CanInteract(user, physical_state))
				data_to_write = new_data
				to_chat(user, "<span class='notice'>You set \the [src]'s memory to \"[new_data]\".</span>")
		if("number")
			accepting_refs = 0
			new_data = input("Now type in a number.","[src] number writing") as null|num
			if(isnum(new_data) && CanInteract(user, physical_state))
				data_to_write = new_data
				to_chat(user, "<span class='notice'>You set \the [src]'s memory to [new_data].</span>")
		if("ref")
			accepting_refs = 1
			to_chat(user, "<span class='notice'>You turn \the [src]'s ref scanner on.  Slide it across \
			an object for a ref of that object to save it in memory.</span>")
		if("null")
			data_to_write = null
			to_chat(user, "<span class='notice'>You set \the [src]'s memory to absolutely nothing.</span>")

/obj/item/device/integrated_electronics/debugger/afterattack(atom/target, mob/living/user, proximity)
	if(accepting_refs && proximity)
		data_to_write = weakref(target)
		visible_message("<span class='notice'>[user] slides \a [src]'s over \the [target].</span>")
		to_chat(user, "<span class='notice'>You set \the [src]'s memory to a reference to [target.name] \[Ref\].  The ref scanner is \
		now off.</span>")
		accepting_refs = 0

/obj/item/device/integrated_electronics/debugger/proc/write_data(var/datum/integrated_io/io, mob/user)
	if(io.io_type == DATA_CHANNEL)
		io.write_data_to_pin(data_to_write)
		var/data_to_show = data_to_write
		if(isweakref(data_to_write))
			var/weakref/w = data_to_write
			var/atom/A = w.resolve()
			data_to_show = A.name
		to_chat(user, "<span class='notice'>You write '[data_to_write ? data_to_show : "NULL"]' to the '[io]' pin of \the [io.holder].</span>")
	else if(io.io_type == PULSE_CHANNEL)
		io.holder.check_then_do_work(ignore_power = TRUE)
		to_chat(user, "<span class='notice'>You pulse \the [io.holder]'s [io].</span>")

	io.holder.interact(user) // This is to update the UI.




/obj/item/device/multitool
	var/datum/integrated_io/selected_io = null
	var/mode = 0


/obj/item/device/multitool/attack_self(mob/user)
	if(selected_io)
		selected_io = null
		to_chat(user, "<span class='notice'>You clear the wired connection from the multitool.</span>")
	else
		..()
	update_icon()

/obj/item/device/multitool/update_icon()
	if(selected_io)
		if(buffer)
			icon_state = "multitool_tracking"
		else
			icon_state = "multitool_red"
	else
		if(buffer)
			icon_state = "multitool_tracking_fail"
		else
			icon_state = "multitool"

/obj/item/device/multitool/proc/wire(var/datum/integrated_io/io, mob/user)
	if(!io.holder.assembly)
		to_chat(user, "<span class='warning'>\The [io.holder] needs to be secured inside an assembly first.</span>")
		return

	if(selected_io)
		if(io == selected_io)
			to_chat(user, "<span class='warning'>Wiring \the [selected_io.holder]'s [selected_io.name] into itself is rather pointless.</span>")
			return
		if(io.io_type != selected_io.io_type)
			to_chat(user, "<span class='warning'>Those two types of channels are incompatable.  The first is a [selected_io.io_type], \
			while the second is a [io.io_type].</span>")
			return
		if(io.holder.assembly && io.holder.assembly != selected_io.holder.assembly)
			to_chat(user, "<span class='warning'>Both \the [io.holder] and \the [selected_io.holder] need to be inside the same assembly.</span>")
			return
		selected_io.linked |= io
		io.linked |= selected_io

		to_chat(user, "<span class='notice'>You connect \the [selected_io.holder]'s [selected_io.name] to \the [io.holder]'s [io.name].</span>")
		selected_io.holder.interact(user) // This is to update the UI.
		selected_io = null

	else
		selected_io = io
		to_chat(user, "<span class='notice'>You link \the multitool to \the [selected_io.holder]'s [selected_io.name] data channel.</span>")

	update_icon()


/obj/item/device/multitool/proc/unwire(var/datum/integrated_io/io1, var/datum/integrated_io/io2, mob/user)
	if(!io1.linked.len || !io2.linked.len)
		to_chat(user, "<span class='warning'>There is nothing connected to the data channel.</span>")
		return

	if(!(io1 in io2.linked) || !(io2 in io1.linked) )
		to_chat(user, "<span class='warning'>These data pins aren't connected!</span>")
		return
	else
		io1.linked.Remove(io2)
		io2.linked.Remove(io1)
		to_chat(user, "<span class='notice'>You clip the data connection between the [io1.holder.displayed_name]'s \
		[io1.name] and the [io2.holder.displayed_name]'s [io2.name].</span>")
		io1.holder.interact(user) // This is to update the UI.
		update_icon()



/obj/item/device/integrated_electronics/analyzer
	name = "circuit analyzer"
	desc = "This tool can scan an assembly in generate code necessary to recreate it in a circuit printer."
	icon = 'icons/obj/electronic_assemblies.dmi'
	icon_state = "analyzer"
	flags = CONDUCT
	w_class = 2
	var/list/circuit_list = list()
	var/list/assembly_list = list()

/obj/item/device/integrated_electronics/analyzer/initialize()

	assembly_list.Add(
			new /obj/item/device/electronic_assembly(null),
			new /obj/item/device/electronic_assembly/medium(null),
			new /obj/item/device/electronic_assembly/large(null),
			new /obj/item/device/electronic_assembly/drone(null),
		)

/obj/item/device/integrated_electronics/analyzer/afterattack(var/atom/A, var/mob/living/user)
	visible_message( "<span class='notice'>attempt to scan</span>")
	if(ispath(A.type,/obj/item/device/electronic_assembly)||ispath(A.type,/obj/item/weapon/implant/integrated_circuit))
		var/i = 0
		var/j = 0
		var/HTML ="start.assembly{{*}}"  //1-st in chapters.1-st block is just to secure start of program from excess symbols.{{*}} is delimeter for chapters.
		visible_message( "<span class='notice'>start of scan</span>")
		for(var/obj/item/I in assembly_list)
			if( A.type == I.type )
				HTML += I.name+"=-="+A.name         //2-nd block.assembly type and name. Maybe in future there will also be color and accesories.
				break
		/*
		If(I.name == "electronic implant")
			var/obj/item/weapon/implant/integrated_circuit/PI = PA        //now it can't recreate electronic implants.and devices maybe I'll fix it later.
			var/obj/item/device/electronic_assembly/implant/PIC = PI.IC
			A = PIC
			*/
		HTML += "{{*}}components"                   //3-rd block.components. First element is useless.delimeter for elements is ^%^.In element first circuit's default name.Second is user given name.delimiter is =-=

		for(var/obj/item/integrated_circuit/IC in A.contents)
			i =i + 1
			HTML += "^%^"+IC.name+"=-="+IC.displayed_name
		if(i == 0)
			return
		HTML += "{{*}}values"					//4-th block.values. First element is useless.delimeter for elements is ^%^.In element first i/o id.Second is data type.third is value.delimiter is :+:

		i = 0
		var/val
		var/list/inp=list()
		var/list/out=list()
		var/list/act=list()
		var/list/ioa=list()
		for(var/obj/item/integrated_circuit/IC in A.contents)
			i += 1
			j = 0
			for(var/datum/integrated_io/IN in IC.inputs)
				j = j + 1
				inp[IN] = "[i]i[j]"
				if(islist(IN.data))
					val = list2params(IN.data)
					HTML += "^%^"+"[i]i[j]:+:list:+:[val]"
				else if(isnum(IN.data))
					val= IN.data
					HTML += "^%^"+"[i]i[j]:+:num:+:[val]"
				else if(istext(IN.data))
					val = IN.data
					HTML += "^%^"+"[i]i[j]:+:text:+:[val]"
			j=0
			for(var/datum/integrated_io/OUT in IC.outputs)               //Also this block uses for setting all i/o id's
				j=j+1
				out[OUT] = "[i]o[j]"
			j=0
			for(var/datum/integrated_io/ACT in IC.activators)
				j=j+1
				act[ACT] = "[i]a[j]"
		ioa.Add(inp)
		ioa.Add(out)
		ioa.Add(act)
		HTML += "{{*}}wires"
		for(var/datum/integrated_io/P in inp)							//5-th block.wires. First element is useless.delimeter for elements is ^%^.In element first i/o id.Second too.delimiter is =-=

			for(var/datum/integrated_io/C in P.linked)
				HTML += "^%^"+inp[P]+"=-="+ioa[C]
		for(var/datum/integrated_io/P in out)
			for(var/datum/integrated_io/C in P.linked)
				HTML += "^%^"+out[P]+"=-="+ioa[C]
		for(var/datum/integrated_io/P in act)
			for(var/datum/integrated_io/C in P.linked)
				HTML += "^%^"+act[P]+"=-="+ioa[C]
		HTML += "{{*}}end"											//6 block.like 1.
		visible_message( "<span class='notice'>[A] has been scanned,</span>")
		user << browse(jointext(HTML, null), "window=analyzer;size=[500]x[600];border=1;can_resize=1;can_close=1;can_minimize=1")
	else
		..()








/obj/item/weapon/storage/bag/circuits
	name = "circuit kit"
	desc = "This kit's essential for any circuitry projects."
	icon = 'icons/obj/electronic_assemblies.dmi'
	icon_state = "circuit_kit"
	w_class = 3
	display_contents_with_number = 0
	can_hold = list(
		/obj/item/integrated_circuit,
		/obj/item/weapon/storage/bag/circuits/mini,
		/obj/item/device/electronic_assembly,
		/obj/item/device/integrated_electronics,
		/obj/item/weapon/crowbar,
		/obj/item/weapon/screwdriver,
		/obj/item/device/multitool
		)

/obj/item/weapon/storage/bag/circuits/basic/New()
	..()
	spawn(2 SECONDS) // So the list has time to initialize.
//		for(var/obj/item/integrated_circuit/IC in all_integrated_circuits)
//			if(IC.spawn_flags & IC_SPAWN_DEFAULT)
//				for(var/i = 1 to 4)
//					new IC.type(src)
		new /obj/item/weapon/storage/bag/circuits/mini/arithmetic(src)
		new /obj/item/weapon/storage/bag/circuits/mini/trig(src)
		new /obj/item/weapon/storage/bag/circuits/mini/input(src)
		new /obj/item/weapon/storage/bag/circuits/mini/output(src)
		new /obj/item/weapon/storage/bag/circuits/mini/memory(src)
		new /obj/item/weapon/storage/bag/circuits/mini/logic(src)
		new /obj/item/weapon/storage/bag/circuits/mini/time(src)
		new /obj/item/weapon/storage/bag/circuits/mini/reagents(src)
		new /obj/item/weapon/storage/bag/circuits/mini/transfer(src)
		new /obj/item/weapon/storage/bag/circuits/mini/converter(src)
		new /obj/item/weapon/storage/bag/circuits/mini/power(src)

		new /obj/item/device/electronic_assembly(src)
		new /obj/item/device/assembly/electronic_assembly(src)
		new /obj/item/device/assembly/electronic_assembly(src)
		new /obj/item/device/multitool(src)
		new /obj/item/weapon/screwdriver(src)
		new /obj/item/weapon/crowbar(src)
		make_exact_fit()

/obj/item/weapon/storage/bag/circuits/all/New()
	..()
	spawn(2 SECONDS) // So the list has time to initialize.
		new /obj/item/weapon/storage/bag/circuits/mini/arithmetic/all(src)
		new /obj/item/weapon/storage/bag/circuits/mini/trig/all(src)
		new /obj/item/weapon/storage/bag/circuits/mini/input/all(src)
		new /obj/item/weapon/storage/bag/circuits/mini/output/all(src)
		new /obj/item/weapon/storage/bag/circuits/mini/memory/all(src)
		new /obj/item/weapon/storage/bag/circuits/mini/logic/all(src)
		new /obj/item/weapon/storage/bag/circuits/mini/smart/all(src)
		new /obj/item/weapon/storage/bag/circuits/mini/manipulation/all(src)
		new /obj/item/weapon/storage/bag/circuits/mini/time/all(src)
		new /obj/item/weapon/storage/bag/circuits/mini/reagents/all(src)
		new /obj/item/weapon/storage/bag/circuits/mini/transfer/all(src)
		new /obj/item/weapon/storage/bag/circuits/mini/converter/all(src)
		new /obj/item/weapon/storage/bag/circuits/mini/power/all(src)

		new /obj/item/device/electronic_assembly(src)
		new /obj/item/device/electronic_assembly/medium(src)
		new /obj/item/device/electronic_assembly/large(src)
		new /obj/item/device/electronic_assembly/drone(src)
		new /obj/item/device/integrated_electronics/wirer(src)
		new /obj/item/device/integrated_electronics/debugger(src)
		new /obj/item/weapon/crowbar(src)
		make_exact_fit()

/obj/item/weapon/storage/bag/circuits/mini/
	name = "circuit box"
	desc = "Used to partition categories of circuits, for a neater workspace."
	w_class = 2
	display_contents_with_number = 1
	can_hold = list(/obj/item/integrated_circuit)
	var/spawn_flags_to_use = IC_SPAWN_DEFAULT

/obj/item/weapon/storage/bag/circuits/mini/arithmetic
	name = "arithmetic circuit box"
	desc = "Warning: Contains math."
	icon_state = "box_arithmetic"

/obj/item/weapon/storage/bag/circuits/mini/arithmetic/all // Don't believe this will ever be needed.
	spawn_flags_to_use = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/weapon/storage/bag/circuits/mini/arithmetic/New()
	..()
	for(var/obj/item/integrated_circuit/arithmetic/IC in all_integrated_circuits)
		if(IC.spawn_flags & spawn_flags_to_use)
			for(var/i = 1 to 4)
				new IC.type(src)
	make_exact_fit()


/obj/item/weapon/storage/bag/circuits/mini/trig
	name = "trig circuit box"
	desc = "Danger: Contains more math."
	icon_state = "box_trig"

/obj/item/weapon/storage/bag/circuits/mini/trig/all // Ditto
	spawn_flags_to_use = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/weapon/storage/bag/circuits/mini/trig/New()
	..()
	for(var/obj/item/integrated_circuit/trig/IC in all_integrated_circuits)
		if(IC.spawn_flags & spawn_flags_to_use)
			for(var/i = 1 to 4)
				new IC.type(src)
	make_exact_fit()


/obj/item/weapon/storage/bag/circuits/mini/input
	name = "input circuit box"
	desc = "Tell these circuits everything you know."
	icon_state = "box_input"

/obj/item/weapon/storage/bag/circuits/mini/input/all
	spawn_flags_to_use = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/weapon/storage/bag/circuits/mini/input/New()
	..()
	for(var/obj/item/integrated_circuit/input/IC in all_integrated_circuits)
		if(IC.spawn_flags & spawn_flags_to_use)
			for(var/i = 1 to 4)
				new IC.type(src)
	make_exact_fit()


/obj/item/weapon/storage/bag/circuits/mini/output
	name = "output circuit box"
	desc = "Circuits to interface with the world beyond itself."
	icon_state = "box_output"

/obj/item/weapon/storage/bag/circuits/mini/output/all
	spawn_flags_to_use = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/weapon/storage/bag/circuits/mini/output/New()
	..()
	for(var/obj/item/integrated_circuit/output/IC in all_integrated_circuits)
		if(IC.spawn_flags & spawn_flags_to_use)
			for(var/i = 1 to 4)
				new IC.type(src)
	make_exact_fit()


/obj/item/weapon/storage/bag/circuits/mini/memory
	name = "memory circuit box"
	desc = "Machines can be quite forgetful without these."
	icon_state = "box_memory"

/obj/item/weapon/storage/bag/circuits/mini/memory/all
	spawn_flags_to_use = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/weapon/storage/bag/circuits/mini/memory/New()
	..()
	for(var/obj/item/integrated_circuit/memory/IC in all_integrated_circuits)
		if(IC.spawn_flags & spawn_flags_to_use)
			for(var/i = 1 to 4)
				new IC.type(src)
	make_exact_fit()


/obj/item/weapon/storage/bag/circuits/mini/logic
	name = "logic circuit box"
	desc = "May or may not be Turing complete."
	icon_state = "box_logic"

/obj/item/weapon/storage/bag/circuits/mini/logic/all
	spawn_flags_to_use = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/weapon/storage/bag/circuits/mini/logic/New()
	..()
	for(var/obj/item/integrated_circuit/logic/IC in all_integrated_circuits)
		if(IC.spawn_flags & spawn_flags_to_use)
			for(var/i = 1 to 4)
				new IC.type(src)
	make_exact_fit()


/obj/item/weapon/storage/bag/circuits/mini/time
	name = "time circuit box"
	desc = "No time machine parts, sadly."
	icon_state = "box_time"

/obj/item/weapon/storage/bag/circuits/mini/time/all
	spawn_flags_to_use = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/weapon/storage/bag/circuits/mini/time/New()
	..()
	for(var/obj/item/integrated_circuit/time/IC in all_integrated_circuits)
		if(IC.spawn_flags & spawn_flags_to_use)
			for(var/i = 1 to 4)
				new IC.type(src)
	make_exact_fit()


/obj/item/weapon/storage/bag/circuits/mini/reagents
	name = "reagent circuit box"
	desc = "Unlike most electronics, these circuits are supposed to come in contact with liquids."
	icon_state = "box_reagents"

/obj/item/weapon/storage/bag/circuits/mini/reagents/all
	spawn_flags_to_use = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/weapon/storage/bag/circuits/mini/reagents/New()
	..()
	for(var/obj/item/integrated_circuit/reagent/IC in all_integrated_circuits)
		if(IC.spawn_flags & spawn_flags_to_use)
			for(var/i = 1 to 4)
				new IC.type(src)
	make_exact_fit()


/obj/item/weapon/storage/bag/circuits/mini/transfer
	name = "transfer circuit box"
	desc = "Useful for moving data representing something arbitrary to another arbitrary virtual place."
	icon_state = "box_transfer"

/obj/item/weapon/storage/bag/circuits/mini/transfer/all
	spawn_flags_to_use = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/weapon/storage/bag/circuits/mini/transfer/New()
	..()
	for(var/obj/item/integrated_circuit/transfer/IC in all_integrated_circuits)
		if(IC.spawn_flags & spawn_flags_to_use)
			for(var/i = 1 to 4)
				new IC.type(src)
	make_exact_fit()


/obj/item/weapon/storage/bag/circuits/mini/converter
	name = "converter circuit box"
	desc = "Transform one piece of data to another type of data with these."
	icon_state = "box_converter"

/obj/item/weapon/storage/bag/circuits/mini/converter/all
	spawn_flags_to_use = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/weapon/storage/bag/circuits/mini/converter/New()
	..()
	for(var/obj/item/integrated_circuit/converter/IC in all_integrated_circuits)
		if(IC.spawn_flags & spawn_flags_to_use)
			for(var/i = 1 to 4)
				new IC.type(src)
	make_exact_fit()

/obj/item/weapon/storage/bag/circuits/mini/smart
	name = "smart box"
	desc = "Sentience not included."
	icon_state = "box_ai"

/obj/item/weapon/storage/bag/circuits/mini/smart/all
	spawn_flags_to_use = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/weapon/storage/bag/circuits/mini/smart/New()
	..()
	for(var/obj/item/integrated_circuit/smart/IC in all_integrated_circuits)
		if(IC.spawn_flags & spawn_flags_to_use)
			for(var/i = 1 to 4)
				new IC.type(src)
	make_exact_fit()

/obj/item/weapon/storage/bag/circuits/mini/manipulation
	name = "manipulation box"
	desc = "Make your machines actually useful with these."
	icon_state = "box_manipulation"

/obj/item/weapon/storage/bag/circuits/mini/manipulation/all
	spawn_flags_to_use = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/weapon/storage/bag/circuits/mini/manipulation/New()
	..()
	for(var/obj/item/integrated_circuit/manipulation/IC in all_integrated_circuits)
		if(IC.spawn_flags & spawn_flags_to_use)
			for(var/i = 1 to 4)
				new IC.type(src)
	make_exact_fit()


/obj/item/weapon/storage/bag/circuits/mini/power
	name = "power circuit box"
	desc = "Electronics generally require electricity."
	icon_state = "box_power"

/obj/item/weapon/storage/bag/circuits/mini/power/all
	spawn_flags_to_use = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/weapon/storage/bag/circuits/mini/power/New()
	..()
	for(var/obj/item/integrated_circuit/passive/power/IC in all_integrated_circuits)
		if(IC.spawn_flags & spawn_flags_to_use)
			for(var/i = 1 to 4)
				new IC.type(src)
	for(var/obj/item/integrated_circuit/power/IC in all_integrated_circuits)
		if(IC.spawn_flags & spawn_flags_to_use)
			for(var/i = 1 to 4)
				new IC.type(src)
	make_exact_fit()


