/obj/machinery/space_heater
	anchored = 0
	density = 1
	icon = 'icons/obj/atmos.dmi'
	icon_state = "sheater0"
	name = "space heater"
	desc = "Made by Space Amish using traditional space techniques, this heater is guaranteed not to set the station on fire."
	var/obj/item/weapon/cell/cell
	var/on = 0
	var/set_temperature = 50		// in celcius, add T0C for kelvin
	var/heating_power = 40000
	var/base_state = "sheater"
	var/nocell = 0
	light_power_on = 0.75
	light_range_on = 2
	light_color = LIGHT_COLOR_ORANGE

	ghost_read = 0
	ghost_write = 0

	flags = FPRINT
	machine_flags = SCREWTOGGLE

/obj/machinery/space_heater/campfire
	name = "campfire"
	icon_state = "campfire0"
	base_state = "campfire"
	desc = "Warning: May attract Space Bears."
	light_power_on = 1.5
	light_range_on = 2
	light_color = LIGHT_COLOR_FIRE
	set_temperature = 35
	nocell = 1
	anchored = 1
	density = 0
	flags = null
	machine_flags = null
	var/lastcharge = null

/obj/machinery/space_heater/campfire/stove
	name = "stove"
	desc = "It's a stove, like the ones used over 6 centuries ago. Why is it in the future?"
	icon_state = "stove"
	base_state = "stove"
	density = 1
	nocell = 2
	machine_flags = WRENCHMOVE

/obj/machinery/space_heater/New()

	..()
	cell = new(src)
	cell.charge = 1000
	cell.maxcharge = 1000
	update_icon()
	return

/obj/machinery/space_heater/campfire/stove/New()
	..()
	cell.charge = 0
	update_icon()
	return

/obj/machinery/space_heater/campfire/stove/Crossed()
	//empty on purpose

/obj/machinery/space_heater/update_icon()
	overlays.len = 0
	icon_state = "[base_state][on]"
	set_light(on ? light_range_on : 0, light_power_on)
	if(panel_open)
		overlays  += "[base_state]-open"
	return

/obj/machinery/space_heater/campfire/update_icon()
	overlays.len = 0
	var/light_r = 0
	var/light_p = 0
	if(on)
		var/fireintensity = min(Floor((cell.charge-1)/(cell.maxcharge/4))+1,4)
		icon_state = "[base_state][fireintensity]"
		light_r = light_range_on+Floor(fireintensity/2)
		light_p = light_power_on+0.2*fireintensity
		set_temperature = 15 + 5*fireintensity
	else icon_state = "[base_state][on]"
	set_light(on ? light_r : 0, light_p)
	return

/obj/machinery/space_heater/examine(mob/user)
	..()
	if(!nocell)
		to_chat(user, "<span class='info'>[bicon(src)]\The [src.name] is [on ? "on" : "off"] and the hatch is [panel_open ? "open" : "closed"].</span>")
		if(panel_open)
			to_chat(user, "<span class='info'>The power cell is [cell ? "installed" : "missing"].</span>")
		else
			to_chat(user, "<span class='info'>The charge meter reads [cell ? round(cell.percent(),1) : 0]%</span>")

/obj/machinery/space_heater/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if((cell) && (!nocell))
		cell.emp_act(severity)
		..(severity)

/obj/machinery/space_heater/attackby(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/weapon/cell) && !nocell)
		if(panel_open)
			if(cell)
				to_chat(user, "There is already a power cell inside.")
				return
			else
				// insert cell
				var/obj/item/weapon/cell/C = usr.get_active_hand()
				if(istype(C))
					if(user.drop_item(C, src))
						cell = C
						C.add_fingerprint(usr)
						user.visible_message("<span class='notice'>[user] inserts a power cell into [src].</span>", "<span class='notice'>You insert the power cell into [src].</span>")
		else
			to_chat(user, "The hatch must be open to insert a power cell.")
			return
	return

/obj/machinery/space_heater/campfire/attackby(obj/item/I, mob/user)
	..()
	if(!on && cell.charge > 0)
	//Items with special messages go first - yes, this is all stolen from cigarette code. sue me.
		if(istype(I, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = I
			if(WT.is_hot()) //Badasses dont get blinded while lighting their !!campfire!! with a welding tool
				light("<span class='notice'>[user] casually lights \the [name] with \his [I], what a badass.</span>")
		else if(istype(I, /obj/item/weapon/lighter/zippo))
			var/obj/item/weapon/lighter/zippo/Z = I
			if(Z.is_hot())
				light("<span class='rose'>With a single flick of their wrist, [user] smoothly lights \the [name] with \his [I]. Damn, that's cool.</span>")
		else if(istype(I, /obj/item/weapon/lighter))
			var/obj/item/weapon/lighter/L = I
			if(L.is_hot())
				light("<span class='notice'>After some fiddling, [user] manages to light \the [name] with \his [I].</span>")
		else if(istype(I, /obj/item/weapon/melee/energy/sword))
			var/obj/item/weapon/melee/energy/sword/S = I
			if(S.is_hot())
				light("<span class='warning'>[user] raises \his [I.name], lighting \the [src]. Holy fucking shit.</span>")
		else if(istype(I, /obj/item/device/assembly/igniter))
			var/obj/item/device/assembly/igniter/Ig = I
			if(Ig.is_hot())
				light("<span class='notice'>[user] fiddles with \his [I.name], and manages to light \the [name].</span>")
		//All other items are included here, any item that is hot can light the campfire
		else if(I.is_hot())
			light("<span class='notice'>[user] lights \the [name] with \his [I].</span>")
		return
	if(istype(I, /obj/item/stack/sheet/wood) && ((on)||(nocell == 2)))
		var/woodnumber = input(user, "You may insert a maximum of four planks.", "How much wood would you like to add to \the [src]?", 0) as num
		woodnumber = Clamp(woodnumber,0,4)
		var/obj/item/stack/sheet/wood/woody = I
		woody.use(woodnumber)
		user.visible_message("<span class='notice'>[user] adds some wood to \the [src].</span>", "<span class='notice'>You add some wood to \the [src].</span>")
		cell.charge = min(cell.charge+woodnumber*250,cell.maxcharge)
		update_icon()
	if(on && istype(I,/obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/fag = I
		fag.light("<span class='notice'>[user] lights \the [fag] using \the [src]'s flames.</span>")

/obj/machinery/space_heater/campfire/proc/light(var/flavourtext = "<span class='notice'>[usr] lights \the [src].</span>")
	if(on)
		return
	var/turf/T = get_turf(src)
	T.visible_message(flavourtext)
	on = 1
	update_icon()

/obj/machinery/space_heater/togglePanelOpen(var/obj/toggleitem, mob/user)
	..()
	update_icon()
	if(!panel_open && user.machine == src)
		user << browse(null, "window=spaceheater")
		user.unset_machine()

/obj/machinery/space_heater/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	interact(user)

/obj/machinery/space_heater/interact(mob/user as mob)

	if(panel_open)

		var/dat
		dat = "Power cell: "
		if(cell)
			dat += "<A href='byond://?src=\ref[src];op=cellremove'>Installed</A><BR>"
		else
			dat += "<A href='byond://?src=\ref[src];op=cellinstall'>Removed</A><BR>"


		dat += {"Power Level: [cell ? round(cell.percent(),1) : 0]%<BR><BR>
			Set Temperature:
			<A href='?src=\ref[src];op=temp;val=-5'>-</A>
			[set_temperature]&deg;C
			<A href='?src=\ref[src];op=temp;val=5'>+</A><BR>"}
		user.set_machine(src)
		user << browse("<HEAD><TITLE>Space Heater Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=spaceheater")
		onclose(user, "spaceheater")




	else
		on = !on
		user.visible_message("<span class='notice'>[user] switches [on ? "on" : "off"] the [src].</span>","<span class='notice'>You switch [on ? "on" : "off"] the [src].</span>")
		update_icon()
	return

/obj/machinery/space_heater/campfire/interact(mob/user as mob)
	if(on)
		user.delayNextAttack(50)
		if(do_after(user,src,50))
			var/mob/living/M = user
			if ((M_CLUMSY in M.mutations) && (prob(50)))
				user.visible_message("<span class='danger'>[user] slides \his hands straight into \the [src]!</span>", "<span class='danger'>You accidentally slide your hands into \the [src]!</span>")
				M.apply_damage(10,BURN,(pick("l_hand", "r_hand")))
			else
				user.visible_message("<span class='notice'>[user] warms \his hands around \the [src].</span>", "<span class='notice'>You warm your hands around \the [src].</span>")
			M.bodytemperature += 2

/obj/machinery/space_heater/Topic(href, href_list)
	if (usr.stat)
		return
	if ((in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

		switch(href_list["op"])

			if("temp")
				var/value = text2num(href_list["val"])

				// limit to 20-90 degC
				set_temperature = Clamp(set_temperature + value, 20, 90)

			if("cellremove")
				if(panel_open && cell && !usr.get_active_hand())
					cell.updateicon()
					usr.put_in_hands(cell)
					cell.add_fingerprint(usr)
					cell = null
					usr.visible_message("<span class='notice'>[usr] removes the power cell from \the [src].</span>", "<span class='notice'>You remove the power cell from \the [src].</span>")

			if("cellinstall")
				if(panel_open && !cell)
					var/obj/item/weapon/cell/C = usr.get_active_hand()
					if(istype(C))
						if(usr.drop_item(C, src))
							cell = C
							C.add_fingerprint(usr)

							usr.visible_message("<span class='notice'>[usr] inserts a power cell into \the [src].</span>", "<span class='notice'>You insert the power cell into \the [src].</span>")

		updateDialog()
	else
		usr << browse(null, "window=spaceheater")
		usr.unset_machine()
	return



/obj/machinery/space_heater/process()
	if(on)
		if(cell && cell.charge > 0)

			var/turf/simulated/L = loc
			if(istype(L))
				var/datum/gas_mixture/env = L.return_air()
				if(env.temperature != set_temperature + T0C)

					var/transfer_moles = 0.25 * env.total_moles()

					var/datum/gas_mixture/removed = env.remove(transfer_moles)

//					to_chat(world, "got [transfer_moles] moles at [removed.temperature]")

					if(removed)

						var/heat_capacity = removed.heat_capacity()
//						to_chat(world, "heating ([heat_capacity])")
						if(heat_capacity) // Added check to avoid divide by zero (oshi-) runtime errors -- TLE
							if(removed.temperature < set_temperature + T0C)
								removed.temperature = min(removed.temperature + heating_power/heat_capacity, 1000) // Added min() check to try and avoid wacky superheating issues in low gas scenarios -- TLE
							else
								removed.temperature = max(removed.temperature - heating_power/heat_capacity, TCMB)
							cell.use(heating_power/20000)

//						to_chat(world, "now at [removed.temperature]")

					env.merge(removed)
			 if(!istype(loc,/turf/space))
			 	for (var/mob/living/carbon/M in view(src,light_range_on))
			 		M.bodytemperature += 0.01 * set_temperature * 1/((get_dist(src,M)+1)) // this is a temporary algorithm until we fix life to not have body temperature change so willy-nilly.
		else
			on = 0
			update_icon()


	return

/obj/machinery/space_heater/campfire/process()
	..()
	var/list/comfyfire = list('sound/misc/comfyfire1.ogg','sound/misc/comfyfire2.ogg','sound/misc/comfyfire3.ogg',)
	if(Floor(cell.charge/10) != lastcharge)
		update_icon()
	if(!(cell && cell.charge > 0) && nocell != 2)
		new /obj/effect/decal/cleanable/campfire(get_turf(src))
		qdel(src)
	lastcharge = Floor(cell.charge/10)
	if(on)
		playsound(get_turf(src), pick(comfyfire), (cell.charge/250)*5, 1, -1,channel = 124)


/obj/machinery/space_heater/campfire/Crossed(mob/user as mob)
	if(istype(user,/mob/living/carbon) && on)
		var/mob/living/carbon/absolutemadman = user
		absolutemadman.adjust_fire_stacks(1)
		if(absolutemadman.IgniteMob())
			absolutemadman.visible_message("<span class='danger'>[user] walks into \the [src], and is set alight!</span>", "<span class='danger'>You walk into \the [src], and are set alight!</span>")

/obj/machinery/space_heater/campfire/stove/fireplace
	name = "fireplace"
	icon = 'icons/obj/fireplace.dmi'
	icon_state = "fireplace"
	base_state = "fireplace"
	desc = "The wood cracks and pops as the fire dances across its grainy surface. The sweet and smokey smell reminds you of smores and hot chocolate."
	light_power_on = 0.8
	light_range_on = 0
	nocell = 2
	density = 0
	pixel_x = -16
	pixel_y = 16

/obj/machinery/space_heater/campfire/stove/fireplace/attackby(obj/item/I, mob/user)
	var/shoesfound = 0
	for(var/obj/W in contents)
		if(istype(W,/obj/item/clothing/shoes))
			shoesfound = 1
//		if(istype(W,/obj/item/weapon/gun/projectile))
//			gunfound = 1
	if(istype(I,/obj/item/clothing/shoes) && !(shoesfound))
		user.drop_item(I,src)
		src.update_icon()
//	else if(istype(I,/obj/item/weapon/gun/projectile) && !(gunfound))
	else
		..()

/obj/machinery/space_heater/campfire/stove/fireplace/update_icon()
	overlays.len = 0
	var/light_r = 0
	if(on)
		var/fireintensity = min(Floor((cell.charge-1)/(cell.maxcharge/4))+1,4)
		if(cell.charge > 150)
			src.overlays += image(icon,"fireplace_glow",LIGHTING_LAYER + 1)
		switch(cell.charge)
			if(15 to 149)
				src.overlays += image(icon,"fireplace_fire0",LIGHTING_LAYER + 1)
			if(150 to 249)
				src.overlays += image(icon,"fireplace_fire1",LIGHTING_LAYER + 1)
			if(250 to 499)
				src.overlays += image(icon,"fireplace_fire2",LIGHTING_LAYER + 1)
			if(500 to 749)
				src.overlays += image(icon,"fireplace_fire3",LIGHTING_LAYER + 1)
			if(750 to INFINITY)
				src.overlays += image(icon,"fireplace_fire4",LIGHTING_LAYER + 1)
		light_r = max(1.1,cell.charge/100)
		set_temperature = 15 + 5*fireintensity
	set_light(on ? light_r : 0, light_power_on)
//	var/gunfound = 0
	for(var/obj/W in contents)
		if(istype(W,/obj/item/clothing/shoes))
			src.overlays += image(icon,"fireplace_stocking")
//		var/icon/img = image(I.icon,I.icon_state)
//		img.Scale(12,12)
//		//img.pixel_y += 12
//		src.overlays += img
//		user.drop_item(I,src)