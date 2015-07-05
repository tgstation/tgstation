/*
 * Gang Boss Pens
 */
/obj/item/weapon/pen/gang
	origin_tech = "materials=2;syndicate=5"
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
	var/cooldown_time = 300+(900*gang.bosses.len) // 1recruiter=2mins, 2recruiters=3.5mins, 3recruiters=5mins

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


//////////////
// IMPLANTS //
//////////////

/obj/item/weapon/implant/gang
	name = "gang implant"
	desc = "Makes you a gangster or such."
	activated = 0
	var/datum/gang/gang

/obj/item/weapon/implant/gang/New(loc,var/setgang)
	..()
	gang = setgang

/obj/item/weapon/implant/gang/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Criminal Loyalty Implant<BR>
				<b>Life:</b> A few seconds after injection.<BR>
				<b>Important Notes:</b> Illegal<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that change the host's brain to be loyal to a certain organization.<BR>
				<b>Special Features:</b> This device will also emit a small EMP pulse, destroying any other implants within the host's brain.<BR>
				<b>Integrity:</b> Implant's EMP function will destroy itself in the process."}
	return dat

/obj/item/weapon/implant/gang/implanted(mob/target)
	..()
	for(var/obj/item/weapon/implant/I in target)
		if(I != src)
			qdel(I)

	var/success
	if(target.stat != DEAD)
		if(ticker.mode.remove_gangster(target.mind,0,1))
			success = 1

	if(!target.mind)
		return

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.sec_hud_set_implants()
		if(success && ticker.mode.add_gangster(target.mind,gang))
			target.Paralyse(5)
		else
			target.visible_message("<span class='warning'>[target] seems to resist the implant!</span>", "<span class='warning'>You feel the influence of your enemies try to invade your mind!</span>")
	qdel(src)

/obj/item/weapon/implanter/gang/
	name = "implanter-gang"

/obj/item/weapon/implanter/gang/New(loc,var/gang)
	if(!gang)
		qdel(src)
		return
	imp = new /obj/item/weapon/implant/gang(src,gang)
	..()
	update_icon()