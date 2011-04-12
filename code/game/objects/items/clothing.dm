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

/obj/item/clothing/suit/space/space_ninja/New()
//Fix for the examine issue mentioned below. Followup: this doesn't fix anything. I'll need to take a look at how examine works.
	src.verbs += /obj/item/clothing/suit/space/space_ninja/proc/init

/obj/item/clothing/suit/space/space_ninja/proc/init()
	set name = "Initialize Suit"
	set desc = "Initializes the suit for field operation."
	set category = "Object"

	if(usr.mind&&usr.mind.special_role=="Space Ninja"&&usr:wear_suit==src&&!src.initialize)
		var/mob/living/carbon/human/U = usr
		U << "\blue Now initializing..."
		sleep(40)
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
		src.canremove=0
		sleep(40)
		U << "\blue Extending neural-net interface...\nNow monitoring brain wave pattern..."
		sleep(40)
		if(U.stat==2)
			U << "\red <B>FATAL ERROR</B>: 344--93#&&21 BRAIN WAV3 PATT$RN <B>RED</B>\nA-A-AB0RTING..."
			return
		U << "\blue Linking neural-net interface...\nPattern \green <B>GREEN</B>\blue, continuing operation."
		sleep(40)
		U << "\blue VOID-shift device status: <B>ONLINE</B>.\nCLOAK-tech device status: <B>ONLINE</B>."
		sleep(40)
		U << "\blue Primary system status: <B>ONLINE</B>.\nBackup system status: <B>ONLINE</B>.\nCurrent energy capacity: <B>[src.charge]<B>."
		sleep(40)
		U << "\blue All systems operational. Welcome to SpiderOS, [U.real_name]."
		U.verbs += /mob/proc/ninjashift
		U.verbs += /mob/proc/ninjajaunt
		U.verbs += /mob/proc/ninjasmoke
		U.verbs += /mob/proc/ninjapulse
		U.verbs += /mob/proc/ninjablade
		U.mind.special_verbs += /mob/proc/ninjashift
		U.mind.special_verbs += /mob/proc/ninjajaunt
		U.mind.special_verbs += /mob/proc/ninjasmoke
		U.mind.special_verbs += /mob/proc/ninjapulse
		U.mind.special_verbs += /mob/proc/ninjablade
		src.verbs -= /obj/item/clothing/suit/space/space_ninja/proc/init
		src.verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit
		src.verbs += /obj/item/clothing/suit/space/space_ninja/proc/toggle
		src.initialize=1
		src.affecting=U
		src.slowdown=0
		U.shoes:slowdown--
	else
		if(usr.mind&&usr.mind.special_role=="Space Ninja")
			usr << "\red You do not understand how this suit functions."
		else if(usr:wear_suit!=src)
			usr << "\red You must be wearing the suit to use this function."
		else if(src.initialize)
			usr << "\red The suit is already functioning."
		else
			usr << "\red You cannot use this function at this time."
	return

/obj/item/clothing/suit/space/space_ninja/proc/deinit()
	set name = "De-Initialize Suit"
	set desc = "Begins procedure to remove the suit."
	set category = "Object"

	if(!src.initialize)
		usr << "\red The suit is not initialized."
		return
	if(alert("Are you certain you wish to remove the suit? This will take time and remove all abilities.",,"Yes","No")=="No")
		return

	var/mob/living/carbon/human/U = usr

	U << "\blue Now de-initializing..."
	sleep(40)
	U.verbs -= /mob/proc/ninjashift
	U.verbs -= /mob/proc/ninjajaunt
	U.verbs -= /mob/proc/ninjasmoke
	U.verbs -= /mob/proc/ninjapulse
	U.verbs -= /mob/proc/ninjablade
	U.mind.special_verbs -= /mob/proc/ninjashift
	U.mind.special_verbs -= /mob/proc/ninjajaunt
	U.mind.special_verbs -= /mob/proc/ninjasmoke
	U.mind.special_verbs -= /mob/proc/ninjapulse
	U.mind.special_verbs -= /mob/proc/ninjablade
	U << "\blue Logging off, [U:real_name]. Shutting down SpiderOS."
	sleep(40)
	U << "\blue Primary system status: <B>OFFLINE</B>.\nBackup system status: <B>OFFLINE</B>."
	sleep(40)
	U << "\blue VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>."
	sleep(40)
	if(U.stat==2||U.health<=0)
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
		U.gloves:canremove=1
	src.canremove=1
	U << "\blue Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>."
	src.verbs += /obj/item/clothing/suit/space/space_ninja/proc/init
	src.verbs -= /obj/item/clothing/suit/space/space_ninja/proc/deinit
	src.verbs -= /obj/item/clothing/suit/space/space_ninja/proc/toggle
	src.initialize=0
	src.affecting=null
	src.slowdown=1
	return

/obj/item/clothing/suit/space/space_ninja/proc/toggle()
	set name = "Toggle Stealth"
	set desc = "Toggles the internal CLOAK-tech on or off."
	set category = "Object"

	if(usr:wear_suit!=src||!src.initialize)
		usr << "\red You suit must be worn and active to use this function."
		return
	if(src.active)
		spawn(0)
			anim(usr.loc,'mob.dmi',usr,"uncloak")
		src.active=0
		usr << "\blue You are now visible."
		for(var/mob/O in oviewers(usr, null))
			O << "[usr.name] appears from thin air!"

	else
		spawn(0)
			anim(usr.loc,'mob.dmi',usr,"cloak")
		src.active=1
		usr << "\blue You are now invisible to normal detection."
		for(var/mob/O in oviewers(usr, null))
			O << "[usr.name] vanishes into thin air!"

//So apparently, examine won't show up as a verb when
//viewing an object equipped on the hud
//and that object having other verbs?
//Doesn't really make any sense
/obj/item/clothing/suit/space/space_ninja/examine()
	..()
	if(src.initialize)
		usr << "All systems operational. Current energy capacity: <B>[src.charge]<B>."
		if(src.active)
			usr << "The CLOAK-tech device is active."
		else
			usr << "The CLOAK-tech device is offline."

/obj/item/clothing/mask/gas/space_ninja/New()
	src.verbs += /obj/item/clothing/mask/gas/space_ninja/proc/togglev
	src.verbs += /obj/item/clothing/mask/gas/space_ninja/proc/switchm

/obj/item/clothing/mask/gas/space_ninja/proc/togglev()
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

/obj/item/clothing/mask/gas/space_ninja/proc/switchm()
	set name = "Switch Mode"
	set desc = "Switches between Night Vision, Meson, or Thermal vision modes."
	set category = "Object"
	//Have to reset these manually since life.dm is retarded like that. Go figure.
	switch(src.mode)
		if(1)
			src.mode=2
			usr.see_in_dark = 2
			usr << "Switching mode to <B>Thermal Scanner</B>."
		if(2)
			src.mode=3
			usr.see_invisible = 0
			usr.sight &= ~SEE_MOBS
			usr << "Switching mode to <B>Meson Scanner</B>."
		if(3)
			src.mode=1
			usr.sight &= ~SEE_TURFS
			usr << "Switching mode to <B>Night Vision</B>."

/obj/item/clothing/mask/gas/space_ninja/examine()
	..()
	var/mode = "Night Vision"
	var/voice = "inactive"
	switch(src.mode)
		if(1)
			mode = "Night Vision"
		if(2)
			mode = "Thermal Scanner"
		if(3)
			mode = "Meson Scanner"
	if(src.vchange==0)
		voice = "inactive"
	else
		voice = "active"
	usr << "<B>[mode]</B> is active."
	usr << "Voice mimicking algorithm is set to <B>[voice]</B>."