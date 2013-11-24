//CONTAINS: Detective's Scanner


/obj/item/device/detective_scanner
	name = "Scanner"
	desc = "Used to scan objects for DNA and fingerprints."
	icon_state = "forensic1"
	var/amount = 20.0
	var/list/stored = list()
	w_class = 3.0
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | CONDUCT | USEDELAY
	slot_flags = SLOT_BELT

	attackby(obj/item/weapon/f_card/W as obj, mob/user as mob)
		..()
		if (istype(W, /obj/item/weapon/f_card))
			if (W.fingerprints)
				return
			if (src.amount == 20)
				return
			if (W.amount + src.amount > 20)
				src.amount = 20
				W.amount = W.amount + src.amount - 20
			else
				src.amount += W.amount
				//W = null
				del(W)
			add_fingerprint(user)
			if (W)
				W.add_fingerprint(user)
		return

	attack(mob/living/carbon/human/M as mob, mob/user as mob)
		if (!ishuman(M))
			user << "\red [M] is not human and cannot have the fingerprints."
			return 0
		if (( !( istype(M.dna, /datum/dna) ) || M.gloves) )
			user << "\blue No fingerprints found on [M]"
			return 0
		else
			if (src.amount < 1)
				user << text("\blue Fingerprints scanned on [M]. Need more cards to print.")
			else
				src.amount--
				var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card( user.loc )
				F.amount = 1
				F.add_fingerprint(M)
				F.icon_state = "fingerprint1"
				F.name = text("FPrintC- '[M.name]'")

				user << "\blue Done printing."
			user << "\blue [M]'s Fingerprints: [md5(M.dna.uni_identity)]"
		if ( !M.blood_DNA || !M.blood_DNA.len )
			user << "\blue No blood found on [M]"
			if(M.blood_DNA)
				del(M.blood_DNA)
		else
			user << "\blue Blood found on [M]. Analysing..."
			spawn(15)
				for(var/blood in M.blood_DNA)
					user << "\blue Blood type: [M.blood_DNA[blood]]\nDNA: [blood]"
		return

	afterattack(atom/A as obj|turf|area, mob/user as mob)
		if(!in_range(A,user))
			return
		if(loc != user)
			return
		if(istype(A,/obj/machinery/computer/forensic_scanning)) //breaks shit.
			return
		if(istype(A,/obj/item/weapon/f_card))
			user << "The scanner displays on the screen: \"ERROR 43: Object on Excluded Object List.\""
			return

		add_fingerprint(user)


		//Special case for blood splaters.
		if (istype(A, /obj/effect/decal/cleanable/blood) || istype(A, /obj/effect/rune))
			if(!isnull(A.blood_DNA))
				for(var/blood in A.blood_DNA)
					user << "\blue Blood type: [A.blood_DNA[blood]]\nDNA: [blood]"
			return

		//General
		if ((!A.fingerprints || !A.fingerprints.len) && !A.suit_fibers && !A.blood_DNA)
			user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,\
			"\blue Unable to locate any fingerprints, materials, fibers, or blood on [A]!",\
			"You hear a faint hum of electrical equipment.")
			return 0

		if(add_data(A))
			user << "\blue Object already in internal memory. Consolidating data..."
			return


		//PRINTS
		if(!A.fingerprints || !A.fingerprints.len)
			if(A.fingerprints)
				del(A.fingerprints)
		else
			user << "\blue Isolated [A.fingerprints.len] fingerprints: Data Stored: Scan with Hi-Res Forensic Scanner to retrieve."
			var/list/complete_prints = list()
			for(var/i in A.fingerprints)
				var/print = A.fingerprints[i]
				if(stringpercent(print) <= FINGERPRINT_COMPLETE)
					complete_prints += print
			if(complete_prints.len < 1)
				user << "\blue &nbsp;&nbsp;No intact prints found"
			else
				user << "\blue &nbsp;&nbsp;Found [complete_prints.len] intact prints"
				for(var/i in complete_prints)
					user << "\blue &nbsp;&nbsp;&nbsp;&nbsp;[i]"

		//FIBERS
		if(A.suit_fibers)
			user << "\blue Fibers/Materials Data Stored: Scan with Hi-Res Forensic Scanner to retrieve."

		//Blood
		if (A.blood_DNA)
			user << "\blue Blood found on [A]. Analysing..."
			spawn(15)
				for(var/blood in A.blood_DNA)
					user << "Blood type: \red [A.blood_DNA[blood]] \t \black DNA: \red [blood]"
		if(prob(80) || !A.fingerprints)
			user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,\
			"You finish scanning \the [A].",\
			"You hear a faint hum of electrical equipment.")
			return 0
		else
			user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]\n[user.gender == MALE ? "He" : "She"] seems to perk up slightly at the readout." ,\
			"The results of the scan pique your interest.",\
			"You hear a faint hum of electrical equipment, and someone making a thoughtful noise.")
			return 0
		return

	proc/add_data(atom/A as mob|obj|turf|area)
		//I love associative lists.
		var/list/data_entry = stored["\ref [A]"]
		if(islist(data_entry)) //Yay, it was already stored!
			//Merge the fingerprints.
			var/list/data_prints = data_entry[1]
			for(var/print in A.fingerprints)
				var/merged_print = data_prints[print]
				if(!merged_print)
					data_prints[print] = A.fingerprints[print]
				else
					data_prints[print] = stringmerge(data_prints[print],A.fingerprints[print])

			//Now the fibers
			var/list/fibers = data_entry[2]
			if(!fibers)
				fibers = list()
			if(A.suit_fibers && A.suit_fibers.len)
				for(var/j = 1, j <= A.suit_fibers.len, j++)	//Fibers~~~
					if(!fibers.Find(A.suit_fibers[j]))	//It isn't!  Add!
						fibers += A.suit_fibers[j]
			var/list/blood = data_entry[3]
			if(!blood)
				blood = list()
			if(A.blood_DNA && A.blood_DNA.len)
				for(var/main_blood in A.blood_DNA)
					if(!blood[main_blood])
						blood[main_blood] = A.blood_DNA[blood]
			return 1
		var/list/sum_list[4]	//Pack it back up!
		sum_list[1] = A.fingerprints ? A.fingerprints.Copy() : null
		sum_list[2] = A.suit_fibers ? A.suit_fibers.Copy() : null
		sum_list[3] = A.blood_DNA ? A.blood_DNA.Copy() : null
		sum_list[4] = "\The [A] in \the [get_area(A)]"
		stored["\ref [A]"] = sum_list
		return 0

/proc/get_timestamp()
	return time2text(world.time + 432000, "hh:mm:ss")

/obj/item/device/detective_scanner/forger
	var/list/custom_forgery[3]
	var/forging = 0

	New()
		..()
		custom_forgery[1] = list()
		custom_forgery[2] = list()
		custom_forgery[3] = list()

	attack_self(var/mob/user as mob)
		var/list/customprints = list()
		var/list/customfiber = list()
		var/list/customblood = list()
		if(forging)
			user << "\red You are already forging evidence"
			return 0
		clear_forgery()
		//fingerprint loop
		while(1)
			var/print = html_encode(input(usr,"Please enter a custom fingerprint or hit cancel to finish fingerprints") as text|null)
			if(!usr.client)
				forging = 0
				break
			if(!print )
				break
			customprints[print] = print
		while(1)
			var/fiber = html_encode(input(usr,"Please enter a custom fiber/material trace or hit cancel to finish fibers/materials") as text|null)
			if(!usr.client)
				forging = 0
				break
			if(!fiber)
				break
			customfiber[fiber] = null
		while(1)
			var/blood = html_encode(input(usr,"Please enter a custom Blood DNA or hit cancel to finish forging") as text|null)
			var/bloodtype = html_encode(input(usr,"Please enter a custom Blood Type") as text|null)
			if(!usr.client)
				forging = 0
				break
			if(!blood)
				break
			customblood[blood] = bloodtype
		forging = 0
		if(!customprints.len && !customfiber.len)
			user << "\blue No forgery saved."
			return
		user << "\blue Forgery saved and will be tied to the next applicable scanned item."
		custom_forgery[1] = customprints ? customprints.Copy() : null
		custom_forgery[2] = customfiber ? customfiber.Copy() : null
		custom_forgery[3] = customblood ? customblood.Copy() : null

//shameless copy pasting
	afterattack(atom/A as obj|turf|area, mob/user as mob)
		var/list/custom_finger = list()
		var/list/custom_fiber = list()
		var/list/custom_blood = list()

		if(custom_forgery)
			custom_finger = custom_forgery[1]
			custom_fiber = custom_forgery[2]
			custom_blood = custom_forgery[3]

		if(!in_range(A,user))
			return
		if(loc != user)
			return
		if(istype(A,/obj/machinery/computer/forensic_scanning)) //breaks shit.
			return
		if(istype(A,/obj/item/weapon/f_card))
			user << "The scanner displays on the screen: \"ERROR 43: Object on Excluded Object List.\""
			return

		add_fingerprint(user)


		//Special case for blood splaters.
		if (istype(A, /obj/effect/decal/cleanable/blood) || istype(A, /obj/effect/rune))
			if(!isnull(A.blood_DNA))
				for(var/blood in A.blood_DNA)
					user << "\blue Blood type: [A.blood_DNA[blood]]\nDNA: [blood]"
			return

		//General
		if ((!A.fingerprints || !A.fingerprints.len) && !A.suit_fibers && !A.blood_DNA)
			if(!custom_finger.len && !custom_fiber.len && !custom_blood.len)
				user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,\
				"\blue Unable to locate any fingerprints, materials, fibers, or blood on [A]!",\
				"You hear a faint hum of electrical equipment.")
				return 0
			else
				user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,\
				"\blue Unable to locate any fingerprints, materials, fibers, or blood on [A], loading custom forgery instead.",\
				"You hear a faint hum of electrical equipment.")


		if(add_data(A))
			user << "\blue Object already in internal memory. Consolidating data..."
			return


		//PRINTS
		if(!A.fingerprints || !A.fingerprints.len)
			if(A.fingerprints)
				del(A.fingerprints)
		if(custom_finger.len)
			user << "\blue Isolated [custom_finger.len] fingerprints: Data Stored: Scan with Hi-Res Forensic Scanner to retrieve."
			user << "\blue &nbsp;&nbsp;Found [custom_finger.len] intact prints"
			for(var/i in custom_finger)
				user << "\blue &nbsp;&nbsp;&nbsp;&nbsp;[i]"
		else if(A.fingerprints && A.fingerprints.len)
			user << "\blue Isolated [A.fingerprints.len] fingerprints: Data Stored: Scan with Hi-Res Forensic Scanner to retrieve."
			var/list/complete_prints = list()
			for(var/i in A.fingerprints)
				var/print = A.fingerprints[i]
				if(stringpercent(print) <= FINGERPRINT_COMPLETE)
					complete_prints += print
			if(complete_prints.len < 1)
				user << "\blue &nbsp;&nbsp;No intact prints found"
			else
				user << "\blue &nbsp;&nbsp;Found [complete_prints.len] intact prints"
				for(var/i in complete_prints)
					user << "\blue &nbsp;&nbsp;&nbsp;&nbsp;[i]"

		//FIBERS
		if(custom_fiber.len)
			user << "\blue Forged Fibers/Materials Data Found: Scan with Hi-Res Forensic Scanner to retrieve."
		else if(A.suit_fibers)
			user << "\blue Fibers/Materials Data Stored: Scan with Hi-Res Forensic Scanner to retrieve."


		//Blood
		if(custom_blood.len)
			user << "\blue Forged Blood found. Analysing..."
			spawn(15)
				for(var/blood in custom_blood)
					user << "Blood type: \red [custom_blood[blood]] \t \black DNA: \red [blood]"
		else if (A.blood_DNA)
			user << "\blue Blood found on [A]. Analysing..."
			spawn(15)
				for(var/blood in A.blood_DNA)
					user << "Blood type: \red [A.blood_DNA[blood]] \t \black DNA: \red [blood]"
		return

	add_data(atom/A as mob|obj|turf|area)
		//I love associative lists.
		var/list/data_entry = stored["\ref [A]"]
		var/list/custom_finger = list()
		var/list/custom_fiber = list()
		var/list/custom_blood = list()

		if(custom_forgery)
			custom_finger = custom_forgery[1]
			custom_fiber = custom_forgery[2]
			custom_blood = custom_forgery[3]

		if(islist(data_entry)) //Yay, it was already stored!
			//Merge the fingerprints.
			var/list/data_prints = data_entry[1]
			if(custom_finger.len)
				for(var/print in custom_finger)
					var/merged_print = data_prints[print]
					if(!merged_print)
						data_prints[print] = custom_finger
					else
						data_prints[print] = stringmerge(data_prints[print],custom_finger[print])
			else
				for(var/print in A.fingerprints)
					var/merged_print = data_prints[print]
					if(!merged_print)
						data_prints[print] = A.fingerprints[print]
					else
						data_prints[print] = stringmerge(data_prints[print],A.fingerprints[print])

			//Now the fibers
			var/list/fibers = data_entry[2]
			if(!fibers)
				fibers = list()
			if(custom_fiber.len)
				for(var/j = 1, j <= custom_fiber.len, j++)	//Fibers~~~
					if(!fibers.Find(custom_fiber[j]))	//It isn't!  Add!
						fibers += custom_fiber[j]

			else if(A.suit_fibers && A.suit_fibers.len)
				for(var/j = 1, j <= A.suit_fibers.len, j++)	//Fibers~~~
					if(!fibers.Find(A.suit_fibers[j]))	//It isn't!  Add!
						fibers += A.suit_fibers[j]
			var/list/blood = data_entry[3]
			if(!blood)
				blood = list()
			if(custom_blood.len)
				for(var/main_blood in custom_blood)
					if(!blood[main_blood])
						blood[main_blood] = custom_blood[blood]
			else if(A.blood_DNA && A.blood_DNA.len)
				for(var/main_blood in A.blood_DNA)
					if(!blood[main_blood])
						blood[main_blood] = A.blood_DNA[blood]
			return 1
		var/list/sum_list[4]	//Pack it back up!
		if(custom_finger.len || custom_fiber.len || custom_blood.len)
			sum_list[1] = custom_finger ? custom_finger.Copy() : null
			sum_list[2] = custom_fiber ? custom_fiber.Copy() : null
			sum_list[3] = custom_blood ? custom_blood.Copy() : null
		else
			sum_list[1] = A.fingerprints ? A.fingerprints.Copy() : null
			sum_list[2] = A.suit_fibers ? A.suit_fibers.Copy() : null
			sum_list[3] = A.blood_DNA ? A.blood_DNA.Copy() : null
		sum_list[4] = "\The [A] in \the [get_area(A)]"
		stored["\ref [A]"] = sum_list
		clear_forgery()
		return 0

	proc/clear_forgery()
		if(custom_forgery.len)
			custom_forgery[1] = list()
			custom_forgery[2] = list()
			custom_forgery[3] = list()