//Time in ticks for each surgery. A bit above the time taken by hand, is multiplied if you have shitty parts

#define SURGERYTIME_SHORT 136	//Stumps, embedded objects
#define SURGERYTIME_MEDIUM 168	//Plastic surgery and sex change
#define SURGERYTIME_LONG 200	//Eyes, lipoplasty, appendectomy
#define SURGERYTIME_LONGEST 256	//Amputation and xeno removal

//Does surgical operations for you
/obj/machinery/rapidsexchanger
	name = "Auto-Doc Mark IX"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper-open"	//An unique icon would be appreciated
	density = 0
	anchored = 1
	state_open = 1
	var/locked = 0
	var/efficiency
	var/scanlevel

	var/list/surgeries = list() //list of surgeries that can be currently performed
	var/list/possible_surgeries = list(list("amputation", "stump cleanup", "appendectomy", "eye surgery", "xenomorph removal"),
								   list("amputation", "stump cleanup", "appendectomy", "eye surgery", "xenomorph removal", "embedded object removal"),
								   list("amputation", "stump cleanup", "appendectomy", "eye surgery", "xenomorph removal", "embedded object removal",
								   		"lipoplasty", "plastic surgery", "sex change"),
								   list("amputation", "stump cleanup", "organ removal", "eye surgery", "embedded object removal",
								   		"lipoplasty", "plastic surgery", "sex change"))	//4th level adds arbitrary organ removal (replaces appendectomy and xeno)

/obj/machinery/rapidsexchanger/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/rapidsexchanger(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)

	component_parts += new /obj/item/weapon/retractor()
	component_parts += new /obj/item/weapon/hemostat()
	component_parts += new /obj/item/weapon/cautery()
	component_parts += new /obj/item/weapon/surgicaldrill()
	component_parts += new /obj/item/weapon/scalpel()
	component_parts += new /obj/item/weapon/circular_saw()

	RefreshParts()

/obj/machinery/rapidsexchanger/RefreshParts()
	var/I = 0
	var/E = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/S in component_parts)
		I += S.rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		E += M.rating

	scanlevel = I	//At 3 you can scan internal organs
	surgeries = possible_surgeries[I]
	efficiency = E

/obj/machinery/rapidsexchanger/allow_drop()
	return 0

/obj/machinery/rapidsexchanger/MouseDrop_T(mob/target, mob/user)
	if(stat || user.stat || user.lying || target.buckled || !Adjacent(user) || !target.Adjacent(user)|| !iscarbon(target))
		return
	close_machine(target)

/obj/machinery/rapidsexchanger/blob_act()
	if(prob(75))
		for(var/atom/movable/A in src)
			A.loc = loc
			A.blob_act()
		qdel(src)

/obj/machinery/rapidsexchanger/attack_animal(var/mob/living/simple_animal/M)//Stop putting hostile mobs in things guise
	if(M.environment_smash)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>[M.name] smashes [src] apart!</span>")
		qdel(src)
	return

/obj/machinery/rapidsexchanger/attackby(obj/item/I, mob/user, params)
	if(!state_open && !occupant)
		if(default_deconstruction_screwdriver(user, "sleeper-o", "sleeper", I))
			return

	if(default_change_direction_wrench(user, I))
		return

	if(exchange_parts(user, I))
		return

	if(default_pry_open(I))
		return

	default_deconstruction_crowbar(I)

/obj/machinery/rapidsexchanger/ex_act(severity, target)
	go_out()
	..()

/obj/machinery/rapidsexchanger/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..(severity)

/obj/machinery/rapidsexchanger/proc/go_out()
	if(!occupant)
		return
	for(var/atom/movable/O in src)
		O.loc = loc
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant = null
	icon_state = "sleeper-open"

/obj/machinery/rapidsexchanger/container_resist()
	open_machine()

/obj/machinery/rapidsexchanger/relaymove(var/mob/user)
	..()
	if(locked)
		user << "The [src.name] is locked! (Resist to break out forcefully)"
	else
		open_machine()

/obj/machinery/rapidsexchanger/attack_hand(mob/user)
	if(..())
		return

	surgeryUI(user)

/obj/machinery/rapidsexchanger/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/rapidsexchanger/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/rapidsexchanger/open_machine()
	if(locked)
		forced_open()
		locked = 0
	if(!state_open && !panel_open)
		..()

/obj/machinery/rapidsexchanger/close_machine(mob/target)
	if(state_open && !panel_open)
		..(target)

/obj/machinery/rapidsexchanger/update_icon()
	if(state_open)
		icon_state = "sleeper-open"
	else
		icon_state = "sleeper"

//Ayy fuck nano
/obj/machinery/rapidsexchanger/proc/surgeryUI(mob/user)
	var/dat
	dat += "<h3>Surgeries</h3>"
	if(occupant && ishuman(occupant))
		for(var/OP in surgeries)
			dat += "<BR><A href='?src=\ref[src];surgery=[OP]'>Initiate [OP]</A>"
	else
		for(var/OP in surgeries)
			dat += "<BR><span class='linkOff'>Initiate [OP]</span>"

	dat += "<h3>Auto-Doc Status</h3>"
	dat += "<A href='?src=\ref[src];refresh=1'>Scan</A>"
	if(!locked)
		dat += "<A href='?src=\ref[src];[state_open ? "close=1'>Close</A>" : "open=1'>Open</A>"]"
	else
		dat += "<span class='linkOff'>Open</span>"
	dat += "<div class='statusDisplay'>"
	if(!occupant)
		dat += "Auto-Doc Unoccupied"
	else
		dat += "[occupant.name] => "
		switch(occupant.stat)	//obvious, see what their status is
			if(0)
				dat += "<span class='good'>Conscious</span>"
			if(1)
				dat += "<span class='average'>Unconscious</span>"
			else
				dat += "<span class='bad'>DEAD</span>"
		dat += "<br />"
		dat +=  "<div class='line'><div class='statusLabel'>Health:</div><div class='progressBar'><div style='width: [occupant.health < 0 ? "0" : "[occupant.health]"]%;' class='progressFill good'></div></div><div class='statusValue'>[occupant.stat > 1 ? "" : "[occupant.health]%"]</div></div>"

		for(var/datum/organ/limb/LI in occupant.get_limbs())
			dat += "<div class='line'>[LI.getDisplayName()]: [LI.exists() ? LI.organitem.name : LI.getStatusString()].</div>"
		if(scanlevel >= 3)	//Phasics
			for(var/datum/organ/internal/OI in occupant.get_all_internal_organs())
				if(OI.exists())
					dat += "<div class='line'>[OI.getDisplayName()]: [OI.organitem.name].</div>"
/*
		if(occupant.disabilites & (BLIND | NEARSIGHT) || occupant.eye_stat)
			dat += "<div class='line'><span class='average'>Subject appears to have eye damage.</span></div>"
*/
	dat += "</div>"

	var/datum/browser/popup = new(user, "sleeper", "Sleeper Console", 520, 540)	//Set up the popup browser window
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.set_content(dat)
	popup.open()

/obj/machinery/rapidsexchanger/Topic(href, href_list)
	if(..() || usr == occupant)
		return
	usr.set_machine(src)
	if(href_list["refresh"])
		updateUsrDialog()
		return
	if(href_list["open"] && !locked)
		open_machine()
		return
	if(href_list["close"])
		close_machine()
		return
	if(occupant && ishuman(occupant) && href_list["surgery"])
		do_operation(usr, href_list["surgery"])
	updateUsrDialog()
	add_fingerprint(usr)

/obj/machinery/rapidsexchanger/proc/do_operation(var/mob/user, var/surgeryname)
	locked = 1
	var/locktime = 0
	var/errstring = "could not start operation"
	var/surgerystring = surgeryname
	var/organname
	switch (surgeryname)
		if("amputation")
			var/list/limbs = list()
			for(var/datum/organ/limb/LI in occupant.get_limbs())
				if(LI.exists() && !istype(LI, /datum/organ/limb/chest))
					limbs += LI.name
			organname = input("Amputate which limb?", "Surgery", null, null) as null|anything in limbs
			if(occupant.exists(organname))
				var/datum/organ/OR = occupant.get_organ(organname)
				locktime = SURGERYTIME_LONGEST
				surgerystring = "[OR.getDisplayName()] amputation"
			errstring = "no limb to amputate"
		if("stump cleanup")
			var/limbscleaned = 0
			for(var/datum/organ/limb/LI in occupant.get_limbs())
				if(!LI.exists() && LI.status != ORGAN_REMOVED)
					limbscleaned++
			locktime = limbscleaned * SURGERYTIME_SHORT
			errstring = "no stumps to clean"
		if("appendectomy")
			if(occupant.exists("appendix"))
				locktime = SURGERYTIME_LONG
			errstring = "could not find appendix"
		if("organ removal")
			var/list/organs = list()
			for(var/datum/organ/OR in occupant.get_all_internal_organs())
				if(OR.exists())
					organs += OR.name
			organname = input("Remove which organ?", "Surgery", null, null) as null|anything in organs
			if(occupant.exists(organname))
				var/datum/organ/OR = occupant.get_organ(organname)
				locktime = SURGERYTIME_LONGEST
				surgerystring = "[OR.getDisplayName()] removal"
			errstring = "no organ to remove"
		if("eye surgery")
			if(occupant.exists("eyes"))
				locktime = SURGERYTIME_LONG
			errstring = "occupant has no eyes"
		if("xenomorph removal")
			if(occupant.exists("egg"))
				locktime = SURGERYTIME_LONGEST
			errstring = "could not find any alien lifeforms"
		if("embedded object removal")
			var/limbscleaned = 0
			for(var/datum/organ/limb/LI in occupant.get_limbs())
				if(LI.exists())
					var/obj/item/organ/limb/OI = LI.organitem
					for(var/obj/item/I in OI.embedded_objects)
						limbscleaned ++
						break
			locktime = limbscleaned * SURGERYTIME_SHORT
			errstring = "could not find any embedded objects"
		if("lipoplasty")
			if(occupant.disabilities & FAT)
				locktime = SURGERYTIME_LONG
			errstring = "not enough fatty tissue for lipoplasty"
		if("plastic surgery")
			locktime = SURGERYTIME_MEDIUM
		if("sex change")
			locktime = SURGERYTIME_MEDIUM
	locktime *= 3 - min(2, efficiency/2)	//Actual time taken is 1-2.5 times the defined time, depending on efficiency
	if(locktime)
		say("Initiating [surgerystring]. Auto-Doc locked for patient safety.")
		spawn(locktime)
			if(!occupant)
				say("Error: occupant removed forcefully.")
			switch(surgeryname)	//I'm so sorry
				if("amputation")
					remove_organ(organname)
				if("stump cleanup")
					stump_cleanup()
				if("appendectomy")
					remove_organ("appendix")
				if("organ removal")
					remove_organ(organname)
				if("eye surgery")
					eye_surgery()
				if("xenomorph removal")
					remove_organ("egg")
				if("embedded object removal")
					remove_embedded()
				if("lipoplasty")
					lipoplasty()
				if("plastic surgery")
					plastic_surgery()
				if("sex change")
					sex_change()
			say("Operation complete!")
			locked = 0
	else
		say("Error: [errstring]")
		locked = 0

//0-15 damage or dismemberment
/obj/machinery/rapidsexchanger/proc/forced_open()
	if(prob(1))	//Complete botch results in dismemberment
		var/list/limbs = occupant.get_limbs()
		for(var/datum/organ/limb/I in limbs)
			if(!I.exists() || istype(I, /datum/organ/limb/head/))	//Don't want instakills
				limbs -= I
		var/datum/organ/limb/LI = pick(limbs)
		LI.dismember(ORGAN_DESTROYED)
		visible_message("<span class='warning'>[src] accidentally chops off [occupant]'s [LI.getDisplayName()]!</span>")
		return
	if(prob(2))	//A little less than 2% chance of botched sexchange
		if(ishuman(occupant))
			var/mob/living/carbon/human/H = occupant
			H.gender_ambiguous = 1
		occupant.gender = pick(MALE, FEMALE)
		occupant.regenerate_icons()
		visible_message("<span class='warning'>[src] mutilates [occupant]'s genitals beyond the point of recognition!</span>")
		return
	else	//0-15 damage
		var/dam = rand(0, 15)
		if(dam)
			var/damstring = pick("scalpel","circular saw")
			occupant.take_organ_damage(dam, 0)
			visible_message("<span class='warning'>[src] accidentally cuts [occupant] with its [damstring]!</span>")
		return

//Surgery procs, all return success (0, 1, or amount)

//Amputation, appendectomy, xeno removal
/obj/machinery/rapidsexchanger/proc/remove_organ(var/organname)
	var/datum/organ/OR = occupant.get_organ(organname)
	if(OR && OR.exists())
		return OR.dismember(ORGAN_REMOVED)
	return 0

//All stumps
/obj/machinery/rapidsexchanger/proc/stump_cleanup(var/organname)
	var/limbscleaned = 0
	for(var/datum/organ/limb/LI in occupant.get_limbs())
		if(!LI.exists() && LI.status != ORGAN_REMOVED)
			LI.status = ORGAN_REMOVED
			limbscleaned++
	return limbscleaned

/obj/machinery/rapidsexchanger/proc/eye_surgery()
	occupant.disabilities &= ~BLIND
	occupant.disabilities &= ~NEARSIGHT
	occupant.eye_blurry = 35	//this will fix itself slowly.
	occupant.eye_stat = 0
	return 1

//From all limbs
/obj/machinery/rapidsexchanger/proc/remove_embedded()
	for(var/datum/organ/limb/LI in occupant.get_limbs())
		if(LI.exists())
			var/obj/item/organ/limb/OI = LI.organitem
			for(var/obj/item/I in OI.embedded_objects)
				I.loc = loc
				OI.embedded_objects -= I
	return 1

//Copy paste FUCK YEAH
/obj/machinery/rapidsexchanger/proc/lipoplasty()
	occupant.overeatduration = 0 //patient is unfatted
	var/removednutriment = occupant.nutrition
	occupant.nutrition = NUTRITION_LEVEL_WELL_FED
	removednutriment -= 450 //whatever was removed goes into the meat
	var/obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/newmeat = new
	newmeat.name = "fatty meat"
	newmeat.desc = "Extremely fatty tissue taken from a patient."
	newmeat.reagents.add_reagent ("nutriment", (removednutriment / 15))
	var/obj/item/meatslab = newmeat
	meatslab.loc = src
	return 1

/obj/machinery/rapidsexchanger/proc/plastic_surgery()
	if(occupant.status_flags & DISFIGURED)
		occupant.status_flags &= ~DISFIGURED
	else
		occupant.real_name = random_name(occupant.gender)
		var/mob/living/carbon/human/H = occupant
		H.sec_hud_set_security_status()	//Update HUD
	return 1

//Finally, something useful
/obj/machinery/rapidsexchanger/proc/sex_change()
	occupant.gender = (occupant.gender == FEMALE ? MALE : FEMALE)
	return 1



#undef SURGERYTIME_SHORT
#undef SURGERYTIME_MEDIUM
#undef SURGERYTIME_LONG
#undef SURGERYTIME_LONGEST