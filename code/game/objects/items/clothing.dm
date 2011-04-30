/*
CONTAINS:
ORANGE SHOES
MUZZLE
CAKEHAT
SUNGLASSES
SWAT SUIT
CHAMELEON JUMPSUIT
DEATH COMMANDO GAS MASK
THERMAL GLASSES
NINJA SUIT
NINJA GLOVES
NINJA MASK
*/


/*
/obj/item/clothing/fire_burn(obj/fire/raging_fire, datum/air_group/environment)
	if(raging_fire.internal_temperature > src.s_fire)
		spawn( 0 )
			var/t = src.icon_state
			src.icon_state = ""
			src.icon = 'b_items.dmi'
			flick(text("[]", t), src)
			spawn(14)
				del(src)
				return
			return
		return 0
	return 1
*/ //TODO FIX

/obj/item/clothing/gloves/examine()
	set src in usr
	..()
	return

/obj/item/clothing/gloves/latex/attackby(obj/item/weapon/cable_coil/O as obj, loc)
	if (istype(O) && O.amount==1)
		var/obj/item/latexballon/LB = new
		if (usr.get_inactive_hand()==src)
			usr.before_take_item(src)
			usr.put_in_inactive_hand(LB)
		else
			LB.loc = src.loc
		del(O)
		del(src)
	else
		return ..()


/obj/item/clothing/shoes/orange/attack_self(mob/user as mob)
	if (src.chained)
		src.chained = null
		src.slowdown = SHOES_SLOWDOWN
		new /obj/item/weapon/handcuffs( user.loc )
		src.icon_state = "orange"
	return

/obj/item/clothing/shoes/orange/attackby(H as obj, loc)
	..()
	if ((istype(H, /obj/item/weapon/handcuffs) && !( src.chained )))
		//H = null
		del(H)
		src.chained = 1
		src.slowdown = 15
		src.icon_state = "orange1"
	return

/obj/item/clothing/mask/muzzle/attack_paw(mob/user as mob)
	if (src == user.wear_mask)
		return
	else
		..()
	return

/obj/item/clothing/head/cakehat/var/processing = 0

/obj/item/clothing/head/cakehat/process()
	if(!onfire)
		processing_items.Remove(src)
		return

	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/living/carbon/human/M = location
		if(M.l_hand == src || M.r_hand == src || M.head == src)
			location = M.loc

	if (istype(location, /turf))
		location.hotspot_expose(700, 1)


/obj/item/clothing/head/cakehat/attack_self(mob/user as mob)
	if(status > 1)	return
	src.onfire = !( src.onfire )
	if (src.onfire)
		src.force = 3
		src.damtype = "fire"
		src.icon_state = "cake1"

		processing_items.Add(src)

	else
		src.force = null
		src.damtype = "brute"
		src.icon_state = "cake0"
	return


/obj/item/clothing/under/chameleon/New()
	..()

	for(var/U in typesof(/obj/item/clothing/under/color)-(/obj/item/clothing/under/color))

		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V

	for(var/U in typesof(/obj/item/clothing/under/rank)-(/obj/item/clothing/under/rank))

		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V

	return


/obj/item/clothing/under/chameleon/all/New()
	..()

	var/blocked = list(/obj/item/clothing/under/chameleon, /obj/item/clothing/under/chameleon/all)
	//to prevent an infinite loop

	for(var/U in typesof(/obj/item/clothing/under)-blocked)

		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V



/obj/item/clothing/under/chameleon/attackby(obj/item/clothing/under/U as obj, mob/user as mob)
	..()

	if(istype(U, /obj/item/clothing/under/chameleon))
		user << "\red Nothing happens."
		return

	if(istype(U, /obj/item/clothing/under))

		if(src.clothing_choices.Find(U))
			user << "\red Pattern is already recognised by the suit."
			return

		src.clothing_choices += U

		user << "\red Pattern absorbed by the suit."

/obj/item/clothing/under/chameleon/verb/change()
	set name = "Change Color"
	set category = "Object"
	set src in usr

	if(icon_state == "psyche")
		usr << "\red Your suit is malfunctioning"
		return

	var/obj/item/clothing/under/A

	A = input("Select Colour to change it to", "BOOYEA", A) in clothing_choices

	if(!A)
		return

	desc = null
	permeability_coefficient = 0.90

	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	color = A.color

/obj/item/clothing/under/chameleon/emp_act(severity)
	name = "psychedelic"
	desc = "Groovy!"
	icon_state = "psyche"
	color = "psyche"
	spawn(200)
		name = "Black Jumpsuit"
		icon_state = "bl_suit"
		color = "black"
		desc = null
	..()

/*
/obj/item/clothing/suit/swat_suit/death_commando
	name = "Death Commando Suit"
	icon_state = "death_commando_suit"
	item_state = "death_commando_suit"
	flags = FPRINT | TABLEPASS | SUITSPACE*/

/obj/item/clothing/mask/gas/death_commando
	name = "Death Commando Mask"
	icon_state = "death_commando_mask"
	item_state = "death_commando_mask"

/obj/item/clothing/under/rank/New()
	sensor_mode = pick(0,1,2,3)
	..()

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	var/mob/M = usr
	if (istype(M, /mob/dead/)) return
	if (usr.stat) return
	if(src.has_sensor >= 2)
		usr << "The controls are locked."
		return 0
	if(src.has_sensor <= 0)
		usr << "This suit does not have any sensors"
		return 0
	src.sensor_mode += 1
	if(src.sensor_mode > 3)
		src.sensor_mode = 0
	switch(src.sensor_mode)
		if(0)
			usr << "You disable your suit's remote sensing equipment."
		if(1)
			usr << "Your suit will now report whether you are live or dead."
		if(2)
			usr << "Your suit will now report your vital lifesigns."
		if(3)
			usr << "Your suit will now report your vital lifesigns as well as your coordinate position."
	..()

/obj/item/clothing/under/examine()
	set src in view()
	..()
	switch(src.sensor_mode)
		if(0)
			usr << "Its sensors appear to be disabled."
		if(1)
			usr << "Its binary life sensors appear to be enabled."
		if(2)
			usr << "Its vital tracker appears to be enabled."
		if(3)
			usr << "Its vital tracker and tracking beacon appear to be enabled."


/obj/item/clothing/head/helmet/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding mask"
	if(src.up)
		src.up = !src.up
		src.see_face = !src.see_face
		src.flags |= HEADCOVERSEYES
		icon_state = "welding"
		usr << "You flip the mask down to protect your eyes."
	else
		src.up = !src.up
		src.see_face = !src.see_face
		src.flags &= ~HEADCOVERSEYES
		icon_state = "weldingup"
		usr << "You push the mask up out of your face."

/obj/item/clothing/shoes/magboots/verb/toggle()
	set name = "Toggle Magboots"
	set category = "Object"
	if(src.magpulse)
		src.flags &= ~NOSLIP
		src.slowdown = SHOES_SLOWDOWN
		src.magpulse = 0
		icon_state = "magboots0"
		usr << "You disable the mag-pulse traction system."
	else
		src.flags |= NOSLIP
		src.slowdown = 2
		src.magpulse = 1
		icon_state = "magboots1"
		usr << "You enable the mag-pulse traction system."

/obj/item/clothing/shoes/magboots/examine()
	set src in view()
	..()
	var/state = "disabled"
	if(src.flags&NOSLIP)
		state = "enabled"
	usr << "Its mag-pulse traction system appears to be [state]."

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	if(src.icon_state == "ushankadown")
		src.icon_state = "ushankaup"
		src.item_state = "ushankaup"
		user << "You raise the ear flaps on the ushanka."
	else
		src.icon_state = "ushankadown"
		src.item_state = "ushankadown"
		user << "You lower the ear flaps on the ushanka."


/obj/item/clothing/glasses/thermal/emp_act(severity)
	if(istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = src.loc
		M << "\red The Optical Thermal Scanner overloads and blinds you!"
		if(M.glasses == src)
			M.eye_blind = 3
			M.eye_blurry = 5
			M.disabilities |= 1
			spawn(100)
				M.disabilities &= ~1
	..()

//SPESS NINJA STUFF

//SUIT

/obj/item/clothing/suit/space/space_ninja/New()
	..()
	src.verbs += /obj/item/clothing/suit/space/space_ninja/proc/init//suit initialize verb
	spark_system = new /datum/effects/system/spark_spread()//spark initialize
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	var/datum/reagents/R = new/datum/reagents(480)//reagent initialize
	reagents = R
	R.my_atom = src
	reagents.add_reagent("tricordrazine", 80)
	reagents.add_reagent("dexalinp", 80)
	reagents.add_reagent("spaceacillin", 80)
	reagents.add_reagent("anti_toxin", 80)
	reagents.add_reagent("radium", 80)
	reagents.add_reagent("nutriment", 80)

/obj/item/clothing/suit/space/space_ninja/proc/ntick(var/mob/living/carbon/human/U as mob)
	set hidden = 1
	set background = 1

	spawn while(initialize&&charge>=0)//Suit on and has power.
		if(!initialize)	return//When turned off the proc stops.
		var/A = 5//Energy cost each tick.
		if(!kamikaze)
			if(istype(U.get_active_hand(), /obj/item/weapon/blade))//Sword check.
				if(charge<=0)//If no charge left.
					U.drop_item()//Sword is dropped from active hand (and deleted).
				else	A += 20//Otherwise, more energy consumption.
			else if(istype(U.get_inactive_hand(), /obj/item/weapon/blade))
				if(charge<=0)
					U.swap_hand()//swap hand
					U.drop_item()//drop sword
				else	A += 20
			if(active)
				A += 25
		else
			A = 100
		charge-=A
		if(charge<0)
			if(kamikaze)
				U.say("I DIE TO LIVE AGAIN!")
				U.death()
				return
			charge=0
			active=0
		sleep(10)//Checks every second.

/obj/item/clothing/suit/space/space_ninja/proc/init()
	set name = "Initialize Suit"
	set desc = "Initializes the suit for field operation."
	set category = "Object"

	if(usr.mind&&usr.mind.special_role=="Space Ninja"&&usr:wear_suit==src&&!src.initialize)
		var/mob/living/carbon/human/U = usr
		verbs -= /obj/item/clothing/suit/space/space_ninja/proc/init
		U << "\blue Now initializing..."
		sleep(40)
		if(U.mind.assigned_role=="Mime")
			U << "\red <B>FATAL ERROR</B>: 382200-*#00CODE <B>RED</B>\nUNAUTHORIZED USE DETECTED\nCOMMENCING SUB-R0UTIN3 13...\nTERMINATING U-U-USER..."
			U.gib()
			return
		if(!istype(U.head, /obj/item/clothing/head/helmet/space/space_ninja))
			U << "\red <B>ERROR</B>: 100113 UNABLE TO LOCATE HEAD GEAR\nABORTING..."
			return
		if(!istype(U.shoes, /obj/item/clothing/shoes/space_ninja))
			U << "\red <B>ERROR</B>: 122011 UNABLE TO LOCATE FOOT GEAR\nABORTING..."
			return
		if(!istype(U.gloves, /obj/item/clothing/gloves/space_ninja))
			U << "\red <B>ERROR</B>: 110223 UNABLE TO LOCATE HAND GEAR\nABORTING..."
			return
		U << "\blue Securing external locking mechanism...\nNeural-net established."
		U.head:canremove=0
		U.shoes:canremove=0
		U.gloves:canremove=0
		canremove=0
		sleep(40)
		U << "\blue Extending neural-net interface...\nNow monitoring brain wave pattern..."
		sleep(40)
		if(U.stat==2||U.health<=0)
			U << "\red <B>FATAL ERROR</B>: 344--93#&&21 BRAIN WAV3 PATT$RN <B>RED</B>\nA-A-AB0RTING..."
			U.head:canremove=1
			U.shoes:canremove=1
			U.gloves:canremove=1
			canremove=1
			verbs += /obj/item/clothing/suit/space/space_ninja/proc/init
			return
		U << "\blue Linking neural-net interface...\nPattern \green <B>GREEN</B>\blue, continuing operation."
		sleep(40)
		U << "\blue VOID-shift device status: <B>ONLINE</B>.\nCLOAK-tech device status: <B>ONLINE</B>."
		sleep(40)
		U << "\blue Primary system status: <B>ONLINE</B>.\nBackup system status: <B>ONLINE</B>.\nCurrent energy capacity: <B>[src.charge]</B>."
		sleep(40)
		U << "\blue All systems operational. Welcome to <B>SpiderOS</B>, [U.real_name]."
		U.verbs += /mob/proc/ninjashift
		U.verbs += /mob/proc/ninjajaunt
		U.verbs += /mob/proc/ninjasmoke
		U.verbs += /mob/proc/ninjaboost
		U.verbs += /mob/proc/ninjapulse
		U.verbs += /mob/proc/ninjablade
		U.verbs += /mob/proc/ninjastar
		U.mind.special_verbs += /mob/proc/ninjashift
		U.mind.special_verbs += /mob/proc/ninjajaunt
		U.mind.special_verbs += /mob/proc/ninjasmoke
		U.mind.special_verbs += /mob/proc/ninjaboost
		U.mind.special_verbs += /mob/proc/ninjapulse
		U.mind.special_verbs += /mob/proc/ninjablade
		U.mind.special_verbs += /mob/proc/ninjastar
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/spideros
		U.gloves.verbs += /obj/item/clothing/gloves/space_ninja/proc/drain_wire
		U.gloves.verbs += /obj/item/clothing/gloves/space_ninja/proc/toggled
		initialize=1
		affecting=U
		slowdown=0
		U.shoes:slowdown--
		ntick(usr)
	else
		if(usr.mind&&usr.mind.special_role=="Space Ninja")
			usr << "\red You do not understand how this suit functions."
		else if(usr:wear_suit!=src)
			usr << "\red You must be wearing the suit to use this function."
		else if(initialize)
			usr << "\red The suit is already functioning."
		else
			usr << "\red You cannot use this function at this time."
	return

/obj/item/clothing/suit/space/space_ninja/proc/deinit()
	set name = "De-Initialize Suit"
	set desc = "Begins procedure to remove the suit."
	set category = "Object"

	if(!initialize)
		usr << "\red The suit is not initialized."
		return
	if(alert("Are you certain you wish to remove the suit? This will take time and remove all abilities.",,"Yes","No")=="No")
		return

	var/mob/living/carbon/human/U = usr
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/deinit
	U << "\blue Now de-initializing..."
	if(kamikaze)
		U << "\blue Disengaging mode...\n\black<b>CODE NAME</b>: \red <b>KAMIKAZE</b>"
		U.verbs -= /mob/proc/ninjaslayer
		U.verbs -= /mob/proc/ninjawalk
		U.verbs -= /mob/proc/ninjamirage
		U.mind.special_verbs -= /mob/proc/ninjaslayer
		U.mind.special_verbs -= /mob/proc/ninjawalk
		U.mind.special_verbs -= /mob/proc/ninjamirage
		kamikaze = 0
		unlock = 0
		U.incorporeal_move = 0
		U.density = 1
		icon_state = "s-ninja"
	spideros = 0
	sleep(40)
	U.verbs -= /mob/proc/ninjashift
	U.verbs -= /mob/proc/ninjajaunt
	U.verbs -= /mob/proc/ninjasmoke
	U.verbs -= /mob/proc/ninjaboost
	U.verbs -= /mob/proc/ninjapulse
	U.verbs -= /mob/proc/ninjablade
	U.verbs -= /mob/proc/ninjastar
	U.mind.special_verbs -= /mob/proc/ninjashift
	U.mind.special_verbs -= /mob/proc/ninjajaunt
	U.mind.special_verbs -= /mob/proc/ninjasmoke
	U.mind.special_verbs -= /mob/proc/ninjaboost
	U.mind.special_verbs -= /mob/proc/ninjapulse
	U.mind.special_verbs -= /mob/proc/ninjablade
	U.mind.special_verbs -= /mob/proc/ninjastar
	U << "\blue Logging off, [U:real_name]. Shutting down <B>SpiderOS</B>."
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
	sleep(40)
	U << "\blue Primary system status: <B>OFFLINE</B>.\nBackup system status: <B>OFFLINE</B>."
	sleep(40)
	U << "\blue VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>."
	if(active)//Shutdowns stealth.
		active=0
	sleep(40)
	if(U.stat||U.health<=0)
		U << "\red <B>FATAL ERROR</B>: 412--GG##&77 BRAIN WAV3 PATT$RN <B>RED</B>\nI-I-INITIATING S-SELf DeStrCuCCCT%$#@@!!$^#!..."
		spawn(10)
			U << "\red #3#"
		spawn(20)
			U << "\red #2#"
		spawn(30)
			U << "\red #1#: <B>G00DBYE</B>"
			U.gib()
		return
	U << "\blue Disconnecting neural-net interface...\green<B>Success</B>\blue."
	sleep(40)
	U << "\blue Disengaging neural-net interface...\green<B>Success</B>\blue."
	sleep(40)
	if(istype(U.head, /obj/item/clothing/head/helmet/space/space_ninja))
		U.head.canremove=1
	if(istype(U.shoes, /obj/item/clothing/shoes/space_ninja))
		U.shoes:canremove=1
		U.shoes:slowdown++
	if(istype(U.gloves, /obj/item/clothing/gloves/space_ninja))
		U.gloves.icon_state = "s-ninja"
		U.gloves.item_state = "s-ninja"
		U.gloves:canremove=1
		U.gloves:candrain=0
		U.gloves:draining=0
		U.gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/drain_wire
		U.gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled
	U.update_clothing()
	canremove=1
	U << "\blue Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>."
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/init
	initialize=0
	affecting=null
	slowdown=1
	return

/obj/item/clothing/suit/space/space_ninja/proc/spideros()
	set name = "Display SpiderOS"
	set desc = "Utilize built-in computer system."
	set category = "Object"

	var/mob/living/carbon/human/U = usr
	var/dat = "<html><head><title>SpiderOS</title></head><body bgcolor=\"#3D5B43\" text=\"#DB2929\"><style>a, a:link, a:visited, a:active, a:hover { color: #DB2929; }img {border-style:none;}</style>"
	/*Here is where you would create a link for the cartridge used if the item has one.
	As noted below, it's not worth the effort to make the cartridge removable unless it's done from the hub.*/
	if(spideros==0)
		dat += "<a href='byond://?src=\ref[src];choice=Refresh'><img src=sos_7.png> Refresh</a>"
		dat += " | <a href='byond://?src=\ref[src];choice=Close'><img src=sos_8.png> Close</a>"
	else
		dat += "<a href='byond://?src=\ref[src];choice=Refresh'><img src=sos_7.png> Refresh</a>"
		dat += " | <a href='byond://?src=\ref[src];choice=Return'><img src=sos_1.png> Return</a>"
		dat += " | <a href='byond://?src=\ref[src];choice=Close'><img src=sos_8.png> Close</a>"
	dat += "<br>"
	dat += "<h2 ALIGN=CENTER>SpiderOS v.1.337</h2>"
	dat += "Welcome, <b>[U.real_name]</b>.<br>"
	dat += "<br>"
	dat += "<img src=sos_10.png> Current Time: [round(world.time / 36000)+12]:[(world.time / 600 % 60) < 10 ? add_zero(world.time / 600 % 60, 1) : world.time / 600 % 60]<br>"
	dat += "<img src=sos_9.png> Battery Life: [round(charge/100)]%<br>"
	dat += "<img src=sos_11.png> Smoke Bombs: [sbombs]<br>"
	dat += "<br>"

	/*
	HOW TO USE OR ADAPT THIS CODE:
	The menu structure should not need to be altered to add new entries. Simply place them after what is already there.
	As an exception, if there are multiple-tiered windows, for instance, going into medical alerts and then to DNA testing or something,
	those menus should be added below their parents but have a greater value. The second sub-menu of menu 2 would have the number 22.
	Another sub-menu of menu 2 would be 23, then 24, and up to 29. If those menus have their own sub-menus a similar format follows.
	Sub-menu 1 of sub-menu 2(of menu 2) would be 221. Sub-menu 5 of sub-menu 2(of menu 2) would be 225. Menu 0 is a special case (it's the menu hub); you are free to use menus 1-9
	to create your own data paths.
	The Return button, when used, simply removes the final number and navigates to the menu prior. Menu 334, the fourth sub-menu of sub-menu
	3, in menu 3, would navigate to sub menu 3 in menu 3. Or 33.
	It is possible to go to a different menu/sub-menu from anywhere. When creating new menus don't forget to add them to Topic proc or else the game
	will interpret you using the messenger function (the else clause in the switch).
	Other buttons and functions should be named according to what they do.*/
	switch(spideros)
		if(0)
			/*
			For items that use cartridges (PDAs), simply switch() their hub function based on the cartridge inserted.
			For ease of use, allow the removal of the cartidge only on the hub.
			*/
			dat += "<h4><img src=sos_1.png> Available Functions:</h4>"
			dat += "<ul>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Stealth'><img src=sos_4.png> Toggle Stealth: [active == 1 ? "Disable" : "Enable"]</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=1'><img src=sos_3.png> Medical Screen</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=2'><img src=sos_5.png> Atmos Scan</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=3'><img src=sos_12.png> Messenger</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=4'><img src=sos_6.png> Other</a></li>"
			dat += "</ul>"
		if(1)
			dat += "<h4><img src=sos_3.png> Medical Report:</h4>"
			if(U.dna)
				dat += "<b>Fingerprints</b>: <i>[md5(U.dna.uni_identity)]</i><br>"
				dat += "<b>Unique identity</b>: <i>[U.dna.unique_enzymes]</i><br>"
			dat += "<h4>Overall Status: [U.stat > 1 ? "dead" : "[U.health]% healthy"]</h4>"
			dat += "<h4>Nutrition Status: [U.nutrition]</h4>"
			dat += "Oxygen loss: [U.oxyloss]"
			dat += " | Toxin levels: [U.toxloss]<br>"
			dat += "Burn severity: [U.fireloss]"
			dat += " | Brute trauma: [U.bruteloss]<br>"
			dat += "Body Temperature: [U.bodytemperature-T0C]&deg;C ([U.bodytemperature*1.8-459.67]&deg;F)<br>"
			if(U.virus)
				dat += "Warning Virus Detected. Name: [U.virus.name].Type: [U.virus.spread]. Stage: [U.virus.stage]/[U.virus.max_stages]. Possible Cure: [U.virus.cure].<br>"
			dat += "<ul>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Dylovene'><img src=sos_2.png> Inject Dylovene: [reagents.get_reagent_amount("anti_toxin")/20] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Dexalin Plus'><img src=sos_2.png> Inject Dexalin Plus: [reagents.get_reagent_amount("dexalinp")/20] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Tricordazine'><img src=sos_2.png> Inject Tricordazine: [reagents.get_reagent_amount("tricordrazine")/20] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Spacelin'><img src=sos_2.png> Inject Spacelin: [reagents.get_reagent_amount("spaceacillin")/20] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Nutriment'><img src=sos_2.png> Inject Nutriment: [reagents.get_reagent_amount("nutriment")/5] left</a></li>"//Special case since it's so freaking potent.
			dat += "</ul>"
		if(2)
			dat += "<h4><img src=sos_5.png>Atmospheric Scan:</h4>"//Headers don't need breaks. They are automatically placed.
			var/turf/T = get_turf_or_move(U.loc)
			if (isnull(T))
				dat += "Unable to obtain a reading."
			else
				var/datum/gas_mixture/environment = T.return_air()

				var/pressure = environment.return_pressure()
				var/total_moles = environment.total_moles()

				dat += "Air Pressure: [round(pressure,0.1)] kPa"

				if (total_moles)
					var/o2_level = environment.oxygen/total_moles
					var/n2_level = environment.nitrogen/total_moles
					var/co2_level = environment.carbon_dioxide/total_moles
					var/plasma_level = environment.toxins/total_moles
					var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)
					dat += "<ul>"
					dat += "<li>Nitrogen: [round(n2_level*100)]%</li>"
					dat += "<li>Oxygen: [round(o2_level*100)]%</li>"
					dat += "<li>Carbon Dioxide: [round(co2_level*100)]%</li>"
					dat += "<li>Plasma: [round(plasma_level*100)]%</li>"
					dat += "</ul>"
					if(unknown_level > 0.01)
						dat += "OTHER: [round(unknown_level)]%<br>"

					dat += "Temperature: [round(environment.temperature-T0C)]&deg;C"
		if(3)
			if(unlock==7)
				dat += "<a href='byond://?src=\ref[src];choice=32'><img src=sos_1.png> Hidden Menu</a>"
			dat += "<h4><img src=sos_12.png> Anonymous Messenger:</h4>"//Anonymous because the receiver will not know the sender's identity.
			dat += "<h4><img src=sos_6.png> Detected PDAs:</h4>"
			dat += "<ul>"
			var/count = 0
			for (var/obj/item/device/pda/P in world)
				if (!P.owner||P.toff)
					continue
				dat += "<li><a href='byond://?src=\ref[src];choice=\ref[P]'>[P]</a>"
				dat += "</li>"
				count++
			dat += "</ul>"
			if (count == 0)
				dat += "None detected.<br>"
			//dat += "<a href='byond://?src=\ref[src];choice=31'> Send Virus</a>
		if(32)
			dat += "<h4><img src=sos_1.png> Hidden Menu:</h4>"
			dat += "Please input password: "
			dat += "<a href='byond://?src=\ref[src];choice=Unlock Kamikaze'><b>HERE</b></a><br>"
			dat += "<br>"
			dat += "Remember, you will not be able to recharge energy during this function. If energy runs out, the suit will auto self-destruct.<br>"
			dat += "Use with caution. De-initialize the suit when energy is low."
		if(4)
			dat += "<h4><img src=sos_6.png> Ninja Manual:</h4>"
			dat += "<h5>Who they are:</h5>"
			dat += "Space ninjas are a special type of ninja, specifically one of the space-faring type. The vast majority of space ninjas belong to the Spider Clan, a cult-like sect, which has existed for several hundred years. The Spider Clan practice a sort of augmentation of human flesh in order to achieve a more perfect state of being and follow Postmodern Space Bushido. They also kill people for money. Their leaders are chosen from the oldest of the grand-masters, people that have lived a lot longer than any mortal man should.<br>Being a sect of technology-loving fanatics, the Spider Clan have the very best to choose from in terms of hardware--cybernetic implants, exoskeleton rigs, hyper-capacity batteries, and you get the idea. Some believe that much of the Spider Clan equipment is based on reverse-engineered alien technology while others doubt such claims.<br>Whatever the case, their technology is absolutely superb."
			dat += "<h5>How they relate to other SS13 organizations:</h5>"
			dat += "<ul>"
			dat += "<li>*<b>Nanotrasen</b> and the Syndicate are two sides of the same coin and that coin is valuable.</li>"
			dat += "<li>*<b>The Space Wizard Federation</b> is a problem, mainly because they are an extremely dangerous group of unpredictable individuals--not to mention the wizards hate technology and are in direct opposition of the Spider Clan. Best avoided or left well-enough alone.</li>"
			dat += "<li>*<b>Changeling Hivemind</b>: extremely dangerous and to be killed on sight.</li>"
			dat += "<li>*<b>Xeno Hivemind</b>: their skulls make interesting kitchen decorations and are challenging to best, especially in larger nests.</li>"
			dat += "</ul>"
			dat += "<h5>The reason they (you) are here</h5>:"
			dat += "Space ninjas are renowned throughout the known controlled space as fearless spies, infiltrators, and assassins. They are sent on missions of varying nature by Nanotrasen, the Syndicate, and other shady organizations and people. To hire a space ninja means serious business."
			dat += "<h5>Their playstyle:</h5>"
			dat += "A mix of traitor, changeling, and wizard. Ninjas rely on energy, or electricity to be precise, to keep their suits running (when out of energy, a suit hibernates). Suits gain energy from objects or creatures that contain electrical charge. APCs, cell batteries, SMES batteries, cyborgs, mechs, and exposed wires are currently supported. Through energy ninjas gain access to special powers--while all powers are tied to the ninja suit, the most useful of them are verb activated--to help them in their mission.<br>It is a constant struggle for a ninja to remain hidden long enough to recharge the suit and accomplish their objective; despite their arsenal of abilities, ninjas can die like any other. Unlike wizards, ninjas do not possess good crowd control and are typically forced to play more subdued in order to achieve their goals. Some of their abilities are specifically designed to confuse and disorient others.<br>With that said, it should be perfectly possible to completely flip the fuck out and rampage as a ninja."
			dat += "<h5>Their powers:</h5>"
			dat += "There are two primary types: powers that are activated through the suit and powers that are activated through the verb panel. Passive powers are always on. Active powers must be turned on and remain active only when there is energy to do so. All verb powers are active and their cost is listed next to them."
			dat += "<b>Powers of the suit</b>: cannot be tracked by AI (passive), faster speed (passive), stealth (active), vision switch (passive if toggled), voice masking (passive), SpiderOS (passive if toggled), energy drain (passive if toggled)."
			dat += "<ul>"
			dat += "<li><i>Voice masking</i> generates a random name the ninja can use over the radio and in-person. Although, the former use is recommended.</li>"
			dat += "<li><i>Toggling vision</i> cycles to one of the following: thermal, meson, or darkness vision.</li>"
			dat += "<li><i>Stealth</i>, when activated, drains more battery charge and works similarly to a syndicate cloak.</li>"
			dat += "<li><i>SpiderOS</i> is a specialized, PDA-like screen that allows for a small variety of functions, such as injecting healing chemicals directly from the suit. You are using it now, if that was not already obvious.</li>"
			dat += "</ul>"
			dat += "<b>Verbpowers</b>:"
			dat += "<ul>"
			dat += "<li>*<b>Phase Shift</b> (<i>2000E</i>) and <b>Phase Jaunt</b> (<i>1000E</i>) are unique powers in that they can both be used for defense and offense. Jaunt launches the ninja forward facing up to 10 squares, somewhat randomly selecting the final destination. Shift can only be used on turf in view but is precise (cannot be used on walls). Any living mob in the area teleported to is instantly gibbed.</li>"
			dat += "<li>*<b>Energy Blade</b> (<i>500E</i>) is a highly effective weapon. It is summoned directly to the ninja's hand and can also function as an EMAG for certain objects (doors/lockers/etc). You may also use it to cut through walls and disabled doors. Experiment! The blade will crit humans in two hits. This item cannot be placed in containers and when dropped or thrown disappears. Having an energy sword drains more power from the battery each tick.</li>"
			dat += "<li>*<b>EM Pulse</b> (<i>2500E</i>) is a highly useful ability that will create an electromagnetic shockwave around the ninja, disabling technology whenever possible. If used properly it can render a security force effectively useless. Of course, getting beat up with a toolbox is not accounted for.</li>"
			dat += "<li>*<b>Energy Star</b> (<i>300E</i>) is a ninja star made of green energy AND coated in poison. It works by picking a random living target within range and can be spammed to great effect in incapacitating foes. Just remember that the poison used is also used by the Xeno Hivemind (and will have no effect on them).</li>"
			dat += "<li>*<b>Adrenaline Boost</b> (<i>1 E. Boost/3</i>) recovers the user from stun, weakness, and paralysis. Also injects 20 units of radium into the bloodstream.</li>"
			dat += "<li>*<b>Smoke Bomb</b> (<i>1 Sm.Bomb/10</i>) is a weak but potentially useful ability. It creates harmful smoke and can be used in tandem with other powers to confuse enemies.</li>"
			dat += "<li>*<b>???</b>: unleash the <b>True Ultimate Power!</b></li>"
			dat += "</ul>"
			dat += "That is all you will need to know. The rest will come with practice and talent. Good luck!"
			dat += "<h4>Master /N</h4>"
/*
			//Sub-menu testing stuff.
			dat += "<li><a href='byond://?src=\ref[src];choice=49'> To sub-menu 49</a></li>"
		if(31)
			dat += "<h4><img src=sos_12.png> Send Virus:</h4>"
			dat += "<h4><img src=sos_6.png> Detected PDAs:</h4>"
			dat += "<ul>"
			var/count = 0
			for (var/obj/item/device/pda/P in world)
				if (!P.owner||P.toff)
					continue
				dat += "<li><a href='byond://?src=\ref[src];choice=\ref[P]'><i>[P]</i></a>"
				dat += "</li>"
				count++
			dat += "</ul>"
			if (count == 0)
				dat += "None detected.<br>"
		if(49)
			dat += "<h4><img src=sos_6.png> Other Functions 49:</h4>"
			dat += "<a href='byond://?src=\ref[src];choice=491'> To sub-menu 491</a>"
		if(491)
			dat += "<h4><img src=sos_6.png> Other Functions 491:</h4>"
			dat += "<a href='byond://?src=\ref[src];choice=0'> To main menu</a>"
*/
	dat += "</body></html>"

	U << browse(dat,"window=spideros;size=400x444;border=1;can_resize=0;can_close=0;can_minimize=0")
	//Setting the can>resize etc to 0 remove them from the drag bar but still allows the window to be draggable.

/obj/item/clothing/suit/space/space_ninja/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/U = usr
	if(U.stat||U.wear_suit!=src||!initialize)//Check to make sure the guy is wearing the suit after clicking and it's on.
		U << "\red Your suit must be worn and active to use this function."
		U << browse(null, "window=spideros")//Closes the window.
		return

	switch(unlock)//To unlock Kamikaze mode. Irrelevant elsewhere.
		if(0)
			if(href_list["choice"]=="Stealth"&&spideros==0)	unlock++
		if(1)
			if(href_list["choice"]=="2"&&spideros==0)	unlock++
			else if(href_list["choice"]=="Return")
			else	unlock=0
		if(2)
			if(href_list["choice"]=="3"&&spideros==0)	unlock++
			else if(href_list["choice"]=="Return")
			else	unlock=0
		if(3)
			if(href_list["choice"]=="Stealth"&&spideros==0)	unlock++
			else if(href_list["choice"]=="Return")
			else	unlock=0
		if(4)
			if(href_list["choice"]=="1"&&spideros==0)	unlock++
			else if(href_list["choice"]=="Return")
			else	unlock=0
		if(5)
			if(href_list["choice"]=="1"&&spideros==0)	unlock++
			else if(href_list["choice"]=="Return")
			else	unlock=0
		if(6)
			if(href_list["choice"]=="4"&&spideros==0)	unlock++
			else if(href_list["choice"]=="Return")
			else	unlock=0
		if(7)//once unlocked, stays unlocked until deactivated.
		else
			unlock = 0

	switch(href_list["choice"])
		if("Close")
			U << browse(null, "window=spideros")
			return
		if("Refresh")//Refresh, goes to the end of the proc.
		if("Return")//Return
			if(spideros<=9)
				spideros=0
			else
				spideros = round(spideros/10)//Best way to do this, flooring to nearest integer. As an example, another way of doing it is attached below:
	//			var/temp = num2text(spideros)
	//			var/return_to = copytext(temp, 1, (length(temp)))//length has to be to the length of the thing because by default it's length+1
	//			spideros = text2num(return_to)//Maximum length here is 6. Use (return_to, X) to specify larger strings if needed.
		if("Stealth")
			if(active)
				spawn(0)
					anim(usr.loc,'mob.dmi',usr,"uncloak")
				active=0
				U << "\blue You are now visible."
				for(var/mob/O in oviewers(usr, null))
					O << "[usr.name] appears from thin air!"
			else
				spawn(0)
					anim(usr.loc,'mob.dmi',usr,"cloak")
				active=1
				U << "\blue You are now invisible to normal detection."
				for(var/mob/O in oviewers(usr, null))
					O << "[usr.name] vanishes into thin air!"
		if("0")//Menus are numbers, see note above. 0 is the hub.
			spideros=0
		if("1")//Begin normal menus 1-9.
			spideros=1
		if("2")
			spideros=2
		if("3")
			spideros=3
		if("32")
			spideros=32
		if("4")
			spideros=4
		/*Sub-menu testing stuff.
		if("31")
			spideros=31
		if("49")
			spideros=49
		if("491")
			spideros=491 */
		if("Unlock Kamikaze")
			if(input(U)=="Divine Wind")
				if( !(U.stat||U.wear_suit!=src||!initialize) )
					U << "\blue Engaging mode...\n\black<b>CODE NAME</b>: \red <b>KAMIKAZE</b>"
					sleep(40)
					U << "\blue Re-routing power nodes... \nUnlocking limiter..."
					sleep(40)
					U << "\blue Power nodes re-routed. \nLimiter unlocked."
					sleep(10)
					U << "\red Do or Die, <b>LET'S ROCK!!</b>"
					if(verbs.Find(/obj/item/clothing/suit/space/space_ninja/proc/deinit))//To prevent engaging kamikaze and de-initializing at the same time.
						kamikaze = 1
						active = 0
						icon_state = "s-ninjak"
						if(istype(U.gloves, /obj/item/clothing/gloves/space_ninja))
							U.gloves.icon_state = "s-ninjak"
							U.gloves.item_state = "s-ninjak"
							U.gloves:candrain = 0
							U.gloves:draining = 0
							U.gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/drain_wire
							U.gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled
						U.update_clothing()
						U.verbs -= /mob/proc/ninjashift
						U.verbs -= /mob/proc/ninjajaunt
						U.verbs -= /mob/proc/ninjapulse
						U.verbs -= /mob/proc/ninjastar
						U.mind.special_verbs -= /mob/proc/ninjashift
						U.mind.special_verbs -= /mob/proc/ninjajaunt
						U.mind.special_verbs -= /mob/proc/ninjapulse
						U.mind.special_verbs -= /mob/proc/ninjastar

						U.verbs += /mob/proc/ninjaslayer
						U.verbs += /mob/proc/ninjawalk
						U.verbs += /mob/proc/ninjamirage
						U.mind.special_verbs += /mob/proc/ninjaslayer
						U.mind.special_verbs += /mob/proc/ninjawalk
						U.mind.special_verbs += /mob/proc/ninjamirage
						verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
						U.ninjablade()
					else
						U << "Nevermind, you cheater."
				U << browse(null, "window=spideros")
				return
			else
				U << "\red ERROR: WRONG PASSWORD!"
				unlock = 0
				spideros = 0
		if("Dylovene")//These names really don't matter for specific functions but it's easier to use descriptive names.
			if(!reagents.get_reagent_amount("anti_toxin"))
				U << "\red Error: the suit cannot perform this function. Out of dylovene."
			else
				reagents.reaction(U, 2)
				reagents.trans_id_to(U, "anti_toxin", amount_per_transfer_from_this)
				U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
		if("Dexalin Plus")
			if(!reagents.get_reagent_amount("dexalinp"))
				U << "\red Error: the suit cannot perform this function. Out of dexalinp."
			else
				reagents.reaction(U, 2)
				reagents.trans_id_to(U, "dexalinp", amount_per_transfer_from_this)
				U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
		if("Tricordazine")
			if(!reagents.get_reagent_amount("tricordrazine"))
				U << "\red Error: the suit cannot perform this function. Out of tricordrazine."
			else
				reagents.reaction(U, 2)
				reagents.trans_id_to(U, "tricordrazine", amount_per_transfer_from_this)
				U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
		if("Spacelin")
			if(!reagents.get_reagent_amount("spaceacillin"))
				U << "\red Error: the suit cannot perform this function. Out of spaceacillin."
			else
				reagents.reaction(U, 2)
				reagents.trans_id_to(U, "spaceacillin", amount_per_transfer_from_this)
				U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
		if("Nutriment")
			if(!reagents.get_reagent_amount("nutriment"))
				U << "\red Error: the suit cannot perform this function. Out of nutriment."
			else
				reagents.reaction(U, 2)
				reagents.trans_id_to(U, "nutriment", 5)
				U << "You feel a tiny prick and a sudden rush of substance in to your veins."

		else
		/*Leaving this for the messenger because it's an awesome solution. For switch to work, the variable has to be static.
		Not the case when P is a specific object. The downside, of course, is that there is only one slot.
		The following switch moves data to the appropriate function based on what screen it was clicked on. For now only uses screen 3.
		As an example, I added screen 31 to send the silence virus to people in the commented bits.
		You can do the same with functions that require dynamic tracking.
		*/
			switch(spideros)
				if(3)
					var/obj/item/device/pda/P = locate(href_list["choice"])
					var/t = input(U, "Please enter untraceable message.") as text
					t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
					if(!t||U.stat||U.wear_suit!=src||!initialize)//Wow, another one of these. Man...
						return
					if(isnull(P)||P.toff)//So it doesn't freak out if the object no-longer exists.
						U << "\red Error: unable to deliver message."
						spideros()
						return
					P.tnote += "<i><b>&larr; From unknown source:</b></i><br>[t]<br>"
					if (!P.silent)
						playsound(P.loc, 'twobeep.ogg', 50, 1)
						for (var/mob/O in hearers(3, P.loc))
							O.show_message(text("\icon[P] *[P.ttone]*"))
					P.overlays = null
					P.overlays += image('pda.dmi', "pda-r")
			/*	if(31)
					var/obj/item/device/pda/P = locate(href_list["choice"])
					if (!P.toff)
						U.show_message("\blue Virus sent!", 1)
						P.silent = 1
						P.ttone = "silence" */

	spideros()//Refreshes the screen by calling it again (which replaces current screen with new screen).
	return

/obj/item/clothing/suit/space/space_ninja/examine()
	set src in view()
	..()
	if(initialize)
		usr << "All systems operational. Current energy capacity: <B>[src.charge]</B>."
		if(!kamikaze)
			if(active)
				usr << "The CLOAK-tech device is <B>active</B>."
			else
				usr << "The CLOAK-tech device is <B>inactive</B>."
		else
			usr << "\red KAMIKAZE MODE ENGAGED!"
		usr << "There are <B>[sbombs]</B> smoke bombs remaining."
		usr << "There are <B>[aboost]</B> adrenaline boosters remaining."

//GLOVES
/obj/item/clothing/gloves/space_ninja/proc/toggled()
	set name = "Toggle Drain"
	set desc = "Toggles the energy drain mechanism on or off."
	set category = "Object"
	if(!candrain)
		candrain=1
		usr << "You enable the energy drain mechanism."
	else
		candrain=0
		usr << "You disable the energy drain mechanism."

/obj/item/clothing/gloves/space_ninja/proc/drain_wire()
	set name = "Drain From Wire"
	set desc = "Drain energy directly from an exposed wire."
	set category = "Object"

	var/obj/cable/attached
	var/mob/living/carbon/human/U = usr
	if(candrain&&!draining)
		var/turf/T = U.loc
		if(isturf(T) && T.is_plating())
			attached = locate() in T
			if(!attached)
				U << "\red Warning: no exposed cable available."
			else
				U << "\blue Now charging battery, stand still..."
				draining = 1
				if(do_after(U,100)&&!isnull(attached))
					processp(attached)
				else
					draining = 0
					U << "\red Procedure interrupted. Protocol terminated."
	return

/obj/item/clothing/gloves/space_ninja/proc/processp(var/obj/cable/attached)
//A lot of this comes from the powersink code.
	var/mob/living/carbon/human/U = usr
	var/obj/item/clothing/suit/space/space_ninja/S = U.wear_suit
	var/obj/item/clothing/gloves/space_ninja/G = U.gloves
	var/drain = 0
	var/maxcapacity = 0
	var/totaldrain = 0
	var/datum/powernet/PN = attached.get_powernet()
	while(candrain&&!maxcapacity&&!isnull(attached))
		drain = (round((rand(G.mindrain,G.maxdrain))/2))
		var/drained = 0
		if(PN&&do_after(U,10))
			drained = min (drain, PN.avail)
			PN.newload += drained
			if(drained < drain)//if no power on net, drain apcs
				for(var/obj/machinery/power/terminal/T in PN.nodes)
					if(istype(T.master, /obj/machinery/power/apc))
						var/obj/machinery/power/apc/A = T.master
						if(A.operating && A.cell && A.cell.charge>0)
							A.cell.charge = max(0, A.cell.charge - 5)
							drained += 5
		else	break
		S.charge += drained
		if(S.charge>S.maxcharge)
			totaldrain += (drained-(S.charge-S.maxcharge))
			S.charge = S.maxcharge
			maxcapacity = 1
		else
			totaldrain += drained
		S.spark_system.start()
		if(drained==0)	break
	draining = 0
	U << "\blue Gained <B>[totaldrain]</B> energy from the power network."
	return

/obj/item/clothing/gloves/space_ninja/examine()
	set src in view()
	..()
	if(!canremove)
		if(candrain)
			usr << "The energy drain mechanism is: <B>active</B>."
		else
			usr << "The energy drain mechanism is: <B>inactive</B>."

//MASK
/obj/item/clothing/mask/gas/voice/space_ninja/New()
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm

/obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev()
	set name = "Toggle Voice"
	set desc = "Toggles the voice synthesizer on or off."
	set category = "Object"
	var/vchange = (alert("Would you like to synthesize a new name or turn off the voice synthesizer?",,"New Name","Turn Off"))
	if(vchange=="New Name")
		var/chance = rand(1,100)
		switch(chance)
			if(1 to 50)//High chance of a regular name.
				var/g = pick(0,1)
				var/first = null
				var/last = pick(last_names)
				if(g==0)
					first = pick(first_names_female)
				else
					first = pick(first_names_male)
				voice = "[first] [last]"
			if(51 to 80)//Smaller chance of a clown name.
				var/first = pick(clown_names)
				voice = "[first]"
			if(81 to 90)//Small chance of a wizard name.
				var/first = pick(wizard_first)
				var/last = pick(wizard_second)
				voice = "[first] [last]"
			if(91 to 100)//Small chance of an existing crew name.
				var/list/names = new()
				for(var/mob/living/carbon/human/M in world)
					if(M==usr||!M.client||!M.real_name)	continue
					names.Add(M)
				if(!names.len)
					voice = "Cuban Pete"//Smallest chance to be the man.
				else
					var/mob/picked = pick(names)
					voice = picked.real_name
		usr << "You are now mimicking <B>[voice]</B>."
		return
	else
		if(voice!="Unknown")
			usr << "You deactivate the voice synthesizer."
			voice = "Unknown"
		else
			usr << "The voice synthesizer is already deactivated."
	return

/obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm()
	set name = "Switch Mode"
	set desc = "Switches between Night Vision, Meson, or Thermal vision modes."
	set category = "Object"
	//Have to reset these manually since life.dm is retarded like that. Go figure.
	switch(mode)
		if(1)
			mode=2
			usr.see_in_dark = 2
			usr << "Switching mode to <B>Thermal Scanner</B>."
		if(2)
			mode=3
			usr.see_invisible = 0
			usr.sight &= ~SEE_MOBS
			usr << "Switching mode to <B>Meson Scanner</B>."
		if(3)
			mode=1
			usr.sight &= ~SEE_TURFS
			usr << "Switching mode to <B>Night Vision</B>."

/obj/item/clothing/mask/gas/voice/space_ninja/examine()
	set src in view()
	..()
	var/mode = "Night Vision"
	var/voice = "inactive"
	switch(mode)
		if(1)
			mode = "Night Vision"
		if(2)
			mode = "Thermal Scanner"
		if(3)
			mode = "Meson Scanner"
	if(vchange==0)
		voice = "inactive"
	else
		voice = "active"
	usr << "<B>[mode]</B> is active."
	usr << "Voice mimicking algorithm is set to <B>[voice]</B>."