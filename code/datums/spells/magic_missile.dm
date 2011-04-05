/obj/spell/magic_missile
	name = "Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	school = "evocation"
	charge_max = 100
	clothes_req = 1
	invocation = "FORTI GY AMA"
	invocation_type = "shout"
	range = 7
	var/max_targets = 0 //max targets for the spell. set to 0 for no limit
	var/missile_lifespan = 20 //in deciseconds * missile_step_delay
	var/missile_step_delay = 5 //lower = faster missile
	var/missile_weaken_amt = 5 //the amount by which the missile weakens the target it hits
	var/missile_damage = 10 //the amount of fireloss each missile deals

/obj/spell/magic_missile/Click()
	..()

	if(!cast_check())
		return

	invocation()

	var/targets = 0
	for (var/mob/M as mob in oview(usr,range))
		if(max_targets)
			if(targets >= max_targets)
				break
		spawn(0)
			var/obj/overlay/A = new /obj/overlay( usr.loc )
			A.icon_state = "magicm"
			A.icon = 'wizard.dmi'
			A.name = "a magic missile"
			A.anchored = 0
			A.density = 0
			A.layer = 4
			var/i
			for(i=0, i<missile_lifespan, i++)
				var/obj/overlay/B = new /obj/overlay( A.loc )
				B.icon_state = "magicmd"
				B.icon = 'wizard.dmi'
				B.name = "trail"
				B.anchored = 1
				B.density = 0
				B.layer = 3
				spawn(5)
					del(B)
				step_to(A,M,0)
				if (get_dist(A,M) == 0)
					M.weakened += missile_weaken_amt
					M.fireloss += missile_damage
					del(A)
					return
				sleep(missile_step_delay)
			del(A)
		targets++