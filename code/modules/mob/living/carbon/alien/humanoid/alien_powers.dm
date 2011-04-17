/*NOTES:
These are general powers. Specific powers are stored under the appropriate alien creature type.
*/

/*Alien spit now works like a taser shot. It won't home in on the target but will act the same once it does hit.
Doesn't work on other aliens/AI.*/

/mob/living/carbon/alien/humanoid/verb/plant()
	set name = "Plant Weeds (100)"
	set desc = "Plants some alien weeds"
	set category = "Alien"

	if(src.stat)
		src << "\green You must be conscious to do this."
		return
	if(!isturf(src.loc) || istype(src.loc, /turf/space))
		src << "\green Bad place for garden!"
		return
	if(src.toxloss < 100)
		src << "\green Not enough plasma stored."
		return

	src.toxloss -= 100
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\green <B>[src] has planted some alien weeds!</B>"), 1)
	var/obj/alien/weeds/W = new (src.loc)
	W.Life()
	return

/mob/living/carbon/alien/humanoid/verb/call_to()
	set name = "Call facehuggers (5)"
	set desc = "Makes all nearby facehuggers follow you"
	set category = "Alien"

	if(src.stat)
		src << "\green You must be conscious to do this."
		return

	if(src.toxloss >= 5)
		src.toxloss -= 5
		for(var/obj/alien/facehugger/F in range(8,src))
			F.call_to(src)
		emote("roar")
	else
		src << "\green Not enough plasma stored."
	return

/mob/living/carbon/alien/humanoid/verb/whisp(mob/M as mob in oview())
	set name = "Whisper (10)"
	set desc = "Whisper to someone"
	set category = "Alien"

	if(src.stat)
		src << "\green You must be conscious to do this."
		return

	var/msg = sanitize(input("Message:", "Alien Whisper") as text|null)
	if (!msg)
		return

	if(src.toxloss >= 10)
		src.toxloss -= 10
		log_say("AlienWhisper: [key_name(src)]->[M.key] : [msg]")

		M << "\green You hear a strange, alien voice in your head... \italic [msg]"
		src << {"\green You said: "[msg]" to [M]"}
	else
		src << "\green Not enough plasma stored."
	return

/mob/living/carbon/alien/humanoid/verb/transfer_plasma(mob/living/carbon/alien/M as mob in oview())
	set name = "Transfer Plasma"
	set desc = "Transfer Plasma to another alien"
	set category = "Alien"

	if(!isalien(M))
		return

	if(src.stat)
		src << "\green You must be conscious to do this."
		return

	if(!src.toxloss)
		src << "\green You don't have any plasma."
		return

	var/amount = input("Amount:", "Transfer Plasma to [M]") as num

	if (!amount)
		return

	if (get_dist(src,M) <= 1)
		if(src.toxloss >= amount)
			M.toxloss += amount
			src.toxloss -= amount
		else
			src << "\green Not enough plasma."
			return

		M << "\green [src] has transfered [amount] plasma to you."
		src << {"\green You have trasferred [amount] plasma to [M]"}

	else
		src << "\green You need to be closer."
	return


/*Xenos now have a proc and a verb for drenching stuff in acid. I couldn't get them to work right when combined so this was the next best solution.
The first proc defines the acid throw function while the other two work in the game itself. Probably a good idea to revise this later.
I kind of like the right click only--the window version can get a little confusing. Perhaps something telling the alien they need to right click?
/N*/
/obj/proc/acid()
	usr.toxloss -= 200
	var/obj/alien/acid/A = new(src.loc)
	A.target = src
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\green <B>[src] vomits globs of vile stuff all over [src]!</B>"), 1)
	A.tick()

/mob/living/carbon/alien/humanoid/proc/corrode_target() //Aliens only see items on the list of objects that they can actually spit on./N
	set name = "Spit Corrosive Acid (200)"
	set desc = "Drench an object in acid, destroying it over time."
	set category = "Alien"

	var/obj/A
	if(src.stat)
		src << "\green You must be conscious to do this."
		return
	var/list/xeno_target
	xeno_target = list("ABORT COMMAND")
	for(var/obj/O in view(1))
		if(!O.unacidable)
			xeno_target.Add(O)
	A = input("Corrode which target?", "Targets", A) in xeno_target
	if(A == "ABORT COMMAND")
		return
	if(src.toxloss < 200)
		src << "\green Not enough plasma."
		return
	if(A in view(1))//Another check to see if the item is in range. So the alien does not run off with the window open.
		A.acid()
	else
		src << "\green Target is too far away."
		return

/mob/living/carbon/alien/humanoid/verb/corrode(obj/O as anything in oview(1)) //If they right click to corrode, an error will flash if its an invalid target./N
	set name = "Corrode with Acid (200)"
	set desc = "Drench an object in acid, destroying it over time."
	set category = "Alien"

	if(!istype(O, /obj))
		return
	if(src.stat)
		src << "\green You must be conscious to do this."
		return
	if(src.toxloss < 200)
		src << "\green Not enough plasma."
		return
	if(O.unacidable) //So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
		src << "\green Cannot destroy this object."
		return
	else
		O.acid()

/mob/living/carbon/alien/humanoid/verb/ventcrawl() // -- TLE
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and appear at a random one"
	set category = "Alien"
//	if(!istype(V,/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent))
//		return

	if(src.stat)
		src << "\green You must be conscious to do this."
		return
	var/vent_found = 0
	for(var/obj/machinery/atmospherics/unary/vent_pump/v in range(1,src))
		if(!v.welded)
			vent_found = v

	if(!vent_found)
		src << "\green You must be standing on or beside an open air vent to enter it."
		return
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
		if(temp_vent.loc == src.loc)
			continue
		if(temp_vent.welded)
			continue
		vents.Add(temp_vent)
	var/list/choices = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/vent in vents)
		if(vent.loc.z != src.loc.z)
			continue
		if(vent.welded)
			continue
		var/atom/a = get_turf_loc(vent)
		choices.Add(a.loc)
	var/turf/startloc = src.loc
	var/obj/selection = input("Select a destination.", "Duct System") in choices
	var/selection_position = choices.Find(selection)
	if(src.loc != startloc)
		src << "\green You need to remain still while entering a vent."
		return
	var/obj/machinery/atmospherics/unary/vent_pump/target_vent = vents[selection_position]
	if(target_vent)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<B>[src] scrambles into the ventillation ducts!</B>"), 1)
		var/list/huggers = list()
		for(var/obj/alien/facehugger/F in view(3, src))
			if(istype(F, /obj/alien/facehugger))
				huggers.Add(F)

		src.loc = vent_found
		for(var/obj/alien/facehugger/F in huggers)
			F.loc = vent_found
		var/travel_time = get_dist(src.loc, target_vent.loc)

		spawn(round(travel_time/2))//give sound warning to anyone near the target vent
			if(!target_vent.welded)
				for(var/mob/O in hearers(target_vent, null))
					O.show_message("You hear something crawling trough the ventilation pipes.")

		spawn(travel_time)
			if(target_vent.welded)//the vent can be welded while alien scrolled through the list or travelled.
				target_vent = vent_found //travel back. No additional time required.
				src << "\red The vent you were heading to appears to be welded."
			src.loc = target_vent.loc
			for(var/obj/alien/facehugger/F in huggers)
				F.loc = src.loc