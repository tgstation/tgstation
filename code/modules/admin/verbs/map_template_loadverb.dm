
/client/proc/map_template_load()
	set category = "Debug"
	set name = "Map template - Place"

	var/turf/T = get_turf(mob)
	if(!T)
		return

	var/list/filelist = flist("_maps/templates/")
	filelist |= map_template_uploads

	var/map = input(usr, "Choose a Map Template to place at your CURRENT LOCATION","Place Map Template") as null|anything in filelist
	if(!map)
		return

	var/mapfile
	if(map in map_template_uploads) //in the cache, not the template folder
		mapfile = map
	else
		mapfile = file("_maps/templates/[map]")

	if(isfile(mapfile))
		maploader.load_map(mapfile, T.x, T.y, T.z)
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] has placed a map template ([map]) at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a></span>")
	else
		usr << "Bad map file: [map]"


//A list of map files that have been uploaded by admins
//It's NOT persistent between rounds
var/global/list/map_template_uploads = list()


/client/proc/map_template_upload()
	set category = "Debug"
	set name = "Map Template - Upload"

	var/map = input(usr, "Choose a Map Template to upload to template storage","Upload Map Template") as null|file
	if(!map)
		return
	if(copytext("[map]",-4) != ".dmm")
		usr << "Bad map file: [map]"
		return

	map_template_uploads |= file(map)
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has uploaded a map template ([map])</span>")
