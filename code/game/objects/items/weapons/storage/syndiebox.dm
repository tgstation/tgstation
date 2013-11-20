/* Chameleon boxes!
Can hold everything a normal box can, but can be disguised as any item sized normal or smaller!
By Miauw */
/obj/item/weapon/storage/box/chameleon
	name = "box"
	desc = "It's just an ordinary box."
	foldable = null
	var/active = 0

	var/saved_name //These vars contain info about the scanned object. Mostly self-explanatory.
	var/saved_desc
	var/saved_icon
	var/saved_icon_state
	var/saved_dir
	var/saved_item_state
	var/saved_pixel_x
	var/saved_pixel_y

	var/list/forbidden_objs = list(/obj/item/weapon/reagent_containers/food/snacks/icecream, /obj/structure/sign, /obj/structure/cable, /obj/machinery/atmospherics, /obj/machinery/light, /obj/machinery/hologram, /obj/machinery/camera, /obj/machinery/power/apc, /obj/machinery/field/containment, /obj/machinery/shieldwall, /obj/machinery/shield, /obj/effect, /obj/screen /*Just to be sure*/, /obj/structure/c_tray, /obj/structure/shuttle, /obj/structure/disposalpipe, /obj/machinery/alarm, /obj/machinery/access_button, /obj/machinery/embedded_controller, /obj/machinery/flasher_button, /obj/machinery/ignition_switch, /obj/machinery/light_switch, /obj/machinery/power/terminal, /obj/machinery/airlock_sensor, /obj/structure/extinguisher_cabinet, /obj/machinery/computer/security/telescreen/entertainment, /obj/item/ammo_casing, /obj/item/weapon/cigbutt, /obj/item/weapon/match, /obj/item/weapon/pai_cable, /obj/item/weapon/pen, /obj/item/weapon/paper_bin, /obj/item/device/radio/beacon, /obj/item/device/radio/intercom, /obj/item/trash, /obj/item/clothing/mask/cigarette, /obj/structure/flora, /obj/structure/m_tray, /obj/structure/window, /obj/structure/noticeboard, /obj/machinery/firealarm, /obj/machinery/newscaster, /obj/machinery/requests_console, /obj/structure/plasticflaps, /obj/structure/lattice, /obj/machinery/conveyor, /obj/machinery/keycard_auth, /obj/machinery/driver_button, /obj/machinery/door/firedoor) //Some things just shouldn't be scanned. This generally has to do with: 1. Overlays (Ice cream cones), 2. Stuff that doesn't make sense (Holograms) and 3. Balancing.
	origin_tech = "syndicate=2;magnets=2"

/obj/item/weapon/storage/box/chameleon/attack_self(mob/user)
	toggle()

/obj/item/weapon/storage/box/chameleon/afterattack(atom/target, mob/user , proximity)
	if(!proximity) return

	if(!active)
		if(target.loc != src && istype(target,/obj)) //It can be everything you want it to be~ //Now it can truely be everything you want it to be, thanks to Pete. Have fun with your dildo-filled holographic doors.

			for(var/checktype in forbidden_objs)
				if(istype(target,checktype))
					user << "<span class='warning'>You can't get a good read on [target].</span>"
					return

			playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1, -6)
			user << "<span class='notice'>Scanned [target].</span>"

			saved_name = target.name
			saved_desc = target.desc
			saved_icon = target.icon
			saved_icon_state = target.icon_state
			saved_dir = target.dir
			saved_pixel_x = target.pixel_x
			saved_pixel_y = target.pixel_y

			if(istype(target, /obj/item))
				var/obj/item/targetitem = target //Neccesary for item_state
				saved_item_state = targetitem.item_state

/obj/item/weapon/storage/box/chameleon/proc/toggle()
	if(active)
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)
		icon = initial(icon)
		item_state = initial(item_state)
		dir = initial(dir)
		pixel_x = initial(pixel_x)
		pixel_y = initial(pixel_y)

		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		active = 0

	else if(!active && saved_name) //Only one saved_ var is checked because they're all set at the same time.
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)

		name = saved_name //Set the box's appearance
		desc = saved_desc
		icon = saved_icon
		icon_state = saved_icon_state
		item_state = saved_item_state
		dir = saved_dir
		pixel_x = saved_pixel_x
		pixel_y = saved_pixel_y

		saved_name = null //Reset the vars.
		saved_desc = null
		saved_icon = null
		saved_icon_state = null
		saved_item_state = null
		saved_dir = null
		saved_pixel_x = null
		saved_pixel_y = null

		active = 1

	if(istype(loc, /mob/living/carbon)) //Update inhands (hopefully)
		var/mob/living/carbon/C = loc
		C.update_inv_l_hand()
		C.update_inv_r_hand()

/obj/item/weapon/storage/box/chameleon/proc/disrupt()
	if(active)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 0, src)
		s.start()
		toggle()
		return //Attention, return here. If you're calling this make sure it's on the END of the proc you're calling it in!

/obj/item/weapon/storage/box/chameleon/handle_item_insertion(obj/item/W, prevent_warning = 0)
	disrupt() //Can't push things trough from the outside if it's on.
	..()

/obj/item/weapon/storage/box/chameleon/emp_act(var/severity)
	disrupt()

/obj/item/weapon/storage/box/chameleon/ex_act(var/severity)
	..()
	disrupt()

/obj/item/weapon/storage/box/chameleon/bullet_act(var/obj/item/projectile/Proj)
	disrupt()
