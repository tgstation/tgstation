/client
	var/cryo_warned = 0

/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */

//Main cryopod console.

/obj/machinery/computer/cryopod
	name = "cryogenic oversight console"
	desc = "An interface between crew and the cryogenic storage oversight systems."
	icon = 'modular_skyrat/modules/cryosleep/icons/cryogenics.dmi'
	icon_state = "cellconsole_1"
	circuit = /obj/item/circuitboard/cryopodcontrol
	density = FALSE
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE
	req_one_access = list(ACCESS_HEADS, ACCESS_ARMORY) //Heads of staff or the warden can go here to claim recover items from their department that people went were cryodormed with.

	var/menu = 1 //Which menu screen to display

	//Used for logging people entering cryosleep and important items they are carrying.
	var/list/frozen_crew = list()
	var/list/frozen_items = list()

	// Used for containing rare items traitors need to steal, so it's not
	// game-over if they get iced
	var/list/objective_items = list()
	// A cache of theft datums so you don't have to re-create them for
	// each item check
	var/list/theft_cache = list()

	var/allow_items = TRUE

/obj/machinery/computer/cryopod/attack_ai()
	attack_hand()

/obj/machinery/computer/cryopod/ui_interact(mob/user = usr)
	. = ..()
	user.set_machine(src)
	add_fingerprint(user)

	var/dat = ""

	dat += "<h2>Welcome, [user.real_name].</h2><hr/>"
	dat += "<br><br>"

	switch(src.menu)
		if(1)
			dat += "<a href='byond://?src=[REF(src)];menu=2'>View crew storage log</a><br><br>"
			if(allow_items)
				dat += "<a href='byond://?src=[REF(src)];menu=3'>View objects storage log</a><br><br>"
				dat += "<a href='byond://?src=[REF(src)];item=1'>Recover object</a><br><br>"
				dat += "<a href='byond://?src=[REF(src)];allitems=1'>Recover all objects</a><br>"
		if(2)
			dat += "<a href='byond://?src=[REF(src)];menu=1'><< Back</a><br><br>"
			dat += "<h3>Recently stored Crew</h3><br/><hr/><br/>"
			if(!frozen_crew.len)
				dat += "There has been no storage usage at this terminal.<br/>"
			else
				for(var/person in frozen_crew)
					dat += "[person]<br/>"
			dat += "<hr/>"
		if(3)
			dat += "<a href='byond://?src=[REF(src)];menu=1'><< Back</a><br><br>"
			dat += "<h3>Recently stored objects</h3><br/><hr/><br/>"
			if(!frozen_items.len)
				dat += "There has been no storage usage at this terminal.<br/>"
			else
				for(var/obj/item/I in frozen_items)
					dat += "[I.name]<br/>"
			dat += "<hr/>"

	var/datum/browser/popup = new(user, "cryopod_console", "Cryogenic System Control")
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/cryopod/Topic(href, href_list)
	if(..())
		return TRUE

	var/mob/user = usr

	add_fingerprint(user)

	if(href_list["item"])
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			updateUsrDialog()
			return
		if(!allow_items) return

		if(frozen_items.len == 0)
			to_chat(user, "<span class='notice'>There is nothing to recover from storage.</span>")
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			updateUsrDialog()
			return

		var/obj/item/I = input(user, "Please choose which object to retrieve.","Object recovery",null) as null|anything in frozen_items
		playsound(src, "terminal_type", 25, 0)
		if(!I)
			return

		if(!(I in frozen_items))
			to_chat(user, "<span class='notice'>\The [I] is no longer in storage.</span>")
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			updateUsrDialog()
			return

		visible_message("<span class='notice'>The console beeps happily as it disgorges \the [I].</span>")
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

		I.forceMove(drop_location())
		if(user && Adjacent(user) && user.can_hold_items())
			user.put_in_hands(I)
		frozen_items -= I
		updateUsrDialog()

	else if(href_list["allitems"])
		playsound(src, "terminal_type", 25, 0)
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			updateUsrDialog()
			return
		if(!allow_items)
			return

		if(frozen_items.len == 0)
			to_chat(user, "<span class='notice'>There is nothing to recover from storage.</span>")
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			return

		visible_message("<span class='notice'>The console beeps happily as it disgorges the desired objects.</span>")
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

		for(var/obj/item/I in frozen_items)
			I.forceMove(drop_location())
			frozen_items -= I
			updateUsrDialog()

	else if (href_list["menu"])
		src.menu = text2num(href_list["menu"])
		playsound(src, "terminal_type", 25, 0)
		updateUsrDialog()

	ui_interact(usr)
	updateUsrDialog()
	return

/obj/item/circuitboard/cryopodcontrol
	name = "Circuit board (Cryogenic Oversight Console)"
	build_path = "/obj/machinery/computer/cryopod"

/obj/machinery/computer/cryopod/contents_explosion()
	return

//Cryopods themselves.
/obj/machinery/cryopod
	name = "cryogenic freezer"
	desc = "Suited for Cyborgs and Humanoids, the pod is a safe place for personnel affected by the Space Sleep Disorder to get some rest."
	icon = 'modular_skyrat/modules/cryosleep/icons/cryogenics.dmi'
	icon_state = "cryopod-open"
	density = TRUE
	anchored = TRUE
	state_open = TRUE

	var/on_store_message = "has entered long-term storage."
	var/on_store_name = "Cryogenic Oversight"

	// 15 minutes-ish safe period before being despawned.
	var/time_till_despawn = 15 * 600 // This is reduced by 90% if a player manually enters cryo
	var/despawn_world_time          // Used to keep track of the safe period.

	var/obj/machinery/computer/cryopod/control_computer
	var/last_no_computer_message = 0

	// These items are preserved when the process() despawn proc occurs.
	var/static/list/preserve_items = typecacheof(list(
		/obj/item/hand_tele,
		/obj/item/card/id/captains_spare,
		/obj/item/aicard,
		/obj/item/mmi,
		/obj/item/paicard,
		/obj/item/gun,
		/obj/item/pinpointer,
		/obj/item/clothing/shoes/magboots,
		/obj/item/areaeditor/blueprints,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/armor,
		/obj/item/defibrillator/compact,
		/obj/item/reagent_containers/hypospray/cmo,
		/obj/item/clothing/accessory/medal/gold/captain,
		/obj/item/clothing/gloves/krav_maga,
		/obj/item/nullrod,
		/obj/item/tank/jetpack,
		/obj/item/documents,
		/obj/item/nuke_core_container
	))
	// These items will NOT be preserved
	var/static/list/do_not_preserve_items = typecacheof(list(
		/obj/item/mmi/posibrain,
		/obj/item/gun/energy/laser/mounted,
		/obj/item/gun/energy/e_gun/advtaser/mounted,
		/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/gun/energy/e_gun/advtaser/cyborg,
		/obj/item/gun/energy/printer,
		/obj/item/gun/energy/kinetic_accelerator/cyborg,
		/obj/item/gun/energy/laser/cyborg
	))

/obj/machinery/cryopod/Initialize(mapload)
	. = ..()
	update_icon()
	find_control_computer(mapload)

/obj/machinery/cryopod/proc/find_control_computer(urgent = FALSE)
	for(var/obj/machinery/computer/cryopod/C in get_area(src))
		control_computer = C
		if(C)
			return C
		break

	// Don't send messages unless we *need* the computer, and less than five minutes have passed since last time we messaged
	if(!control_computer && urgent && last_no_computer_message + 5*60*10 < world.time)
		log_admin("Cryopod in [get_area(src)] could not find control computer!")
		message_admins("Cryopod in [get_area(src)] could not find control computer!")
		last_no_computer_message = world.time

	return control_computer != null

/obj/machinery/cryopod/close_machine(mob/user)
	if(!control_computer)
		find_control_computer(TRUE)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		START_PROCESSING(SSmachines, src)
		..(user)
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(occupant, "<span class='boldnotice'>You feel cool air surround you. You go numb as your senses turn inward.</span>")
		if(mob_occupant.client)//if they're logged in
			despawn_world_time = world.time + (time_till_despawn * 0.1)
		else
			despawn_world_time = world.time + time_till_despawn
	icon_state = "cryopod"

/obj/machinery/cryopod/open_machine()
	..()
	STOP_PROCESSING(SSmachines, src)
	icon_state = "cryopod-open"
	density = TRUE
	name = initial(name)

/obj/machinery/cryopod/container_resist_act(mob/living/user)
	visible_message("<span class='notice'>[occupant] emerges from [src]!</span>",
		"<span class='notice'>You climb out of [src]!</span>")
	open_machine()

/obj/machinery/cryopod/relaymove(mob/user)
	container_resist_act(user)

/obj/machinery/cryopod/process()
	if(!occupant)
		return

	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		// Eject dead people
		if(mob_occupant.stat == DEAD)
			open_machine()

		if(!(world.time > despawn_world_time + 100))//+ 10 seconds
			return

		if(!mob_occupant.client && mob_occupant.stat < 2) //Occupant is living and has no client.
			if(!control_computer)
				find_control_computer(urgent = TRUE)//better hope you found it this time

			despawn_occupant()

#define CRYO_DESTROY 0
#define CRYO_PRESERVE 1
#define CRYO_OBJECTIVE 2
#define CRYO_IGNORE 3
#define CRYO_DESTROY_LATER 4

/obj/machinery/cryopod/proc/should_preserve_item(obj/item/I)
	for(var/datum/objective_item/steal/T in control_computer.theft_cache)
		if(istype(I, T.targetitem) && T.check_special_completion(I))
			return CRYO_OBJECTIVE
	if(preserve_items[I] && !do_not_preserve_items[I])
		return CRYO_PRESERVE
	return CRYO_DESTROY

// This function can not be undone; do not call this unless you are sure
/obj/machinery/cryopod/proc/despawn_occupant()
	if(!control_computer)
		find_control_computer()

	var/mob/living/mob_occupant = occupant
	var/list/obj/item/cryo_items = list()

	//Handle Borg stuff first
	if(iscyborg(mob_occupant))
		var/mob/living/silicon/robot/R = mob_occupant
		if(R.mmi?.brain)
			cryo_items[R.mmi] = CRYO_DESTROY_LATER
			cryo_items[R.mmi.brain] = CRYO_DESTROY_LATER
		for(var/obj/item/I in R.module) // the tools the borg has; metal, glass, guns etc
			for(var/obj/item/O in I) // the things inside the tools, if anything; mainly for janiborg trash bags
				cryo_items[O] = should_preserve_item(O)
				O.forceMove(src)
			R.module.remove_module(I, TRUE)	//delete the module itself so it doesn't transfer over.

	//Drop all items into the pod.
	for(var/obj/item/I in mob_occupant)
		if(cryo_items[I] == CRYO_IGNORE || cryo_items[I] ==CRYO_DESTROY_LATER)
			continue
		cryo_items[I] = should_preserve_item(I)
		mob_occupant.transferItemToLoc(I, src, TRUE)
		if(I.contents.len) //Make sure we catch anything not handled by qdel() on the items.
			if(cryo_items[I] != CRYO_DESTROY) // Don't remove the contents of things that need preservation
				continue
			for(var/obj/item/O in I.contents)
				cryo_items[O] = should_preserve_item(O)
				O.forceMove(src)

	for(var/A in cryo_items)
		var/obj/item/I = A
		if(QDELETED(I)) //edge cases and DROPDEL.
			continue
		var/preserve = cryo_items[I]
		if(preserve == CRYO_DESTROY_LATER)
			continue
		if(preserve != CRYO_IGNORE)
			if(preserve == CRYO_DESTROY)
				qdel(I)
			else if(control_computer?.allow_items)
				control_computer.frozen_items += I
				if(preserve == CRYO_OBJECTIVE)
					control_computer.objective_items += I
				I.moveToNullspace()
			else
				I.forceMove(loc)
		cryo_items -= I

	/*
	//Update any existing objectives involving this mob.
	for(var/datum/objective/O in GLOB.objectives)
		// We don't want revs to get objectives that aren't for heads of staff. Letting
		// them win or lose based on cryo is silly so we remove the objective.
		if(istype(O,/datum/objective/mutiny) && O.target == mob_occupant.mind)
			qdel(O)
		else if(O.target && istype(O.target, /datum/mind))
			if(O.target == mob_occupant.mind)
				if(O.owner && O.owner.current)
					to_chat(O.owner.current, "<BR><span class='userdanger'>You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")]. Objectives updated!</span>")
				O.target = null
				spawn(10) //This should ideally fire after the occupant is deleted.
					if(!O)
						return
					O.find_target()
					O.update_explanation_text()
					if(!(O.target))
						qdel(O)*/

	if(mob_occupant.mind)
		//Handle job slot/tater cleanup.
		if(mob_occupant.mind.assigned_role)
			var/datum/job/JOB = SSjob.GetJob(mob_occupant.mind.assigned_role)
			if(JOB)
				JOB.current_positions = max(0, JOB.current_positions - 1)
		mob_occupant.mind.special_role = null

	// Delete them from datacore.

	var/announce_rank = null
	for(var/datum/data/record/R in GLOB.data_core.medical)
		if((R.fields["name"] == mob_occupant.real_name))
			qdel(R)
			break
	for(var/datum/data/record/T in GLOB.data_core.security)
		if((T.fields["name"] == mob_occupant.real_name))
			qdel(T)
			break
	for(var/datum/data/record/G in GLOB.data_core.general)
		if((G.fields["name"] == mob_occupant.real_name))
			announce_rank = G.fields["rank"]
			qdel(G)
			break

	//Make an announcement and log the person entering storage.
	if(control_computer)
		control_computer.frozen_crew += "[mob_occupant.real_name]"

	if(GLOB.announcement_systems.len)
		var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
		announcer.announce("CRYOSTORAGE", mob_occupant.real_name, announce_rank, list())
		visible_message("<span class='notice'>\The [src] hums and hisses as it moves [mob_occupant.real_name] into storage.</span>")

	// Ghost and delete the mob.
	if(!mob_occupant.get_ghost(TRUE))
		mob_occupant.ghostize(FALSE)

	QDEL_NULL(occupant)
	for(var/I in cryo_items) //only "CRYO_DESTROY_LATER" atoms are left)
		var/atom/A = I
		if(!QDELETED(A))
			qdel(A)
	open_machine()
	name = initial(name)

#undef CRYO_DESTROY
#undef CRYO_PRESERVE
#undef CRYO_OBJECTIVE
#undef CRYO_IGNORE
#undef CRYO_DESTROY_LATER

/obj/machinery/cryopod/MouseDrop_T(mob/living/target, mob/user)
	if(!istype(target) || user.incapacitated() || !target.Adjacent(user) || !Adjacent(user) || !ismob(target) || (!ishuman(user) && !iscyborg(user)) || !istype(user.loc, /turf) || target.buckled)
		return
	if(occupant)
		to_chat(user, "<span class='warning'>The cryo pod is already occupied!</span>")
		return
	if(target.stat == DEAD)
		to_chat(user, "<span class='notice'>Dead people can not be put into cryo.</span>")
		return
	if(target.client && user != target)
		if(iscyborg(target))
			to_chat(user, "<span class='danger'>You can't put [target] into [src]. They're online.</span>")
		else
			to_chat(user, "<span class='danger'>You can't put [target] into [src]. They're conscious.</span>")
		return
	else if(target.client)
		if(alert(target,"Would you like to enter cryosleep?",,"Yes","No") == "No")
			return
	var/generic_plsnoleave_message = " Please adminhelp before leaving the round, even if there are no administrators online!"
	if(target == user && world.time - target.client.cryo_warned > 5 MINUTES)//if we haven't warned them in the last 5 minutes
		var/list/caught_string
		var/addendum = ""
		if(target.mind.assigned_role in GLOB.command_positions)
			LAZYADD(caught_string, "Head of Staff")
			addendum = " Be sure to put your locker items back into your locker!"
		if(iscultist(target))
			LAZYADD(caught_string, "Cultist")
		if(target.mind.has_antag_datum(/datum/antagonist/gang))
			LAZYADD(caught_string, "Gangster")
		if(target.mind.has_antag_datum(/datum/antagonist/rev/head))
			LAZYADD(caught_string, "Head Revolutionary")
		if(target.mind.has_antag_datum(/datum/antagonist/rev))
			LAZYADD(caught_string, "Revolutionary")
		if(caught_string)
			alert(target, "You're a [english_list(caught_string)]![generic_plsnoleave_message][addendum]")
			target.client.cryo_warned = world.time
			return
	if(!target || user.incapacitated() || !target.Adjacent(user) || !Adjacent(user) || (!ishuman(user) && !iscyborg(user)) || !istype(user.loc, /turf) || target.buckled)
		return
		//rerun the checks in case of shenanigans
	if(occupant)
		to_chat(user, "<span class='warning'>\The [src] is in use.</span>")
		return
	if(target == user)
		visible_message("<span class='notice'>[user] starts climbing into the cryo pod.</span>")
	else
		visible_message("<span class='notice'>[user] starts putting [target] into the cryo pod.</span>")
	if(do_after(user, 3 SECONDS, target = target))
		if(occupant)
			return
		close_machine(target)
		to_chat(target, "<span class='boldnotice'>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</span>")
		name = "[name] ([occupant.name])"
		if(target == user)
			log_admin("<span class='notice'>[key_name(target)] entered a stasis pod.</span>")
			message_admins("[key_name_admin(target)] entered a stasis pod. (<A HREF='?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
		else
			log_admin("<span class='notice'>[key_name(user)] put [key_name(target)] inside a stasis pod.</span>")
			message_admins("[key_name_admin(user)] put [key_name_admin(target)] inside a stasis pod. (<A HREF='?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
		add_fingerprint(target)

//Attacks/effects.
/obj/machinery/cryopod/blob_act()
	return //Sorta gamey, but we don't really want these to be destroyed.
