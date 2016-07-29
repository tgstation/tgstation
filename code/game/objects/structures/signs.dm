<<<<<<< HEAD
/obj/structure/sign
	icon = 'icons/obj/decals.dmi'
	anchored = 1
	opacity = 0
	density = 0
	layer = SIGN_LAYER

/obj/structure/sign/basic
	name = "blank sign"
	desc = "How can signs be real if our eyes aren't real?"
	icon_state = "backing"

/obj/structure/sign/ex_act(severity, target)
	qdel(src)

/obj/structure/sign/blob_act(obj/effect/blob/B)
	qdel(src)
	return

/obj/structure/sign/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/wrench))
		user.visible_message("<span class='notice'>[user] starts removing [src]...</span>", \
							 "<span class='notice'>You start unfastening [src].</span>")
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		if(!do_after(user, 30/O.toolspeed, target = src))
			return
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] unfastens [src].</span>", \
							 "<span class='notice'>You unfasten [src].</span>")
		var/obj/item/sign_backing/SB = new (get_turf(user))
		SB.icon_state = icon_state
		SB.sign_path = type
		qdel(src)
	else if(istype(O, /obj/item/weapon/pen))
		var/list/sign_types = list("Secure Area", "Biohazard", "High Voltage", "Radiation", "Hard Vacuum Ahead", "Disposal: Leads To Space", "Danger: Fire", "No Smoking", "Medbay", "Science", "Chemistry", \
		"Hydroponics", "Xenobiology")
		var/obj/structure/sign/sign_type
		switch(input(user, "Select a sign type.", "Sign Customization") as null|anything in sign_types)
			if("Blank")
				sign_type = /obj/structure/sign/basic
			if("Secure Area")
				sign_type = /obj/structure/sign/securearea
			if("Biohazard")
				sign_type = /obj/structure/sign/biohazard
			if("High Voltage")
				sign_type = /obj/structure/sign/electricshock
			if("Radiation")
				sign_type = /obj/structure/sign/radiation
			if("Hard Vacuum Ahead")
				sign_type = /obj/structure/sign/vacuum
			if("Disposal: Leads To Space")
				sign_type = /obj/structure/sign/deathsposal
			if("Danger: Fire")
				sign_type = /obj/structure/sign/fire
			if("No Smoking")
				sign_type = /obj/structure/sign/nosmoking_1
			if("Medbay")
				sign_type = /obj/structure/sign/bluecross_2
			if("Science")
				sign_type = /obj/structure/sign/science
			if("Chemistry")
				sign_type = /obj/structure/sign/chemistry
			if("Hydroponics")
				sign_type = /obj/structure/sign/botany
			if("Xenobiology")
				sign_type = /obj/structure/sign/xenobio

		//Make sure user is adjacent still
		if(!Adjacent(user))
			return

		if(!sign_type)
			return

		//It's import to clone the pixel layout information
		//Otherwise signs revert to being on the turf and
		//move jarringly
		var/obj/structure/sign/newsign = new sign_type(get_turf(src))
		newsign.pixel_x = pixel_x
		newsign.pixel_y = pixel_y
		qdel(src)
	else
		return ..()

/obj/item/sign_backing
	name = "sign backing"
	desc = "A sign with adhesive backing."
	icon = 'icons/obj/decals.dmi'
	icon_state = "backing"
	w_class = 3
	burn_state = FLAMMABLE
	var/sign_path = /obj/structure/sign/basic //the type of sign that will be created when placed on a turf

/obj/item/sign_backing/afterattack(atom/target, mob/user, proximity)
	if(isturf(target) && proximity)
		var/turf/T = target
		user.visible_message("<span class='notice'>[user] fastens [src] to [T].</span>", \
							 "<span class='notice'>You attach a blank sign to [T].</span>")
		playsound(T, 'sound/items/Deconstruct.ogg', 50, 1)
		new sign_path(T)
		user.drop_item()
		qdel(src)
	else
		return ..()

/obj/structure/sign/map
	name = "station map"
	desc = "A framed picture of the station."

/obj/structure/sign/map/left
	icon_state = "map-left"

/obj/structure/sign/map/left/dream
	icon_state = "map-left-DS"

/obj/structure/sign/map/right
	icon_state = "map-right"

/obj/structure/sign/map/right/dream
	icon_state = "map-right-DS"

/obj/structure/sign/securearea
	name = "\improper SECURE AREA"
	desc = "A warning sign which reads 'SECURE AREA'."
	icon_state = "securearea"

/obj/structure/sign/biohazard
	name = "\improper BIOHAZARD"
	desc = "A warning sign which reads 'BIOHAZARD'"
	icon_state = "bio"

/obj/structure/sign/electricshock
	name = "\improper HIGH VOLTAGE"
	desc = "A warning sign which reads 'HIGH VOLTAGE'"
	icon_state = "shock"

/obj/structure/sign/examroom
	name = "\improper EXAM ROOM"
	desc = "A guidance sign which reads 'EXAM ROOM'"
	icon_state = "examroom"

/obj/structure/sign/vacuum
	name = "\improper HARD VACUUM AHEAD"
	desc = "A warning sign which reads 'HARD VACUUM AHEAD'"
	icon_state = "space"

/obj/structure/sign/deathsposal
	name = "\improper DISPOSAL: LEADS TO SPACE"
	desc = "A warning sign which reads 'DISPOSAL: LEADS TO SPACE'"
	icon_state = "deathsposal"

/obj/structure/sign/pods
	name = "\improper ESCAPE PODS"
	desc = "A warning sign which reads 'ESCAPE PODS'"
	icon_state = "pods"

/obj/structure/sign/fire
	name = "\improper DANGER: FIRE"
	desc = "A warning sign which reads 'DANGER: FIRE'"
	icon_state = "fire"


/obj/structure/sign/nosmoking_1
	name = "\improper NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'"
	icon_state = "nosmoking"


/obj/structure/sign/nosmoking_2
	name = "\improper NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'"
	icon_state = "nosmoking2"

/obj/structure/sign/radiation
	name = "HAZARDOUS RADIATION"
	desc = "A warning sign alerting the user of potential radiation hazards."
	icon_state = "radiation"

/obj/structure/sign/bluecross
	name = "medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here."
	icon_state = "bluecross"

/obj/structure/sign/bluecross_2
	name = "medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here."
	icon_state = "bluecross2"

/obj/structure/sign/goldenplaque
	name = "The Most Robust Men Award for Robustness"
	desc = "To be Robust is not an action or a way of life, but a mental state. Only those with the force of Will strong enough to act during a crisis, saving friend from foe, are truly Robust. Stay Robust my friends."
	icon_state = "goldenplaque"

/obj/structure/sign/kiddieplaque
	name = "AI developers plaque"
	desc = "Next to the extremely long list of names and job titles, there is a drawing of a little child. The child appears to be retarded. Beneath the image, someone has scratched the word \"PACKETS\""
	icon_state = "kiddieplaque"

/obj/structure/sign/atmosplaque
	name = "\improper FEA Atmospherics Division plaque"
	desc = "This plaque commemorates the fall of the Atmos FEA division. For all the charred, dizzy, and brittle men who have died in its hands."
	icon_state = "atmosplaque"

/obj/structure/sign/nanotrasen
	name = "\improper NanoTrasen Logo "
	desc = "A sign with the Nanotrasen Logo on it.  Glory to Nanotrasen!"
	icon_state = "nanotrasen"

/obj/structure/sign/science			//These 3 have multiple types, just var-edit the icon_state to whatever one you want on the map
	name = "\improper SCIENCE"
	desc = "A sign labelling an area where research and science is performed."
	icon_state = "science1"

/obj/structure/sign/chemistry
	name = "\improper CHEMISTRY"
	desc = "A sign labelling an area containing chemical equipment."
	icon_state = "chemistry1"

/obj/structure/sign/botany
	name = "\improper HYDROPONICS"
	desc = "A sign labelling an area as a place where plants are grown."
	icon_state = "hydro1"

/obj/structure/sign/xenobio
	name = "\improper XENOBIOLOGY"
	desc = "A sign labelling an area as a place where xenobiological entites are researched."
	icon_state = "xenobio"

/obj/structure/sign/directions/science
	name = "science department"
	desc = "A direction sign, pointing out which way the Science department is."
	icon_state = "direction_sci"

/obj/structure/sign/directions/engineering
	name = "engineering department"
	desc = "A direction sign, pointing out which way the Engineering department is."
	icon_state = "direction_eng"

/obj/structure/sign/directions/security
	name = "security department"
	desc = "A direction sign, pointing out which way the Security department is."
	icon_state = "direction_sec"

/obj/structure/sign/directions/medical
	name = "medical bay"
	desc = "A direction sign, pointing out which way the Medical Bay is."
	icon_state = "direction_med"

/obj/structure/sign/directions/evac
	name = "escape arm"
	desc = "A direction sign, pointing out which way the escape shuttle dock is."
	icon_state = "direction_evac"


=======
/*//////////////////////////////////////////
//			WARNING! ACHTUNG!			  //
//		WHEN YOU'RE MAKING A SIGN:		  //
//		REMEMBER TO USE \improper		  //
//	ONLY IF NAME IS CAPITALIZED AND 	  //
//ACTUALLY NOT PROPER; FAILURE TO DO THIS //
// WILL RESULT IN MESSAGES LIKE "The The  //
//	Periodic Table has been hit..."		  //
//	PLEASE REMEMBER THAT AND THANKS.	  //
//			HAVE A NICE DAY!			  //
*///////////////////////////////////////////

/obj/structure/sign
	icon = 'icons/obj/decals.dmi'
	anchored = 1
	opacity = 0
	density = 0
	layer = 3.5

/obj/structure/sign/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			qdel(src)
			return
		if(3.0)
			qdel(src)
			return
		else
	return

/obj/structure/sign/blob_act()
	qdel(src)
	return

/obj/structure/sign/attackby(obj/item/tool as obj, mob/user as mob)	//deconstruction
	if(isscrewdriver(tool) && !istype(src, /obj/structure/sign/double))
		to_chat(user, "You unfasten the sign with your [tool].")
		var/obj/item/sign/S = new(src.loc)
		S.name = name
		S.desc = desc
		S.icon_state = icon_state
		//var/icon/I = icon('icons/obj/decals.dmi', icon_state)
		//S.icon = I.Scale(24, 24)
		S.sign_state = icon_state
		qdel(src)
		return
	else ..()

/obj/item/sign
	name = "sign"
	desc = ""
	icon = 'icons/obj/decals.dmi'
	w_class = W_CLASS_MEDIUM		//big
	var/sign_state = ""

/obj/item/sign/attackby(obj/item/tool as obj, mob/user as mob)	//construction
	if(isscrewdriver(tool) && isturf(user.loc))
		var/direction = input("In which direction?", "Select direction.") in list("North", "East", "South", "West", "Cancel")
		if(direction == "Cancel" || src.loc == null) return // We can get qdel'd if someone spams screwdrivers on signs before responding to the prompt.
		var/obj/structure/sign/S = new(user.loc)
		switch(direction)
			if("North")
				S.pixel_y = 32
			if("East")
				S.pixel_x = 32
			if("South")
				S.pixel_y = -32
			if("West")
				S.pixel_x = -32
			else return
		S.name = name
		S.desc = desc
		S.icon_state = sign_state
		to_chat(user, "You fasten \the [S] with your [tool].")
		qdel(src)
		return
	else ..()

/obj/structure/sign/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] kicks \the [src]!</span>", "<span class='danger'>You kick \the [src]!</span>")

	if(prob(70))
		to_chat(H, "<span class='userdanger'>Ouch! That hurts!</span>")

		H.apply_damage(rand(5,7), BRUTE, pick(LIMB_RIGHT_LEG, LIMB_LEFT_LEG, LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT))

/obj/structure/sign/double/map
	name = "station map"
	desc = "A framed picture of the station."

/obj/structure/sign/double/map/left
	icon_state = "map-left"

/obj/structure/sign/double/map/right
	icon_state = "map-right"

//For efficiency station
/obj/structure/sign/map/efficiency
	name = "station map"
	desc = "A framed picture of the station."
	icon_state = "map_efficiency"

/obj/structure/sign/map/meta/left
	name = "station map"
	desc = "A framed picture of the station."
	icon_state = "map-left-MS"

/obj/structure/sign/map/meta/right
	name = "station map"
	desc = "A framed picture of the station."
	icon_state = "map-right-MS"

/obj/structure/sign/securearea
	name = "SECURE AREA"
	desc = "A warning sign which reads 'SECURE AREA'."
	icon_state = "securearea"

/obj/structure/sign/biohazard
	name = "BIOHAZARD"
	desc = "A warning sign which reads 'BIOHAZARD'"
	icon_state = "bio"

/obj/structure/sign/electricshock
	name = "HIGH VOLTAGE"
	desc = "A warning sign which reads 'HIGH VOLTAGE'"
	icon_state = "shock"

/obj/structure/sign/examroom
	name = "EXAM"
	desc = "A guidance sign which reads 'EXAM ROOM'"
	icon_state = "examroom"

/obj/structure/sign/vacuum
	name = "HARD VACUUM AHEAD"
	desc = "A warning sign which reads 'HARD VACUUM AHEAD'"
	icon_state = "space"

/obj/structure/sign/deathsposal
	name = "DISPOSAL LEADS TO SPACE"
	desc = "A warning sign which reads 'DISPOSAL LEADS TO SPACE'"
	icon_state = "deathsposal"

/obj/structure/sign/pods
	name = "ESCAPE PODS"
	desc = "A warning sign which reads 'ESCAPE PODS'"
	icon_state = "pods"

/obj/structure/sign/fire
	name = "DANGER: FIRE"
	desc = "A warning sign which reads 'DANGER: FIRE'"
	icon_state = "fire"

/obj/structure/sign/nosmoking_1
	name = "NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'"
	icon_state = "nosmoking"

/obj/structure/sign/nosmoking_2
	name = "NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'"
	icon_state = "nosmoking2"

/obj/structure/sign/redcross
	name = "Medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here.'"
	icon_state = "redcross"

/obj/structure/sign/greencross
	name = "Medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here.'"
	icon_state = "greencross"

/obj/structure/sign/goldenplaque
	name = "The Most Robust Men Award for Robustness"
	desc = "To be Robust is not an action or a way of life, but a mental state. Only those with the force of Will strong enough to act during a crisis, saving friend from foe, are truly Robust. Stay Robust my friends."
	icon_state = "goldenplaque"

/obj/structure/sign/kiddieplaque
	name = "\improper AI developer's plaque"
	desc = "Next to the extremely long list of names and job titles, there is a drawing of a little child. The child appears to be retarded. Beneath the image, someone has scratched the word \"PACKETS\""
	icon_state = "kiddieplaque"

/obj/structure/sign/atmosplaque
	name = "\improper FEA Atmospherics Division plaque"
	desc = "This plaque commemorates the fall of the Atmos FEA division. For all the charred, dizzy, and brittle men who have died in its hands."
	icon_state = "atmosplaque"

/obj/structure/sign/science			//These 3 have multiple types, just var-edit the icon_state to whatever one you want on the map
	name = "SCIENCE!"
	desc = "A warning sign which reads 'SCIENCE!'"
	icon_state = "science1"

/obj/structure/sign/chemistry
	name = "CHEMISTRY"
	desc = "A warning sign which reads 'CHEMISTRY'"
	icon_state = "chemistry1"

/obj/structure/sign/chemtable
	name = "The Periodic Table"
	desc = "A very colorful and detailed table of all the chemical elements you could blow up or burn down a chemistry laboratory with, titled 'The Space Periodic Table - To be continued'. Just the mere sight of it makes you feel smarter."
	icon_state = "periodic"

/obj/structure/sign/botany
	name = "HYDROPONICS"
	desc = "A warning sign which reads 'HYDROPONICS'"
	icon_state = "hydro1"

/obj/structure/sign/directions/science
	name = "Science department"
	desc = "A direction sign, pointing out which way Science department is."
	icon_state = "direction_sci"

/obj/structure/sign/directions/engineering
	name = "Engineering department"
	desc = "A direction sign, pointing out which way Engineering department is."
	icon_state = "direction_eng"

/obj/structure/sign/directions/security
	name = "Security department"
	desc = "A direction sign, pointing out which way Security department is."
	icon_state = "direction_sec"

/obj/structure/sign/directions/medical
	name = "Medical Bay"
	desc = "A direction sign, pointing out which way Meducal Bay is."
	icon_state = "direction_med"

/obj/structure/sign/directions/evac
	name = "Escape Arm"
	desc = "A direction sign, pointing out which way escape shuttle dock is."
	icon_state = "direction_evac"

/obj/structure/sign/crime
	name = "CRIME DOES NOT PAY"
	desc = "A warning sign which suggests that you reconsider your poor life choices."
	icon_state = "crime"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
