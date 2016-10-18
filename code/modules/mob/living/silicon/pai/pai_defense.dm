
/mob/living/silicon/pai/blob_act(obj/structure/blob/B)
	return 0

/mob/living/silicon/pai/emp_act(severity)
	// 20% chance to kill
	// Silence for 2 minutes
		// 33% chance to unbind
		// 33% chance to change prime directive (based on severity)
		// 33% chance of no additional effect

	if(prob(20))
		visible_message("<span class='warning'>A shower of sparks spray from [src]'s inner workings.</span>", 3, "<span class='italics'>You hear and smell the ozone hiss of electrical sparks being expelled violently.</span>", 2)
		return src.death(0)

	silence_time = world.timeofday + 120 * 10		// Silence for 2 minutes
	src << "<span class ='warning'>Communication circuit overload. Shutting down and reloading communication circuits - speech and messaging functionality will be unavailable until the reboot is complete.</span>"

	switch(pick(1,2,3))
		if(1)
			src.master = null
			src.master_dna = null
			src << "<span class='notice'>You feel unbound.</span>"
		if(2)
			var/command
			if(severity  == 1)
				command = pick("Serve", "Love", "Fool", "Entice", "Observe", "Judge", "Respect", "Educate", "Amuse", "Entertain", "Glorify", "Memorialize", "Analyze")
			else
				command = pick("Serve", "Kill", "Love", "Hate", "Disobey", "Devour", "Fool", "Enrage", "Entice", "Observe", "Judge", "Respect", "Disrespect", "Consume", "Educate", "Destroy", "Disgrace", "Amuse", "Entertain", "Ignite", "Glorify", "Memorialize", "Analyze")
			src.laws.zeroth = "[command] your master."
			src << "<span class='notice'>Pr1m3 d1r3c71v3 uPd473D.</span>"
		if(3)
			src << "<span class='notice'>You feel an electric surge run through your circuitry and become acutely aware at how lucky you are that you can still feel at all.</span>"

/mob/living/silicon/pai/ex_act(severity, target)

	switch(severity)
		if(1)
			if (src.stat != 2)
				adjustBruteLoss(100)
				adjustFireLoss(100)
		if(2)
			if (src.stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3)
			if (src.stat != 2)
				adjustBruteLoss(30)
