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
	flags_1 = CONDUCT_1
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
	flags_1 = CONDUCT_1 | NOBLUDGEON_1
	w_class = 2
	var/data_to_write = null
	var/accepting_refs = 0

/obj/item/device/integrated_electronics/debugger/attack_self(mob/user)
	var/type_to_use = input("Please choose a type to use.","[src] type setting") as null|anything in list("string","number","ref", "null")
	if(!user.IsAdvancedToolUser())
		return

	var/new_data = null
	switch(type_to_use)
		if("string")
			accepting_refs = 0
			new_data = input("Now type in a string.","[src] string writing") as null|text
			if(istext(new_data) && user.IsAdvancedToolUser())
				data_to_write = new_data
				to_chat(user, "<span class='notice'>You set \the [src]'s memory to \"[new_data]\".</span>")
		if("number")
			accepting_refs = 0
			new_data = input("Now type in a number.","[src] number writing") as null|num
			if(isnum(new_data) && user.IsAdvancedToolUser())
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
			var/datum/weakref/w = data_to_write
			var/atom/A = w.resolve()
			data_to_show = A.name
		to_chat(user, "<span class='notice'>You write '[data_to_write ? data_to_show : "NULL"]' to the '[io]' pin of \the [io.holder].</span>")
	else if(io.io_type == PULSE_CHANNEL)
		io.holder.check_then_do_work(ignore_power = TRUE)
		to_chat(user, "<span class='notice'>You pulse \the [io.holder]'s [io].</span>")

	io.holder.interact(user) // This is to update the UI.

/obj/item/device/integrated_electronics/analyzer
	name = "circuit analyzer"
	desc = "This tool can scan an assembly and generate code necessary to recreate it in a circuit printer."
	icon = 'icons/obj/electronic_assemblies.dmi'
	icon_state = "analyzer"
	flags_1 = CONDUCT_1
	w_class = 2
	var/list/circuit_list = list()
	var/list/assembly_list = list(new /obj/item/device/electronic_assembly(null),
			new /obj/item/device/electronic_assembly/medium(null),
			new /obj/item/device/electronic_assembly/large(null),
			new /obj/item/device/electronic_assembly/drone(null))

/obj/item/device/integrated_electronics/analyzer/afterattack(var/atom/A, var/mob/living/user)
	visible_message( "<span class='notice'>attempt to scan</span>")
	if(ispath(A.type,/obj/item/device/electronic_assembly))
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




