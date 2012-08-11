//original code and idea from Alfie275 (luna) and ISaidNo (goon) - with thanks




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// samples

/obj/item/weapon/rocksliver
	name = "rock sliver"
	desc = "It looks extremely delicate."
	icon = 'mining.dmi'
	icon_state = "sliver0"	//0-4
	//item_state = "electronic"
	var/source_rock = "/turf/simulated/mineral/archaeo"
	item_state = ""
	var/datum/geosample/geological_data

/obj/item/weapon/rocksliver/New()
	icon_state = "sliver[rand(0,4)]"




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// strange rocks

/obj/item/weapon/ore/strangerock
	var/datum/geosample/geological_data
	var/source_rock = "/turf/simulated/mineral"

/obj/item/weapon/ore/strangerock/New()
	..()
	//var/datum/reagents/r = new/datum/reagents(50)
	//src.reagents = r
	if(rand(3))
		method = 0
	else
		method = 1
	inside = pick(150;"", 50;"/obj/item/weapon/crystal", 25;"/obj/item/weapon/talkingcrystal", "/obj/item/weapon/fossil/base")

/obj/item/weapon/ore/strangerock/bullet_act(var/obj/item/projectile/P)

/obj/item/weapon/ore/strangerock/ex_act(var/severity)
	src.visible_message("The [src] crumbles away, leaving some dust and gravel behind.")

/obj/item/weapon/ore/strangerock/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W,/obj/item/weapon/weldingtool/))
		var/obj/item/weapon/weldingtool/w = W
		if(w.isOn() && (w.get_fuel() > 3))
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
		w.remove_fuel(4)

	else if(istype(W,/obj/item/device/core_sampler/))
		var/obj/item/device/core_sampler/S = W
		if(S.filled_bag)
			user << "\red The core sampler is full!"
		else if(S.num_stored_bags < 1)
			user << "\red The core sampler is out of sample bags!"
		else
			S.filled_bag = new /obj/item/weapon/storage/samplebag(S)
			S.icon_state = "sampler1"

			for(var/i=0, i<7, i++)
				var/obj/item/weapon/rocksliver/R = new /obj/item/weapon/rocksliver(S.filled_bag)
				R.source_rock = src.source_rock
				R.geological_data = src.geological_data
			user << "\blue You take a core sample of the [src]."

/obj/item/weapon/ore/strangerock/acid_act(var/datum/reagent/R)
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
	return 1




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// crystals

/obj/item/weapon/crystal
	name = "Crystal"
	icon = 'mining.dmi'
	icon_state = "crystal"

/obj/item/weapon/crystal/bullet_act(var/obj/item/projectile/P)
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
		..()

/obj/item/weapon/talkingcrystal
	name = "Crystal"
	icon = 'mining.dmi'
	icon_state = "crystal2"
	var/list/list/words = list()
	var/lastsaid

/obj/item/weapon/talkingcrystal/New()
	spawn(100)
		process()

/obj/item/weapon/talkingcrystal/bullet_act(var/obj/item/projectile/P)
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
		..()

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




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// fossils

/obj/item/weapon/fossil
	name = "Fossil"
	icon = 'fossil.dmi'
	icon_state = "bone"
	desc = "It's a fossil."

/obj/item/weapon/fossil/base/New()
	spawn(0)
		var/list/l = list("/obj/item/weapon/fossil/bone"=8,"/obj/item/weapon/fossil/skull"=2,
		"/obj/item/weapon/fossil/skull/horned"=2,"/obj/item/weapon/fossil/shell"=1)
		var/t = pickweight(l)
		new t(src.loc)
		del src

/obj/item/weapon/fossil/bone
	name = "Fossilised bone"
	icon_state = "bone"
	desc = "It's a fossilised bone."

/obj/item/weapon/fossil/shell
	name = "Fossilised shell"
	icon_state = "shell"
	desc = "It's a fossilised shell."

/obj/item/weapon/fossil/skull/horned
	icon_state = "hskull"
	desc = "It's a fossilised, horned skull."

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
	src.desc = "An incomplete skeleton, looks like it could use [src.breq-src.bnum] more bones."

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
