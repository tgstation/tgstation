/* Windoor (window door) assembly -Nodrak
 * Step 1: Create a windoor out of rglass
 * Step 2: Add plasteel to the assembly to make a secure windoor (Optional)
 * Step 3: Rotate or Flip the assembly to face and open the way you want
 * Step 4: Wrench the assembly in place
 * Step 5: Add cables to the assembly
 * Step 6: Set access for the door.
 * Step 7: Screwdriver the door to complete
 */


/obj/structure/windoor_assembly
	icon = 'icons/obj/doors/windoor.dmi'

	name = "Windoor Assembly"
	icon_state = "l_windoor_assembly01"
	anchored = 0
	density = 0
	dir = NORTH

	var/ini_dir
	var/obj/item/weapon/circuitboard/airlock/electronics = null

	//Vars to help with the icon's name
	var/facing = "l"	//Does the windoor open to the left or right?
	var/secure = ""		//Whether or not this creates a secure windoor
	var/state = "01"	//How far the door assembly has progressed in terms of sprites
	var/plasma = 0

/obj/structure/windoor_assembly/plasma
	icon = 'icons/obj/doors/plasmawindoor.dmi'
	name = "Plasma Windoor Assembly"
	plasma = 1

/obj/structure/windoor_assembly/New(dir=NORTH)
	..()
	src.ini_dir = src.dir
	update_nearby_tiles()

obj/structure/windoor_assembly/Destroy()
	density = 0
	update_nearby_tiles()
	..()

/obj/structure/windoor_assembly/update_icon()
	icon_state = "[facing]_[secure]windoor_assembly[state]"

/obj/structure/windoor_assembly/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		if(air_group) return 0
		return !density
	else
		return 1

/obj/structure/windoor_assembly/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1


/obj/structure/windoor_assembly/attackby(obj/item/W as obj, mob/user as mob)
	//I really should have spread this out across more states but thin little windoors are hard to sprite.
	switch(state)
		if("01")
			if(iswelder(W) && !anchored )
				var/obj/item/weapon/weldingtool/WT = W
				if (WT.remove_fuel(0,user))
					user.visible_message("[user] dissassembles the windoor assembly.", "You start to dissassemble the windoor assembly.")
					playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)

					if(do_after(user, 40))
						if(!src || !WT.isOn()) return
						user << "<span class='notice'>You dissasembled the windoor assembly!</span>"
						new /obj/item/stack/sheet/glass/rglass(get_turf(src), 5)
						if(secure)
							new /obj/item/stack/rods(get_turf(src), 4)
						del(src)
				else
					user << "<span class='rose'>You need more welding fuel to dissassemble the windoor assembly.</span>"
					return

			//Wrenching an unsecure assembly anchors it in place. Step 4 complete
			if(iswrench(W) && !anchored)
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
				user.visible_message("[user] secures the windoor assembly to the floor.", "You start to secure the windoor assembly to the floor.")

				if(do_after(user, 40))
					if(!src) return
					user << "<span class='notice'>You've secured the windoor assembly!</span>"
					src.anchored = 1
					if(src.secure)
						src.name = "Secure Anchored Windoor Assembly"
					else
						src.name = "Anchored Windoor Assembly"

			//Unwrenching an unsecure assembly un-anchors it. Step 4 undone
			else if(istype(W, /obj/item/weapon/wrench) && anchored)
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
				user.visible_message("[user] unsecures the windoor assembly to the floor.", "You start to unsecure the windoor assembly to the floor.")

				if(do_after(user, 40))
					if(!src) return
					user << "<span class='notice'>You've unsecured the windoor assembly!</span>"
					src.anchored = 0
					if(src.secure)
						src.name = "Secure Windoor Assembly"
					else
						src.name = "Windoor Assembly"

			//Adding plasteel makes the assembly a secure windoor assembly. Step 2 (optional) complete.
			else if(istype(W, /obj/item/stack/sheet/plasteel) && !secure)
				var/obj/item/stack/sheet/plasteel/P = W
				if(P.amount < 2)
					user << "<span class='rose'>You need more plasteel to do this.</span>"
					return
				user << "<span class='notice'>You start to reinforce the windoor with plasteel.</span>"

				if(do_after(user,40))
					if(!src) return

					P.use(2)
					user << "<span class='notice'>You reinforce the windoor.</span>"
					src.secure = "secure_"
					if(src.anchored)
						src.name = "Secure Anchored Windoor Assembly"
					else
						src.name = "Secure Windoor Assembly"

			//Adding cable to the assembly. Step 5 complete.
			else if(istype(W, /obj/item/stack/cable_coil) && anchored)
				user.visible_message("[user] wires the windoor assembly.", "You start to wire the windoor assembly.")

				if(do_after(user, 40))
					if(!src) return
					var/obj/item/stack/cable_coil/CC = W
					CC.use(1)
					user << "<span class='notice'>You wire the windoor!</span>"
					src.state = "02"
					if(src.secure)
						src.name = "Secure Wired Windoor Assembly"
					else
						src.name = "Wired Windoor Assembly"
			else
				..()

		if("02")

			//Removing wire from the assembly. Step 5 undone.
			if(iswirecutter(W))
				playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 100, 1)
				user.visible_message("[user] cuts the wires from the airlock assembly.", "You start to cut the wires from airlock assembly.")

				if(do_after(user, 40))
					if(!src || state != "02") return
					user << "<span class='notice'>You cut the windoor wires!</span>"
					new/obj/item/stack/cable_coil(get_turf(user), 1)
					src.state = "01"
					if(src.secure)
						src.name = "Secure Wired Windoor Assembly"
					else
						src.name = "Wired Windoor Assembly"

			//Adding airlock electronics for access. Step 6 complete.
			else if(istype(W, /obj/item/weapon/circuitboard/airlock) && W:icon_state != "door_electronics_smoked")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 100, 1)
				user.visible_message("[user] installs the electronics into the airlock assembly.", "You start to install electronics into the airlock assembly.")

				if(do_after(user, 40))
					if(!src) return

					user.drop_item(src)
					user << "<span class='notice'>You've installed the airlock electronics!</span>"
					src.name = "Near finished Windoor Assembly"
					src.electronics = W
				else
					W.loc = src.loc

			//Screwdriver to remove airlock electronics. Step 6 undone.
			else if(istype(W, /obj/item/weapon/screwdriver) && electronics)
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 100, 1)
				user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to uninstall electronics from the airlock assembly.")

				if(do_after(user, 40))
					if(!src) return
					user << "<span class='notice'>You've removed the airlock electronics!</span>"
					src.name = "Wired Windoor Assembly"
					var/obj/item/weapon/circuitboard/airlock/ae
					ae = electronics
					electronics = null
					ae.loc = src.loc


			//Crowbar to complete the assembly, Step 7 complete.
			else if(iscrowbar(W))
				if(!src.electronics)
					usr << "<span class='rose'>The assembly is missing electronics.</span>"
					return
				usr << browse(null, "window=windoor_access")
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 100, 1)
				user.visible_message("[user] pries the windoor into the frame.", "You start prying the windoor into the frame.")

				if(do_after(user, 40))

					if(!src) return
					var/obj/machinery/door/window/windoor = Create()
					density = 1 //Shouldn't matter but just incase
					user << "<span class='notice'>You finish the windoor!</span>"
					if(secure == "secure_")
						secure = "secure"
					if(src.facing == "l")
						windoor.icon_state = "left[secure]open"
						windoor.base_state = "left[secure]"
					else
						windoor.icon_state = "right[secure]open"
						windoor.base_state = "right[secure]"
					windoor.dir = src.dir
					windoor.density = 0

					windoor.req_access = src.electronics.conf_access
					windoor.electronics = src.electronics
					src.electronics.loc = windoor
					qdel(src)


			else
				..()

	//Update to reflect changes(if applicable)
	update_icon()

//I'm actually surprised this works, but boy am I pleased that it does
/obj/structure/windoor_assembly/proc/Create()
	if(secure && plasma)
		return new /obj/machinery/door/window/plasma/secure(src.loc)
	else if(secure && !plasma)
		return new /obj/machinery/door/window/brigdoor(src.loc)
	else if(plasma)
		return new /obj/machinery/door/window/plasma(src.loc)
	else
		return new /obj/machinery/door/window(src.loc)

//Rotates the windoor assembly clockwise
/obj/structure/windoor_assembly/verb/revrotate()
	set name = "Rotate Windoor Assembly"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the floor; therefore, you can't rotate it!"
		return 0
	if(src.state != "01")
		update_nearby_tiles() //Compel updates before

	src.dir = turn(src.dir, 270)

	if(src.state != "01")
		update_nearby_tiles()

	src.ini_dir = src.dir
	update_icon()
	return

//Flips the windoor assembly, determines whather the door opens to the left or the right
/obj/structure/windoor_assembly/verb/flip()
	set name = "Flip Windoor Assembly"
	set category = "Object"
	set src in oview(1)

	if(src.facing == "l")
		usr << "The windoor will now slide to the right."
		src.facing = "r"
	else
		src.facing = "l"
		usr << "The windoor will now slide to the left."

	update_icon()
	return

/obj/structure/windoor_assembly/proc/update_nearby_tiles()
	if (isnull(air_master))
		return 0

	var/T = loc

	if (isturf(T))
		air_master.mark_for_update(T)

	return 1
