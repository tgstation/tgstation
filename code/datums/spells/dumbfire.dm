/obj/effect/proc_holder/spell/dumbfire

	var/projectile_type = ""
	var/activate_on_collision = 1

	var/proj_icon = 'icons/obj/projectiles.dmi'
	var/proj_icon_state = "spell"
	var/proj_name = "a spell projectile"

	var/proj_trail = 0 //if it leaves a trail
	var/proj_trail_lifespan = 0 //deciseconds
	var/proj_trail_icon = 'icons/obj/wizard.dmi'
	var/proj_trail_icon_state = "trail"

	var/proj_type = "/obj/effect/proc_holder/spell" //IMPORTANT use only subtypes of this

	var/proj_insubstantial = 0 //if it can pass through dense objects or not
	var/proj_trigger_range = 1 //the range from target at which the projectile triggers cast(target)

	var/proj_lifespan = 100 //in deciseconds * proj_step_delay
	var/proj_step_delay = 1 //lower = faster

/obj/effect/proc_holder/spell/dumbfire/choose_targets(mob/user = usr)

	var/turf/T = get_turf(usr)
	for(var/i = 1; i < range; i++)
		var/turf/new_turf = get_step(T, usr.dir)
		if(new_turf.density)
			break
		T = new_turf
	perform(list(T))

/obj/effect/proc_holder/spell/dumbfire/cast(list/targets, mob/user = usr)

	for(var/turf/target in targets)
		spawn(0)
			var/obj/effect/proc_holder/spell/targeted/projectile
			if(istext(proj_type))
				var/projectile_type = text2path(proj_type)
				projectile = new projectile_type(user)
			if(istype(proj_type,/obj/effect/proc_holder/spell))
				projectile = new /obj/effect/proc_holder/spell/targeted/trigger(user)
				projectile:linked_spells += proj_type
			projectile.icon = proj_icon
			projectile.icon_state = proj_icon_state
			projectile.dir = get_dir(projectile, target)
			projectile.name = proj_name

			var/current_loc = usr.loc

			projectile.loc = current_loc

			for(var/i = 0,i < proj_lifespan,i++)
				if(!projectile)
					break

				if(proj_insubstantial)
					projectile.loc = get_step(projectile, projectile.dir)
				else
					step(projectile, projectile.dir)

				if(projectile.loc == current_loc || i == proj_lifespan)
					projectile.cast(current_loc)
					break

				var/mob/living/L = locate(/mob/living) in range(projectile, proj_trigger_range) - usr
				if(L)
					projectile.cast(L.loc)
					break

				if(proj_trail && projectile)
					spawn(0)
						if(projectile)
							var/obj/effect/overlay/trail = new /obj/effect/overlay(projectile.loc)
							trail.icon = proj_trail_icon
							trail.icon_state = proj_trail_icon_state
							trail.density = 0
							spawn(proj_trail_lifespan)
								del(trail)

				current_loc = projectile.loc

				sleep(proj_step_delay)

			if(projectile)
				del(projectile)