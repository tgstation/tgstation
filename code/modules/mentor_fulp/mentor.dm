GLOBAL_LIST_EMPTY(mentor_datums)
GLOBAL_PROTECT(mentor_datums)

GLOBAL_VAR_INIT(mentor_href_token, GenerateToken())
GLOBAL_PROTECT(mentor_href_token)

/datum/mentors
	var/name = "someone's mentor datum"
	var/client/owner // the actual mentor, client type
	var/target // the mentor's ckey
	var/href_token // href token for mentor commands, uses the same token used by admins.
	var/mob/following

/datum/mentors/New(ckey)
	if(!ckey)
		QDEL_IN(src, 0)
		throw EXCEPTION("Mentor datum created without a ckey")
		return
	target = ckey(ckey)
	name = "[ckey]'s mentor datum"
	href_token = GenerateToken()
	GLOB.mentor_datums[target] = src
	//set the owner var and load commands
	owner = GLOB.directory[ckey]
	if(owner)
		owner.mentor_datum = src
		owner.add_mentor_verbs()
		if(!check_rights_for(owner, R_ADMIN,0)) // don't add admins to mentor list.
			GLOB.mentors += owner

/datum/mentors/proc/CheckMentorHREF(href, href_list)
	var/auth = href_list["mentor_token"]
	. = auth && (auth == href_token || auth == GLOB.mentor_href_token)
	if(.)
		return
	var/msg = !auth ? "no" : "a bad"
	message_admins("[key_name_admin(usr)] clicked an href with [msg] authorization key!")
	if(CONFIG_GET(flag/debug_admin_hrefs))
		message_admins("Debug mode enabled, call not blocked. Please ask your coders to review this round's logs.")
		log_world("UAH: [href]")
		return TRUE
	log_admin_private("[key_name(usr)] clicked an href with [msg] authorization key! [href]")

/proc/RawMentorHrefToken(forceGlobal = FALSE)
	var/tok = GLOB.mentor_href_token
	if(!forceGlobal && usr)
		var/client/C = usr.client
		to_chat(world, C)
		to_chat(world, usr)
		if(!C)
			CRASH("No client for HrefToken()!")
		var/datum/mentors/holder = C.mentor_datum
		if(holder)
			tok = holder.href_token
	return tok

/proc/MentorHrefToken(forceGlobal = FALSE)
	return "mentor_token=[RawMentorHrefToken(forceGlobal)]"

/proc/load_mentors()
	GLOB.mentor_datums.Cut()
	for(var/client/C in GLOB.mentors)
		C.remove_mentor_verbs()
		C.mentor_datum = null
	GLOB.mentors.Cut()
	if(CONFIG_GET(flag/mentor_legacy_system))//legacy
		var/list/lines = world.file2list("config/mentors.txt")
		for(var/line in lines)
			if(!length(line))
				continue
			if(findtextEx(line, "#", 1, 2))
				continue
			new /datum/mentors(line)
	else//Database
		if(!SSdbcore.Connect())
			log_world("Failed to connect to database in load_mentors(). Reverting to legacy system.")
			WRITE_FILE(GLOB.world_game_log, "Failed to connect to database in load_mentors(). Reverting to legacy system.")
			CONFIG_SET(flag/mentor_legacy_system, TRUE)
			load_mentors()
			return
		var/datum/DBQuery/query_load_mentors = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("mentor")]")
		if(!query_load_mentors.Execute())
			qdel(query_load_mentors)
			return
		while(query_load_mentors.NextRow())
			var/ckey = ckey(query_load_mentors.item[1])
			new /datum/mentors(ckey)
		qdel(query_load_mentors)

// new client var: mentor_datum. Acts the same way holder does towards admin: it holds the mentor datum. if set, the guy's a mentor.
/client
	var/datum/mentors/mentor_datum