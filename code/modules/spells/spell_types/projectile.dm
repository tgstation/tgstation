
//NEEDS MAJOR CODE CLEANUP.

/obj/effect/proc_holder/spell/targeted/projectile
	name = "Projectile"
	desc = "This spell summons projectiles which try to hit the targets."

	var/proj_icon = 'icons/obj/projectiles.dmi'
	var/proj_icon_state = "spell"
	var/proj_name = "a spell projectile"

	var/proj_trail = 0 //if it leaves a trail
	var/proj_trail_lifespan = 0 //deciseconds
	var/proj_trail_icon = 'icons/obj/wizard.dmi'
	var/proj_trail_icon_state = "trail"


	var/proj_type = "/obj/effect/proc_holder/spell/targeted" //IMPORTANT use only subtypes of this

	var/proj_lingering = 0 //if it lingers or disappears upon hitting an obstacle
	var/proj_homing = 1 //if it follows the target
	var/proj_insubstantial = 0 //if it can pass through dense objects or not
	var/proj_trigger_range = 0 //the range from target at which the projectile triggers cast(target)

	var/proj_lifespan = 15 //in deciseconds * proj_step_delay
	var/proj_step_delay = 1 //lower = faster

/obj/effect/proc_holder/spell/targeted/projectile/cast(list/targets, mob/user = usr)
	playMagSound()
	for(var/mob/living/target in targets)
		launch(target, user)

/obj/effect/proc_holder/spell/targeted/projectile/proc/launch(mob/living/target, mob/user)
	set waitfor = FALSE
	var/obj/effect/proc_holder/spell/targeted/projectile
	if(istext(proj_type))
		var/projectile_type = text2path(proj_type)
		projectile = new projectile_type(user)
	if(istype(proj_type,/obj/effect/proc_holder/spell))
		projectile = new /obj/effect/proc_holder/spell/targeted/trigger(user)
		var/obj/effect/proc_holder/spell/targeted/trigger/T = projectile
		T.linked_spells += proj_type
	projectile.icon = proj_icon
	projectile.icon_state = proj_icon_state
	projectile.setDir(get_dir(target,projectile))
	projectile.name = proj_name

	var/current_loc = user.loc

	projectile.loc = current_loc

	for(var/i = 0,i < proj_lifespan,i++)
		if(!projectile)
			break

		if(proj_homing)
			if(proj_insubstantial)
				projectile.setDir(get_dir(projectile,target))
				projectile.loc = get_step_to(projectile,target)
			else
				step_to(projectile,target)
		else
			if(proj_insubstantial)
				projectile.loc = get_step(projectile,dir)
			else
				step(projectile,dir)

		if(!projectile) // step and step_to sleeps so we'll have to check again.
			break

		if(!target || (!proj_lingering && projectile.loc == current_loc)) //if it didn't move since last time
			qdel(projectile)
			break

		if(proj_trail && projectile)
			spawntrail(projectile)

		if(projectile.loc in range(target.loc,proj_trigger_range))
			projectile.perform(list(target),user=user)
			break

		current_loc = projectile.loc

		sleep(proj_step_delay)

	if(projectile)
		qdel(projectile)

/obj/effect/proc_holder/spell/targeted/projectile/proc/spawntrail(obj/effect/proc_holder/spell/targeted/projectile)
	set waitfor = FALSE
	if(projectile)
		var/obj/effect/overlay/trail = new /obj/effect/overlay(projectile.loc)
		trail.icon = proj_trail_icon
		trail.icon_state = proj_trail_icon_state
		trail.density = FALSE
		QDEL_IN(trail, proj_trail_lifespan)
