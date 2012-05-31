//gloves w_uniform wear_suit shoes

atom/var/list/suit_fibers

atom/proc/add_fibers(mob/living/carbon/human/M)
	if(M.gloves)
		if(M.gloves.transfer_blood) //bloodied gloves transfer blood to touched objects
			if(add_blood(M.gloves.bloody_hands_mob)) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				M.gloves.transfer_blood--
	else if(M.bloody_hands)
		if(add_blood(M.bloody_hands_mob))
			M.bloody_hands--
	if(!suit_fibers) suit_fibers = list()
	var/fibertext
	var/item_multiplier = istype(src,/obj/item)?1.2:1
	if(M.wear_suit)
		fibertext = "Material from \a [M.wear_suit]."
		if(prob(10*item_multiplier) && !(fibertext in suit_fibers))
			//world.log << "Added fibertext: [fibertext]"
			suit_fibers += fibertext
		if(!(M.wear_suit.body_parts_covered & 32))
			if(M.w_uniform)
				fibertext = "Fibers from \a [M.w_uniform]."
				if(prob(12*item_multiplier) && !(fibertext in suit_fibers)) //Wearing a suit means less of the uniform exposed.
					//world.log << "Added fibertext: [fibertext]"
					suit_fibers += fibertext
		if(!(M.wear_suit.body_parts_covered & 64))
			if(M.gloves)
				fibertext = "Material from a pair of [M.gloves.name]."
				if(prob(20*item_multiplier) && !(fibertext in suit_fibers))
					//world.log << "Added fibertext: [fibertext]"
					suit_fibers += fibertext
	else if(M.w_uniform)
		fibertext = "Fibers from \a [M.w_uniform]."
		if(prob(15*item_multiplier) && !(fibertext in suit_fibers))
			// "Added fibertext: [fibertext]"
			suit_fibers += fibertext
		if(M.gloves)
			fibertext = "Material from a pair of [M.gloves.name]."
			if(prob(20*item_multiplier) && !(fibertext in suit_fibers))
				//world.log << "Added fibertext: [fibertext]"
				suit_fibers += "Material from a pair of [M.gloves.name]."
	else if(M.gloves)
		fibertext = "Material from a pair of [M.gloves.name]."
		if(prob(20*item_multiplier) && !(fibertext in suit_fibers))
			//world.log << "Added fibertext: [fibertext]"
			suit_fibers += "Material from a pair of [M.gloves.name]."
	if(!suit_fibers.len) del suit_fibers

var/const/FINGERPRINT_COMPLETE = 6	//This is the output of the stringpercent(print) proc, and means about 80% of
								//the print must be there for it to be complete.  (Prints are 32 digits)

obj/machinery/computer/forensic_scanning
	name = "High-Res Forensic Scanning Computer"
	icon_state = "forensic"
	var
		obj/item/scanning
		temp = ""
		canclear = 1
		authenticated = 0

//Here's the structure for files: each entry is a list, and entry one in that list is the string of their
//full and scrambled fingerprint.  This acts as the method to arrange evidence.  Each subsequent entry is list
//in the form (from entries):
//	1: Object
//	2: All prints on the object
//	3: All fibers on the object
//	4: All blood on the object
//This is then used to show what objects were used to "find" the full print, as well as the fibers on it.
		list/files
//This holds objects (1) without prints, and their fibers(2) and blood(3).
		list/misc
		obj/item/weapon/f_card/card

		scan_data = ""
		scan_name = ""
		scan_process = 0

	req_access = list(access_forensics_lockers)


	New()
		..()
		new /obj/item/weapon/book/manual/detective(get_turf(src))
		return


	attack_ai(mob/user)
		return attack_hand(user)


	attack_hand(mob/user)
		if(..())
			return
		user.machine = src
		var/dat = ""
		var/isai = 0
		if(istype(usr,/mob/living/silicon))
			isai = 1
		if(temp)
			dat += "<tt>[temp]</tt><br><br>"
			if(canclear) dat += "<a href='?src=\ref[src];operation=clear'>{Clear Screen}</a>"
		else
			if(!authenticated)
				dat += "<a href='?src=\ref[src];operation=login'>{Log In}</a>"
			else
				dat += "<a href='?src=\ref[src];operation=logout'>{Log Out}</a><br><hr><br>"
				if(scanning)
					if(scan_process)
						dat += "Scan Object: {[scanning.name]}<br>"
						dat += "<a href='?src=\ref[src];operation=cancel'>{Cancel Scan}</a> {Print}<br>"
					else
						if(isai) dat += "Scan Object: {[scanning.name]}<br>"
						else dat += "Scan Object: <a href='?src=\ref[src];operation=eject'>{[scanning.name]}</a><br>"
						dat += "<a href='?src=\ref[src];operation=scan'>{Scan}</a> <a href='?src=\ref[src];operation=print'>{Print}</a><br>"
				else
					if(isai) dat += "{No Object Inserted}<br>"
					else dat += "<a href='?src=\ref[src];operation=insert'>{No Object Inserted}</a><br>"
					dat += "{Scan} <a href='?src=\ref[src];operation=print'>{Print}</a><br>"
				dat += "<a href='?src=\ref[src];operation=database'>{Access Database}</a><br><br>"
				dat += "<tt>[scan_data]</tt>"
				if(scan_data && !scan_process)
					dat += "<br><a href='?src=\ref[src];operation=erase'>{Erase Data}</a>"
		user << browse(dat,"window=scanner")
		onclose(user,"scanner")


	Topic(href,href_list)
		switch(href_list["operation"])
			if("login")
				var/mob/M = usr
				if(istype(M,/mob/living/silicon))
					authenticated = 1
					updateDialog()
					return
				var/obj/item/weapon/card/id/I = M.equipped()
				if (I && istype(I))
					if(src.check_access(I))
						authenticated = 1
						//usr << "\green Access Granted"
				//if(!authenticated)
					//usr << "\red Access Denied"
			if("logout")
				authenticated = 0
			if("clear")
				if(canclear)
					temp = null
			if("eject")
				if(scanning)
					scanning.loc = loc
					scanning = null
				else
					temp = "Eject Failed: No Object"
			if("insert")
				var/mob/M = usr
				var/obj/item/I = M.equipped()
				if(I && istype(I))
					if(istype(I, /obj/item/weapon/evidencebag))
						scanning = I.contents[1]
						scanning.loc = src
						I.overlays -= scanning
						I.icon_state = "evidenceobj"
					else
						scanning = I
						M.drop_item()
						I.loc = src
				else
					usr << "Invalid Object Rejected."
			if("card")  //Processing a fingerprint card.
				var/mob/M = usr
				var/obj/item/I = M.equipped()
				if(!(I && istype(I,/obj/item/weapon/f_card)))
					I = card
				if(I && istype(I,/obj/item/weapon/f_card))
					card = I
					if(!card.fingerprints)
						card.fingerprints = list()
					if(card.amount > 1 || !card.fingerprints.len)
						usr << "\red ERROR: No prints/too many cards."
						if(card.loc == src)
							card.loc = src.loc
						card = null
						return
					M.drop_item()
					I.loc = src
					process_card()
				else
					usr << "\red Invalid Object Rejected."
			if("database") //Viewing all records in each database
				canclear = 1
				if(href_list["delete_record"])
					delete_dossier(href_list["delete_record"])
				if(href_list["delete_aux"])
					delete_record(href_list["delete_aux"])
				if((!misc || !misc.len) && (!files || !files.len))
					temp = "Database is empty."
				else
					if(files && files.len)
						temp = "<b>Criminal Evidence Database</b><br><br>"
						temp += "Consolidated data points:<br>"
						var/i = 1
						for(var/print in files)
							temp += "<a href='?src=\ref[src];operation=record;identifier=[print]'>{Dossier [i]}</a><br>"
							i++
						temp += "<br><a href='?src=\ref[src];operation=card'>{Insert Finger Print Card (To complete a Dossier)}</a><br><br><br>"
					else
						temp = ""
					if(misc && misc.len)
						temp += "<b>Auxiliary Evidence Database</b><br><br>"
						temp += "This is where anything without fingerprints goes.<br><br>"
						for(var/atom in misc)
							var/list/data_entry = misc[atom]
							temp += "<a href='?src=\ref[src];operation=auxiliary;identifier=[atom]'>{[data_entry[3]]}</a><br>"
			if("record") //Viewing a record from the "files" database.
				canclear = 0
				if(files)
					temp = "<b>Criminal Evidence Database</b><br><br>"
					temp += "Consolidated data points: Dossier [files.Find(href_list["identifier"])]<br>"
					var/list/dossier = files[href_list["identifier"]]
					var/print_string = "Fingerprints: Print not complete!<br>"
					if(stringpercent(dossier[1]) <= FINGERPRINT_COMPLETE)
						print_string = "Fingerprints: (80% or higher completion reached)<br>[dossier[1]]<br>"
					temp += print_string
					for(var/object in dossier)
						if(object == dossier[1])
							continue
						temp += "<hr>"
						var/list/outputs = dossier[object]
						var/list/prints_len = outputs[1]
						temp += "<big><b>Object:</b> [outputs[4]]</big><br>"
						temp += "&nbsp<b>Fingerprints:</b><br>"
						temp += "&nbsp;&nbsp;&nbsp;&nbsp;[prints_len.len] Unique fingerprints found.<br>"
						var/list/fibers = outputs[2]
						if(fibers && fibers.len)
							temp += "&nbsp<b>Fibers:</b><br>"
							for(var/j = 1, j <= fibers.len, j++)
								temp += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[fibers[j]]<br>"
						var/list/blood = outputs[3]
						if(blood && blood.len)
							temp += "&nbsp<b>Blood:</b><br>"
							for(var/named in blood)
								temp += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type: [blood[named]], DNA: [named]<br>"
					temp += "<br><a href='?src=\ref[src];operation=database;delete_record=[href_list["identifier"]]'>{Delete this Dossier}</a>"
					temp += "<br><a href='?src=\ref[src];operation=databaseprint;identifier=[href_list["identifier"]]'>{Print}</a>"
				else
					temp = "ERROR.  Database not found!<br>"
				temp += "<br><a href='?src=\ref[src];operation=database'>{Return}</a>"
			if("databaseprint") //Printing from the "files" database.
				if(files)
					var/obj/item/weapon/paper/P = new(loc)
					P.name = "Database File (Dossier [files.Find(href_list["identifier"])])"
					P.overlays += "paper_words"
					P.info = "<b>Criminal Evidence Database</b><br><br>"
					P.info += "Consolidated data points: Dossier [href_list["identifier"]]<br>"
					var/list/dossier = files[href_list["identifier"]]
					var/print_string = "Fingerprints: Print not complete!<br>"
					if(stringpercent(dossier[1]) <= FINGERPRINT_COMPLETE)
						print_string = "Fingerprints: (80% or higher completion reached)<br>[dossier[1]]<br>"
					P.info += print_string
					for(var/object in dossier)
						if(object == dossier[1])
							continue
						P.info += "<hr>"
						var/list/outputs = dossier[object]
						var/list/prints_len = outputs[1]
						P.info += "<big><b>Object:</b> [outputs[4]]</big><br>"
						P.info += "&nbsp<b>Fingerprints:</b><br>"
						P.info += "&nbsp;&nbsp;&nbsp;&nbsp;[prints_len.len] Unique fingerprints found.<br>"
						var/list/fibers = outputs[2]
						if(fibers && fibers.len)
							P.info += "&nbsp<b>Fibers:</b><br>"
							for(var/j = 1, j <= fibers.len, j++)
								P.info += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[fibers[j]]<br>"
						var/list/blood = outputs[3]
						if(blood && blood.len)
							P.info += "&nbsp<b>Blood:</b><br>"
							for(var/named in blood)
								P.info += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type: [blood[named]], DNA: [named]<br>"
				else
					usr << "ERROR.  Database not found!<br>"
			if("auxiliary") //Viewing a record from the "misc" database.
				canclear = 0
				if(misc)
					temp = "<b>Auxiliary Evidence Database</b><br><br>"
					var/list/outputs = misc[href_list["identifier"]]
					temp += "<big><b>Consolidated data points:</b> [outputs[3]]</big><br>"
					var/list/fibers = outputs[1]
					if(fibers && fibers.len)
						temp += "&nbsp<b>Fibers:</b><br>"
						for(var/j = 1, j <= fibers.len, j++)
							temp += "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[fibers[j]]"
					var/list/blood = outputs[2]
					if(blood && blood.len)
						temp += "&nbsp<b>Blood:</b><br>"
						for(var/j = 1, j <= blood.len, j++)
							var/list/templist2 = blood[j]
							temp += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type: [templist2[2]], DNA: [templist2[1]]<br>"
					temp += "<br><a href='?src=\ref[src];operation=database;delete_aux=[href_list["identifier"]]'>{Delete This Record}</a>"
					temp += "<br><a href='?src=\ref[src];operation=auxiliaryprint;identifier=[href_list["identifier"]]'>{Print}</a>"
				else
					temp = "ERROR.  Database not found!<br>"
				temp += "<br><a href='?src=\ref[src];operation=database'>{Return}</a>"
			if("auxiliaryprint") //Printing from the "misc" database.
				if(misc)
					var/obj/item/weapon/paper/P = new(loc)
					var/list/outputs = misc[href_list["identifier"]]
					P.name = "Auxiliary Database File ([outputs[3]])"
					P.overlays += "paper_words"
					P.info = "<b>Auxiliary Evidence Database</b><br><br>"
					P.info += "<big><b>Consolidated data points:</b> [outputs[3]]</big><br>"
					var/list/fibers = outputs[1]
					if(fibers && fibers.len)
						P.info += "&nbsp<b>Fibers:</b><br>"
						for(var/j = 1, j <= fibers.len, j++)
							P.info += "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[fibers[j]]"
					var/list/blood = outputs[2]
					if(blood && blood.len)
						P.info += "&nbsp<b>Blood:</b><br>"
						for(var/j = 1, j <= blood.len, j++)
							var/list/templist2 = blood[j]
							P.info += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type: [templist2[2]], DNA: [templist2[1]]<br>"
				else
					usr << "ERROR.  Database not found!<br>"
			if("scan")
				if(istype(scanning,/obj/item/weapon/f_card))
					card = scanning
					scanning = initial(scanning)
					process_card()
				else if(scanning)
					scan_process = 3
					scan_data = "Scanning [scanning]: 25% complete"
					updateDialog()
					sleep(50)
					if(!scan_process)
						scan_data = null
						updateDialog()
						return
					scan_data = "Scanning [scanning]: 50% complete"
					updateDialog()
					scan_process = 2
					sleep(50)
					if(!scan_process)
						scan_data = null
						updateDialog()
						return
					scan_data = "Scanning [scanning]: 75% complete"
					updateDialog()
					scan_process = 1
					sleep(50)
					if(!scan_process)
						scan_data = null
						updateDialog()
						return
					if(scanning)
						scan_process = 0
						scan_name = scanning.name
						scan_data = "<u>[scanning]</u><br><br>"
						if (scanning.blood_DNA)
							scan_data += "Blood Found:<br>"
							for(var/blood in scanning.blood_DNA)
								scan_data += "Blood type: [scanning.blood_DNA[blood]]\nDNA: [blood]<br><br>"
						else
							scan_data += "No Blood Found<br><br>"
						if(!scanning.fingerprints)
							scan_data += "No Fingerprints Found<br><br>"
						else
							var/list/L = scanning.fingerprints
							scan_data += "Isolated [L.len] Fingerprints.  Loaded into database.<br>"
							add_data(scanning)

						if(!scanning.suit_fibers)
							/*if(istype(scanning,/obj/item/device/detective_scanner))
								var/obj/item/device/detective_scanner/scanner = scanning
								if(scanner.stored_name)
									scan_data += "Fibers/Materials Data - [scanner.stored_name]:<br>"
									for(var/data in scanner.stored_fibers)
										scan_data += "- [data]<br>"
								else
									scan_data += "No Fibers/Materials Data<br>"
							else*/
							scan_data += "No Fibers/Materials Located<br>"
						else
							/*if(istype(scanning,/obj/item/device/detective_scanner))
								var/obj/item/device/detective_scanner/scanner = scanning
								if(scanner.stored_name)
									scan_data += "Fibers/Materials Data - [scanner.stored_name]:<br>"
									for(var/data in scanner.stored_fibers)
										scan_data += "- [data]<br>"
								else
									scan_data += "No Fibers/Materials Data<br>"*/

							scan_data += "Fibers/Materials Found:<br>"
							for(var/data in scanning.suit_fibers)
								scan_data += "- [data]<br>"
						if(istype(scanning,/obj/item/device/detective_scanner))
							scan_data += "<br><b>Data transfered from Scanner to Database.</b><br>"
							add_data_scanner(scanning)
						else if(!scanning.fingerprints)
							scan_data += "<br><b><a href='?src=\ref[src];operation=add'>Add to Database?</a></b><br>"
				else
					temp = "Scan Failed: No Object"


			if("print") //Printing scan data
				if(scan_data)
					temp = "Scan Data Printed."
					var/obj/item/weapon/paper/P = new(loc)
					P.name = "Scan Data ([scan_name])"
					P.info = "<tt>[scan_data]</tt>"
					P.overlays += "paper_words"
				else
					temp = "Print Failed: No Data"
			if("erase")
				scan_data = ""
			if("cancel")
				scan_process = 0
			if("add") //Adding an object (Manually) to the database.
				if(scanning)
					add_data(scanning)
				else
					temp = "Data Transfer Failed: No Object."
		updateUsrDialog()

	ex_act()
		return


	proc/add_data_scanner(var/obj/item/device/detective_scanner/W)
		if(W.stored)
			for(var/atom in W.stored)
				var/list/data = W.stored[atom]
				add_data_master(atom,data[1],data[2],data[3],data[4])
		W.stored = list()
		return

	proc/add_data(var/atom/scanned_atom)
		return add_data_master("\ref [scanned_atom]", scanned_atom.fingerprints,\
		scanned_atom.suit_fibers, scanned_atom.blood_DNA, scanned_atom.name)



/********************************
*****DO NOT DIRECTLY CALL ME*****
********************************/
	proc/add_data_master(var/atom_reference, var/list/atom_fingerprints, var/list/atom_suit_fibers, var/list/atom_blood_DNA, var/atom_name)
//What follows is massive.  It cross references all stored data in the scanner with the other stored data,
//and what is already in the computer.  Not sure how bad the lag may/may not be.

		if(!atom_fingerprints)	//No prints
			if(!misc)
				misc = list()
			var/list/data_entry = misc[atom_reference]
			if(data_entry)
				var/list/fibers = data_entry[1]
				if(!fibers)
					fibers = list()
				if(atom_suit_fibers)
					for(var/j = 1, j <= atom_suit_fibers.len, j++)	//Fibers~~~
						if(!fibers.Find(atom_suit_fibers[j]))	//It isn't!  Add!
							fibers += atom_suit_fibers[j]
				var/list/blood = data_entry[2]
				if(!blood)
					blood = list()
				if(atom_blood_DNA)
					for(var/main_blood in atom_blood_DNA)
						if(!blood[main_blood])
							blood[main_blood] = atom_blood_DNA[blood]
				return 1
			var/list/templist[3]
			templist[1] = atom_suit_fibers
			templist[2] = atom_blood_DNA
			templist[3] = atom_name
			misc[atom_reference] = templist	//Store it!
			return 0
		//Has prints.
		if(!files)
			files = list()
		for(var/main_print in atom_fingerprints)
			var/list/data_entry = files[main_print]
			if(data_entry)//The print is already in here!
				var/list/internal_atom = data_entry[atom_reference] //Lets see if we can find the current object
				if(internal_atom)
					//We must be on a roll!  Just update what needs to be updated.
					var/list/internal_prints = internal_atom[1]
					for(var/print in atom_fingerprints) //Sorry for the double loop! D:
						var/associated_print = internal_prints[print]
						var/reference_print = atom_fingerprints[print]
						if(associated_print && associated_print != reference_print) //It does not match
							internal_prints[print] = stringmerge(associated_print, reference_print)
						else if(!associated_print)
							internal_prints[print] = reference_print
						//If the main print was updated, lets update the master as well.
						if(print == main_print && (!associated_print || (associated_print && associated_print != reference_print)))
							update_fingerprints(main_print, internal_prints[print])
					//Fibers.
					var/list/fibers = internal_atom[2]
					if(!fibers)
						fibers = list()
					if(atom_suit_fibers)
						for(var/j = 1, j < atom_suit_fibers.len, j++)	//Fibers~~~
							if(!fibers.Find(atom_suit_fibers[j]))	//It isn't!  Add!
								fibers += atom_suit_fibers[j]
					//Blood.
					var/list/blood = internal_atom[3]
					if(!blood)
						blood = list()
					if(atom_blood_DNA)
						for(var/main_blood in atom_blood_DNA)
							if(!blood[main_blood])
								blood[main_blood] = atom_blood_DNA[blood]

					continue
				//It's not in there!  We gotta add it.
				update_fingerprints(main_print, atom_fingerprints[main_print])
				var/list/data_point[4]
				data_point[1] = atom_fingerprints
				data_point[2] = atom_suit_fibers
				data_point[3] = atom_blood_DNA
				data_point[4] = atom_name
				data_entry[atom_reference] = data_point
				continue
			//No print at all!  New data entry, go!
			var/list/data_point[4]
			data_point[1] = atom_fingerprints
			data_point[2] = atom_suit_fibers
			data_point[3] = atom_blood_DNA
			data_point[4] = atom_name
			var/list/new_file[1]
			new_file[1] = atom_fingerprints[main_print]
			new_file[atom_reference] = data_point
			files[main_print] = new_file
		return 1
/********************************
***END DO NOT DIRECTLY CALL ME***
********************************/

	proc/update_fingerprints(var/ref_print, var/new_print)
		var/list/master = files[ref_print]
		if(master)
			master[1] = stringmerge(master[1],new_print)
		else
			CRASH("Fucking hell.  Something went wrong, and it tried to update a null print or something.  Tell SkyMarshal (and give him this call stack)")
		return

	proc/process_card()	//Same as above, but for fingerprint cards
		if(card.fingerprints && !(card.amount > 1) && islist(card.fingerprints) && files && files.len)
			usr << "You insert the card, and it is destroyed by the machinery in the process of comparing prints."
			var/found = 0
			for(var/master_print in card.fingerprints)
				var/list/data_entry = files[master_print]
				if(data_entry)
					found = 1
					data_entry[1] = master_print
			if(found)
				usr << "The machinery finds it can complete a match."
			else
				usr << "No match found."
			del(card)
		else
			usr << "\red ERROR: No prints/too many cards."
			if(card.loc == src)
				card.loc = src.loc
			card = null
			return
		return

	proc/delete_record(var/atom_ref)	//Deletes an entry in the misc database at the given location
		if(misc && misc.len)
			misc.Remove(atom_ref)
		return

	proc/delete_dossier(var/print)	//Deletes a Dossier at a given location.
		if(files && files.len)
			files.Remove(print)
		return

	detective
		icon_state = "old"
		name = "PowerScan Mk.I"

obj/item/clothing/shoes/var
	track_blood = 0
	mob/living/carbon/human/track_blood_mob
	track_blood_type
mob/var
	bloody_hands = 0
	mob/living/carbon/human/bloody_hands_mob
	track_blood
	mob/living/carbon/human/track_blood_mob
	track_blood_type
obj/item/clothing/gloves/var
	transfer_blood = 0
	mob/living/carbon/human/bloody_hands_mob


obj/effect/decal/cleanable/var
	track_amt = 3
	mob/blood_owner

turf/Exited(mob/living/carbon/human/M)
	if(istype(M,/mob/living) && !istype(M,/mob/living/carbon/metroid))
		if(!istype(src, /turf/space))  // Bloody tracks code starts here
			var/dofoot = 1
			if(istype(M,/mob/living/simple_animal))
				if(!(istype(M,/mob/living/simple_animal/cat) || istype(M,/mob/living/simple_animal/corgi) || istype(M,/mob/living/simple_animal/constructwraith)))
					dofoot = 0

			if(dofoot)

				if(!istype(src, /turf/space))  // Bloody tracks code starts here
					if(M.track_blood > 0)
						M.track_blood--
						src.add_bloody_footprints(M.track_blood_mob,1,M.dir,get_tracks(M),M.track_blood_type)
					else if(istype(M,/mob/living/carbon/human))
						if(M.shoes)
							if(M.shoes.track_blood > 0)
								M.shoes.track_blood--
								src.add_bloody_footprints(M.shoes.track_blood_mob,1,M.dir,M.shoes.name,M.shoes.track_blood_type) // And bloody tracks end here
		. = ..()
turf/Entered(mob/living/carbon/human/M)
	if(istype(M,/mob/living) && !istype(M,/mob/living/carbon/metroid))
		var/dofoot = 1
		if(istype(M,/mob/living/simple_animal))
			if(!(istype(M,/mob/living/simple_animal/cat) || istype(M,/mob/living/simple_animal/corgi) || istype(M,/mob/living/simple_animal/constructwraith)))
				dofoot = 0

		if(dofoot)

			if(M.track_blood > 0)
				M.track_blood--
				src.add_bloody_footprints(M.track_blood_mob,0,M.dir,get_tracks(M),M.track_blood_type)
			else if(istype(M,/mob/living/carbon/human))
				if(M.shoes && !istype(src,/turf/space))
					if(M.shoes.track_blood > 0)
						M.shoes.track_blood--
						src.add_bloody_footprints(M.shoes.track_blood_mob,0,M.dir,M.shoes.name,M.shoes.track_blood_type)


			for(var/obj/effect/decal/cleanable/B in src)
				if(B:track_amt <= 0) continue
				if(B.type != /obj/effect/decal/cleanable/blood/tracks)
					if(istype(B, /obj/effect/decal/cleanable/xenoblood) || istype(B, /obj/effect/decal/cleanable/blood) || istype(B, /obj/effect/decal/cleanable/oil) || istype(B, /obj/effect/decal/cleanable/robot_debris))

						var/track_type = "blood"
						if(istype(B, /obj/effect/decal/cleanable/xenoblood))
							track_type = "xeno"
						else if(istype(B, /obj/effect/decal/cleanable/oil) || istype(B, /obj/effect/decal/cleanable/robot_debris))
							track_type = "oil"

						if(istype(M,/mob/living/carbon/human))
							if(M.shoes)
								M.shoes.add_blood(B.blood_owner)
								M.shoes.track_blood_mob = B.blood_owner
								M.shoes.track_blood = max(M.shoes.track_blood,8)
								M.shoes.track_blood_type = track_type
						else
							M.add_blood(B.blood_owner)
							M.track_blood_mob = B.blood_owner
							M.track_blood = max(M.track_blood,rand(4,8))
							M.track_blood_type = track_type
						B.track_amt--
						break
	. = ..()

turf/proc/add_bloody_footprints(mob/living/carbon/human/M,leaving,d,info,bloodcolor)
	for(var/obj/effect/decal/cleanable/blood/tracks/T in src)
		if(T.dir == d && findtext(T.icon_state, bloodcolor))
			if((leaving && T.icon_state == "steps2") || (!leaving && T.icon_state == "steps1"))
				T.desc = "These bloody footprints appear to have been made by [info]."
				if(!T.blood_DNA)
					T.blood_DNA = list()
				if(istype(M,/mob/living/carbon/human))
					T.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
				else if(istype(M,/mob/living/carbon/alien))
					T.blood_DNA["UNKNOWN DNA"] = "X*"
				else if(istype(M,/mob/living/carbon/monkey))
					T.blood_DNA["Non-human DNA"] = "A+"
				return
	var/obj/effect/decal/cleanable/blood/tracks/this = new(src)
	this.icon = 'footprints.dmi'

	var/preiconstate = ""

	if(info == "animal paws")
		preiconstate = "paw"
	else if(info == "alien claws")
		preiconstate = "claw"
	else if(info == "small alien feet")
		preiconstate = "paw"

	if(leaving)
		this.icon_state = "[bloodcolor][preiconstate]2"
	else
		this.icon_state = "[bloodcolor][preiconstate]1"
	this.dir = d

	if(bloodcolor == "blood")
		this.desc = "These bloody footprints appear to have been made by [info]."
	else if(bloodcolor == "xeno")
		this.desc = "These acidic bloody footprints appear to have been made by [info]."
	else if(bloodcolor == "oil")
		this.name = "oil"
		this.desc = "These oil footprints appear to have been made by [info]."

	if(istype(M,/mob/living/carbon/human))
		if(!this.blood_DNA)
			this.blood_DNA = list()
		this.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type

proc/get_tracks(mob/M)
	if(istype(M,/mob/living))
		if(istype(M,/mob/living/carbon/human))
			. = "human feet"
		else if(istype(M,/mob/living/carbon/monkey) || istype(M,/mob/living/simple_animal/cat) || istype(M,/mob/living/simple_animal/corgi) || istype(M,/mob/living/simple_animal/crab))
			. = "animal paws"
		else if(istype(M,/mob/living/silicon/robot))
			. = "robot feet"
		else if(istype(M,/mob/living/carbon/alien/humanoid))
			. = "alien claws"
		else if(istype(M,/mob/living/carbon/alien/larva))
			. = "small alien feet"
		else
			. = "an unknown creature"


proc/blood_incompatible(donor,receiver)
	var
		donor_antigen = copytext(donor,1,lentext(donor))
		receiver_antigen = copytext(receiver,1,lentext(receiver))
		donor_rh = findtext("+",donor)
		receiver_rh = findtext("+",receiver)
	if(donor_rh && !receiver_rh) return 1
	switch(receiver_antigen)
		if("A")
			if(donor_antigen != "A" && donor_antigen != "O") return 1
		if("B")
			if(donor_antigen != "B" && donor_antigen != "O") return 1
		if("O")
			if(donor_antigen != "O") return 1
		//AB is a universal receiver.
	return 0

/obj/item/weapon/rag
	New() // So I don't have to grab maplock
		spawn(1)
			new/obj/item/weapon/reagent_containers/glass/rag(loc)
			del src

/obj/item/weapon/reagent_containers/glass/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = 1
	icon = 'toy.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5)
	volume = 5
	can_be_placed_into = null

	attack(atom/target as obj|turf|area, mob/user as mob , flag)
		if(ismob(target) && target.reagents && reagents.total_volume)
			user.visible_message("\red \The [target] has been smothered with \the [src] by \the [user]!", "\red You smother \the [target] with \the [src]!", "You hear some struggling and muffled cries of surprise")
			src.reagents.reaction(target, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return
		else
			..()

	afterattack(atom/A as obj|turf|area, mob/user as mob)
		if(istype(A) && src in user)
			user.visible_message("[user] starts to wipe down [A] with [src]!")
			if(do_after(user,30))
				user.visible_message("[user] finishes wiping off the [A]!")
				A.clean_blood()
		return

	examine()
		if (!usr)
			return
		usr << "That's \a [src]."
		usr << desc
		return
