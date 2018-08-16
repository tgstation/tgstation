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
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "cellconsole_1"
	circuit = /obj/item/circuitboard/cryopodcontrol
	density = FALSE
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE
	req_one_access = list(ACCESS_HEADS, ACCESS_ARMORY) //Heads of staff or the warden can go here to claim recover items from their department that people went were cryodormed with.
	var/mode = null

	//Used for logging people entering cryosleep and important items they are carrying.
	var/list/frozen_crew = list()
	var/list/frozen_items = list()

	var/storage_type = "crewmembers"
	var/storage_name = "Cryogenic Oversight Control"
	var/allow_items = TRUE

/obj/machinery/computer/cryopod/ui_interact(mob/user = usr)
	. = ..()

	user.set_machine(src)
	add_fingerprint(user)

	var/dat

	dat += "<hr/><br/><b>[storage_name]</b><br/>"
	dat += "<i>Welcome, [user.real_name].</i><br/><br/><hr/>"
	dat += "<a href='?src=[REF(src)];log=1'>View storage log</a>.<br>"
	if(allow_items)
		dat += "<a href='?src=[REF(src)];view=1'>View objects</a>.<br>"
		dat += "<a href='?src=[REF(src)];item=1'>Recover object</a>.<br>"
		dat += "<a href='?src=[REF(src)];allitems=1'>Recover all objects</a>.<br>"

	user << browse(dat, "window=cryopod_console")
	onclose(user, "cryopod_console")

/obj/machinery/computer/cryopod/Topic(href, href_list)
	if(..())
		return 1

	var/mob/user = usr

	add_fingerprint(user)

	if(href_list["log"])

		var/dat = "<b>Recently stored [storage_type]</b><br/><hr/><br/>"
		for(var/person in frozen_crew)
			dat += "[person]<br/>"
		dat += "<hr/>"

		user << browse(dat, "window=cryolog")

	if(href_list["view"])
		if(!allow_items) return

		var/dat = "<b>Recently stored objects</b><br/><hr/><br/>"
		for(var/obj/item/I in frozen_items)
			dat += "[I.name]<br/>"
		dat += "<hr/>"

		user << browse(dat, "window=cryoitems")

	else if(href_list["item"])
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			return
		if(!allow_items) return

		if(frozen_items.len == 0)
			to_chat(user, "<span class='notice'>There is nothing to recover from storage.</span>")
			return

		var/obj/item/I = input(user, "Please choose which object to retrieve.","Object recovery",null) as null|anything in frozen_items
		if(!I)
			return

		if(!(I in frozen_items))
			to_chat(user, "<span class='notice'>\The [I] is no longer in storage.</span>")
			return

		visible_message("<span class='notice'>The console beeps happily as it disgorges \the [I].</span>")

		I.forceMove(get_turf(src))
		frozen_items -= I

	else if(href_list["allitems"])
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			return
		if(!allow_items) return

		if(frozen_items.len == 0)
			to_chat(user, "<span class='notice'>There is nothing to recover from storage.</span>")
			return

		visible_message("<span class='notice'>The console beeps happily as it disgorges the desired objects.</span>")

		for(var/obj/item/I in frozen_items)
			I.forceMove(get_turf(src))
			frozen_items -= I

	updateUsrDialog()

/obj/item/circuitboard/cryopodcontrol
	name = "Circuit board (Cryogenic Oversight Console)"
	build_path = "/obj/machinery/computer/cryopod"


//Cryopods themselves.
/obj/machinery/cryopod
	name = "cryogenic freezer"
	desc = "Suited for Cyborgs and Humanoids, the pod is a safe place for personnel affected by the Space Sleep Disorder to get some rest."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "cryopod-open"
	density = TRUE
	anchored = TRUE
	state_open = TRUE

	var/on_store_message = "has entered long-term storage."
	var/on_store_name = "Cryogenic Oversight"

	// 15 minutes-ish safe period before being despawned.
	var/time_till_despawn = 15 * 600 // This is reduced by 90% if a player manually enters cryo
	var/despawn_world_time = null          // Used to keep track of the safe period.

	var/obj/machinery/computer/cryopod/control_computer
	var/last_no_computer_message = 0

	// These items are preserved when the process() despawn proc occurs.
	var/list/preserve_items = list(
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
		/obj/item/reagent_containers/hypospray/CMO,
		/obj/item/clothing/accessory/medal/gold/captain,
		/obj/item/clothing/gloves/krav_maga,
		/obj/item/nullrod,
		/obj/item/tank/jetpack,
		/obj/item/documents,
		/obj/item/nuke_core_container
	)
	// These items will NOT be preserved
	var/list/do_not_preserve_items = list (
		/obj/item/mmi/posibrain,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/gun/energy/kinetic_accelerator/cyborg,
		/obj/item/gun/energy/laser/cyborg
	)

/obj/machinery/cryopod/Initialize()
	update_icon()
	find_control_computer()
	return ..()

/obj/machinery/cryopod/proc/find_control_computer(urgent = 0,area/A)
	for(var/obj/machinery/computer/cryopod/C in A)
		control_computer = C
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
	icon_state = "cryopod-open"
	density = TRUE
	name = initial(name)

/obj/machinery/cryopod/container_resist(mob/living/user)
	visible_message("<span class='notice'>[occupant] emerges from [src]!</span>",
		"<span class='notice'>You climb out of [src]!</span>")
	open_machine()

/obj/machinery/cryopod/relaymove(mob/user)
	container_resist(user)

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

// This function can not be undone; do not call this unless you are sure
/obj/machinery/cryopod/proc/despawn_occupant()
	var/mob/living/mob_occupant = occupant
	var/list/target_candidates = list()

	if(istype(SSticker.mode, /datum/antagonist/cult))//thank
		if("sacrifice" in SSticker.mode.cult)
			for(var/mob/living/carbon/human/player in GLOB.player_list)
				if(player.mind && !player.mind.has_antag_datum(/datum/antagonist/cult) && !is_convertable_to_cult(player) && player.stat != DEAD)
					target_candidates += player.mind

			target_candidates -= mob_occupant.mind

			if(target_candidates.len == 0)
				message_admins("Cult Sacrifice: Could not find unconvertable target, checking for convertable target.")
				for(var/mob/living/carbon/human/player in GLOB.player_list)
					if(player.mind && !player.mind.has_antag_datum(/datum/antagonist/cult) && player.stat != DEAD)
						target_candidates += player.mind

			listclearnulls(target_candidates)
			if(LAZYLEN(target_candidates))
				var/datum/objective/sacrifice/sac_objective = locate() in GLOB.objectives
				sac_objective.target = pick(target_candidates)
				sac_objective.update_explanation_text()

				var/datum/job/sacjob = SSjob.GetJob(sac_objective.target.assigned_role)
				var/datum/preferences/sacface = sac_objective.target.current.client.prefs
				var/icon/reshape = get_flat_human_icon(null, sacjob, sacface)
				reshape.Shift(SOUTH, 4)
				reshape.Shift(EAST, 1)
				reshape.Crop(7,4,26,31)
				reshape.Crop(-5,-3,26,30)
				sac_objective.sac_image = reshape

				for(var/datum/mind/H in SSticker.mode.cult)
					if(H.current)
						to_chat(H.current, "<span class='danger'>Nar'Sie</span> murmurs, <span class='cultlarge'>[occupant] is beyond your reach. Sacrifice [sac_objective.target.current] instead...</span></span>")

			else
				message_admins("Cult Sacrifice: Could not find unconvertable or convertable target after cryopod. WELP!")

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
						O.owner.objectives -= O
						qdel(O)

	if(mob_occupant.mind && mob_occupant.mind.assigned_role)
		//Handle job slot/tater cleanup.
		var/job = mob_occupant.mind.assigned_role
		SSjob.FreeRole(job)
		if(mob_occupant.mind.objectives.len)
			mob_occupant.mind.objectives.Cut()
			mob_occupant.mind.special_role = null

	// Delete them from datacore.

	var/announce_rank = null
	for(var/datum/data/record/R in GLOB.data_core.medical)
		if((R.fields["name"] == mob_occupant.real_name))
			qdel(R)
	for(var/datum/data/record/T in GLOB.data_core.security)
		if((T.fields["name"] == mob_occupant.real_name))
			qdel(T)
	for(var/datum/data/record/G in GLOB.data_core.general)
		if((G.fields["name"] == mob_occupant.real_name))
			announce_rank = G.fields["rank"]
			qdel(G)

	for(var/obj/machinery/computer/cloning/cloner in world)
		for(var/datum/data/record/R in cloner.records)
			if(R.fields["name"] == mob_occupant.real_name)
				cloner.records.Remove(R)

	//Make an announcement and log the person entering storage.
	if(control_computer)
		control_computer.frozen_crew += "[mob_occupant.real_name]"

	if(GLOB.announcement_systems.len)
		var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
		announcer.announce("CRYOSTORAGE", mob_occupant.real_name, announce_rank, list())
		visible_message("<span class='notice'>\The [src] hums and hisses as it moves [mob_occupant.real_name] into storage.</span>")


	for(var/obj/item/W in mob_occupant.GetAllContents())
		if(W.loc.loc && (( W.loc.loc == loc ) || (W.loc.loc == control_computer)))
			continue//means we already moved whatever this thing was in
			//I'm a professional, okay
		for(var/T in preserve_items)
			if(istype(W, T))
				if(control_computer && control_computer.allow_items)
					control_computer.frozen_items += W
					mob_occupant.transferItemToLoc(W, control_computer, TRUE)
				else
					mob_occupant.transferItemToLoc(W, loc, TRUE)

	for(var/obj/item/W in mob_occupant.GetAllContents())
		qdel(W)//because we moved all items to preserve away
		//and yes, this totally deletes their bodyparts one by one, I just couldn't bother

	if(iscyborg(mob_occupant))
		var/mob/living/silicon/robot/R = occupant
		if(!istype(R)) return ..()

		R.contents -= R.mmi
		qdel(R.mmi)

	// Ghost and delete the mob.
	if(!mob_occupant.get_ghost(1))
		if(world.time < 30 * 600)//before the 30 minute mark
			mob_occupant.ghostize(0) // Players despawned too early may not re-enter the game
		else
			mob_occupant.ghostize(1)
	QDEL_NULL(occupant)
	open_machine()
	name = initial(name)

/obj/machinery/cryopod/MouseDrop_T(mob/living/target, mob/user)
	if(!istype(target) || user.incapacitated() || !target.Adjacent(user) || !Adjacent(user) || !ismob(target) || (!ishuman(user) && !iscyborg(user)) || !istype(user.loc, /turf) || target.buckled)
		return

	if(occupant)
		to_chat(user, "<span class='boldnotice'>The cryo pod is already occupied!</span>")
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

	if(target == user && world.time - target.client.cryo_warned > 5 * 600)//if we haven't warned them in the last 5 minutes
		var/caught = FALSE
		if(target.mind.assigned_role in GLOB.command_positions)
			alert("<span class='userdanger'>You're a Head of Staff![generic_plsnoleave_message] Be sure to put your locker items back into your locker!</span>")
			caught = TRUE
		if(iscultist(target) || is_servant_of_ratvar(target))
			to_chat(target, "<span class='userdanger'>You're a Cultist![generic_plsnoleave_message]</span>")
			caught = TRUE
		if(istype(SSticker.mode, /datum/antagonist/blob))
			if(target.mind in GLOB.overminds)
				alert("<span class='userdanger'>You're a Blob![generic_plsnoleave_message]</span>")
				caught = TRUE
		if(is_devil(target))
			alert("<span class='userdanger'>You're a Devil![generic_plsnoleave_message]</span>")
			caught = TRUE
		if(istype(SSticker.mode, /datum/antagonist/rev))
			if(target.mind.has_antag_datum(/datum/antagonist/rev/head))
				alert("<span class='userdanger'>You're a Head Revolutionary![generic_plsnoleave_message]</span>")
				caught = TRUE
			else if(target.mind.has_antag_datum(/datum/antagonist/rev))
				alert("<span class='userdanger'>You're a Revolutionary![generic_plsnoleave_message]</span>")
				caught = TRUE

		if(caught)
			target.client.cryo_warned = world.time
			return

	if(!Adjacent(user))
		return

	if(target == user)
		visible_message("[user] starts climbing into the cryo pod.")
	else
		visible_message("[user] starts putting [target] into the cryo pod.")

	if(occupant)
		to_chat(user, "<span class='boldnotice'>\The [src] is in use.</span>")
		return

	close_machine(target)

	to_chat(target, "<span class='boldnotice'>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</span>")
	name = "[name] ([occupant.name])"
	log_admin("<span class='notice'>[key_name(target)] entered a stasis pod.</span>")
	message_admins("[key_name_admin(target)] entered a stasis pod. (<A HREF='?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
	add_fingerprint(target)

//Attacks/effects.
/obj/machinery/cryopod/blob_act()
	return //Sorta gamey, but we don't really want these to be destroyed.
