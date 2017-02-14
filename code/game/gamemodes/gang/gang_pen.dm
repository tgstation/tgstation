/*
 * Gang Boss Pens
 */
/obj/item/weapon/pen/gang
	origin_tech = "materials=2;syndicate=3"
	var/cooldown
	var/last_used = 0
	var/charges = 1

/obj/item/weapon/pen/gang/New()
	..()
	last_used = world.time

/obj/item/weapon/pen/gang/attack(mob/living/M, mob/user)
	if(!istype(M))
		return
	if(ishuman(M) && ishuman(user) && M.stat != DEAD)
		if(user.mind && (user.mind in ticker.mode.get_gang_bosses()))
			if(..(M,user,1))
				if(cooldown)
					user << "<span class='warning'>[src] needs more time to recharge before it can be used.</span>"
					return
				if(M.client)
					M.mind_initialize()		//give them a mind datum if they don't have one.
					var/datum/gang/G = user.mind.gang_datum
					var/recruitable = ticker.mode.add_gangster(M.mind,G)
					switch(recruitable)
						if(2)
							M.Paralyse(5)
							cooldown(G)
						if(1)
							user << "<span class='warning'>This mind is resistant to recruitment!</span>"
						else
							user << "<span class='warning'>This mind has already been recruited into a gang!</span>"
			return
	..()

/obj/item/weapon/pen/gang/proc/cooldown(datum/gang/gang)
	var/cooldown_time = 600+(600*gang.bosses.len) // 1recruiter=2mins, 2recruiters=3mins, 3recruiters=4mins

	cooldown = 1
	icon_state = "pen_blink"

	var/time_passed = world.time - last_used
	var/time
	for(time=time_passed, time>=cooldown_time, time-=cooldown_time) //get 1 charge every cooldown interval
		charges++

	charges = max(0,charges-1)

	last_used = world.time - time

	if(charges)
		cooldown_time = 50
	spawn(cooldown_time)
		cooldown = 0
		icon_state = "pen"
		var/mob/M = get(src, /mob)
		M << "<span class='notice'>\icon[src] [src][(src.loc == M)?(""):(" in your [src.loc]")] vibrates softly. It is ready to be used again.</span>"
