/*
 * Paper
 * also scraps of paper
 *
 * lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!
 */

/obj/item/weapon/paper
	name = "paper"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	throwforce = 0
	w_class = 1
	throw_range = 1
	throw_speed = 1
	layer = 3
	pressure_resistance = 0
	slot_flags = SLOT_HEAD
	body_parts_covered = HEAD
	burn_state = FLAMMABLE
	burntime = 5

	var/info		//What's actually written on the paper.
	var/info_links	//A different version of the paper which includes html links at fields and EOF
	var/stamps		//The (text for the) stamps on the paper.
	var/fields		//Amount of user created fields
	var/list/stamped
	var/rigged = 0
	var/spam_flag = 0


/obj/item/weapon/paper/New()
	..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	update_icon()
	updateinfolinks()


/obj/item/weapon/paper/update_icon()
	if(burn_state == ON_FIRE)
		icon_state = "paper_onfire"
		return
	if(info)
		icon_state = "paper_words"
		return
	icon_state = "paper"


/obj/item/weapon/paper/examine(mob/user)
	..()
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/paper)
	assets.send(user)

	if(in_range(user, src) || isobserver(user))
		if( !(ishuman(user) || isobserver(user) || issilicon(user)) )
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(info)]<HR>[stamps]</BODY></HTML>", "window=[name]")
			onclose(user, "[name]")
		else
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info]<HR>[stamps]</BODY></HTML>", "window=[name]")
			onclose(user, "[name]")
	else
		user << "<span class='notice'>It is too far away.</span>"


/obj/item/weapon/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(H.disabilities & CLUMSY && prob(25))
		H << "<span class='warning'>You cut yourself on the paper! Ahhhh! Ahhhhh!</span>"
		H.damageoverlaytemp = 9001
		H.update_damage_hud()
		return
	var/n_name = stripped_input(usr, "What would you like to label the paper?", "Paper Labelling", null, MAX_NAME_LEN)
	if((loc == usr && usr.stat == 0))
		name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)

/obj/item/weapon/paper/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] scratches a grid on their wrist with the paper! It looks like \he's trying to commit sudoku..</span>")
	return (BRUTELOSS)

/obj/item/weapon/paper/attack_self(mob/user)
	user.examinate(src)
	if(rigged && (SSevent.holidays && SSevent.holidays[APRIL_FOOLS]))
		if(spam_flag == 0)
			spam_flag = 1
			playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
			spawn(20)
				spam_flag = 0


/obj/item/weapon/paper/attack_ai(mob/living/silicon/ai/user)
	var/dist
	if(istype(user) && user.current) //is AI
		dist = get_dist(src, user.current)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if(dist < 2)
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info]<HR>[stamps]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")
	else
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(info)]<HR>[stamps]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")


/obj/item/weapon/paper/proc/addtofield(id, text, links = 0)
	var/locid = 0
	var/laststart = 1
	var/textindex = 1
	while(1)	//I know this can cause infinite loops and fuck up the whole server, but the if(istart==0) should be safe as fuck
		var/istart = 0
		if(links)
			istart = findtext(info_links, "<span class=\"paper_field\">", laststart)
		else
			istart = findtext(info, "<span class=\"paper_field\">", laststart)

		if(istart == 0)
			return	//No field found with matching id

		laststart = istart+1
		locid++
		if(locid == id)
			var/iend = 1
			if(links)
				iend = findtext(info_links, "</span>", istart)
			else
				iend = findtext(info, "</span>", istart)

			//textindex = istart+26
			textindex = iend
			break

	if(links)
		var/before = copytext(info_links, 1, textindex)
		var/after = copytext(info_links, textindex)
		info_links = before + text + after
	else
		var/before = copytext(info, 1, textindex)
		var/after = copytext(info, textindex)
		info = before + text + after
		updateinfolinks()


/obj/item/weapon/paper/proc/updateinfolinks()
	info_links = info
	var/i = 0
	for(i=1,i<=fields,i++)
		addtofield(i, "<font face=\"[PEN_FONT]\"><A href='?src=\ref[src];write=[i]'>write</A></font>", 1)
	info_links = info_links + "<font face=\"[PEN_FONT]\"><A href='?src=\ref[src];write=end'>write</A></font>"


/obj/item/weapon/paper/proc/clearpaper()
	info = null
	stamps = null
	stamped = list()
	overlays.Cut()
	updateinfolinks()
	update_icon()


/obj/item/weapon/paper/proc/parsepencode(t, obj/item/weapon/pen/P, mob/user, iscrayon = 0)
	if(length(t) < 1)		//No input means nothing needs to be parsed
		return

//	t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)

	t = replacetext(t, "\[center\]", "<center>")
	t = replacetext(t, "\[/center\]", "</center>")
	t = replacetext(t, "\[br\]", "<BR>")
	t = replacetext(t, "\[b\]", "<B>")
	t = replacetext(t, "\[/b\]", "</B>")
	t = replacetext(t, "\[i\]", "<I>")
	t = replacetext(t, "\[/i\]", "</I>")
	t = replacetext(t, "\[u\]", "<U>")
	t = replacetext(t, "\[/u\]", "</U>")
	t = replacetext(t, "\[large\]", "<font size=\"4\">")
	t = replacetext(t, "\[/large\]", "</font>")
	t = replacetext(t, "\[sign\]", "<font face=\"[SIGNFONT]\"><i>[user.real_name]</i></font>")
	t = replacetext(t, "\[field\]", "<span class=\"paper_field\"></span>")

	if(!iscrayon)
		t = replacetext(t, "\[*\]", "<li>")
		t = replacetext(t, "\[hr\]", "<HR>")
		t = replacetext(t, "\[small\]", "<font size = \"1\">")
		t = replacetext(t, "\[/small\]", "</font>")
		t = replacetext(t, "\[list\]", "<ul>")
		t = replacetext(t, "\[/list\]", "</ul>")

		t = "<font face=\"[PEN_FONT]\" color=[P.colour]>[t]</font>"
	else // If it is a crayon, and he still tries to use these, make them empty!
		var/obj/item/toy/crayon/C = P
		t = replacetext(t, "\[*\]", "")
		t = replacetext(t, "\[hr\]", "")
		t = replacetext(t, "\[small\]", "")
		t = replacetext(t, "\[/small\]", "")
		t = replacetext(t, "\[list\]", "")
		t = replacetext(t, "\[/list\]", "")

		t = "<font face=\"[CRAYON_FONT]\" color=[C.paint_color]><b>[t]</b></font>"

//	t = replacetext(t, "#", "") // Junk converted to nothing!

//Count the fields
	var/laststart = 1
	while(1)
		var/i = findtext(t, "<span class=\"paper_field\">", laststart)
		if(i == 0)
			break
		laststart = i+1
		fields++

	return t


/obj/item/weapon/paper/proc/openhelp(mob/user)
	user << browse({"<HTML><HEAD><TITLE>Pen Help</TITLE></HEAD>
	<BODY>
		<b><center>Crayon&Pen commands</center></b><br>
		<br>
		\[br\] : Creates a linebreak.<br>
		\[center\] - \[/center\] : Centers the text.<br>
		\[b\] - \[/b\] : Makes the text <b>bold</b>.<br>
		\[i\] - \[/i\] : Makes the text <i>italic</i>.<br>
		\[u\] - \[/u\] : Makes the text <u>underlined</u>.<br>
		\[large\] - \[/large\] : Increases the <font size = \"4\">size</font> of the text.<br>
		\[sign\] : Inserts a signature of your name in a foolproof way.<br>
		\[field\] : Inserts an invisible field which lets you start type from there. Useful for forms.<br>
		<br>
		<b><center>Pen exclusive commands</center></b><br>
		\[small\] - \[/small\] : Decreases the <font size = \"1\">size</font> of the text.<br>
		\[list\] - \[/list\] : A list.<br>
		\[*\] : A dot used for lists.<br>
		\[hr\] : Adds a horizontal rule.
	</BODY></HTML>"}, "window=paper_help")


/obj/item/weapon/paper/Topic(href, href_list)
	..()
	if(usr.stat || usr.restrained())
		return

	if(href_list["write"])
		var/id = href_list["write"]
		var/t =  stripped_multiline_input("Enter what you want to write:", "Write")
		if(!t)
			return
		var/obj/item/i = usr.get_active_hand()	//Check to see if he still got that darn pen, also check if he's using a crayon or pen.
		var/iscrayon = 0
		if(!istype(i, /obj/item/weapon/pen))
			if(!istype(i, /obj/item/toy/crayon))
				return
			iscrayon = 1

		if(!in_range(src, usr) && loc != usr && !istype(loc, /obj/item/weapon/clipboard) && loc.loc != usr && usr.get_active_hand() != i)	//Some check to see if he's allowed to write
			return

		t = parsepencode(t, i, usr, iscrayon) // Encode everything from pencode to html

		if(t != null)	//No input from the user means nothing needs to be added
			if(id!="end")
				addtofield(text2num(id), t) // He wants to edit a field, let him.
			else
				info += t // Oh, he wants to edit to the end of the file, let him.
				updateinfolinks()

			usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info_links]<HR>[stamps]</BODY></HTML>", "window=[name]") // Update the window
			update_icon()


/obj/item/weapon/paper/attackby(obj/item/weapon/P, mob/living/carbon/human/user, params)
	..()

	if(burn_state == ON_FIRE)
		return

	if(is_blind(user))
		return

	if(istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		if(user.IsAdvancedToolUser())
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info_links]<HR>[stamps]</BODY></HTML>", "window=[name]")
			return
		else
			user << "<span class='notice'>You don't know how to read or write.</span>"
			return
		if(istype(src, /obj/item/weapon/paper/talisman/))
			user << "<span class='warning'>[P]'s ink fades away shortly after it is written.</span>"
			return

	else if(istype(P, /obj/item/weapon/stamp))
		if(!in_range(src, usr) && loc != user && !istype(loc, /obj/item/weapon/clipboard) && loc.loc != user && user.get_active_hand() != P)
			return

		stamps += "<img src=large_[P.icon_state].png>"

		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		stampoverlay.pixel_x = rand(-2, 2)
		stampoverlay.pixel_y = rand(-3, 2)

		stampoverlay.icon_state = "paper_[P.icon_state]"

		if(!stamped)
			stamped = new
		stamped += P.type
		overlays += stampoverlay

		user << "<span class='notice'>You stamp the paper with your rubber stamp.</span>"

	if(P.is_hot())
		if(user.disabilities & CLUMSY && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites themselves!</span>", \
								"<span class='userdanger'>You miss the paper and accidentally light yourself on fire!</span>")
			user.unEquip(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return

		if(!(in_range(user, src))) //to prevent issues as a result of telepathically lighting a paper
			return

		user.unEquip(src)
		user.visible_message("<span class='danger'>[user] lights [src] ablaze with [P]!</span>", "<span class='danger'>You light [src] on fire!</span>")
		fire_act()



	add_fingerprint(user)

/obj/item/weapon/paper/fire_act()
	..(0)
	icon_state = "paper_onfire"
	info = "[stars(info)]"


/obj/item/weapon/paper/extinguish()
	..()
	update_icon()

/*
 * Premade paper
 */

/obj/item/weapon/paper/Court
	name = "paper- 'Judgement'"
	info = "For crimes against the station, the offender is sentenced to:<BR>\n<BR>\n"

/obj/item/weapon/paper/Toxin
	name = "paper- 'Chemical Information'"
	info = "Known Onboard Toxins:<BR>\n\tGrade A Semi-Liquid Plasma:<BR>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<BR>\n\t\tA gas mask fails to filter plasma after 50 units.<BR>\n\t\tWill attempt to diffuse like a gas.<BR>\n\t\tFiltered by scrubbers.<BR>\n\t\tThere is a bottled version which is very different<BR>\n\t\t\tfrom the version found in canisters!<BR>\n<BR>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<BR>\n\t\texcept in a enclosed fire area!<BR>\n\t\tWARNING: It is a crime to use this without authorization.<BR>\nKnown Onboard Anti-Toxin:<BR>\n\tAnti-Toxin Type 01P: Works against Grade A Plasma.<BR>\n\t\tBest if injected directly into bloodstream.<BR>\n\t\tA full injection is in every regular Med-Kit.<BR>\n\t\tSpecial toxin Kits hold around 7.<BR>\n<BR>\nKnown Onboard Chemicals (other):<BR>\n\tRejuvenation T#001:<BR>\n\t\tEven 1 unit injected directly into the bloodstream<BR>\n\t\t\twill cure paralysis and sleep toxins.<BR>\n\t\tIf administered to a dying patient it will prevent<BR>\n\t\t\tfurther damage for about units*3 seconds.<BR>\n\t\t\tit will not cure them or allow them to be cured.<BR>\n\t\tIt can be administeredd to a non-dying patient<BR>\n\t\t\tbut the chemicals disappear just as fast.<BR>\n\tMorphine T#054:<BR>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<BR>\n\t\t\tThe effect are cumulative.<BR>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/weapon/paper/courtroom
	name = "paper- 'A Crash Course in Legal SOP on SS13'"
	info = "<B>Roles:</B><BR>\nThe Detective is basically the investigator and prosecutor.<BR>\nThe Staff Assistant can perform these functions with written authority from the Detective.<BR>\nThe Captain/HoP/Warden is ct as the judicial authority.<BR>\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.<BR>\n<BR>\n<B>Investigative Phase:</B><BR>\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<BR>\n<BR>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<BR>\n<BR>\n<B>Pre-Pre-Trial Phase:</B><BR>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<BR>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<BR>\n<B>Possible Motions:</B><BR>\n1. <U>Invalidate Evidence-</U> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<BR>\n2. <U>Free Movement-</U> Basically the defendant is to be kept uncuffed before and during the trial.<BR>\n3. <U>Subpoena Witness-</U> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<BR>\n4. <U>Drop the Charges-</U> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<BR>\n5. <U>Declare Incompetent-</U> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<BR>\n<BR>\nALL SIDES MOVE TO A COURTROOM<BR>\n<B>Pre-Trial Hearings:</B><BR>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<BR>\n<BR>\n<B>The Trial:</B><BR>\nThe trial has three phases.<BR>\n1. <B>Opening Arguments</B>- Each side can give a short speech. They may not present ANY evidence.<BR>\n2. <B>Witness Calling/Evidence Presentation</B>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<BR>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<BR>\n3. <B>Closing Arguments</B>- Same as opening.<BR>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<BR>\n<BR>\n<B>Sentencing Phase:</B><BR>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <BR>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<BR>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<BR>\n<BR>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<BR>\n"

/obj/item/weapon/paper/hydroponics
	name = "paper- 'Greetings from Billy Bob'"
	info = "<B>Hey fellow botanist!</B><BR>\n<BR>\nI didn't trust the station folk so I left<BR>\na couple of weeks ago. But here's some<BR>\ninstructions on how to operate things here.<BR>\nYou can grow plants and each iteration they become<BR>\nstronger, more potent and have better yield, if you<BR>\nknow which ones to pick. Use your botanist's analyzer<BR>\nfor that. You can turn harvested plants into seeds<BR>\nat the seed extractor, and replant them for better stuff!<BR>\nSometimes if the weed level gets high in the tray<BR>\nmutations into different mushroom or weed species have<BR>\nbeen witnessed. On the rare occassion even weeds mutate!<BR>\n<BR>\nEither way, have fun!<BR>\n<BR>\nBest regards,<BR>\nBilly Bob Johnson.<BR>\n<BR>\nPS.<BR>\nHere's a few tips:<BR>\nIn nettles, potency = damage<BR>\nIn amanitas, potency = deadliness + side effect<BR>\nIn Liberty caps, potency = drug power + effect<BR>\nIn chilis, potency = heat<BR>\n<B>Nutrients keep mushrooms alive!</B><BR>\n<B>Water keeps weeds such as nettles alive!</B><BR>\n<B>All other plants need both.</B>"

/obj/item/weapon/paper/djstation
	name = "paper - 'DJ Listening Outpost'"
	info = "<B>Welcome new owner!</B><BR><BR>You have purchased the latest in listening equipment. The telecommunication setup we created is the best in listening to common and private radio frequencies. Here is a step by step guide to start listening in on those saucy radio channels:<br><ol><li>Equip yourself with a multitool</li><li>Use the multitool on the relay.</li><li>Turn it on. It has already been configured for you to listen on.</li></ol> Simple as that. Now to listen to the private channels, you'll have to configure the intercoms. They are located on the front desk. Here is a list of frequencies for you to listen on.<br><ul><li>145.9 - Common Channel</li><li>144.7 - Private AI Channel</li><li>135.9 - Security Channel</li><li>135.7 - Engineering Channel</li><li>135.5 - Medical Channel</li><li>135.3 - Command Channel</li><li>135.1 - Science Channel</li><li>134.9 - Service Channel</li><li>134.7 - Supply Channel</li>"

/obj/item/weapon/paper/jobs
	name = "paper- 'Job Information'"
	info = "Information on all formal jobs that can be obtained on the station can be found on this document.<BR>The data will be in the following form:<BR><B>Job Name</B><BR>Job Description<BR>Job Duties<BR><BR><B>Captain</B><BR>This is the highest ranking position on the station. The Captain can go anywhere and everywhere on the station in order to perform their duties. They can assign jobs, positions, and accesses.<BR>1. Manage your Department Heads<BR>2. Protect the Nuclear Authentication Disk.<BR>3. Keep morale high.<BR><BR><B>Head of Personnel</B><BR>The Head of Personnel is in charge of managing the Cargo & Services departments, as well as assigning accesses and, in the event of the Captain being absent or dead, serving as Acting Captain.<BR>1. Assign jobs and ranks.<BR>2. Manage Cargo & Service.<BR>3. Act as the Captain's Second-In-Command<BR><BR><B>Head of Security</B><BR>The Head of Security manages the Security Department. The Head of Security should direct officers, monitor the distribution of armory weapons in an emergency, and manage station responses to security emergencies.<BR>1. Manage Security.<BR>2. Protect the Station.<BR>3. Protect the Crew.<BR><BR><B>Chief Engineer</B><BR>The Chief Engineer manages Engineering and keeps the station running.<BR>1. Coordinate Engineering<BR>2. Maintain Telecommunications<BR>3. Keep the Station Pressurized<BR><BR><B>Research Director</B><BR>The Research Director manages the Research Department, creating interesting gadgets and equipment for the crew through the work of his scientists.<BR>1. Supervise research efforts.<BR>2. Ensure Robotics is working well. <BR> 3. Keep Xenobiology secure.<BR><BR><B>Chief Medical Officer</B><BR>The Chief Medical Officer is in charge of coordinating the Medical Department, ensuring crew members are healed or if they die, they are cloned.<BR>1. Coordinate Medical<BR>2. Keep Crew Alive<BR>3. Fill in for Doctors in Emergencies.<BR><BR><B>Warden</B><BR>The Warden is in charge of processing the Brig, managing the Armory, and filling in for the Head of Security.<BR>1. Manage the Armory<BR>2. Manage the Brig<BR>3. Process Prisoners<BR><BR><B>Security Officer</B>A Security Officer is in charge of keeping the peace and enforcing the law on the station.<BR>1. Enforce the Law<BR>2 Keep the Peace<BR>3. Put down revolts.<BR><BR><B>Detective</B><BR>The Detective is in charge of investigating crimes, proving criminals guilty, and proving criminals innocent.<BR>1. Investigate Crimes<BR>2. Gather Evidence<BR>3. Prove Criminals Innocent/Guilty<BR><BR><B>Station Engineer</B><BR>The Station Engineer is responsible for keeping the station in working order. They maintain the hull, lights, power systems, etc. Essentially, they are the maintenance & expansion crew.<BR>1. Maintain the Station<BR>2. Expand the Station<BR>3. Keep Power Running<BR><BR><B>Atmospheric Technician</B><BR>Atmospheric Technician's are responsible for the atmospherics. They keep the station hot, cold, and breathable.<BR>1. Keep the air inside the Station.<BR>2. Keep the Station warm.<BR>3. Extinguish fires.<BR><BR><B>Scientist</B><BR>Scientists research advancements in technology. They keep us up-to-date in modern times.<BR>1. Research Technology.<BR>2. Make Bombs.<BR>3. Breed Slimes.<BR><BR><B>Roboticist</B><BR>Roboticists are scientists specializing in cyborgs, mechs, and drones. They maintain cyborgs and build mechs.<BR>1. Maintain & Create Cyborgs<BR>2. Build & Maintain Mechs<BR>3. Mass-Produce Medibots<BR><BR><B>Medical Doctor</B><BR>Medical Doctors are responsible for keeping the crew happy, healthy, and alive. They answer to the Chief Medical Officer.<BR>1. Perform Surgeries<BR>2. Heal Injuries<BR>3. Drug the Unhealthy.<BR><BR><B>Chemist</B><BR>Chemists are responsible for creating drugs for use by the Station.<BR>1. Create Drugs<BR>2. Create Cleaning Fluid<BR><BR><B>Geneticist</B><BR>Geneticists are responsible for manipulating the human/monkey/etc. Genome and cloning the deceased. They are playing God.<BR>1. Research Genetics<BR>2. Clone the Deceased<BR><BR><B>Virologist</B><BR>The Virologist is responsible for creating beneficial viruses and curing harmful ones. They are the pathologists of our crew.<BR>1. Create Beneficial Viruses<BR>2. Cure Harmful Diseases<BR><BR><B>Quartermaster</B><BR>The Quartermaster manages Supply, directly under the Head of Personnel's supervision. They keep the station supplied and manage distribution of materials and minerals.<BR>1. Manage Cargo<BR>2. Direct Miners<BR>3. Distribute Supplies<BR><BR><B>Cargo Technician</B><BR>Cargo Technicians operate Cargo's supply requests, move objects on and off the shuttle, and distribute goods personally.<BR>1. Approve & Deny Supply Requests<BR>2. Load & Unload the Cargo Shuttle<BR>3. Distribute Supplies<BR><BR><B>Shaft Miner</B><BR>Shaft Miners mine and refine resources such as plasma, diamonds, and iron for the station's use in robotics, chemistry, and research.<BR>1. Mine Resources<BR>2. Refine Resources<BR><BR><B>Janitor</B><BR>Janitors are in charge of keeping the station clean and appearing well maintained.<BR>1. Clean the Station<BR>2. Dispose of garbage<BR><BR><B>Bartender</B><BR>The Bartender is in charge of providing the crew with alcoholic & non-alcoholic beverages. When people need to drown their sorrows, they turn to him.<BR>1. Give Drink to the Thirsty<BR>2. Keep Peace in the Bar<BR><BR><B>Cook</B><BR>The Cook is in charge of preparing fine meals to feed the Station's crew.<BR>1. Give Food to the Hungry<BR><BR><B>Botanist</B><BR>The Botanist is in responsible for the growth of plants for the Cook to use in meal preparation and for raw consumption by the populous.<BR>1. Grow Food<BR><BR>"

/obj/item/weapon/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	info = "Alert Levels:<BR>\nBlue- Emergency<BR>\n\t1. Caused by fire<BR>\n\t2. Caused by manual interaction<BR>\n\tAction:<BR>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<BR>\nRed- Ejection/Self Destruct<BR>\n\t1. Caused by module operating computer.<BR>\n\tAction:<BR>\n\t\tAfter the specified time the module will eject completely.<BR>\n<BR>\nEngine Maintenance Instructions:<BR>\n\tShut off ignition systems:<BR>\n\tActivate internal power<BR>\n\tActivate orbital balance matrix<BR>\n\tRemove volatile liquids from area<BR>\n\tWear a fire suit<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nToxin Laboratory Procedure:<BR>\n\tWear a gas mask regardless<BR>\n\tGet an oxygen tank.<BR>\n\tActivate internal atmosphere<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nDisaster Procedure:<BR>\n\tFire:<BR>\n\t\tActivate sector fire alarm.<BR>\n\t\tMove to a safe area.<BR>\n\t\tGet a fire suit<BR>\n\t\tAfter:<BR>\n\t\t\tAssess Damage<BR>\n\t\t\tRepair damages<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tMeteor Shower:<BR>\n\t\tActivate fire alarm<BR>\n\t\tMove to the back of ship<BR>\n\t\tAfter<BR>\n\t\t\tRepair damage<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tAccidental Reentry:<BR>\n\t\tActivate fire alrms in front of ship.<BR>\n\t\tMove volatile matter to a fire proof area!<BR>\n\t\tGet a fire suit.<BR>\n\t\tStay secure until an emergency ship arrives.<BR>\n<BR>\n\t\tIf ship does not arrive-<BR>\n\t\t\tEvacuate to a nearby safe area!"

/obj/item/weapon/paper/centcom
	name = "paper- 'Official Bulletin'"
	info = "<BR>Centcom Security<BR>Port Division<BR>Official Bulletin<BR><BR>Inspector,<BR>There is an emergency shuttle arriving today.<BR><BR>Approval is restricted to Nanotrasen employees only. Deny all other entrants.<BR><BR>Centcom Port Commissioner"

/obj/item/weapon/paper/range
	name = "paper- Firing Range Instructions"
	info = "Directions:<br><i>First you'll want to make sure there is a target stake in the center of the magnetic platform. Next, take an aluminum target from the crates back there and slip it into the stake. Make sure it clicks! Next, there should be a control console mounted on the wall somewhere in the room.<br><br> This control console dictates the behaviors of the magnetic platform, which can move your firing target around to simulate real-world combat situations. From here, you can turn off the magnets or adjust their electromagnetic levels and magnetic fields. The electricity level dictates the strength of the pull - you will usually want this to be the same value as the speed. The magnetic field level dictates how far the magnetic pull reaches.<br><br>Speed and path are the next two settings. Speed is associated with how fast the machine loops through the designated path. Paths dictate where the magnetic field will be centered at what times. There should be a pre-fabricated path input already. You can enable moving to observe how the path affects the way the stake moves. To script your own path, look at the following key:</i><br><br>N: North<br>S: South<br>E: East<br>W: West<br>C: Center<br>R: Random (results may vary)<br>; or &: separators. They are not necessary but can make the path string better visible."

/obj/item/weapon/paper/mining
	name = "paper- Smelting Operations Closed"
	info = "<B>**NOTICE**</B><BR><BR>Smelting operations moved on-station.<BR><BR>Take your unrefined ore to the Redeption Machine in the Delivery Office to redeem points.<BR><BR>--SS13 Command"

/obj/item/weapon/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"

/obj/item/weapon/paper/crumpled/update_icon()
	return


/obj/item/weapon/paper/crumpled/bloody
	icon_state = "scrap_bloodied"
