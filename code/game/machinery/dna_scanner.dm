/obj/machinery/cloning/scanner
	name = "\improper DNA scanner"
	desc = "It scans DNA structures."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner"
	density = 1
	var/locked = 0
	anchored = 1
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 300
	var/damage_coeff
	var/scan_level
	var/precision_coeff

/obj/machinery/cloning/scanner/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/clonescanner(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/clonescanner
	name = "circuit board (Cloning Scanner)"
	build_path = /obj/machinery/cloning/scanner
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stack/cable_coil = 2)

/obj/machinery/cloning/scanner/RefreshParts()
	scan_level = 0
	damage_coeff = 0
	precision_coeff = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/P in component_parts)
		scan_level += P.rating
	for(var/obj/item/weapon/stock_parts/manipulator/P in component_parts)
		precision_coeff = P.rating
	for(var/obj/item/weapon/stock_parts/micro_laser/P in component_parts)
		damage_coeff = P.rating

/obj/machinery/cloning/scanner/update_icon()

	//no power or maintenance
	if(stat & (NOPOWER|BROKEN))
		icon_state = initial(icon_state)+ (state_open ? "_open" : "") + "_unpowered"
		return

	if((stat & MAINT) || panel_open)
		icon_state = initial(icon_state)+ (state_open ? "_open" : "") + "_maintenance"
		return

	//running and someone in there
	if(occupant)
		icon_state = initial(icon_state)+ "_occupied"
		return

	//running
	icon_state = initial(icon_state)+ (state_open ? "_open" : "")

/obj/machinery/cloning/scanner/power_change()
	..()
	update_icon()

/obj/machinery/cloning/scanner/proc/toggle_open(mob/user)
	if(panel_open)
		user << "<span class='notice'>Close the maintenance panel first.</span>"
		return

	if(state_open)
		close_machine()
		return

	else if(locked)
		user << "<span class='notice'>The bolts are locked down, securing the door shut.</span>"
		return

	open_machine()

/obj/machinery/cloning/scanner/container_resist(mob/living/user)
	var/breakout_time = 2
	if(state_open || !locked)	//Open and unlocked, no need to escape
		state_open = 1
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user << "<span class='notice'>You lean on the back of [src] and start pushing the door open... (this will take about [breakout_time] minutes.)</span>"
	user.visible_message("<span class='italics'>You hear a metallic creaking from [src]!</span>")

	if(do_after(user,(breakout_time*60*10), target = src)) //minutes * 60seconds * 10deciseconds
		if(!user || user.stat != CONSCIOUS || user.loc != src || state_open || !locked)
			return

		locked = 0
		visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>")
		user << "<span class='notice'>You successfully break out of [src]!</span>"

		open_machine()

/obj/machinery/cloning/scanner/close_machine()
	if(!state_open)
		return 0

	..()

	// search for ghosts, if the corpse is empty and the scanner is connected to a cloner
	if(occupant)
		if(istype(computer, /obj/machinery/computer/cloning))
			if(!occupant.suiciding && !(occupant.disabilities & NOCLONE) && !occupant.hellbound)
				occupant.notify_ghost_cloning("Your corpse has been placed into a cloning scanner. Re-enter your corpse if you want to be cloned!", source = src)

		if(istype(computer, /obj/machinery/computer/scan_consolenew))
			var/obj/machinery/computer/scan_consolenew/console = computer
			if(console)
				console.on_scanner_close()
	return 1

/obj/machinery/cloning/scanner/open_machine()
	if(state_open)
		return 0

	..()

	return 1

/obj/machinery/cloning/scanner/relaymove(mob/user as mob)
	if(user.stat || locked)
		return

	open_machine()

/obj/machinery/dna_scannernew/attackby(obj/item/I, mob/user, params)

	if(!occupant && default_deconstruction_screwdriver(user, icon_state, icon_state, I))//sent icon_state is irrelevant...
		update_icon()//..since we're updating the icon here, since the scanner can be unpowered when opened/closed
		return

	if(exchange_parts(user, I))
		return

	if(default_pry_open(I))
		return

	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/cloning/scanner/attack_hand(mob/user)
	if(..(user,1,0)) //don't set the machine, since there's no dialog
		return

	toggle_open(user)
