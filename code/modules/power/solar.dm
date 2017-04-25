#define SOLAR_MAX_DIST 40
#define SOLARGENRATE 1500

/obj/machinery/power/solar
	name = "solar panel"
	desc = "A solar panel. Generates electricity when in contact with sunlight."
	icon = 'icons/obj/power.dmi'
	icon_state = "sp_base"
	anchored = 1
	density = 1
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0
	var/id = 0
	obj_integrity = 150
	max_integrity = 150
	integrity_failure = 50
	var/obscured = 0
	var/sunfrac = 0
	var/adir = SOUTH // actual dir
	var/ndir = SOUTH // target dir
	var/turn_angle = 0
	var/obj/machinery/power/solar_control/control = null

/obj/machinery/power/solar/New(var/turf/loc, var/obj/item/solar_assembly/S)
	..(loc)
	Make(S)
	connect_to_network()

/obj/machinery/power/solar/Destroy()
	unset_control() //remove from control computer
	return ..()

//set the control of the panel to a given computer if closer than SOLAR_MAX_DIST
/obj/machinery/power/solar/proc/set_control(obj/machinery/power/solar_control/SC)
	if(!SC || (get_dist(src, SC) > SOLAR_MAX_DIST))
		return 0
	control = SC
	SC.connected_panels |= src
	return 1

//set the control of the panel to null and removes it from the control list of the previous control computer if needed
/obj/machinery/power/solar/proc/unset_control()
	if(control)
		control.connected_panels.Remove(src)
	control = null

/obj/machinery/power/solar/proc/Make(obj/item/solar_assembly/S)
	if(!S)
		S = new /obj/item/solar_assembly(src)
		S.glass_type = /obj/item/stack/sheet/glass
		S.anchored = 1
	S.loc = src
	if(S.glass_type == /obj/item/stack/sheet/rglass) //if the panel is in reinforced glass
		max_integrity *= 2 								 //this need to be placed here, because panels already on the map don't have an assembly linked to
		obj_integrity = max_integrity
	update_icon()

/obj/machinery/power/solar/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/crowbar))
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		user.visible_message("[user] begins to take the glass off the solar panel.", "<span class='notice'>You begin to take the glass off the solar panel...</span>")
		if(do_after(user, 50*W.toolspeed, target = src))
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message("[user] takes the glass off the solar panel.", "<span class='notice'>You take the glass off the solar panel.</span>")
			deconstruct(TRUE)
	else
		return ..()

/obj/machinery/power/solar/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(stat & BROKEN)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 60, 1)
			else
				playsound(loc, 'sound/effects/Glasshit.ogg', 90, 1)
		if(BURN)
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)


/obj/machinery/power/solar/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT))
		playsound(loc, 'sound/effects/Glassbr3.ogg', 100, 1)
		stat |= BROKEN
		unset_control()
		update_icon()

/obj/machinery/power/solar/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(disassembled)
			var/obj/item/solar_assembly/S = locate() in src
			if(S)
				S.forceMove(loc)
				S.give_glass(stat & BROKEN)
		else
			playsound(src, "shatter", 70, 1)
			new /obj/item/weapon/shard(src.loc)
			new /obj/item/weapon/shard(src.loc)
	qdel(src)


/obj/machinery/power/solar/update_icon()
	..()
	cut_overlays()
	if(stat & BROKEN)
		add_overlay(mutable_appearance(icon, "solar_panel-b", FLY_LAYER))
	else
		add_overlay(mutable_appearance(icon, "solar_panel", FLY_LAYER))
		src.setDir(angle2dir(adir))

//calculates the fraction of the sunlight that the panel recieves
/obj/machinery/power/solar/proc/update_solar_exposure()
	if(obscured)
		sunfrac = 0
		return

	//find the smaller angle between the direction the panel is facing and the direction of the sun (the sign is not important here)
	var/p_angle = min(abs(adir - SSsun.angle), 360 - abs(adir - SSsun.angle))

	if(p_angle > 90)			// if facing more than 90deg from sun, zero output
		sunfrac = 0
		return

	sunfrac = cos(p_angle) ** 2
	//isn't the power recieved from the incoming light proportionnal to cos(p_angle) (Lambert's cosine law) rather than cos(p_angle)^2 ?

/obj/machinery/power/solar/process()//TODO: remove/add this from machines to save on processing as needed ~Carn PRIORITY
	if(stat & BROKEN)
		return
	if(!control) //if there's no sun or the panel is not linked to a solar control computer, no need to proceed
		return

	if(powernet)
		if(powernet == control.powernet)//check if the panel is still connected to the computer
			if(obscured) //get no light from the sun, so don't generate power
				return
			var/sgen = SOLARGENRATE * sunfrac
			add_avail(sgen)
			control.gen += sgen
		else //if we're no longer on the same powernet, remove from control computer
			unset_control()


/obj/machinery/power/solar/fake/New(var/turf/loc, var/obj/item/solar_assembly/S)
	..(loc, S, 0)

/obj/machinery/power/solar/fake/process()
	. = PROCESS_KILL
	return

//trace towards sun to see if we're in shadow
/obj/machinery/power/solar/proc/occlusion()

	var/ax = x		// start at the solar panel
	var/ay = y
	var/turf/T = null
	var/dx = SSsun.dx
	var/dy = SSsun.dy

	for(var/i = 1 to 20)		// 20 steps is enough
		ax += dx	// do step
		ay += dy

		T = locate( round(ax,0.5),round(ay,0.5),z)

		if(T.x == 1 || T.x==world.maxx || T.y==1 || T.y==world.maxy)		// not obscured if we reach the edge
			break

		if(T.density)			// if we hit a solid turf, panel is obscured
			obscured = 1
			return

	obscured = 0		// if hit the edge or stepped 20 times, not obscured
	update_solar_exposure()


//
// Solar Assembly - For construction of solar arrays.
//

/obj/item/solar_assembly
	name = "solar panel assembly"
	desc = "A solar panel assembly kit, allows constructions of a solar panel, or with a tracking circuit board, a solar tracker."
	icon = 'icons/obj/power.dmi'
	icon_state = "sp_base"
	item_state = "electropack"
	w_class = WEIGHT_CLASS_BULKY // Pretty big!
	anchored = 0
	var/tracker = 0
	var/glass_type = null

/obj/item/solar_assembly/attack_hand(mob/user)
	if(!anchored && isturf(loc)) // You can't pick it up
		..()

// Give back the glass type we were supplied with
/obj/item/solar_assembly/proc/give_glass(device_broken)
	if(device_broken)
		new /obj/item/weapon/shard(loc)
		new /obj/item/weapon/shard(loc)
	else if(glass_type)
		var/obj/item/stack/sheet/S = new glass_type(loc)
		S.amount = 2
	glass_type = null


/obj/item/solar_assembly/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench) && isturf(loc))
		if(isinspace())
			to_chat(user, "<span class='warning'>You can't secure [src] here.</span>")
			return
		anchored = !anchored
		if(anchored)
			user.visible_message("[user] wrenches the solar assembly into place.", "<span class='notice'>You wrench the solar assembly into place.</span>")
			playsound(src.loc, W.usesound, 75, 1)
		else
			user.visible_message("[user] unwrenches the solar assembly from its place.", "<span class='notice'>You unwrench the solar assembly from its place.</span>")
			playsound(src.loc, W.usesound, 75, 1)
		return 1

	if(istype(W, /obj/item/stack/sheet/glass) || istype(W, /obj/item/stack/sheet/rglass))
		if(!anchored)
			to_chat(user, "<span class='warning'>You need to secure the assembly before you can add glass.</span>")
			return
		var/obj/item/stack/sheet/S = W
		if(S.use(2))
			glass_type = W.type
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			user.visible_message("[user] places the glass on the solar assembly.", "<span class='notice'>You place the glass on the solar assembly.</span>")
			if(tracker)
				new /obj/machinery/power/tracker(get_turf(src), src)
			else
				new /obj/machinery/power/solar(get_turf(src), src)
		else
			to_chat(user, "<span class='warning'>You need two sheets of glass to put them into a solar panel!</span>")
			return
		return 1

	if(!tracker)
		if(istype(W, /obj/item/weapon/electronics/tracker))
			if(!user.drop_item())
				return
			tracker = 1
			qdel(W)
			user.visible_message("[user] inserts the electronics into the solar assembly.", "<span class='notice'>You insert the electronics into the solar assembly.</span>")
			return 1
	else
		if(istype(W, /obj/item/weapon/crowbar))
			new /obj/item/weapon/electronics/tracker(src.loc)
			tracker = 0
			user.visible_message("[user] takes out the electronics from the solar assembly.", "<span class='notice'>You take out the electronics from the solar assembly.</span>")
			return 1
	return ..()

//
// Solar Control Computer
//

/obj/machinery/power/solar_control
	name = "solar panel control"
	desc = "A controller for solar panel arrays."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	anchored = 1
	density = 1
	use_power = 1
	idle_power_usage = 250
	obj_integrity = 200
	max_integrity = 200
	integrity_failure = 100
	var/icon_screen = "solar"
	var/icon_keyboard = "power_key"
	var/id = 0
	var/currentdir = 0
	var/targetdir = 0		// target angle in manual tracking (since it updates every game minute)
	var/gen = 0
	var/lastgen = 0
	var/track = 0			// 0= off  1=timed  2=auto (tracker)
	var/trackrate = 600		// 300-900 seconds
	var/nexttime = 0		// time for a panel to rotate of 1 degree in manual tracking
	var/obj/machinery/power/tracker/connected_tracker = null
	var/list/connected_panels = list()

/obj/machinery/power/solar_control/Initialize()
	. = ..()
	if(powernet)
		set_panels(currentdir)
	connect_to_network()

/obj/machinery/power/solar_control/Destroy()
	for(var/obj/machinery/power/solar/M in connected_panels)
		M.unset_control()
	if(connected_tracker)
		connected_tracker.unset_control()
	return ..()

/obj/machinery/power/solar_control/disconnect_from_network()
	..()
	SSsun.solars.Remove(src)

/obj/machinery/power/solar_control/connect_to_network()
	var/to_return = ..()
	if(powernet) //if connected and not already in solar_list...
		SSsun.solars |= src //... add it
	return to_return

//search for unconnected panels and trackers in the computer powernet and connect them
/obj/machinery/power/solar_control/proc/search_for_connected()
	if(powernet)
		for(var/obj/machinery/power/M in powernet.nodes)
			if(istype(M, /obj/machinery/power/solar))
				var/obj/machinery/power/solar/S = M
				if(!S.control) //i.e unconnected
					S.set_control(src)
			else if(istype(M, /obj/machinery/power/tracker))
				if(!connected_tracker) //if there's already a tracker connected to the computer don't add another
					var/obj/machinery/power/tracker/T = M
					if(!T.control) //i.e unconnected
						T.set_control(src)

//called by the sun controller, update the facing angle (either manually or via tracking) and rotates the panels accordingly
/obj/machinery/power/solar_control/proc/update()
	if(stat & (NOPOWER | BROKEN))
		return

	switch(track)
		if(1)
			if(trackrate) //we're manual tracking. If we set a rotation speed...
				currentdir = targetdir //...the current direction is the targetted one (and rotates panels to it)
		if(2) // auto-tracking
			if(connected_tracker)
				connected_tracker.set_angle(SSsun.angle)

	set_panels(currentdir)
	updateDialog()

/obj/machinery/power/solar_control/update_icon()
	cut_overlays()
	if(stat & NOPOWER)
		add_overlay("[icon_keyboard]_off")
		return
	add_overlay(icon_keyboard)
	if(stat & BROKEN)
		add_overlay("[icon_state]_broken")
	else
		add_overlay(icon_screen)
	if(currentdir > -1)
		setDir(angle2dir(currentdir))
		add_overlay(mutable_appearance(icon, "solcon-o", FLY_LAYER))

/obj/machinery/power/solar_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
												datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "solar_control", name, 500, 400, master_ui, state)
		ui.open()

/obj/machinery/power/solar_control/ui_data()
	var/data = list()

	data["generated"] = round(lastgen)
	data["angle"] = currentdir
	data["direction"] = angle2text(currentdir)

	data["tracking_state"] = track
	data["tracking_rate"] = trackrate
	data["rotating_way"] = (trackrate<0 ? "CCW" : "CW")

	data["connected_panels"] = connected_panels.len
	data["connected_tracker"] = (connected_tracker ? 1 : 0)
	return data

/obj/machinery/power/solar_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("direction")
			var/adjust = text2num(params["adjust"])
			if(adjust)
				currentdir = Clamp((360 + adjust + currentdir) % 360, 0, 359)
				targetdir = currentdir
				set_panels(currentdir)
				. = TRUE
		if("rate")
			var/adjust = text2num(params["adjust"])
			if(adjust)
				trackrate = Clamp(trackrate + adjust, -7200, 7200)
				if(trackrate)
					nexttime = world.time + 36000 / abs(trackrate)
				. = TRUE
		if("tracking")
			var/mode = text2num(params["mode"])
			if(mode)
				track = mode
				. = TRUE
			if(mode == 2 && connected_tracker)
				connected_tracker.set_angle(SSsun.angle)
				set_panels(currentdir)
			else if(mode == 1)
				targetdir = currentdir
				if(trackrate)
					nexttime = world.time + 36000 / abs(trackrate)
				set_panels(targetdir)
		if("refresh")
			search_for_connected()
			if(connected_tracker && track == 2)
				connected_tracker.set_angle(SSsun.angle)
			set_panels(currentdir)
			. = TRUE

/obj/machinery/power/solar_control/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, I.usesound, 50, 1)
		if(do_after(user, 20*I.toolspeed, target = src))
			if (src.stat & BROKEN)
				to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				var/obj/structure/frame/computer/A = new /obj/structure/frame/computer( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/computer/solar_control/M = new /obj/item/weapon/circuitboard/computer/solar_control( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				qdel(src)
			else
				to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				var/obj/structure/frame/computer/A = new /obj/structure/frame/computer( src.loc )
				var/obj/item/weapon/circuitboard/computer/solar_control/M = new /obj/item/weapon/circuitboard/computer/solar_control( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				qdel(src)
	else if(user.a_intent != INTENT_HARM && !(I.flags & NOBLUDGEON))
		src.attack_hand(user)
	else
		return ..()

/obj/machinery/power/solar_control/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
			else
				playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

/obj/machinery/power/solar_control/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT))
		playsound(loc, 'sound/effects/Glassbr3.ogg', 100, 1)
		stat |= BROKEN
		update_icon()

/obj/machinery/power/solar_control/process()
	lastgen = gen
	gen = 0

	if(stat & (NOPOWER | BROKEN))
		return

	if(connected_tracker) //NOTE : handled here so that we don't add trackers to the processing list
		if(connected_tracker.powernet != powernet)
			connected_tracker.unset_control()

	if(track==1 && trackrate) //manual tracking and set a rotation speed
		if(nexttime <= world.time) //every time we need to increase/decrease the angle by 1�...
			targetdir = (targetdir + trackrate/abs(trackrate) + 360) % 360 	//... do it
			nexttime += 36000/abs(trackrate) //reset the counter for the next 1�

//rotates the panel to the passed angle
/obj/machinery/power/solar_control/proc/set_panels(currentdir)

	for(var/obj/machinery/power/solar/S in connected_panels)
		S.adir = currentdir //instantly rotates the panel
		S.occlusion()//and
		S.update_icon() //update it

	update_icon()


/obj/machinery/power/solar_control/power_change()
	..()
	update_icon()




//
// MISC
//

/obj/item/weapon/paper/solar
	name = "paper- 'Going green! Setup your own solar array instructions.'"
	info = "<h1>Welcome</h1><p>At greencorps we love the environment, and space. With this package you are able to help mother nature and produce energy without any usage of fossil fuel or plasma! Singularity energy is dangerous while solar energy is safe, which is why it's better. Now here is how you setup your own solar array.</p><p>You can make a solar panel by wrenching the solar assembly onto a cable node. Adding a glass panel, reinforced or regular glass will do, will finish the construction of your solar panel. It is that easy!</p><p>Now after setting up 19 more of these solar panels you will want to create a solar tracker to keep track of our mother nature's gift, the sun. These are the same steps as before except you insert the tracker equipment circuit into the assembly before performing the final step of adding the glass. You now have a tracker! Now the last step is to add a computer to calculate the sun's movements and to send commands to the solar panels to change direction with the sun. Setting up the solar computer is the same as setting up any computer, so you should have no trouble in doing that. You do need to put a wire node under the computer, and the wire needs to be connected to the tracker.</p><p>Congratulations, you should have a working solar array. If you are having trouble, here are some tips. Make sure all solar equipment are on a cable node, even the computer. You can always deconstruct your creations if you make a mistake.</p><p>That's all to it, be safe, be green!</p>"
