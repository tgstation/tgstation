
//NEEDS MAJOR CODE CLEANUP

/obj/effect/proc_holder/spell/dumbfire
	var/proj_type = /obj/item/projectile/magic/dumbfire //IMPORTANT use only subtypes of this


	var/update_projectile = FALSE //So you want to admin abuse magic bullets ? This is for you

	var/proj_icon = 'icons/obj/projectiles.dmi'
	var/proj_icon_state = "spell"
	var/proj_name = "a spell projectile"

	var/proj_trail = 0 //if it leaves a trail
	var/proj_trail_lifespan = 0 //deciseconds
	var/proj_trail_icon = 'icons/obj/wizard.dmi'
	var/proj_trail_icon_state = "trail"

	var/proj_insubstantial = 0 //if it can pass through dense objects or not
	var/proj_trigger_range = 1 //the range from target at which the projectile triggers cast(target)

	var/proj_lifespan = 100 //in deciseconds * proj_step_delay
	var/proj_step_delay = 1 //lower = faster
	var/list/ignore_factions = list() //Faction types that will be ignored

	var/check_antimagic = TRUE
	var/check_holy = FALSE

/obj/effect/proc_holder/spell/dumbfire/choose_targets(mob/user = usr)
	var/turf/T = get_turf(user)
	for(var/i = 1; i < range; i++)
		var/turf/new_turf = get_step(T, user.dir)
		if(new_turf.density)
			break
		T = new_turf
	perform(list(T),user = user)

/obj/effect/proc_holder/spell/dumbfire/cast(list/targets, mob/user = usr)
	playMagSound()
	for(var/turf/target in targets)
		launch_at(target, user)

/obj/effect/proc_holder/spell/dumbfire/proc/launch_at(turf/target, mob/user)
	var/obj/item/projectile/magic/dumbfire/projectile = new proj_type()
	
	if(update_projectile)
		//Generally these should already be set on the projectile, this is mostly here for varedited spells.
		projectile.icon = proj_icon
		projectile.icon_state = proj_icon_state
		projectile.name = proj_name
		if(proj_insubstantial)
			projectile.movement_type |= UNSTOPPABLE
		projectile.trigger_range = proj_trigger_range
		projectile.ignored_factions = ignore_factions
		projectile.range = proj_lifespan
		projectile.speed = proj_step_delay
		projectile.trail = proj_trail
		projectile.trail_lifespan = proj_trail_lifespan
		projectile.trail_icon = proj_trail_icon
		projectile.trail_icon_state = proj_trail_icon_state

	projectile.preparePixelProjectile(target,user)
	projectile.fire()

/obj/effect/proc_holder/spell/dumbfire/proc/proj_trail(obj/effect/proc_holder/spell/targeted/projectile)
	set waitfor = FALSE
	if(projectile)
		var/obj/effect/overlay/trail = new /obj/effect/overlay(projectile.loc)
		trail.icon = proj_trail_icon
		trail.icon_state = proj_trail_icon_state
		trail.density = FALSE
		QDEL_IN(trail, proj_trail_lifespan)


/obj/item/projectile/magic/dumbfire
	name = "dumbfire projectile"
	var/list/ignored_factions
	var/check_holy = FALSE
	var/check_antimagic = FALSE
	var/trigger_range = 1

	var/trail = FALSE //if it leaves a trail
	var/trail_lifespan = 0 //deciseconds
	var/trail_icon = 'icons/obj/wizard.dmi'
	var/trail_icon_state = "trail"

//todo unify this and magic/aoe under common path
/obj/item/projectile/magic/dumbfire/Range()
	if(trigger_range > 1)
		for(var/mob/living/L in range(trigger_range, get_turf(src)))
			if(can_hit_target(L, ignore_loc = TRUE))
				return Bump(L)
	. = ..()

/obj/item/projectile/magic/dumbfire/Moved(atom/OldLoc, Dir)
	. = ..()
	if(trail)
		create_trail()

/obj/item/projectile/magic/dumbfire/proc/create_trail()
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

/obj/item/projectile/magic/dumbfire/can_hit_target(atom/target, list/passthrough, direct_target = FALSE, ignore_loc = FALSE)
	. = ..()
	if(ismob(target) && !direct_target) //Unsure about the direct target, i guess it could always skip these.
		var/mob/M = target
		if(M.anti_magic_check(check_antimagic, check_holy))
			return FALSE
		if(ignored_factions && ignored_factions.len && faction_check(M.faction,ignored_factions))
			return FALSE