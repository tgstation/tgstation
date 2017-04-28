/obj/machinery/dna_scannernew
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

/obj/machinery/dna_scannernew/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/clonescanner(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/clonescanner
	name = "Cloning Scanner (Machine Board)"
	build_path = /obj/machinery/dna_scannernew
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stack/cable_coil = 2)

/obj/machinery/dna_scannernew/RefreshParts()
	scan_level = 0
	damage_coeff = 0
	precision_coeff = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/P in component_parts)
		scan_level += P.rating
	for(var/obj/item/weapon/stock_parts/manipulator/P in component_parts)
		precision_coeff = P.rating
	for(var/obj/item/weapon/stock_parts/micro_laser/P in component_parts)
		damage_coeff = P.rating

/obj/machinery/dna_scannernew/update_icon()

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

/obj/machinery/dna_scannernew/power_change()
	..()
	update_icon()

/obj/machinery/dna_scannernew/proc/toggle_open(mob/user)
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return

	if(state_open)
		close_machine()
		return

	else if(locked)
		to_chat(user, "<span class='notice'>The bolts are locked down, securing the door shut.</span>")
		return

	open_machine()

/obj/machinery/dna_scannernew/container_resist(mob/living/user)
	var/breakout_time = 2
	if(state_open || !locked)	//Open and unlocked, no need to escape
		state_open = 1
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, "<span class='notice'>You lean on the back of [src] and start pushing the door open... (this will take about [breakout_time] minutes.)</span>")
	user.visible_message("<span class='italics'>You hear a metallic creaking from [src]!</span>")

	if(do_after(user,(breakout_time*60*10), target = src)) //minutes * 60seconds * 10deciseconds
		if(!user || user.stat != CONSCIOUS || user.loc != src || state_open || !locked)
			return

		locked = 0
		visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>")
		to_chat(user, "<span class='notice'>You successfully break out of [src]!</span>")

		open_machine()

/obj/machinery/dna_scannernew/close_machine()
	if(!state_open)
		return 0

	..()

	// search for ghosts, if the corpse is empty and the scanner is connected to a cloner
	if(occupant)
		if(locate(/obj/machinery/computer/cloning, get_step(src, NORTH)) \
			|| locate(/obj/machinery/computer/cloning, get_step(src, SOUTH)) \
			|| locate(/obj/machinery/computer/cloning, get_step(src, EAST)) \
			|| locate(/obj/machinery/computer/cloning, get_step(src, WEST)))
			if(!occupant.suiciding && !(occupant.disabilities & NOCLONE) && !occupant.hellbound)
				occupant.notify_ghost_cloning("Your corpse has been placed into a cloning scanner. Re-enter your corpse if you want to be cloned!", source = src)

		var/obj/machinery/computer/scan_consolenew/console
		for(dir in list(NORTH,EAST,SOUTH,WEST))
			console = locate(/obj/machinery/computer/scan_consolenew, get_step(src, dir))
			if(console)
				console.on_scanner_close()
				break
	return 1

/obj/machinery/dna_scannernew/open_machine()
	if(state_open)
		return 0

	..()

	return 1

/obj/machinery/dna_scannernew/relaymove(mob/user as mob)
	if(user.stat || locked)
		return

	open_machine()
	return

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

/obj/machinery/dna_scannernew/attack_hand(mob/user)
	if(..(user,1,0)) //don't set the machine, since there's no dialog
		return

	toggle_open(user)