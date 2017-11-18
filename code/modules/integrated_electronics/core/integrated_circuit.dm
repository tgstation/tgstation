/obj/item/integrated_circuit
	name = "integrated circuit"
	desc = "It's a tiny chip!  This one doesn't seem to do much, however."
	icon = 'icons/obj/electronic_assemblies.dmi'
	icon_state = "template"
	w_class = WEIGHT_CLASS_TINY
	var/obj/item/device/electronic_assembly/assembly // Reference to the assembly holding this circuit, if any.
	var/extended_desc
	var/list/inputs = list()
	var/list/inputs_default = list()// Assoc list which will fill a pin with data upon creation.  e.g. "2" = 0 will set input pin 2 to equal 0 instead of null.
	var/list/outputs = list()
	var/list/outputs_default =list()// Ditto, for output.
	var/list/activators = list()
	var/next_use = 0 				// Uses world.time
	var/complexity = 1 				// This acts as a limitation on building machines, more resource-intensive components cost more 'space'.
	var/size = 1						// This acts as a limitation on building machines, bigger components cost more 'space'. -1 for size 0
	var/cooldown_per_use = 9		// Circuits are limited in how many times they can be work()'d by this variable.
	var/power_draw_per_use = 0 		// How much power is drawn when work()'d.
	var/power_draw_idle = 0			// How much power is drawn when doing nothing.
	var/spawn_flags					// Used for world initializing, see the #defines above.
	var/category_text = "NO CATEGORY THIS IS A BUG"	// To show up on circuit printer, and perhaps other places.
	var/removable = TRUE 			// Determines if a circuit is removable from the assembly.
	var/displayed_name = ""
	var/allow_multitool = TRUE		// Allows additional multitool functionality
									// Used as a global var, (Do not set manually in children).

/*
	Integrated circuits are essentially modular machines.  Each circuit has a specific function, and combining them inside Electronic Assemblies allows
a creative player the means to solve many problems.  Circuits are held inside an electronic assembly, and are wired using special tools.
*/

/obj/item/integrated_circuit/examine(mob/user)
	interact(user)
	external_examine(user)
	. = ..()

// This should be used when someone is examining while the case is opened.
/obj/item/integrated_circuit/proc/internal_examine(mob/user)
	to_chat(user, "This board has [inputs.len] input pin\s, [outputs.len] output pin\s and [activators.len] activation pin\s.")
	for(var/k in 1 to inputs.len)
		var/datum/integrated_io/I = inputs[k]
		if(I.linked.len)
			to_chat(user, "The '[I]' is connected to [I.get_linked_to_desc()].")
	for(var/k in 1 to outputs.len)
		var/datum/integrated_io/O = outputs[k]
		if(O.linked.len)
			to_chat(user, "The '[O]' is connected to [O.get_linked_to_desc()].")
	for(var/k in 1 to activators.len)
		var/datum/integrated_io/activate/A = activators[k]
		if(A.linked.len)
			to_chat(user, "The '[A]' is connected to [A.get_linked_to_desc()].")
	any_examine(user)
	interact(user)

// This should be used when someone is examining from an 'outside' perspective, e.g. reading a screen or LED.
/obj/item/integrated_circuit/proc/external_examine(mob/user)
	any_examine(user)

/obj/item/integrated_circuit/proc/any_examine(mob/user)
	return

/obj/item/integrated_circuit/proc/check_interactivity(mob/user)
	if(assembly)
		return assembly.check_interactivity(user)
	else
		return user.canUseTopic(src,be_close = TRUE)

/obj/item/integrated_circuit/Initialize()
	displayed_name = name
	setup_io(inputs, /datum/integrated_io, inputs_default)
	setup_io(outputs, /datum/integrated_io, outputs_default)
	setup_io(activators, /datum/integrated_io/activate)
	..()

/obj/item/integrated_circuit/proc/on_data_written() //Override this for special behaviour when new data gets pushed to the circuit.
	return

/obj/item/integrated_circuit/Destroy()
	QDEL_LIST(inputs)
	QDEL_LIST(outputs)
	QDEL_LIST(activators)
	. = ..()

/obj/item/integrated_circuit/emp_act(severity)
	for(var/k in 1 to inputs.len)
		var/datum/integrated_io/I = inputs[k]
		I.scramble()
	for(var/k in 1 to outputs.len)
		var/datum/integrated_io/O = outputs[k]
		O.scramble()
	for(var/k in 1 to activators.len)
		var/datum/integrated_io/activate/A = activators[k]
		A.scramble()


/obj/item/integrated_circuit/verb/rename_component()
	set name = "Rename Circuit"
	set category = "Object"
	set desc = "Rename your circuit, useful to stay organized."

	var/mob/M = usr
	if(!check_interactivity(M))
		return

	var/input = reject_bad_name(stripped_input(M, "What do you want to name this?", "Rename", src.name),1)
	if(src && input && check_interactivity(M))
		to_chat(M, "<span class='notice'>The circuit '[src.name]' is now labeled '[input]'.</span>")
		displayed_name = input

/obj/item/integrated_circuit/interact(mob/user)
	if(!check_interactivity(user))
		return

	var/window_height = 350
	var/window_width = 600

	var/table_edge_width = "30%"
	var/table_middle_width = "40%"

	var/HTML = list()
	HTML += "<html><head><title>[src.displayed_name]</title></head><body>"
	HTML += "<div align='center'>"
	HTML += "<table border='1' style='undefined;table-layout: fixed; width: 80%'>"

	HTML += "<br><a href='?src=[REF(src)];return=1'>\[Return to Assembly\]</a>"

	HTML += "<br><a href='?src=[REF(src)];'>\[Refresh\]</a>  |  "
	HTML += "<a href='?src=[REF(src)];rename=1'>\[Rename\]</a>  |  "
	HTML += "<a href='?src=[REF(src)];scan=1'>\[Scan with Device\]</a>  |  "
	if(src.removable)
		HTML += "<a href='?src=[REF(src)];remove=1'>\[Remove\]</a><br>"

	HTML += "<colgroup>"
	HTML += "<col style='width: [table_edge_width]'>"
	HTML += "<col style='width: [table_middle_width]'>"
	HTML += "<col style='width: [table_edge_width]'>"
	HTML += "</colgroup>"

	var/column_width = 3
	var/row_height = max(inputs.len, outputs.len, 1)

	for(var/i = 1 to row_height)
		HTML += "<tr>"
		for(var/j = 1 to column_width)
			var/datum/integrated_io/io = null
			var/words = list()
			var/height = 1
			switch(j)
				if(1)
					io = get_pin_ref(IC_INPUT, i)
					if(io)
						words += "<b><a href=?src=[REF(src)];pin_name=1;pin=[REF(io)]>[io.display_pin_type()] [io.name]</a> <a href=?src=[REF(src)];pin_data=1;pin=[REF(io)]>[io.display_data(io.data)]</a></b><br>"
						if(io.linked.len)
							for(var/k in 1 to io.linked.len)
								var/datum/integrated_io/linked = io.linked[k]
								words += "<a href=?src=[REF(src)];pin_unwire=1;pin=[REF(io)];link=[REF(linked)]>[linked]</a> \
								@ <a href=?src=[REF(linked.holder)];examine=1;>[linked.holder.displayed_name]</a><br>"

						if(outputs.len > inputs.len)
							height = 1
				if(2)
					if(i == 1)
						words += "[src.displayed_name]<br>[src.name != src.displayed_name ? "([src.name])":""]<hr>[src.desc]"
						height = row_height
					else
						continue
				if(3)
					io = get_pin_ref(IC_OUTPUT, i)
					if(io)
						words += "<b><a href=?src=[REF(src)];pin_name=1;pin=[REF(io)]>[io.display_pin_type()] [io.name]</a> <a href=?src=[REF(src)];pin_data=1;pin=[REF(io)]>[io.display_data(io.data)]</a></b><br>"
						if(io.linked.len)
							for(var/k in 1 to io.linked.len)
								var/datum/integrated_io/linked = io.linked[k]
								words += "<a href=?src=[REF(src)];pin_unwire=1;pin=[REF(io)];link=[REF(linked)]>[linked]</a> \
								@ <a href=?src=[REF(linked.holder)];examine=1;>[linked.holder.displayed_name]</a><br>"

						if(inputs.len > outputs.len)
							height = 1
			HTML += "<td align='center' rowspan='[height]'>[jointext(words, null)]</td>"
		HTML += "</tr>"

	for(var/activator in activators)
		var/datum/integrated_io/io = activator
		var/words = list()

		words += "<b><a href=?src=[REF(src)];pin_name=1;pin=[REF(io)]><font color='FF0000'>[io]</font></a> <a href=?src=[REF(src)];pin_data=1;pin=[REF(io)]><font color='FF0000'>[io.data?"\<PULSE OUT\>":"\<PULSE IN\>"]</font></a></b><br>"
		if(io.linked.len)
			for(var/k in 1 to io.linked.len)
				var/datum/integrated_io/linked = io.linked[k]
				words += "<a href=?src=[REF(src)];pin_unwire=1;pin=[REF(io)];link=[REF(linked)]><font color='FF0000'>[linked]</font></a> \
				@ <a href=?src=[REF(linked.holder)];examine=1;><font color='FF0000'>[linked.holder.displayed_name]</font></a><br>"

		HTML += "<tr>"
		HTML += "<td colspan='3' align='center'>[jointext(words, null)]</td>"
		HTML += "</tr>"

	HTML += "</table>"
	HTML += "</div>"

	HTML += "<br><font color='0000AA'>Complexity: [complexity]</font>"
	if(power_draw_idle)
		HTML += "<br><font color='0000AA'>Power Draw: [power_draw_idle] W (Idle)</font>"
	if(power_draw_per_use)
		HTML += "<br><font color='0000AA'>Power Draw: [power_draw_per_use] W (Active)</font>" // Borgcode says that powercells' checked_use() takes joules as input.
	HTML += "<br><font color='0000AA'>[extended_desc]</font>"

	HTML += "</body></html>"
	if(src.assembly)
		user << browse(jointext(HTML, null), "window=assembly-[REF(src.assembly)];size=[window_width]x[window_height];border=1;can_resize=1;can_close=1;can_minimize=1")
	else
		user << browse(jointext(HTML, null), "window=circuit-[REF(src)];size=[window_width]x[window_height];border=1;can_resize=1;can_close=1;can_minimize=1")

	onclose(user, "assembly-[REF(src.assembly)]")

/obj/item/integrated_circuit/Topic(href, href_list)
	if(!check_interactivity(usr))
		return
	if(..())
		return TRUE

	var/update = TRUE
	var/obj/item/device/electronic_assembly/A = src.assembly
	var/update_to_assembly = FALSE
	var/datum/integrated_io/pin = locate(href_list["pin"]) in inputs + outputs + activators
	var/datum/integrated_io/linked = null
	if(href_list["link"])
		linked = locate(href_list["link"]) in pin.linked

	var/obj/held_item = usr.get_active_held_item()

	if(href_list["rename"])
		rename_component(usr)
		if(href_list["from_assembly"])
			update = FALSE
			var/obj/item/device/electronic_assembly/ea = loc
			if(istype(ea))
				ea.interact(usr)

	if(href_list["pin_name"])
		if (!istype(held_item, /obj/item/device/multitool) || !allow_multitool)
			href_list["wire"] = TRUE
		else
			var/obj/item/device/multitool/M = held_item
			M.wire(pin,usr)



	if(href_list["pin_data"])
		if (!istype(held_item, /obj/item/device/multitool) || !allow_multitool)
			href_list["wire"] = TRUE

		else
			var/datum/integrated_io/io = pin
			io.ask_for_pin_data(usr) // The pins themselves will determine how to ask for data, and will validate the data.

	if(href_list["pin_unwire"])
		if (!istype(held_item, /obj/item/device/multitool) || !allow_multitool)
			href_list["wire"] = TRUE
		else
			var/obj/item/device/multitool/M = held_item
			M.unwire(pin, linked, usr)

	if(href_list["wire"])
		if(istype(held_item, /obj/item/device/integrated_electronics/wirer))
			var/obj/item/device/integrated_electronics/wirer/wirer = held_item
			if(linked)
				wirer.wire(linked, usr)
			else if(pin)
				wirer.wire(pin, usr)

		else if(istype(held_item, /obj/item/device/integrated_electronics/debugger))
			var/obj/item/device/integrated_electronics/debugger/debugger = held_item
			if(pin)
				debugger.write_data(pin, usr)
		else
			to_chat(usr, "<span class='warning'>You can't do a whole lot without the proper tools.</span>")

	if(href_list["examine"])
		var/obj/item/integrated_circuit/examined
		if(href_list["examined"])
			examined = href_list["examined"]
		else
			examined = src
		examined.interact(usr)
		update = FALSE

	if(href_list["bottom"])
		var/obj/item/integrated_circuit/circuit = locate(href_list["bottom"]) in src.assembly.contents
		var/assy = circuit.assembly
		if(!circuit)
			return
		circuit.loc = null
		circuit.loc = assy
		. = TRUE
		update_to_assembly = TRUE

	if(href_list["scan"])
		if(istype(held_item, /obj/item/device/integrated_electronics/debugger))
			var/obj/item/device/integrated_electronics/debugger/D = held_item
			if(D.accepting_refs)
				D.afterattack(src, usr, TRUE)
			else
				to_chat(usr, "<span class='warning'>The Debugger's 'ref scanner' needs to be on.</span>")
		else
			to_chat(usr, "<span class='warning'>You need a multitool/debugger set to 'ref' mode to do that.</span>")

	if(href_list["return"])
		if(A)
			update_to_assembly = TRUE
			usr << browse(null, "window=circuit-[REF(src)];border=1;can_resize=1;can_close=1;can_minimize=1")
		else
			to_chat(usr, "<span class='warning'>This circuit is not in an assembly!</span>")


	if(href_list["remove"])
		if(!A)
			to_chat(usr, "<span class='warning'>This circuit is not in an assembly!</span>")
			return
		if(!removable)
			to_chat(usr, "<span class='warning'>\The [src] seems to be permanently attached to the case.</span>")
			return
		var/obj/item/device/electronic_assembly/ea = loc
		disconnect_all()
		var/turf/T = get_turf(src)
		forceMove(T)
		assembly = null
		playsound(T, 'sound/items/Crowbar.ogg', 50, 1)
		to_chat(usr, "<span class='notice'>You pop \the [src] out of the case, and slide it out.</span>")

		if(istype(ea))
			ea.interact(usr)
		update = FALSE
		return

	if(update)
		if(A && istype(A) && update_to_assembly)
			A.interact(usr)
		else
			interact(usr) // To refresh the UI.

/obj/item/integrated_circuit/proc/push_data()
	for(var/k in 1 to outputs.len)
		var/datum/integrated_io/O = outputs[k]
		O.push_data()

/obj/item/integrated_circuit/proc/pull_data()
	for(var/k in 1 to inputs.len)
		var/datum/integrated_io/I = inputs[k]
		I.push_data()

/obj/item/integrated_circuit/proc/draw_idle_power()
	if(assembly)
		return assembly.draw_power(power_draw_idle)

// Override this for special behaviour when there's no power left.
/obj/item/integrated_circuit/proc/power_fail()
	return

// Returns true if there's enough power to work().
/obj/item/integrated_circuit/proc/check_power()
	if(!assembly)
		return FALSE // Not in an assembly, therefore no power.
	if(assembly.draw_power(power_draw_per_use))
		return TRUE // Battery has enough.
	return FALSE // Not enough power.

/obj/item/integrated_circuit/proc/check_then_do_work(var/ignore_power = FALSE)
	if(world.time < next_use) 	// All intergrated circuits have an internal cooldown, to protect from spam.
		return
	if(power_draw_per_use && !ignore_power)
		if(!check_power())
			power_fail()
			return
	next_use = world.time + cooldown_per_use
	do_work()

/obj/item/integrated_circuit/proc/do_work()
	return

/obj/item/integrated_circuit/proc/disconnect_all()

	for(var/k in 1 to inputs.len)
		var/datum/integrated_io/I = inputs[k]
		I.disconnect()
	for(var/k in 1 to outputs.len)
		var/datum/integrated_io/O = outputs[k]
		O.disconnect()
	for(var/k in 1 to activators.len)
		var/datum/integrated_io/activate/A = activators[k]
		A.disconnect()

/obj/item/integrated_circuit/proc/ext_moved(oldLoc, dir)
	return
