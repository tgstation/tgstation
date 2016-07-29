/obj/effect/vaultspawner
	var/maxX = 6
	var/maxY = 6
	var/minX = 2
	var/minY = 2

<<<<<<< HEAD
/obj/effect/vaultspawner/New(turf/location,lX = minX,uX = maxX,lY = minY,uY = maxY,type = null)
=======
/obj/effect/vaultspawner/New(turf/location as turf,lX = minX,uX = maxX,lY = minY,uY = maxY,var/type = null)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(!type)
		type = pick("sandstone","rock","alien")

	var/lowBoundX = location.x
	var/lowBoundY = location.y

	var/hiBoundX = location.x + rand(lX,uX)
	var/hiBoundY = location.y + rand(lY,uY)

	var/z = location.z

	for(var/i = lowBoundX,i<=hiBoundX,i++)
		for(var/j = lowBoundY,j<=hiBoundY,j++)
<<<<<<< HEAD
			var/turf/T = locate(i,j,z)
			if(i == lowBoundX || i == hiBoundX || j == lowBoundY || j == hiBoundY)
				T.ChangeTurf(/turf/closed/wall/vault)
			else
				T.ChangeTurf(/turf/open/floor/vault)
			T.icon_state = "[type]vault"
=======
			if(i == lowBoundX || i == hiBoundX || j == lowBoundY || j == hiBoundY)
				new /turf/simulated/wall/vault(locate(i,j,z),type)
			else
				new /turf/simulated/floor/vault(locate(i,j,z),type)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	qdel(src)
