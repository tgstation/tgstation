/*

	This is a smart+stupid method of maintaining paths during refactors.
	At this point in time we have more maps than ever, and our tools just aren't that great.
	So instead of repathing all the maps...

	Keep the old path defined, just as an empty type with that path, and then define it's
	parent_type as the new path, effectively maintaining the object/mob w/e without having
	to touch all the maps, avoiding all those nasty conflicts!

	Ideally the old paths would be cleaned out as mappers go about their usual routine of
	updating old maps.

	tl;dr TYPEFUCKERY, because fuck updating all these maps

*/



//Vehicle Refactor - 2015
/obj/structure/bed/chair/janicart/secway
	parent_type = /obj/vehicle/secway

/obj/structure/bed/chair/janicart
	parent_type = /obj/vehicle/janicart

/obj/structure/bed/chair/janicart/atv
	parent_type = /obj/vehicle/atv

//Animal Farm Botany Expansion - 2016
/mob/living/simple_animal/chick
	parent_type = /mob/living/simple_animal/farm/chick
/mob/living/simple_animal/chicken
	parent_type = /mob/living/simple_animal/farm/chicken
/mob/living/simple_animal/hostile/retaliate/goat
	parent_type = /mob/living/simple_animal/farm/goat
/mob/living/simple_animal/chicken/rabbit
	parent_type = /mob/living/simple_animal/farm/rabbit
/mob/living/simple_animal/chicken/rabbit/space
	parent_type = /mob/living/simple_animal/farm/rabbit/space
/mob/living/simple_animal/hostile/carp
	parent_type = /mob/living/simple_animal/farm/carp
/mob/living/simple_animal/hostile/carp/megacarp
	parent_type = /mob/living/simple_animal/farm/carp/megacarp
/mob/living/simple_animal/hostile/carp/holocarp
	parent_type = /mob/living/simple_animal/farm/carp/holocarp
/mob/living/simple_animal/hostile/carp/ranged
	parent_type = /mob/living/simple_animal/hostile/carp_ranged
/mob/living/simple_animal/hostile/carp/ranged/chaos
	parent_type = /mob/living/simple_animal/hostile/carp_ranged/chaos
/mob/living/simple_animal/cow
	parent_type = /mob/living/simple_animal/farm/cow
/mob/living/simple_animal/hostile/carp/cayenne
	parent_type = /mob/living/simple_animal/farm/carp/cayenne