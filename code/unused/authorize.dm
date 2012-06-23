/*
/client/proc/authorize()
	set name = "Authorize"

	if (src.authenticating)
		return

	if (!config.enable_authentication)
		src.authenticated = 1
		return

	src.authenticating = 1

	spawn (rand(4, 18))
		var/result = world.Export("http://byond.lljk.net/status/?key=[src.ckey]")
		var/success = 0

		if(lowertext(result["STATUS"]) == "200 ok")
			var/content = file2text(result["CONTENT"])

			var/pos = findtext(content, " ")
			var/code
			var/account = ""

			if (!pos)
				code = lowertext(content)
			else
				code = lowertext(copytext(content, 1, pos))
				account = copytext(content, pos + 1)

			if (code == "ok" && account)
				src.verbs -= /client/proc/authorize
				src.authenticated = account
				src << "Key authorized: Hello [html_encode(account)]!"
				src << "\blue[auth_motd]"
				success = 1

		if (!success)
			src.verbs += /client/proc/authorize
			src << "Failed to authenticate your key."
			src << "If you have not already authorize it at http://byond.lljk.net/ - your BYOND key is [src.key]."
			src << "Try again using the <b>Authorize</b> command, sometimes the server will hiccup and not correctly authorize."
			src << "\blue[no_auth_motd]"
		src.authenticating = 0
*/

/* The old goon auth/beta code is here
/client/proc/beta_tester_auth()
	set name = "Tester?"
	/*if(istester(src))
		src << "\blue <B>Key accepted as beta tester</B>"
	else
		src << "\red<B>Key not accepted as beta tester. You may only observe the rounds. */

/client/proc/goonauth()
	set name = "Goon?"

	if (src.authenticating)
		return

	if(isgoon(src))
		src.goon = goon_keylist[src.ckey]
		src.verbs -= /client/proc/goonauth
		src << "Key authorized: Hello [goon_keylist[src.ckey]]!"
		src << "\blue[auth_motd]"
		return

	if (config.enable_authentication)	//so that this verb isn't used when its goon only
		if(src.authenticated && src.authenticated != 1)
			src.goon = src.authenticated
			src.verbs -= /client/proc/goonauth
			src << "Key authorized: Hello [src.goon]!"
			src << "\blue[auth_motd]"
		else
			src << "Please authorize first"
		return

	src.authenticating = 1

	spawn (rand(4, 18))
		var/result = world.Export("http://byond.lljk.net/status/?key=[src.ckey]")
		var/success = 0

		if(lowertext(result["STATUS"]) == "200 ok")
			var/content = file2text(result["CONTENT"])

			var/pos = findtext(content, " ")
			var/code
			var/account = ""

			if (!pos)
				code = lowertext(content)
			else
				code = lowertext(copytext(content, 1, pos))
				account = copytext(content, pos + 1)

			if (code == "ok" && account)
				src.verbs -= /client/proc/goonauth
				src.goon = account
				src << "Key authorized: Hello [html_encode(account)]!"
				src << "\blue[auth_motd]"
				success = 1
				goon_key(src.ckey, account)

		if (!success)
			src.verbs += /client/proc/goonauth
			//src << "Failed"
			src << "\blue[no_auth_motd]"

		src.authenticating = 0

var/goon_keylist[0]
var/list/beta_tester_keylist

/proc/beta_tester_loadfile()
	beta_tester_keylist = new/list()
	var/text = file2text("config/testers.txt")
	if (!text)
		diary << "Failed to load config/testers.txt\n"
	else
		var/list/lines = dd_text2list(text, "\n")
		for(var/line in lines)
			if (!line)
				continue

			var/tester_key = copytext(line, 1, 0)
			beta_tester_keylist.Add(tester_key)


/proc/goon_loadfile()
	var/savefile/S=new("data/goon.goon")
	S["key[0]"] >> goon_keylist
	log_admin("Loading goon_keylist")
	if (!length(goon_keylist))
		goon_keylist=list()
		log_admin("goon_keylist was empty")

/proc/goon_savefile()
	var/savefile/S=new("data/goon.goon")
	S["key[0]"] << goon_keylist

/proc/goon_key(key as text,account as text)
	var/ckey=ckey(key)
	if (!goon_keylist.Find(ckey))
		goon_keylist.Add(ckey)
	goon_keylist[ckey] = account
	goon_savefile()

/proc/isgoon(X)
	if (istype(X,/mob)) X=X:ckey
	if (istype(X,/client)) X=X:ckey
	if ((ckey(X) in goon_keylist)) return 1
	else return 0

/proc/istester(X)
	if (istype(X,/mob)) X=X:ckey
	if (istype(X,/client)) X=X:ckey
	if ((ckey(X) in beta_tester_keylist)) return 1
	else return 0

/proc/remove_goon(key as text)
	var/ckey=ckey(key)
	if (key && goon_keylist.Find(ckey))
		goon_keylist.Remove(ckey)
		goon_savefile()
		return 1
	return 0
*/