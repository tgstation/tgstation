///////////////////////////////////////
//Contents: Ladders, Hatches, Stairs.//
///////////////////////////////////////

/obj/multiz
	icon = 'multiz.dmi'
	density = 0
	opacity = 0
	anchored = 1
	var/obj/multiz/target

	CanPass(obj/mover, turf/source, height, airflow)
		return airflow || !density

/obj/multiz/ladder
	icon_state = "ladderdown"
	name = "ladder"
	desc = "A Ladder.  You climb up and down it."

	var/top_icon_state = "ladderdown"
	var/bottom_icon_state = "ladderup"

	New()
		. = ..()
		spawn(1) //Allow map to load
			if(!target)
				var/list/adjacent_to_me = global_adjacent_z_levels["[z]"]
				target = locate() in locate(x,y,adjacent_to_me["down"])
				if (istype(target))
					icon_state = top_icon_state
				else
					target = locate() in locate(x,y,adjacent_to_me["up"])
					if (istype(target))
						icon_state = bottom_icon_state
					else
						del src
				if(target)
					target.icon_state = ( icon_state == top_icon_state ? bottom_icon_state : top_icon_state)
					target.target = src

	Del()
		spawn(1)
			if(target)
				del target
		return ..()

	attack_paw(var/mob/M)
		return attack_hand(M)

	attackby(var/W, var/mob/M)
		return attack_hand(M)

	attack_hand(var/mob/M)
		if(!target || !istype(target.loc, /turf))
			del src
		var/list/adjacent_to_me = global_adjacent_z_levels["[z]"]
		M.visible_message("\blue \The [M] climbs [target.z == adjacent_to_me["up"] ? "up" : "down"] \the [src]!", "You climb [target.z == adjacent_to_me["up"]  ? "up" : "down"] \the [src]!", "You hear some grunting, and clanging of a metal ladder being used.")
		M.Move(target.loc)


	hatch
		icon_state = "hatchdown"
		name = "hatch"
		desc = "A hatch. You climb down it, and it will automatically seal against pressure loss behind you."
		top_icon_state = "hatchdown"
		var/top_icon_state_open = "hatchdown-open"
		var/top_icon_state_close = "hatchdown-close"

		bottom_icon_state = "hatchup"

		var/image/green_overlay
		var/image/red_overlay

		var/active = 0

		New()
			. = ..()
			red_overlay = image(icon, "red-ladderlight")
			green_overlay = image(icon, "green-ladderlight")

		attack_hand(var/mob/M)

			if(!target || !istype(target.loc, /turf))
				del src

			if(active)
				M << "That [src] is being used."
				return // It is a tiny airlock, only one at a time.

			active = 1
			var/obj/multiz/ladder/hatch/top_hatch = target
			var/obj/multiz/ladder/hatch/bottom_hatch = src
			if(icon_state == top_icon_state)
				top_hatch = src
				bottom_hatch = target

			flick(top_icon_state_open, top_hatch)
			bottom_hatch.overlays += green_overlay

			spawn(7)
				if(!target || !istype(target.loc, /turf))
					del src
				if(M.z == z && get_dist(src,M) <= 1)
					var/list/adjacent_to_me = global_adjacent_z_levels["[z]"]
					M.visible_message("\blue \The [M] scurries [target.z == adjacent_to_me["up"] ? "up" : "down"] \the [src]!", "You scramble [target.z == adjacent_to_me["up"] ? "up" : "down"] \the [src]!", "You hear some grunting, and a hatch sealing.")
					M.Move(target.loc)
				flick(top_icon_state_close,top_hatch)
				bottom_hatch.overlays -= green_overlay
				bottom_hatch.overlays += red_overlay

				spawn(7)
					top_hatch.icon_state = top_icon_state
					bottom_hatch.overlays -= red_overlay
					active = 0

/obj/multiz/stairs
	name = "Stairs"
	desc = "Stairs.  You walk up and down them."
	icon_state = "ramptop"
	var/top_icon_state = "ramptop"
	var/bottom_icon_state = "rampbottom"

	active
		density = 1


		New()
			. = ..()
			spawn(1)
				if(!target)
					var/list/adjacent_to_me = global_adjacent_z_levels["[z]"]
					target = locate() in locate(x,y,adjacent_to_me["up"])
					if(istype(target))
						icon_state = bottom_icon_state
					else
						target = locate() in locate(x,y,adjacent_to_me["down"])
						if(istype(target))
							icon_state = top_icon_state
						else
							del src
					if(target)
						target.icon_state = ( icon_state == top_icon_state ? bottom_icon_state : top_icon_state)
						target.target = src
					var/obj/multiz/stairs/lead_in = locate() in get_step(src, reverse_direction(dir))
					if(lead_in)
						lead_in.icon_state = ( icon_state == top_icon_state ? bottom_icon_state : top_icon_state)


		Del()
			spawn(1)
				if(target)
					del target
			return ..()


	Bumped(var/atom/movable/M)
		if(target.z > z && istype(src, /obj/multiz/stairs/active) && !locate(/obj/multiz/stairs) in M.loc)
			return //If on bottom, only let them go up stairs if they've moved to the entry tile first.
		//If it's the top, they can fall down just fine.

		if(!target || !istype(target.loc, /turf))
			del src

		if(ismob(M) && M:client)
			M:client.moving = 1
		M.Move(target.loc)
		if (ismob(M) && M:client)
			M:client.moving = 0

	Click()
		if(!istype(usr,/mob/dead/observer))
			return ..()
		if(!target || !istype(target.loc, /turf))
			del src
		usr.client.moving = 1
		usr.Move(target.loc)
		usr.client.moving = 0