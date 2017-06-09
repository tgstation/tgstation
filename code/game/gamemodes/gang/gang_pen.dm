/*
 * Gang Boss Pens
 */
/obj/item/weapon/pen/gang
	origin_tech = "materials=2;syndicate=3"
	var/cooldown

/obj/item/weapon/pen/gang/attack(mob/living/M, mob/user, stealth = TRUE)
	if(!istype(M))
		return
	if(ishuman(M) && ishuman(user) && M.stat != DEAD)
		if(user.mind && (user.mind in SSticker.mode.get_gang_bosses()))
			if(..(M,user,1))
				if(cooldown)
					to_chat(user, "<span class='warning'>[src] needs more time to recharge before it can be used.</span>")
					return
				if(M.client)
					M.mind_initialize()		//give them a mind datum if they don't have one.
					var/datum/gang/G = user.mind.gang_datum
					var/recruitable = SSticker.mode.add_gangster(M.mind,G)
					switch(recruitable)
						if(3)
							for(var/obj/O in M.contents)
								if(istype(O, /obj/item/device/gangtool/soldier))
									to_chat(user, "<span class='warning'>This gangster already has an uplink!</span>")
									return
							new /obj/item/device/gangtool/soldier(M)
							to_chat(user, "<span class='warning'>You inject [M] with a new gangtool!</span>")
							cooldown(G)
						if(2)
							M.Paralyse(2)
							cooldown(G)
						if(1)
							to_chat(user, "<span class='warning'>This mind is resistant to recruitment!</span>")
						else
							to_chat(user, "<span class='warning'>This mind has already been recruited into a gang!</span>")
			return
	..()

/obj/item/weapon/pen/gang/proc/cooldown(datum/gang/gang)
	icon_state = "pen_blink"
	cooldown = TRUE
	var/living = 0
	for(var/mob/living/M in gang.gangsters)
		if(M.stat != DEAD)
			living++
	var/cooldown_time = 500+(250*(living))
	addtimer(CALLBACK(src, .proc/cooldown_refresh), cooldown_time, TIMER_UNIQUE)


/obj/item/weapon/pen/gang/proc/cooldown_refresh(datum/gang/gang)
	cooldown = FALSE
	icon_state = "pen"
	var/mob/M = get(src, /mob)
	to_chat(M, "<span class='notice'>[bicon(src)] [src][(src.loc == M)?(""):(" in your [src.loc]")] vibrates softly. It is ready to be used again.</span>")

