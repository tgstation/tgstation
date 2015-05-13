/obj/effect/vaultspawner
	var/maxX = 6
	var/maxY = 6
	var/minX = 2
	var/minY = 2

/obj/effect/vaultspawner/New(turf/location as turf,lX = minX,uX = maxX,lY = minY,uY = maxY,var/type = null)
	if(!type)
		type = pick("sandstone","rock","alien")

	var/lowBoundX = location.x
	var/lowBoundY = location.y

	var/hiBoundX = location.x + rand(lX,uX)
	var/hiBoundY = location.y + rand(lY,uY)

	var/z = location.z

	for(var/i = lowBoundX,i<=hiBoundX,i++)
		for(var/j = lowBoundY,j<=hiBoundY,j++)
			var/turf/T = locate(i,j,z)
			if(i == lowBoundX || i == hiBoundX || j == lowBoundY || j == hiBoundY)
				T.ChangeTurf(/turf/simulated/wall/vault)
			else
				T.ChangeTurf(/turf/simulated/floor/vault)
			T.icon_state = "[type]vault"

	qdel(src)
