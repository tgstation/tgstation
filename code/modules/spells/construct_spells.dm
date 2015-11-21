//////////////////////////////Construct Spells/////////////////////////

proc/findNullRod(var/atom/target)
	if(istype(target,/obj/item/weapon/nullrod))
		var/turf/T = get_turf(target)
		T.turf_animation('icons/effects/96x96.dmi',"nullding",-32,-32,MOB_LAYER+1,'sound/piano/Ab7.ogg')
		return 1
	else if(target.contents)
		for(var/atom/A in target.contents)
			if(findNullRod(A))
				return 1
	return 0
