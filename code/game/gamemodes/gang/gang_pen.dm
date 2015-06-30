/*
 * Gang Boss Pens
 */
/obj/item/weapon/pen/gang
	origin_tech = "materials=2;syndicate=5"
	var/cooldown

/obj/item/weapon/pen/gang/attack(mob/living/M, mob/user)
	if(!istype(M))	return
	if(..(M,user,1))
		if(ishuman(M) && ishuman(user) && M.stat != DEAD)
			if(user.mind && ((user.mind in ticker.mode.A_bosses) || (user.mind in ticker.mode.B_bosses)))
				if(cooldown)
					user << "<span class='warning'>[src] needs more time to recharge before it can be used.</span>"
					return
				if(M.client)
					M.mind_initialize()		//give them a mind datum if they don't have one.
					if(user.mind in ticker.mode.A_bosses)
						var/recruitable = ticker.mode.add_gangster(M.mind,"A")
						switch(recruitable)
							if(2)
								M.Paralyse(5)
								cooldown(max(0,ticker.mode.B_gang.len - ticker.mode.A_gang.len))
							if(1)
								user << "<span class='warning'>This mind is resistant to recruitment!</span>"
							else
								user << "<span class='warning'>This mind has already been recruited into a gang!</span>"
					else if(user.mind in ticker.mode.B_bosses)
						var/recruitable = ticker.mode.add_gangster(M.mind,"B")
						switch(recruitable)
							if(2)
								M.Paralyse(5)
								cooldown(max(0,ticker.mode.A_gang.len - ticker.mode.B_gang.len))
							if(1)
								user << "<span class='warning'>This mind is resistant to recruitment!</span>"
							else
								user << "<span class='warning'>This mind has already been recruited into a gang!</span>"

/obj/item/weapon/pen/gang/proc/cooldown(modifier)
	cooldown = 1
	icon_state = "pen_blink"
	spawn(max(50,1800-(modifier*300)))
		cooldown = 0
		icon_state = "pen"
		var/mob/M = get(src, /mob)
		M << "<span class='notice'>\icon[src] [src][(src.loc == M)?(""):(" in your [src.loc]")] vibrates softly.</span>"


//////////////
// IMPLANTS //
//////////////

/obj/item/weapon/implant/gang
	name = "gang implant"
	desc = "Makes you a gangster or such."
	activated = 0
	var/gang

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

	ticker.mode.remove_gangster(target.mind,0,1,1)
	if(ticker.mode.add_gangster(target.mind,gang))
		target.Paralyse(5)
	else
		target.visible_message("<span class='warning'>[target] seems to resist the implant!</span>", "<span class='warning'>You feel the influence of your enemies try to invade your mind!</span>")
	qdel(src)

/obj/item/weapon/implanter/gang/New(loc,var/gang)
	if(!gang)
		qdel(src)
		return
	imp = new /obj/item/weapon/implant/gang(src,gang)
	..()
	update_icon()