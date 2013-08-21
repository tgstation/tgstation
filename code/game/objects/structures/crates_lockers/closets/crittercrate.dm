/obj/structure/closet/critter
	name = "critter crate"
	desc = "A crate designed for safe transport of animals. Can sustain life for a while. Only openable from the the outside."
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

/obj/structure/closet/critter/can_open()
	if(src.locked || src.welded)
		return 0
	return 1

/obj/structure/closet/critter/open()
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
	..()

/obj/structure/closet/critter/close()
	..()
	src.locked = 1
	return 1

/obj/structure/closet/critter/attack_hand(mob/user as mob)
	src.add_fingerprint(user)

	if(src.loc == usr.loc)
		usr << "<span class='notice'>It won't budge!</span>"
		src.toggle()
	else
		src.locked = 0
		src.toggle()

/obj/structure/closet/critter/corgi
	name = "corgi crate"
	content_mob = /mob/living/simple_animal/corgi //This statement is (not) false. See above.

/obj/structure/closet/critter/cow
	name = "cow crate"
	content_mob = /mob/living/simple_animal/cow

/obj/structure/closet/critter/goat
	name = "goat crate"
	content_mob = /mob/living/simple_animal/hostile/retaliate/goat

/obj/structure/closet/critter/chick
	name = "chicken crate"
	content_mob = /mob/living/simple_animal/chick

/obj/structure/closet/critter/cat
	name = "cat crate"
	content_mob = /mob/living/simple_animal/cat

/*/obj/structure/closet/critter/pug //just in case pugs gets added
	  name = "pug crate"
	  content_mob = /mob/living/simple_animal/pug
*/