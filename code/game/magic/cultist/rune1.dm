/obj/rune/proc/teleport(var/key)
/*	for(var/obj/rune/R in world)
		if(R == src)
			continue
		if(R.word3 == key && R.word1 == src.word1 && R.word2 == src.word2)
			usr.say("Sas'so c'arta forbici!")
			for (var/mob/V in viewers(src))
				V.show_message("\red [usr] disappears in a flash of red light!", 3, "\red You hear a sickening crunch and sloshing of viscera.", 2)
			usr.loc = R.loc
			return
	return fizzle()*/

	var/allrunesloc[]
	allrunesloc = new/list()
	var/index = 0
//	var/tempnum = 0
	for(var/obj/rune/R in world)
		if(R == src)
			continue
		if(R.word1 == wordtravel && R.word2 == wordself && R.word3 == key)
			index++
			allrunesloc.len = index
			allrunesloc[index] = R.loc
	if(allrunesloc && index != 0)
		usr.say("Sas'so c'arta forbici!")
		for (var/mob/V in viewers(src))
			V.show_message("\red [usr] disappears in a flash of red light!", 3, "\red You hear a sickening crunch and sloshing of viscera.", 2)
		usr.loc = allrunesloc[rand(1,index)]
		return
	return	fizzle() //Use friggin manuals, Dorf, your list was of zero length.

/*	var/allrunesx[]
	var/allrunesy[]
	var/allrunesz[]
	allrunesx = new/list()
	allrunesy = new/list()
	allrunesz = new/list()
	var/tempnum
	var/count = 0
	for(var/obj/rune/R in world)
		if(R == src)
			continue
		if(R.word3 == key && R.word1 == src.word1 && R.word2 == src.word2)
			count++
			allrunesx.len = count
			allrunesy.len = count
			allrunesz.len = count
			allrunesx[count] = R.x
			allrunesy[count] = R.y
			allrunesz[count] = R.z
	if(allrunesx && allrunesy && allrunesz)
		usr.say("Sas'so c'arta forbici!")
		for (var/mob/V in viewers(src))
			V.show_message("\red [usr] disappears in a flash of red light!", 3, "\red You hear a sickening crunch and sloshing of viscera.", 2)
		tempnum = rand(1,count)
		usr.x = allrunesx[tempnum]
		usr.y = allrunesy[tempnum]
		usr.z = allrunesz[tempnum]
		return
	return	fizzle()*/