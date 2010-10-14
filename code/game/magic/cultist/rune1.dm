/obj/rune/proc/teleport(var/key)
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
		if(istype(src,/obj/rune))
			usr.say("Sas'so c'arta forbici!")
		else
			usr.whisper("Sas'so c'arta forbici!")
		for (var/mob/V in viewers(src))
			V.show_message("\red [usr] disappears in a flash of red light!", 3, "\red You hear a sickening crunch and sloshing of viscera.", 2)
		usr.loc = allrunesloc[rand(1,index)]
		return
	if(istype(src,/obj/rune))
		return	fizzle() //Use friggin manuals, Dorf, your list was of zero length.
	else
		call(/obj/rune/proc/fizzle)()
		return