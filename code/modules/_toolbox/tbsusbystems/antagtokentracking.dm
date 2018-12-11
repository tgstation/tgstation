//******************************************************************
//This subsystem rewards players with antag tokens for hours played.
//******************************************************************

#define ANTAGTOKENMINUTESPATH "data/other_saves/antagtokensminutes.sav"
#define MINUTESFORANTAGTOKEN 240 //Played time in minutes required to be awarded an antag token. 4 hours for now
#define MAXANTAGTOKENS 3 //Maximum number of antag tokens

SUBSYSTEM_DEF(antagtokens)
	name = "Antag Tokens"
	var/tick_delay = 60 //seconds between checks
	var/last_check = 0 //world.time of last check
	var/list/afk_locs = list( //Paths that count you as afk if you are inside of one these.
		/obj/structure/closet,
		/obj/machinery/disposal)
	var/list/minutes_tracked

/datum/controller/subsystem/antagtokens/fire(resumed = 0)
	if(!last_check)
		last_check = world.time
	if(!istype(minutes_tracked,/list))
		var/savefile/S = new /savefile(ANTAGTOKENMINUTESPATH)
		if(S)
			S["minutes_tracked"] >> minutes_tracked
		if(!istype(minutes_tracked,/list))
			minutes_tracked = list()
	if(istype(minutes_tracked,/list) && last_check+(tick_delay*10) <= world.time)
		last_check = world.time
		for(var/client/C in GLOB.clients)
			if(IsGuestKey(C.key)) //guests dont get counted.
				continue
			if(C.is_afk())
				continue
			if(!isliving(C.mob) && !isobserver(C.mob))//no sitting in the lobby for antag tokens.
				continue
			if(isobserver(C.mob))
				var/mob/dead/observer/O = C.mob
				if(O.started_as_observer) //Observers are not given antag tokens.
					continue
			else
				if(C.mob.stat != DEAD)
					if(!C.mob.loc)
						continue
					var/inafkloc = 0
					for(var/t in afk_locs)
						if(istype(C.mob.loc,t))
							inafkloc = 1
							break
					if(inafkloc)
						continue
			var/currentminutes = 0
			if(minutes_tracked[C.ckey] && isnum(minutes_tracked[C.ckey]))
				currentminutes = minutes_tracked[C.ckey]
			currentminutes++
			if(currentminutes >= MINUTESFORANTAGTOKEN)
				var/tokens = 0
				var/savefile/S = new /savefile(GLOB.antagtokenpath)
				if(S)
					S["[C.ckey]"] >> tokens
					if(!isnum(tokens) || tokens < 1)
						tokens = 0
					if(tokens < MAXANTAGTOKENS)
						tokens++
						S["[C.ckey]"] << tokens
						to_chat(C,"<font color='blue'><B>You have been awarded ONE antag token for [round(MINUTESFORANTAGTOKEN/60,)] hours of play.</B></font>")
					else
						to_chat(C,"<font color='black'>You have accumulated [round(MINUTESFORANTAGTOKEN/60,)] hours of play time, however you are at a maximum of [MAXANTAGTOKENS] antag tokens and can not be awarded any more.</font>")
				currentminutes = 0
			minutes_tracked[C.ckey] = currentminutes
		var/savefile/S = new /savefile(ANTAGTOKENMINUTESPATH)
		if(S)
			S["minutes_tracked"] << minutes_tracked

