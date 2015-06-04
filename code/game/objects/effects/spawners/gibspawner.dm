/obj/effect/gibspawner

/obj/effect/gibspawner/generic
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/core)
	gibamounts = list(2,2,1)

/obj/effect/gibspawner/generic/New()
	playsound(src, 'sound/effects/blobattack.ogg', 40, 1)
	gibdirections = list(list(WEST, NORTHWEST, SOUTHWEST, NORTH),list(EAST, NORTHEAST, SOUTHEAST, SOUTH), list())
	..()

/obj/effect/gibspawner/human
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/up,/obj/effect/decal/cleanable/blood/gibs/down,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/body,/obj/effect/decal/cleanable/blood/gibs/limb,/obj/effect/decal/cleanable/blood/gibs/core)
	gibamounts = list(1,1,1,1,1,1,1)

/obj/effect/gibspawner/human/New()
	playsound(src, 'sound/effects/blobattack.ogg', 50, 1)
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), alldirs, alldirs, list())
	gibamounts[6] = pick(0,1,2)
	..()

/obj/effect/gibspawner/xeno
	gibtypes = list(/obj/effect/decal/cleanable/xenoblood/xgibs/up,/obj/effect/decal/cleanable/xenoblood/xgibs/down,/obj/effect/decal/cleanable/xenoblood/xgibs,/obj/effect/decal/cleanable/xenoblood/xgibs,/obj/effect/decal/cleanable/xenoblood/xgibs/body,/obj/effect/decal/cleanable/xenoblood/xgibs/limb,/obj/effect/decal/cleanable/xenoblood/xgibs/core)
	gibamounts = list(1,1,1,1,1,1,1)

/obj/effect/gibspawner/xeno/New()
	playsound(src, 'sound/effects/blobattack.ogg', 60, 1)
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), alldirs, alldirs, list())
	gibamounts[6] = pick(0,1,2)
	..()

/obj/effect/gibspawner/robot
	sparks = 1
	gibtypes = list(/obj/effect/decal/cleanable/robot_debris/up,/obj/effect/decal/cleanable/robot_debris/down,/obj/effect/decal/cleanable/robot_debris,/obj/effect/decal/cleanable/robot_debris,/obj/effect/decal/cleanable/robot_debris,/obj/effect/decal/cleanable/robot_debris/limb)
	gibamounts = list(1,1,1,1,1,1)

/obj/effect/gibspawner/robot/New()
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), alldirs, alldirs)
	gibamounts[6] = pick(0,1,2)
	..()