#define IC_COMPONENTS_BASE		25
#define IC_COMPLEXITY_BASE		75

/obj/item/device/electronic_assembly
	name = "electronic assembly"
	desc = "It's a case, for building small electronics with."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/electronic_assemblies.dmi'
	icon_state = "setup_small"
	var/max_components = IC_COMPONENTS_BASE
	var/max_complexity = IC_COMPLEXITY_BASE
	var/opened = 0
	var/obj/item/stock_parts/cell/battery = null // Internal cell which most circuits need to work.
	var/cell_type = /obj/item/stock_parts/cell
	var/can_charge = 1 //Can it be charged in a recharger?
	var/charge_sections = 4
	var/charge_tick = 0
	var/charge_delay = 4
	var/use_cyborg_cell = 1

/obj/item/device/electronic_assembly/medium
	name = "electronic mechanism"
	icon_state = "setup_medium"
	desc = "It's a case, for building medium-sized electronics with."
	w_class = WEIGHT_CLASS_SMALL
	max_components = IC_COMPONENTS_BASE * 2
	max_complexity = IC_COMPLEXITY_BASE * 2

/obj/item/device/electronic_assembly/large
	name = "electronic machine"
	icon_state = "setup_large"
	desc = "It's a case, for building large electronics with."
	w_class = WEIGHT_CLASS_BULKY
	max_components = IC_COMPONENTS_BASE * 4
	max_complexity = IC_COMPLEXITY_BASE * 4
	anchored = 0

/obj/item/device/electronic_assembly/large/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/wrench))
		if(!istype(src.loc,/turf))
			return
		src.anchored = !anchored
		to_chat(user,"You [src.anchored ? "wrench" : "unwrench"] \the [src].")
		return
	..()

/obj/item/device/electronic_assembly/large/attack_tk(mob/user as mob)
	if(anchored)
		return
	..()

/obj/item/device/electronic_assembly/large/attack_hand(mob/user as mob)
	if(anchored)
		src.attack_self(user)
		return
	..()

/obj/item/device/electronic_assembly/drone
	name = "electronic drone"
	icon_state = "setup_drone"
	desc = "It's a case, for building mobile electronics with."
	w_class = WEIGHT_CLASS_SMALL
	max_components = IC_COMPONENTS_BASE * 3
	max_complexity = IC_COMPLEXITY_BASE * 3



/obj/item/device/electronic_assembly/New()
	..()
	battery = new(src)
	GLOB.machines |= src

/obj/item/device/electronic_assembly/Destroy()
	battery = null
	GLOB.machines -= src
	for(var/atom/movable/AM in contents)
		qdel(AM)
	..()

/obj/item/device/electronic_assembly/process()
	handle_idle_power()

/obj/item/device/electronic_assembly/proc/handle_idle_power()
	// First we generate power.
	for(var/obj/item/integrated_circuit/passive/power/P in contents)
		P.make_energy()

	// Now spend it.
	for(var/obj/item/integrated_circuit/IC in contents)
		if(IC.power_draw_idle)
			if(!draw_power(IC.power_draw_idle))
				IC.power_fail()
/*
/obj/item/device/electronic_assembly/implant
	name = "electronic implant"
	icon_state = "setup_implant"
	desc = "It's a case, for building very tiny electronics with."
	w_class = WEIGHT_CLASS_SMALL
	max_components = IC_COMPONENTS_BASE / 2
	max_complexity = IC_COMPLEXITY_BASE / 2
	var/obj/item/weapon/implant/integrated_circuit/implant = null

/obj/item/device/electronic_assembly/implant/update_icon()
	..()
	implant.icon_state = icon_state


/obj/item/device/electronic_assembly/implant/nano_host()
	return implant

/obj/item/device/electronic_assembly/proc/resolve_nano_host()
	return src

/obj/item/device/electronic_assembly/implant/resolve_nano_host()
	return implant
*/
/obj/item/device/electronic_assembly/proc/check_interactivity(mob/user)
	if(!user.IsAdvancedToolUser())
		return 0
	return 1

/obj/item/device/electronic_assembly/interact(mob/user)
	if(!check_interactivity(user))
		return

	var/total_parts = 0
	var/total_complexity = 0
	for(var/obj/item/integrated_circuit/part in contents)
		total_parts += part.size
		total_complexity = total_complexity + part.complexity
	var/HTML = list()

	HTML += "<html><head><title>[src.name]</title></head><body>"
	HTML += "<br><a href='?src=\ref[src]'>\[Refresh\]</a>  |  "
	HTML += "<a href='?src=\ref[src];rename=1'>\[Rename\]</a><br>"
	HTML += "[total_parts]/[max_components] ([round((total_parts / max_components) * 100, 0.1)]%) space taken up in the assembly.<br>"
	HTML += "[total_complexity]/[max_complexity] ([round((total_complexity / max_complexity) * 100, 0.1)]%) maximum complexity.<br>"
	if(battery)
		HTML += "[round(battery.charge, 0.1)]/[battery.maxcharge] ([round(battery.percent(), 0.1)]%) cell charge. <a href='?src=\ref[src];remove_cell=1'>\[Remove\]</a>"
	else
		HTML += "<span class='danger'>No powercell detected!</span>"
	HTML += "<br><br>"
	HTML += "Components:<hr>"
	HTML += "Built in:<br>"


//Put removable circuits in separate categories from non-removable
	for(var/obj/item/integrated_circuit/circuit in contents)
		if(!circuit.removable)
			HTML += "<a href=?src=\ref[circuit];examine=1;from_assembly=1>[circuit.displayed_name]</a> | "
			HTML += "<a href=?src=\ref[circuit];rename=1;from_assembly=1>\[Rename\]</a> | "
			HTML += "<a href=?src=\ref[circuit];scan=1;from_assembly=1>\[Scan with Debugger\]</a> | "
			HTML += "<a href=?src=\ref[circuit];bottom=\ref[circuit];from_assembly=1>\[Move to Bottom\]</a>"
			HTML += "<br>"

	HTML += "<hr>"
	HTML += "Removable:<br>"

	for(var/obj/item/integrated_circuit/circuit in contents)
		if(circuit.removable)
			HTML += "<a href=?src=\ref[circuit];examine=1;from_assembly=1>[circuit.displayed_name]</a> | "
			HTML += "<a href=?src=\ref[circuit];rename=1;from_assembly=1>\[Rename\]</a> | "
			HTML += "<a href=?src=\ref[circuit];scan=1;from_assembly=1>\[Scan with Debugger\]</a> | "
			HTML += "<a href=?src=\ref[circuit];remove=1;from_assembly=1>\[Remove\]</a> | "
			HTML += "<a href=?src=\ref[circuit];bottom=\ref[circuit];from_assembly=1>\[Move to Bottom\]</a>"
			HTML += "<br>"

	HTML += "</body></html>"
	user << browse(jointext(HTML,null), "window=assembly-\ref[src];size=600x350;border=1;can_resize=1;can_close=1;can_minimize=1")

/obj/item/device/electronic_assembly/Topic(href, href_list[])
	if(..())
		return 1

	if(href_list["rename"])
		rename(usr)

	if(href_list["remove_cell"])
		if(!battery)
			to_chat(usr, "<span class='warning'>There's no power cell to remove from \the [src].</span>")
		else
			var/turf/T = get_turf(src)
			battery.forceMove(T)
			playsound(T, 'sound/items/Crowbar.ogg', 50, 1)
			to_chat(usr, "<span class='notice'>You pull \the [battery] out of \the [src]'s power supplier.</span>")
			battery = null

	interact(usr) // To refresh the UI.

/obj/item/device/electronic_assembly/verb/rename()
	set name = "Rename Circuit"
	set category = "Object"
	set desc = "Rename your circuit, useful to stay organized."

	var/mob/M = usr
	if(!check_interactivity(M))
		return

	var/input = reject_bad_name(input("What do you want to name this?", "Rename", src.name) as null|text,1)
	if(src && input)
		to_chat(M, "<span class='notice'>The machine now has a label reading '[input]'.</span>")
		name = input

/obj/item/device/electronic_assembly/proc/can_move()
	return FALSE

/obj/item/device/electronic_assembly/drone/can_move()
	return TRUE

/obj/item/device/electronic_assembly/update_icon()
	if(opened)
		icon_state = initial(icon_state) + "-open"
	else
		icon_state = initial(icon_state)

/obj/item/device/electronic_assembly/GetAccess()
	. = list()
	for(var/obj/item/integrated_circuit/part in contents)
		. |= part.GetAccess()

/obj/item/device/electronic_assembly/GetIdCard()
	. = list()
	for(var/obj/item/integrated_circuit/part in contents)
		var/id_card = part.GetIdCard()
		if(id_card)
			return id_card

/obj/item/device/electronic_assembly/examine(mob/user)
	. = ..(user, 1)
	if(.)
		for(var/obj/item/integrated_circuit/IC in contents)
			IC.external_examine(user)
	//	for(var/obj/item/integrated_circuit/output/screen/S in contents)
	//		if(S.stuff_to_display)
	//			to_chat(user, "There's a little screen labeled '[S.name]', which displays '[S.stuff_to_display]'.")
		if(opened)
			interact(user)

/obj/item/device/electronic_assembly/proc/get_part_complexity()
	. = 0
	for(var/obj/item/integrated_circuit/part in contents)
		. += part.complexity

/obj/item/device/electronic_assembly/proc/get_part_size()
	. = 0
	for(var/obj/item/integrated_circuit/part in contents)
		. += part.size

// Returns true if the circuit made it inside.
/obj/item/device/electronic_assembly/proc/add_circuit(var/obj/item/integrated_circuit/IC, var/mob/user)
	if(!opened)
		to_chat(user, "<span class='warning'>\The [src] isn't opened, so you can't put anything inside.  Try using a crowbar.</span>")
		return FALSE

	if(IC.w_class > src.w_class)
		to_chat(user, "<span class='warning'>\The [IC] is way too big to fit into \the [src].</span>")
		return FALSE

	var/total_part_size = get_part_size()
	var/total_complexity = get_part_complexity()

	if((total_part_size + IC.size) > max_components)
		to_chat(user, "<span class='warning'>You can't seem to add the '[IC.name]', as there's insufficient space.</span>")
		return FALSE
	if((total_complexity + IC.complexity) > max_complexity)
		to_chat(user, "<span class='warning'>You can't seem to add the '[IC.name]', since this setup's too complicated for the case.</span>")
		return FALSE

	if(!IC.forceMove(src))
		return FALSE

	IC.assembly = src

	return TRUE

/obj/item/device/electronic_assembly/afterattack(atom/target, mob/user, proximity)
	if(proximity)
		var/scanned = FALSE
		for(var/obj/item/integrated_circuit/input/sensor/S in contents)
//			S.set_pin_data(IC_OUTPUT, 1, weakref(target))
//			S.check_then_do_work()
			if(S.scan(target))
				scanned = TRUE
		if(scanned)
			visible_message("<span class='notice'>\The [user] waves \the [src] around [target].</span>")

/obj/item/device/electronic_assembly/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/integrated_circuit))
		if(!user.transferItemToLoc(I, src))
			return FALSE
		if(add_circuit(I, user))
			to_chat(user, "<span class='notice'>You slide \the [I] inside \the [src].</span>")
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			interact(user)
			return TRUE
	else if(istype(I, /obj/item/crowbar))
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
		opened = !opened
		to_chat(user, "<span class='notice'>You [opened ? "opened" : "closed"] \the [src].</span>")
		update_icon()
		return TRUE
	else if(istype(I, /obj/item/device/integrated_electronics/wirer) || istype(I, /obj/item/device/integrated_electronics/debugger) || istype(I, /obj/item/screwdriver))
		if(opened)
			interact(user)
		else
			to_chat(user, "<span class='warning'>\The [src] isn't opened, so you can't fiddle with the internal components.  \
			Try using a crowbar.</span>")
	else if(istype(I, /obj/item/stock_parts/cell))
		if(!opened)
			to_chat(user, "<span class='warning'>\The [src] isn't opened, so you can't put anything inside.  Try using a crowbar.</span>")
			return FALSE
		if(battery)
			to_chat(user, "<span class='warning'>\The [src] already has \a [battery] inside.  Remove it first if you want to replace it.</span>")
			return FALSE
		var/obj/item/stock_parts/cell = I
		user.transferItemToLoc(I, loc)
		cell.forceMove(src)
		battery = cell
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You slot \the [cell] inside \the [src]'s power supplier.</span>")
		interact(user)
		return TRUE
	else
		return ..()

/obj/item/device/electronic_assembly/attack_self(mob/user)
	if(!check_interactivity(user))
		return
	if(opened)
		interact(user)

	var/list/input_selection = list()
	var/list/available_inputs = list()
	for(var/obj/item/integrated_circuit/input/input in contents)
		if(input.can_be_asked_input)
			available_inputs.Add(input)
			var/i = 0
			for(var/obj/item/integrated_circuit/s in available_inputs)
				if(s.name == input.name && s.displayed_name == input.displayed_name && s != input)
					i++
			var/disp_name= "[input.displayed_name] \[[input.name]\]"
			if(i)
				disp_name += " ([i+1])"
			input_selection.Add(disp_name)

	var/obj/item/integrated_circuit/input/choice
	if(available_inputs)
		var/selection = input(user, "What do you want to interact with?", "Interaction") as null|anything in input_selection
		if(selection)
			var/index = input_selection.Find(selection)
			choice = available_inputs[index]

	if(choice)
		choice.ask_for_input(user)

/obj/item/device/electronic_assembly/emp_act(severity)
	..()
	for(var/atom/movable/AM in contents)
		AM.emp_act(severity)

// Returns true if power was successfully drawn.
/obj/item/device/electronic_assembly/proc/draw_power(amount)
	if(battery && battery.use(amount * GLOB.CELLRATE))
		return TRUE
	return FALSE

// Ditto for giving.
/obj/item/device/electronic_assembly/proc/give_power(amount)
	if(battery && battery.give(amount * GLOB.CELLRATE))
		return TRUE
	return FALSE

