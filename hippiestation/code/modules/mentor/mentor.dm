GLOBAL_LIST_EMPTY(mentor_datums)
GLOBAL_PROTECT(mentor_datums)

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
	target = ckey
	name = "[ckey]'s mentor datum"
	href_token = GenerateToken()
	//set the owner var and load commands
	owner = GLOB.directory[ckey]
	owner.mentor_datum = src
	owner.add_mentor_verbs()
	GLOB.mentors += owner
	GLOB.mentor_datums += src

/datum/mentors/proc/CheckMentorHref(href, href_list)
	var/auth = href_list["admin_token"]
	. = auth && (auth == href_token || auth == GLOB.href_token)
	if(.)
		return
	var/msg = !auth ? "no" : "a bad"
	message_admins("[key_name_admin(usr)] clicked an href with [msg] authorization key!")
	if(CONFIG_GET(flag/debug_admin_hrefs))
		message_admins("Debug mode enabled, call not blocked. Please ask your coders to review this round's logs.")
		log_world("UAH: [href]")
		return TRUE
	log_admin_private("[key_name(usr)] clicked an href with [msg] authorization key! [href]")

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
			if(!line)
				continue
			new /datum/mentors(line)
	else//Database
		if(!SSdbcore.Connect())
			log_world("Failed to connect to database in load_mentors(). Reverting to legacy system.")
			WRITE_FILE(GLOB.world_game_log, "Failed to connect to database in load_mentors(). Reverting to legacy system.")
			CONFIG_SET(flag/mentor_legacy_system, TRUE)
			load_mentors()
			return
		var/datum/DBQuery/query_load_mentors = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("mentor")]")//REMEMBER TO CREATE TABLE,CARBON
		if(!query_load_mentors.Execute())
			return
		while(query_load_mentors.NextRow())
			var/ckey = ckey(query_load_mentors.item[1])
			new /datum/mentors(ckey)

// new client var: mentor_datum. Acts the same way holder does towards admin: it holds the mentor datum. if set, the guy's a mentor.
/client
	var/datum/mentors/mentor_datum