SUBSYSTEM_DEF(input)
	name = "Input"
	wait = 1 //SS_TICKER means this runs every tick
	init_order = INIT_ORDER_INPUT
	flags = SS_TICKER
	priority = FIRE_PRIORITY_INPUT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	var/list/macro_set

/datum/controller/subsystem/input/Initialize()
	setup_default_macro_sets()

	initialized = TRUE

	refresh_client_macro_sets()

	return ..()

// This is for when macro sets are eventualy datumized
/datum/controller/subsystem/input/proc/setup_default_macro_sets()
	macro_set = list(
	"Any" = "\"KeyDown \[\[*\]\]\"",
	"Any+UP" = "\"KeyUp \[\[*\]\]\"",
	"Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"",
	"Tab" = "\".winset \\\"input.focus=true?map.focus=true input.background-color=[COLOR_INPUT_DISABLED]:input.focus=true input.background-color=[COLOR_INPUT_ENABLED]\\\"\"",
	"Escape" = "Reset-Held-Keys",
	)

// Badmins just wanna have fun ♪
/datum/controller/subsystem/input/proc/refresh_client_macro_sets()
	var/list/clients = GLOB.clients
	for(var/i in 1 to clients.len)
		var/client/user = clients[i]
		user.set_macros()

/datum/controller/subsystem/input/fire()
	for(var/mob/user as anything in GLOB.keyloop_list)
		if(user.focus)
			var/movement_dir = NONE
			for(var/_key in user.client?.keys_held)
				movement_dir = movement_dir | user.client.movement_keys[_key]
			if(user.client?.next_move_dir_add)
				movement_dir |= user.client.next_move_dir_add
			if(user.client?.next_move_dir_sub)
				movement_dir &= ~user.client.next_move_dir_sub
			// Sanity checks in case you hold left and right and up to make sure you only go up
			if((movement_dir & NORTH) && (movement_dir & SOUTH))
				movement_dir &= ~(NORTH|SOUTH)
			if((movement_dir & EAST) && (movement_dir & WEST))
				movement_dir &= ~(EAST|WEST)

			if(user.client && movement_dir) //If we're not moving, don't compensate, as byond will auto-fill dir otherwise
				movement_dir = turn(movement_dir, -dir2angle(user.client.dir)) //By doing this we ensure that our input direction is offset by the client (camera) direction

			if(user.client?.movement_locked && user.focus)
				if(isliving(user.focus))
					var/mob/living/living_focus = user.focus
					if(stat > SOFT_CRIT)
						continue
					living_focus.SetDir(movement_dir)
				else if(istype(user.focus, /mob/camera/imaginary_friend))
					var/mob/camera/imaginary_friend/dave = user.focus
					dave.SetDir(movement_dir)
					dave.Show()
				else
					user.focus?.keybind_face_direction(movement_dir)
			else
				user.client?.Move(get_step(src, movement_dir), movement_dir)
