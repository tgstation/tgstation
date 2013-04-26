var/list/crystals = list()
var/list/crystal_types = typesof(/obj/item/crystal) - /obj/item/crystal

var/const/CRYSTAL_POWER_EMP = 1
var/const/CRYSTAL_POWER_FIRE = 2
var/const/CRYSTAL_POWER_HEAL = 4

/obj/item/crystal
	name = "crystal"
	desc = "A giant mystical alien crystal. The power inside can be activated with a touch."
	w_class = 3
	icon = 'icons/obj/crystal.dmi'

	var/powers = 0
	var/cooldown = 0
	var/cooldown_timer = 300

/obj/item/crystal/New()
	..()
	crystals += src

/obj/item/crystal/Del()
	crystals -= src
	..()

/obj/item/crystal/attack_self(var/mob/living/L)
	..()

	if(cooldown)
		L << "<span class='alert'>The crystal is recharging...</span>"
		return

	L.visible_message("<span class='warning'>[L] activates the [src]!</span>")

	if(powers & CRYSTAL_POWER_EMP)
		empulse(src, 4, 10)

	if(powers & CRYSTAL_POWER_FIRE)
		for(var/mob/living/M in oview(7, L))
			M.adjustFireLoss(rand(25, 40))
			M << "<span class='alert'>You feel your insides burning!</span>"

	if(powers & CRYSTAL_POWER_HEAL)
		for(var/mob/living/M in view(7, L))
			var/heal = rand(15, 30)
			M.adjustFireLoss(-heal)
			M.adjustToxLoss(-heal)
			M.adjustBruteLoss(-heal)
			M.adjustCloneLoss(-heal)
			M << "<span class='notice'>You suddenly feel better.</span>"

	playsound(loc, 'sound/weapons/emitter.ogg', 50, 1)

	cooldown = 1
	spawn(cooldown_timer)
		cooldown = 0

// Strong glows depending on how close other crystals are.
/obj/item/crystal/examine()

	..()
	var/dist = 255
	var/message = "The crystal isn't glowing at all."

	var/turf/T = get_turf(src)
	if(!T)
		return

	for(var/obj/item/crystal/C in crystals)
		if(C == src)
			continue
		var/turf/crystal_turf = get_turf(C)
		if(!crystal_turf)
			continue

		dist = min(get_dist(T, crystal_turf), dist)

	switch(dist)
		if(0 to 1)
			message = "The crystal is glowing very strongly!"
		if(2 to 5)
			message = "The crystal is glowing quite strongly."
		if(6 to 10)
			message = "The crystal is glowing."
		if(11 to 25)
			message = "The crystal is glowing a little."
		if(26 to 40)
			message = "The crystal is barely glowing."

	usr << message


// TYPES OF CRYSTALS

/obj/item/crystal/red
	name = "red crystal"
	powers = CRYSTAL_POWER_FIRE
	icon_state = "crystal_red"

/obj/item/crystal/blue
	name = "blue crystal"
	powers = CRYSTAL_POWER_EMP
	icon_state = "crystal_blue"

/obj/item/crystal/green
	name = "green crystal"
	powers = CRYSTAL_POWER_HEAL
	icon_state = "crystal_green"