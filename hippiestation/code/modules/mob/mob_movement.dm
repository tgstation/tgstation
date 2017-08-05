#define MAX_SW_LUMS 0.2

proc/Can_ShadowWalk(var/mob/mob)
	if(mob.shadow_walk)
		return 1
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(istype(H.dna.species, /datum/species/shadow/ling))
			return 1
	return 0

/client/proc/Process_ShadowWalk(direct)
	var/turf/target = get_step(mob, direct)
	var/turf/mobloc = get_turf(mob)

	if (istype(mob.pulling))
		var/doPull = 1
		if (mob.pulling.anchored)
			mob.stop_pulling()
			doPull = 0
		if (mob.pulling == mob.loc && mob.pulling.density)
			mob.stop_pulling()
			doPull = 0
		if (istype(mob.pulling, /mob/))
			var/mob/M = mob.pulling

			M.stop_pulling()
			if (M.buckled)
				mob.stop_pulling()
				doPull = 0
		if (doPull)
			var/turf/pullloc = get_turf(mob.pulling)

			if(mobloc.get_lumcount()==null || mobloc.get_lumcount() <= MAX_SW_LUMS || pullloc.get_lumcount()==null || pullloc.get_lumcount() <= MAX_SW_LUMS || target.get_lumcount()==null || target.get_lumcount() <= MAX_SW_LUMS)
				mob.pulling.dir = get_dir(mob.pulling, mob)
				mob.pulling.loc = mob.loc
				return 1

	if (target.get_lumcount() == null || target.get_lumcount() <= MAX_SW_LUMS)
		mob.loc = target
		mob.dir = direct
		return 1

	return 0
