//gloves w_uniform wear_suit shoes

atom/var/list/suit_fibers

atom/proc/add_fibers(mob/living/carbon/human/M)
	if(M.gloves)
		if(M.gloves.transfer_blood)
			if(add_blood(M.gloves.bloody_hands_mob))
				M.gloves.transfer_blood--
				//world.log << "[M.gloves] added blood to [src] from [M.gloves.bloody_hands_mob]"
	else if(M.bloody_hands)
		if(add_blood(M.bloody_hands_mob))
			M.bloody_hands--
			//world.log << "[M] added blood to [src] from [M.bloody_hands_mob]"
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

#define FINGERPRINT_COMPLETE 6	//This is the output of the stringpercent(print) proc, and means about 80% of
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


	ex_act()
		return


	proc/add_data_scanner(var/obj/item/device/detective_scanner/W)
		for(var/i = 1, i < (W.stored.len + 1), i++)
			var/list/data = W.stored[i]
			add_data(data[1],1,data[2],data[3],data[4])


	proc/add_data(var/atom/A, var/override = 0, var/tempfingerprints, var/tempsuit_fibers,var/tempblood_DNA)
//What follows is massive.  It cross references all stored data in the scanner with the other stored data,
//and what is already in the computer.  Not sure how bad the lag may/may not be.
		var
			backup_prints
			backup_fibers
			backup_DNA
		if(override)
			backup_prints = A.fingerprints
			A.fingerprints = tempfingerprints
			backup_fibers = A.suit_fibers
			A.suit_fibers = tempsuit_fibers
			backup_DNA = A.blood_DNA
			A.blood_DNA = tempblood_DNA
		if((!A.fingerprints || !length(A.fingerprints)))	//No prints
			var/merged = 0
			if(!misc)
				misc = list()
			if(misc)
				for(var/i = 1, i < (misc.len + 1), i++)	//Lets see if we can find it.
					var/list/templist = misc[i]
					var/check = templist[1]
					if(check == A) //There it is!
						merged = 1
						var/list/fibers = templist[2]
						if(!fibers)
							fibers = list()
						if(A.suit_fibers)
							for(var/j = 1, j < (A.suit_fibers.len + 1), j++)	//Fibers~~~
								if(!fibers.Find(A.suit_fibers[j]))	//It isn't!  Add!
									fibers += A.suit_fibers[j]
						var/list/blood = templist[3]
						if(!blood)
							blood = list()
						if(A.blood_DNA)
							for(var/j = 1, j < (A.blood_DNA.len + 1), j++)	//Blood~~~
								if(!blood.Find(A.blood_DNA[j]))	//It isn't!  Add!
									blood += A.blood_DNA[j]
						var/list/sum_list[3]	//Pack it back up!
						sum_list[1] = A
						sum_list[2] = fibers
						sum_list[3] = blood
						misc[i] = sum_list	//Store it!
						break	//We found it, we're done here.
			if(!merged)	//Nope!  Guess we have to add it!
				var/list/templist[4]
				templist[1] = A
				templist[2] = A.suit_fibers
				templist[3] = A.blood_DNA
				misc.len++
				misc[misc.len] = templist	//Store it!
			return !merged
		else //Has prints.
			var/list/found_prints[A.fingerprints.len + 1]
			for(var/i = 1, i < (found_prints.len + 1), i++)
				found_prints[i] = 0
			if(!files)
				files = list()
			for(var/i = 1, i < (files.len + 1), i++)	//Lets see if we can find the owner of the prints
				var/list/perp_list = files[i]
				var/list/perp_prints = params2list(perp_list[1])
				var/perp = perp_prints[1]
				var/found2 = 0
				for(var/m = 1, m < (A.fingerprints.len + 1), m++)	//Compare database prints with prints on object.
					var/list/test_prints_list = params2list(A.fingerprints[m])
					var/checker = test_prints_list[1]
					if(checker == perp)	//Found 'em!  Merge!
						found_prints[m] = 1
						for(var/n = 2, n < (perp_list.len + 1), n++)	//Lets see if it is already in the database
							var/list/target = perp_list[n]
							if(target[1] == A)	//Found the original object!
								found2 = 1
								var/list/prints = target[2]
								if(!prints)
									prints = list()
								if(A.fingerprints)
									for(var/j = 1, j < (A.fingerprints.len + 1), j++)	//Fingerprints~~~
										var/list/print_test1 = params2list(A.fingerprints[j])
										var/test_print1 = print_test1[1]
										var/found = 0
										for(var/k = 1, k <= (prints.len + 1), k++)	//Lets see if the print is already in there
											var/list/print_test2 = params2list(prints[k])
											var/test_print2 = print_test2[1]
											if(test_print2 == test_print1)	//It is!  Merge!
												prints[k] = test_print2 + "&" + stringmerge(print_test2[2],print_test1[2])
												found = 1
												break	//We found it, we're done here.
										if(!found)	//It isn't!  Add!
											prints += A.fingerprints[j]
								var/list/fibers = target[3]
								if(!fibers)
									fibers = list()
								if(A.suit_fibers)
									for(var/j = 1, j < A.suit_fibers.len, j++)	//Fibers~~~
										if(!fibers.Find(A.suit_fibers[j]))	//It isn't!  Add!
											fibers += A.suit_fibers[j]
								var/list/blood = target[4]
								if(!blood)
									blood = list()
								if(A.blood_DNA)
									for(var/j = 1, j < A.blood_DNA.len, j++)	//Blood~~~
										if(!blood.Find(A.blood_DNA[j]))	//It isn't!  Add!
											blood += A.blood_DNA[j]
								var/list/sum_list[4]	//Pack it back up!
								sum_list[1] = A
								sum_list[2] = prints
								sum_list[3] = fibers
								sum_list[4] = blood
								perp_list[n] = sum_list	//Store it!
								files[i] = perp_list
								break	//We found it, we're done here.
						if(!found2) //Add a new datapoint to this perp!
							var/list/sum_list[4]
							sum_list[1] = A
							sum_list[2] = A.fingerprints
							sum_list[3] = A.suit_fibers
							sum_list[4] = A.blood_DNA
							perp_list.len++
							perp_list[perp_list.len] = sum_list
							files[i] = perp_list
			for(var/m = 1, m < found_prints.len, m++)	//Uh Oh!  A print wasn't used!  New datapoint!
				if(found_prints[m] == 0)
					var/list/newperp[2]
					var/list/sum_list[4]
					sum_list[1] = A
					sum_list[2] = A.fingerprints
					sum_list[3] = A.suit_fibers
					sum_list[4] = A.blood_DNA
					newperp[2] = sum_list
					newperp[1] = A.fingerprints[m]
					if(!files)
						files = newperp
					else
						files.len++
						files[files.len] = newperp
			update_fingerprints()	//Lets update the calculated sum of the stored prints.
			if(override)
				A.fingerprints = backup_prints
				A.suit_fibers = backup_fibers
				A.blood_DNA = backup_DNA
			return


	proc/update_fingerprints()	//I am tired, but this updates the master print, which is used to determine completion of a print.
		for(var/k = 1, k < (files.len + 1), k++)
			var/list/perp_list = files[k]
			var/list/perp_prints = params2list(perp_list[1])
			var/perp = perp_prints[1]
			var/list/found_prints = list()
			for(var/i = 2, i < (perp_list.len + 1), i++)
				var/list/test_list = perp_list[i]
				var/list/test_prints = test_list[2]
				for(var/j = 1, j < (test_prints.len + 1), j++)
					var/list/test_list_2 = params2list(test_prints[j])
					var/test_prints_2 = test_list_2[1]
					if(test_prints_2 == perp)
						found_prints += test_list_2[2]
						break
			for(var/prints in found_prints)
				perp_prints[2] = stringmerge(perp_prints[2],prints)
			perp_list[1] = perp + "&" + perp_prints[2]
			files[k] = perp_list
		return

	proc/process_card()	//I am tired, but this updates the master print from a fingerprint card
						//which is used to determine completion of a print.
		if(card.fingerprints)
			for(var/k = 1, k < (card.fingerprints.len + 1), k++)
				var/list/test_prints = params2list(card.fingerprints[k])
				var/print = test_prints[1]
				for(var/i = 1, i < (files.len + 1), i++)
					var/list/test_list = files[i]
					var/list/perp_prints = params2list(test_list[1])
					var/perp = perp_prints[1]
					if(perp == print)
						test_list[1] = print + "&" + print
						files[i] = test_list
						break
		del(card)
		return

	proc/get_name(var/atom/A)
		return A.name

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
					temp = "Invalid Object Rejected."
			if("card")
				var/mob/M = usr
				var/obj/item/I = M.equipped()
				if(I && istype(I,/obj/item/weapon/f_card))
					card = I
					M.drop_item()
					I.loc = src
					process_card()
					usr << "You insert the card, and it is destroyed by the machinery in the process of comparing prints."
				else
					usr << "\red Invalid Object Rejected."
			if("database")
				canclear = 1
				if(!misc && !files)
					temp = "Database is empty."
				else
					if(files)
						temp = "<b>Criminal Evidence Database</b><br><br>"
						temp += "Consolidated data points:<br>"
						for(var/i = 1, i < (files.len + 1), i++)
							temp += "<a href='?src=\ref[src];operation=record;identifier=[i]'>{Dossier [i]}</a><br>"
						temp += "<br><a href='?src=\ref[src];operation=card'>{Insert Finger Print Card}</a><br><br><br>"
					else
						temp = ""
					if(misc)
						temp += "<b>Auxiliary Evidence Database</b><br><br>"
						temp += "This is where anything without fingerprints goes.<br><br>"
						for(var/i = 1, i < (misc.len + 1), i++)
							var/list/temp_list = misc[i]
							var/item_name = get_name(temp_list[1])
							temp += "<a href='?src=\ref[src];operation=auxiliary;identifier=[i]'>{[item_name]}</a><br>"
			if("record")
				canclear = 0
				if(files)
					temp = "<b>Criminal Evidence Database</b><br><br>"
					temp += "Consolidated data points: Dossier [href_list["identifier"]]<br>"
					var/identifier = text2num(href_list["identifier"])
					var/list/dossier = files[identifier]
					var/list/prints = params2list(dossier[1])
					var/print_string = "Fingerprints: Print not complete!<br>"
					if(stringpercent(prints[2]) <= FINGERPRINT_COMPLETE)
						print_string = "Fingerprints: (80% or higher completion reached)<br>" + prints[2] + "<br>"
					temp += print_string
					for(var/i = 2, i < (dossier.len + 1), i++)
						var/list/outputs = dossier[i]
						var/item_name = get_name(outputs[1])
						var/list/prints_len = outputs[2]
						temp += "Object: [item_name]<br>"
						temp += "&nbsp;&nbsp;&nbsp;&nbsp;[prints_len.len] Unique fingerprints found.<br>"
						var/list/fibers = outputs[3]
						if(fibers)
							var/dat = "[fibers[1]]"
							for(var/j = 2, j < (fibers.len + 1), j++)
								dat += ",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[fibers[j]]"
							temp += "&nbsp;&nbsp;&nbsp;&nbsp;Fibers: [dat]<br>"
						else
							temp += "&nbsp;&nbsp;&nbsp;&nbsp;No fibers found.<br>"
						var/list/blood = outputs[4]
						if(blood)
							var/dat = "[blood[1]]"
							if(blood.len > 1)
								for(var/j = 2, j < (blood.len + 1), j++)
									dat += ",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[blood[j]]"
							temp += "&nbsp;&nbsp;&nbsp;&nbsp;Blood: [dat]<br>"
						else
							temp += "&nbsp;&nbsp;&nbsp;&nbsp;No blood found.<br>"
				else
					temp = "ERROR.  Database not found!<br>"
				temp += "<br><a href='?src=\ref[src];operation=databaseprint;identifier=[href_list["identifier"]]'>{Print}</a>"
				temp += "<br><a href='?src=\ref[src];operation=database'>{Return}</a>"
			if("databaseprint")
				if(files)
					var/obj/item/weapon/paper/P = new(loc)
					P.name = "Database File (Dossier [href_list["identifier"]])"
					P.overlays += "paper_words"
					P.info = "<b>Criminal Evidence Database</b><br><br>"
					P.info += "Consolidated data points: Dossier [href_list["identifier"]]<br>"
					var/list/dossier = files[text2num(href_list["identifier"])]
					var/list/prints = params2list(dossier[1])
					var/print_string = "Fingerprints: Print not complete!<br>"
					if(stringpercent(prints[2]) <= FINGERPRINT_COMPLETE)
						print_string = "Fingerprints: " + prints[2] + "<BR>"
					P.info += print_string
					for(var/i = 2, i < (dossier.len + 1), i++)
						var/list/outputs = dossier[i]
						var/item_name = get_name(outputs[1])
						var/list/prints_len = outputs[2]
						P.info += "Object: [item_name]<br>"
						P.info += "&nbsp;&nbsp;&nbsp;&nbsp;[prints_len.len] Unique fingerprints found.<br>"
						var/list/fibers = outputs[3]
						if(fibers)
							var/dat = "[fibers[1]]"
							for(var/j = 2, j < (fibers.len + 1), j++)
								dat += ",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[fibers[j]]"
							P.info += "&nbsp;&nbsp;&nbsp;&nbsp;Fibers: [dat]<br>"
						else
							P.info += "&nbsp;&nbsp;&nbsp;&nbsp;No fibers found.<br>"
						var/list/blood = outputs[4]
						if(blood)
							var/dat = "[blood[1]]"
							if(blood.len > 1)
								for(var/j = 2, j < (blood.len + 1), j++)
									dat += ",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[blood[j]]"
							P.info += "&nbsp;&nbsp;&nbsp;&nbsp;Blood: [dat]<br>"
						else
							P.info += "&nbsp;&nbsp;&nbsp;&nbsp;No blood found."
				else
					usr << "ERROR.  Database not found!<br>"
			if("auxiliary")
				canclear = 0
				if(misc)
					temp = "<b>Auxiliary Evidence Database</b><br><br>"
					var/identifier = text2num(href_list["identifier"])
					var/list/outputs = misc[identifier]
					var/item_name = get_name(outputs[1])
					temp += "Consolidated data points: [item_name]<br>"
					var/list/fibers = outputs[2]
					if(fibers)
						var/dat = "[fibers[1]]"
						for(var/j = 2, j < (fibers.len + 1), j++)
							dat += ",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[fibers[j]]"
						temp += "&nbsp;&nbsp;&nbsp;&nbsp;Fibers: [dat]<br>"
					else
						temp += "&nbsp;&nbsp;&nbsp;&nbsp;No fibers found."
					var/list/blood = outputs[3]
					if(blood)
						var/dat = "[blood[1]]"
						for(var/j = 2, j < (blood.len + 1), j++)
							dat += ",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[blood[j]]"
						temp += "&nbsp;&nbsp;&nbsp;&nbsp;Blood: [dat]<br>"
					else
						temp += "&nbsp;&nbsp;&nbsp;&nbsp;No blood found.<br>"
				else
					temp = "ERROR.  Database not found!<br>"
				temp += "<br><a href='?src=\ref[src];operation=database'>{Return}</a>"
			if("scan")
				if(scanning)
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
					scan_process = 0
					scan_name = scanning.name
					scan_data = "<u>[scanning]</u><br><br>"
					if (scanning.blood_DNA)
						scan_data += "Blood Found:<br>"
						for(var/i = 1, i < (scanning.blood_DNA.len + 1), i++)
							var/list/templist = scanning.blood_DNA[i]
							scan_data += "-Blood type: [templist[2]]\nDNA: [templist[1]]<br><br>"
					else
						scan_data += "No Blood Found<br><br>"
					if (!length(scanning.fingerprints))
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
					else if(!length(scanning.fingerprints))
						scan_data += "<br><b><a href='?src=\ref[src];operation=add'>Add to Database?</a></b><br>"
				else
					temp = "Scan Failed: No Object"


			if("print")
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
			if("add")
				if(scanning)
					add_data(scanning)
				else
					temp = "Data Transfer Failed: No Object."
		updateUsrDialog()

	detective
		icon_state = "old"
		name = "PowerScan Mk.I"

obj/item/clothing/shoes/var
	track_blood = 0
	mob/living/carbon/human/track_blood_mob
mob/var
	bloody_hands = 0
	mob/living/carbon/human/bloody_hands_mob
	track_blood
	mob/living/carbon/human/track_blood_mob
obj/item/clothing/gloves/var
	transfer_blood = 0
	mob/living/carbon/human/bloody_hands_mob


obj/effect/decal/cleanable/blood/var
	track_amt = 3
	mob/blood_owner

turf/Exited(mob/living/carbon/human/M)
	if(istype(M,/mob/living))
		if(!istype(src, /turf/space))  // Bloody tracks code starts here
			if(M.track_blood > 0)
				M.track_blood--
				src.add_bloody_footprints(M.track_blood_mob,1,M.dir,get_tracks(M))
			else if(istype(M,/mob/living/carbon/human))
				if(M.shoes)
					if(M.shoes.track_blood > 0)
						M.shoes.track_blood--
						src.add_bloody_footprints(M.shoes.track_blood_mob,1,M.dir,M.shoes.name) // And bloody tracks end here
	. = ..()
turf/Entered(mob/living/carbon/human/M)
	if(istype(M,/mob/living))
		if(M.track_blood > 0)
			M.track_blood--
			src.add_bloody_footprints(M.track_blood_mob,0,M.dir,get_tracks(M))
		else if(istype(M,/mob/living/carbon/human))
			if(M.shoes && !istype(src,/turf/space))
				if(M.shoes.track_blood > 0)
					M.shoes.track_blood--
					src.add_bloody_footprints(M.shoes.track_blood_mob,0,M.dir,M.shoes.name)

		for(var/obj/effect/decal/cleanable/blood/B in src)
			if(B.track_amt <= 0) continue
			if(B.type != /obj/effect/decal/cleanable/blood/tracks)
				if(istype(M,/mob/living/carbon/human))
					if(M.shoes)
						M.shoes.add_blood(B.blood_owner)
						M.shoes.track_blood_mob = B.blood_owner
						M.shoes.track_blood = max(M.shoes.track_blood,8)
				else
					M.add_blood(B.blood_owner)
					M.track_blood_mob = B.blood_owner
					M.track_blood = max(M.track_blood,rand(4,8))
				B.track_amt--
				break
	. = ..()

turf/proc/add_bloody_footprints(mob/living/carbon/human/M,leaving,d,info)
	for(var/obj/effect/decal/cleanable/blood/tracks/T in src)
		if(T.dir == d)
			if((leaving && T.icon_state == "steps2") || (!leaving && T.icon_state == "steps1"))
				T.desc = "These bloody footprints appear to have been made by [info]."
				if(istype(M,/mob/living/carbon/human))
					T.blood_DNA.len++
					T.blood_DNA[T.blood_DNA.len] = list(M.dna.unique_enzymes,M.b_type)
				return
	var/obj/effect/decal/cleanable/blood/tracks/this = new(src)
	this.icon = 'footprints.dmi'
	if(leaving)
		this.icon_state = "blood2"
	else
		this.icon_state = "blood1"
	this.dir = d
	this.desc = "These bloody footprints appear to have been made by [info]."
	if(istype(M,/mob/living/carbon/human))
		this.blood_DNA.len++
		this.blood_DNA[this.blood_DNA.len] = list(M.dna.unique_enzymes,M.b_type)

proc/get_tracks(mob/M)
	if(istype(M,/mob/living))
		if(istype(M,/mob/living/carbon/human))
			. = "human feet"
		else if(istype(M,/mob/living/carbon/monkey))
			. = "monkey paws"
		else if(istype(M,/mob/living/silicon/robot))
			. = "robot feet"
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