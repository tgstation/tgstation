#define MAX_SW_LUMS 0.2
#define ALLOW_PULL_THROUGH_WALLS 0

proc/Is_ShadowWalkable(var/turf/loc)
	return (loc.get_lumcount()==null || loc.get_lumcount() <= MAX_SW_LUMS)

proc/Can_ShadowWalk(var/mob/mob)
	if(mob.shadow_walk)
		return TRUE
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(istype(H.dna.species, /datum/species/shadow/ling))
			return TRUE
	return FALSE

/client/proc/Process_ShadowWalk(direct)
	var/turf/target = get_step(mob, direct)
	var/turf/mobloc = get_turf(mob)

	var/atom/movable/A
	var/doPull = FALSE
	if (istype(mob.pulling))
		doPull = TRUE
		if (mob.pulling.anchored)
			mob.stop_pulling()
			doPull = FALSE
		if(isliving(mob.pulling))
			var/mob/living/L = mob.pulling
			if(L.buckled && L.buckled.buckle_prevents_pull) //if they're buckled to something that disallows pulling, prevent it
				mob.stop_pulling()
				doPull = FALSE
		if((mobloc.density || target.density) && !ALLOW_PULL_THROUGH_WALLS) //this will disallow the target to be pulled if the shadowwalker is on or going into a solid tile.
			doPull = FALSE
			if(istype(mob.pulling, /mob/living))
				var/mob/living/M = mob.pulling
				M.Knockdown(60)
				to_chat(M, "<span class='danger'>You fall down as you slam against the surface!</span>")
		if (doPull)
			var/turf/pullloc = get_turf(mob.pulling)
			if(Is_ShadowWalkable(mobloc) || Is_ShadowWalkable(target) || Is_ShadowWalkable(pullloc))
				mob.pulling.dir = get_dir(mob.pulling, mob)
				A = mob.pulling
				mob.pulling.forceMove(mob.loc)

	if(Is_ShadowWalkable(target))
		mob.forceMove(target)
		mob.dir = direct
		if (doPull)
			mob.start_pulling(A, TRUE) //this was the only way I could figure out how to do this
		return TRUE

	return FALSE
