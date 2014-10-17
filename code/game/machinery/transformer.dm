/obj/machinery/transformer
	name = "Automatic Robotic Factory 5000"
	desc = "A large metallic machine with an entrance and an exit. A sign on the side reads 'human goes in, robot comes out'. Human must be lying down and alive. Has to cooldown between each use."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "separator-AO1"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	var/transform_dead = 0
	var/transform_standing = 0
	var/cooldown_duration = 900 // 1.5 minutes
	var/cooldown_time = 0
	var/cooldown_state = 0 // Just for icons.
	var/robot_cell_charge = 5000
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 5000

	// /vg/
	var/force_borg_module=null

/obj/machinery/transformer/New()
	// On us
	..()
	new /obj/machinery/conveyor/auto(loc, WEST)

/obj/machinery/transformer/power_change()
	..()
	update_icon()

/obj/machinery/transformer/update_icon()
	..()
	if(stat & (BROKEN|NOPOWER) || cooldown_time > world.time)
		icon_state = "separator-AO0"
	else
		icon_state = initial(icon_state)

/obj/machinery/transformer/Bumped(var/atom/movable/AM)
	if(cooldown_state)
		return

	// Crossed didn't like people lying down.
	if(ishuman(AM))
		// Only humans can enter from the west side, while lying down.
		var/move_dir = get_dir(loc, AM.loc)
		var/mob/living/carbon/human/H = AM
		if((transform_standing || H.lying) && move_dir == EAST)// || move_dir == WEST)
			AM.loc = src.loc
			do_transform(AM)
	//Shit bugs out if theres too many items on the enter side conveyer
	else if(istype(AM, /obj/item))
		var/move_dir = get_dir(loc, AM.loc)
		if(move_dir == EAST)
			AM.loc = src.loc

/obj/machinery/transformer/proc/do_transform(var/mob/living/carbon/human/H)
	if(stat & (BROKEN|NOPOWER))
		return
	if(cooldown_state)
		return

	if(!transform_dead && H.stat == DEAD)
		playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
		return

	playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
	H.agony = 1
	H.emote("scream") // It is painful
	H.agony = 0
	H.adjustBruteLoss(max(0, 80 - H.getBruteLoss())) // Hurt the human, don't try to kill them though.
	H.handle_regular_hud_updates() // Make sure they see the pain.

	// Sleep for a couple of ticks to allow the human to see the pain
	sleep(5)

	var/mob/living/silicon/robot/R = H.Robotize(1) // Delete the items or they'll all pile up in a single tile and lag
	if(R)
		R.cell.maxcharge = robot_cell_charge
		R.cell.charge = robot_cell_charge

	 	// So he can't jump out the gate right away.
		R.weakened = 5

		// /vg/: Force borg module, if needed.
		R.pick_module(force_borg_module)
		R.updateicon()

	spawn(50)
		playsound(get_turf(src), 'sound/machines/ding.ogg', 50, 0)
		if(R)
			R.weakened = 0

	// Activate the cooldown
	cooldown_time = world.time + cooldown_duration
	cooldown_state = 1
	update_icon()

/obj/machinery/transformer/process()
	..()
	var/old_cooldown_state=cooldown_state
	cooldown_state = cooldown_time > world.time
	if(cooldown_state!=old_cooldown_state)
		update_icon()
		if(!cooldown_state)
			playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 0)

/obj/machinery/transformer/conveyor/New()
	..()
	var/turf/T = loc
	if(T)
		// Spawn Conveyour Belts

		//East
		var/turf/east = locate(T.x + 1, T.y, T.z)
		if(istype(east, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(east, WEST)

		// West
		var/turf/west = locate(T.x - 1, T.y, T.z)
		if(istype(west, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(west, WEST)

/obj/machinery/transformer/attack_ai(var/mob/user)
	interact(user)

/obj/machinery/transformer/interact(var/mob/user)
	var/data=""
	if(cooldown_state)
		data += {"<b>Recalibrating.</b> Time left: [(cooldown_time - world.time)/10] seconds."}
	else
		data += {"<p style="color:red;font-weight:bold;"><blink>ROBOTICIZER ACTIVE.</blink></p>"}
	data += {"
		<h2>Settings</h2>
		<ul>
			<li>
				<b>Next Borg's Module:</b>
				<a href="?src=\ref[src];act=force_class">[isnull(force_borg_module)?"Not Forced":force_borg_module]</a>
			</li>
		</ul>
	"}

	var/datum/browser/popup = new(user, "transformer", src.name, 400, 300)
	popup.set_content(data)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/transformer/Topic(href, href_list)
	if(!isAI(usr))
		usr << "\red This machine is way above your pay-grade."
		return 0
	if(!("act" in href_list))
		return 0
	switch(href_list["act"])
		if("force_class")
			var/list/modules = list("(Robot's Choice)")
			modules += getAvailableRobotModules()
			var/sel_mod = input("Please, select a module!", "Robot", null, null) in modules
			if(sel_mod == "(Robot's Choice)")
				force_borg_module = null
			else
				force_borg_module = sel_mod
	interact(usr)
	return 1