//By Carnwennan

//This system was made as an alternative to all the in-game lists and variables used to log stuff in-game.
//lists and variables are great. However, they have several major flaws:
//Firstly, they use memory. TGstation has one of the highest memory usage of all the ss13 branches.
//Secondly, they are usually stored in an object. This means that they aren't centralised. It also means that
//the data is lost when the object is deleted! This is especially annoying for things like the singulo engine!
#define INVESTIGATE_DIR "data/investigate/"

//SYSTEM
/proc/investigate_subject2file(var/subject)
	switch(subject)
		if("singulo")
			return file("[INVESTIGATE_DIR]singulo.html")
		if("silicon")
			return file("[INVESTIGATE_DIR]silicon.html")
		else
			return

/proc/investigate_reset()
	if(fdel(INVESTIGATE_DIR))	return 1
	return 0

/atom/proc/investigate_log(var/message, var/subject)
	if(!message)	return
	var/F = investigate_subject2file(subject)
	if(!F)	return
	F << "<small>[time2text(world.timeofday,"hh:mm")] \ref[src] ([x],[y],[z])</small> || [src] [message]<br>"



//ADMINVERBS
/client/proc/investigate_show( subject in list("singulo","silicon") )
	set name = "Investigate"
	set category = "Admin"
	if(!holder)	return
	var/F = investigate_subject2file(subject)
	if(!F)
		src << "<font color='red'>Error: admin_investigate: [INVESTIGATE_DIR][subject] is an invalid path or cannot be accessed.</font>"
		return
	src << browse(F,"window=investigate;size=800x300")


