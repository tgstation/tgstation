//Wheelchair, stolen shamelessly from Hippie

/obj/structure/stool/bed/chair/wheelchair
	name = "wheelchair"
	desc = "Chances are you don't really need this."
	icon_state = "wheelchair"
	anchored = 0
	var/cooldown = 0

/obj/structure/stool/bed/chair/wheelchair/handle_rotation()
	overlays = null
	var/image/O = image(icon = 'icons/obj/objects.dmi', icon_state = "wheelchair_overlay", layer = FLY_LAYER, dir = src.dir)
	overlays += O
	if(buckled_mob)
		buckled_mob.dir = dir

/obj/structure/stool/bed/chair/wheelchair/relaymove(mob/user, direction)
	if((!Process_Spacemove(direction)) || (!has_gravity(src.loc)) || (cooldown) || user.stat || user.stunned || user.weakened || user.paralysis || (user.restrained()))
		return
	step(src, direction)
	handle_rotation()
	handle_layer()
	cooldown = 1
	spawn(3+user.movement_delay())	//Missing arms slows you down, as does anything else that causes slowdown
		cooldown = 0

/obj/structure/stool/bed/chair/wheelchair/rotate()
	..()
	handle_rotation()