#define IC_MAX_SIZE_BASE		25
#define IC_COMPLEXITY_BASE		75

/obj/item/device/electronic_assembly
	name = "electronic assembly"
	desc = "It's a case, for building small electronics with."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/electronic_assemblies.dmi'
	icon_state = "setup_small"
	flags_1 = NOBLUDGEON_1
	var/max_components = IC_MAX_SIZE_BASE
	var/max_complexity = IC_COMPLEXITY_BASE
	var/opened = FALSE
	var/obj/item/stock_parts/cell/battery // Internal cell which most circuits need to work.
	var/cell_type = /obj/item/stock_parts/cell
	var/can_charge = TRUE //Can it be charged in a recharger?
	var/charge_sections = 4
	var/charge_tick = FALSE
	var/charge_delay = 4
	var/use_cyborg_cell = TRUE

/obj/item/device/electronic_assembly/proc/check_interactivity(mob/user)
	return user.canUseTopic(src,be_close = TRUE)


/obj/item/device/electronic_assembly/medium
	name = "electronic mechanism"
	icon_state = "setup_medium"
	desc = "It's a case, for building medium-sized electronics with."
	w_class = WEIGHT_CLASS_NORMAL
	max_components = IC_MAX_SIZE_BASE * 2
	max_complexity = IC_COMPLEXITY_BASE * 2

/obj/item/device/electronic_assembly/large
	name = "electronic machine"
	icon_state = "setup_large"
	desc = "It's a case, for building large electronics with."
	w_class = WEIGHT_CLASS_BULKY
	max_components = IC_MAX_SIZE_BASE * 4
	max_complexity = IC_COMPLEXITY_BASE * 4
	anchored = FALSE

/obj/item/device/electronic_assembly/large/attackby(var/obj/item/O, var/mob/user)
	if(default_unfasten_wrench(user, O, 20))
		return
	..()

/obj/item/device/electronic_assembly/large/attack_tk(mob/user)
	if(anchored)
		return
	..()

/obj/item/device/electronic_assembly/large/attack_hand(mob/user)
	if(anchored)
		attack_self(user)
		return
	..()

/obj/item/device/electronic_assembly/drone
	name = "electronic drone"
	icon_state = "setup_drone"
	desc = "It's a case, for building mobile electronics with."
	w_class = WEIGHT_CLASS_SMALL
	max_components = IC_MAX_SIZE_BASE * 3
	max_complexity = IC_COMPLEXITY_BASE * 3



/obj/item/device/electronic_assembly/Initialize()
	.=..()
	START_PROCESSING(SScircuit, src)

/obj/item/device/electronic_assembly/Destroy()
	STOP_PROCESSING(SScircuit, src)
	return ..()

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


/obj/item/device/electronic_assembly/interact(mob/user)
	if(!check_interactivity(user))
		return

	var/total_part_size = return_total_size()
	var/total_complexity = return_total_complexity()
	var/HTML = list()

	HTML += "<html><head><title>[name]</title></head><body>"
	HTML += "<br><a href='?src=[REF(src)]'>\[Refresh\]</a>  |  "
	HTML += "<a href='?src=[REF(src)];rename=1'>\[Rename\]</a><br>"
	HTML += "[total_part_size]/[max_components] ([round((total_part_size / max_components) * 100, 0.1)]%) space taken up in the assembly.<br>"
	HTML += "[total_complexity]/[max_complexity] ([round((total_complexity / max_complexity) * 100, 0.1)]%) maximum complexity.<br>"
	if(battery)
		HTML += "[round(battery.charge, 0.1)]/[battery.maxcharge] ([round(battery.percent(), 0.1)]%) cell charge. <a href='?src=[REF(src)];remove_cell=1'>\[Remove\]</a>"
	else
		HTML += "<span class='danger'>No powercell detected!</span>"
	HTML += "<br><br>"
	HTML += "Components:<hr>"
	HTML += "Built in:<br>"


//Put removable circuits in separate categories from non-removable
	for(var/obj/item/integrated_circuit/circuit in contents)
		if(!circuit.removable)
			HTML += "<a href=?src=[REF(circuit)];examine=1;from_assembly=1>[circuit.displayed_name]</a> | "
			HTML += "<a href=?src=[REF(circuit)];rename=1;from_assembly=1>\[Rename\]</a> | "
			HTML += "<a href=?src=[REF(circuit)];scan=1;from_assembly=1>\[Scan with Debugger\]</a> | "
			HTML += "<a href=?src=[REF(circuit)];bottom=[REF(circuit)];from_assembly=1>\[Move to Bottom\]</a>"
			HTML += "<br>"

	HTML += "<hr>"
	HTML += "Removable:<br>"

	for(var/obj/item/integrated_circuit/circuit in contents)
		if(circuit.removable)
			HTML += "<a href=?src=[REF(circuit)];examine=1;from_assembly=1>[circuit.displayed_name]</a> | "
			HTML += "<a href=?src=[REF(circuit)];rename=1;from_assembly=1>\[Rename\]</a> | "
			HTML += "<a href=?src=[REF(circuit)];scan=1;from_assembly=1>\[Scan with Debugger\]</a> | "
			HTML += "<a href=?src=[REF(circuit)];remove=1;from_assembly=1>\[Remove\]</a> | "
			HTML += "<a href=?src=[REF(circuit)];bottom=[REF(circuit)];from_assembly=1>\[Move to Bottom\]</a>"
			HTML += "<br>"

	HTML += "</body></html>"
	user << browse(jointext(HTML,null), "window=assembly-\[REF(src)];size=600x350;border=1;can_resize=1;can_close=1;can_minimize=1")

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

/obj/item/device/electronic_assembly/proc/rename()

	var/mob/M = usr
	if(!check_interactivity(M))
		return

	var/input = reject_bad_name(input("What do you want to name this?", "Rename", src.name) as null|text,1)
	if(!check_interactivity(M))
		return
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

/obj/item/device/electronic_assembly/examine(mob/user)
	..()
	for(var/obj/item/integrated_circuit/IC in contents)
		IC.external_examine(user)
		if(istype(IC,/obj/item/integrated_circuit/output/screen))
			var/obj/item/integrated_circuit/output/screen/S
			if(S.stuff_to_display)
				to_chat(user, "There's a little screen labeled '[S]', which displays '[S.stuff_to_display]'.")
	if(opened)
		interact(user)

/obj/item/device/electronic_assembly/proc/return_total_complexity()
	. = 0
	for(var/obj/item/integrated_circuit/part in contents)
		. += part.complexity

/obj/item/device/electronic_assembly/proc/return_total_size()
	. = 0
	for(var/obj/item/integrated_circuit/part in contents)
		. += part.size

// Returns true if the circuit made it inside.
/obj/item/device/electronic_assembly/proc/add_circuit(var/obj/item/integrated_circuit/IC, var/mob/user)
	if(!opened)
		to_chat(user, "<span class='warning'>\The [src] isn't opened, so you can't put anything inside.  Try using a crowbar.</span>")
		return FALSE

	if(IC.w_class > w_class)
		to_chat(user, "<span class='warning'>\The [IC] is way too big to fit into \the [src].</span>")
		return FALSE

	var/total_part_size = return_total_size()
	var/total_complexity = return_total_complexity()

	if((total_part_size + IC.size) > max_components)
		to_chat(user, "<span class='warning'>You can't seem to add the '[IC]', as there's insufficient space.</span>")
		return FALSE
	if((total_complexity + IC.complexity) > max_complexity)
		to_chat(user, "<span class='warning'>You can't seem to add the '[IC]', since this setup's too complicated for the case.</span>")
		return FALSE

	if(!user.transferItemToLoc(IC, src))
		return FALSE

	IC.assembly = src

	return TRUE

/obj/item/device/electronic_assembly/afterattack(atom/target, mob/user, proximity)
	for(var/obj/item/integrated_circuit/input/sensor/S in contents)
		if(!proximity)
			if(istype(S,/obj/item/integrated_circuit/input/sensor/ranged)||(!user))
				if(user.client)
					if(!(target in view(user.client)))
						continue
				else
					if(!(target in view(user)))
						continue
			else
				continue
		S.set_pin_data(IC_OUTPUT, 1, WEAKREF(target))
		S.check_then_do_work()
		S.scan(target)

	visible_message("<span class='notice'> [user] waves [src] around [target].</span>")

/obj/item/device/electronic_assembly/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/integrated_circuit))
		if(!user.canUnEquip(I))
			return FALSE
		if(add_circuit(I, user))
			to_chat(user, "<span class='notice'>You slide [I] inside [src].</span>")
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			interact(user)
			return TRUE
	else if(istype(I, /obj/item/crowbar))
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
		opened = !opened
		to_chat(user, "<span class='notice'>You [opened ? "opened" : "closed"] [src].</span>")
		update_icon()
		return TRUE
	else if(istype(I, /obj/item/device/integrated_electronics/wirer) || istype(I, /obj/item/device/integrated_electronics/debugger) || istype(I, /obj/item/screwdriver))
		if(opened)
			interact(user)
		else
			to_chat(user, "<span class='warning'> [src] isn't opened, so you can't fiddle with the internal components.  \
			Try using a crowbar.</span>")
	else if(istype(I, /obj/item/stock_parts/cell))
		if(!opened)
			to_chat(user, "<span class='warning'> [src] isn't opened, so you can't put anything inside.  Try using a crowbar.</span>")
			return FALSE
		if(battery)
			to_chat(user, "<span class='warning'> [src] already has \a [battery] inside.  Remove it first if you want to replace it.</span>")
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
			var/disp_name= "[input.displayed_name] \[[input]\]"
			if(i)
				disp_name += " ([i+1])"
			input_selection.Add(disp_name)

	var/obj/item/integrated_circuit/input/choice
	if(available_inputs)
		if(available_inputs.len ==1)
			choice = available_inputs[1]
		else
			var/selection = input(user, "What do you want to interact with?", "Interaction") as null|anything in input_selection
			if(!check_interactivity(user))
				return
			if(selection)
				var/index = input_selection.Find(selection)
				choice = available_inputs[index]

	if(choice)
		choice.ask_for_input(user)

/obj/item/device/electronic_assembly/emp_act(severity)
	..()
	for(var/i in 1 to contents.len)
		var/atom/movable/AM = contents[i]
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

/obj/item/device/electronic_assembly/Moved(oldLoc, dir)
	for(var/obj/item/integrated_circuit/IC in contents)
		IC.ext_moved(oldLoc, dir)
