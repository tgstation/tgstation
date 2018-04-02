/obj/effect/turf_decal/plaque/toolbox
	name = "plaque"
	icon = 'icons/oldschool/ss13sign1rowdecals.dmi'
	var/ismain = 0
/obj/effect/turf_decal/plaque/toolbox/New()
	. = ..()
	if(ismain)
		if(!isturf(loc))
			qdel(src)
			return
		var/startx = x-3
		for(var/i=1,i<=7,i++)
			var/turf/T = locate(startx,y,z)
			if(istype(T))
				var/obj/effect/turf_decal/plaque/toolbox/P = new(T)
				if(T == loc)
					P = src
				else
					P = new(T)
				P.icon_state = "S[i]"
			startx++
		ismain = 0