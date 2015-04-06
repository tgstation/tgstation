// Save/Load by ACCount
// Two BYOND bugs was spotted and reported while working on this.


/client/proc/save_to_file(var/atom/movable/A in world)
	set category = "Debug"
	set name = "Save To File"

	if(!check_rights(R_DEBUG))	return

	var/crash = alert("Are you sure you want to save [A]? THIS IS UNSAFE AND CAN CRASH THE SERVER! USE ON LOCAL SERVER ONLY!",
	"Not For Ingame Use",
	"NO!", "Yes")

	if(crash != "Yes")
		return

	message_admins("[key_name(src)] is trying to crash the server with Save To File by saving [A]!")
	log_admin("[key_name(src)] is trying to crash the server with Save To File by saving [A]!")

	var/savefile/F = new()
	var/txtfile = file("temp.sav")
	F["save"] << A

	fdel(txtfile)
	F.ExportText("/", txtfile)
	usr << ftp(txtfile, A.name)

	usr << "Saved!"
	fdel(txtfile)



/client/proc/load_savefile(F as file)
	set category = "Debug"
	set name = "Load Save File"

	if(!check_rights(R_SPAWN))	return

	var/txtfile = file("temp.sav")
	fdel(txtfile)
	fcopy(F,"temp.sav")
	txtfile = file("temp.sav")

	message_admins("[key_name(src)] has loaded a save file.")
	log_admin("[key_name(src)] has loaded a save file.")
	src << "RMB a turf and press Spawn Save File Contents to spawn a save file."

	var/savefile/S = new()
	S.ImportText("/", txtfile)
	holder.savefile = S
	verbs += /client/proc/load_savefile_to_turf
	fdel(txtfile)


/client/proc/load_savefile_to_turf(var/turf/T in world)
	set category = "Debug"
	set name = "Spawn Save File Contents"

	if(!check_rights(R_SPAWN))	return
	if(!T)						return
	if(!holder.savefile)		return

	var/atom/movable/A
	message_admins("[key_name(src)] is spawning a save file.")
	log_admin("[key_name(src)] is spawning a save file.")
	holder.savefile["save"] >> A
	if(A)
		A.Move(T)
		A.loc = T

		message_admins("[key_name(src)] has spawned a save file [A] ([A.type]) at [T.x], [T.y], [T.z].")
		log_admin("[key_name(src)] has spawned a save file [A] ([A.type]) at [T.x], [T.y], [T.z].")