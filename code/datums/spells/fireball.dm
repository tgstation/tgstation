/obj/spell/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."

	school = "evocation"
	recharge = 200
	clothes_req = 0
	invocation = "ONI SOMA"
	invocation_type = "shout"
	var/radius_devastation = -1
	var/radius_heavy = -1
	var/radius_light = 2
	var/radius_flash = 2
	var/bruteloss = 20 // apparently fireball deals damage in addition to the explosion
	var/fireloss = 25  // huh
	var/lifetime = 200 // in deciseconds

/obj/spell/fireball/Click()
	..()

	if(!cast_check())
		return

	var/mob/M = input("Choose whom to fireball", "ABRAKADABRA") as mob|obj|turf in oview(usr,range)

	invocation()

	var/obj/overlay/A = new /obj/overlay( usr.loc )
	A.icon_state = "fireball"
	A.icon = 'wizard.dmi'
	A.name = "a fireball"
	A.anchored = 0
	A.density = 0
	var/i
	for(i=0, i<lifetime, i++)
		step_to(A,M,0)
		if(get_dist(A,M) <= 1)
			if(istype(M,/mob))
				M:bruteloss += bruteloss
				M:fireloss += fireloss
			explosion(M.loc, radius_devastation, radius_heavy, radius_light, radius_flash)
			del(A)
			return
		sleep(1)
	del(A)
	return