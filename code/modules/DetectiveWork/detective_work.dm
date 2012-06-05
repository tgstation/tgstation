//CONTAINS: Suit fibers and Detective's Scanning Computer

atom/var/list/suit_fibers

atom/proc/add_fibers(mob/living/carbon/human/M)
	if(M.gloves && istype(M.gloves,/obj/item/clothing/))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.transfer_blood) //bloodied gloves transfer blood to touched objects
			if(add_blood(G.bloody_hands_mob)) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				G.transfer_blood--
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
	name = "\improper High-Res Forensic Scanning Computer"
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
				if (allowed(M))
					authenticated = 1
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
						for(var/print in files)
							var/list/file = files[print]
							temp += "<a href='?src=\ref[src];operation=record;identifier=[print]'>{[file[2]]}</a><br>"
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
					var/list/dossier = files[href_list["identifier"]]
					if(href_list["ren"])
						var/new_title = copytext(sanitize(input("Rename to what?", "Dossier Editing", "Dossier [files.Find(href_list["identifier"])]") as null|text),1,MAX_MESSAGE_LEN)
						if(new_title)
							dossier[2] = new_title
						else
							usr << "Illegal or blank name."
					temp = "<b>Criminal Evidence Database</b><br><br>"
					temp += "Consolidated data points: [dossier[2]]<br>"
					var/print_string = "Fingerprints: Print not complete!<br>"
					if(stringpercent(dossier[1]) <= FINGERPRINT_COMPLETE)
						print_string = "Fingerprints: (80% or higher completion reached)<br>[dossier[1]]<br>"
					temp += print_string
					for(var/object in dossier)
						if(object == dossier[1] || object == dossier[2])
							continue
						temp += "<hr>"
						var/list/outputs = dossier[object]
						var/list/prints = outputs[1]
						temp += "<big><b>Object:</b> [outputs[4]]</big><br>"
						temp += "&nbsp<b>Fingerprints:</b><br>"
						temp += "&nbsp;&nbsp;&nbsp;&nbsp;[prints.len] Unique fingerprints found.<br>"
						var/complete_prints = 0
						for(var/print in prints)
							if(stringpercent(prints[print]) <= FINGERPRINT_COMPLETE)
								complete_prints++
								temp += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[prints[print]]<br>"
						if(complete_prints)
							temp += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;And [prints.len - complete_prints] unknown unique prints.<br>"
						else
							temp += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;No prints of sufficient completeness.<br>"
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
					temp += "<br><a href='?src=\ref[src];operation=record;identifier=[href_list["identifier"]];ren=true'>{Rename this Dossier}</a>"
					temp += "<br><a href='?src=\ref[src];operation=database;delete_record=[href_list["identifier"]]'>{Delete this Dossier}</a>"
					temp += "<br><a href='?src=\ref[src];operation=databaseprint;identifier=[href_list["identifier"]]'>{Print}</a>"
				else
					temp = "ERROR.  Database not found!<br>"
				temp += "<br><a href='?src=\ref[src];operation=database'>{Return}</a>"
			if("databaseprint") //Printing from the "files" database.
				if(files)
					var/obj/item/weapon/paper/P = new(loc)
					P.name = "\improper Database File (Dossier [files.Find(href_list["identifier"])])"
					P.overlays += "paper_words"
					P.info = "<b>Criminal Evidence Database</b><br><br>"
					var/list/dossier = files[href_list["identifier"]]
					P.info += "Consolidated data points: [dossier[2]]<br>"
					var/print_string = "Fingerprints: Print not complete!<br>"
					if(stringpercent(dossier[1]) <= FINGERPRINT_COMPLETE)
						print_string = "Fingerprints: (80% or higher completion reached)<br>[dossier[1]]<br>"
					P.info += print_string
					for(var/object in dossier)
						if(object == dossier[1] || object == dossier[2])
							continue
						P.info += "<hr>"
						var/list/outputs = dossier[object]
						var/list/prints = outputs[1]
						P.info += "<big><b>Object:</b> [outputs[4]]</big><br>"
						P.info += "&nbsp<b>Fingerprints:</b><br>"
						P.info += "&nbsp;&nbsp;&nbsp;&nbsp;[prints.len] Unique fingerprints found.<br>"
						var/complete_prints = 0
						for(var/print in prints)
							if(stringpercent(prints[print]) <= FINGERPRINT_COMPLETE)
								complete_prints++
								P.info += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[prints[print]]<br>"
						if(complete_prints)
							P.info += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;And [prints.len - complete_prints] unknown unique prints.<br>"
						else
							P.info += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;No prints of sufficient completeness.<br>"
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
					var/list/prints = outputs[4]
					if(prints)
						temp += "&nbsp<b>Fingerprints:</b><br>"
						temp += "&nbsp;&nbsp;&nbsp;&nbsp;[prints.len] Unique fingerprints found.<br>"
						var/complete_prints = 0
						for(var/print in prints)
							if(stringpercent(prints[print]) <= FINGERPRINT_COMPLETE)
								complete_prints++
								temp += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[prints[print]]<br>"
						if(complete_prints)
							temp += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;And [prints.len - complete_prints] unknown unique prints.<br>"
						else
							temp += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;No prints of sufficient completeness.<br>"
					var/list/fibers = outputs[1]
					if(fibers && fibers.len)
						temp += "&nbsp<b>Fibers:</b><br>"
						for(var/fiber in fibers)
							temp += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[fiber]<br>"
					var/list/blood = outputs[2]
					if(blood && blood.len)
						temp += "&nbsp<b>Blood:</b><br>"
						for(var/named in blood)
							temp += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type: [blood[named]], DNA: [named]<br>"
					temp += "<br><a href='?src=\ref[src];operation=database;delete_aux=[href_list["identifier"]]'>{Delete This Record}</a>"
					temp += "<br><a href='?src=\ref[src];operation=auxiliaryprint;identifier=[href_list["identifier"]]'>{Print}</a>"
				else
					temp = "ERROR.  Database not found!<br>"
				temp += "<br><a href='?src=\ref[src];operation=database'>{Return}</a>"
			if("auxiliaryprint") //Printing from the "misc" database.
				if(misc)
					var/obj/item/weapon/paper/P = new(loc)
					var/list/outputs = misc[href_list["identifier"]]
					P.name = "\improper Auxiliary Database File ([outputs[3]])"
					P.overlays += "paper_words"
					P.info = "<b>Auxiliary Evidence Database</b><br><br>"
					P.info += "<big><b>Consolidated data points:</b> [outputs[3]]</big><br>"
					var/list/prints = outputs[4]
					if(prints)
						P.info += "&nbsp<b>Fingerprints:</b><br>"
						P.info += "&nbsp;&nbsp;&nbsp;&nbsp;[prints.len] Unique fingerprints found.<br>"
						var/complete_prints = 0
						for(var/print in prints)
							if(stringpercent(prints[print]) <= FINGERPRINT_COMPLETE)
								complete_prints++
								P.info += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[prints[print]]<br>"
						if(complete_prints)
							P.info += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;And [prints.len - complete_prints] unknown unique prints.<br>"
						else
							P.info += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;No prints of sufficient completeness.<br>"
					var/list/fibers = outputs[1]
					if(fibers && fibers.len)
						P.info += "&nbsp<b>Fibers:</b><br>"
						for(var/fiber in fibers)
							P.info += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[fiber]<br>"
					var/list/blood = outputs[2]
					if(blood && blood.len)
						P.info += "&nbsp<b>Blood:</b><br>"
						for(var/named in blood)
							P.info += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type: [blood[named]], DNA: [named]<br>"
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
							scan_data += "Isolated [scanning.fingerprints.len] Fingerprints.  Loaded into database.<br>"
							add_data(scanning)

						if(!scanning.suit_fibers)
							scan_data += "No Fibers/Materials Located<br>"
						else
							scan_data += "Fibers/Materials Found:<br>"
							for(var/data in scanning.suit_fibers)
								scan_data += "- [data]<br>"
						if(istype(scanning,/obj/item/device/detective_scanner) || (istype(scanning, /obj/item/device/pda) && scanning:cartridge && scanning:cartridge.access_security))
							scan_data += "<br><b>Data transfered from \the [scanning] to Database.</b><br>"
							add_data_scanner(scanning)
						else if(!scanning.fingerprints)
							scan_data += "<br><b><a href='?src=\ref[src];operation=add'>Add to Database?</a></b><br>"
				else
					temp = "Scan Failed: No Object"


			if("print") //Printing scan data
				if(scan_data)
					temp = "Scan Data Printed."
					var/obj/item/weapon/paper/P = new(loc)
					P.name = "\improper Scan Data ([scan_name])"
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
			if("rename")
				if(!files || !files[href_list["identifier"]])
					temp = "ERROR: Record/Database not found!"
				else
					var/new_title = copytext(sanitize(input("Rename to what?", "Dossier Editing", "Dossier [files.Find(href_list["identifier"])]") as null|text),1,MAX_MESSAGE_LEN)
					if(new_title)
						var/list/file = files[href_list["identifier"]]
						file[2] = new_title
		updateUsrDialog()

	ex_act()
		return


	proc/add_data_scanner(var/obj/item/device/W)
		if(istype(W, /obj/item/device/detective_scanner))
			if(W:stored)
				for(var/atom in W:stored)
					var/list/data = W:stored[atom]
					add_data_master(atom,data[1],data[2],data[3],data[4])
			W:stored = list()
		else if(istype(W, /obj/item/device/pda) && W:cartridge && W:cartridge.access_security)
			if(W:cartridge.stored_data)
				for(var/atom in W:cartridge.stored_data)
					var/list/data = W:cartridge.stored_data[atom]
					add_data_master(atom,data[1],data[2],data[3],data[4])
			W:cartridge.stored_data = list()
		return

	proc/add_data(var/atom/scanned_atom)
		return add_data_master("\ref [scanned_atom]", scanned_atom.fingerprints,\
		scanned_atom.suit_fibers, scanned_atom.blood_DNA, "[scanned_atom.name] (Direct Scan)")



/********************************
*****DO NOT DIRECTLY CALL ME*****
********************************/
	proc/add_data_master(var/atom_reference, var/list/atom_fingerprints, var/list/atom_suit_fibers, var/list/atom_blood_DNA, var/atom_name)
//What follows is massive.  It cross references all stored data in the scanner with the other stored data,
//and what is already in the computer.  Not sure how bad the lag may/may not be.

		if(!misc)
			misc = list()
		var/list/data_entry = misc[atom_reference]
		if(data_entry)
			var/list/fibers = data_entry[1]
			if(!fibers)
				fibers = list()
			if(atom_suit_fibers)
				for(var/fiber in atom_suit_fibers)	//Fibers~~~
					if(!fibers.Find(fiber))	//It isn't!  Add!
						fibers += fiber
			var/list/blood = data_entry[2]
			if(!blood)
				blood = list()
			if(atom_blood_DNA)
				for(var/main_blood in atom_blood_DNA)
					if(!blood[main_blood])
						blood[main_blood] = atom_blood_DNA[blood]
			var/list/prints = data_entry[4]
			if(!prints && atom_fingerprints)
				prints = list()
			if(atom_fingerprints)
				for(var/print in atom_fingerprints)
					if(!prints[print])
						prints[print] = atom_fingerprints[print]
		else
			var/list/templist[4]
			templist[1] = atom_suit_fibers
			templist[2] = atom_blood_DNA
			templist[3] = atom_name
			templist[4] = atom_fingerprints
			misc[atom_reference] = templist	//Store it!
		//Has prints.
		if(atom_fingerprints)
			if(!files)
				files = list()
			for(var/main_print in atom_fingerprints)
				data_entry = files[main_print]
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
							for(var/fiber in atom_suit_fibers)	//Fibers~~~
								if(!fibers.Find(fiber))	//It isn't!  Add!
									fibers += fiber
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
				var/list/new_file[2]
				new_file[1] = atom_fingerprints[main_print]
				new_file[2] = "Dossier [files.len + 1]"
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