/obj/structure/closet/critter
	name = "critter crate"
	desc = "A crate designed for safe transport of animals. Only openable from the the outside."
	icon_state = "critter"
	var/already_opened = 0
	var/content_mob = null
	var/amount = 1

/obj/structure/closet/critter/can_open()
	if(locked || welded)
		return 0
	return 1

/obj/structure/closet/critter/open()
	if(!can_open())
		return 0

	if(content_mob == null) //making sure we don't spawn anything too eldritch
		already_opened = 1
		return ..()

	if(content_mob != null && already_opened == 0)
		for(var/i = 1, i <= amount, i++)
			new content_mob(loc)
		already_opened = 1
	..()

/obj/structure/closet/critter/close()
	..()
	locked = 1
	return 1

/obj/structure/closet/critter/attack_hand(mob/user as mob)
	src.add_fingerprint(user)

	if(src.loc == user.loc)
		user << "<span class='notice'>It won't budge!</span>"
		toggle()
	else
		locked = 0
		toggle()

/obj/structure/closet/critter/corgi
	name = "corgi crate"
	content_mob = /mob/living/simple_animal/pet/corgi

/obj/structure/closet/critter/corgi/New()
	if(prob(50))
		content_mob = /mob/living/simple_animal/pet/corgi/Lisa
	..()

/obj/structure/closet/critter/cow
	name = "cow crate"
	content_mob = /mob/living/simple_animal/cow

/obj/structure/closet/critter/goat
	name = "goat crate"
	content_mob = /mob/living/simple_animal/hostile/retaliate/goat

/obj/structure/closet/critter/chick
	name = "chicken crate"
	content_mob = /mob/living/simple_animal/chick

/obj/structure/closet/critter/chick/New()
	amount = rand(1, 3)
	..()

/obj/structure/closet/critter/cat
	name = "cat crate"
	content_mob = /mob/living/simple_animal/pet/cat

/obj/structure/closet/critter/cat/New()
	if(prob(50))
		content_mob = /mob/living/simple_animal/pet/cat/Proc
	..()

/obj/structure/closet/critter/pug
	name = "pug crate"
	content_mob = /mob/living/simple_animal/pet/pug

/obj/structure/closet/critter/fox
	name = "fox crate"
	content_mob = /mob/living/simple_animal/pet/fox

/obj/structure/closet/critter/butterfly
	name = "butterflies crate"
	content_mob = /mob/living/simple_animal/butterfly
	amount = 50