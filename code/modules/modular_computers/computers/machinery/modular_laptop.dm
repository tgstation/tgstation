// Laptop in it's item state, can be carried around.

/obj/item/laptop
	name		= "laptop computer"
	desc		= "A portable computer. It is closed."
	icon		= 'icons/obj/modular_laptop.dmi'
	icon_state	= "laptop-closed"
	item_state	= "laptop-inhand"
	w_class		= 3
	var/obj/machinery/modular_computer/laptop/stored_computer = null

/obj/item/laptop/verb/open_computer()
	set name = "Open Laptop"
	set category = "Object"
	set src in view(1)

	if(usr.stat || usr.restrained() || usr.lying || !istype(usr, /mob/living))
		usr << "<span class='warning'>You can't do that.</span>"
		return

	if(!Adjacent(usr))
		usr << "You can't reach it."
		return

	if(!istype(loc,/turf))
		usr << "[src] is too bulky!  You'll have to set it down."
		return

	if(!stored_computer)
		if(contents.len)
			for(var/obj/O in contents)
				O.forceMove(src.loc)
		usr << "\The [src] crumbles to pieces."
		spawn(5)
			qdel(src)
		return

	stored_computer.forceMove(src.loc)
	stored_computer.stat &= ~MAINT
	stored_computer.update_icon()
	if(stored_computer.cpu)
		stored_computer.cpu.screen_on = 1
	loc = stored_computer
	usr << "You open \the [src]."


/obj/item/laptop/AltClick()
	if(Adjacent(usr))
		open_computer()

// The actual laptop
/obj/machinery/modular_computer/laptop
	name = "laptop computer"
	desc = "A portable computer."
	var/obj/item/laptop/portable = null						// Portable version of this computer, dropped on alt-click to allow transport. Used by laptops.
	hardware_flag = PROGRAM_LAPTOP
	icon_state_unpowered = "laptop-open"					// Icon state when the computer is turned off
	icon = 'icons/obj/modular_laptop.dmi'
	icon_state = "laptop-open"
	base_idle_power_usage = 25
	base_active_power_usage = 200
	max_hardware_size = 2
	light_strength = 3
	_max_damage = 200
	_break_damage = 100

/obj/machinery/modular_computer/laptop/buildable/New()
	..()
	// User-built consoles start as empty frames.
	qdel(tesla_link)
	qdel(cpu.network_card)
	qdel(cpu.hard_drive)

// Close the computer. collapsing it into movable item that can't be used.
/obj/machinery/modular_computer/laptop/verb/close_computer()
	set name = "Close Laptop"
	set category = "Object"
	set src in view(1)

	if(usr.stat || usr.restrained() || usr.lying || !istype(usr, /mob/living))
		usr << "<span class='warning'>You can't do that.</span>"
		return

	if(!Adjacent(usr))
		usr << "<span class='warning'>You can't reach it.</span>"
		return

	close_laptop(usr)

/obj/machinery/modular_computer/laptop/proc/close_laptop(mob/user = null)
	if(istype(loc,/obj/item/laptop))
		return
	if(!istype(loc,/turf))
		return

	if(!portable)
		portable=new
		portable.stored_computer = src

	portable.forceMove(src.loc)
	src.forceMove(portable)
	stat |= MAINT
	if(user)
		user << "You close \the [src]."
	if(cpu)
		cpu.screen_on = 0

/obj/machinery/modular_computer/laptop/AltClick()
	if(Adjacent(usr))
		close_laptop()