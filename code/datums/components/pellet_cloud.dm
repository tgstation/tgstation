/*
	This component is used when you want to create a bunch of shrapnel or projectiles (say, shrapnel from a fragmentation grenade, or buckshot from a shotgun) from a central point,
	without necessarily printing a separate message for every single impact. This component should be instantiated right when you need it (like the moment of firing), then activated
	by signal.

	Pellet cloud currently works on two types of items: ammo casings, and grenades.
		-Ammo casings: This means you're shooting multiple pellets, like buckshot. If an ammo casing is defined as having multiple pellets, it will automatically create a pellet cloud
			and call COMSIG_PELLET_CLOUD_INIT (see [/obj/item/ammo_casing/proc/fire_casing]), then delete its normal BB. Thus, the only projectiles fired will be the ones fired here.
			The magnitude var controls how many pellets are created.
		-Grenades: This results in a big spray of shrapnel flying all around the detonation point when the grenade fires COMSIG_GRENADE_PRIME. The magnitude var controls how big the detonation
			radius is (the bigger the magnitude, the more shrapnel is created).

	Once all of the fired projectiles either hit a target or disappear due to reaching their maximum range,
*/

/datum/component/pellet_cloud
	var/projectile_type
	var/proj_name
	var/num_pellets
	var/list/pellets = list()
	var/list/targets_hit = list()
	var/terminated
	var/hits
	var/radius = 4
	var/not_done_yet
	var/list/bodies
	var/list/purple_hearts
	var/mob/living/shooter /// for if we're an ammo casing being fired

/datum/component/pellet_cloud/Initialize(projectile_type, magnitude=5)
	if(!isammocasing(parent) && !isgrenade(parent) && !islandmine(parent))
		return COMPONENT_INCOMPATIBLE

	src.projectile_type = projectile_type

	if(isammocasing(parent))
		num_pellets = magnitude
	else if(isgrenade(parent) || islandmine(parent))
		radius = magnitude
		not_done_yet = TRUE

	var/obj/projectile/p = projectile_type
	proj_name = initial(p.name)

/datum/component/pellet_cloud/Destroy(force, silent)
	if(not_done_yet) // Grenade clouds need to hang around for a bit after the grenade is gone so we know what happened to the pellets.
		return QDEL_HINT_LETMELIVE
	return ..()

/datum/component/pellet_cloud/RegisterWithParent()
	if(isammocasing(parent))
		RegisterSignal(parent, COMSIG_PELLET_CLOUD_INIT, .proc/create_pellets)
	else if(isgrenade(parent))
		RegisterSignal(parent, COMSIG_GRENADE_ARMED, .proc/grenade_armed)
		RegisterSignal(parent, COMSIG_GRENADE_PRIME, .proc/circle_pellets)
	else if(islandmine(parent))
		RegisterSignal(parent, COMSIG_MINE_TRIGGERED, .proc/circle_pellets)

/datum/component/pellet_cloud/UnregisterFromParent()
	if(not_done_yet)
		return QDEL_HINT_LETMELIVE
	UnregisterSignal(parent, list(COMSIG_PELLET_CLOUD_INIT, COMSIG_GRENADE_PRIME, COMSIG_GRENADE_ARMED, COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_UNCROSSED, COMSIG_MINE_TRIGGERED, COMSIG_ITEM_DROPPED))

///Creating pellets for an ammo casing we just fired
/datum/component/pellet_cloud/proc/create_pellets(obj/item/ammo_casing/A, atom/target, mob/living/user, fired_from, randomspread, spread, zone_override, params, distro)
	shooter = user

	if(!zone_override)
		zone_override = shooter.zone_selected
	var/targloc = get_turf(target)

	for(var/i in 1 to num_pellets)
		A.ready_proj(target, user, SUPPRESSED_VERY, zone_override, fired_from)
		if(distro)
			if(randomspread)
				spread = round((rand() - 0.5) * distro)
			else //Smart spread
				spread = round((i / num_pellets - 0.5) * distro)

		RegisterSignal(A.BB, COMSIG_PROJECTILE_SELF_ON_HIT, .proc/pellet_hit)
		RegisterSignal(A.BB, COMSIG_PROJECTILE_RANGE_OUT, .proc/pellet_range)
		pellets += A.BB
		if(!A.throw_proj(target, targloc, shooter, params, spread))
			return 0
		if(i != num_pellets)
			A.newshot()

		//pew_gun(target, spread, zone_override)

///Creating pellets for a grenade
/datum/component/pellet_cloud/proc/circle_pellets()
	if(radius < 1)
		not_done_yet = FALSE
		QDEL_NULL(src)
		return

	var/atom/target = parent
	var/total_pellets_absorbed = 0

	if(isgrenade(parent)) // handle_martyrs can reduce the radius and thus the number of pellets we produce if someone dives on top of a frag grenade
		total_pellets_absorbed = handle_martyrs()

	if(radius < 1)
		return

	var/list/all_the_turfs_were_gonna_lacerate = RANGE_TURFS(radius, target) - RANGE_TURFS(radius-1, target)
	num_pellets = all_the_turfs_were_gonna_lacerate.len + total_pellets_absorbed
	testing("Total pellets: [num_pellets] ([total_pellets_absorbed] absorbed, [all_the_turfs_were_gonna_lacerate.len] free")

	for(var/T in all_the_turfs_were_gonna_lacerate)
		var/turf/shootat_turf = T
		pew(shootat_turf)

/datum/component/pellet_cloud/proc/handle_martyrs()
	var/list/martyrs = list()
	for(var/mob/living/L in get_turf(parent))
		if(!(L in bodies))
			martyrs += L

	var/magnitude_absorbed
	var/total_pellets_absorbed = 0

	for(var/M in martyrs)
		var/mob/living/L = M
		if(radius > 4)
			L.visible_message("<b><span class='danger'>[L] heroically covers \the [parent] with [L.p_their()] body, absorbing a load of the shrapnel!</span></b>", "<span class='userdanger'>You heroically cover \the [parent] with your body, absorbing a load of the shrapnel!</span>")
			magnitude_absorbed += round(radius * 0.5)
		else if(radius >= 2)
			L.visible_message("<b><span class='danger'>[L] heroically covers \the [parent] with [L.p_their()] body, absorbing some of the shrapnel!</span></b>", "<span class='userdanger'>You heroically cover \the [parent] with your body, absorbing some of the shrapnel!</span>")
			magnitude_absorbed += 2
		else
			L.visible_message("<b><span class='danger'>[L] heroically covers \the [parent] with [L.p_their()] body, snuffing out the shrapnel!</span></b>", "<span class='userdanger'>You heroically cover \the [parent] with your body, snuffing out the shrapnel!</span>")
			magnitude_absorbed = radius

		var/pellets_absorbed
		pellets_absorbed = (radius ** 2) - ((radius - magnitude_absorbed - 1) ** 2)
		testing("Absorbed [pellets_absorbed] (Radius [radius] -> [radius - magnitude_absorbed])")
		radius -= magnitude_absorbed
		total_pellets_absorbed += round(pellets_absorbed/2)

		for(var/i in 1 to round(pellets_absorbed/2))
			pew(L)

		if(L.stat != DEAD && L.client)
			LAZYADD(purple_hearts, L)

		if(radius < 1)
			break

	return total_pellets_absorbed

///One of our pellets hit something, record what it was and check if we're done (terminated == num_pellets)
/datum/component/pellet_cloud/proc/pellet_hit(obj/projectile/P, atom/movable/firer, atom/target, Angle)
	pellets -= P
	terminated++
	hits++
	targets_hit[target]++
	if(terminated == num_pellets)
		finalize()

///One of our pellets disappeared due to hitting their max range, remove it from our list and check if we're done (terminated == num_pellets)
/datum/component/pellet_cloud/proc/pellet_range(obj/projectile/P)
	pellets -= P
	terminated++
	if(terminated == num_pellets)
		finalize()

/datum/component/pellet_cloud/proc/pew_gun(atom/target, mob/living/user, spread, zone)
	return
/*
	var/obj/item/ammo_casing/A = parent
	var/obj/projectile/P = new projectile_type(get_turf(parent))
	P.def_zone = zone

	if(A.reagents && P.reagents)
		A.reagents.trans_to(P, A.reagents.total_volume, transfered_by = shooter) //For chemical darts/bullets
		qdel(A.reagents)
	//Shooting Code:
	P.spread = spread
	P.original = target
	P.fired_from = A.fired_from
	P.firer = shooter // don't hit ourself that would be really annoying
	P.suppressed = SUPPRESSED_VERY // set the projectiles to make no message so we can do our own aggregate message
	P.preparePixelProjectile(target, parent, , spread)

	var/firing_dir
	if(A.firer)
		firing_dir = A.firer.dir
	if(!A.suppressed && A.firing_effect_type)
		new firing_effect_type(get_turf(src), firing_dir)

	RegisterSignal(P, COMSIG_PROJECTILE_SELF_ON_HIT, .proc/pellet_hit)
	RegisterSignal(P, COMSIG_PROJECTILE_RANGE_OUT, .proc/pellet_range)
	pellets += P
	P.fire()
*/
/datum/component/pellet_cloud/proc/pew(atom/target, spread=0)
	var/obj/projectile/P = new projectile_type(get_turf(parent))

	//Shooting Code:
	P.spread = spread
	P.original = target
	P.fired_from = parent
	P.firer = parent // don't hit ourself that would be really annoying
	P.permutated += parent // don't hit the target we hit already with the flak
	P.suppressed = SUPPRESSED_VERY // set the projectiles to make no message so we can do our own aggregate message
	P.preparePixelProjectile(target, parent)
	RegisterSignal(P, COMSIG_PROJECTILE_SELF_ON_HIT, .proc/pellet_hit)
	RegisterSignal(P, COMSIG_PROJECTILE_RANGE_OUT, .proc/pellet_range)
	pellets += P
	P.fire()

///All of our pellets are accounted for, time to go target by target and tell them how many things they got hit by.
/datum/component/pellet_cloud/proc/finalize()
	for(var/atom/target in targets_hit)
		var/num_hits = targets_hit[target]
		if(num_hits > 1)
			target.visible_message("<span class='danger'>[target] is hit by [num_hits] [proj_name]s!</span>", null, null, COMBAT_MESSAGE_RANGE, target)
			to_chat(target, "<span class='userdanger'>You're hit by [num_hits] [proj_name]s!</span>")
		else
			target.visible_message("<span class='danger'>[target] is hit by a [proj_name]!</span>", null, null, COMBAT_MESSAGE_RANGE, target)
			to_chat(target, "<span class='userdanger'>You're hit by [num_hits] [proj_name]s!</span>")

	if(purple_hearts)
		for(var/M in purple_hearts)
			var/mob/living/L = M
			if(L.stat == DEAD && L.client)
				//L.client.give_award(/datum/award/achievement/misc/lookoutsir, L)
				testing("Award!")

	not_done_yet = FALSE
	qdel(src)

///All of our pellets are accounted for, time to go target by target and tell them how many things they got hit by.
/datum/component/pellet_cloud/proc/grenade_armed()
	LAZYINITLIST(bodies)
	RegisterSignal(parent, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED), .proc/grenade_moved)
	RegisterSignal(parent, COMSIG_MOVABLE_UNCROSSED, .proc/grenade_uncrossed)

///All of our pellets are accounted for, time to go target by target and tell them how many things they got hit by.
/datum/component/pellet_cloud/proc/grenade_moved()
	LAZYCLEARLIST(bodies)
	for(var/mob/living/L in get_turf(parent))
		testing("[L] is in bodies")
		bodies += L

///All of our pellets are accounted for, time to go target by target and tell them how many things they got hit by.
/datum/component/pellet_cloud/proc/grenade_uncrossed(atom/movable/AM)
	if(AM in bodies)
		testing("[AM] is out of bodies now")
	bodies -= AM

