//By Carnwennan

//This system was made as an alternative to all the in-game lists and variables used to log stuff in-game.
//lists and variables are great. However, they have several major flaws:
//Firstly, they use memory. TGstation has one of the highest memory usage of all the ss13 branches.
//Secondly, they are usually stored in an object. This means that they aren't centralised. It also means that
//the data is lost when the object is deleted! This is especially annoying for things like the singulo engine!
#define INVESTIGATE_DIR "data/investigate/"

//SYSTEM
/proc/investigate_subject2file(subject)
	return file("[INVESTIGATE_DIR][subject].html")

/proc/investigate_reset()
	if(fdel(INVESTIGATE_DIR))
		return 1
	return 0

/atom/proc/investigate_log(message, subject)
	if(!message)
		return
	var/F = investigate_subject2file(subject)
	if(!F)
		return
	F << "<small>[time_stamp()] \ref[src] ([x],[y],[z])</small> || [src] [message]<br>"

//ADMINVERBS
/client/proc/investigate_show( subject in list("hrefs","notes","watchlist","singulo","wires","telesci", "gravity", "records", "cargo", "supermatter", "atmos", "experimentor", "kudzu") )
	set name = "Investigate"
	set category = "Admin"
	if(!holder)
		return
	switch(subject)
		if("singulo", "wires", "telesci", "gravity", "records", "cargo", "supermatter", "atmos", "kudzu")			//general one-round-only stuff
			var/F = investigate_subject2file(subject)
			if(!F)
				src << "<font color='red'>Error: admin_investigate: [INVESTIGATE_DIR][subject] is an invalid path or cannot be accessed.</font>"
				return
			src << browse(F,"window=investigate[subject];size=800x300")
		if("hrefs")				//persistent logs and stuff
			if(href_logfile)
				src << browse(href_logfile,"window=investigate[subject];size=800x300")
			else if(!config.log_hrefs)
				src << "<span class='danger'>Href logging is off and no logfile was found.</span>"
				return
			else
				src << "<span class='danger'>No href logfile was found.</span>"
				return
		if("notes")
			show_note()
		if("watchlist")
			watchlist_show()
