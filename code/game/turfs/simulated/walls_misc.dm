/turf/simulated/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon_state = "cult"
	walltype = "cult"
	dismantle_type = /turf/simulated/floor/engine/cult
	girder_type = /obj/structure/cultgirder

/turf/simulated/wall/cult/cultify()
	return

/turf/simulated/wall/cult/dismantle_wall(devastated = 0, explode = 0)
	if(!devastated)
		getFromPool(/obj/effect/decal/cleanable/blood, src)
		new girder_type(src)
	else
		if(prob(10))
			getFromPool(/obj/effect/decal/cleanable/blood, src)
		//	new /obj/effect/decal/remains/human(src) //Commented out until remains are cleanable

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)

	ChangeTurf(dismantle_type)

/turf/simulated/wall/cult/attack_construct(mob/user as mob)
	if(istype(user,/mob/living/simple_animal/construct/builder) && user.Adjacent(src))
		dismantle_wall(1)
		return 1
	return 0
