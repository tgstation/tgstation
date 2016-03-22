/obj/item/clothing/head/helmet/space/chronos
	name = "Chronosuit Helmet"
	desc = "A white helmet with an opaque blue visor."
	icon_state = "chronohelmet"
	item_state = "chronohelmet"
	slowdown = 1
	armor = list(melee = 60, bullet = 30/*bullet through the visor*/, laser = 60, energy = 60, bomb = 30, bio = 90, rad = 90)
	var/obj/item/clothing/suit/space/chronos/suit = null

/obj/item/clothing/head/helmet/space/chronos/dropped()
	if(suit)
		suit.deactivate()
	..()

/obj/item/clothing/head/helmet/space/chronos/Destroy()
	dropped()
	return ..()


/obj/item/clothing/suit/space/chronos
	name = "Chronosuit"
	desc = "An advanced spacesuit equipped with teleportation and anti-compression technology"
	icon_state = "chronosuit"
	item_state = "chronosuit"
	actions_types = list(/datum/action/item_action/toggle)
	armor = list(melee = 60, bullet = 60, laser = 60, energy = 60, bomb = 30, bio = 90, rad = 90)
	var/list/chronosafe_items = list(/obj/item/weapon/chrono_eraser, /obj/item/weapon/gun/energy/chrono_gun)
	var/hands_nodrop_states
	var/obj/item/clothing/head/helmet/space/chronos/helmet = null
	var/obj/effect/chronos_cam/camera = null
	var/atom/movable/overlay/phase_underlay = null
	var/datum/action/innate/chrono_teleport/teleport_now = new
	var/activating = 0
	var/activated = 0
	var/cooldowntime = 50 //deciseconds
	var/teleporting = 0

/obj/item/clothing/suit/space/chronos/New()
	..()
	teleport_now.chronosuit = src
	teleport_now.target = src

/obj/item/clothing/suit/space/chronos/proc/new_camera(mob/user)
	if(camera)
		qdel(camera)
	camera = new /obj/effect/chronos_cam(user)
	camera.holder = user
	camera.chronosuit = src
	user.remote_control = camera

/obj/item/clothing/suit/space/chronos/ui_action_click()
	if((cooldown <= world.time) && !teleporting && !activating)
		if(!activated)
			activate()
		else
			deactivate()

/obj/item/clothing/suit/space/chronos/dropped()
	if(activated)
		deactivate()
	..()

/obj/item/clothing/suit/space/chronos/Destroy()
	dropped()
	return ..()

/obj/item/clothing/suit/space/chronos/emp_act(severity)
	var/mob/living/carbon/human/user = src.loc
	switch(severity)
		if(1)
			if(activated && user && ishuman(user) && (user.wear_suit == src))
				user << "<span class='userdanger'>E:FATAL:RAM_READ_FAIL\nE:FATAL:STACK_EMPTY\nE:FATAL:READ_NULL_POINT\nE:FATAL:PWR_BUS_OVERLOAD</span>"
			deactivate(1, 1)

/obj/item/clothing/suit/space/chronos/proc/finish_chronowalk()
	var/mob/living/carbon/human/user = src.loc
	if(istype(user))
		user.SetStunned(0)
		user.next_move = 1
		user.alpha = 255
		user.color = "#ffffff"
		user.animate_movement = FORWARD_STEPS
		user.notransform = 0
		user.anchored = 0
		teleporting = 0
		if(user.l_hand && !(hands_nodrop_states & 1))
			user.l_hand.flags &= ~NODROP
		if(user.r_hand && !(hands_nodrop_states & 2))
			user.r_hand.flags &= ~NODROP
		if(phase_underlay && !qdeleted(phase_underlay))
			qdel(phase_underlay)
			phase_underlay = null
		if(camera)
			camera.remove_target_ui()
			camera.loc = user
		teleport_now.UpdateButtonIcon()

/obj/item/clothing/suit/space/chronos/proc/chronowalk(atom/location)
	var/mob/living/carbon/human/user = src.loc
	if(activated && !teleporting && user && istype(user) && location && user.loc && location.loc && user.wear_suit == src && user.stat == CONSCIOUS)
		teleporting = 1
		var/turf/from_turf = get_turf(user)
		var/turf/to_turf = get_turf(location)
		var/distance = cheap_hypotenuse(from_turf.x, from_turf.y, to_turf.x, to_turf.y)
		var/phase_in_ds = distance*2

		if(camera)
			camera.remove_target_ui()

		teleport_now.UpdateButtonIcon()

		var/list/nonsafe_slots = list(slot_belt, slot_back, slot_l_hand, slot_r_hand)
		for(var/slot in nonsafe_slots)
			var/obj/item/slot_item = user.get_item_by_slot(slot)
			if(slot_item && !(slot_item.type in chronosafe_items) && user.unEquip(slot_item))
				user << "<span class='notice'>Your [slot_item.name] got left behind.</span>"

		user.ExtinguishMob()
		if(user.buckled)
			user.buckled.unbuckle_mob(user,force=1)

		phase_underlay = create_phase_underlay(user)

		hands_nodrop_states = 0
		if(user.l_hand)
			hands_nodrop_states |= (user.l_hand.flags & NODROP) ? 1 : 0
			user.l_hand.flags |= NODROP
		if(user.r_hand)
			hands_nodrop_states |= (user.r_hand.flags & NODROP) ? 2 : 0
			user.r_hand.flags |= NODROP

		user.animate_movement = NO_STEPS
		user.changeNext_move(8 + phase_in_ds)
		user.notransform = 1
		user.anchored = 1
		user.Stun(INFINITY)

		animate(user, color = "#00ccee", time = 3)
		spawn(3)
			if(teleporting && activated && user && phase_underlay && !qdeleted(phase_underlay))
				animate(user, alpha = 0, time = 2)
				animate(phase_underlay, alpha = 255, time = 2)
				sleep(2)
				if(teleporting && activated && user && phase_underlay && !qdeleted(phase_underlay))
					phase_underlay.loc = to_turf
					user.loc = to_turf
					animate(user, alpha = 255, time = phase_in_ds)
					animate(phase_underlay, alpha = 0, time = phase_in_ds)
					sleep(phase_in_ds)
					if(teleporting && activated && phase_underlay && !qdeleted(phase_underlay))
						animate(user, color = "#ffffff", time = 3)
						sleep(3)
			if(teleporting && user && !qdeleted(user))
				user.loc = to_turf //this will cover if bad things happen before the teleport, yes it is redundant
				finish_chronowalk()

/obj/item/clothing/suit/space/chronos/proc/create_phase_underlay(var/mob/user)
	var/icon/user_icon = getFlatIcon(user)
	user_icon.Blend("#ffffff")
	var/atom/movable/overlay/phase = new(user.loc)
	phase.icon = user_icon
	phase.density = 1
	phase.anchored = 1
	phase.master = user
	phase.animate_movement = NO_STEPS
	phase.alpha = 0
	phase.mouse_opacity = 0
	phase.name = user.name
	phase.transform = user.transform
	phase.pixel_x = user.pixel_x
	phase.pixel_y = user.pixel_y
	return phase

/obj/item/clothing/suit/space/chronos/process()
	if(activated)
		var/mob/living/carbon/human/user = src.loc
		if(user && ishuman(user) && (user.wear_suit == src))
			if(camera && (user.remote_control == camera))
				if(!teleporting)
					if(camera.loc != user && ((camera.x != user.x) || (camera.y != user.y) || (camera.z != user.z)))
						if(camera.phase_time <= world.time)
							chronowalk(camera)
					else
						camera.remove_target_ui()
			else
				new_camera(user)
	else
		SSobj.processing.Remove(src)

/obj/item/clothing/suit/space/chronos/proc/activate()
	if(!activating && !activated && !teleporting)
		activating = 1
		var/mob/living/carbon/human/user = src.loc
		if(user && ishuman(user))
			if(user.wear_suit == src)
				user << "\nChronosuitMK4 login: root"
				user << "Password:\n"
				user << "root@ChronosuitMK4# chronowalk4 --start\n"
				if(user.head && istype(user.head, /obj/item/clothing/head/helmet/space/chronos))
					user << "\[ <span style='color: #00ff00;'>ok</span> \] Mounting /dev/helmet"
					helmet = user.head
					helmet.flags |= NODROP
					helmet.suit = src
					src.flags |= NODROP
					user << "\[ <span style='color: #00ff00;'>ok</span> \] Starting brainwave scanner"
					user << "\[ <span style='color: #00ff00;'>ok</span> \] Starting ui display driver"
					user << "\[ <span style='color: #00ff00;'>ok</span> \] Initializing chronowalk4-view"
					new_camera(user)
					SSobj.processing |= src
					activated = 1
				else
					user << "\[ <span style='color: #ff0000;'>fail</span> \] Mounting /dev/helmet"
					user << "<span style='color: #ff0000;'><b>FATAL: </b>Unable to locate /dev/helmet. <b>Aborting...</b>"
			teleport_now.Grant(user)
		cooldown = world.time + cooldowntime
		activating = 0
		return 0

/obj/item/clothing/suit/space/chronos/proc/deactivate(force = 0, silent = 0)
	if(activated && (!teleporting || force))
		activating = 1
		var/mob/living/carbon/human/user = src.loc
		if(user && ishuman(user))
			if(user.wear_suit == src)
				if(!silent)
					user << "\nroot@ChronosuitMK4# chronowalk4 --stop\n"
				if(camera)
					if(!silent)
						user << "\[ <span style='color: #ff5500;'>ok</span> \] Sending TERM signal to chronowalk4-view" //yes I know they aren't a different color when shutting down, but they were too similar at a glance
					qdel(camera)
				if(helmet)
					if(!silent)
						user << "\[ <span style='color: #ff5500;'>ok</span> \] Stopping ui display driver"
						user << "\[ <span style='color: #ff5500;'>ok</span> \] Stopping brainwave scanner"
						user << "\[ <span style='color: #ff5500;'>ok</span> \] Unmounting /dev/helmet"
					helmet.flags &= ~NODROP
					helmet.suit = null
					helmet = null
				if(!silent)
					user << "logout"
			teleport_now.Remove(user)
		src.flags &= ~NODROP
		cooldown = world.time + cooldowntime * 1.5
		activated = 0
		activating = 0
		finish_chronowalk()
		if(teleporting && force)
			user.electrocute_act(35, src, safety = 1)

/obj/effect/chronos_cam
	name = "Chronosuit View"
	density = 0
	anchored = 1
	invisibility = 101
	opacity = 0
	mouse_opacity = 0
	var/mob/holder = null
	var/phase_time = 0
	var/phase_time_length = 3
	var/obj/screen/chronos_target/target_ui = null
	var/obj/item/clothing/suit/space/chronos/chronosuit

/obj/effect/chronos_cam/proc/create_target_ui()
	if(holder && holder.client && chronosuit)
		if(target_ui)
			remove_target_ui()
		target_ui = new(null, holder)
		holder.client.screen += target_ui

/obj/effect/chronos_cam/proc/remove_target_ui()
	if(target_ui)
		qdel(target_ui)
		target_ui = null

/obj/effect/chronos_cam/relaymove(var/mob/user, direction)
	if(holder)
		if(user == holder)
			if(loc == user)
				loc = get_turf(user)
			if(user.client && user.client.eye != src)
				src.loc = get_turf(user)
				user.reset_perspective(src)
				user.set_machine(src)
			var/atom/step = get_step(src, direction)
			if(step)
				if((step.x <= TRANSITIONEDGE) || (step.x >= (world.maxx - TRANSITIONEDGE - 1)) || (step.y <= TRANSITIONEDGE) || (step.y >= (world.maxy - TRANSITIONEDGE - 1)))
					if(!src.Move(step))
						src.loc = step
				else
					src.loc = step
				if((x == holder.x) && (y == holder.y) && (z == holder.z))
					remove_target_ui()
					loc = user
				else if(!target_ui)
					create_target_ui()
				phase_time = world.time + phase_time_length
	else
		qdel(src)

/obj/effect/chronos_cam/check_eye(mob/user)
	if(user != holder)
		user.unset_machine()

/obj/effect/chronos_cam/on_unset_machine(mob/user)
	user.reset_perspective(null)

/obj/effect/chronos_cam/Destroy()
	if(holder)
		if(holder.remote_control == src)
			holder.remote_control = null
		if(holder.client && (holder.client.eye == src))
			holder.unset_machine()
	return ..()

/obj/screen/chronos_target
	name = "target display"
	screen_loc = "CENTER,CENTER"
	color = "#ff3311"
	blend_mode = BLEND_SUBTRACT

/obj/screen/chronos_target/New(loc, var/mob/living/carbon/human/user)
	if(user)
		var/icon/user_icon = getFlatIcon(user)
		icon = user_icon
		transform = user.transform
	else
		qdel(src)

/datum/action/innate/chrono_teleport
	name = "Teleport Now"
	button_icon_state = "chrono_phase"
	check_flags = AB_CHECK_CONSCIOUS //|AB_CHECK_INSIDE
	var/obj/item/clothing/suit/space/chronos/chronosuit = null

/datum/action/innate/chrono_teleport/IsAvailable()
	return (chronosuit && chronosuit.activated && chronosuit.camera && !chronosuit.teleporting)

/datum/action/innate/chrono_teleport/Activate()
	if(IsAvailable())
		if(chronosuit.camera)
			chronosuit.chronowalk(chronosuit.camera)
