/obj/machinery/nanite_chamber
	name = "nanite chamber"
	desc = "A device that can scan, reprogram, and inject nanites."
	circuit = /obj/item/circuitboard/machine/nanite_chamber
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "nanite_chamber"
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE
	idle_power_usage = 50
	active_power_usage = 300
	occupant_typecache = list(/mob/living)

	var/obj/machinery/computer/nanite_chamber_control/console
	var/locked = FALSE
	var/breakout_time = 1200
	var/scan_level
	var/busy = FALSE
	var/busy_message
	var/message_cooldown = 0

/obj/machinery/nanite_chamber/RefreshParts()
	scan_level = 0
	for(var/obj/item/stock_parts/scanning_module/P in component_parts)
		scan_level += P.rating

/obj/machinery/nanite_chamber/proc/set_busy(status, message)
	busy = status
	busy_message = message
	update_icon()

/obj/machinery/nanite_chamber/proc/set_safety(threshold)
	if(!occupant)
		return
	GET_COMPONENT_FROM(nanites, /datum/component/nanites, occupant)
	if(!nanites)
		return
	nanites.safety_threshold = threshold
	
/obj/machinery/nanite_chamber/proc/set_cloud(cloud_id)
	if(!occupant)
		return
	GET_COMPONENT_FROM(nanites, /datum/component/nanites, occupant)
	if(!nanites)
		return
	nanites.cloud_id = cloud_id

/obj/machinery/nanite_chamber/proc/inject_nanites()
	if(stat & (NOPOWER|BROKEN))
		return
	if((stat & MAINT) || panel_open)
		return
	if(!occupant || busy)
		return

	var/locked_state = locked
	locked = TRUE

	//TODO OMINOUS MACHINE SOUNDS
	set_busy(TRUE, "Initializing injection protocol...")
	addtimer(CALLBACK(src, .proc/set_busy, TRUE, "Analyzing host bio-structure..."),35)
	addtimer(CALLBACK(src, .proc/set_busy, TRUE, "Activating nanites..."),70)
	addtimer(CALLBACK(src, .proc/set_busy, TRUE, "Injecting..."),105)
	addtimer(CALLBACK(src, .proc/complete_injection, locked_state),130)

/obj/machinery/nanite_chamber/proc/complete_injection(locked_state)
	//TODO MACHINE DING
	set_busy(FALSE)
	locked = locked_state
	if(!occupant)
		return
	occupant.AddComponent(/datum/component/nanites, 100)

/obj/machinery/nanite_chamber/proc/install_program(datum/nanite_program/NP)
	if(stat & (NOPOWER|BROKEN))
		return
	if((stat & MAINT) || panel_open)
		return
	if(!occupant || busy)
		return

	var/locked_state = locked
	locked = TRUE

	//TODO COMPUTERY MACHINE SOUNDS
	set_busy(TRUE, "Initializing installation protocol...")
	addtimer(CALLBACK(src, .proc/set_busy, TRUE, "Connecting to nanite framework..."),15)
	addtimer(CALLBACK(src, .proc/set_busy, TRUE, "Installing program..."),25)
	addtimer(CALLBACK(src, .proc/complete_installation, locked_state, NP),35)

/obj/machinery/nanite_chamber/proc/complete_installation(locked_state, datum/nanite_program/NP)
	//TODO MACHINE DING
	set_busy(FALSE)
	locked = locked_state
	if(!occupant)
		return
	GET_COMPONENT_FROM(nanites, /datum/component/nanites, occupant)
	if(nanites)
		nanites.add_program(NP.copy())

/obj/machinery/nanite_chamber/proc/uninstall_program(datum/nanite_program/NP)
	if(stat & (NOPOWER|BROKEN))
		return
	if((stat & MAINT) || panel_open)
		return
	if(!occupant || busy)
		return

	var/locked_state = locked
	locked = TRUE

	//TODO COMPUTERY MACHINE SOUNDS
	set_busy(TRUE, "Initializing uninstallation protocol...")
	addtimer(CALLBACK(src, .proc/set_busy, TRUE, "Connecting to nanite framework..."),15)
	addtimer(CALLBACK(src, .proc/set_busy, TRUE, "Uninstalling program..."),25)
	addtimer(CALLBACK(src, .proc/complete_uninstallation, locked_state, NP),40)

/obj/machinery/nanite_chamber/proc/complete_uninstallation(locked_state, datum/nanite_program/NP)
	//TODO MACHINE DING
	set_busy(FALSE)
	locked = locked_state
	if(!occupant)
		return
	qdel(NP)

/obj/machinery/nanite_chamber/update_icon()
	//no power or maintenance
	if(stat & (NOPOWER|BROKEN))
		icon_state = initial(icon_state)+ (state_open ? "_open" : "") + "_unpowered"
		return

	if((stat & MAINT) || panel_open)
		icon_state = initial(icon_state)+ (state_open ? "_open" : "") + "_maintenance"
		return

	//running and someone in there
	if(occupant)
		if(busy)
			icon_state = initial(icon_state)+ "_working"
		else
			icon_state = initial(icon_state)+ "_occupied"
		return

	//running
	icon_state = initial(icon_state)+ (state_open ? "_open" : "")

/obj/machinery/nanite_chamber/power_change()
	..()
	update_icon()

/obj/machinery/nanite_chamber/proc/toggle_open(mob/user)
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

/obj/machinery/nanite_chamber/container_resist(mob/living/user)
	if(!locked)
		open_machine()
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message("<span class='notice'>You see [user] kicking against the door of [src]!</span>", \
		"<span class='notice'>You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(breakout_time)].)</span>", \
		"<span class='italics'>You hear a metallic creaking from [src].</span>")
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || state_open || !locked)
			return
		locked = FALSE
		user.visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>", \
			"<span class='notice'>You successfully break out of [src]!</span>")
		open_machine()

/obj/machinery/nanite_chamber/close_machine(mob/living/carbon/user)
	if(!state_open)
		return FALSE

	..(user)
	return TRUE

/obj/machinery/nanite_chamber/open_machine()
	if(state_open)
		return FALSE

	..()

	return TRUE

/obj/machinery/nanite_chamber/relaymove(mob/user as mob)
	if(user.stat || locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, "<span class='warning'>[src]'s door won't budge!</span>")
		return
	open_machine()

/obj/machinery/nanite_chamber/attackby(obj/item/I, mob/user, params)
	if(!occupant && default_deconstruction_screwdriver(user, icon_state, icon_state, I))//sent icon_state is irrelevant...
		update_icon()//..since we're updating the icon here, since the scanner can be unpowered when opened/closed
		return

	if(default_pry_open(I))
		return

	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/nanite_chamber/interact(mob/user)
	toggle_open(user)

/obj/machinery/nanite_chamber/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	close_machine(target)