/obj/machinery/computer/secure_data/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/secure_data/M = new /obj/item/weapon/circuitboard/secure_data( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/secure_data/M = new /obj/item/weapon/circuitboard/secure_data( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	else
		src.attack_hand(user)
	return

/obj/machinery/computer/secure_data/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/secure_data/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/secure_data/attack_hand(mob/user as mob)
	if(..())
		return
	var/dat
	if (src.temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];temp=1'>Clear Screen</A>", src.temp, src)
	else
		dat = text("Confirm Identity: <A href='?src=\ref[];scan=1'>[]</A><HR>", src, (src.scan ? text("[]", src.scan.name) : "----------"))
		if (src.authenticated)
			switch(src.screen)
				if(1.0)
					dat += text("<A href='?src=\ref[];search=1'>Search Records</A><BR>\n<A href='?src=\ref[];list=1'>List Records</A><BR>\n<A href='?src=\ref[];search_f=1'>Search Fingerprints</A><BR>\n<A href='?src=\ref[];new_r=1'>New Record</A><BR>\n<BR>\n<A href='?src=\ref[];rec_m=1'>Record Maintenance</A><BR>\n<A href='?src=\ref[];logout=1'>{Log Out}</A><BR>\n", src, src, src, src, src, src)
				if(2.0)
					dat += "<B>Record List</B>:<HR>"
					for(var/datum/data/record/R in data_core.general)
						dat += text("<A href='?src=\ref[];d_rec=\ref[]'>[]: []<BR>", src, R, R.fields["id"], R.fields["name"])
						//Foreach goto(136)
					dat += text("<HR><A href='?src=\ref[];main=1'>Back</A>", src)
				if(3.0)
					dat += text("<B>Records Maintenance</B><HR>\n<A href='?src=\ref[];back=1'>Backup To Disk</A><BR>\n<A href='?src=\ref[];u_load=1'>Upload From disk</A><BR>\n<A href='?src=\ref[];del_all=1'>Delete All Records</A><BR>\n<BR>\n<A href='?src=\ref[];main=1'>Back</A>", src, src, src, src)
				if(4.0)
					dat += "<CENTER><B>Security Record</B></CENTER><BR>"
					if ((istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1)))
						dat += text("Name: <A href='?src=\ref[];field=name'>[]</A> ID: <A href='?src=\ref[];field=id'>[]</A><BR>\nSex: <A href='?src=\ref[];field=sex'>[]</A><BR>\nAge: <A href='?src=\ref[];field=age'>[]</A><BR>\nRank: <A href='?src=\ref[];field=rank'>[]</A><BR>\nFingerprint: <A href='?src=\ref[];field=fingerprint'>[]</A><BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", src, src.active1.fields["name"], src, src.active1.fields["id"], src, src.active1.fields["sex"], src, src.active1.fields["age"], src, src.active1.fields["rank"], src, src.active1.fields["fingerprint"], src.active1.fields["p_stat"], src.active1.fields["m_stat"])
					else
						dat += "<B>General Record Lost!</B><BR>"
					if ((istype(src.active2, /datum/data/record) && data_core.security.Find(src.active2)))
						dat += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: <A href='?src=\ref[];field=criminal'>[]</A><BR>\n<BR>\nMinor Crimes: <A href='?src=\ref[];field=mi_crim'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=mi_crim_d'>[]</A><BR>\n<BR>\nMajor Crimes: <A href='?src=\ref[];field=ma_crim'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=ma_crim_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[];field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src, src.active2.fields["criminal"], src, src.active2.fields["mi_crim"], src, src.active2.fields["mi_crim_d"], src, src.active2.fields["ma_crim"], src, src.active2.fields["ma_crim_d"], src, src.active2.fields["notes"])
						var/counter = 1
						while(src.active2.fields[text("com_[]", counter)])
							dat += text("[]<BR><A href='?src=\ref[];del_c=[]'>Delete Entry</A><BR><BR>", src.active2.fields[text("com_[]", counter)], src, counter)
							counter++
						dat += text("<A href='?src=\ref[];add_c=1'>Add Entry</A><BR><BR>", src)
						dat += text("<A href='?src=\ref[];del_r=1'>Delete Record (Security Only)</A><BR><BR>", src)
					else
						dat += "<B>Security Record Lost!</B><BR>"
						dat += text("<A href='?src=\ref[];new=1'>New Record</A><BR><BR>", src)
					dat += text("\n<A href='?src=\ref[];dela_r=1'>Delete Record (ALL)</A><BR><BR>\n<A href='?src=\ref[];print_p=1'>Print Record</A><BR>\n<A href='?src=\ref[];list=1'>Back</A><BR>", src, src, src)
				else
		else
			dat += text("<A href='?src=\ref[];login=1'>{Log In}</A>", src)
	user << browse(text("<HEAD><TITLE>Security Records</TITLE></HEAD><TT>[]</TT>", dat), "window=secure_rec")
	onclose(user, "secure_rec")
	return

/obj/machinery/computer/secure_data/Topic(href, href_list)
	if(..())
		return
	if (!( data_core.general.Find(src.active1) ))
		src.active1 = null
	if (!( data_core.security.Find(src.active2) ))
		src.active2 = null
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if (href_list["temp"])
			src.temp = null
		if (href_list["scan"])
			if (src.scan)
				src.scan.loc = src.loc
				src.scan = null
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I.loc = src
					src.scan = I
		else
			if (href_list["logout"])
				src.authenticated = null
				src.screen = null
				src.active1 = null
				src.active2 = null
			else
				if (href_list["login"])
					if (istype(usr, /mob/living/silicon))
						src.active1 = null
						src.active2 = null
						src.authenticated = 1
						src.rank = "AI"
						src.screen = 1
					if (istype(src.scan, /obj/item/weapon/card/id))
						src.active1 = null
						src.active2 = null
						if(check_access(src.scan))
							src.authenticated = src.scan.registered
							src.rank = src.scan.assignment
							src.screen = 1
		if (src.authenticated)
			if (href_list["list"])
				src.screen = 2
				src.active1 = null
				src.active2 = null
			else
				if (href_list["rec_m"])
					src.screen = 3
					src.active1 = null
					src.active2 = null
				else
					if (href_list["del_all"])
						src.temp = text("Are you sure you wish to delete all records?<br>\n\t<A href='?src=\ref[];temp=1;del_all2=1'>Yes</A><br>\n\t<A href='?src=\ref[];temp=1'>No</A><br>", src, src)
					else
						if (href_list["del_all2"])
							for(var/datum/data/record/R in data_core.security)
								//R = null
								del(R)
								//Foreach goto(497)
							src.temp = "All records deleted."
						else
							if (href_list["main"])
								src.screen = 1
								src.active1 = null
								src.active2 = null
							else
								if (href_list["field"])
									var/a1 = src.active1
									var/a2 = src.active2
									switch(href_list["field"])
										if("name")
											if (istype(src.active1, /datum/data/record))
												var/t1 = input("Please input name:", "Secure. records", src.active1.fields["name"], null)  as text
												if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon)))) || src.active1 != a1)
													return
												src.active1.fields["name"] = t1
										if("id")
											if (istype(src.active2, /datum/data/record))
												var/t1 = input("Please input id:", "Secure. records", src.active1.fields["id"], null)  as text
												if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active1 != a1))
													return
												src.active1.fields["id"] = t1
										if("fingerprint")
											if (istype(src.active1, /datum/data/record))
												var/t1 = input("Please input fingerprint hash:", "Secure. records", src.active1.fields["fingerprint"], null)  as text
												if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active1 != a1))
													return
												src.active1.fields["fingerprint"] = t1
										if("sex")
											if (istype(src.active1, /datum/data/record))
												if (src.active1.fields["sex"] == "Male")
													src.active1.fields["sex"] = "Female"
												else
													src.active1.fields["sex"] = "Male"
										if("age")
											if (istype(src.active1, /datum/data/record))
												var/t1 = input("Please input age:", "Secure. records", src.active1.fields["age"], null)  as text
												if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active1 != a1))
													return
												src.active1.fields["age"] = t1
										if("mi_crim")
											if (istype(src.active2, /datum/data/record))
												var/t1 = input("Please input minor disabilities list:", "Secure. records", src.active2.fields["mi_crim"], null)  as text
												if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
													return
												src.active2.fields["mi_crim"] = t1
										if("mi_crim_d")
											if (istype(src.active2, /datum/data/record))
												var/t1 = input("Please summarize minor dis.:", "Secure. records", src.active2.fields["mi_crim_d"], null)  as message
												if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
													return
												src.active2.fields["mi_crim_d"] = t1
										if("ma_crim")
											if (istype(src.active2, /datum/data/record))
												var/t1 = input("Please input major diabilities list:", "Secure. records", src.active2.fields["ma_crim"], null)  as text
												if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
													return
												src.active2.fields["ma_crim"] = t1
										if("ma_crim_d")
											if (istype(src.active2, /datum/data/record))
												var/t1 = input("Please summarize major dis.:", "Secure. records", src.active2.fields["ma_crim_d"], null)  as message
												if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
													return
												src.active2.fields["ma_crim_d"] = t1
										if("notes")
											if (istype(src.active2, /datum/data/record))
												var/t1 = input("Please summarize notes:", "Secure. records", src.active2.fields["notes"], null)  as message
												if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
													return
												src.active2.fields["notes"] = t1
										if("criminal")
											if (istype(src.active2, /datum/data/record))
												src.temp = text("<B>Criminal Status:</B><BR>\n\t<A href='?src=\ref[];temp=1;criminal2=none'>None</A><BR>\n\t<A href='?src=\ref[];temp=1;criminal2=arrest'>*Arrest*</A><BR>\n\t<A href='?src=\ref[];temp=1;criminal2=incarcerated'>Incarcerated</A><BR>\n\t<A href='?src=\ref[];temp=1;criminal2=parolled'>Parolled</A><BR>\n\t<A href='?src=\ref[];temp=1;criminal2=released'>Released</A><BR>", src, src, src, src, src)
										if("rank")
											var/list/L = list( "Head of Personnel", "Captain", "AI" )
											if ((istype(src.active1, /datum/data/record) && L.Find(src.rank)))
												src.temp = text("<B>Rank:</B><BR>\n<B>Assistants:</B><BR>\n<A href='?src=\ref[];temp=1;rank=res_assist'>Assistant</A><BR>\n<B>Technicians:</B><BR>\n<A href='?src=\ref[];temp=1;rank=foren_tech'>Detective</A><BR>\n<A href='?src=\ref[];temp=1;rank=atmo_tech'>Atmospheric Technician</A><BR>\n<A href='?src=\ref[];temp=1;rank=engineer'>Station Engineer</A><BR>\n<B>Researchers:</B><BR>\n<A href='?src=\ref[];temp=1;rank=med_res'>Geneticist</A><BR>\n<A href='?src=\ref[];temp=1;rank=tox_res'>Scientist</A><BR>\n<B>Officers:</B><BR>\n<A href='?src=\ref[];temp=1;rank=med_doc'>Medical Doctor</A><BR>\n<A href='?src=\ref[];temp=1;rank=secure_off'>Security Officer</A><BR>\n<B>Higher Officers:</B><BR>\n<A href='?src=\ref[];temp=1;rank=hoperson'>Head of Security</A><BR>\n<A href='?src=\ref[];temp=1;rank=hosecurity'>Head of Personnel</A><BR>\n<A href='?src=\ref[];temp=1;rank=captain'>Captain</A><BR>", src, src, src, src, src, src, src, src, src, src, src)
											else
												alert(usr, "You do not have the required rank to do this!")
										else
								else
									if (href_list["rank"])
										if (src.active1)
											switch(href_list["rank"])
												if("res_assist")
													src.active1.fields["rank"] = "Assistant"
												if("foren_tech")
													src.active1.fields["rank"] = "Detective"
												if("atmo_tech")
													src.active1.fields["rank"] = "Atmospheric Technician"
												if("engineer")
													src.active1.fields["rank"] = "Station Engineer"
												if("med_res")
													src.active1.fields["rank"] = "Geneticist"
												if("tox_res")
													src.active1.fields["rank"] = "Scientist"
												if("med_doc")
													src.active1.fields["rank"] = "Medical Doctor"
												if("secure_off")
													src.active1.fields["rank"] = "Security Officer"
												if("hoperson")
													src.active1.fields["rank"] = "Head of Security"
												if("hosecurity")
													src.active1.fields["rank"] = "Head of Personnel"
												if("captain")
													src.active1.fields["rank"] = "Captain"
												if("barman")
													src.active1.fields["rank"] = "Barman"
												if("chemist")
													src.active1.fields["rank"] = "Chemist"
												if("janitor")
													src.active1.fields["rank"] = "Janitor"
												if("clown")
													src.active1.fields["rank"] = "Clown"

									else
										if (href_list["criminal2"])
											if (src.active2)
												switch(href_list["criminal2"])
													if("none")
														src.active2.fields["criminal"] = "None"
													if("arrest")
														src.active2.fields["criminal"] = "*Arrest*"
													if("incarcerated")
														src.active2.fields["criminal"] = "Incarcerated"
													if("parolled")
														src.active2.fields["criminal"] = "Parolled"
													if("released")
														src.active2.fields["criminal"] = "Released"

										else
											if (href_list["del_r"])
												if (src.active2)
													src.temp = text("Are you sure you wish to delete the record (Security Portion Only)?<br>\n\t<A href='?src=\ref[];temp=1;del_r2=1'>Yes</A><br>\n\t<A href='?src=\ref[];temp=1'>No</A><br>", src, src)
											else
												if (href_list["del_r2"])
													if (src.active2)
														//src.active2 = null
														del(src.active2)
												else
													if (href_list["dela_r"])
														if (src.active1)
															src.temp = text("Are you sure you wish to delete the record (ALL)?<br>\n\t<A href='?src=\ref[];temp=1;dela_r2=1'>Yes</A><br>\n\t<A href='?src=\ref[];temp=1'>No</A><br>", src, src)
													else
														if (href_list["dela_r2"])
															for(var/datum/data/record/R in data_core.medical)
																if ((R.fields["name"] == src.active1.fields["name"] || R.fields["id"] == src.active1.fields["id"]))
																	//R = null
																	del(R)
																else
															if (src.active2)
																//src.active2 = null
																del(src.active2)
															if (src.active1)
																//src.active1 = null
																del(src.active1)
														else
															if (href_list["d_rec"])
																var/datum/data/record/R = locate(href_list["d_rec"])
																var/S = locate(href_list["d_rec"])
																if (!( data_core.general.Find(R) ))
																	src.temp = "Record Not Found!"
																	return
																for(var/datum/data/record/E in data_core.security)
																	if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
																		S = E
																	else
																		//Foreach continue //goto(2614)
																src.active1 = R
																src.active2 = S
																src.screen = 4
															else
																if (href_list["new_r"])
																	var/datum/data/record/G = new /datum/data/record(  )
																	G.fields["name"] = "New Record"
																	G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
																	G.fields["rank"] = "Unassigned"
																	G.fields["sex"] = "Male"
																	G.fields["age"] = "Unknown"
																	G.fields["fingerprint"] = "Unknown"
																	G.fields["p_stat"] = "Active"
																	G.fields["m_stat"] = "Stable"
																	data_core.general += G
																	src.active1 = G
																	src.active2 = null
																else
																	if (href_list["new"])
																		if ((istype(src.active1, /datum/data/record) && !( istype(src.active2, /datum/data/record) )))
																			var/datum/data/record/R = new /datum/data/record(  )
																			R.fields["name"] = src.active1.fields["name"]
																			R.fields["id"] = src.active1.fields["id"]
																			R.name = text("Security Record #[]", R.fields["id"])
																			R.fields["criminal"] = "None"
																			R.fields["mi_crim"] = "None"
																			R.fields["mi_crim_d"] = "No minor crime convictions."
																			R.fields["ma_crim"] = "None"
																			R.fields["ma_crim_d"] = "No major crime convictions."
																			R.fields["notes"] = "No notes."
																			data_core.security += R
																			src.active2 = R
																			src.screen = 4
																	else
																		if (href_list["add_c"])
																			if (!( istype(src.active2, /datum/data/record) ))
																				return
																			var/a2 = src.active2
																			var/t1 = input("Add Comment:", "Secure. records", null, null)  as message
																			if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
																				return
																			var/counter = 1
																			while(src.active2.fields[text("com_[]", counter)])
																				counter++
																			src.active2.fields[text("com_[]", counter)] = text("Made by [] ([]) on [], 2053<BR>[]", src.authenticated, src.rank, time2text(world.realtime, "DDD MMM DD hh:mm:ss"), t1)
																		else
																			if (href_list["del_c"])
																				if ((istype(src.active2, /datum/data/record) && src.active2.fields[text("com_[]", href_list["del_c"])]))
																					src.active2.fields[text("com_[]", href_list["del_c"])] = "<B>Deleted</B>"
																			else
																				if (href_list["search_f"])
																					var/t1 = input("Search String: (Fingerprint)", "Secure. records", null, null)  as text
																					if ((!( t1 ) || usr.stat || !( src.authenticated ) || usr.restrained() || (!in_range(src, usr)) && (!istype(usr, /mob/living/silicon))))
																						return
																					src.active1 = null
																					src.active2 = null
																					t1 = lowertext(t1)
																					for(var/datum/data/record/R in data_core.general)
																						if (lowertext(R.fields["fingerprint"]) == t1)
																							src.active1 = R
																						else
																							//Foreach continue //goto(3414)
																					if (!( src.active1 ))
																						src.temp = text("Could not locate record [].", t1)
																					else
																						for(var/datum/data/record/E in data_core.security)
																							if ((E.fields["name"] == src.active1.fields["name"] || E.fields["id"] == src.active1.fields["id"]))
																								src.active2 = E
																							else
																								//Foreach continue //goto(3502)
																						src.screen = 4
																				else
																					if (href_list["search"])
																						var/t1 = input("Search String: (Name or ID)", "Secure. records", null, null)  as text
																						if ((!( t1 ) || usr.stat || !( src.authenticated ) || usr.restrained() || !in_range(src, usr)))
																							return
																						src.active1 = null
																						src.active2 = null
																						t1 = lowertext(t1)
																						for(var/datum/data/record/R in data_core.general)
																							if ((lowertext(R.fields["name"]) == t1 || t1 == lowertext(R.fields["id"])))
																								src.active1 = R
																							else
																								//Foreach continue //goto(3708)
																						if (!( src.active1 ))
																							src.temp = text("Could not locate record [].", t1)
																						else
																							for(var/datum/data/record/E in data_core.security)
																								if ((E.fields["name"] == src.active1.fields["name"] || E.fields["id"] == src.active1.fields["id"]))
																									src.active2 = E
																								else
																									//Foreach continue //goto(3813)
																							src.screen = 4
																					else
																						if (href_list["print_p"])
																							if (!( src.printing ))
																								src.printing = 1
																								sleep(50)
																								var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( src.loc )
																								P.info = "<CENTER><B>Security Record</B></CENTER><BR>"
																								if ((istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1)))
																									P.info += text("Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", src.active1.fields["name"], src.active1.fields["id"], src.active1.fields["sex"], src.active1.fields["age"], src.active1.fields["fingerprint"], src.active1.fields["p_stat"], src.active1.fields["m_stat"])
																								else
																									P.info += "<B>General Record Lost!</B><BR>"
																								if ((istype(src.active2, /datum/data/record) && data_core.security.Find(src.active2)))
																									P.info += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: []<BR>\n<BR>\nMinor Crimes: []<BR>\nDetails: []<BR>\n<BR>\nMajor Crimes: []<BR>\nDetails: []<BR>\n<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src.active2.fields["criminal"], src.active2.fields["mi_crim"], src.active2.fields["mi_crim_d"], src.active2.fields["ma_crim"], src.active2.fields["ma_crim_d"], src.active2.fields["notes"])
																									var/counter = 1
																									while(src.active2.fields[text("com_[]", counter)])
																										P.info += text("[]<BR>", src.active2.fields[text("com_[]", counter)])
																										counter++
																								else
																									P.info += "<B>Security Record Lost!</B><BR>"
																								P.info += "</TT>"
																								P.name = "paper- 'Security Record'"
																								src.printing = null
	src.add_fingerprint(usr)
	src.updateUsrDialog()

	return

