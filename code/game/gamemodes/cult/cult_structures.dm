/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'
	var/cooldowntime = 0
	var/health = 100
	var/maxhealth = 100

/obj/structure/cult/examine(mob/user)
	..()
	user << "<span class='notice'>\The [src] is [anchored ? "":"not "]secured to the floor.</span>"
	if(iscultist(user) && cooldowntime > world.time)
		user << "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [getETA()].</span>"

/obj/structure/cult/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/weapon/tome) && iscultist(user))
		anchored = !anchored
		user << "<span class='notice'>You [anchored ? "":"un"]secure \the [src] [anchored ? "to":"from"] the floor.</span>"
		if(!anchored)
			icon_state = "[initial(icon_state)]_off"
		else
			icon_state = initial(icon_state)
	else
		return ..()

/obj/structure/cult/proc/getETA()
	var/time = (cooldowntime - world.time)/600
	var/eta = "[round(time, 1)] minutes"
	if(time <= 1)
		time = (cooldowntime - world.time)*0.1
		eta = "[round(time, 1)] seconds"
	return eta

/obj/structure/cult/talisman
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "talismanaltar"

/obj/structure/cult/talisman/attack_hand(mob/living/user)
	if(!iscultist(user))
		user << "<span class='warning'>You're pretty sure you know exactly what this is used for and you can't seem to touch it.</span>"
		return
	if(!anchored)
		user << "<span class='cultitalic'>You need to anchor [src] to the floor with a tome first.</span>"
		return
	if(cooldowntime > world.time)
		user << "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [getETA()].</span>"
		return
	var/choice = alert(user,"You study the schematics etched into the forge...",,"Eldritch Whetstone","Zealot's Blindfold","Flask of Unholy Water")
	var/pickedtype
	switch(choice)
		if("Eldritch Whetstone")
			pickedtype = /obj/item/weapon/sharpener/cult
		if("Zealot's Blindfold")
			pickedtype = /obj/item/clothing/glasses/night/cultblind
		if("Flask of Unholy Water")
			pickedtype = /obj/item/weapon/reagent_containers/food/drinks/bottle/unholywater
	if(src && !qdeleted(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated() && iscultist(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		var/obj/item/N = new pickedtype(get_turf(src))
		user << "<span class='cultitalic'>You kneel before the altar and your faith is rewarded with an [N]!</span>"


/obj/structure/cult/forge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie."
	icon_state = "forge"
	luminosity = 3

/obj/structure/cult/forge/attack_hand(mob/living/user)
	if(!iscultist(user))
		user << "<span class='warning'>The heat radiating from [src] pushes you back.</span>"
		return
	if(!anchored)
		user << "<span class='cultitalic'>You need to anchor [src] to the floor with a tome first.</span>"
		return
	if(cooldowntime > world.time)
		user << "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [getETA()].</span>"
		return
	var/choice = alert(user,"You study the schematics etched into the forge...",,"Shielded Robe","Flagellant's Robe","Nar-Sien Hardsuit")
	var/pickedtype
	switch(choice)
		if("Shielded Robe")
			pickedtype = /obj/item/clothing/suit/hooded/cultrobes/cult_shield
		if("Flagellant's Robe")
			pickedtype = /obj/item/clothing/suit/hooded/cultrobes/berserker
		if("Nar-Sien Hardsuit")
			pickedtype = /obj/item/clothing/suit/space/hardsuit/cult
	if(src && !qdeleted(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated() && iscultist(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		var/obj/item/N = new pickedtype(get_turf(src))
		user << "<span class='cultitalic'>You work the forge as dark knowledge guides your hands, creating [N]!</span>"


var/list/blacklisted_pylon_turfs = typecacheof(list(
	/turf/closed,
	/turf/open/floor/engine/cult,
	/turf/open/space,
	/turf/open/floor/plating/lava,
	/turf/open/chasm))

/obj/structure/cult/pylon
	name = "pylon"
	desc = "A floating crystal that slowly heals those faithful to Nar'Sie."
	icon_state = "pylon"
	luminosity = 5
	var/heal_delay = 25
	var/last_heal = 0
	var/corrupt_delay = 50
	var/last_corrupt = 0

/obj/structure/cult/pylon/New()
	START_PROCESSING(SSfastprocess, src)
	..()

/obj/structure/cult/pylon/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/cult/pylon/process()
	if(!anchored)
		return
	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(5, src))
			if(iscultist(L) || isshade(L) || isconstruct(L))
				if(L.health != L.maxHealth)
					PoolOrNew(/obj/effect/overlay/temp/heal, list(get_turf(src), "#960000"))
					if(ishuman(L))
						L.adjustBruteLoss(-1, 0)
						L.adjustFireLoss(-1, 0)
						L.updatehealth()
					if(isshade(L) || isconstruct(L))
						var/mob/living/simple_animal/M = L
						if(M.health < M.maxHealth)
							M.adjustHealth(-1)
			CHECK_TICK
	if(last_corrupt <= world.time)
		var/list/validturfs = list()
		var/list/cultturfs = list()
		for(var/T in circleviewturfs(src, 5))
			if(istype(T, /turf/open/floor/engine/cult))
				cultturfs |= T
				continue
			if(is_type_in_typecache(T, blacklisted_pylon_turfs))
				continue
			else
				validturfs |= T

		last_corrupt = world.time + corrupt_delay

		var/turf/T = safepick(validturfs)
		if(T)
			T.ChangeTurf(/turf/open/floor/engine/cult)
		else
			var/turf/open/floor/engine/cult/F = safepick(cultturfs)
			if(F)
				PoolOrNew(/obj/effect/overlay/temp/cult/turf/open/floor, F)
			else
				// Are we in space or something? No cult turfs or
				// convertable turfs?
				last_corrupt = world.time + corrupt_delay*2

/obj/structure/cult/tome
	name = "archives"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	luminosity = 1

/obj/structure/cult/tome/attack_hand(mob/living/user)
	if(!iscultist(user))
		user << "<span class='warning'>All of these books seem to be gibberish.</span>"
		return
	if(!anchored)
		user << "<span class='cultitalic'>You need to anchor [src] to the floor with a tome first.</span>"
		return
	if(cooldowntime > world.time)
		user << "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [getETA()].</span>"
		return
	var/choice = alert(user,"You flip through the black pages of the archives...",,"Supply Talisman","Shuttle Curse","Veil Shifter")
	var/pickedtype
	switch(choice)
		if("Supply Talisman")
			pickedtype = /obj/item/weapon/paper/talisman/supply/weak
		if("Shuttle Curse")
			pickedtype = /obj/item/device/shuttle_curse
		if("Veil Shifter")
			pickedtype = /obj/item/device/cult_shift
	if(src && !qdeleted(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated() && iscultist(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		var/obj/item/N = new pickedtype(get_turf(src))
		user << "<span class='cultitalic'>You summon [N] from the archives!</span>"

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	unacidable = 1
	anchored = 1
