//Xenobio control console
/mob/camera/aiEye/remote/xenobio
	visible_icon = 1
	icon = 'icons/obj/abductor.dmi'
	icon_state = "camera_target"
	var/allowed_area = null

/mob/camera/aiEye/remote/xenobio/Initialize()
	var/area/A = get_area(loc)
	allowed_area = A.name
	. = ..()

/mob/camera/aiEye/remote/xenobio/setLoc(var/t)
	var/area/new_area = get_area(t)
	if(new_area && new_area.name == allowed_area || new_area && new_area.xenobiology_compatible)
		return ..()
	else
		return

/obj/machinery/computer/camera_advanced/xenobio
	name = "Slime management console"
	desc = "A computer used for remotely handling slimes."
	networks = list("ss13")
	circuit = /obj/item/circuitboard/computer/xenobiology
	var/datum/action/innate/slime_place/slime_place_action
	var/datum/action/innate/slime_pick_up/slime_up_action
	var/datum/action/innate/feed_slime/feed_slime_action
	var/datum/action/innate/monkey_recycle/monkey_recycle_action
	var/datum/action/innate/slime_scan/scan_action
	var/datum/action/innate/feed_potion/potion_action

	var/datum/component/redirect/listener

	var/list/stored_slimes
	var/obj/item/slimepotion/slime/current_potion
	var/max_slimes = 5
	var/monkeys = 0

	icon_screen = "slime_comp"
	icon_keyboard = "rd_key"

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/camera_advanced/xenobio/Initialize()
	. = ..()
	slime_place_action = new
	slime_up_action = new
	feed_slime_action = new
	monkey_recycle_action = new
	scan_action = new
	potion_action = new
	stored_slimes = list()
	listener = AddComponent(/datum/component/redirect, list(COMSIG_ATOM_CONTENTS_DEL = CALLBACK(src, .proc/on_contents_del)))

/obj/machinery/computer/camera_advanced/xenobio/Destroy()
	stored_slimes = null
	QDEL_NULL(current_potion)
	for(var/i in contents)
		var/mob/living/simple_animal/slime/S = i
		if(istype(S))
			S.forceMove(drop_location())
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/CreateEye()
	eyeobj = new /mob/camera/aiEye/remote/xenobio(get_turf(src))
	eyeobj.origin = src
	eyeobj.visible_icon = 1
	eyeobj.icon = 'icons/obj/abductor.dmi'
	eyeobj.icon_state = "camera_target"

/obj/machinery/computer/camera_advanced/xenobio/GrantActions(mob/living/user)
	..()

	if(slime_up_action)
		slime_up_action.target = src
		slime_up_action.Grant(user)
		actions += slime_up_action

	if(slime_place_action)
		slime_place_action.target = src
		slime_place_action.Grant(user)
		actions += slime_place_action

	if(feed_slime_action)
		feed_slime_action.target = src
		feed_slime_action.Grant(user)
		actions += feed_slime_action

	if(monkey_recycle_action)
		monkey_recycle_action.target = src
		monkey_recycle_action.Grant(user)
		actions += monkey_recycle_action

	if(scan_action)
		scan_action.target = src
		scan_action.Grant(user)
		actions += scan_action

	if(potion_action)
		potion_action.target = src
		potion_action.Grant(user)
		actions += potion_action

/obj/machinery/computer/camera_advanced/xenobio/proc/on_contents_del(datum/source, atom/deleted)
	if(current_potion == deleted)
		current_potion = null
	if(deleted in stored_slimes)
		stored_slimes -= deleted

/obj/machinery/computer/camera_advanced/xenobio/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/reagent_containers/food/snacks/monkeycube))
		monkeys++
		to_chat(user, "<span class='notice'>You feed [O] to [src]. It now has [monkeys] monkey cubes stored.</span>")
		qdel(O)
		return
	else if(istype(O, /obj/item/storage/bag))
		var/obj/item/storage/P = O
		var/loaded = FALSE
		for(var/obj/G in P.contents)
			if(istype(G, /obj/item/reagent_containers/food/snacks/monkeycube))
				loaded = TRUE
				monkeys++
				qdel(G)
		if(loaded)
			to_chat(user, "<span class='notice'>You fill [src] with the monkey cubes stored in [O]. [src] now has [monkeys] monkey cubes stored.</span>")
		return
	else if(istype(O, /obj/item/slimepotion/slime))
		var/replaced = FALSE
		if(user && !user.transferItemToLoc(O, src))
			return
		if(!QDELETED(current_potion))
			current_potion.forceMove(drop_location())
			replaced = TRUE
		current_potion = O
		to_chat(user, "<span class='notice'>You load [O] in the console's potion slot[replaced ? ", replacing the one that was there before" : ""].</span>")
		return
	..()

/datum/action/innate/slime_place
	name = "Place Slimes"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/slime_place/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/aiEye/remote/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in X.stored_slimes)
			S.forceMove(remote_eye.loc)
			S.visible_message("[S] warps in!")
			X.stored_slimes -= S
	else
		to_chat(owner, "<span class='notice'>Target is not near a camera. Cannot proceed.</span>")

/datum/action/innate/slime_pick_up
	name = "Pick up Slime"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_up"

/datum/action/innate/slime_pick_up/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/aiEye/remote/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in remote_eye.loc)
			if(X.stored_slimes.len >= X.max_slimes)
				break
			if(!S.ckey)
				if(S.buckled)
					S.Feedstop(silent = TRUE)
				S.visible_message("[S] vanishes in a flash of light!")
				S.forceMove(X)
				X.stored_slimes += S
	else
		to_chat(owner, "<span class='notice'>Target is not near a camera. Cannot proceed.</span>")


/datum/action/innate/feed_slime
	name = "Feed Slimes"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "monkey_down"

/datum/action/innate/feed_slime/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/aiEye/remote/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		if(X.monkeys >= 1)
			var/mob/living/carbon/monkey/food = new /mob/living/carbon/monkey(remote_eye.loc, TRUE, owner)
			if (!QDELETED(food))
				food.LAssailant = C
				X.monkeys --
				to_chat(owner, "[X] now has [X.monkeys] monkeys left.")
	else
		to_chat(owner, "<span class='notice'>Target is not near a camera. Cannot proceed.</span>")


/datum/action/innate/monkey_recycle
	name = "Recycle Monkeys"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "monkey_up"

/datum/action/innate/monkey_recycle/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/aiEye/remote/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/carbon/monkey/M in remote_eye.loc)
			if(M.stat)
				M.visible_message("[M] vanishes as [M.p_theyre()] reclaimed for recycling!")
				X.monkeys = round(X.monkeys + 0.2,0.1)
				qdel(M)
	else
		to_chat(owner, "<span class='notice'>Target is not near a camera. Cannot proceed.</span>")

/datum/action/innate/slime_scan
	name = "Scan Slime"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_scan"

/datum/action/innate/slime_scan/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/aiEye/remote/xenobio/remote_eye = C.remote_control

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in remote_eye.loc)
			slime_scan(S, C)
	else
		to_chat(owner, "<span class='notice'>Target is not near a camera. Cannot proceed.</span>")

/datum/action/innate/feed_potion
	name = "Apply Potion"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_potion"

/datum/action/innate/feed_potion/Activate()
	if(!target || !isliving(owner))
		return

	var/mob/living/C = owner
	var/mob/camera/aiEye/remote/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(QDELETED(X.current_potion))
		to_chat(owner, "<span class='notice'>No potion loaded.</span>")
		return

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in remote_eye.loc)
			X.current_potion.attack(S, C)
			break
	else
		to_chat(owner, "<span class='notice'>Target is not near a camera. Cannot proceed.</span>")
