// Inherited

// Except for this, of course.
/mob/living/silicon/robot/mommi/laws_sanity_check()
	if (!laws)
		laws = new mommi_base_law_type

// And this.
/mob/living/silicon/robot/mommi/statelaws() // -- TLE
	var/prefix=";"
	if(src.keeper)
		prefix=":b" // Binary channel.
	src.say(prefix+"Current Active Laws:")
	//src.laws_sanity_check()
	//src.laws.show_laws(world)
	var/number = 1
	sleep(10)
	if (src.laws.zeroth)
		if (src.lawcheck[1] == "Yes") //This line and the similar lines below make sure you don't state a law unless you want to. --NeoFite
			src.say("[prefix]0. [src.laws.zeroth]")
			sleep(10)

	for (var/index = 1, index <= src.laws.ion.len, index++)
		var/law = src.laws.ion[index]
		var/num = ionnum()
		if (length(law) > 0)
			if (src.ioncheck[index] == "Yes")
				src.say("[prefix][num]. [law]")
				sleep(10)

	for (var/index = 1, index <= src.laws.inherent.len, index++)
		var/law = src.laws.inherent[index]

		if (length(law) > 0)
			if (src.lawcheck[index+1] == "Yes")
				src.say("[prefix][number]. [law]")
				sleep(10)
			number++


	for (var/index = 1, index <= src.laws.supplied.len, index++)
		var/law = src.laws.supplied[index]

		if (length(law) > 0)
			if(src.lawcheck.len >= number+1)
				if (src.lawcheck[number+1] == "Yes")
					src.say("[prefix][number]. [law]")
					sleep(10)
				number++

// Disable this.
/mob/living/silicon/robot/mommi/lawsync()
	laws_sanity_check()
	return