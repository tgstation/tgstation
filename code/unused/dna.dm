/proc/scram(n)
	var/t = ""
	var/p = null
	p = 1
	while(p <= n)
		t = text("[][]", t, rand(1, 9))
		p++
	return t

/obj/machinery/computer/dna/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/dna/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/dna/attack_hand(mob/user as mob)
	if(..())
		return
	user.machine = src
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon/ai))
		var/dat = text("<I>Please Insert the cards into the slots</I><BR>\n\t\t\t\tFunction Disk: <A href='?src=\ref[];scan=1'>[]</A><BR>\n\t\t\t\tTarget Disk: <A href='?src=\ref[];modify=1'>[]</A><BR>\n\t\t\t\tAux. Data Disk: <A href='?src=\ref[];modify2=1'>[]</A><BR>\n\t\t\t\t\t(Not always used!)<BR>\n\t\t\t\t[]", src, (src.scan ? text("[]", src.scan.name) : "----------"), src, (src.modify ? text("[]", src.modify.name) : "----------"), src, (src.modify2 ? text("[]", src.modify2.name) : "----------"), (src.scan ? text("<A href='?src=\ref[];execute=1'>Execute Function</A>", src) : "No function disk inserted!"))
		if (src.temp)
			dat = text("[]<BR><BR><A href='?src=\ref[];clear=1'>Clear Message</A>", src.temp, src)
		user << browse(dat, "window=dna_comp")
		onclose(user, "dna_comp")
	else
		var/dat = text("<I>[]</I><BR>\n\t\t\t\t[] <A href='?src=\ref[];scan=1'>[]</A><BR>\n\t\t\t\t[] <A href='?src=\ref[];modify=1'>[]</A><BR>\n\t\t\t\t[] <A href='?src=\ref[];modify2=1'>[]</A><BR>\n\t\t\t\t\t(Not always used!)<BR>\n\t\t\t\t[]", stars("Please Insert the cards into the slots"), stars("Function Disk:"), src, (src.scan ? text("[]", src.scan.name) : "----------"), stars("Target Disk:"), src, (src.modify ? text("[]", src.modify.name) : "----------"), stars("Aux. Data Disk:"), src, (src.modify2 ? text("[]", src.modify2.name) : "----------"), (src.scan ? text("<A href='?src=\ref[];execute=1'>[]</A>", src, stars("Execute Function")) : stars("No function disk inserted!")))
		if (src.temp)
			dat = text("[]<BR><BR><A href='?src=\ref[];clear=1'>[]", stars(src.temp), src, stars("Clear Message</A>"))
		user << browse(dat, "window=dna_comp")
		onclose(user, "dna_comp")
	return

/obj/machinery/computer/dna/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1 || usr.telekinesis == 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.machine = src
		if (href_list["modify"])
			if (src.modify)
				src.modify.loc = src.loc
				src.modify = null
				src.mode = null
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/weapon/card/data))
					usr.drop_item()
					I.loc = src
					src.modify = I
				src.mode = null
		if (href_list["modify2"])
			if (src.modify2)
				src.modify2.loc = src.loc
				src.modify2 = null
				src.mode = null
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/weapon/card/data))
					usr.drop_item()
					I.loc = src
					src.modify2 = I
				src.mode = null
		if (href_list["scan"])
			if (src.scan)
				src.scan.loc = src.loc
				src.scan = null
				src.mode = null
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/weapon/card/data))
					usr.drop_item()
					I.loc = src
					src.scan = I
				src.mode = null
		if (href_list["clear"])
			src.temp = null
		if (href_list["execute"])
			if ((src.scan && src.scan.function))
				switch(src.scan.function)
					if("data_mutate")
						if (src.modify)
							if (!( findtext(src.scan.data, "-", 1, null) ))
								if ((src.modify.data && src.scan.data && length(src.modify.data) >= length(src.scan.data)))
									src.modify.data = text("[][]", src.scan.data, (length(src.modify.data) > length(src.scan.data) ? copytext(src.modify.data, length(src.scan.data) + 1, length(src.modify.data) + 1) : null))
								else
									src.temp = "Disk Failure: Cannot examine data! (Null or wrong format)"
							else
								var/d = findtext(src.modify.data, "-", 1, null)
								var/t = copytext(src.modify.data, d + 1, length(src.modify.data) + 1)
								d = text2num(copytext(1, d, null))
								if ((d && t && src.modify.data && src.scan.data && length(src.modify.data) >= (length(t) + d - 1) ))
									src.modify.data = text("[][][]", copytext(src.modify.data, 1, d), t, (length(src.modify.data) > length(t) + d ? copytext(src.modify.data, length(t) + d, length(src.modify.data) + 1) : null))
								else
									src.temp = "Disk Failure: Cannot examine data! (Null or wrong format)"
						else
							src.temp = "Disk Failure: Cannot read target disk!"
					if("dna_seq")
						src.temp = "<TT>DNA Systems Help:\nHuman DNA sequences: (Compressed in *.dna format version 10.76)\n\tSpecies Identification Marker: (28 chromosomes)\n\t\t5BDFE293BA5500F9FFFD500AAFFE\n\tStructural Enzymes:\n\t\tCDE375C9A6C25A7DBDA50EC05AC6CEB63\n\t\tNote: The first id set is used for DNA clean up operations.\n\tUsed Enzymes:\n\t\t493DB249EB6D13236100A37000800AB71\n\tSpecies/Genus Classification: <I>Homo Sapien</I>\n\nMonkey DNA sequences: (Compressed in *.dna format version 10.76)\n\tSpecies Identification Marker: (16 chromosomes)\n\t\t2B6696D2B127E5A4\n\tStructural Enzymes:\n\t\tCDEAF5B90AADBC6BA8033DB0A7FD613FA\n\t\tNote: The first id set is used for DNA clean up operations.\n\tUsed Enzymes:\n\t\tC8FFFE7EC09D80AEDEDB9A5A0B4085B61\n\tSpecies/Genus Classification: Generic Monkey\n</TT>>"
					if("dna_help")
						src.temp = "<TT>DNA Systems Help:\nThe DNA systems consists 3 systems.\nI. DNA Scanner/Implanter - This system is slightly advanced to use. It accepts\n\t1 disk. Before you wish to run a function/program you must implant the\n\tdisk data into the temporary memory. Note that once this is done the disk can\n\tbe removed to place a data disk in.\nII. DNA computer - This is a simple yet fast computer that basically operates on data.\nIII. Restructurer - This device reorganizes the anatomical structure of the subject\n\taccording to the DNA sequences. Please note that it is illegal to perform a\n\ttransfer from one species to or from the <I>Homo sapiens</I> species but\n\thuman to human is acceptable under UNSD guidlines.\n\tNote: This machine is programmed to operate on specific preprogrammed species with\n\tspecialized anatomical blueprints hard coded into its databanks. It cannot operate\n\ton other species. (Current: Human, Monkey)\n\nData Disks:\n\tThese run on 2 (or 3) types: DNA scanner program disks and data modification\nfunctions (and disk modification functions)\n\nDisk-Copy\n\tThis erases the target disk and completely copies the data from the aux. disk.\nDisk-Erase\n\tThis erases everything on the target disk.\nData-Clear\n\tThis erases (clears) only the data.\n\nData-Trunicate\n\tThis removes data from the target disk (parameters gathered from data slot on target\n\tdisk). This fuction has 4 modes (a,b,c,default) defined by this way. (mode id)(#)\n\ta - This cuts # data from the end. (ex a1 on ABCD = ABC)\n\tb - This cuts # data from the beginning. (ex b1 on ABCD = BCD)\n\tc - This limits the data from the end. (ex c1 on ABCD = A)\n\tdefault - This limits the data from the end. (ex 1 on ABCD = D)\nData-Add\n\tThis adds thedata on the aux. disk to the data on the target disk.\nData-Sramble\n\tThis scrambles the data on the target disk. The length is equal to\n\tthe length of the original data.\nData-Input\n\tThis lets you input data into the data slot of any data disk.\n\tNote: This doesn't work only on storage.\nData-Mutate\n\tThis basically inserts text. You follow this format:\n\tpos-text (or just text for automatic pos 1)\n\tie 2-IVE on FOUR yields FIVE\n</TT>"
					if("data_add")
						if (src.modify)
							if (src.modify2)
								if ((src.modify.data && src.modify2.data))
									src.modify.data += src.modify2.data
									src.temp = text("Done!<BR>New Data:<BR>[]", src.modify.data)
								else
									src.temp = "Cannot read data! (may be null)"
							else
								src.temp = "Disk Failure: Cannot read aux. data disk!"
						else
							src.temp = "Disk Failure: Cannot read target disk!"
					if("data_scramble")
						if (src.modify)
							if (length(text("[]", src.modify.data)) >= 1)
								src.modify.data = scram(length(text("[]", src.modify.data)))
								src.temp = text("Data scrambled: []", src.modify.data)
							else
								src.temp = "No data to scramble"
						else
							src.temp = "Disk Failure: Cannot read target disk!"
					if("data_input")
						if (src.modify)
							var/dat = input(usr, ">", text("[]", src.name), null)  as text
							var/s = src.scan
							var/m = src.modify
							if ((usr.stat || usr.restrained() || src.modify != m || src.scan != s))
								return
							if (((get_dist(src, usr) <= 1 || usr.telekinesis == 1) && istype(src.loc, /turf)))
								src.modify.data = dat
						else
							src.temp = "Disk Failure: Cannot read target disk!"
					if("disk_copy")
						if (src.modify)
							if (src.modify2)
								src.modify.function = src.modify2.function
								src.modify.data = src.modify2.data
								src.modify.special = src.modify2.special
								src.temp = "All disk data/programs copied."
							else
								src.temp = "Disk Failure: Cannot read aux. data disk!"
						else
							src.temp = "Disk Failure: Cannot read target disk!"
					if("disk_dis")
						if (src.modify)
							src.temp = text("Function: [][]<BR>Data: []", src.modify.function, (src.modify.special ? text("-[]", src.modify.special) : null), src.modify.data)
						else
							src.temp = "Disk Failure: Cannot read target disk!"
					if("disk_erase")
						if (src.modify)
							src.modify.data = null
							src.modify.function = "storage"
							src.modify.special = null
							src.temp = "All Disk contents deleted."
						else
							src.temp = "Disk Failure: Cannot read target disk!"
					if("data_clear")
						if (src.modify)
							src.modify.data = null
							src.temp = "Disk data cleared."
						else
							src.temp = "Disk Failure: Cannot read target disk!"
					if("data_trun")
						if (src.modify)
							if ((src.modify.data && src.scan.data))
								var/l1 = length(src.modify.data)
								var/l2 = max(round(text2num(src.scan.data)), 1)
								switch(copytext(src.modify.data, 1, 2))
									if("a")
										if (l1 > l2)
											src.modify.data = copytext(src.modify.data, 1, (l1 - l2) + 1)
										else
											src.modify.data = ""
										src.temp = text("Done!<BR>New Data:<BR>[]", src.modify.data)
									if("b")
										if (l1 > l2)
											src.modify.data = copytext(src.modify.data, l2, l1 + 1)
										else
											src.modify.data = ""
										src.temp = text("Done!<BR>New Data:<BR>[]", src.modify.data)
									if("c")
										if (l1 >= l2)
											src.modify.data = copytext(src.modify.data, l1 - l2, l1 + 1)
										src.temp = text("Done!<BR>New Data:<BR>[]", src.modify.data)
									else
										if (l1 >= l2)
											src.modify.data = copytext(src.modify.data, 1, l2 + 1)
										src.temp = text("Done!<BR>New Data:<BR>[]", src.modify.data)
							else
								src.temp = "Cannot read data! (may be null and note that function data slot is used instead of aux disk!!)"
						else
							src.temp = "Disk Failure: Cannot read target disk!"
					else
			else
				src.temp = "System Failure: Cannot read disk function!"
		src.add_fingerprint(usr)
		src.updateUsrDialog()
	return

/obj/machinery/computer/dna/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		else
	return

/obj/machinery/dna_scanner/allow_drop()
	return 0

/obj/machinery/dna_scanner/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/dna_scanner/verb/eject()
	set src in oview(1)

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/dna_scanner/verb/move_inside()
	set src in oview(1)

	if (usr.stat != 0)
		return
	if (src.occupant)
		usr << "\blue <B>The scanner is already occupied!</B>"
		return
	if (usr.abiotic2())
		usr << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	usr.pulling = null
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.loc = src
	src.occupant = usr
	src.icon_state = "scanner_1"
	for(var/obj/O in src)
		//O = null
		del(O)
		//Foreach goto(124)
	src.add_fingerprint(usr)
	return

/obj/machinery/dna_scanner/attackby(obj/item/weapon/grab/G as obj, user as mob)
	if ((!( istype(G, /obj/item/weapon/grab) ) || !( ismob(G.affecting) )))
		return
	if (src.occupant)
		user << "\blue <B>The scanner is already occupied!</B>"
		return
	if (G.affecting.abiotic2())
		user << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	var/mob/M = G.affecting
	if (M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.loc = src
	src.occupant = M
	src.icon_state = "scanner_1"
	for(var/obj/O in src)
		O.loc = src.loc
		//Foreach goto(154)
	src.add_fingerprint(user)
	//G = null
	del(G)
	return

/obj/machinery/dna_scanner/proc/go_out()
	if ((!( src.occupant ) || src.locked))
		return
	for(var/obj/O in src)
		O.loc = src.loc
		//Foreach goto(30)
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	src.icon_state = "scanner_0"
	return

/obj/machinery/dna_scanner/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
				//Foreach goto(35)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(108)
				//SN src = null
				del(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(181)
				//SN src = null
				del(src)
				return
		else
	return


/obj/machinery/dna_scanner/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/machinery/scan_console/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		else
	return

/obj/machinery/scan_console/blob_act()

	if(prob(75))
		del(src)

/obj/machinery/scan_console/power_change()
	if(stat & BROKEN)
		icon_state = "broken"
	else if(powered())
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			src.icon_state = "c_unpowered"
			stat |= NOPOWER

/obj/machinery/scan_console/New()
	..()
	spawn( 5 )
		src.connected = locate(/obj/machinery/dna_scanner, get_step(src, WEST))
		return
	return

/obj/machinery/scan_console/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(250)

	var/mob/M
	if (!( src.status ))
		return
	if (!( src.func ))
		src.temp = "No function loaded into memory core!"
		src.status = null
	if ((src.connected && src.connected.occupant))
		M = src.connected.occupant
	if (src.status == "load")
		src.prog_p1 = null
		src.prog_p2 = null
		src.prog_p3 = null
		src.prog_p4 = null
		switch(src.func)
			if("dna_trun")
				if (src.data)
					src.prog_p1 = copytext(src.data, 1, 2)
					src.prog_p2 = text2num(src.data)
					src.prog_p3 = src.special
					src.status = "dna_trun"
					src.temp = "Executing trunication function on occupant."
				else
					src.temp = "No data implanted in core memory."
					src.status = null
			if("dna_scan")
				if (src.special)
					if (src.scan)
						if (istype(M, /mob))
							switch(src.special)
								if("UI")
									src.temp = text("Scan Complete:<BR>Data downloaded to disk!<BR>Unique Identifier: []", M.primary.uni_identity)
									src.scan.data = M.primary.uni_identity
								if("SE")
									src.temp = text("Scan Complete:<BR>Data downloaded to disk!<BR>Structural Enzymes: []", M.primary.struc_enzyme)
									src.scan.data = M.primary.struc_enzyme
								if("UE")
									src.temp = text("Scan Complete:<BR>Data downloaded to disk!<BR>Used Enzynmes: []", M.primary.use_enzyme)
									src.scan.data = M.primary.use_enzyme
								if("SI")
									src.temp = text("Scan Complete:<BR>Data downloaded to disk!<BR>Species Identifier: []", M.primary.spec_identity)
									src.scan.data = M.primary.spec_identity
								else
						else
							src.temp = "No occupant to scan!"
					else
						src.temp = "Error: No disk to upload data to."
				else
					src.temp = "Error: Function program errors."
				src.status = null
			if("dna_replace")
				if ((src.data && src.special))
					src.prog_p1 = src.special
					src.prog_p2 = src.data
					src.status = "dna_replace"
					src.temp = "Executing repalcement function on occupant."
				else
					src.temp = "Error: No DNA data loaded into core or function program errors."
					src.status = null
			if("dna_add")
				if ((src.data && src.special))
					src.prog_p1 = src.special
					src.prog_p2 = src.data
					src.status = "dna_add"
					src.temp = "Executing addition function on occupant."
				else
					src.temp = "Error: No DNA data loaded into core or function program errors."
					src.status = null
			else
				src.temp = "Cannot execute program!"
				src.status = null
	else
		if (src.status == "dna_trun")
			if (istype(M, /mob))
				var/t = null
				switch(src.prog_p3)
					if("UI")
						t = M.primary.uni_identity
					if("SE")
						t = M.primary.struc_enzyme
					if("UE")
						t = M.primary.use_enzyme
					if("SI")
						t = M.primary.spec_identity
					else
				if (!( src.prog_p4 ))
					switch(src.prog_p1)
						if("a")
							src.prog_p4 = length(t)
						if("b")
							src.prog_p4 = 1
						else
				else
					if (src.prog_p1 == "a")
						src.prog_p4--
					else
						if (src.prog_p1 == "b")
							src.prog_p4--
				switch(src.prog_p1)
					if("a")
						if (src.prog_p4 <= 0)
							src.temp = "Trunication complete"
							src.status = null
						else
							t = copytext(t, 1, length(t))
							src.temp = text("Trunicating []'s DNA sequence...<BR>[]<BR>Status: [] units left.<BR><BR><A href='?src=\ref[];abort=1'>Emergency Abort</A>", M.name, t, src.prog_p4, src)
					if("b")
						if (src.prog_p4 <= 0)
							src.temp = "Trunication complete"
							src.status = null
						else
							t = copytext(t, 2, length(t) + 1)
							src.temp = text("Trunicating []'s DNA sequence...<BR>[]<BR>Status: [] units left.<BR><BR><A href='?src=\ref[];abort=1'>Emergency Abort</A>", M.name, t, src.prog_p4, src)
					if("c")
						if (length(t) <= src.prog_p2)
							src.temp = "Limitation complete"
							src.status = null
						else
							t = copytext(t, 1, length(t))
							src.temp = text("Limiting []'s DNA sequence...<BR>[]<BR>Status: [] units converting to [] units.<BR><BR><A href='?src=\ref[];abort=1'>Emergency Abort</A>", M.name, t, length(t), src.prog_p2, src)
					else
						if (length(t) <= src.prog_p2)
							src.temp = "Limitation complete"
							src.status = null
						else
							t = copytext(t, 2, length(t) + 1)
							src.temp = text("Limiting []'s DNA sequence...<BR>[]<BR>Status: [] units converting to [] units.<BR><BR><A href='?src=\ref[];abort=1'>Emergency Abort</A>", M.name, t, length(t), src.prog_p2, src)
				switch(src.prog_p3)
					if("UI")
						M.primary.uni_identity = t
					if("SE")
						M.primary.struc_enzyme = t
					if("UE")
						M.primary.use_enzyme = t
					if("SI")
						M.primary.spec_identity = t
					else
			else
				src.temp = "Process terminated due to lack of occupant in DNA chamber."
				src.status = null
		else
			if (src.status == "dna_replace")
				if (istype(M, /mob))
					var/t = null
					switch(src.prog_p1)
						if("UI")
							t = M.primary.uni_identity
						if("SE")
							t = M.primary.struc_enzyme
						if("UE")
							t = M.primary.use_enzyme
						if("SI")
							t = M.primary.spec_identity
						else
					if (!( src.prog_p4 ))
						src.prog_p4 = 1
					else
						src.prog_p4++
					if ((src.prog_p4 > length(t) || src.prog_p4 > length(src.prog_p2)))
						src.temp = "Replacement complete"
						src.status = null
					else
						t = text("[][][]", copytext(t, 1, src.prog_p4), copytext(src.prog_p2, src.prog_p4, src.prog_p4 + 1), (src.prog_p4 < length(t) ? copytext(t, src.prog_p4 + 1, length(t) + 1) : null))
						src.temp = text("Replacing []'s DNA sequence...<BR>[]<BR>Target: []<BR>Status: At position []<BR><BR><A href='?src=\ref[];abort=1'>Emergency Abort</A>", M.name, t, src.prog_p2, src.prog_p4, src)
					switch(src.prog_p1)
						if("UI")
							M.primary.uni_identity = t
						if("SE")
							M.primary.struc_enzyme = t
						if("UE")
							M.primary.use_enzyme = t
						if("SI")
							M.primary.spec_identity = t
						else
				else
					src.temp = "Process terminated due to lack of occupant in DNA chamber."
					src.status = null
			else
				if (src.status == "dna_add")
					if (istype(M, /mob))
						var/t = null
						switch(src.prog_p1)
							if("UI")
								t = M.primary.uni_identity
							if("SE")
								t = M.primary.struc_enzyme
							if("UE")
								t = M.primary.use_enzyme
							if("SI")
								t = M.primary.spec_identity
							else
						if (!( src.prog_p4 ))
							src.prog_p4 = 1
						else
							src.prog_p4++
						if (src.prog_p4 > length(src.prog_p2))
							src.temp = "Addition complete"
							src.status = null
						else
							t = text("[][]", t, copytext(src.prog_p2, src.prog_p4, src.prog_p4 + 1))
							src.temp = text("Adding to []'s DNA sequence...<BR>[]<BR>Adding: []<BR>Position: []<BR><BR><A href='?src=\ref[];abort=1'>Emergency Abort</A>", M.name, t, src.prog_p2, src.prog_p4, src)
						switch(src.prog_p1)
							if("UI")
								M.primary.uni_identity = t
							if("SE")
								M.primary.struc_enzyme = t
							if("UE")
								M.primary.use_enzyme = t
							if("SI")
								M.primary.spec_identity = t
							else
					else
						src.temp = "Process terminated due to lack of occupant in DNA chamber."
						src.status = null
				else
					src.status = null
					src.temp = "Unknown system error."
	src.updateDialog()
	return

/obj/machinery/scan_console/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/scan_console/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/scan_console/attack_hand(user as mob)
	if(..())
		return
	var/dat
	if (src.temp)
		dat = text("[]<BR><BR><A href='?src=\ref[];clear=1'>Clear Message</A>", src.temp, src)
	else
		if (src.connected)
			var/mob/occupant = src.connected.occupant
			dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>"
			if (occupant)
				var/t1
				switch(occupant.stat)
					if(0)
						t1 = "Conscious"
					if(1)
						t1 = "Unconscious"
					else
						t1 = "*dead*"
				dat += text("[]\tHealth %: [] ([])</FONT><BR><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
			else
				dat += "The scanner is empty.<BR>"
			if (!( src.connected.locked ))
				dat += text("<A href='?src=\ref[];locked=1'>Lock (Unlocked)</A><BR>", src)
			else
				dat += text("<A href='?src=\ref[];locked=1'>Unlock (Locked)</A><BR>", src)
			dat += text("Disk: <A href='?src=\ref[];scan=1'>[]</A><BR>\n[]<BR>\n[]<BR>", src,
			 	(src.scan ? text("[]", src.scan.name) : "----------"),
			 	(src.scan ? text("<A href='?src=\ref[];u_dat=1'>Upload Data</A>", src) : "No disk to upload"),
			 	((src.data || src.func || src.special) ? text("<A href='?src=\ref[];c_dat=1'>Clear Data</A><BR><A href='?src=\ref[];e_dat=1'>Execute Data</A><BR>Function Type: [][]<BR>Data: []", src, src, src.func, (src.special ? text("-[]", src.special) : null), src.data) : "No data uploaded"))
			dat += text("<BR><BR><A href='?src=\ref[];mach_close=scanner'>Close</A>", user)
	user << browse(dat, "window=scanner;size=400x500")
	onclose(user, "scanner")
	return

/obj/machinery/scan_console/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (get_dist(src, usr) <= 1 || usr.telekinesis == 1) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon/ai)))
		usr.machine = src
		if (href_list["locked"])
			if ((src.connected && src.connected.occupant))
				src.connected.locked = !( src.connected.locked )
		if (href_list["scan"])
			if (src.scan)
				src.scan.loc = src.loc
				src.scan = null
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/weapon/card/data))
					usr.drop_item()
					I.loc = src
					src.scan = I
		if (href_list["u_dat"])
			if ((src.scan && !( src.status )))
				if ((src.scan.function && src.scan.function != "storage"))
					src.func = src.scan.function
					src.special = src.scan.special
				if (src.scan.data)
					src.data = src.scan.data
			else
				src.temp = "No disk found or core data access lock out!"
		if (href_list["c_dat"])
			if (!src.status)
				src.func = null
				src.data = null
				src.special = null
			else
				src.temp = "No disk found or core data access lock out!"
		if (href_list["clear"])
			src.temp = null
		if (href_list["abort"])
			src.status = null
		if (href_list["e_dat"])
			if (!( src.status ))
				src.status = "load"
				src.temp = "Loading..."
		src.add_fingerprint(usr)
		src.updateUsrDialog()
	return

/obj/machinery/restruct/allow_drop()
	return 0

/obj/machinery/restruct/verb/eject()
	set src in oview(1)

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/restruct/verb/operate()
	set src in oview(1)

	src.add_fingerprint(usr)
	if ((src.occupant && src.occupant.primary))
		switch(src.occupant.primary.spec_identity)
			if("5BDFE293BA5500F9FFFD500AAFFE")
				if (!istype(src.occupant, /mob/living/carbon/human))
					for(var/obj/O in src.occupant)
						del(O)

					var/mob/living/carbon/human/O = new /mob/living/carbon/human( src )
					if(ticker.killer == src.occupant)
						O.memory = src.occupant.memory
						ticker.killer = O
					var/mob/M = src.occupant
					O.start = 1
					O.primary = M.primary
					M.primary = null
					var/t1 = hex2num(copytext(O.primary.uni_identity, 25, 28))
					if (t1 < 125)
						O.gender = "male"
					else
						O.gender = "female"
					M << "Genetic Transversal Complete!"
					if (M.client)
						M << "Transferring..."
						M.client.mob = O
					O << "Neural Sequencing Complete!"
					O.loc = src
					src.occupant = O
					//M = null
					del(M)
					src.occupant = O
					src.occupant << "Done!"
			if("2B6696D2B127E5A4")
				if (!istype(src.occupant, /mob/living/carbon/monkey))
					for(var/obj/O in src.occupant)
						del(O)
					var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey(src)
					if(ticker.killer == src.occupant)
						O.memory = src.occupant.memory
						ticker.killer = O
					var/mob/M = src.occupant
					O.start = 1
					O.primary = M.primary
					M.primary = null
					M << "Genetic Transversal Complete!"
					if (M.client)
						M << "Transferring..."
						M.client.mob = O
					O << "Neural Sequencing Complete!"
					O.loc = src
					O << "Genetic Transversal Complete!"
					src.occupant = O
					del(M)
					O.name = text("monkey ([])", copytext(md5(src.occupant.primary.uni_identity), 2, 6))
					src.occupant << "Done!"
			else
		if (istype(src.occupant, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src.occupant

			var/speak = (length(H.primary.struc_enzyme) >= 25 ? hex2num(copytext(H.primary.struc_enzyme, 22, 25)) : 9999)
			var/ears = (length(H.primary.struc_enzyme) >= 10 ? hex2num(copytext(H.primary.struc_enzyme, 7, 10)) : 9999)
			var/vision = (length(H.primary.struc_enzyme) >= 16 ? hex2num(copytext(H.primary.struc_enzyme, 13, 16)) : 1)
			var/mental1 = (length(H.primary.struc_enzyme) >= 31 ? hex2num(copytext(H.primary.struc_enzyme, 28, 31)) : 1)
			var/mental2 = (length(H.primary.struc_enzyme) >= 28 ? hex2num(copytext(H.primary.struc_enzyme, 25, 28)) : 1)
			var/speak2 = (length(H.primary.struc_enzyme) >= 22 ? hex2num(copytext(H.primary.struc_enzyme, 19, 22)) : 1)
			H.sdisabilities = 0
			H.disabilities = 0
			if (speak < 3776)
				H.disabilities = H.disabilities | 4
			else
				if (speak > 3776)
					H.sdisabilities = H.sdisabilities | 2
			if (speak2 < 2640)
				H.disabilities = H.disabilities | 16
			if (ears > 3226)
				H.sdisabilities = H.sdisabilities | 4
			if (vision < 1447)
				H.sdisabilities = H.sdisabilities | 1
			else
				if (vision > 1447)
					H.disabilities = H.disabilities | 1
			if (mental1 < 1742)
				H.disabilities = H.disabilities | 2
			if (mental2 < 1452)
				H.disabilities = H.disabilities | 8
			var/t1 = null
			if (length(H.primary.uni_identity) >= 20)
				t1 = copytext(H.primary.uni_identity, 19, 21)
				if (hex2num(t1) > 127)
					H.gender = "female"
				else
					H.gender = "male"
			else
				H.gender = "neuter"
			if (length(H.primary.uni_identity) >= 18)
				t1 = copytext(H.primary.uni_identity, 17, 19)
				H.ns_tone = hex2num(t1)
				H.ns_tone =  -H.ns_tone + 35
			else
				H.ns_tone = 1
				H.ns_tone =  -H.ns_tone + 35
			if (length(H.primary.uni_identity) >= 16)
				t1 = copytext(H.primary.uni_identity, 15, 17)
				H.b_eyes = hex2num(t1)
			else
				H.b_eyes = 255
			if (length(H.primary.uni_identity) >= 14)
				t1 = copytext(H.primary.uni_identity, 13, 15)
				H.g_eyes = hex2num(t1)
			else
				H.g_eyes = 255
			if (length(H.primary.uni_identity) >= 12)
				t1 = copytext(H.primary.uni_identity, 11, 13)
				H.r_eyes = hex2num(t1)
			else
				H.r_eyes = 255
			if (length(H.primary.uni_identity) >= 10)
				t1 = copytext(H.primary.uni_identity, 9, 11)
				H.nb_hair = hex2num(t1)
			else
				H.nb_hair = 255
			if (length(H.primary.uni_identity) >= 8)
				t1 = copytext(H.primary.uni_identity, 7, 9)
				H.ng_hair = hex2num(t1)
			else
				H.ng_hair = 255
			if (length(H.primary.uni_identity) >= 6)
				t1 = copytext(H.primary.uni_identity, 5, 7)
				H.nr_hair = hex2num(t1)
			else
				H.nr_hair = 255
			H.r_hair = H.nr_hair
			H.g_hair = H.ng_hair
			H.b_hair = H.nb_hair
			H.s_tone = H.ns_tone
			H.update_face()
			H.update_body()

			if (reg_dna[H.primary.uni_identity])
				H.real_name = reg_dna[H.primary.uni_identity]
			else
				var/i
				while (!i)
					var/randomname
					if (src.gender == "male")
						randomname = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
					else
						randomname = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
					if (findname(randomname))
						continue
					else
						H.real_name = randomname
						i++
				reg_dna[H.primary.uni_identity] = H.real_name
			H << text("\red <B>Your name is now [].</B>", H.real_name)
	return

/obj/machinery/restruct/verb/move_inside()
	set src in oview(1)

	if (usr.stat != 0)
		return
	if (src.occupant)
		usr << "\blue <B>The scanner is already occupied!</B>"
		return
	if (usr.abiotic2())
		usr << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	usr.pulling = null
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.loc = src
	src.occupant = usr
	src.icon_state = "restruct_1"
	for(var/obj/O in src)
		//O = null
		del(O)
		//Foreach goto(124)
	src.add_fingerprint(usr)
	return

/obj/machinery/restruct/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/restruct/attackby(obj/item/weapon/grab/G as obj, user as mob)
	if(..())
		return
	if ((!( istype(G, /obj/item/weapon/grab) ) || !( ismob(G.affecting) )))
		return
	if (src.occupant)
		user << "\blue <B>The machine is already occupied!</B>"
		return
	if (G.affecting.abiotic2())
		user << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	var/mob/M = G.affecting
	if (M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.loc = src
	src.occupant = M
	src.icon_state = "restruct_1"
	for(var/obj/O in src)
		O.loc = src.loc
		//Foreach goto(154)
	src.add_fingerprint(user)
	//G = null
	del(G)
	return

/obj/machinery/restruct/proc/go_out()
	if ((!( src.occupant ) || src.locked))
		return
	for(var/obj/O in src)
		O.loc = src.loc
		//Foreach goto(30)
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	src.icon_state = "restruct_0"
	return

/obj/machinery/restruct/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
		else
	return

/obj/machinery/restruct/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)