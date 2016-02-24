
/client/proc/map_template_load()
	set category = "Debug"
	set name = "Load Map Template"

	var/turf/T = get_turf(mob)
	if(!T)
		return
	var/map = input(usr, "Choose a Map Template to load at your CURRENT LOCATION","Load Map Template") as null|anything in flist("_maps/templates/")
	if(!map)
		return
	var/formatted_map = "_maps/templates/[map]"
	var/mapfile = file(formatted_map)
	if(isfile(mapfile))
		maploader.load_map(mapfile, T.x, T.y, T.z)
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] has loaded a map template ([map]) at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a></span>")
	else
		usr << "Bad map file"
