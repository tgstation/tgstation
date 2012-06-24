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
			user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.get_visible_gender() == MALE ? "him" : H.get_visible_gender() == FEMALE ? "her" : "them"] humming[prob(70) ? " gently." : "."]" ,\
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
			user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.get_visible_gender() == MALE ? "him" : H.get_visible_gender() == FEMALE ? "her" : "them"] humming[prob(70) ? " gently." : "."]" ,\
			"You finish scanning \the [A].",\
			"You hear a faint hum of electrical equipment.")
			return 0
		else
			user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.get_visible_gender() == MALE ? "him" : H.get_visible_gender() == FEMALE ? "her" : "them"] humming[prob(70) ? " gently." : "."]\n[user.get_visible_gender() == MALE ? "He" : H.get_visible_gender() == FEMALE ? "She" : "They"] seems to perk up slightly at the readout." ,\
			"The results of the scan pique your interest.",\
			"You hear a faint hum of electrical equipment, and someone making a thoughtful noise.")
			return 0
		return

	proc/add_data(atom/A as mob|obj|turf|area)
		//I love hashtables.
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