/obj/structure/closet/crate/critter
	name = "critter crate"
	desc = "A crate designed for safe transport of animals. Only openable from the the outside."
	icon_state = "crittercrate"
	allow_mobs = TRUE
	breakout_time = 1

/obj/structure/closet/crate/critter/update_icon()
	overlays.Cut()
	if(opened)
		overlays += "crittercrate_door_open"
	else
		overlays += "crittercrate_door"
		if(manifest)
			overlays += "manifest"

/obj/structure/closet/crate/critter/attack_hand(mob/user)
	if(user in src)
		user << "<span class='notice'>It won't budge!</span>"
	else
		..()

/obj/structure/closet/crate/critter/corgi/New()
	..()
	if(prob(50))
		new /mob/living/simple_animal/pet/dog/corgi/Lisa(src)
	else
		new /mob/living/simple_animal/pet/dog/corgi(src)

/obj/structure/closet/crate/critter/cat/New()
	..()
	if(prob(50))
		new /mob/living/simple_animal/pet/cat/Proc(src)
	else
		new /mob/living/simple_animal/pet/cat(src)

/obj/structure/closet/crate/critter/chick/New()
	..()
	for(var/i in 1 to rand(1, 3))
		new /mob/living/simple_animal/chick(src)

/obj/structure/closet/crate/critter/butterfly/New()
	..()
	for(var/i in 1 to 50)
		new /mob/living/simple_animal/butterfly(src)