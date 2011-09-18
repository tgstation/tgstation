//These could likely use an Onhit proc
/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	flag = "taser"//Need to check this
	damage = 0
	nodamage = 1
	New()
		..()
		effects["emp"] = 1
		effectprob["emp"] = 80

/obj/item/projectile/freeze
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	var/temperature = 0

	proc/Freeze(atom/A as mob|obj|turf|area)
		if(istype(A, /mob))
			var/mob/M = A
			if(M.bodytemperature > temperature)
				M.bodytemperature = temperature

/obj/item/projectile/plasma
	name = "plasma blast"
	icon_state = "plasma_2"
	damage = 0
	var/temperature = 800

	proc/Heat(atom/A as mob|obj|turf|area)
		if(istype(A, /mob/living/carbon))
			var/mob/M = A
			if(M.bodytemperature < temperature)
				M.bodytemperature = temperature
