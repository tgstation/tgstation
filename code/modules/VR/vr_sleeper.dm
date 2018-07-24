

//Glorified teleporter that puts you in a new human body.
// it's """VR"""
/obj/machinery/vr_sleeper
	name = "virtual reality sleeper"
	desc = "A sleeper modified to alter the subconscious state of the user, allowing them to visit virtual worlds."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	state_open = TRUE
	occupant_typecache = list(/mob/living/carbon/human) // turned into typecache in Initialize
	circuit = /obj/item/circuitboard/machine/vr_sleeper
	var/you_die_in_the_game_you_die_for_real = FALSE
	var/datum/effect_system/spark_spread/sparks
	var/mob/living/carbon/human/virtual_reality/vr_human
	var/vr_category = "default" //Specific category of spawn points to pick from
	var/allow_creating_vr_humans = TRUE //So you can have vr_sleepers that always spawn you as a specific person or 1 life/chance vr games
	var/only_current_user_can_interact = FALSE

/obj/machinery/vr_sleeper/Initialize()
	. = ..()
	sparks = new /datum/effect_system/spark_spread()
	sparks.set_up(2,0)
	sparks.attach(src)
	update_icon()

/obj/machinery/vr_sleeper/attackby(obj/item/I, mob/user, params)
	if(!state_open && !occupant)
		if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_pry_open(I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/vr_sleeper/relaymove(mob/user)
	open_machine()

/obj/machinery/vr_sleeper/container_resist(mob/living/user)
	open_machine()

/obj/machinery/vr_sleeper/Destroy()
	open_machine()
	cleanup_vr_human()
	QDEL_NULL(sparks)
	return ..()

/obj/machinery/vr_sleeper/hugbox
	desc = "A sleeper modified to alter the subconscious state of the user, allowing them to visit virtual worlds. Seems slightly more secure."
	flags_1 = NODECONSTRUCT_1
	only_current_user_can_interact = TRUE

/obj/machinery/vr_sleeper/hugbox/emag_act(mob/user)
	return

/obj/machinery/vr_sleeper/emag_act(mob/user)
	you_die_in_the_game_you_die_for_real = TRUE
	sparks.start()
	addtimer(CALLBACK(src, .proc/emagNotify), 150)

/obj/machinery/vr_sleeper/update_icon()
	icon_state = "[initial(icon_state)][state_open ? "-open" : ""]"

/obj/machinery/vr_sleeper/open_machine()
	if(!state_open)
		if(vr_human)
			vr_human.revert_to_reality(FALSE)
		if(occupant)
			SStgui.close_user_uis(occupant, src)
		..()

/obj/machinery/vr_sleeper/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	close_machine(target)

/obj/machinery/vr_sleeper/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "vr_sleeper", "VR Sleeper", 475, 340, master_ui, state)
		ui.open()

/obj/machinery/vr_sleeper/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("vr_connect")
			var/mob/living/carbon/human/human_occupant = occupant
			if(human_occupant && human_occupant.mind && usr == occupant)
				to_chat(occupant, "<span class='warning'>Transferring to virtual reality...</span>")
				if(vr_human && vr_human.stat == CONSCIOUS && !vr_human.real_mind)
					SStgui.close_user_uis(occupant, src)
					vr_human.real_mind = human_occupant.mind
					vr_human.ckey = human_occupant.ckey
					to_chat(vr_human, "<span class='notice'>Transfer successful! you are now playing as [vr_human] in VR!</span>")
				else
					if(allow_creating_vr_humans)
						to_chat(occupant, "<span class='warning'>Virtual avatar not found, attempting to create one...</span>")
						var/obj/effect/landmark/vr_spawn/V = get_vr_spawnpoint()
						var/turf/T = get_turf(V)
						if(T)
							SStgui.close_user_uis(occupant, src)
							build_virtual_human(occupant, T, V.vr_outfit)
							to_chat(vr_human, "<span class='notice'>Transfer successful! you are now playing as [vr_human] in VR!</span>")
						else
							to_chat(occupant, "<span class='warning'>Virtual world misconfigured, aborting transfer</span>")
					else
						to_chat(occupant, "<span class='warning'>The virtual world does not support the creation of new virtual avatars, aborting transfer</span>")
			. = TRUE
		if("delete_avatar")
			if(!occupant || usr == occupant)
				if(vr_human)
					cleanup_vr_human()
			else
				to_chat(usr, "<span class='warning'>The VR Sleeper's safeties prevent you from doing that.</span>")
			. = TRUE
		if("toggle_open")
			if(state_open)
				close_machine()
			else if ((!occupant || usr == occupant) || !only_current_user_can_interact)
				open_machine()
			. = TRUE

/obj/machinery/vr_sleeper/ui_data(mob/user)
	var/list/data = list()
	if(vr_human && !QDELETED(vr_human))
		data["can_delete_avatar"] = TRUE
		var/status
		switch(vr_human.stat)
			if(CONSCIOUS)
				status = "Conscious"
			if(DEAD)
				status = "Dead"
			if(UNCONSCIOUS)
				status = "Unconscious"
			if(SOFT_CRIT)
				status = "Barely Conscious"
		data["vr_avatar"] = list("name" = vr_human.name, "status" = status, "health" = vr_human.health, "maxhealth" = vr_human.maxHealth)
	data["toggle_open"] = state_open
	data["emagged"] = you_die_in_the_game_you_die_for_real
	data["isoccupant"] = (user == occupant)
	return data

/obj/machinery/vr_sleeper/proc/get_vr_spawnpoint() //proc so it can be overridden for team games or something
	return safepick(GLOB.vr_spawnpoints[vr_category])

/obj/machinery/vr_sleeper/proc/build_spawnpoints() // used to rebuild the list for admins if need be
	GLOB.vr_spawnpoints = list()
	for(var/obj/effect/landmark/vr_spawn/V in GLOB.landmarks_list)
		GLOB.vr_spawnpoints[V.vr_category] = V

/obj/machinery/vr_sleeper/proc/build_virtual_human(mob/living/carbon/human/H, location, var/datum/outfit/outfit, transfer = TRUE)
	if(H)
		cleanup_vr_human()
		vr_human = new /mob/living/carbon/human/virtual_reality(location)
		vr_human.mind_initialize()
		vr_human.vr_sleeper = src
		vr_human.real_mind = H.mind
		H.dna.transfer_identity(vr_human)
		vr_human.name = H.name
		vr_human.real_name = H.real_name
		vr_human.socks = H.socks
		vr_human.undershirt = H.undershirt
		vr_human.underwear = H.underwear
		vr_human.updateappearance(TRUE, TRUE, TRUE)
		if(outfit)
			var/datum/outfit/O = new outfit()
			O.equip(vr_human)
		if(transfer && H.mind)
			SStgui.close_user_uis(H, src)
			vr_human.ckey = H.ckey

/obj/machinery/vr_sleeper/proc/cleanup_vr_human()
	if(vr_human)
		vr_human.vr_sleeper = null // Prevents race condition where a new human could get created out of order and set to null.
		QDEL_NULL(vr_human)

/obj/machinery/vr_sleeper/proc/emagNotify()
	if(vr_human)
		vr_human.Dizzy(10)

/obj/effect/landmark/vr_spawn //places you can spawn in VR, auto selected by the vr_sleeper during get_vr_spawnpoint()
	var/vr_category = "default" //So we can have specific sleepers, eg: "Basketball VR Sleeper", etc.
	var/vr_outfit = /datum/outfit/vr

/obj/effect/landmark/vr_spawn/Initialize()
	. = ..()
	LAZYADD(GLOB.vr_spawnpoints[vr_category], src)

/obj/effect/landmark/vr_spawn/Destroy()
	LAZYREMOVE(GLOB.vr_spawnpoints[vr_category], src)
	return ..()

/obj/effect/landmark/vr_spawn/team_1
	vr_category = "team_1"

/obj/effect/landmark/vr_spawn/team_2
	vr_category = "team_2"

/obj/effect/landmark/vr_spawn/admin
	vr_category = "event"

/obj/effect/landmark/vr_spawn/syndicate // Multiple missions will use syndicate gear
	vr_outfit = /datum/outfit/vr/syndicate

/obj/effect/vr_clean_master // Will keep VR areas that have this relatively clean.
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	color = "#00FF00"
	invisibility = INVISIBILITY_ABSTRACT
	var/area/vr_area

/obj/effect/vr_clean_master/Initialize()
	. = ..()
	vr_area = get_area(src)
	addtimer(CALLBACK(src, .proc/clean_up), 3 MINUTES)

/obj/effect/vr_clean_master/proc/clean_up()
	if (vr_area)
		for (var/obj/item/ammo_casing/casing in vr_area)
			qdel(casing)
		for(var/obj/effect/decal/cleanable/C in vr_area)
			qdel(C)
		for (var/mob/living/carbon/human/virtual_reality/H in vr_area)
			if (H.stat == DEAD && !H.vr_sleeper && !H.real_mind)
				qdel(H)
		addtimer(CALLBACK(src, .proc/clean_up), 3 MINUTES)