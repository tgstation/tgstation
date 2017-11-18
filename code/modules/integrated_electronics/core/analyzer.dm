

/obj/item/device/integrated_electronics/analyzer
	name = "circuit analyzer"
	desc = "This tool can scan an assembly and generate code necessary to recreate it in a circuit printer."
	icon = 'icons/obj/electronic_assemblies.dmi'
	icon_state = "analyzer"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_SMALL
	var/list/circuit_list = list()
	var/list/assembly_list = list(/obj/item/device/electronic_assembly,
			/obj/item/device/electronic_assembly/medium,
			/obj/item/device/electronic_assembly/large,
			/obj/item/device/electronic_assembly/drone)

/obj/item/device/integrated_electronics/analyzer/afterattack(var/atom/A, var/mob/living/user)
	visible_message( "<span class='notice'>attempt to scan</span>")
	if(ispath(A.type,/obj/item/device/electronic_assembly))
		var/i = 0
		var/j = 0
		var/HTML ="start.assembly{{*}}"  //1-st in chapters.1-st block is just to secure start of program from excess symbols.{{*}} is delimeter for chapters.
		visible_message( "<span class='notice'>start of scan</span>")
		for(var/ix in 1 to assembly_list.len)
			var/obj/item/I = assembly_list[ix]
			if( A.type == I )
				HTML += initial(I.name) +"=-="+A.name         //2-nd block.assembly type and name. Maybe in future there will also be color and accesories.
				break

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
			if(IC.inputs && IC.inputs.len)
				for(j in 1 to IC.inputs.len)
					var/datum/integrated_io/IN =IC.inputs[j]
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
			if(IC.outputs && IC.outputs.len)
				for(j in 1 to IC.outputs.len)               //Also this block uses for setting all i/o id's
					var/datum/integrated_io/OUT = IC.outputs[j]
					out[OUT] = "[i]o[j]"
			if(IC.activators && IC.activators.len)
				for(j in 1 to IC.activators.len)
					var/datum/integrated_io/ACT = IC.activators[j]
					act[ACT] = "[i]a[j]"
		ioa.Add(inp)
		ioa.Add(out)
		ioa.Add(act)
		HTML += "{{*}}wires"
		if(inp && inp.len)
			for(i in 1 to inp.len)							//5-th block.wires. First element is useless.delimeter for elements is ^%^.In element first i/o id.Second too.delimiter is =-=
				var/datum/integrated_io/P = inp[i]
				for(j in 1 to P.linked.len)
					var/datum/integrated_io/C = P.linked[j]
					HTML += "^%^"+inp[P]+"=-="+ioa[C]
		if(out && out.len)
			for(i in 1 to out.len)							//5-th block.wires. First element is useless.delimeter for elements is ^%^.In element first i/o id.Second too.delimiter is =-=
				var/datum/integrated_io/P = out[i]
				for(j in 1 to P.linked.len)
					var/datum/integrated_io/C = P.linked[j]
					HTML += "^%^"+out[P]+"=-="+ioa[C]
		if(act && act.len)
			for(i in 1 to act.len)							//5-th block.wires. First element is useless.delimeter for elements is ^%^.In element first i/o id.Second too.delimiter is =-=
				var/datum/integrated_io/P = act[i]
				for(j in 1 to P.linked.len)
					var/datum/integrated_io/C = P.linked[j]
					HTML += "^%^"+act[P]+"=-="+ioa[C]

		HTML += "{{*}}end"											//6 block.like 1.
		visible_message( "<span class='notice'>[A] has been scanned,</span>")
		user << browse(jointext(HTML, null), "window=analyzer;size=[500]x[600];border=1;can_resize=1;can_close=1;can_minimize=1")
	else
		..()




