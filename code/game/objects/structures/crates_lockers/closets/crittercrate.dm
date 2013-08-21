/obj/structure/closet/crate/critter
	name = "critter crate"
	desc = "A crate which can sustain life for a while. Only openable from the the outside."
	icon_state = "critter"
	icon_opened = "critteropen"
	icon_closed = "critter"
	var/target_temp = T0C + 20
	var/ac_power = 20
	var/already_opened = 0
	var/content_mob = null
	var/locked = 0 //used for breaking out only

	return_air() //keeps it warm and fuzzy inside for mobs (for a while)
		var/datum/gas_mixture/gas = (..())
		if(!gas)	return null
		var/datum/gas_mixture/newgas = new/datum/gas_mixture()
		newgas.oxygen = gas.oxygen
		newgas.carbon_dioxide = gas.carbon_dioxide
		newgas.nitrogen = gas.nitrogen
		newgas.toxins = gas.toxins
		newgas.volume = gas.volume
		newgas.temperature = gas.temperature
		if(newgas.temperature >= target_temp)
			return
		if((newgas.temperature + ac_power) < target_temp)
			newgas.temperature += ac_power
		else
			newgas.temperature = target_temp
		return newgas

/obj/structure/closet/crate/critter/can_open()
	if(src.locked)
		return 0
	return 1

/obj/structure/closet/crate/critter/open()

	if(!src.can_open())
		return 0

	if(src.content_mob == null) //making sure we don't spawn anything too eldritch
		src.already_opened = 1

	if(src.content_mob != null && src.already_opened == 0)
		if(src.content_mob == /mob/living/simple_animal/chick)
			var/num = rand(4, 6)
			for(var/i = 0, i < num, i++)
				new src.content_mob(loc)
			src.already_opened = 1
		else if(src.content_mob == /mob/living/simple_animal/corgi)
			var/num = rand(0, 1)
			if(num) //No more matriarchy for cargo
				src.content_mob = /mob/living/simple_animal/corgi/Lisa
			new src.content_mob(loc)
			src.already_opened = 1
		else
			new src.content_mob(loc)
			src.already_opened = 1

	playsound(src.loc, sound_effect_open, 15, 1, -3)

	dump_contents()

	src.icon_state = icon_opened
	src.opened = 1
	src.density = 0
	return 1

/obj/structure/closet/crate/critter/close()
	playsound(src.loc, sound_effect_close, 15, 1, -3)

	take_contents()

	src.icon_state = icon_closed
	src.opened = 0
	src.density = 1
	src.locked = 1
	return 1

/obj/structure/closet/crate/critter/insert(var/atom/movable/AM)

	if(contents.len >= storage_capacity)
		return -1

	if(istype(AM, /mob/living))
		var/mob/living/L = AM
		if(L.buckled)
			return 0
		if(L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src

	else if(isobj(AM))
		if(AM.density || AM.anchored || istype(AM,/obj/structure/closet))
			return 0
	else
		return 0

	if(istype(AM, /obj/structure/stool/bed)) //This is only necessary because of rollerbeds and swivel chairs.
		var/obj/structure/stool/bed/B = AM
		if(B.buckled_mob)
			return 0

	AM.loc = src
	return 1

/obj/structure/closet/crate/critter/relaymove(mob/user as mob)
	if(user.stat || !isturf(src.loc))
		return

	if(!src.open())
		user << "<span class='notice'>It won't budge!</span>"
		if(!lastbang)
			lastbang = 1
			for (var/mob/M in hearers(src, null))
				M << text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M)))
			spawn(30)
				lastbang = 0

/obj/structure/closet/crate/critter/attack_hand(mob/user as mob)
	src.add_fingerprint(user)

	if(src.loc == usr.loc)
		usr << "<span class='notice'>It won't budge!</span>"
		src.toggle()
	else
		src.locked = 0
		src.toggle()

/obj/structure/closet/crate/critter/corgi
	name = "corgi crate"
	content_mob = /mob/living/simple_animal/corgi //This statement is (not) false. See above.

/obj/structure/closet/crate/critter/cow
	name = "cow crate"
	content_mob = /mob/living/simple_animal/cow

/obj/structure/closet/crate/critter/goat
	name = "goat crate"
	content_mob = /mob/living/simple_animal/hostile/retaliate/goat

/obj/structure/closet/crate/critter/chick
	name = "chicken crate"
	content_mob = /mob/living/simple_animal/chick

/obj/structure/closet/crate/critter/cat
	name = "cat crate"
	content_mob = /mob/living/simple_animal/cat

/*/obj/structure/closet/crate/critter/pug //just in case pugs gets added
	  name = "pug crate"
	  content_mob = /mob/living/simple_animal/pug
*/