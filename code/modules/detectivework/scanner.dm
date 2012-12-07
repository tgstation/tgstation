//CONTAINS: Detective's Scanner

// TODO: Split everything into easy to manage procs.

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
			P.name = "paper- 'Scanner Report'"
			P.info = "<center><font size='6'><B>Scanner Report</B></font></center><HR><BR>"
			P.info += dd_list2text(log, "<BR>")
			P.info += "<HR><B>Notes:</B><BR>"
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

			var/found_something = 0
			user << "<span class='notice'>You scan [M]. The scanner is analysing the results...</span>"
			add_log(null, "<B>[time2text(world.time + 432000, "hh:mm:ss")] - [M]</B>")
			// Fingerprints
			if(ishuman(M))
				if (istype(M.dna, /datum/dna) && !M.gloves)
					sleep(30)
					add_log(user, "<span class='info'><B>Prints:</B></span>")
					add_log(user, "[md5(M.dna.uni_identity)]")
					found_something = 1

			// Blood
			if ( !M.blood_DNA || !M.blood_DNA.len )
				if(M.blood_DNA)
					del(M.blood_DNA)
			else
				sleep(30)
				add_log(user, "<span class='info'><B>Blood:</B></span>")
				found_something = 1
				for(var/blood in M.blood_DNA)
					add_log(user, "Type: <font color='red'>[M.blood_DNA[blood]]</font> DNA: <font color='red'>[blood]</font>")

			//Reagents
			if(M.reagents && M.reagents.reagent_list.len)
				sleep(30)
				add_log(user, "<span class='info'><B>Reagents:</B></span>")
				for(var/datum/reagent/R in M.reagents.reagent_list)
					add_log(user, "Reagent: <font color='red'>[R.name]</font> Volume: <font color='red'>[R.volume]</font>")
				found_something = 1

			if(!found_something)
				add_log(null, "<I># No forensic traces found #</I>")
				user.visible_message("\The [user] scans \the [M] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,\
				"<span class='notice'>Unable to locate any fingerprints, materials, fibers, or blood on [M]!</span>",\
				"You hear a faint hum of electrical equipment.")
			else
				user.visible_message("\The [user] scans \the [M] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,\
				"<span class='notice'>You finish scanning \the [M].</span>",\
				"You hear a faint hum of electrical equipment.")
			add_log(null, "---------------------------------------------------------")
			scanning = 0
			return

/obj/item/device/detective_scanner/afterattack(atom/A as obj|turf|area, mob/user as mob)
	// Note, don't add formating, such as <span class>, as it won't show up in the logs.
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

			var/found_something = 0
			user << "<span class='notice'>You scan [A]. The scanner is analysing the results...</span>"
			add_log(null, "<B>[time2text(world.time + 432000, "hh:mm:ss")] - [capitalize(A.name)]</B>")
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

				if(completed_prints.len)

					sleep(30)
					add_log(user, "<span class='info'><B>Prints:</B></span>")
					for(var/i in completed_prints)
						add_log(user, "[i]")
					found_something = 1

			//FIBERS
			if(A.suit_fibers && A.suit_fibers.len)
				sleep(30)
				add_log(user, "<span class='info'><B>Fibers:</B></span>")
				for(var/fiber in A.suit_fibers)
					add_log(user, "[fiber]")
				found_something = 1

			//Blood
			if (A.blood_DNA && A.blood_DNA.len)
				sleep(30)
				add_log(user, "<span class='info'><B>Blood:</B></span>")
				for(var/blood in A.blood_DNA)
					add_log(user, "Type: <font color='red'>[A.blood_DNA[blood]]</font> DNA: <font color='red'>[blood]</font>")
				found_something = 1

			//Reagents
			if(A.reagents && A.reagents.reagent_list.len)
				sleep(30)
				add_log(user, "<span class='info'><B>Reagents:</B></span>")
				for(var/datum/reagent/R in A.reagents.reagent_list)
					add_log(user, "Reagent: <font color='red'>[R.name]</font> Volume: <font color='red'>[R.volume]</font>")
				found_something = 1

			//General
			if (!found_something)
				add_log(null, "<I># No forensic traces found #</I>")
				user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,\
				"<span class='notice'>Unable to locate any fingerprints, materials, fibers, or blood on [A]!</span>",\
				"You hear a faint hum of electrical equipment.")
			else
				user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,\
				"<span class='notice'>You finish analysing \the [A].</span>",\
				"You hear a faint hum of electrical equipment.")

			add_log(null, "---------------------------------------------------------")
			scanning = 0
			return 0

/obj/item/device/detective_scanner/proc/add_log(var/mob/user, var/msg)
	if(scanning)
		if(user)
			user << msg
		log += "&nbsp;&nbsp;[msg]"
	else
		CRASH("[src] \ref[src] is adding a log when it was never put in scanning mode!")