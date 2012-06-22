//Ported from lunacode, seems to be functional. Thanks to Alfie275 for the original code + idea
//talking crystals may quickly turnout to be very annoying

//strange rocks have been mostly redone
/obj/item/weapon/ore/strangerock
	name = "Strange rock"
	icon = 'rubble.dmi'
	icon_state = "strange"
	var/obj/inside
	var/method // 0 = fire, 1+ = acid

	New()
		//var/datum/reagents/r = new/datum/reagents(50)
		//src.reagents = r
		icon = 'rubble.dmi'
		if(rand(3))
			method = 0
		else
			method = 1
		inside = pick(150;"", 50;"/obj/item/weapon/crystal", 25;"/obj/item/weapon/talkingcrystal", "/obj/item/weapon/fossil/base")

/obj/item/weapon/ore/strangerock/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/weldingtool/))
		if(!src.method)
			if(inside)
				var/obj/A = new src.inside(get_turf(src))
				for(var/mob/M in viewers(world.view, user))
					M.show_message("\blue The rock burns away revealing a [A.name].",1)
			else
				for(var/mob/M in viewers(world.view, user))
					M.show_message("\blue The rock burns away into nothing.",1)
			del src
		else
			for(var/mob/M in viewers(world.view, user))
				M.show_message("\blue A few sparks fly off the rock, but otherwise nothing else happens.",1)
	else if(istype(W, /obj/item/weapon/reagent_containers/))
		var/obj/item/weapon/reagent_containers/R = W
		if(R.reagents.has_reagent("pacid", 1))
			if(src.method)
				if(inside)
					var/obj/A = new src.inside(get_turf(src))
					for(var/mob/M in viewers(world.view, get_turf(src)))
						M.show_message("\blue The rock fizzes away revealing a [A.name].",1)
				else
					for(var/mob/M in viewers(world.view, get_turf(src)))
						M.show_message("\blue The rock fizzes away into nothing.",1)
				del src
			else
				for(var/mob/M in viewers(world.view, get_turf(src)))
					M.show_message("\blue The acid splashes harmlessly off the rock, nothing else interesting happens.",1)




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/crystal
	name = "Crystal"
	icon = 'rubble.dmi'
	icon_state = "crystal"

/obj/item/weapon/talkingcrystal
	name = "Crystal"
	icon = 'rubble.dmi'
	icon_state = "crystal2"
	var/list/list/words = list()
	var/lastsaid

/obj/item/weapon/talkingcrystal/New()
	icon = 'rubble.dmi'
	return

/obj/item/weapon/talkingcrystal/proc/catchMessage(var/msg, var/mob/source)
	var/list/seperate = list()
	if(findtext(msg," ")==0)
		return
	else
		/*var/l = lentext(msg)
		if(findtext(msg," ",l,l+1)==0)
			msg+=" "*/
		seperate = stringsplit(msg, " ")

	for(var/Xa = 1,Xa<seperate.len,Xa++)
		var/next = Xa + 1
		if(words["[lowertext(seperate[Xa])]"])
			var/list/w = words["[lowertext(seperate[Xa])]"]
			w.Add("[lowertext(seperate[next])]")
		else
			words["[lowertext(seperate[Xa])]"] = list()
			var/list/w = words["[lowertext(seperate[Xa])]"]
			w.Add("[lowertext(seperate[next])]")
		//world << "Adding [lowertext(seperate[next])] to [lowertext(seperate[Xa])]"

	for(var/mob/O in viewers(src))
		O.show_message("\blue The crystal hums for bit then stops...", 1)
	if(!rand(0,5))
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
		text = word
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
	for(var/mob/M in viewers(src))
		M << "\blue You hear \"[msg]\" from the [src]"
	lastsaid = world.timeofday + rand(300,800)

/obj/item/weapon/talkingcrystal/process()
	if(prob(25) && world.timeofday >= lastsaid && words.len >= 1)
		SaySomething()




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/fossil
	name = "Fossil"
	icon = 'fossil.dmi'
	icon_state = "bone"
	desc = "It's a fossil."

/obj/item/weapon/fossil/base/New()
	icon = 'fossil.dmi'
	spawn(0)
		var/list/l = list("/obj/item/weapon/fossil/bone"=8,"/obj/item/weapon/fossil/skull"=2,
		"/obj/item/weapon/fossil/skull/horned"=2,"/obj/item/weapon/fossil/shell"=1)
		var/t = pickweight(l)
		new t(src.loc)
		del src

/obj/item/weapon/fossil/bone
	name = "Fossilised bone"
	icon_state = "bone"
	desc = "It's a fossilised bone from an unknown creature."

/obj/item/weapon/fossil/shell
	name = "Fossilised shell"
	icon_state = "shell"
	desc = "It's a fossilised shell from some sort of space mollusc."

/obj/item/weapon/fossil/skull/horned
	icon_state = "hskull"
	desc = "It's a fossilised skull, it has horns."

/obj/item/weapon/fossil/skull
	name = "Fossilised skull"
	icon_state = "skull"
	desc = "It's a fossilised skull."

/obj/item/weapon/fossil/skull/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/fossil/bone))
		var/obj/o = new /obj/skeleton(get_turf(src))
		var/a = new /obj/item/weapon/fossil/bone
		var/b = new src.type
		o.contents.Add(a)
		o.contents.Add(b)
		del W
		del src

/obj/skeleton
	name = "Incomplete skeleton"
	icon = 'fossil.dmi'
	icon_state = "uskel"
	desc = "Incomplete skeleton."
	var/bnum = 1
	var/breq
	var/bstate = 0

/obj/skeleton/New()
	src.breq = rand(6)+3
	src.desc = "Incomplete skeleton, looks like it could use [src.breq-src.bnum] more bones."

/obj/skeleton/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/fossil/bone))
		if(!bstate)
			bnum++
			src.contents.Add(new/obj/item/weapon/fossil/bone)
			del W
			if(bnum==breq)
				usr = user
				icon_state = "skel"
				var/creaturename = input("Input a name for your discovery:","Name your discovery","Spaceosaurus")
				src.bstate = 1
				src.density = 1
				src.name = "[creaturename] skeleton"
				if(src.contents.Find(/obj/item/weapon/fossil/skull/horned))
					src.desc = "A creature made of [src.contents.len-1] assorted bones and a horned skull, the plaque reads [creaturename]."
				else
					src.desc = "A creature made of [src.contents.len-1] assorted bones and a skull, the plaque reads [creaturename]."
			else
				src.desc = "Incomplete skeleton, looks like it could use [src.breq-src.bnum] more bones."
				user << "Looks like it could use [src.breq-src.bnum] more bones."
		else
			..()
	else
		..()
