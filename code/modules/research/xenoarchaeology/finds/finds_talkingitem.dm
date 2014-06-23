
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Formerly talking crystals - these procs are now modular so that you can make any /obj/item/weapon 'parrot' player speech back to them
// This could be extended to atoms, but it's bad enough as is
// I genuinely tried to Add and Remove them from var and proc lists, but just couldn't get it working

/obj/item/weapon
	var/list/heard_words = list()
	var/lastsaid
	var/listening_to_players = 0
	var/speaking_to_players = 0

/obj/item/weapon/process()
	if(!speaking_to_players)
		processing_objects.Remove(src)
		return
	if(prob(10) && world.timeofday >= lastsaid && heard_words.len >= 1)
		SaySomething()

/obj/item/weapon/proc/catchMessage(var/msg, var/mob/source)
	if(speaking_to_players)
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
			seperate = text2list(msg, " ")

		for(var/Xa = 1,Xa<seperate.len,Xa++)
			var/next = Xa + 1
			if(heard_words.len > 20 + rand(10,20))
				heard_words.Remove(heard_words[1])
			if(!heard_words["[lowertext(seperate[Xa])]"])
				heard_words["[lowertext(seperate[Xa])]"] = list()
			var/list/w = heard_words["[lowertext(seperate[Xa])]"]
			if(w)
				w.Add("[lowertext(seperate[next])]")
			//world << "Adding [lowertext(seperate[next])] to [lowertext(seperate[Xa])]"

		if(!rand(0, 5))
			spawn(2) SaySomething(pick(seperate))
	if(prob(30))
		for(var/mob/O in viewers(src))
			O.show_message("\blue [src] hums for bit then stops...", 1)

/*/obj/item/weapon/talkingcrystal/proc/debug()
	//set src in view()
	for(var/v in heard_words)
		world << "[uppertext(v)]"
		var/list/d = heard_words["[v]"]
		for(var/X in d)
			world << "[X]"*/

/obj/item/weapon/proc/SaySomething(var/word = null)

	var/msg
	var/limit = rand(max(5,heard_words.len/2))+3
	var/text
	if(!word)
		text = "[pick(heard_words)]"
	else
		text = pick(text2list(word, " "))
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

		if(heard_words.Find("[text]"))
			var/list/w = heard_words["[text]"]
			text=pick(w)
		else
			text = "[pick(heard_words)]"
		msg+=" [text]"
	if(q)
		msg+="?"
	else
		if(rand(0,10))
			msg+="."
		else
			msg+="!"

	var/list/listening = viewers(src)
	for(var/mob/M in mob_list)
		if (!M.client)
			continue //skip monkeys and leavers
		if (istype(M, /mob/new_player))
			continue
		if(M.stat == 2 &&  M.client.prefs.toggles & CHAT_GHOSTEARS)
			listening|=M

	for(var/mob/M in listening)
		M << "<b>[src]</b> reverberates, \blue\"[msg]\""
	lastsaid = world.timeofday + rand(300,800)
