
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// crystals

/obj/item/weapon/crystal
	name = "Crystal"
	icon = 'mining.dmi'
	icon_state = "crystal"

//needs to be solid to have collision, but shouldn't block movement
/*/obj/item/weapon/crystal/bullet_act(var/obj/item/projectile/P)
	if(istype(P,/obj/item/projectile/beam/emitter))
		switch(rand(0,3))
			if(0)
				var/obj/item/projectile/beam/emitter/A = new /obj/item/projectile/beam/emitter( src.loc )
				A.dir = 1
				A.yo = 20
				A.xo = 0
			if(0)
				var/obj/item/projectile/beam/emitter/A = new /obj/item/projectile/beam/emitter( src.loc )
				A.dir = 2
				A.yo = -20
				A.xo = 0
			if(0)
				var/obj/item/projectile/beam/emitter/A = new /obj/item/projectile/beam/emitter( src.loc )
				A.dir = 4
				A.yo = 0
				A.xo = 20
			if(0)
				var/obj/item/projectile/beam/emitter/A = new /obj/item/projectile/beam/emitter( src.loc )
				A.dir = 8
				A.yo = 0
				A.xo = -20
	else
		..()*/

/obj/item/weapon/talkingcrystal
	name = "Crystal"
	icon = 'mining.dmi'
	icon_state = "crystal2"
	var/list/list/words = list()
	var/lastsaid

/obj/item/weapon/talkingcrystal/New()
	spawn(100)
		process()

//needs to be solid to have collision, but shouldn't block movement
/*/obj/item/weapon/talkingcrystal/bullet_act(var/obj/item/projectile/P)
	if(istype(P,/obj/item/projectile/beam))
		switch(rand(0,3))
			if(0)
				var/obj/item/projectile/beam/A = new /obj/item/projectile/beam( src.loc )
				A.dir = pick(alldirs)
				A.yo = 20
				A.xo = 0
			if(0)
				var/obj/item/projectile/beam/A = new /obj/item/projectile/beam( src.loc )
				A.dir = pick(alldirs)
				A.yo = -20
				A.xo = 0
			if(0)
				var/obj/item/projectile/beam/A = new /obj/item/projectile/beam( src.loc )
				A.dir = pick(alldirs)
				A.yo = 0
				A.xo = 20
			if(0)
				var/obj/item/projectile/beam/A = new /obj/item/projectile/beam( src.loc )
				A.dir = pick(alldirs)
				A.yo = 0
				A.xo = -20
		var/word = pick("pain","hurt","masochism","sadist","rage","repressed","ouch","evil","void","kill","destroy")
		SaySomething(word)
	else
		..()*/

/obj/item/weapon/talkingcrystal/proc/catchMessage(var/msg, var/mob/source)
	var/list/seperate = list()
	if(findtext(msg,"(("))
		return
	else if(findtext(msg,"))"))
		return
	else if(findtext(msg," ")==0)
		return
	else
		/*var/l = lentext(msg)
		if(findtext(msg," ",l,l+1)==0)
			msg+=" "*/
		seperate = stringsplit(msg, " ")

	var/addressing_crystal = 0
	if("crystal" in seperate || "gem" in seperate)
		addressing_crystal = 1

	for(var/Xa = 1,Xa<seperate.len,Xa++)
		var/next = Xa + 1
		if(words.len > 20 + rand(10,20))
			words.Remove(words[1])
		if(!words["[lowertext(seperate[Xa])]"])
			words["[lowertext(seperate[Xa])]"] = list()
		var/list/w = words["[lowertext(seperate[Xa])]"]
		if(w)
			w.Add("[lowertext(seperate[next])]")
		//world << "Adding [lowertext(seperate[next])] to [lowertext(seperate[Xa])]"

	for(var/mob/O in viewers(src))
		O.show_message("\blue The crystal hums for bit then stops...", 1)
	if(!rand(0, 5 - addressing_crystal * 3))
		spawn(2) SaySomething(pick(seperate))

/obj/item/weapon/talkingcrystal/proc/debug()
	//set src in view()
	for(var/v in words)
		world << "[uppertext(v)]"
		var/list/d = words["[v]"]
		for(var/X in d)
			world << "[X]"

/obj/item/weapon/talkingcrystal/proc/SaySomething(var/word = null)

	var/msg
	var/limit = rand(max(5,words.len/2))+3
	var/text
	if(!word)
		text = "[pick(words)]"
	else
		text = pick(stringsplit(word, " "))
	if(lentext(text)==1)
		text=uppertext(text)
	else
		var/cap = copytext(text,1,2)
		cap = uppertext(cap)
		cap += copytext(text,2,lentext(text)+1)
		text=cap
	var/q = 0
	msg+=text
	if(msg=="What" | msg == "Who" | msg == "How" | msg == "Why" | msg == "Are")
		q=1

	text=lowertext(text)
	for(var/ya,ya <= limit,ya++)

		if(words.Find("[text]"))
			var/list/w = words["[text]"]
			text=pick(w)
		else
			text = "[pick(words)]"
		msg+=" [text]"
	if(q)
		msg+="?"
	else
		if(rand(0,10))
			msg+="."
		else
			msg+="!"

	var/list/listening = viewers(src)
	for(var/mob/M in world)
		if (!M.client)
			continue //skip monkeys and leavers
		if (istype(M, /mob/new_player))
			continue
		if(M.stat == 2 && M.client.ghost_ears)
			listening|=M

	for(var/mob/M in listening)
		M << "<b>The crystal</b> reverberates, \blue\"[msg]\""
	lastsaid = world.timeofday + rand(300,800)

/obj/item/weapon/talkingcrystal/process()
	if(prob(25) && world.timeofday >= lastsaid && words.len >= 1)
		SaySomething()
	spawn(100)
		process()




//sentient crystals
/mob/sentient_crystal
	name = "Crystal"
	icon = 'mining.dmi'
	icon_state = "crystal2"
	var/list/list/words = list()
	var/lastsaid

/mob/sentient_crystal/proc/catchMessage(var/msg, var/mob/source)
	var/list/seperate = list()
	if(findtext(msg,"(("))
		return
	else if(findtext(msg,"))"))
		return
	else
		/*var/l = lentext(msg)
		if(findtext(msg," ",l,l+1)==0)
			msg+=" "*/
		seperate = stringsplit(msg, " ")

	for(var/Xa = 1,Xa<seperate.len,Xa++)
		var/next = Xa + 1
		if(words.len > 20 + rand(10,20))
			words.Remove(words[1])
		if(!words["[lowertext(seperate[Xa])]"])
			words["[lowertext(seperate[Xa])]"] = list()
		var/list/w = words["[lowertext(seperate[Xa])]"]
		if(w)
			w.Add("[lowertext(seperate[next])]")
		//world << "Adding [lowertext(seperate[next])] to [lowertext(seperate[Xa])]"

	for(var/mob/O in viewers(src))
		O.show_message("\blue The crystal hums for bit then stops...", 1)

/mob/sentient_crystal/Life()