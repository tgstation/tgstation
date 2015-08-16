/obj/machinery/computer/security/advanced
	name = "Advanced Security Cameras"
	desc = "Used to access the various cameras on the station with an interactive user interface."
	circuit = "/obj/item/weapon/circuitboard/security/advanced"

/obj/machinery/computer/security/advanced/New()
	..()
	html_machines += src

/obj/item/weapon/circuitboard/security/advanced
	name = "Circuit board (Advanced Security)"
	build_path = /obj/machinery/computer/security/advanced

/obj/machinery/computer/security/advanced/attack_hand(var/mob/user as mob)
	if (src.z > 6)
		user << "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!"
		return
	if(stat & (NOPOWER|BROKEN))	return
	adv_camera.show(user, (current ? current.z : z))
	if(current) user.reset_view(current)
	user.machine = src
	return

/obj/machinery/computer/security/advanced/check_eye(var/mob/user as mob)
	if (( ( get_dist(user, src) > 1 ) || !( user.canmove ) || ( user.blinded )) && (!istype(user, /mob/living/silicon)))
		if(user.machine == src) user.machine = null
		return null
	if(stat & (NOPOWER|BROKEN)) return null
	user.reset_view(current)
	return 1

var/global/datum/interactive_map/camera/adv_camera = new
/client/verb/lookatdatum()
	set category = "Debug"
	debug_variables(adv_camera)

/datum/interactive_map/camera
	var/list/zlevel_data
	var/list/zlevels
	var/list/camerasbyzlevel
	var/initialized = 0

/datum/interactive_map/camera/New()
	. = ..()

	zlevels = list(1,5)
	zlevel_data = list("1" = list(),"5" = list())

/obj/machinery/computer/camera/Destroy()
	..()
	html_machines -= src

/datum/interactive_map/camera/show(mob/mob, z, datum/html_interface/currui)
	z = text2num(z)
	if (!z) z = mob.z
	if (!(z in zlevels))
		mob << "zlevel([z]) good levels: [list2text(zlevels, " ")]"
		mob << "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!"
		return

	if (src.interfaces)
		var/datum/html_interface/hi

		if (!src.interfaces["[z]"])
			src.interfaces["[z]"] = new/datum/html_interface/nanotrasen(src, "Security Cameras", 900, 800, "[MAPHEADER] </script><script type=\"text/javascript\">var z = [z]; var tile_size = [world.icon_size]; var maxx = [world.maxx]; var maxy = [world.maxy];</script><script type=\"text/javascript\" src=\"advcamera.js\"></script>")

			hi = src.interfaces["[z]"]

			hi.updateContent("content", "<div id='switches'><a href=\"javascript:switchTo(0);\">Switch to mini map</a> <a href=\"javascript:switchTo(1);\">Switch to text-based</a> <a href='javascript:changezlevels();'>Change Z-Level</a> <a href='byond://?src=\ref[hi]&cancel=1'>Cancel Viewing</a></div> <div id=\"uiMapContainer\"><div id=\"uiMap\" unselectable=\"on\"></div></div><div id=\"textbased\"></div>")

			src.update(z, TRUE)
		else
			hi = src.interfaces["[z]"]

		hi = src.interfaces["[z]"]
		hi.show(mob, currui)
		src.updateFor(mob, hi, z)

/datum/interactive_map/camera/updateFor(hclient_or_mob, datum/html_interface/hi, z, single)
	//copy pasted code but given so many cameras i dont want to iterate over the entire worlds worth of cams, so we save our data based on zlevel
	if(!single) hi.callJavaScript("clearAll", new/list(), hclient_or_mob)
	data = zlevel_data["[z]"]
	for (var/list/L in data)
		hi.callJavaScript("add", L, hclient_or_mob)

#define toAdd 1
#define toRemove 2
#define toChange 4
/datum/interactive_map/camera/update(z, ignore_unused = FALSE, var/obj/machinery/camera/single, adding = 0)
	if (src.interfaces["[z]"])
		var/zz = text2num(z)
		if(!zz) zz = z
		var/datum/html_interface/hi = src.interfaces["[zz]"]
		var/ID
		var/status
		var/name
		var/area
		var/pos_x
		var/pos_y
		var/pos_z
		var/see_x
		var/see_y
		if (ignore_unused || hi.isUsed())
			var/list/results = list()
			var/list/ourcams = camerasbyzlevel["[z]"]
			if(!istype(single))
				for (var/obj/machinery/camera/C in ourcams)
					var/turf/pos = get_turf(C)
					if(!pos)
						camerasbyzlevel["[zz]"] -= C
						continue
					if(pos.z != zz)
						camerasbyzlevel["[zz]"] -= C //bad zlevel
						if(pos.z == 1 || pos.z == 5)
							camerasbyzlevel["[zz]"] |= C //try to fix the zlevel list.
						continue
					ID="\ref[C]"
					status = C.alarm_on //1 = alarming 0 = all is well
					if(!C.can_use())
						continue
						// weve already cleared the board son.status = -1 //mark this shit for removal
					name = C.c_tag
					var/area/AA = get_area(C)
					area = format_text(AA.name)
					pos_x = pos.x
					pos_y = pos.y
					pos_z = pos.z
					see_x = pos.x - WORLD_X_OFFSET[z]
					see_y = pos.y - WORLD_Y_OFFSET[z]
					results[++results.len]=list(ID, status, name,area,pos_x,pos_y,pos_z,see_x,see_y)
			else
				var/turf/pos = get_turf(single)
				if(pos.z != zz)
					camerasbyzlevel["[zz]"] -= single //bad zlevel
					if(pos.z == 1 || pos.z == 5)
						camerasbyzlevel["[zz]"] |= single //try to fix the zlevel list
					else adding = 2 //Set to remove
				ID="\ref[single]"
				status = single.alarm_on //1 = alarming 0 = all is well
				if(!single.can_use())
					adding = 2 //mark this shit for removal
				name = single.c_tag
				var/area/AA = get_area(single)
				area = format_text(AA.name)
				pos_x = pos.x
				pos_y = pos.y
				pos_z = pos.z
				see_x = pos.x - WORLD_X_OFFSET[z]
				see_y = pos.y - WORLD_Y_OFFSET[z]
				results[++results.len]=list(ID, status, name,area,pos_x,pos_y,pos_z,see_x,see_y,adding)

			//src.data = results
			zlevel_data["[z]"] = results
			src.updateFor(null, hi, z, single) // updates for everyone
#undef toAdd
#undef toRemove
#undef toChange
/datum/interactive_map/camera/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
/*	zlevel limit removed on /vg/
	var/z = ""

	for (z in src.interfaces)
		if (src.interfaces[z] == hi) break
*/
	. = ..()

	var/los = hclient.client.mob.html_mob_check(/obj/machinery/computer/security/advanced)
	if(!los) hclient.client.mob.reset_view(hclient.client.mob)

	return (. && los)

/datum/interactive_map/camera/Topic(href, href_list[], datum/html_interface_client/hclient)
	//world.log << "[src.type] topic call"
	if(..())
		//world.log << "[src.type] topic call handled by parent"
		return // Our parent handled it the topic call
	if (istype(hclient))
		if (hclient && hclient.client && hclient.client.mob && isliving(hclient.client.mob))
			var/mob/living/L = hclient.client.mob
			usr = L
			for(var/obj/machinery/computer/security/advanced/A in html_machines)
				if(usr.machine == A)
					A.Topic(href, href_list, hclient)
					break

/datum/interactive_map/camera/queueUpdate(z)
	var/datum/controller/process/html/html = processScheduler.getProcess("html")
	html.queue(crewmonitor, "update", z)

/datum/interactive_map/camera/sendResources(client/C)
	..()
	C << browse_rsc('advcamera.js')

/obj/machinery/computer/security/advanced/Topic(href, href_list)
	//world.log << "[src.type] topic call"
	if(..())
		return 0

	if(href_list["cancel"])
		usr.reset_view(null)
		current = null
	if(href_list["view"])
		var/obj/machinery/camera/cam = locate(href_list["view"])
		if(cam)
			if(isAI(usr))
				var/mob/living/silicon/ai/A = usr
				A.eyeobj.forceMove(get_turf(cam))
				A.client.eye = A.eyeobj
			else
				use_power(50)
				current = cam
				usr.reset_view(current)
	return 1