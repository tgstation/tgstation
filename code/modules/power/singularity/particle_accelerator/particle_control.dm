/obj/machinery/particle_accelerator/control_box
	name = "Particle Accelerator Control Console"
	desc = "This controls the density of the particles."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "control_box"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 500
	active_power_usage = 10000
	dir = NORTH
	var/strength_upper_limit = 2
	var/interface_control = 1
	var/list/obj/structure/particle_accelerator/connected_parts
	var/assembled = 0
	var/construction_state = PA_CONSTRUCTION_UNSECURED
	var/active = 0
	var/strength = 0
	var/powered = 0
	mouse_opacity = MOUSE_OPACITY_OPAQUE

/obj/machinery/particle_accelerator/control_box/Initialize()
	. = ..()
	wires = new /datum/wires/particle_accelerator/control_box(src)
	connected_parts = list()

/obj/machinery/particle_accelerator/control_box/Destroy()
	if(active)
		toggle_power()
	for(var/CP in connected_parts)
		var/obj/structure/particle_accelerator/part = CP
		part.master = null
	connected_parts.Cut()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/particle_accelerator/control_box/attack_hand(mob/user)
	if(construction_state == PA_CONSTRUCTION_COMPLETE)
		interact(user)
	else if(construction_state == PA_CONSTRUCTION_PANEL_OPEN)
		wires.interact(user)

/obj/machinery/particle_accelerator/control_box/proc/update_state()
	if(construction_state < PA_CONSTRUCTION_COMPLETE)
		use_power = NO_POWER_USE
		assembled = 0
		active = 0
		for(var/CP in connected_parts)
			var/obj/structure/particle_accelerator/part = CP
			part.strength = null
			part.powered = 0
			part.update_icon()
		connected_parts.Cut()
		return
	if(!part_scan())
		use_power = IDLE_POWER_USE
		active = 0
		connected_parts.Cut()

/obj/machinery/particle_accelerator/control_box/update_icon()
	if(active)
		icon_state = "control_boxp1"
	else
		if(use_power)
			if(assembled)
				icon_state = "control_boxp"
			else
				icon_state = "ucontrol_boxp"
		else
			switch(construction_state)
				if(PA_CONSTRUCTION_UNSECURED, PA_CONSTRUCTION_UNWIRED)
					icon_state = "control_box"
				if(PA_CONSTRUCTION_PANEL_OPEN)
					icon_state = "control_boxw"
				else
					icon_state = "control_boxc"

/obj/machinery/particle_accelerator/control_box/Topic(href, href_list)
	if(..())
		return

	if(!interface_control)
		to_chat(usr, "<span class='error'>ERROR: Request timed out. Check wire contacts.</span>")
		return

	if(href_list["close"])
		usr << browse(null, "window=pacontrol")
		usr.unset_machine()
		return
	if(href_list["togglep"])
		if(!wires.is_cut(WIRE_POWER))
			toggle_power()

	else if(href_list["scan"])
		part_scan()

	else if(href_list["strengthup"])
		if(!wires.is_cut(WIRE_STRENGTH))
			add_strength()

	else if(href_list["strengthdown"])
		if(!wires.is_cut(WIRE_STRENGTH))
			remove_strength()

	updateDialog()
	update_icon()

/obj/machinery/particle_accelerator/control_box/proc/strength_change()
	for(var/CP in connected_parts)
		var/obj/structure/particle_accelerator/part = CP
		part.strength = strength
		part.update_icon()

/obj/machinery/particle_accelerator/control_box/proc/add_strength(s)
	if(assembled && (strength < strength_upper_limit))
		strength++
		strength_change()

		message_admins("PA Control Computer increased to [strength] by [ADMIN_LOOKUPFLW(usr)] in [ADMIN_COORDJMP(src)]",0,1)
		log_game("PA Control Computer increased to [strength] by [key_name(usr)] in [COORD(src)]")
		investigate_log("increased to <font color='red'>[strength]</font> by [key_name(usr)]", INVESTIGATE_SINGULO)


/obj/machinery/particle_accelerator/control_box/proc/remove_strength(s)
	if(assembled && (strength > 0))
		strength--
		strength_change()

		message_admins("PA Control Computer decreased to [strength] by [ADMIN_LOOKUPFLW(usr)] in [ADMIN_COORDJMP(src)]",0,1)
		log_game("PA Control Computer decreased to [strength] by [key_name(usr)] in [COORD(src)]")
		investigate_log("decreased to <font color='green'>[strength]</font> by [key_name(usr)]", INVESTIGATE_SINGULO)


/obj/machinery/particle_accelerator/control_box/power_change()
	..()
	if(stat & NOPOWER)
		active = 0
		use_power = NO_POWER_USE
	else if(!stat && construction_state == PA_CONSTRUCTION_COMPLETE)
		use_power = IDLE_POWER_USE

/obj/machinery/particle_accelerator/control_box/process()
	if(active)
		//a part is missing!
		if(connected_parts.len < 6)
			investigate_log("lost a connected part; It <font color='red'>powered down</font>.", INVESTIGATE_SINGULO)
			toggle_power()
			update_icon()
			return
		//emit some particles
		for(var/obj/structure/particle_accelerator/particle_emitter/PE in connected_parts)
			PE.emit_particle(strength)

/obj/machinery/particle_accelerator/control_box/proc/part_scan()
	var/ldir = turn(dir,-90)
	var/rdir = turn(dir,90)
	var/odir = turn(dir,180)
	var/turf/T = loc

	assembled = 0
	critical_machine = FALSE

	var/obj/structure/particle_accelerator/fuel_chamber/F = locate() in orange(1,src)
	if(!F)
		return 0

	setDir(F.dir)
	connected_parts.Cut()

	T = get_step(T,rdir)
	if(!check_part(T, /obj/structure/particle_accelerator/fuel_chamber))
		return 0
	T = get_step(T,odir)
	if(!check_part(T, /obj/structure/particle_accelerator/end_cap))
		return 0
	T = get_step(T,dir)
	T = get_step(T,dir)
	if(!check_part(T, /obj/structure/particle_accelerator/power_box))
		return 0
	T = get_step(T,dir)
	if(!check_part(T, /obj/structure/particle_accelerator/particle_emitter/center))
		return 0
	T = get_step(T,ldir)
	if(!check_part(T, /obj/structure/particle_accelerator/particle_emitter/left))
		return 0
	T = get_step(T,rdir)
	T = get_step(T,rdir)
	if(!check_part(T, /obj/structure/particle_accelerator/particle_emitter/right))
		return 0

	assembled = 1
	critical_machine = TRUE	//Only counts if the PA is actually assembled.
	return 1

/obj/machinery/particle_accelerator/control_box/proc/check_part(turf/T, type)
	var/obj/structure/particle_accelerator/PA = locate(/obj/structure/particle_accelerator) in T
	if(istype(PA, type) && (PA.construction_state == PA_CONSTRUCTION_COMPLETE))
		if(PA.connect_master(src))
			connected_parts.Add(PA)
			return 1
	return 0


/obj/machinery/particle_accelerator/control_box/proc/toggle_power()
	active = !active
	investigate_log("turned [active?"<font color='green'>ON</font>":"<font color='red'>OFF</font>"] by [usr ? key_name(usr) : "outside forces"]", INVESTIGATE_SINGULO)
	message_admins("PA Control Computer turned [active ?"ON":"OFF"] by [usr ? key_name_admin(usr) : "outside forces"](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	log_game("PA Control Computer turned [active ?"ON":"OFF"] by [usr ? "[key_name(usr)]" : "outside forces"] in ([x],[y],[z])")
	if(active)
		use_power = ACTIVE_POWER_USE
		for(var/CP in connected_parts)
			var/obj/structure/particle_accelerator/part = CP
			part.strength = strength
			part.powered = 1
			part.update_icon()
	else
		use_power = IDLE_POWER_USE
		for(var/CP in connected_parts)
			var/obj/structure/particle_accelerator/part = CP
			part.strength = null
			part.powered = 0
			part.update_icon()
	return 1


/obj/machinery/particle_accelerator/control_box/interact(mob/user)
	if((get_dist(src, user) > 1) || (stat & (BROKEN|NOPOWER)))
		if(!issilicon(user))
			user.unset_machine()
			user << browse(null, "window=pacontrol")
			return
	user.set_machine(src)

	var/dat = ""
	dat += "<A href='?src=\ref[src];close=1'>Close</A><BR><BR>"
	dat += "<h3>Status</h3>"
	if(!assembled)
		dat += "Unable to detect all parts!<BR>"
		dat += "<A href='?src=\ref[src];scan=1'>Run Scan</A><BR><BR>"
	else
		dat += "All parts in place.<BR><BR>"
		dat += "Power:"
		if(active)
			dat += "On<BR>"
		else
			dat += "Off <BR>"
		dat += "<A href='?src=\ref[src];togglep=1'>Toggle Power</A><BR><BR>"
		dat += "Particle Strength: [strength] "
		dat += "<A href='?src=\ref[src];strengthdown=1'>--</A>|<A href='?src=\ref[src];strengthup=1'>++</A><BR><BR>"

	var/datum/browser/popup = new(user, "pacontrol", name, 420, 300)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/particle_accelerator/control_box/examine(mob/user)
	..()
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			to_chat(user, "Looks like it's not attached to the flooring")
		if(PA_CONSTRUCTION_UNWIRED)
			to_chat(user, "It is missing some cables")
		if(PA_CONSTRUCTION_PANEL_OPEN)
			to_chat(user, "The panel is open")


/obj/machinery/particle_accelerator/control_box/attackby(obj/item/W, mob/user, params)
	var/did_something = FALSE

	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			if(istype(W, /obj/item/weapon/wrench) && !isinspace())
				playsound(loc, W.usesound, 75, 1)
				anchored = TRUE
				user.visible_message("[user.name] secures the [name] to the floor.", \
					"You secure the external bolts.")
				construction_state = PA_CONSTRUCTION_UNWIRED
				did_something = TRUE
		if(PA_CONSTRUCTION_UNWIRED)
			if(istype(W, /obj/item/weapon/wrench))
				playsound(loc, W.usesound, 75, 1)
				anchored = FALSE
				user.visible_message("[user.name] detaches the [name] from the floor.", \
					"You remove the external bolts.")
				construction_state = PA_CONSTRUCTION_UNSECURED
				did_something = TRUE
			else if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/CC = W
				if(CC.use(1))
					user.visible_message("[user.name] adds wires to the [name].", \
						"You add some wires.")
					construction_state = PA_CONSTRUCTION_PANEL_OPEN
					did_something = TRUE
		if(PA_CONSTRUCTION_PANEL_OPEN)
			if(istype(W, /obj/item/weapon/wirecutters))//TODO:Shock user if its on?
				user.visible_message("[user.name] removes some wires from the [name].", \
					"You remove some wires.")
				construction_state = PA_CONSTRUCTION_UNWIRED
				did_something = TRUE
			else if(istype(W, /obj/item/weapon/screwdriver))
				user.visible_message("[user.name] closes the [name]'s access panel.", \
					"You close the access panel.")
				construction_state = PA_CONSTRUCTION_COMPLETE
				did_something = TRUE
		if(PA_CONSTRUCTION_COMPLETE)
			if(istype(W, /obj/item/weapon/screwdriver))
				user.visible_message("[user.name] opens the [name]'s access panel.", \
					"You open the access panel.")
				construction_state = PA_CONSTRUCTION_PANEL_OPEN
				did_something = TRUE

	if(did_something)
		user.changeNext_move(CLICK_CD_MELEE)
		update_state()
		update_icon()
		return

	..()

/obj/machinery/particle_accelerator/control_box/blob_act(obj/structure/blob/B)
	if(prob(50))
		qdel(src)

#undef PA_CONSTRUCTION_UNSECURED
#undef PA_CONSTRUCTION_UNWIRED
#undef PA_CONSTRUCTION_PANEL_OPEN
#undef PA_CONSTRUCTION_COMPLETE
