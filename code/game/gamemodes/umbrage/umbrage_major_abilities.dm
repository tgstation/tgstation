/datum/action/innate/umbrage/tutorial
	name = "Tutorial"
	desc = "Need more information on being an umbrage? This in-game tutorial can help you with any questions."
	button_icon_state = "umbrage_tutorial"
	check_flags = 0
	psi_cost = 0

/datum/action/innate/umbrage/tutorial/Activate()
	switch(alert(usr, "Basic or in-depth tutorial?", "Umbrage Tutorial", "Basic", "Advanced", "tl;dr"))
		if("Basic")
			//basic_tutorial(usr)
		if("Advanced")
			//advanced_tutorial(usr)
		if("tl;dr")
			usr << "<span class='warning'>Read the tutorial, jackass.</span>"

#Do the tutorials at some point

/datum/action/innate/umbrage/divulge
	name = "Divulge"
	desc = "Cast off your human disguise and become a proper umbrage. This takes time and renders you vulnerable during the process."
	button_icon_state = "umbrage_divulge"
	check_flags = AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS

/datum/action/innate/umbrage/IsAvailable()
	if(active)
		return
	return ..()

/datum/action/innate/umbrage/Activate()
	active = 1
	spawn(600) //1-minute cooldown on all attempts, regardless of success or failure
		active = 0
	var/mob/living/carbon/human/user = usr
	user.visible_message("<span class='warning'>[user] begins to chant and wave their arms!</span>", "<span class='notice'>You begin erecting a psychic barrier around yourself...</span>")
	if(!do_after(user, 30, target = user))
		return
	user.visible_message("<span class='warning'>A vortex of violet energies form around [user]!</span>", "<span class='notice'>Your barrier will keep you shielded... to a degree.</span>")
	user.visible_message("<span class='danger'>[user] slowly rises into the air, their belongings falling away, and sings a haunting song...</span>", \
						"<span class='boldnotice'>You begin the removal of your human disguise. You will be completely vulnerable during this time.</span>")
	for(var/obj/item/I in user)
		if(!I.flags & NODROP)
			user.unEquip(I)
	user.underwear = "Nude"
	user.undershirt = "Nude"
	user.socks = "Nude"
	for(var/stage = 1, stage <= 3, stage++)
		switch(stage)

