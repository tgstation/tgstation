//////////////////////////////////////
// SUIT STORAGE UNIT /////////////////
//////////////////////////////////////


/obj/machinery/suit_storage_unit
	name = "suit storage unit"
	desc = "An industrial U-Stor-It Storage unit designed to accomodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a UV-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\"."
	icon = 'icons/obj/suitstorage.dmi'
	icon_state = "close"
	anchored = 1
	density = 1
	//Vars to hold internal items
	var/mob/living/OCCUPANT = null
	var/obj/item/clothing/suit/space/SUIT = null
	var/obj/item/clothing/head/helmet/space/HELMET = null
	var/obj/item/clothing/mask/MASK = null 
	var/obj/item/STORAGE = null
	
	//Base types on creation
	var/SUIT_TYPE = null
	var/HELMET_TYPE = null
	var/MASK_TYPE = null
	var/STORAGE_TYPE = null
	
	//Machine related vars
	var/isopen = 0
	var/islocked = 0
	var/isUV = 0
	var/ispowered = 1
	var/isbroken = 0
	var/issuperUV = 0
	var/panelopen = 0
	var/safetieson = 1
	var/cycletime_left = 0



/obj/machinery/suit_storage_unit/standard_unit
	SUIT_TYPE = /obj/item/clothing/suit/space/eva
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/eva
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/captain
	SUIT_TYPE = /obj/item/clothing/suit/space/captain
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/captain
	MASK_TYPE = /obj/item/clothing/mask/gas
	STORAGE_TYPE = /obj/item/weapon/tank/jetpack/oxygen

/obj/machinery/suit_storage_unit/engine
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/engine
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/ce
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/engine/elite
	MASK_TYPE = /obj/item/clothing/mask/breath
	STORAGE_TYPE= /obj/item/clothing/shoes/magboots/advance

/obj/machinery/suit_storage_unit/security
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/security
	MASK_TYPE = /obj/item/clothing/mask/gas/sechailer

/obj/machinery/suit_storage_unit/hos
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/security/hos
	MASK_TYPE = /obj/item/clothing/mask/gas/sechailer

/obj/machinery/suit_storage_unit/atmos
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/engine/atmos
	MASK_TYPE = /obj/item/clothing/mask/gas
	STORAGE_TYPE = /obj/item/weapon/watertank/atmos

/obj/machinery/suit_storage_unit/mining
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/mining
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/cmo
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/medical
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/syndicate
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/syndi
	MASK_TYPE = /obj/item/clothing/mask/gas/syndicate
	STORAGE_TYPE = /obj/item/weapon/tank/jetpack/oxygen/harness

/obj/machinery/suit_storage_unit/ertCom
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/ert
	MASK_TYPE = /obj/item/clothing/mask/breath
	STORAGE_TYPE = /obj/item/weapon/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ertSec
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/ert/sec
	MASK_TYPE = /obj/item/clothing/mask/breath
	STORAGE_TYPE = /obj/item/weapon/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ertEngi
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/ert/engi
	MASK_TYPE = /obj/item/clothing/mask/breath
	STORAGE_TYPE = /obj/item/weapon/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ertMed
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/ert/med
	MASK_TYPE = /obj/item/clothing/mask/breath
	STORAGE_TYPE = /obj/item/weapon/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/New()
	src.update_icon()
	if(SUIT_TYPE)
		SUIT = new SUIT_TYPE(src)
	if(HELMET_TYPE)
		HELMET = new HELMET_TYPE(src)
	if(MASK_TYPE)
		MASK = new MASK_TYPE(src)
	if(STORAGE_TYPE)
		STORAGE = new STORAGE_TYPE(src)

/obj/machinery/suit_storage_unit/update_icon() //overlays yaaaay - Jordie
	src.overlays = 0

	if(!isopen)
		overlays += "close"
	if(OCCUPANT)
		overlays += "human"
	if(OCCUPANT && isUV)
		overlays += "uvhuman"
	if(isUV)
		overlays += "uv"
	if(issuperUV && isUV)
		overlays += "super"
	if(isopen)
		overlays += "open"
		if(SUIT)
			overlays += "suit"
		if(HELMET)
			overlays += "helm"
		if(STORAGE)
			overlays += "storage"
		if(isbroken)
			overlays += "broken"
	return

/obj/machinery/suit_storage_unit/power_change()
	..()
	ispowered = !(stat & NOPOWER)
	if((stat & NOPOWER) && isopen)
		dump_everything()
	update_icon()

/obj/machinery/suit_storage_unit/ex_act(severity, target)
	switch(severity)
		if(1.0)
			if(prob(50))
				src.dump_everything() //So suits dont survive all the time
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				src.dump_everything()
				qdel(src)
			return
		else
			return
	return


/obj/machinery/suit_storage_unit/attack_hand(mob/user)
	var/dat
	if(..())
		return
	if(stat & NOPOWER)
		return
	if(src.panelopen) //The maintenance panel is open. Time for some shady stuff
		dat+= "<HEAD><TITLE>Suit storage unit: Maintenance panel</TITLE></HEAD>"
		dat+= "<B>Maintenance panel controls</B><HR>"
		dat+= "The panel is ridden with controls, button and meters, labeled in strange signs and symbols that <BR>you cannot understand. Probably the manufactoring world's language.<BR> Among other things, a few controls catch your eye.<BR><BR>"
		dat+= text("A small dial with a \"ë\" symbol embroidded on it. It's pointing towards a gauge that reads [].<BR> <A href='?src=\ref[];toggleUV=1'>Turn towards []</A><BR>",(src.issuperUV ? "15nm" : "185nm"),src,(src.issuperUV ? "185nm" : "15nm") )
		dat+= text("A thick old-style button, with 2 grimy LED lights next to it. The [] LED is on.<BR><A href='?src=\ref[];togglesafeties=1'>Press button</a>",(src.safetieson? "<font color='green'><B>GREEN</B></font>" : "<font color='red'><B>RED</B></font>"),src)
		dat+= text("<HR><BR><A href='?src=\ref[];mach_close=suit_storage_unit'>Close panel</A>", user)
	else if(src.isUV) //The thing is running its cauterisation cycle. You have to wait.
		dat += "<HEAD><TITLE>Suit storage unit</TITLE></HEAD>"
		dat+= "<font color ='red'><B>Unit is cauterising contents with selected UV ray intensity. Please wait.</font></B><BR>"


	else
		if(!src.isbroken)
			dat+= "<HEAD><TITLE>Suit storage unit</TITLE></HEAD>"
			dat+= "<font size = 4><B>U-Stor-It Suit Storage Unit, model DS1900</B></FONT><BR>"
			dat+= "<B>Welcome to the Unit control panel.</B><HR>"
			dat+= text("Helmet storage compartment: <B>[]</B><BR>",(src.HELMET ? HELMET.name : "<font color ='grey'>No helmet detected.</font>") )
			if(HELMET && src.isopen)
				dat+=text("<A href='?src=\ref[];dispense_helmet=1'>Dispense helmet</A><BR>",src)
			dat+= text("Suit storage compartment: <B>[]</B><BR>",(src.SUIT ? SUIT.name : "<font color ='grey'>No exosuit detected.</font>") )
			if(SUIT && src.isopen)
				dat+=text("<A href='?src=\ref[];dispense_suit=1'>Dispense suit</A><BR>",src)
			dat+= text("Breathmask storage compartment: <B>[]</B><BR>",(src.MASK ? MASK.name : "<font color ='grey'>No breathmask detected.</font>") )
			if(MASK && src.isopen)
				dat+=text("<A href='?src=\ref[];dispense_mask=1'>Dispense mask</A><BR>",src)
			dat+= text("Auxiliary storage compartment: <B>[]</B><BR>",(src.STORAGE ? STORAGE.name : "<font color ='grey'>Contents empty.</font>") )
			if(STORAGE && src.isopen)
				dat+=text("<A href='?src=\ref[];eject_storage=1'>Eject contents</A><BR>",src)
			if(src.OCCUPANT)
				dat+= "<HR><B><font color ='red'>WARNING: Biological entity detected inside the Unit's storage. Please remove.</B></font><BR>"
				dat+= "<A href='?src=\ref[src];eject_guy=1'>Eject extra load</A>"
			dat+= text("<HR>Unit is: [] - <A href='?src=\ref[];toggle_open=1'>[] Unit</A> ",(src.isopen ? "Open" : "Closed"),src,(src.isopen ? "Close" : "Open"))
			if(src.isopen)
				dat+="<HR>"
			else
				dat+= text(" - <A href='?src=\ref[];toggle_lock=1'><font color ='orange'>*[] Unit*</A></font><HR>",src,(src.islocked ? "Unlock" : "Lock") )
			dat+= text("Unit status: []",(src.islocked? "<font color ='red'><B>**LOCKED**</B></font><BR>" : "<font color ='green'><B>**UNLOCKED**</B></font><BR>") )
			dat+= text("<A href='?src=\ref[];start_UV=1'>Start Disinfection cycle</A><BR>",src)
			dat += text("<BR><BR><A href='?src=\ref[];mach_close=suit_storage_unit'>Close control panel</A>", user)

		else //Ohhhh shit it's dirty or broken! Let's inform the guy.
			dat+= "<HEAD><TITLE>Suit storage unit</TITLE></HEAD>"
			dat+= "<B>Unit chamber is too contaminated to continue usage. Please call for a qualified individual to perform maintenance.</B><BR><BR>"
			dat+= text("<HR><A href='?src=\ref[];mach_close=suit_storage_unit'>Close control panel</A>", user)


	var/datum/browser/popup = new(user, "suit_storage_unit", "Suit Storage Unit", 440, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return


/obj/machinery/suit_storage_unit/Topic(href, href_list) //I fucking HATE this proc
	if(..())
		return
	if(usr == src.OCCUPANT)
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.set_machine(src)
		if (href_list["toggleUV"])
			src.toggleUV(usr)
		if (href_list["togglesafeties"])
			src.togglesafeties(usr)
		if (href_list["dispense_helmet"])
			src.dispense_helmet(usr)
		if (href_list["dispense_suit"])
			src.dispense_suit(usr)
		if (href_list["dispense_mask"])
			src.dispense_mask(usr)
		if (href_list["eject_storage"])
			src.eject_storage(usr)
		if (href_list["toggle_open"])
			src.toggle_open(usr)
		if (href_list["toggle_lock"])
			src.toggle_lock(usr)
		if (href_list["start_UV"])
			src.start_UV(usr)
		if (href_list["eject_guy"])
			src.eject_occupant(usr)
		src.updateUsrDialog()
		src.update_icon()
	src.add_fingerprint(usr)
	return


/obj/machinery/suit_storage_unit/proc/toggleUV(mob/user)
	if(!src.panelopen)
		return
		
	else
		if(src.issuperUV)
			user << "<span class='notice'>You slide the dial back towards \"185nm\".</span>"
			src.issuperUV = 0
		else
			user << "<span class='notice'>You crank the dial all the way up to \"15nm\".</span>"
			src.issuperUV = 1
		return


/obj/machinery/suit_storage_unit/proc/togglesafeties(mob/user)
	if(!src.panelopen) //Needed check due to bugs
		return
	else
		user << "<span class='notice'>You push the button. The coloured LED next to it changes.</span>"
		src.safetieson = !src.safetieson


/obj/machinery/suit_storage_unit/proc/dispense_helmet()
	eject(HELMET)
	HELMET = null

/obj/machinery/suit_storage_unit/proc/dispense_suit()
	eject(SUIT)
	SUIT = null

/obj/machinery/suit_storage_unit/proc/dispense_mask()
	eject(MASK)
	MASK = null

/obj/machinery/suit_storage_unit/proc/eject_storage()
	eject(STORAGE)
	STORAGE = null

/obj/machinery/suit_storage_unit/proc/eject(atom/movable/ITEM)
	//Check item still exists - if not, then usually someone has already ejected the item
	if(ITEM)
		ITEM.loc = src.loc

/obj/machinery/suit_storage_unit/proc/dump_everything()
	for(var/obj/item/ITEM in src)
		eject(ITEM)
	src.SUIT = null
	src.HELMET = null
	src.MASK = null
	src.STORAGE = null
	if(src.OCCUPANT)
		src.eject_occupant(OCCUPANT)
	return


/obj/machinery/suit_storage_unit/proc/toggle_open(mob/user)
	if(src.islocked || src.isUV)
		user << "<span class='warning'>You're unable to open unit!</span>"
		return 0
	if(src.OCCUPANT)
		src.eject_occupant(user)
		return 1  // eject_occupant opens the door, so we need to return
	src.isopen = !src.isopen
	return 1


/obj/machinery/suit_storage_unit/proc/toggle_lock(mob/user)
	if(src.OCCUPANT && src.safetieson)
		user << "<span class='warning'>The Unit's safety protocols disallow locking when a biological form is detected inside its compartments.</span>"
		return
	if(src.isopen)
		return
	src.islocked = !src.islocked
	return


/obj/machinery/suit_storage_unit/proc/start_UV(mob/user)
	if(src.isUV || src.isopen) //I'm bored of all these sanity checks
		return
	if(src.OCCUPANT && src.safetieson)
		user << "<font color='red'><B>WARNING:</B> Biological entity detected in the confines of the Unit's storage. Cannot initiate cycle.</font>"
		return
	if(!src.HELMET && !src.MASK && !src.SUIT && !src.STORAGE && !src.OCCUPANT )
		user << "<font color='red'>Unit storage bays empty. Nothing to disinfect -- Aborting.</font>"
		return
	user << "<span class='notice'>You start the Unit's cauterisation cycle.</span>"
	src.cycletime_left = 20
	src.isUV = 1
	if(src.OCCUPANT && !src.islocked)
		src.islocked = 1 //Let's lock it for good measure
	src.update_icon()
	src.updateUsrDialog()

	var/i
	spawn(0)
		for(i=0,i<4,++i)
			sleep(50)
			if(src.OCCUPANT)
				var/burndamage = rand(6,10)
				if(src.issuperUV)
					burndamage = rand(28,35)
				if(iscarbon(OCCUPANT))
					OCCUPANT.take_organ_damage(0,burndamage)
					OCCUPANT.emote("scream")
				else
					OCCUPANT.take_organ_damage(burndamage)
			if(i==3) //End of the cycle
				if(!src.issuperUV)
					for(var/obj/item/ITEM in src)
						ITEM.clean_blood()
					if(istype(STORAGE, /obj/item/weapon/reagent_containers/food))
						qdel(STORAGE)
				else //It was supercycling, destroy everything
					src.HELMET = null
					src.SUIT = null
					src.MASK = null
					qdel(STORAGE)
					visible_message("<font color='red'>With a loud whining noise, the Suit Storage Unit's door grinds open. Puffs of ashen smoke come out of its chamber.</font>", 3)
					src.isbroken = 1
					src.isopen = 1
					src.islocked = 0
					src.eject_occupant(OCCUPANT)
				src.isUV = 0 //Cycle ends
		src.update_icon()
		src.updateUsrDialog()
		return

/obj/machinery/suit_storage_unit/proc/cycletimeleft()
	if(src.cycletime_left >= 1)
		src.cycletime_left--
	return src.cycletime_left


/obj/machinery/suit_storage_unit/proc/eject_occupant(mob/user)
	if (src.islocked)
		return

	if (!src.OCCUPANT)
		return

	if (src.OCCUPANT.client)
		if(user != OCCUPANT)
			OCCUPANT << "<font color='blue'>The machine kicks you out!</font>"
		if(user.loc != src.loc)
			OCCUPANT << "<font color='blue'>You leave the not-so-cozy confines of the SSU.</font>"

		src.OCCUPANT.client.eye = src.OCCUPANT.client.mob
		src.OCCUPANT.client.perspective = MOB_PERSPECTIVE
	if(src.OCCUPANT.loc == src)
		src.OCCUPANT.loc = src.loc
	src.OCCUPANT = null
	if(!src.isopen)
		src.isopen = 1
	src.update_icon()
	return


/obj/machinery/suit_storage_unit/container_resist()
	var/mob/living/user = usr
	if(islocked)
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		var/breakout_time = 2
		user << "<span class='notice'>You start kicking against the doors to escape... (This will take about [breakout_time] minutes.)</span>"
		visible_message("You see [user] kicking against the doors of \the [src]!")
		if(do_after(user,(breakout_time*60*10), target = src))
			if(!user || user.stat != CONSCIOUS || user.loc != src || isopen || !islocked)
				return
			else
				isopen = 1
				islocked = 0
				visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>")

		else
			return
	src.eject_occupant(user)
	add_fingerprint(user)
	src.updateUsrDialog()
	src.update_icon()
	return


/obj/machinery/suit_storage_unit/MouseDrop_T(mob/M, mob/user)
	store_mob(M, user)

/obj/machinery/suit_storage_unit/proc/store_mob(mob/living/M, mob/user)
	if(!istype(M))
		return
	if (user.stat != 0)
		return
	if (!src.isopen)
		user << "<span class='warning'>The unit's doors are shut!</span>"
		return
	if (!src.ispowered || src.isbroken)
		user << "<span class='warning'>The unit is not operational!</span>"
		return
	if ( (src.OCCUPANT) || (src.HELMET) || (src.SUIT) || (src.STORAGE))
		user << "<span class='warning'>It's too cluttered inside to fit in!</span>"
		return
	if(M == user)
		visible_message("[user] starts squeezing into the suit storage unit!", 3)
	else
		visible_message("[user] starts putting [M.name] into the Suit Storage Unit!", 3)
	if(do_mob(user, M, 10))
		user.stop_pulling()
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		src.OCCUPANT = M
		src.isopen = 0
		src.update_icon()

		src.add_fingerprint(user)
		src.updateUsrDialog()
		return
	return


/obj/machinery/suit_storage_unit/attackby(obj/item/I, mob/user, params)
	if(!src.ispowered)
		if(istype(I, /obj/item/weapon/crowbar) && !isopen)
			if(toggle_open(user))
				dump_everything()
				user << text("<span class='notice'>You pry \the [src] open.</span>")
				update_icon()
		return
	if(istype(I, /obj/item/weapon/screwdriver))
		src.panelopen = !src.panelopen
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		user << text("<span class='notice'>You [] the unit's maintenance panel.</span>",(src.panelopen ? "open up" : "close") )
		src.updateUsrDialog()
		return
	if ( istype(I, /obj/item/weapon/grab) )
		var/obj/item/weapon/grab/G = I
		store_mob(G.affecting, user)
		return
	if( istype(I,/obj/item/clothing/suit/space) )
		if(!src.isopen || src.isbroken)
			return
		var/obj/item/clothing/suit/space/S = I
		if(src.SUIT)
			user << "<span class='notice'>The unit already contains a suit.</span>"
			return
		if(!user.drop_item())
			user << "<span class='warning'>\The [S] is stuck to your hand, you cannot put it in the Suit Storage Unit!</span>"
			return
		user << "<span class='notice'>You load the [S.name] into the suit storage compartment.</span>"
		S.loc = src
		src.SUIT = S
		src.update_icon()
		src.updateUsrDialog()
		return
	if( istype(I,/obj/item/clothing/head/helmet) )
		if(!src.isopen || src.isbroken)
			return
		var/obj/item/clothing/head/helmet/H = I
		if(src.HELMET)
			user << "<span class='warning'>The unit already contains a helmet!</span>"
			return
		if(!user.drop_item())
			user << "<span class='warning'>\The [H] is stuck to your hand, you cannot put it in the Suit Storage Unit!</span>"
			return
		user << "<span class='notice'>You load the [H.name] into the helmet storage compartment.</span>"
		H.loc = src
		src.HELMET = H
		src.update_icon()
		src.updateUsrDialog()
		return
	if( istype(I,/obj/item/clothing/mask) )
		if(!src.isopen || src.isbroken)
			return
		var/obj/item/clothing/mask/M = I
		if(src.MASK)
			user << "<span class='warning'>The unit already contains a mask!</span>"
			return
		if(!user.drop_item())
			user << "<span class='warning'>\The [M] is stuck to your hand, you cannot put it in the Suit Storage Unit!</span>"
			return
		user << "<span class='notice'>You load the [M.name] into the mask storage compartment.</span>"
		M.loc = src
		src.MASK = M
		src.update_icon()
		src.updateUsrDialog()
		return
	if( istype(I,/obj/item) )
		if(!src.isopen || src.isbroken)
			return
		var/obj/item/ITEM = I
		if(src.STORAGE)
			user << "<span class='warning'>The auxiliary storage compartment is full!</span>"
			return
		if(!user.drop_item())
			user << "<span class='warning'>\The [ITEM] is stuck to your hand, you cannot put it in the Suit Storage Unit!</span>"
			return
		user << "<span class='notice'>You load the [ITEM.name] into the auxiliary storage compartment.</span>"
		ITEM.loc = src
		src.STORAGE = ITEM
	src.update_icon()
	src.updateUsrDialog()
	return


/obj/machinery/suit_storage_unit/attack_ai(mob/user)
	return src.attack_hand(user)


/obj/machinery/suit_storage_unit/attack_paw(mob/user)
	user << "<span class='warning'>The console controls are far too complicated for your tiny brain!</span>"
	return

