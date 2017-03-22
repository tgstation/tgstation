/obj/item/weapon/implant/gang
	name = "gang implant"
	desc = "Makes you a gangster or such."
	activated = 0
	origin_tech = "materials=2;biotech=4;programming=4;syndicate=3"
	var/datum/gang/gang

/obj/item/weapon/implant/gang/New(loc,var/setgang)
	..()
	gang = setgang

/obj/item/weapon/implant/gang/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Criminal brainwash implant<BR>
				<b>Life:</b> A few seconds after injection.<BR>
				<b>Important Notes:</b> Illegal<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that change the host's brain to be loyal to a certain organization.<BR>
				<b>Special Features:</b> This device will also emit a small EMP pulse, destroying any other implants within the host's brain.<BR>
				<b>Integrity:</b> Implant's EMP function will destroy itself in the process."}
	return dat

/obj/item/weapon/implant/gang/implant(mob/living/target, mob/user, silent = 0)
	if(..())
		for(var/obj/item/weapon/implant/I in target.implants)
			if(I != src)
				qdel(I)

		if(!target.mind || target.stat == DEAD)
			return 0

		var/success
		if(target.mind in SSticker.mode.get_gangsters())
			if(SSticker.mode.remove_gangster(target.mind,0,1))
				success = 1	//Was not a gang boss, convert as usual
		else
			success = 1

		if(ishuman(target))
			if(!success)
				target.visible_message("<span class='warning'>[target] seems to resist the implant!</span>", "<span class='warning'>You feel the influence of your enemies try to invade your mind!</span>")

		qdel(src)
		return 0

/obj/item/weapon/implanter/gang
	name = "implanter (gang)"

/obj/item/weapon/implanter/gang/New(loc, gang)
	if(!gang)
		qdel(src)
		return
	imp = new /obj/item/weapon/implant/gang(src,gang)
	..()
