//Just a copy paste from clock_structures, but it gets the job done.

/obj/structure/cult
	icon = 'icons/obj/cult.dmi'
	anchored = 1
	density = 1
	opacity = 0
	layer = OBJ_LAYER
	var/max_health = 100 //All clockwork structures have health that can be removed via attacks
	var/health = 100
	var/takes_damage = TRUE //If the structure can be damaged
	var/break_message = "<span class='warning'>The frog isn't a meme after all!</span>" //The message shown when a structure breaks
	var/break_sound = 'sound/magic/clockwork/anima_fragment_death.ogg' //The sound played when a structure breaks
	var/cooldowntime = 0

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

/obj/structure/cult/proc/destroyed()
	if(!takes_damage)
		return 0
	visible_message(break_message)
	playsound(src, break_sound, 50, 1)
	qdel(src)
	return 1

/obj/structure/cult/burn()
	SSobj.burning -= src
	if(takes_damage)
		playsound(src, 'sound/items/Welder.ogg', 100, 1)
		visible_message("<span class='warning'>[src] is warped by the heat!</span>")
		take_damage(rand(50, 100), BURN)

/obj/structure/cult/proc/take_damage(amount, damage_type)
	if(!amount || !damage_type || !damage_type in list(BRUTE, BURN))
		return 0
	if(takes_damage)
		health = max(0, health - amount)
		if(!health)
			destroyed()
		return 1
	return 0

/obj/structure/cult/ex_act(severity)
	var/damage = 0
	switch(severity)
		if(1)
			damage = max_health //100% max health lost
		if(2)
			damage = max_health * (0.01 * rand(50, 70)) //50-70% max health lost
		if(3)
			damage = max_health * (0.01 * rand(10, 30)) //10-30% max health lost
	if(damage)
		take_damage(damage, BRUTE)


/obj/structure/cult/bullet_act(obj/item/projectile/P)
	. = ..()
	visible_message("<span class='danger'>[src] is hit by \a [P]!</span>")
	playsound(src, P.hitsound, 50, 1)
	take_damage(P.damage, P.damage_type)

/obj/structure/cult/proc/attack_generic(mob/user, damage = 0, damage_type = BRUTE) //used by attack_alien, attack_animal, and attack_slime
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='danger'>[user] smashes into [src]!</span>")
	take_damage(damage, damage_type)

/obj/structure/cult/attack_alien(mob/living/user)
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, 1)
	attack_generic(user, 15)

/obj/structure/cult/attack_animal(mob/living/simple_animal/M)
	if(!M.melee_damage_upper && !M.obj_damage)
		return
	playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
	if(M.obj_damage)
		attack_generic(M, M.obj_damage, M.melee_damage_type)
	else
		attack_generic(M, M.melee_damage_upper, M.melee_damage_type)

/obj/structure/cult/attack_slime(mob/living/simple_animal/slime/user)
	if(!user.is_adult)
		return
	playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
	attack_generic(user, rand(10, 15))

/obj/structure/cult/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(I.force && takes_damage)
		playsound(src, I.hitsound, 50, 1)
		take_damage(I.force, I.damtype)

/obj/structure/cult/mech_melee_attack(obj/mecha/M)
	if(..())
		playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
		take_damage(M.force, M.damtype)

/obj/structure/cult/talisman
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "talismanaltar"
	break_message = "<span class='warning'>There is a thunderous crack as the altar collapses!</span>"
	max_health = 80
	health = 80

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
	break_message = "<span class='warning'>The wailing of the damned echoes out as the forge is destroyed!</span>"
	max_health = 100
	health = 100

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
	break_message = "<span class='warning'>The blood-red crystal falls to the floor and shatters!</span>"
	max_health = 50
	health = 50

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
				PoolOrNew(/obj/effect/overlay/temp/cult/turf/floor, F)
			else
				// Are we in space or something? No cult turfs or
				// convertable turfs?
				last_corrupt = world.time + corrupt_delay*2

/obj/structure/cult/tome
	name = "archives"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	luminosity = 1
	break_message = "<span class='warning'>The eldritch texts ignite in unholy fire as the archives burn to ash!</span>"
	max_health = 60
	health = 60

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
	var/choice = alert(user,"You flip through the black pages of the archives...",,"Supply Talisman","Shuttle Curse","Veil Walker Set")
	var/pickedtype
	switch(choice)
		if("Supply Talisman")
			pickedtype = /obj/item/weapon/paper/talisman/supply/weak
		if("Shuttle Curse")
			pickedtype = /obj/item/device/shuttle_curse
		if("Veil Walker Set")
			pickedtype = /obj/item/device/cult_shift
			pickedtype = /obj/item/device/flashlight/flare/culttorch
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
