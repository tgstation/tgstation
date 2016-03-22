/obj/structure/closet/crate/critter
	name = "critter crate"
	desc = "A crate designed for safe transport of animals. It has an oxygen tank for safe transport in space."
	icon_state = "crittercrate"
	horizontal = FALSE
	allow_objects = FALSE
	breakout_time = 1
	material_drop = /obj/item/stack/sheet/mineral/wood
	var/obj/item/weapon/tank/internals/emergency_oxygen/tank

/obj/structure/closet/crate/critter/New()
	..()
	tank = new

/obj/structure/closet/crate/critter/Destroy()
	var/turf/T = get_turf(src)
	tank.loc = T
	tank = null

	for(var/i in 1 to rand(2, 5))
		new material_drop(T)

	return ..()

/obj/structure/closet/crate/critter/update_icon()
	overlays.Cut()
	if(opened)
		overlays += "crittercrate_door_open"
	else
		overlays += "crittercrate_door"
		if(manifest)
			overlays += "manifest"

/obj/structure/closet/crate/critter/return_air()
	if(tank)
		return tank.air_contents
	else
		return loc.return_air()