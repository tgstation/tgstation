//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

//Potential replacement for genetics revives or something I dunno (?)

#define CLONE_INITIAL_DAMAGE     190    //Clones in clonepods start with 190 cloneloss damage and 190 brainloss damage, thats just logical

#define SPEAK(message) radio.talk_into(src, message, radio_channel, get_spans())

/obj/machinery/clonepod
	anchored = 1
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = 1
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(access_genetics) //For premature unlocking.
	verb_say = "states"
	var/heal_level = 90 //The clone is released once its health reaches this level.
	var/locked = FALSE
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = FALSE //Need to clean out it if it's full of exploded clone.
	var/attempting = FALSE //One clone attempt at a time thanks
	var/eject_wait = FALSE //Don't eject them as soon as they are created fuckkk
	var/speed_coeff
	var/efficiency

	var/datum/mind/clonemind
	var/grab_ghost_when = CLONER_MATURE_CLONE

	var/obj/item/device/radio/radio
	var/radio_key = /obj/item/device/encryptionkey/headset_med
	var/radio_channel = "Medical"

	var/obj/effect/countdown/clonepod/countdown

/obj/machinery/clonepod/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/clonepod(null)
	B.apply_default_parts(src)

	countdown = new(src)

	radio = new(src)
	radio.keyslot = new radio_key
	radio.subspace_transmission = 1
	radio.canhear_range = 0
	radio.recalculateChannels()

/obj/machinery/clonepod/Destroy()
	go_out()
	qdel(radio)
	radio = null
	qdel(countdown)
	countdown = null
	. = ..()

/obj/machinery/clonepod/RefreshParts()
	speed_coeff = 0
	efficiency = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/S in component_parts)
		efficiency += S.rating
	for(var/obj/item/weapon/stock_parts/manipulator/P in component_parts)
		speed_coeff += P.rating
	heal_level = (efficiency * 15) + 10
	if(heal_level > 100)
		heal_level = 100

/obj/item/weapon/circuitboard/machine/clonepod
	name = "circuit board (Clone Pod)"
	build_path = /obj/machinery/clonepod
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/scanning_module = 2,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/sheet/glass = 1)

//The return of data disks?? Just for transferring between genetics machine/cloning machine.
//TO-DO: Make the genetics machine accept them.
/obj/item/weapon/disk/data
	name = "cloning data disk"
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	var/list/fields = list()
	var/read_only = 0 //Well,it's still a floppy disk

//Disk stuff.
/obj/item/weapon/disk/data/New()
	..()
	icon_state = "datadisk[rand(0,6)]"
	add_overlay("datadisk_gene")

/obj/item/weapon/disk/data/attack_self(mob/user)
	read_only = !read_only
	user << "<span class='notice'>You flip the write-protect tab to [read_only ? "protected" : "unprotected"].</span>"

/obj/item/weapon/disk/data/examine(mob/user)
	..()
	user << "The write-protect tab is set to [read_only ? "protected" : "unprotected"]."


//Clonepod

/obj/machinery/clonepod/examine(mob/user)
	..()
	if(mess)
		user << "It's filled with blood and viscera. You swear you can see it moving..."
	if (is_operational() && (!isnull(occupant)) && (occupant.stat != DEAD))
		user << "Current clone cycle is [round(get_completion())]% complete."

/obj/machinery/clonepod/proc/get_completion()
	. = (100 * ((occupant.health + 100) / (heal_level + 100)))

/obj/machinery/clonepod/attack_ai(mob/user)
	return examine(user)

//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(ckey, clonename, ui, se, mindref, datum/species/mrace, list/features, factions)
	if(panel_open)
		return FALSE
	if(mess || attempting)
		return FALSE
	clonemind = locate(mindref)
	if(!istype(clonemind))	//not a mind
		return FALSE
	if( clonemind.current && clonemind.current.stat != DEAD )	//mind is associated with a non-dead body
		return FALSE
	if(clonemind.active)	//somebody is using that mind
		if( ckey(clonemind.key)!=ckey )
			return FALSE
	else
		// get_ghost() will fail if they're unable to reenter their body
		var/mob/dead/observer/G = clonemind.get_ghost()
		if(!G)
			return FALSE
	if(clonemind.damnation_type) //Can't clone the damned.
		addtimer(src, "horrifyingsound", 0)
		mess = 1
		icon_state = "pod_g"
		update_icon()
		return FALSE

	attempting = TRUE //One at a time!!
	locked = TRUE
	countdown.start()

	eject_wait = TRUE
	addtimer(src, "wait_complete", 30)

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src)

	H.hardset_dna(ui, se, H.real_name, null, mrace, features)

	if(efficiency > 2)
		var/list/unclean_mutations = (not_good_mutations|bad_mutations)
		H.dna.remove_mutation_group(unclean_mutations)
	if(efficiency > 5 && prob(20))
		H.randmutvg()
	if(efficiency < 3 && prob(50))
		var/mob/M = H.randmutb()
		if(ismob(M))
			H = M

	H.silent = 20 //Prevents an extreme edge case where clones could speak if they said something at exactly the right moment.
	occupant = H

	if(!clonename)	//to prevent null names
		clonename = "clone ([rand(0,999)])"
	H.real_name = clonename

	icon_state = "pod_1"
	//Get the clone body ready
	H.setCloneLoss(CLONE_INITIAL_DAMAGE)     //Yeah, clones start with very low health, not with random, because why would they start with random health
	H.setBrainLoss(CLONE_INITIAL_DAMAGE)
	H.Paralyse(4)

	if(grab_ghost_when == CLONER_FRESH_CLONE)
		clonemind.transfer_to(H)
		H.ckey = ckey
		H << "<span class='notice'><b>Consciousness slowly creeps over you \
			as your body regenerates.</b><br><i>So this is what cloning \
			feels like?</i></span>"
	else if(grab_ghost_when == CLONER_MATURE_CLONE)
		clonemind.current << "<span class='notice'>Your body is \
			beginning to regenerate in a cloning pod. You will \
			become conscious when it is complete.</span>"

	if(H)
		H.faction |= factions

		H.set_cloned_appearance()

		H.suiciding = FALSE
	attempting = FALSE
	return TRUE

/obj/machinery/clonepod/proc/wait_complete()
	eject_wait = FALSE

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/process()

	if(!is_operational()) //Autoeject if power is lost
		if (occupant)
			locked = FALSE
			go_out()
			connected_message("Clone Ejected: Loss of power.")

	else if((occupant) && (occupant.loc == src))
		if((occupant.stat == DEAD) || (occupant.suiciding) || occupant.hellbound)  //Autoeject corpses and suiciding dudes.
			connected_message("Clone Rejected: Deceased.")
			SPEAK("The cloning of <b>[occupant.real_name]</b> has been \
				aborted due to unrecoverable tissue failure.")
			locked = FALSE
			go_out()

		else if(occupant.cloneloss > (100 - heal_level))
			occupant.Paralyse(4)

			 //Slowly get that clone healed and finished.
			occupant.adjustCloneLoss(-((speed_coeff/2) * config.damage_multiplier))

			//Premature clones may have brain damage.
			occupant.adjustBrainLoss(-((speed_coeff/2) * config.damage_multiplier))

			//So clones don't die of oxyloss in a running pod.
			if (occupant.reagents.get_reagent_amount("salbutamol") < 30)
				occupant.reagents.add_reagent("salbutamol", 60)
			// NOBREATH species will take brute damage in crit instead
			// so heal that as well
			if(occupant.reagents.get_reagent_amount("bicaridine") < 5)
				occupant.reagents.add_reagent("bicaridine", 10)

			use_power(7500) //This might need tweaking.

		else if((occupant.cloneloss <= (100 - heal_level)) && (!eject_wait))
			connected_message("Cloning Process Complete.")
			SPEAK("The cloning cycle of <b>[occupant]</b> is complete.")
			locked = FALSE
			go_out()

	else if ((!occupant) || (occupant.loc != src))
		occupant = null
		if (locked)
			locked = FALSE
		if (!mess && !panel_open)
			icon_state = "pod_0"
		use_power(200)

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(obj/item/weapon/W, mob/user, params)
	if(!(occupant || mess || locked))
		if(default_deconstruction_screwdriver(user, "[icon_state]_maintenance", "[initial(icon_state)]",W))
			return

	if(exchange_parts(user, W))
		return

	if(default_deconstruction_crowbar(W))
		return

	if (W.GetID())
		if (!check_access(W))
			user << "<span class='danger'>Access Denied.</span>"
			return
		if (!locked || !occupant)
			return
		if (occupant.health < -20 && occupant.stat != DEAD)
			user << "<span class='danger'>Access Refused. Patient status still unstable.</span>"
			return
		else
			locked = FALSE
			user << "System unlocked."
	else
		return ..()

/obj/machinery/clonepod/emag_act(mob/user)
	if (isnull(occupant))
		return
	user << "<span class='notice'>You force an emergency ejection.</span>"
	locked = FALSE
	go_out()

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(message)
	if ((isnull(connected)) || (!istype(connected, /obj/machinery/computer/cloning)))
		return FALSE
	if (!message)
		return FALSE

	connected.temp = message
	connected.updateUsrDialog()
	return TRUE

/obj/machinery/clonepod/verb/eject()
	set name = "Eject Cloner"
	set category = "Object"
	set src in oview(1)

	if(!usr)
		return
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	go_out()
	add_fingerprint(usr)

/obj/machinery/clonepod/proc/go_out()
	if (locked)
		return
	countdown.stop()

	if (mess) //Clean that mess and dump those gibs!
		mess = FALSE
		new /obj/effect/gibspawner/generic(loc)
		audible_message("<span class='italics'>You hear a splat.</span>")
		icon_state = "pod_0"
		return

	if (!occupant)
		return

	if(grab_ghost_when == CLONER_MATURE_CLONE)
		clonemind.transfer_to(occupant)
		occupant.grab_ghost()
		occupant << "<span class='notice'><b>There is a bright flash!</b><br>\
			<i>You feel like a new being.</i></span>"
		occupant.flash_act()

	var/turf/T = get_turf(src)
	occupant.forceMove(T)
	icon_state = "pod_0"
	eject_wait = FALSE //If it's still set somehow.
	occupant.domutcheck(1) //Waiting until they're out before possible monkeyizing. The 1 argument forces powers to manifest.
	occupant = null

/obj/machinery/clonepod/proc/malfunction()
	if(occupant)
		connected_message("Critical Error!")
		SPEAK("Critical error! Please contact a Thinktronic Systems \
			technician, as your warranty may be affected.")
		mess = TRUE
		icon_state = "pod_g"
		if(occupant.mind != clonemind)
			clonemind.transfer_to(occupant)
		occupant.grab_ghost() // We really just want to make you suffer.
		flash_color(occupant, flash_color="#960000", flash_time=100)
		occupant << "<span class='warning'><b>Agony blazes across your \
			consciousness as your body is torn apart.</b><br>\
			<i>Is this what dying is like? Yes it is.</i></span>"
		playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, 0)
		occupant << sound('sound/hallucinations/veryfar_noise.ogg',0,1,50)
		QDEL_IN(occupant, 40)

/obj/machinery/clonepod/relaymove(mob/user)
	if(user.stat == CONSCIOUS)
		go_out()

/obj/machinery/clonepod/emp_act(severity)
	if(prob(100/(severity*efficiency)))
		malfunction()
	..()

/obj/machinery/clonepod/ex_act(severity, target)
	..()
	if(!qdeleted(src))
		locked = FALSE
		go_out()

/obj/machinery/clonepod/handle_atom_del(atom/A)
	if(A == occupant)
		occupant = null
		locked = FALSE
		go_out()

/obj/machinery/clonepod/proc/horrifyingsound()
	for(var/i in 1 to 5)
		playsound(loc,pick('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg'), 100, rand(0.95,1.05))
		sleep(1)
	sleep(10)
	playsound(loc,'sound/hallucinations/wail.ogg',100,1)

/obj/machinery/clonepod/deconstruct(disassembled = TRUE)
	if(occupant)
		locked = FALSE
		go_out()
	..()


/*
 *	Diskette Box
 */

/obj/item/weapon/storage/box/disks
	name = "diskette box"
	icon_state = "disk_kit"

/obj/item/weapon/storage/box/disks/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/disk/data(src)

/*
 *	Manual -- A big ol' manual.
 */

/obj/item/weapon/paper/Cloning
	name = "paper - 'H-87 Cloning Apparatus Manual"
	info = {"<h4>Getting Started</h4>
	Congratulations, your station has purchased the H-87 industrial cloning device!<br>
	Using the H-87 is almost as simple as brain surgery! Simply insert the target humanoid into the scanning chamber and select the scan option to create a new profile!<br>
	<b>That's all there is to it!</b><br>
	<i>Notice, cloning system cannot scan inorganic life or small primates.  Scan may fail if subject has suffered extreme brain damage.</i><br>
	<p>Clone profiles may be viewed through the profiles menu. Scanning implants a complementary HEALTH MONITOR IMPLANT into the subject, which may be viewed from each profile.
	Profile Deletion has been restricted to \[Station Head\] level access.</p>
	<h4>Cloning from a profile</h4>
	Cloning is as simple as pressing the CLONE option at the bottom of the desired profile.<br>
	Per your company's EMPLOYEE PRIVACY RIGHTS agreement, the H-87 has been blocked from cloning crewmembers while they are still alive.<br>
	<br>
	<p>The provided CLONEPOD SYSTEM will produce the desired clone.  Standard clone maturation times (With SPEEDCLONE technology) are roughly 90 seconds.
	The cloning pod may be unlocked early with any \[Medical Researcher\] ID after initial maturation is complete.</p><br>
	<i>Please note that resulting clones may have a small DEVELOPMENTAL DEFECT as a result of genetic drift.</i><br>
	<h4>Profile Management</h4>
	<p>The H-87 (as well as your station's standard genetics machine) can accept STANDARD DATA DISKETTES.
	These diskettes are used to transfer genetic information between machines and profiles.
	A load/save dialog will become available in each profile if a disk is inserted.</p><br>
	<i>A good diskette is a great way to counter aforementioned genetic drift!</i><br>
	<br>
	<font size=1>This technology produced under license from Thinktronic Systems, LTD.</font>"}

#undef CLONE_INITIAL_DAMAGE
#undef SPEAK
