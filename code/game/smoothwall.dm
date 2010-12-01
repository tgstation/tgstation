//Separate dm because it relates to two types of atoms + ease of removal in case it's needed.
//Also assemblies.dm for falsewall checking for this when used.

/atom/proc/relativewall() //atom because it should be useable both for walls and false walls

	var/junction = 0 //will be used to determine from which side the wall is connected to other walls

	for(var/turf/simulated/wall/W in orange(src,1))
		if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
			junction |= get_dir(src,W)

	for(var/obj/falsewall/W in orange(src,1))
		if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
			junction |= get_dir(src,W)

	if(istype(src,/turf/simulated/wall/r_wall) || istype(src,/obj/falserwall))
		src.icon_state = "rwall[junction]"
	else if(istype(src,/turf/simulated/wall) || istype(src,/obj/falsewall) || istype(src,/obj/falserwall))
		src.icon_state = "wall[junction]"

/* When we have animations for different directions of falsewalls, then it'd be needed. Not now.
	if(istype(src,/obj/falsewall)) //saving the junctions for the falsewall because it changes icon_state often instead of once
		var/obj/falsewall/F = src
		F.junctions = junction
*/
	return

/turf/simulated/wall/New()

	for(var/turf/simulated/wall/W in range(src,1))
		W.relativewall()

	for(var/obj/falsewall/W in range(src,1))
		W.relativewall()

	..()

/obj/falsewall/New()

	for(var/turf/simulated/wall/W in range(src,1))
		W.relativewall()

	for(var/obj/falsewall/W in range(src,1))
		W.relativewall()

	..()

/turf/simulated/wall/Del()

	var/temploc = src.loc

	spawn(10)
		for(var/turf/simulated/wall/W in range(temploc,1))
			W.relativewall()

		for(var/obj/falsewall/W in range(temploc,1))
			W.relativewall()

	..()

/turf/falsewall/Del()

	var/temploc = src.loc

	spawn(10)
		for(var/turf/simulated/wall/W in range(temploc,1))
			W.relativewall()

		for(var/obj/falsewall/W in range(temploc,1))
			W.relativewall()

	..()