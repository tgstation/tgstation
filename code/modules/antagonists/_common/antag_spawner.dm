/obj/item/antag_spawner
	throw_speed = 1
	throw_range = 5
	atom_size = WEIGHT_CLASS_TINY
	var/used = FALSE

/obj/item/antag_spawner/proc/spawn_antag(client/C, turf/T, kind = "", datum/mind/user)
	return

/obj/item/antag_spawner/proc/equip_antag(mob/target)
	return


///////////WIZARD

/obj/item/antag_spawner/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	var/polling = FALSE

/obj/item/antag_spawner/contract/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(polling)
		balloon_alert(user, "already calling an apprentice!")
		return FALSE

/obj/item/antag_spawner/contract/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ApprenticeContract", name)
		ui.open()

/obj/item/antag_spawner/contract/ui_state(mob/user)
	if(used)
		return GLOB.never_state
	return GLOB.default_state

/obj/item/antag_spawner/contract/ui_assets(mob/user)
	. = ..()
	return list(
		get_asset_datum(/datum/asset/simple/contracts),
	)

/obj/item/antag_spawner/contract/ui_act(action, list/params)
	. = ..()
	if(used || polling || !ishuman(usr))
		return
	INVOKE_ASYNC(src, .proc/poll_for_student, usr, params["school"])
	SStgui.close_uis(src)

/obj/item/antag_spawner/contract/proc/poll_for_student(mob/living/carbon/human/teacher, apprentice_school)
	balloon_alert(teacher, "contacting apprentice...")
	polling = TRUE
	var/list/candidates = poll_candidates_for_mob("Do you want to play as a wizard's [apprentice_school] apprentice?", ROLE_WIZARD, ROLE_WIZARD, 15 SECONDS, src)
	polling = FALSE
	if(!LAZYLEN(candidates))
		to_chat(teacher, span_warning("Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later."))
		return
	if(QDELETED(src) || used)
		return
	used = TRUE
	var/mob/dead/observer/student = pick(candidates)
	spawn_antag(student.client, get_turf(src), apprentice_school, teacher.mind)

/obj/item/antag_spawner/contract/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	new /obj/effect/particle_effect/smoke(T)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.safe_transfer_prefs_to(M, is_antag = TRUE)
	M.key = C.key
	var/datum/mind/app_mind = M.mind

	var/datum/antagonist/wizard/apprentice/app = new()
	app.master = user
	app.school = kind

	var/datum/antagonist/wizard/master_wizard = user.has_antag_datum(/datum/antagonist/wizard)
	if(master_wizard)
		if(!master_wizard.wiz_team)
			master_wizard.create_wiz_team()
		app.wiz_team = master_wizard.wiz_team
		master_wizard.wiz_team.add_member(app_mind)
	app_mind.add_antag_datum(app)
	app_mind.set_assigned_role(SSjob.GetJobType(/datum/job/wizard_apprentice))
	app_mind.special_role = ROLE_WIZARD_APPRENTICE
	SEND_SOUND(M, sound('sound/effects/magic.ogg'))

///////////BORGS AND OPERATIVES


/**
 * Device to request reinforcments from ghost pop
 */
/obj/item/antag_spawner/nuke_ops
	name = "syndicate operative beacon"
	desc = "A single-use beacon designed to quickly launch reinforcement operatives into the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/borg_to_spawn
	var/special_role_name = ROLE_NUCLEAR_OPERATIVE ///The name of the special role given to the recruit
	var/datum/outfit/syndicate/outfit = /datum/outfit/syndicate/no_crystals ///The applied outfit
	var/datum/antagonist/nukeop/antag_datum = /datum/antagonist/nukeop ///The antag datam applied
	/// Style used by the droppod
	var/pod_style = STYLE_SYNDICATE

/obj/item/antag_spawner/nuke_ops/proc/check_usability(mob/user)
	if(used)
		to_chat(user, span_warning("[src] is out of power!"))
		return FALSE
	if(!user.mind.has_antag_datum(/datum/antagonist/nukeop,TRUE))
		to_chat(user, span_danger("AUTHENTICATION FAILURE. ACCESS DENIED."))
		return FALSE
	return TRUE

/// Creates the drop pod the nukie will be dropped by
/obj/item/antag_spawner/nuke_ops/proc/setup_pod()
	var/obj/structure/closet/supplypod/pod = new(null, pod_style)
	pod.explosionSize = list(0,0,0,0)
	pod.bluespace = TRUE
	return pod

/obj/item/antag_spawner/nuke_ops/attack_self(mob/user)
	if(!(check_usability(user)))
		return

	to_chat(user, span_notice("You activate [src] and wait for confirmation."))
	var/list/nuke_candidates = poll_ghost_candidates("Do you want to play as a syndicate [borg_to_spawn ? "[lowertext(borg_to_spawn)] cyborg":"operative"]?", ROLE_OPERATIVE, ROLE_OPERATIVE, 150, POLL_IGNORE_SYNDICATE)
	if(LAZYLEN(nuke_candidates))
		if(QDELETED(src) || !check_usability(user))
			return
		used = TRUE
		var/mob/dead/observer/G = pick(nuke_candidates)
		spawn_antag(G.client, get_turf(src), "nukeop", user.mind)
		do_sparks(4, TRUE, src)
		qdel(src)
	else
		to_chat(user, span_warning("Unable to connect to Syndicate command. Please wait and try again later or use the beacon on your uplink to get your points refunded."))

/obj/item/antag_spawner/nuke_ops/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	var/mob/living/carbon/human/nukie = new()
	var/obj/structure/closet/supplypod/pod = setup_pod()
	C.prefs.safe_transfer_prefs_to(nukie, is_antag = TRUE)
	nukie.ckey = C.key
	var/datum/mind/op_mind = nukie.mind

	antag_datum = new()
	antag_datum.send_to_spawnpoint = FALSE
	antag_datum.nukeop_outfit = outfit

	var/datum/antagonist/nukeop/creator_op = user.has_antag_datum(/datum/antagonist/nukeop, TRUE)
	op_mind.add_antag_datum(antag_datum, creator_op ? creator_op.get_team() : null)
	op_mind.special_role = special_role_name
	nukie.forceMove(pod)
	new /obj/effect/pod_landingzone(get_turf(src), pod)

//////CLOWN OP
/obj/item/antag_spawner/nuke_ops/clown
	name = "clown operative beacon"
	desc = "A single-use beacon designed to quickly launch reinforcement clown operatives into the field."
	special_role_name = ROLE_CLOWN_OPERATIVE
	outfit = /datum/outfit/syndicate/clownop/no_crystals
	antag_datum = /datum/antagonist/nukeop/clownop
	pod_style = STYLE_HONK

//////SYNDICATE BORG
/obj/item/antag_spawner/nuke_ops/borg_tele
	name = "syndicate cyborg beacon"
	desc = "A single-use beacon designed to quickly launch reinforcement cyborgs into the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"

/obj/item/antag_spawner/nuke_ops/borg_tele/assault
	name = "syndicate assault cyborg beacon"
	borg_to_spawn = "Assault"

/obj/item/antag_spawner/nuke_ops/borg_tele/medical
	name = "syndicate medical beacon"
	borg_to_spawn = "Medical"

/obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	name = "syndicate saboteur beacon"
	borg_to_spawn = "Saboteur"

/obj/item/antag_spawner/nuke_ops/borg_tele/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	var/mob/living/silicon/robot/borg
	var/datum/antagonist/nukeop/creator_op = user.has_antag_datum(/datum/antagonist/nukeop,TRUE)
	if(!creator_op)
		return
	var/obj/structure/closet/supplypod/pod = setup_pod()
	switch(borg_to_spawn)
		if("Medical")
			borg = new /mob/living/silicon/robot/model/syndicate/medical()
		if("Saboteur")
			borg = new /mob/living/silicon/robot/model/syndicate/saboteur()
		else
			borg = new /mob/living/silicon/robot/model/syndicate() //Assault borg by default

	var/brainfirstname = pick(GLOB.first_names_male)
	if(prob(50))
		brainfirstname = pick(GLOB.first_names_female)
	var/brainopslastname = pick(GLOB.last_names)
	if(creator_op.nuke_team.syndicate_name)  //the brain inside the syndiborg has the same last name as the other ops.
		brainopslastname = creator_op.nuke_team.syndicate_name
	var/brainopsname = "[brainfirstname] [brainopslastname]"

	borg.mmi.name = "[initial(borg.mmi.name)]: [brainopsname]"
	borg.mmi.brain.name = "[brainopsname]'s brain"
	borg.mmi.brainmob.real_name = brainopsname
	borg.mmi.brainmob.name = brainopsname
	borg.real_name = borg.name

	borg.key = C.key

	var/datum/antagonist/nukeop/new_borg = new()
	new_borg.send_to_spawnpoint = FALSE
	borg.mind.add_antag_datum(new_borg,creator_op.nuke_team)
	borg.mind.special_role = "Syndicate Cyborg"
	borg.forceMove(pod)
	new /obj/effect/pod_landingzone(get_turf(src), pod)

///////////SLAUGHTER DEMON

/obj/item/antag_spawner/slaughter_demon //Warning edgiest item in the game
	name = "vial of blood"
	desc = "A magically infused bottle of blood, distilled from countless murder victims. Used in unholy rituals to attract horrifying creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

	var/shatter_msg = "<span class='notice'>You shatter the bottle, no turning back now!</span>"
	var/veil_msg = "<span class='warning'>You sense a dark presence lurking just beyond the veil...</span>"
	var/mob/living/demon_type = /mob/living/simple_animal/hostile/imp/slaughter
	var/antag_type = /datum/antagonist/slaughter


/obj/item/antag_spawner/slaughter_demon/attack_self(mob/user)
	if(!is_station_level(user.z))
		to_chat(user, span_warning("You should probably wait until you reach the station."))
		return
	if(used)
		return
	var/list/candidates = poll_candidates_for_mob("Do you want to play as a [initial(demon_type.name)]?", ROLE_ALIEN, ROLE_ALIEN, 5 SECONDS, src)
	if(LAZYLEN(candidates))
		if(used || QDELETED(src))
			return
		used = TRUE
		var/mob/dead/observer/C = pick(candidates)
		spawn_antag(C.client, get_turf(src), initial(demon_type.name),user.mind)
		to_chat(user, shatter_msg)
		to_chat(user, veil_msg)
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, TRUE)
		qdel(src)
	else
		to_chat(user, span_warning("You can't seem to work up the nerve to shatter the bottle! Perhaps you should try again later."))


/obj/item/antag_spawner/slaughter_demon/spawn_antag(client/C, turf/T, kind = "", datum/mind/user)
	var/obj/effect/dummy/phased_mob/holder = new /obj/effect/dummy/phased_mob(T)
	var/mob/living/simple_animal/hostile/imp/slaughter/S = new demon_type(holder)
	S.key = C.key
	S.mind.set_assigned_role(SSjob.GetJobType(/datum/job/slaughter_demon))
	S.mind.special_role = ROLE_SLAUGHTER_DEMON
	S.mind.add_antag_datum(antag_type)
	to_chat(S, "<B>You are currently not currently in the same plane of existence as the station. \
	Ctrl+Click a blood pool to manifest.</B>")

/obj/item/antag_spawner/slaughter_demon/laughter
	name = "vial of tickles"
	desc = "A magically infused bottle of clown love, distilled from countless hugging attacks. Used in funny rituals to attract adorable creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"
	color = "#FF69B4" // HOT PINK

	veil_msg = "<span class='warning'>You sense an adorable presence lurking just beyond the veil...</span>"
	demon_type = /mob/living/simple_animal/hostile/imp/slaughter/laughter
	antag_type = /datum/antagonist/slaughter/laughter
