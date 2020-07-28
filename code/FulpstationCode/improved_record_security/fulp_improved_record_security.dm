/mob/living/simple_animal/bot/secbot/proc/fulp_threat_assess_carbon_filter(mob/living/carbon/C, judgement_criteria) //We check whether the target is carbon and threat assess appropriately
	if(!C) //Sanity
		return

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		threatlevel = H.assess_threat_fulp(judgement_criteria, src, FALSE, null, weaponcheck=CALLBACK(src, .proc/check_for_weapons))
		return

	threatlevel = C.assess_threat(judgement_criteria, weaponcheck=CALLBACK(src, .proc/check_for_weapons))



/mob/living/simple_animal/bot/secbot/proc/arrest_security_record(mob/living/carbon/C, arrest_type, threat, location)

	if(!C) //Sanity
		return

	if(arrest_cooldown.Find(C)) //Don't arrest people whose names are in the cooldown list
		return

	for(var/obj/machinery/computer/secure_data/sec_comp in GLOB.machines)
		if(sec_comp)
			sec_comp.secbot_entry(C, src, arrest_type, threat, location)
			arrest_cooldown += C
			addtimer(CALLBACK(src, /mob/living/simple_animal/bot/secbot.proc/sec_record_bot_cooldown_end,C), SEC_RECORD_BOT_COOLDOWN)
			return

/mob/living/simple_animal/bot/secbot/proc/sec_record_bot_cooldown_end(mob/living/carbon/C)
	arrest_cooldown -= C //Remove from the cooldown list


/obj/machinery/computer/secure_data/proc/secbot_entry(mob/living/carbon/C, mob/living/simple_animal/bot/secbot/S, arrest_type, threat, location)
	if(!C || !S) //Sanity
		return

	if(!ishuman(C)) //If it's not human, don't bother.
		return

	var/bot_authenticated = "[S.name]"
	var/bot_rank = "Security Robot"
	var/match_found
	var/assignment = "NO ASSIGNMENT"
	var/mob/living/carbon/human/H = C

	if(ishuman(H))
		assignment = H.get_assignment()

	for(var/datum/data/record/R in GLOB.data_core.security)
		if(!R) //Sanity
			return

		if(R.fields["name"] == "[C.name]")
			match_found = TRUE
			active2 = R //We found the record we want
			break

	if(!match_found) //No record match; alert Security.
		playsound(S, 'sound/machines/engine_alert1.ogg', 100, FALSE) //SOUND ALARM!!
		S.speak("<b>WARNING!!</b> No security record found for [arrest_type ? "Detained" : "Arrested"] level [threat] scumbag <b>[C], [assignment]</b> at <b>[location]</b>. Recommend further investigation.", S.radio_channel)
		return

	var/counter = 1
	while(active2.fields[text("com_[]", counter)])
		counter++

	var/t1 = "<b>[bot_authenticated] [arrest_type ? "Detained" : "Arrested"]:</b> [C.name], [assignment] <b>LOCATION:</b> [location]. <BR>\
			<b>STATUS AT TIME OF ARREST:</b> [active2.fields["criminal"]] <b>THREAT LEVEL:</b> [threat].<BR>\
			<b>WEAPON VIOLATION:</b> [S.weapons_violation ? "[S.weapons_violation]" : "N/A"] <BR>\
			<b>SECBOT RETALIATION?</b> [S.harm_violation ? "TRUE" : "FALSE"] <b>ARRESTED FOR NO ID?</b> [S.id_violation ? "TRUE" : "FALSE"]"

	active2.fields[text("com_[]", counter)] = text("<b>Made by [] ([]) on [] [], []</b><BR>[]", bot_authenticated, bot_rank, station_time_timestamp(), time2text(world.realtime, "MMM DD"), GLOB.year_integer+540, t1)

	//RESET VIOLATIONS
	S.weapons_violation = null
	S.harm_violation = null
	S.id_violation = null
	S.record_violation = null

/mob/living/carbon/proc/check_unknown()
	var/obj/item/card/id/idcard = get_idcard(FALSE)
	if( !idcard && name=="Unknown")
		return TRUE

	return FALSE

/mob/living/carbon/proc/check_unauthorized_weapons(datum/callback/weaponcheck=null)
	//Check for weapons
	if(!weaponcheck)
		return FALSE

	var/obj/item/card/id/idcard = get_idcard(FALSE)
	if(!idcard || !(ACCESS_WEAPONS in idcard.access))
		return TRUE

	return FALSE

/obj/machinery/computer/secure_data/proc/check_input_clearance(mob/M, delete = FALSE)
	if(!issilicon(M) && !issiliconoradminghost(M)) //Silicons and AdminGhosts ignore access checks.
		var/obj/item/card/id/I = M.get_idcard(TRUE)
		if(!I)
			return FALSE
		req_access = list(ACCESS_SECURITY, ACCESS_ARMORY)
		if(delete) //Wardens can modify security record entries, but cannot delete them; only HoS, Silicons and Captain can do that.
			req_access = list(ACCESS_SECURITY, ACCESS_ARMORY, ACCESS_KEYCARD_AUTH)
		if(!check_access(I))
			req_access = null
			return FALSE
		req_access = null
	return TRUE

/obj/machinery/computer/secure_data/proc/delete_allrecords_feedback()
	temp = ""
	if(check_input_clearance(usr, TRUE))
		temp += "<h5><b>Are you sure you wish to delete all Security records?</b></h5><br>"
		temp += "<a href='?src=[REF(src)];choice=Purge All Records'>Yes</a><br>"
		temp += "<a href='?src=[REF(src)];choice=Clear Screen'>No</a>"
	else
		temp += "<a href='?src=[REF(src)];choice=Clear Screen'><b>[SEC_RECORD_BAD_CLEARANCE]</b></a>"
	return temp


/obj/machinery/computer/secure_data/proc/delete_record_feedback(type = "Security Portion Only")
	temp = ""
	if(check_input_clearance(usr, TRUE))
		temp = "<h5><b>Are you sure you wish to delete the record ([type])?</b></h5><br>"
		temp += "<a href='?src=[REF(src)];choice=Delete Record ([type]) Execute'>Yes</a><br>"
		temp += "<a href='?src=[REF(src)];choice=Clear Screen'>No</a>"
	else
		temp += "<a href='?src=[REF(src)];choice=Clear Screen'><b>[SEC_RECORD_BAD_CLEARANCE]</b></a>"

	return temp
