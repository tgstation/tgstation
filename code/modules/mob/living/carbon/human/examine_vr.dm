/mob/living/carbon/human/proc/examine_nutrition()
	var/message = ""
	var/nutrition_examine = round(nutrition)
	var/t_He 	= "It" //capitalised for use at the start of each line.
	var/t_His 	= "Its"
	var/t_his 	= "its"
	var/t_is 	= "is"
	var/t_has 	= "has"
	switch(gender)
		if(MALE)
			t_He 	= "He"
			t_his 	= "his"
			t_His 	= "His"
		if(FEMALE)
			t_He 	= "She"
			t_his 	= "her"
			t_His 	= "Her"
		if(PLURAL)
			t_He  	= "They"
			t_his 	= "their"
			t_His 	= "Their"
			t_is	= "are"
			t_has 	= "have"
		if(NEUTER)
			t_He 	= "It"
			t_his 	= "its"
			t_His	= "Its"
	switch(nutrition_examine)
		if(0 to 49)
			message = "<span class='warning'>[t_He] [t_is] starving! You can hear [t_his] stomach snarling from across the room!</span>\n"
		if(50 to 99)
			message = "<span class='warning'>[t_He] [t_is] extremely hungry. A deep growl occasionally rumbles from [t_his] empty stomach.</span>\n"
		if(100 to 499)
			return message //Well that's pretty normal, really.
		if(500 to 864) // Fat.
			message = "[t_He] [t_has] a stuffed belly, bloated fat and round from eating too much.\n"
		if(1200 to 1934) // One person fully digested.
			message = "<span class='warning'>[t_He] [t_is] sporting a large, round, sagging stomach. It's contains at least their body weight worth of glorping slush.</span>\n"
		if(1935 to 3004) // Two people.
			message = "<span class='warning'>[t_He] [t_is] engorged with a huge stomach that sags and wobbles as they move. [t_He] must have consumed at least twice their body weight. It looks incredibly soft.</span>\n"
		if(3005 to 4074) // Three people.
			message = "<span class='warning'>[t_His] stomach is firmly packed with digesting slop. [t_He] must have eaten at least a few times worth their body weight! It looks hard for them to stand, and [t_his] gut jiggles when they move.</span>\n"
		if(4075 to 10000) // Four or more people.
			message = "<span class='warning'>[t_He] [t_is] so absolutely stuffed that you aren't sure how it's possible to move. [t_He] can't seem to swell any bigger. The surface of [t_his] belly looks sorely strained!</span>\n"
	return message