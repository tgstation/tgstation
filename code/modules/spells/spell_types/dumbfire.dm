
//NEEDS MAJOR CODE CLEANUP

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
	set waitfor = FALSE
	var/obj/effect/proc_holder/spell/targeted/projectile
	if(istext(proj_type))
		var/projectile_type = text2path(proj_type)
		projectile = new projectile_type(user)
	else if(istype(proj_type, /obj/effect/proc_holder/spell))
		projectile = new /obj/effect/proc_holder/spell/targeted/trigger(user)
		var/obj/effect/proc_holder/spell/targeted/trigger/T = projectile
		T.linked_spells += proj_type
	else
		projectile = new proj_type(user)
	projectile.icon = proj_icon
	projectile.icon_state = proj_icon_state
	projectile.setDir(get_dir(projectile, target))
	projectile.name = proj_name

	var/current_loc = user.loc

	projectile.forceMove(current_loc)

	for(var/i = 0,i < proj_lifespan,i++)
		if(!projectile)
			break

		if(proj_insubstantial)
			projectile.forceMove(get_step(projectile, projectile.dir))
		else
			step(projectile, projectile.dir)

		if(projectile.loc == current_loc || i == proj_lifespan)
			projectile.cast(current_loc,user=user)
			break

		var/mob/living/L = locate(/mob/living) in range(projectile, proj_trigger_range) - user
		if(L && L.stat != DEAD && L.anti_magic_check(check_antimagic, check_holy))
			if(!ignore_factions.len)
				projectile.cast(L.loc,user=user)
				break
			else
				var/faction_check = FALSE
				for(var/faction in L.faction)
					if(ignore_factions.Find(faction))
						faction_check = TRUE
						break
				if(!faction_check)
					projectile.cast(L.loc,user=user)
					break

		if(proj_trail && projectile)
			proj_trail(projectile)

		current_loc = projectile.loc
		var/matrix/M = new
		M.Turn(dir2angle(projectile.dir))
		projectile.transform = M

		sleep(proj_step_delay)

	if(projectile)
		qdel(projectile)

/obj/effect/proc_holder/spell/dumbfire/proc/proj_trail(obj/effect/proc_holder/spell/targeted/projectile)
	set waitfor = FALSE
	if(projectile)
		var/obj/effect/overlay/trail = new /obj/effect/overlay(projectile.loc)
		trail.icon = proj_trail_icon
		trail.icon_state = proj_trail_icon_state
		trail.density = FALSE
		QDEL_IN(trail, proj_trail_lifespan)
