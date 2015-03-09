
/mob/living/carbon/alien/larva/verb/hide()
	set name = "Hide"
	set desc = "Allows you to hide beneath tables or items laid on the ground. Toggle."
	set category = "Alien"

	if(stat != CONSCIOUS)
		return

	if(layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		visible_message("<span class='danger'>[src] scurries to the ground !</span>", "<span class='alien'>You are now hiding.</span>")
	else
		layer = MOB_LAYER
		visible_message("<span class='warning'>[src] slowly peeks up from the ground...</span>", "<span class='alien'>You have stopped hiding.</span>")

/mob/living/carbon/alien/larva/verb/evolve()
	set name = "Evolve"
	set desc = "Evolve into a fully grown Alien."
	set category = "Alien"

	if(stat != CONSCIOUS)
		return

	//Seems about right
	//if(handcuffed || legcuffed)
		//src << "\red You cannot evolve when you are cuffed."

	if(amount_grown >= max_grown)	//TODO ~Carn
		//green is impossible to read, so i made these blue and changed the formatting slightly
		src << {"<span class='notice'><B>You are growing into a beautiful alien! It is time to choose a caste.</B><br>
		There are three castes to choose from:<br>
		<B>Hunters</B> are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves.<br>
		<B>Sentinels</B> are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters.<br>
		<B>Drones</B> are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen."}
		var/alien_caste = alert(src, "Please choose which alien caste you shall evolve to.",,"Hunter","Sentinel","Drone")

		var/mob/living/carbon/alien/humanoid/new_xeno
		switch(alien_caste)
			if("Hunter")
				new_xeno = new /mob/living/carbon/alien/humanoid/hunter(loc)
			if("Sentinel")
				new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(loc)
			if("Drone")
				new_xeno = new /mob/living/carbon/alien/humanoid/drone(loc)
		if(mind)	mind.transfer_to(new_xeno)
		del(src)
		playsound(get_turf(src), 'sound/effects/evolve.ogg', 40, 1)
		return
	else
		src << "<span class='warning'>You are not fully grown yet.</span>"
		return
