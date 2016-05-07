/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'
	var/cooldowntime = 0
	var/health = 100
	var/maxhealth = 100

/obj/structure/cult/proc/getETA()
    var/time = round((0-(world.time-cooldowntime))/600, 1)
    var/eta = "[time] minutes."
    if(time == 1)
        eta = "about one minute."
    else if(time == 0)
        eta = "less than thirty seconds."
    return eta
         
/obj/structure/cult/talisman
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "talismanaltar"

	
/obj/structure/cult/talisman/attack_hand(mob/living/user)
	if(!iscultist(user))
		user << "<span class='warning'>You don't even begin to understand what these words mean...</span>"
		return
	if(cooldowntime > world.time)
		user << "<span class='cultitalic'>The magic here is weak, it will be ready to use again in [getETA()]. </span>"
		return
	cooldowntime = world.time + 2400
	var/choice = alert(user,"You study the schematics etched into the forge...",,"Eldritch Whetstone","Zealot's Blindfold","Flask of Unholy Water")
	switch(choice)
		if("Eldritch Whetstone")
			var/obj/item/weapon/sharpener/cult/N = new(get_turf(src))
			user << "<span class='cultitalic'>You kneel before the altar and your faith is rewarded with an [N.name]!</span>"
		if("Zealot's Blindfold")
			var/obj/item/clothing/glasses/night/cultblind/N = new(get_turf(src))
			user << "<span class='cultitalic'>You kneel before the altar and your faith is rewarded with a [N.name]!</span>"
		if("Flask of Unholy Water")
			var/obj/item/weapon/reagent_containers/food/drinks/bottle/unholywater/N = new(get_turf(src))
			user << "<span class='cultitalic'>You kneel before the altar and your faith is rewarded with a [N.name]!</span>"
	
	
/obj/structure/cult/forge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie."
	icon_state = "forge"
	luminosity = 3

/obj/structure/cult/forge/attack_hand(mob/living/user)
	if(!iscultist(user))
		user << "<span class='warning'>You don't even begin to understand what these words mean...</span>"
		return
	if(cooldowntime > world.time)
		user << "<span class='cultitalic'>The magic here is weak, it will be ready to use again in [getETA()]. </span>"
		return
	cooldowntime = world.time + 2400
	var/choice = alert(user,"You study the schematics etched into the forge...",,"Shielded Robe","Flagellant's Robe","Nar-Sien Hardsuit")
	switch(choice)
		if("Shielded Robe")
			var/obj/item/clothing/suit/hooded/cultrobes/cult_shield/N = new(get_turf(src))
			user << "<span class='cultitalic'>You work the forge as dark knowledge guides your hands, creating [N]!</span>"
		if("Flagellant's Robe")
			var/obj/item/clothing/suit/hooded/cultrobes/berserker/N = new(get_turf(src))
			user << "<span class='cultitalic'>You work the forge as dark knowledge guides your hands, creating [N]!</span>"
		if("Nar-Sien Hardsuit")
			new /obj/item/clothing/head/helmet/space/cult(get_turf(src))
			var /obj/item/clothing/suit/space/cult/N = new(get_turf(src))
			user << "<span class='cultitalic'>You work the forge as dark knowledge guides your hands, creating [N]!</span>"

/obj/structure/cult/pylon
	name = "pylon"
	desc = "A floating crystal that slowly heals those faithful to Nar'Sie."
	icon_state = "pylon"
	luminosity = 5
	var/heal_delay = 50
	var/last_shot = 0
	var/list/corruption = list()

/obj/structure/cult/pylon/New()
	SSobj.processing |= src
	corruption += get_turf(src)
	for(var/i in 1 to 5)
		for(var/t in corruption)
			var/turf/T = t
			corruption |= T.GetAtmosAdjacentTurfs()	
	..()

/obj/structure/cult/pylon/Destroy()
	SSobj.processing.Remove(src)
	return ..()
	
/obj/structure/cult/pylon/process()
	if((last_shot + heal_delay) <= world.time)
		last_shot = world.time
		for(var/mob/living/L in range(5, src))
			if(iscultist(L))
				var/mob/living/carbon/human/H = L
				if(istype(H))
					L.adjustBruteLoss(-1, 0)
					L.adjustFireLoss(-1, 0)
					L.updatehealth()
				if(istype(L, /mob/living/simple_animal/hostile/construct))
					var/mob/living/simple_animal/M = L
					if(M.health < M.maxHealth)
						M.adjustHealth(-2)
		if(corruption.len)
			var/turf/T = pick_n_take(corruption)
			corruption -= T
			if (istype(T, /turf/open/floor/engine/cult) || istype(T, /turf/open/space) || istype(T, /turf/open/floor/plating/lava))
				return
			T.ChangeTurf(/turf/open/floor/engine/cult)

/obj/structure/cult/tome
	name = "archives"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	luminosity = 1

/obj/structure/cult/tome/attack_hand(mob/living/user)
	if(!iscultist(user))
		user << "<span class='warning'>You don't even begin to understand what these words mean...</span>"
		return
	if(cooldowntime > world.time)
		user << "<span class='cultitalic'>The magic here is weak, it will be ready to use again in [getETA()]. </span>"
		return
	cooldowntime = world.time + 2400
	var/choice = alert(user,"You flip through the black pages of the archives...",,"Supply Talisman","Shuttle Curse","Veil Shift")
	switch(choice)
		if("Supply Talisman")
			var/obj/item/weapon/paper/talisman/supply/N = new(get_turf(src))
			N.uses = 2
			user << "<span class='cultitalic'>You summon [N] from the archives!</span>"
		if("Shuttle Curse")
			var/obj/item/device/shuttle_curse/N = new(get_turf(src))
			user << "<span class='cultitalic'>You summon [N] from the archives!</span>"
		if("Veil Shift")
			var /obj/item/device/cult_shift/N = new(get_turf(src))
			user << "<span class='cultitalic'>You summon [N] from the archives!</span>"
	
/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	unacidable = 1
	anchored = 1
