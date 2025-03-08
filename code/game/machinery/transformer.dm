/obj/machinery/transformer
	name = "\improper Automatic Robotic Factory 5000"
	desc = "A large metallic machine with an entrance and an exit. A sign on \
		the side reads, 'human go in, robot come out'. The human must be \
		lying down and alive. Has a cooldown between each use."
	icon = 'icons/obj/machines/recycling.dmi'
	icon_state = "separator-AO1"
	layer = ABOVE_ALL_MOB_LAYER // Overhead
	plane = ABOVE_GAME_PLANE
	density = FALSE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 5
	/// Whether this machine transforms dead mobs into cyborgs
	var/transform_dead = FALSE
	/// Whether this machine transforms standing mobs into cyborgs
	var/transform_standing = FALSE
	/// How long we have to wait between processing mobs
	var/cooldown_duration = 60 SECONDS
	/// Whether we're on cooldown
	var/cooldown = FALSE
	/// How long until the next mob can be processed
	var/cooldown_timer
	/// The created cyborg's cell chage
	var/robot_cell_charge = STANDARD_CELL_CHARGE * 5
	/// The visual countdown effect
	var/obj/effect/countdown/transformer/countdown
	/// Who the master AI is that created this factory
	var/mob/living/silicon/ai/master_ai

/obj/machinery/transformer/Initialize(mapload)
	. = ..()
	new /obj/machinery/conveyor/auto(locate(x - 1, y, z), WEST)
	new /obj/machinery/conveyor/auto(loc, WEST)
	new /obj/machinery/conveyor/auto(locate(x + 1, y, z), WEST)
	countdown = new(src)
	countdown.start()

/obj/machinery/transformer/examine(mob/user)
	. = ..()
	if(cooldown && (issilicon(user) || isobserver(user)))
		. += "It will be ready in [DisplayTimeText(cooldown_timer - world.time)]."

/obj/machinery/transformer/Destroy()
	QDEL_NULL(countdown)
	. = ..()

/obj/machinery/transformer/update_icon_state()
	if(machine_stat & (BROKEN|NOPOWER) || cooldown == 1)
		icon_state = "separator-AO0"
	else
		icon_state = initial(icon_state)
	return ..()

/obj/machinery/transformer/Bumped(atom/movable/entering_thing)
	if(cooldown)
		return

	// Crossed didn't like people lying down.
	if(ishuman(entering_thing))
		// Only humans can enter from the west side, while lying down.
		var/move_dir = get_dir(loc, entering_thing.loc)
		var/mob/living/carbon/human/victim = entering_thing
		if((transform_standing || victim.body_position == LYING_DOWN) && move_dir == EAST)
			entering_thing.forceMove(drop_location())
			do_transform(entering_thing)

/obj/machinery/transformer/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	// Allows items to go through to stop them from blocking the conveyor belt.
	if(!ishuman(mover))
		if(get_dir(src, mover) == EAST)
			return
	return FALSE

/obj/machinery/transformer/process()
	if(cooldown && (cooldown_timer <= world.time))
		cooldown = FALSE
		update_appearance()

/obj/machinery/transformer/proc/do_transform(mob/living/carbon/human/victim)
	if(machine_stat & (BROKEN|NOPOWER))
		return

	if(cooldown)
		return

	if(!transform_dead && victim.stat == DEAD)
		playsound(src.loc, 'sound/machines/buzz/buzz-sigh.ogg', 50, FALSE)
		return

	// Activate the cooldown
	cooldown = TRUE
	cooldown_timer = world.time + cooldown_duration
	update_appearance()

	playsound(src.loc, 'sound/items/tools/welder.ogg', 50, TRUE)
	victim.painful_scream() // DOPPLER EDIT: check for painkilling before screaming // It is painful
	victim.adjustBruteLoss(max(0, 80 - victim.getBruteLoss())) // Hurt the human, don't try to kill them though.

	// Sleep for a couple of ticks to allow the human to see the pain
	sleep(0.5 SECONDS)

	use_energy(active_power_usage) // Use a lot of power.
	var/mob/living/silicon/robot/new_borg = victim.Robotize()
	new_borg.cell = new /obj/item/stock_parts/power_store/cell/upgraded/plus(new_borg, robot_cell_charge)

	// So he can't jump out the gate right away.
	new_borg.SetLockdown()
	if(master_ai && new_borg.connected_ai != master_ai)
		new_borg.set_connected_ai(master_ai)
		new_borg.lawsync()
		new_borg.lawupdate = TRUE
		log_silicon("[key_name(new_borg)] resynced to [key_name(master_ai)]")
	addtimer(CALLBACK(src, PROC_REF(unlock_new_robot), new_borg), 5 SECONDS)

/obj/machinery/transformer/proc/unlock_new_robot(mob/living/silicon/robot/new_borg)
	playsound(src.loc, 'sound/machines/ping.ogg', 50, FALSE)
	sleep(3 SECONDS)
	if(new_borg)
		new_borg.SetLockdown(FALSE)
		new_borg.notify_ai(AI_NOTIFICATION_NEW_BORG)
