/obj/item/weapon/implant/mindslave
	name = "mindslave implant"
	desc = "Now YOU too can have your very own mindslave! Pop this implant into anybody and they'll obey any command you give for around 15 to 20 minutes."
	origin_tech = "materials=2;biotech=4;programming=4"
	activated = 0
	var/permanent = FALSE
	var/time = 10200 // 1020 seconds aka 17 mins
	var/timerid
	var/datum/objective/protect/protect_objective

/obj/item/weapon/implant/mindslave/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Syndicate Mindslave implant MK1<BR>
				<b>Life:</b> Varies between 15 and 20 minutes.<BR>
				<b>Important Notes:</b> Personnel injected with this device become loyal to the user and will obey any command given for a limited time.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Allows user to command anyone implanted to do whatever they want.<BR>
				<b>Special Features:</b> Person with implant MUST obey any order you give. <BR>
				<b>Integrity:</b> Implant will last around 15 and 20 minutes."}
	return dat

/obj/item/weapon/implant/mindslave/implant(mob/target,mob/user,silent=0)
	if(target.mind)
		if(target == user)
			to_chat(target,"<span class='notice'>You can't implant yourself!</span>")
			return 0
		if(target.isloyal())
			to_chat(target,"<span class='danger'>Your loyalty implant rejects [user]'s mindslave!</span>")
			to_chat(user,"<span class='danger'>[target] somehow rejects the mindslave implant!</span>")
			return 0
		if(..())
			to_chat(target,"<span class='notice'>You feel a surge of loyalty towards [user].</span>")
			to_chat(target,"<span class='userdanger'> You MUST obey any command given to you by your master (that doesn't violate any rules). You are an antag while mindslaved.</span>")
			to_chat(target,"<span class='danger'>You CANNOT harm your master. Check your memory (with the notes verb) if you forget who your master is.</span>")
			if(!permanent)
				timerid = addtimer(CALLBACK(src, .proc/remove_mindslave), time, TIMER_STOPPABLE)
			if(!target.mind.special_role)
				target.mind.special_role = "Mindslave"
				SSticker.mode.traitors |= target.mind
			protect_objective = new /datum/objective/protect
			protect_objective.owner = target.mind
			protect_objective.target = user.mind
			protect_objective.explanation_text = "Protect [user], your mindslave master. Obey any command given by them."
			target.mind.objectives += protect_objective
			message_admins("[user]/([user.ckey]) made a mindslave out of [target]/([target.ckey]).")
			return 1
	to_chat(user,"<span class='notice'>[target] has no mind!</span>")
	return 0

/obj/item/weapon/implant/mindslave/removed(mob/source)
	deltimer(timerid)
	remove_mindslave()
	..()

/obj/item/weapon/implant/mindslave/Destroy()
	deltimer(timerid)
	remove_mindslave()
	..()

/obj/item/weapon/implant/mindslave/greater
	name = "greater mindslave implant"
	desc = "Like the normal mindslave implant, but this one lasts forever."
	permanent = TRUE

/obj/item/weapon/implant/mindslave/greater/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Syndicate Mindslave implant MK2<BR>
				<b>Life:</b> Permanent.<BR>
				<b>Important Notes:</b> Personnel injected with this device become loyal to the user and will obey any command given for a limited time.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Allows user to command anyone implanted to do whatever they want.<BR>
				<b>Special Features:</b> Person with implant MUST obey any order you give. <BR>
				<b>Integrity:</b> Implant will last forever."}
	return dat

/obj/item/weapon/implant/mindslave/proc/remove_mindslave()
	if(imp_in)
		if(imp_in.mind.special_role == "Mindslave")
			imp_in.mind.special_role = ""
			SSticker.mode.traitors -= imp_in.mind
		to_chat(imp_in,"<span class='userdanger'>You feel your free will come back to you! You no longer have to obey your master!</span>")
		to_chat(imp_in,"<span class='userdanger'>If you were not an antagonist BEFORE being mindslave, then you no longer are one.</span>")
		protect_objective.owner.objectives -= protect_objective
		qdel(protect_objective)
		message_admins("[imp_in]/([imp_in.ckey]) is no longer a mindslave.")

/obj/item/weapon/implanter/mindslave
	name = "implanter (mindslave)"
	imp_type = /obj/item/weapon/implant/mindslave

/obj/item/weapon/implanter/mindslave/greater
	name = "implanter (greater mindslave)"
	imp_type = /obj/item/weapon/implant/mindslave/greater