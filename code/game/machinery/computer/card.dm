//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

/obj/machinery/computer/card
	name = "Identification Computer"
	desc = "A computer used to modify ID cards."
	icon_state = "id"
	req_access = list(access_change_ids)
	circuit = "/obj/item/weapon/circuitboard/card"
	var/obj/item/weapon/card/id/scan = null
	var/obj/item/weapon/card/id/modify = null
	var/authenticated = 0.0
	var/mode = 0.0
	var/printing = null


/obj/machinery/computer/card/attackby(O as obj, user as mob)//TODO:SANITY
	if(istype(O, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/idcard = O
		if(access_change_ids in idcard.access)
			if(!scan)
				usr.drop_item()
				idcard.loc = src
				scan = idcard
			else if(!modify)
				usr.drop_item()
				idcard.loc = src
				modify = idcard
		else
			if(!modify)
				usr.drop_item()
				idcard.loc = src
				modify = idcard
	else
		..()


/obj/machinery/computer/card/attack_ai(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/card/attack_paw(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/card/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.machine = src
	var/dat
	if (!( ticker ))
		return
	if (mode) // accessing crew manifest
		var/crew = data_core.get_manifest()
		dat = "<tt><b>Crew Manifest:</b><br>Please use the security record computer to modify entries.<br>[crew]<a href='?src=\ref[src];choice=print'>Print</a><br><br><a href='?src=\ref[src];choice=mode;mode_target=0'>Access ID modification console.</a><br></tt>"
	else
		var/header = "<div align='center'><b>Identification Card Modifier</b></div>"

		var/target_name
		var/target_owner
		var/target_rank
		if(modify)
			target_name = modify.name
		else
			target_name = "--------"
		if(modify && modify.registered_name)
			target_owner = modify.registered_name
		else
			target_owner = "--------"
		if(modify && modify.assignment)
			target_rank = modify.assignment
		else
			target_rank = "Unassigned"

		var/scan_name
		if(scan)
			scan_name = scan.name
		else
			scan_name = "--------"

		if(!authenticated)
			header += "<br><i>Please insert the cards into the slots</i><br>"
			header += "Target: <a href='?src=\ref[src];choice=modify'>[target_name]</a><br>"
			header += "Confirm Identity: <a href='?src=\ref[src];choice=scan'>[scan_name]</a><br>"
		else
			header += "<div align='center'><br>"
			header += "<a href='?src=\ref[src];choice=modify'>Remove [target_name]</a> || "
			header += "<a href='?src=\ref[src];choice=scan'>Remove [scan_name]</a> <br> "
			header += "<a href='?src=\ref[src];choice=mode;mode_target=1'>Access Crew Manifest</a> || "
			header += "<a href='?src=\ref[src];choice=logout'>Log Out</a></div>"

		header += "<hr>"

		var/jobs_all = ""
		var/list/alljobs = (istype(src,/obj/machinery/computer/card/centcom)? get_all_centcom_jobs() : get_all_jobs()) + "Custom"
		for(var/job in alljobs)
			jobs_all += "<a href='?src=\ref[src];choice=assign;assign_target=[job]'>[dd_replacetext(job, " ", "&nbsp")]</a> " //make sure there isn't a line break in the middle of a job


		var/body
		if (authenticated && modify)
			var/carddesc = {"<script type="text/javascript">
								function markRed(){
									var nameField = document.getElementById('namefield');
									nameField.style.backgroundColor = "#FFDDDD";
								}
								function markGreen(){
									var nameField = document.getElementById('namefield');
									nameField.style.backgroundColor = "#DDFFDD";
								}
								function showAll(){
									var allJobsSlot = document.getElementById('alljobsslot');
									allJobsSlot.innerHTML = "<a href='#' onclick='hideAll()'>hide</a><br>"+ "[jobs_all]";
								}
								function hideAll(){
									var allJobsSlot = document.getElementById('alljobsslot');
									allJobsSlot.innerHTML = "<a href='#' onclick='showAll()'>show</a>";
								}
							</script>"}
			carddesc += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
			carddesc += "<input type='hidden' name='src' value='\ref[src]'>"
			carddesc += "<input type='hidden' name='choice' value='reg'>"
			carddesc += "<b>Registered:</b> <input type='text' id='namefield' name='reg' value='[target_owner]' style='width:250px; background-color:white;' onchange='markRed()'>"
			carddesc += "<input type='submit' value='Rename' onclick='markGreen()'>"
			carddesc += "</form>"
			carddesc += "<b>Assignment:</b> "

			var/jobs = "<span id='alljobsslot'><a href='#' onclick='showAll()'>[target_rank]</a></span>" //CHECK THIS

			var/accesses = ""
			if(istype(src,/obj/machinery/computer/card/centcom))
				accesses += "<h5>Central Command:</h5>"
				for(var/A in get_all_centcom_access())
					if(A in modify.access)
						accesses += "<a href='?src=\ref[src];choice=access;access_target=[A];allowed=0'><font color=\"red\">[dd_replacetext(get_centcom_access_desc(A), " ", "&nbsp")]</font></a> "
					else
						accesses += "<a href='?src=\ref[src];choice=access;access_target=[A];allowed=1'>[dd_replacetext(get_centcom_access_desc(A), " ", "&nbsp")]</a> "
			else
				accesses += "<div align='center'><b>Access</b></div>"
				accesses += "<table style='width:100%'>"
				accesses += "<tr>"
				for(var/i = 1; i <= 7; i++)
					accesses += "<td style='width:14%'><b>[get_region_accesses_name(i)]:</b></td>"
				accesses += "</tr><tr>"
				for(var/i = 1; i <= 7; i++)
					accesses += "<td style='width:14%' valign='top'>"
					for(var/A in get_region_accesses(i))
						if(A in modify.access)
							accesses += "<a href='?src=\ref[src];choice=access;access_target=[A];allowed=0'><font color=\"red\">[dd_replacetext(get_access_desc(A), " ", "&nbsp")]</font></a> "
						else
							accesses += "<a href='?src=\ref[src];choice=access;access_target=[A];allowed=1'>[dd_replacetext(get_access_desc(A), " ", "&nbsp")]</a> "
						accesses += "<br>"
					accesses += "</td>"
				accesses += "</tr></table>"

			var/biometric = ""
			biometric += 	"<b>Biometric Data</b>:<br />\
							Blood type: <a href='?src=\ref[src];choice=bio_btype'>[modify.blood_type]</a><br />\
							DNA hash: <a href='?src=\ref[src];choice=bio_dna'>[modify.dna_hash]</a><br />\
							Fingerprint hash: <a href='?src=\ref[src];choice=bio_fprint'>[modify.fingerprint_hash]</a>"

			body = "[carddesc]<br>[jobs]<br>[biometric]<br><br>[accesses]" //CHECK THIS
		else
			body = "<a href='?src=\ref[src];choice=auth'>{Log in}</a> <br><hr>"
			body += "<a href='?src=\ref[src];choice=mode;mode_target=1'>Access Crew Manifest</a>"
		dat = "<tt>[header][body]<hr><br></tt>"
	user << browse(dat, "window=id_com;size=900x520")
	onclose(user, "id_com")
	return


/obj/machinery/computer/card/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	switch(href_list["choice"])
		if("bio_btype")
			var/new_b_type = input("Please input the blood type.", "Biometric Input")  as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
			if(new_b_type)
				modify.blood_type = new_b_type

		if("bio_dna")
			modify.dna_hash = input("Please input the DNA hash.", "Biometric Input", modify.dna_hash)

		if("bio_fprint")
			modify.fingerprint_hash = input("Please input the fingerprint hash.", "Biometric Input", modify.fingerprint_hash)

		if ("modify")
			if (modify)
				data_core.manifest_modify(modify.registered_name, modify.assignment)
				if(istype(modify,/obj/item/weapon/card/id/fluff/lifetime))
					modify.name = text("[modify.registered_name]'s Lifetime ID Card ([modify.assignment])")
				else
					modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")
				if(ishuman(usr))
					modify.loc = usr.loc
					if(!usr.get_active_hand())
						usr.put_in_hand(modify)
					modify = null
				else
					modify.loc = loc
					modify = null
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I.loc = src
					modify = I
			authenticated = 0

		if ("scan")
			if (scan)
				if(ishuman(usr))
					scan.loc = usr.loc
					if(!usr.get_active_hand())
						usr.put_in_hand(scan)
					scan = null
				else
					scan.loc = src.loc
					scan = null
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I.loc = src
					scan = I
			authenticated = 0
		if ("auth")
			if ((!( authenticated ) && (scan || (istype(usr, /mob/living/silicon))) && (modify || mode)))
				if (check_access(scan))
					authenticated = 1
			else if ((!( authenticated ) && (istype(usr, /mob/living/silicon))) && (!modify))
				usr << "You can't modify an ID without an ID inserted to modify. Once one is in the modify slot on the computer, you can log in."
		if ("logout")
			authenticated = 0
		if("access")
			if(href_list["allowed"])
				if(authenticated)
					var/access_type = text2num(href_list["access_target"])
					var/access_allowed = text2num(href_list["allowed"])
					if(access_type in (istype(src,/obj/machinery/computer/card/centcom)?get_all_centcom_access() : get_all_accesses()))
						modify.access -= access_type
						if(access_allowed == 1)
							modify.access += access_type
		if ("assign")
			if (authenticated)
				var/t1 = href_list["assign_target"]
				if(t1 == "Custom")
					var/temp_t = copytext(sanitize(input("Enter a custom job assignment.","Assignment")),1,MAX_MESSAGE_LEN)
					if(temp_t)
						t1 = temp_t
				else
					modify.access = ( istype(src,/obj/machinery/computer/card/centcom) ? get_centcom_access(t1) : get_access(t1) )
				if (modify)
					modify.assignment = t1
		if ("reg")
			if (authenticated)
				var/t2 = modify
				//var/t1 = input(usr, "What name?", "ID computer", null)  as text
				if ((authenticated && modify == t2 && (in_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(loc, /turf)))
					modify.registered_name = href_list["reg"]
		if ("mode")
			mode = text2num(href_list["mode_target"])
		if ("print")
			if (!( printing ))
				printing = 1
				sleep(50)
				var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( loc )
				P.info = "<B>Crew Manifest:</B><BR>" + data_core.get_manifest()
				P.name = "paper - 'Crew Manifest'"
				printing = null
	if (modify)
		modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")
	updateUsrDialog()
	return



/obj/machinery/computer/card/centcom
	name = "CentCom Identification Computer"
	circuit = "/obj/item/weapon/circuitboard/card/centcom"
	req_access = list(access_cent_captain)

