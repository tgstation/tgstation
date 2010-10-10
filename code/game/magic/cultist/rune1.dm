/obj/rune/proc/teleport(var/key)
	for(var/obj/rune/R in world)
		if(R == src)
			continue
		if(R.word3 == key && R.word1 == src.word1 && R.word2 == src.word2)
			usr.say("Sas'so c'arta forbici!")
			for (var/mob/V in viewers(src))
				V.show_message("\red [usr] disappears in a flash of red light!", 3, "\red You hear a sickening crunch and sloshing of viscera.", 2)
			usr.loc = R.loc
			return
	return fizzle()

/*	var/allrunes[]
	var/index = 0
	for(var/obj/rune/R in world)
		if(R == src)
			continue
		if(R.word3 == key && R.word1 == src.word1 && R.word2 == src.word2)
			allrunes[index] = R.loc
			index++
	if(allrunes)
		usr.say("Sas'so c'arta forbici!")
		for (var/mob/V in viewers(src))
			V.show_message("\red [usr] disappears in a flash of red light!", 3, "\red You hear a sickening crunch and sloshing of viscera.", 2)
		usr.loc = allrunes[rand(allrunes.len)]
		return
	return	fizzle()*/ //Doesn't work for some raisin

/*	var/list/allrunesx
	var/list/allrunesy
	var/tempnum
	var/count = 0
	for(var/obj/rune/R in world)
		if(R == src)
			continue
		if(R.word3 == key && R.word1 == src.word1 && R.word2 == src.word2)
			allrunesx += R.x
			allrunesy += R.y
			count++
	if(allrunesx && allrunesy)
		usr.say("Sas'so c'arta forbici!")
		for (var/mob/V in viewers(src))
			V.show_message("\red [usr] disappears in a flash of red light!", 3, "\red You hear a sickening crunch and sloshing of viscera.", 2)
		tempnum = rand(1,count)
		usr.x = allrunesx[tempnum]
		usr.y = allrunesy[tempnum]
		return
	return	fizzle()*/