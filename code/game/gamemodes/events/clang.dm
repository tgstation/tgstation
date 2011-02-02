/*
Immovable rod random event.
The rod will spawn at some location outside the station, and travel in a straight line to the opposite side of the station
Everything solid in the way will be ex_act()'d
In my current plan for it, 'solid' will be defined as anything with density == 1

--NEOFite
*/

/obj/immovablerod
	name = "Immovable Rod"
	desc = "What the fuck is that?"
	icon = 'objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	density = 0

	Bump(atom/clong)
		if (istype(clong, /turf))
			if(clong.density)
				clong.ex_act(2)
				for (var/mob/O in hearers(src, null))
					O.show_message("CLANG", 2)
		if (istype(clong, /obj))
			if(clong.density)
				clong.ex_act(2)
				for (var/mob/O in hearers(src, null))
					O.show_message("CLANG", 2)
		if (istype(clong, /mob))
			if(clong.density || prob(10))
				src.throw_impact(clong)

/proc/immovablerod()

	var/list/liste = list()
	var/list/listw = list()
	var/list/listn = list()
	var/list/lists = list()

	var/obj/start
	var/obj/end

	for (var/obj/landmark/rod in world) //setting up the possible start points
		switch (rod.name)
			if("rod-n")
				listn += rod
			if("rod-s")
				lists += rod
			if("rod-e")
				liste += rod
			if("rod-w")
				listw += rod

	if (!(liste.len && listw.len && listn.len && lists.len)) //cancel the event if not all directions have locations
		log_admin("Immovable rod event failed due to lack of starting points")
		return

	var/pick = pick("north","south","east","west") //Picking which side we start from
	switch(pick)
		if("north")
			start = pick(listn)
			end = pick(lists)
		if("south")
			start = pick(lists)
			end = pick(listn)
		if("east")
			start = pick(liste)
			end = pick(listw)
		if("west")
			start = pick(listw)
			end = pick(liste)

	//rod time!
	var/obj/immovablerod/immrod = new /obj/immovablerod(start.loc)
//	world << "Rod in play, starting at [start.loc.x],[start.loc.y] and going to [end.loc.x],[end.loc.y]"
	while (immrod.loc != end.loc)
		step_towards(immrod, end)
/*		for(var/turf/T in immrod.loc)
			if(T.density)
				T.ex_act(2)
				for (var/mob/O in hearers(immrod, null))
					O.show_message("CLANG", 2)
		for(var/obj/O in immrod.loc)
			if(O.density)
				O.ex_act(2)
				for (var/mob/M in hearers(immrod, null))
					M.show_message("CLANG", 2)
		for(var/mob/living/ouch in immrod.loc)
			if(ouch.density || prob(10))
				immrod.throw_impact(ouch)
				*/
		sleep(1)

	del(immrod)
	sleep(50)
	command_alert("What the fuck was that?!", "General Alert")