//CONTAINS: Detective's Scanner


/obj/item/device/detective_scanner
	name = "Scanner"
	desc = "Used to scan objects for DNA and fingerprints. Can print a report of the findings."
	icon_state = "forensic1"
	w_class = 3.0
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | CONDUCT | USEDELAY
	slot_flags = SLOT_BELT
	var/scanning = 0
	var/list/log = list()

/obj/item/device/detective_scanner/attack_self(var/mob/user)
	if(log.len && !scanning)
		scanning = 1
		user << "<span class='notice'>Printing report, please wait...</span>"
		spawn(100)
			var/obj/item/weapon/paper/P = new(get_turf(src))
			P.info = "<center><font size='4'>Scanner Report</font></center><HR><BR>"
			P.info += dd_list2text(log, "<BR>")
			P.info_links = P.info

			user.put_in_hands(P)

			log = list()
			scanning = 0
			if(user)
				user << "<span class='notice'>Report printed. Log cleared.<span>"
	else
		user << "<span class='notice'>The scanner has no logs or is in use.</span>"

/obj/item/device/detective_scanner/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	if(!scanning)
		scanning = 1
		spawn(0)
			add_log(user, "<font color='blue'>Scanning [M]...</font>")
			if (!ishuman(M))
				add_log(user, "<span class='warning'>[M] is not human and cannot have the fingerprints.</span>")
			else
				if (( !( istype(M.dna, /datum/dna) ) || M.gloves) )
					add_log(user, "<span class='info'>No fingerprints found on [M]</span>")
				else
					add_log(user, "<span class='info'>Fingerprints found on [M]. Analysing...</span>")
					sleep(30)
					add_log(user, "<span class='info'>[M]'s Fingerprints: [md5(M.dna.uni_identity)]</span>")

			if ( !M.blood_DNA || !M.blood_DNA.len )
				add_log(user, "<span class='info'>No blood found on [M]</span>")
				if(M.blood_DNA)
					del(M.blood_DNA)
			else
				add_log(user, "<span class='info'>Blood found on [M]. Analysing...</span>")
				sleep(30)
				for(var/blood in M.blood_DNA)
					add_log(user, "<span class='info'>Blood type: [M.blood_DNA[blood]]\nDNA: [blood]</span>")
			add_log(null, "<font color='blue'>Ending scan report.</font>")
			scanning = 0
			return

/obj/item/device/detective_scanner/afterattack(atom/A as obj|turf|area, mob/user as mob)
	if(!in_range(A,user))
		return
	if(!isturf(A) && !isobj(A))
		return
	if(loc != user)
		return

	if(!scanning)
		scanning = 1
		add_fingerprint(user)

		spawn(0)

			add_log(user, "<font color='blue'>Scanning [A]...</font>")
			//PRINTS
			if(!A.fingerprints || !A.fingerprints.len)
				if(A.fingerprints)
					del(A.fingerprints)
			else
				var/list/completed_prints = list()
				// Bah this looks awful but basically it loop throught the last 15 entries.
				for(var/i in A.fingerprints)
					var/print = A.fingerprints[i]
					completed_prints += print
				if(completed_prints.len < 1)
					add_log(user, "<span class='info'>No intact prints found</span>")
				else
					add_log(user, "<span class='info'>Found [completed_prints.len] intact print[completed_prints.len == 1 ? "" : "s"]. Analysing...</span>")
					sleep(30)
					for(var/i in completed_prints)
						add_log(user, "&nbsp;&nbsp;&nbsp;&nbsp;[i]")

			//FIBERS
			if(A.suit_fibers && A.suit_fibers.len)
				add_log(user, "<span class='info'>Fibers found. Analysing...</span>")
				sleep(30)
				for(var/fiber in A.suit_fibers)
					add_log(user, "&nbsp;&nbsp;&nbsp;&nbsp;[fiber]")

			//Blood
			if (A.blood_DNA && A.blood_DNA.len)
				add_log(user, "<span class='info'>Blood found. Analysing...</span>")
				sleep(30)
				for(var/blood in A.blood_DNA)
					add_log(user, "&nbsp;&nbsp;&nbsp;&nbsp;Blood type: <font color='red'>[A.blood_DNA[blood]]</font> DNA: <font color='red'>[blood]</font>")

			//General
			if ((!A.fingerprints || !A.fingerprints.len) && (!A.suit_fibers || !A.suit_fibers.len) && (!A.blood_DNA || !A.blood_DNA.len))
				add_log(null, "Unable to locate any fingerprints, materials, fibers, or blood.")
				user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,\
				"<span class='notice'>Unable to locate any fingerprints, materials, fibers, or blood on [A]!</span>",\
				"You hear a faint hum of electrical equipment.")
			else
				user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,\
				"You finish scanning \the [A].",\
				"You hear a faint hum of electrical equipment.")

			add_log(null, "<font color='blue'>Ending scan report.</font>")
			scanning = 0
			return 0


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
/obj/item/device/detective_scanner/proc/add_log(var/mob/user, var/msg)
	if(scanning)
		if(user)
			user << msg
		log += "<span class='prefix'>[time2text(world.time + 432000, "hh:mm:ss")]</span>:&nbsp;&nbsp;[msg]"
	else
		CRASH("[src] \ref[src] is adding a log when it was never put in scanning mode!")