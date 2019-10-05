/obj/item/implant/gang
	name = "gang implant"
	desc = "Makes you a gangster or such."
	activated = 0
	var/datum/team/gang/gang

/obj/item/implant/gang/Initialize(loc, setgang)
	.=..()
	gang = setgang

/obj/item/implant/gang/Destroy()
	gang = null
	return ..()

/obj/item/implant/gang/get_data()
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

/obj/item/implant/gang/implant(mob/living/target, mob/user, silent = 0)
	if(!target || !target.mind || target.stat == DEAD)
		return 0
	var/datum/antagonist/gang/G = target.mind.has_antag_datum(/datum/antagonist/gang)
	if(G && G.gang == G)
		return 0 // it's pointless
	if(..())
		for(var/obj/item/implant/I in target.implants)
			if(I != src)
				qdel(I)

		if(ishuman(target))
			var/success
			if(G)
				if(!istype(G, /datum/antagonist/gang/boss))
					success = TRUE	//Was not a gang boss, convert as usual
					target.mind.remove_antag_datum(/datum/antagonist/gang)
			else
				success = TRUE
			if(!success)
				target.visible_message("<span class='warning'>[target] seems to resist the implant!</span>", "<span class='warning'>You feel the influence of your enemies try to invade your mind!</span>")
				return FALSE
		target.mind.add_antag_datum(/datum/antagonist/gang, gang)
		qdel(src)
		return TRUE

/obj/item/implanter/gang
	name = "implanter (gang)"

/obj/item/implanter/gang/Initialize(loc, gang)
	if(!gang)
		qdel(src)
		return
	imp = new /obj/item/implant/gang(src,gang)
	.=..()
