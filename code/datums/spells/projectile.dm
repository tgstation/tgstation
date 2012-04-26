/obj/effect/proc_holder/spell/targeted/projectile
	name = "Projectile"
	desc = "This spell summons projectiles which try to hit the targets."

	var/proj_icon = 'projectiles.dmi'
	var/proj_icon_state = "spell"
	var/proj_name = "a spell projectile"

	var/proj_trail = 0 //if it leaves a trail
	var/proj_trail_lifespan = 0 //deciseconds
	var/proj_trail_icon = 'wizard.dmi'
	var/proj_trail_icon_state = "trail"

	var/proj_type = "/obj/effect/proc_holder/spell/targeted" //IMPORTANT use only subtypes of this

	var/proj_lingering = 0 //if it lingers or disappears upon hitting an obstacle
	var/proj_homing = 1 //if it follows the target
	var/proj_insubstantial = 0 //if it can pass through dense objects or not
	var/proj_trigger_range = 0 //the range from target at which the projectile triggers cast(target)

	var/proj_lifespan = 15 //in deciseconds * proj_step_delay
	var/proj_step_delay = 1 //lower = faster

/obj/effect/proc_holder/spell/targeted/projectile/cast(list/targets, mob/user = usr)

	for(var/mob/target in targets)
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
			projectile.dir = get_dir(target,projectile)
			projectile.name = proj_name

			var/current_loc = usr.loc

			projectile.loc = current_loc

			for(var/i = 0,i < proj_lifespan,i++)
				if(!projectile)
					break

				if(proj_homing)
					if(proj_insubstantial)
						projectile.dir = get_dir(projectile,target)
						projectile.loc = get_step_to(projectile,target)
					else
						step_to(projectile,target)
				else
					if(proj_insubstantial)
						projectile.loc = get_step(projectile,dir)
					else
						step(projectile,dir)

				if(!proj_lingering && projectile.loc == current_loc) //if it didn't move since last time
					del(projectile)
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

				if(projectile.loc in range(target.loc,proj_trigger_range))
					projectile.perform(list(target))
					break

				current_loc = projectile.loc

				sleep(proj_step_delay)

			if(projectile)
				del(projectile)