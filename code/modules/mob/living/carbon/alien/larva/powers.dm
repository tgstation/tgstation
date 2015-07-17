/obj/effect/proc_holder/alien/hide
	name = "Hide"
	desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	plasma_cost = 0

	action_icon_state = "alien_hide"

/obj/effect/proc_holder/alien/hide/fire(mob/living/carbon/alien/user)
	if(user.stat != CONSCIOUS)
		return

	if (user.layer != TURF_LAYER+0.2)
		user.layer = TURF_LAYER+0.2
		user.visible_message("<span class='name'>[user] scurries to the ground!</span>", \
						"<span class='noticealien'>You are now hiding.</span>")
	else
		user.layer = MOB_LAYER
		user.visible_message("[user.] slowly peaks up from the ground...", \
					"<span class='noticealien'>You stop hiding.</span>")
	return 1


/obj/effect/proc_holder/alien/larva_evolve
	name = "Evolve"
	desc = "Evolve into a fully grown Alien."
	plasma_cost = 0

	action_icon_state = "alien_evolve_larva"

/obj/effect/proc_holder/alien/larva_evolve/fire(mob/living/carbon/alien/user)
	if(!islarva(user))
		return
	var/mob/living/carbon/alien/larva/L = user

	if(L.stat != CONSCIOUS)
		return
	if(L.handcuffed || L.legcuffed) // Cuffing larvas ? Eh ?
		user << "<span class='danger'>You cannot evolve when you are cuffed.</span>"

	if(L.amount_grown >= L.max_grown)	//TODO ~Carn
		L << "<span class='name'>You are growing into a beautiful alien! It is time to choose a caste.</span>"
		L << "<span class='info'>There are three to choose from:"
		L << "<span class='name'>Hunters</span> <span class='info'>are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves.</span>"
		L << "<span class='name'>Sentinels</span> <span class='info'>are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters.</span>"
		L << "<span class='name'>Drones</span> <span class='info'>are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen.</span>"
		var/alien_caste = alert(L, "Please choose which alien caste you shall belong to.",,"Hunter","Sentinel","Drone")

		var/mob/living/carbon/alien/humanoid/new_xeno
		switch(alien_caste)
			if("Hunter")
				new_xeno = new /mob/living/carbon/alien/humanoid/hunter(L.loc)
			if("Sentinel")
				new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(L.loc)
			if("Drone")
				new_xeno = new /mob/living/carbon/alien/humanoid/drone(L.loc)
		if(L.mind)	L.mind.transfer_to(new_xeno)
		qdel(L)
		return 0
	else
		user << "<span class='danger'>You are not fully grown.</span>"
		return 0