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