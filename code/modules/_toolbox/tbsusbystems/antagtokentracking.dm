GLOBAL_LIST_EMPTY(memorized_restricted_jobs)

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
	var/list/token_role_min_players = list("changeling" = 15)

/datum/controller/subsystem/antagtokens/Initialize(start_timeofday)
	var/datum/game_mode/traitor/T = new()
	GLOB.memorized_restricted_jobs = T.protected_jobs.Copy()
	qdel(T)
	//seeing who used an antag token when the server crashed, if it crashed.
	var/savefile/S = new /savefile(ANTAGTOKENMINUTESPATH)
	if(S)
		var/list/uncanceled_antag_tokens
		S["activated_tokens"] >> uncanceled_antag_tokens
		if(istype(uncanceled_antag_tokens) && uncanceled_antag_tokens.len)
			var/savefile/TS = new /savefile(GLOB.antagtokenpath)
			if(TS)
				for(var/t in uncanceled_antag_tokens)
					if(istext(t))
						var/tokens
						TS["[t]"] >> tokens
						if(!isnum(tokens))
							tokens = 0
						tokens++
						TS["[t]"] << tokens
	wipe_cached_tokens(S)
	merge_antag_tokens()
	. = ..()

//created because we had to change hosts for a while. This allows us to merge a different antag token file in with the current one.
/datum/controller/subsystem/antagtokens/proc/merge_antag_tokens()
	if(fexists("data/other_saves/mergable_antagtokens.sav"))
		var/savefile/S = new /savefile(GLOB.antagtokenpath)
		var/savefile/S2 = new /savefile("data/other_saves/mergable_antagtokens.sav")
		if(S && S2 && istype(S2.dir,/list))
			for(var/v in S2.dir)
				var/newtokens = 0
				S2["[v]"] >> newtokens
				if(isnum(newtokens) && newtokens > 0)
					var/existingtokens = 0
					S["[v]"] >> existingtokens
					if(isnum(existingtokens))
						existingtokens = min(existingtokens+newtokens,MAXANTAGTOKENS)
						S["[v]"] << existingtokens
		fdel("data/other_saves/mergable_antagtokens.sav")

/datum/controller/subsystem/antagtokens/proc/wipe_cached_tokens(savefile/S)
	if(!S)
		S = new /savefile(ANTAGTOKENMINUTESPATH)
	if(S)
		S["activated_tokens"] << list()

/datum/controller/subsystem/antagtokens/proc/cache_a_token(ckey)
	if(!ckey || !istext(ckey))
		return
	var/savefile/S = new /savefile(ANTAGTOKENMINUTESPATH)
	if(S)
		var/list/uncanceled_antag_tokens
		S["activated_tokens"] >> uncanceled_antag_tokens
		if(istype(uncanceled_antag_tokens) && !(ckey in uncanceled_antag_tokens))
			uncanceled_antag_tokens += ckey
			S["activated_tokens"] << uncanceled_antag_tokens

/datum/controller/subsystem/antagtokens/proc/remove_unavailable_token_roles(list/choices)
	if(istype(choices,/list))
		for(var/t in choices)
			var/minplayers
			if(t in token_role_min_players)
				minplayers = token_role_min_players[t]
			var/num_players = GLOB.clients.len
			if((minplayers && isnum(minplayers)) && (minplayers > num_players))
				choices -= t
	else
		choices = list()
	return choices

/datum/controller/subsystem/antagtokens/fire(resumed)
	if(!last_check)
		last_check = world.time
	var/savefile/Sminutes = new /savefile(ANTAGTOKENMINUTESPATH)
	if(!istype(minutes_tracked,/list))
		if(Sminutes)
			Sminutes["minutes_tracked"] >> minutes_tracked
		if(!istype(minutes_tracked,/list))
			minutes_tracked = list()
	if(istype(minutes_tracked,/list) && last_check+(tick_delay*10) <= world.time)
		last_check = world.time
		var/savefile/S = new /savefile(GLOB.antagtokenpath)
		for(var/client/C in GLOB.clients)
			if(is_special_character(C.mob)) //antags dont get counted
				continue
			if(IsGuestKey(C.key)) //guests dont get counted.
				continue
			if(C.is_afk(300))
				continue
			if(!isliving(C.mob) && !isobserver(C.mob))//no sitting in the lobby for antag tokens.
				continue
			if(isobserver(C.mob))
				var/mob/dead/observer/O = C.mob
				if(O.mind && O.mind.assigned_role == "Space Jesus") //no antag tokens for afk admins as space jesus
					continue
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
			//security gets double fucking tokens
			if((C.mob.mind && C.mob.mind.assigned_role && C.mob.mind.assigned_role in GLOB.memorized_restricted_jobs)||(check_perseus(C.mob)))
				currentminutes++
			if(currentminutes >= MINUTESFORANTAGTOKEN)
				var/tokens = 0
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
		if(Sminutes)
			Sminutes["minutes_tracked"] << minutes_tracked

