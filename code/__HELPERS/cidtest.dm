

var/global/compid_file


/datum/compid_info
	var/compid = ""
	var/last_seen = 0 //The time this was last spotted
	var/last_ckey = "" //The latest key associated with this ID
	var/times_seen = 0

/proc/initialize_compid_savefile()
	if(!compid_file)
		compid_file = new /savefile("data/compid_file.sav")

	return compid_file

/proc/load_compids(var/ckey)
	var/savefile/SF = initialize_compid_savefile()

	var/path = "/[copytext(ckey, 1, 2)]/[ckey]"
	var/list/datum/compid_info/cid_list = list()

	SF.cd = path
	while (!SF.eof)
		var/datum/compid_info/CI
		SF >> CI
		cid_list += CI

	return cid_list

/proc/save_compids(var/ckey, var/list/datum/compid_info/cid_list)
	var/savefile/SF = initialize_compid_savefile()
	var/path = "/[copytext(ckey, 1, 2)]/[ckey]"

	SF.cd = path
	SF.eof = -1
	for(var/datum/compid_info/CI in cid_list)
		SF << CI

/proc/check_compid_list(var/client/C)
	C.compid_info_list = load_compids(C.ckey)

	var/append_CID = 1

	for(var/datum/compid_info/CI in C.compid_info_list)
		if(CI.compid == C.computer_id) //Seen this computer ID before
			append_CID = 0

			CI.last_seen = world.realtime
			CI.times_seen++
			break

	if(append_CID) //Did not find an entry
		var/datum/compid_info/CI = new
		CI.compid = C.computer_id
		CI.last_seen = world.realtime
		CI.last_ckey = C.ckey
		CI.times_seen = 1

		//Has this computerid changed recently and does it have a habit of changing?
		if(C.compid_info_list.len >= 2) //Do they have more than 2 CID's on file? Weird
			var/today = time2text(world.realtime, "YYYYMMDD")
			var/current_hour = time2text(world.realtime, "hh")
			var/current_minute = time2text(world.realtime, "mm")
			var/hits = 0
			for(var/datum/compid_info/CII in C.compid_info_list)
				if(today == time2text(CII.last_seen, "YYYYMMDD"))
					var/last_seen_hour = time2text(CII.last_seen, "hh")
					var/last_seen_minute = time2text(CII.last_seen, "nn")
					var/time_diff = ( text2num(current_hour) * 60 + text2num(current_minute) ) -  ( text2num(last_seen_hour) * 60 + text2num(last_seen_minute) )

					if(time_diff <= 180 && CI.times_seen < 30)
						//If the ID changed within 3 hours and the ID hasn't been seen several times (unlikely to happen with automatically generated IDs
						hits++
			if(hits)
				var/msg = "'s compID changed [hits] time[hits>1 ? "s" : null] within the last 180 minutes - [C.compid_info_list.len + 1] IDs on file."
				if(hits >= 2) //This person used 3 computers within as many hours
					if(!cid_test) cid_test = list()
					if(!cid_tested) cid_tested = list()
					if(!(C.ckey in cid_test) && !(C.ckey in cid_tested)) //They aren't yet scheduled for a test or they have been tested
						cid_test[C.ckey] = C.computer_id
						cid_tested += C.ckey
						msg += " Executing automatic test."
						spawn(10)
							del(C) //RIP
					message_admins("[key_name_admin(C)][msg]")
					//logTheThing("admin", C, null, msg)

				else
					message_admins("[key_name_admin(C)][msg]")
					log_admin("[key_name(C)][msg]")


				send2irc("CID SCANNER", "(Ip: [C.address]) [msg]")



		//Done with the analysis

		C.compid_info_list += CI
	/* Pointless alert
	if(C.compid_info_list.len > 10) //Holy evasion, Batman!
		message_admins("[key_name(C)] (ID:[C.computer_id]) has been seen having [C.compid_info_list.len] IDs!")
		logTheThing("admin", C, null, "(ID:[C.computer_id]) has been seen having [C.compid_info_list.len] IDs!")
	*/

	save_compids(C.ckey, C.compid_info_list)

var/global/list/cid_test = list()
var/global/list/cid_tested = list()

/proc/do_computerid_test(client/C)
	var/cid = cid_test[C.ckey]
	if(!cid) return //They were not scheduled for testing
	var/is_fucker = cid != C.computer_id //IT CHANGED!!!
	cid_test -= C.ckey

	var/msg = " [is_fucker ? "failed" : "passed"] the automatic cid dll test."

	send2irc("CID SCANNER", "[C.mob.real_name]([C.key]) [msg]")

	message_admins("[key_name(C)][msg]")
	log_admin("[key_name(C)] [msg]")
	if(is_fucker)
		message_admins("[key_name_admin(C)] was automatically banned for using the CID DLL.")
		//var/banData[] = new()
		//banData["ckey"] = C.ckey
		//banData["compID"] = C.computer_id
		//banData["akey"] = "Auto Banner"
		//banData["ip"] = C.address
		//banData["reason"] = "Using a modified dreamseeker client."
		//banData["mins"] = 0
		//addBan(1, banData)
