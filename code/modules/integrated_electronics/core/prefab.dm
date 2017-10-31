/obj/item/device/integrated_electronics/prefab
	name = "prefab"
	desc = "new machine in package"
	icon = 'icons/obj/electronic_assemblies.dmi'
	icon_state = "box_template"
	w_class = WEIGHT_CLASS_BULKY
	var/program="blank"
	var/list/as_names = list()
	var/list/cir_names = list()


/obj/item/device/integrated_electronics/prefab/attack_self(var/mob/user)
	if(program)
		if(program != "blank")
			assemble(program)

/obj/item/device/integrated_electronics/prefab/Initialize()
	var/list/assembly_list = list(
			new /obj/item/device/electronic_assembly(null),
			new /obj/item/device/electronic_assembly/medium(null),
			new /obj/item/device/electronic_assembly/large(null),
			new /obj/item/device/electronic_assembly/drone(null),
			//new /obj/item/weapon/implant/integrated_circuit(null),
			//new /obj/item/device/assembly/electronic_assembly(null)
		)
	for(var/obj/item/I in assembly_list)
		as_names[I.name] = I.type
	for(var/obj/item/integrated_circuit/IC in all_integrated_circuits)
		if((IC.spawn_flags & IC_SPAWN_DEFAULT) || (IC.spawn_flags & IC_SPAWN_RESEARCH))
			cir_names[IC.name] = IC.type

/obj/item/device/integrated_electronics/prefab/proc/assemble(var/program)
	var/debug = 0
	var/list/chap = splittext( program ,"{{*}}")
	var/list/elements = list()
	var/list/elements_input = list()
	var/list/element = list()
	var/obj/item/AS
	var/PA
	var/i = 0
	var/j = 0
	var/list/ioa = list()
	var/datum/integrated_io/IO
	var/datum/integrated_io/IO2
	if(debug)
		visible_message( "<span class='notice'>started successful</span>")
	if(chap[2] != "")
		if(debug)
			visible_message( "<span class='notice'>assembly</span>")
		element = splittext( chap[2] ,"=-=")
		PA = as_names[element[1]]
		AS = new PA(null)
		AS.loc = src
		AS.name = element[2]
	else
		return //what's the point if there is no assembly?
	if(chap[3] != "components")   //if there is only one word,there is no components.
		elements_input = splittext( chap[3] ,"^%^")
		if(debug)
			visible_message( "<span class='notice'>components[elements_input.len]</span>")
		i = 0
		elements = list()
		for(var/elem in elements_input)
			i=i+1
			if(i>1)
				elements.Add(elem)            //I don't know,why Cut or copy don't works. If somebody can fix it, it should be fixed.
		if(debug)
			visible_message( "<span class='notice'>components[elements.len]</span>")
		if(elements_input.len<1)
			return
		if(debug)
			visible_message( "<span class='notice'>inserting components[elements.len]</span>")
		var/obj/item/integrated_circuit/comp
		i=0
		for(var/E in elements)
			i=i+1
			element = splittext( E ,"=-=")
			if(debug)
				visible_message( "<span class='notice'>[E]</span>")
			PA = cir_names[element[1]]
			comp = new PA(null)
			comp.loc = AS
			comp.displayed_name = element[2]
			comp.assembly = AS
			j = 0
			for(var/datum/integrated_io/IN in comp.inputs)
				j = j + 1
				ioa["[i]i[j]"] = IN
				if(debug)
					visible_message( "<span class='notice'>[i]i[j]</span>")
			j = 0
			for(var/datum/integrated_io/OUT in comp.outputs)               //Also this block uses for setting all i/o id's
				j=j+1
				ioa["[i]o[j]"] = OUT
				if(debug)
					visible_message( "<span class='notice'>[i]o[j]</span>")
			j = 0
			for(var/datum/integrated_io/ACT in comp.activators)
				j=j+1
				ioa["[i]a[j]"] = ACT
				if(debug)
					visible_message( "<span class='notice'>[i]a[j]</span>")

	else
		return
	if(!AS.contents.len)
		return
	if(chap[4] != "values")   //if there is only one word,there is no values
		elements_input = splittext( chap[4] ,"^%^")
		if(debug)
			visible_message( "<span class='notice'>values[elements_input.len]</span>")
		i=0
		elements = list()
		for(var/elem in elements_input)
			i=i+1
			if(i>1)
				elements.Add(elem)
		if(debug)
			visible_message( "<span class='notice'>values[elements.len]</span>")
		if(elements.len>0)
			if(debug)
				visible_message( "<span class='notice'>setting values[elements.len]</span>")
			for(var/E in elements)
				element = splittext( E ,":+:")
				if(debug)
					visible_message( "<span class='notice'>[E]</span>")
				IO = ioa[element[1]]
				if(element[2]=="text")
					IO.write_data_to_pin(element[3])
				else if(element[2]=="num")
					IO.write_data_to_pin(text2num(element[3]))
				else if(element[2]=="list")
					IO.write_data_to_pin(params2list(element[3]))
	if(chap[5] != "wires")   //if there is only one word,there is no wires
		elements_input = splittext( chap[5] ,"^%^")
		i=0
		elements = list()
		if(debug)
			visible_message( "<span class='notice'>wires[elements_input.len]</span>")
		for(var/elem in elements_input)
			i=i+1
			if(i>1)
				elements.Add(elem)
		if(debug)
			visible_message( "<span class='notice'>wires[elements.len]</span>")
		if(elements.len>0)
			if(debug)
				visible_message( "<span class='notice'>setting wires[elements.len]</span>")
			for(var/E in elements)
				element = splittext( E ,"=-=")
				if(debug)
					visible_message( "<span class='notice'>[E]</span>")
				IO = ioa[element[1]]
				IO2 = ioa[element[2]]
				IO.linked |= IO2

	AS.loc = get_turf(src)
	qdel(src)
