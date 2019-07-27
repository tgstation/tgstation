<<<<<<< HEAD


/obj/item/projectile/magic/spell
	name = "custom spell projectile"
	var/list/ignored_factions //Do not hit these
	var/check_holy = FALSE
	var/check_antimagic = FALSE
	var/trigger_range = 0 //How far we do we need to be to hit
	var/linger = FALSE //Can't hit anything but the intended target

	var/trail = FALSE //if it leaves a trail
	var/trail_lifespan = 0 //deciseconds
	var/trail_icon = 'icons/obj/wizard.dmi'
	var/trail_icon_state = "trail"

//todo unify this and magic/aoe under common path
/obj/item/projectile/magic/spell/Range()
	if(trigger_range > 1)
		for(var/mob/living/L in range(trigger_range, get_turf(src)))
			if(can_hit_target(L, ignore_loc = TRUE))
				return Bump(L)
	. = ..()

/obj/item/projectile/magic/spell/Moved(atom/OldLoc, Dir)
	. = ..()
	if(trail)
		create_trail()

/obj/item/projectile/magic/spell/proc/create_trail()
	if(!trajectory)
		return
	var/datum/point/vector/previous = trajectory.return_vector_after_increments(1,-1)
	var/obj/effect/overlay/trail = new /obj/effect/overlay(previous.return_turf())
	trail.pixel_x = previous.return_px()
	trail.pixel_y = previous.return_py()
	trail.icon = trail_icon
	trail.icon_state = trail_icon_state
	//might be changed to temp overlay
	trail.density = FALSE
	trail.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	QDEL_IN(trail, trail_lifespan)

/obj/item/projectile/magic/spell/can_hit_target(atom/target, list/passthrough, direct_target = FALSE, ignore_loc = FALSE)
	. = ..()
	if(linger && target != original)
		return FALSE
	if(ismob(target) && !direct_target) //Unsure about the direct target, i guess it could always skip these.
		var/mob/M = target
		if(M.anti_magic_check(check_antimagic, check_holy))
			return FALSE
		if(ignored_factions && ignored_factions.len && faction_check(M.faction,ignored_factions))
			return FALSE


//NEEDS MAJOR CODE CLEANUP.

/obj/effect/proc_holder/spell/targeted/projectile
	name = "Projectile"
	desc = "This spell summons projectiles which try to hit the targets."

	

	var/proj_type =  /obj/item/projectile/magic/spell //IMPORTANT use only subtypes of this
	
	
	var/update_projectile = FALSE //So you want to admin abuse magic bullets ? This is for you
	//Below only apply if update_projectile is true
	var/proj_icon = 'icons/obj/projectiles.dmi'
	var/proj_icon_state = "spell"
	var/proj_name = "a spell projectile"
	var/proj_trail = FALSE //if it leaves a trail
	var/proj_trail_lifespan = 0 //deciseconds
	var/proj_trail_icon = 'icons/obj/wizard.dmi'
	var/proj_trail_icon_state = "trail"
	var/proj_lingering = FALSE //if it lingers or disappears upon hitting an obstacle
	var/proj_homing = TRUE //if it follows the target
	var/proj_insubstantial = FALSE //if it can pass through dense objects or not
	var/proj_trigger_range = 0 //the range from target at which the projectile triggers cast(target)
	var/proj_lifespan = 15 //in deciseconds * proj_step_delay
	var/proj_step_delay = 1 //lower = faster
	var/list/ignore_factions = list() //Faction types that will be ignored
	var/check_antimagic = TRUE
	var/check_holy = FALSE

/obj/effect/proc_holder/spell/targeted/projectile/proc/fire_projectile(atom/target, mob/user)
	var/obj/item/projectile/magic/spell/projectile = new proj_type()
	
	if(update_projectile)
		//Generally these should already be set on the projectile, this is mostly here for varedited spells.
		projectile.icon = proj_icon
		projectile.icon_state = proj_icon_state
		projectile.name = proj_name
		if(proj_insubstantial)
			projectile.movement_type |= UNSTOPPABLE
		if(proj_homing)
			projectile.homing = TRUE
			projectile.homing_turn_speed = 360 //Perfect tracking
		if(proj_lingering)
			projectile.linger = TRUE
		projectile.trigger_range = proj_trigger_range
		projectile.ignored_factions = ignore_factions
		projectile.range = proj_lifespan
		projectile.speed = proj_step_delay
		projectile.trail = proj_trail
		projectile.trail_lifespan = proj_trail_lifespan
		projectile.trail_icon = proj_trail_icon
		projectile.trail_icon_state = proj_trail_icon_state

	projectile.preparePixelProjectile(target,user)
	if(projectile.homing)
		projectile.set_homing_target(target)
	projectile.fire()

/obj/effect/proc_holder/spell/targeted/projectile/cast(list/targets, mob/user = usr)
	playMagSound()
	for(var/atom/target in targets)
		fire_projectile(target, user)

//This one just pops one projectile in direction user is facing, irrelevant of max_targets etc
/obj/effect/proc_holder/spell/targeted/projectile/dumbfire
	name = "Dumbfire projectile"

/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/choose_targets(mob/user = usr)
	var/turf/T = get_turf(user)
	for(var/i = 1; i < range; i++)
		var/turf/new_turf = get_step(T, user.dir)
		if(new_turf.density)
			break
		T = new_turf
	perform(list(T),user = user)
=======

//NEEDS MAJOR CODE CLEANUP.

/obj/effect/proc_holder/spell/targeted/projectile
	name = "Projectile"
	desc = "This spell summons projectiles which try to hit the targets."

	var/proj_icon = 'icons/obj/projectiles.dmi'
	var/proj_icon_state = "spell"
	var/proj_name = "a spell projectile"

	var/proj_trail = FALSE //if it leaves a trail
	var/proj_trail_lifespan = 0 //deciseconds
	var/proj_trail_icon = 'icons/obj/wizard.dmi'
	var/proj_trail_icon_state = "trail"


	var/proj_type = "/obj/effect/proc_holder/spell/targeted" //IMPORTANT use only subtypes of this

	var/proj_lingering = FALSE //if it lingers or disappears upon hitting an obstacle
	var/proj_homing = TRUE //if it follows the target
	var/proj_insubstantial = FALSE //if it can pass through dense objects or not
	var/proj_trigger_range = FALSE //the range from target at which the projectile triggers cast(target)

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
	if(istype(proj_type, /obj/effect/proc_holder/spell))
		projectile = new /obj/effect/proc_holder/spell/targeted/trigger(user)
		var/obj/effect/proc_holder/spell/targeted/trigger/T = projectile
		T.linked_spells += proj_type
	projectile.icon = proj_icon
	projectile.icon_state = proj_icon_state
	projectile.setDir(get_dir(target,projectile))
	projectile.name = proj_name

	var/current_loc = user.loc

	projectile.forceMove(current_loc)

	for(var/i = 0,i < proj_lifespan,i++)
		if(!projectile)
			break

		if(proj_homing)
			if(proj_insubstantial)
				projectile.setDir(get_dir(projectile,target))
				projectile.forceMove(get_step_to(projectile,target))
			else
				step_to(projectile,target)
		else
			if(proj_insubstantial)
				projectile.forceMove(get_step(projectile,dir))
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
>>>>>>> Updated this old code to fork
