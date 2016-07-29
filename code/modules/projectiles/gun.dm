/obj/item/weapon/gun
	name = "gun"
<<<<<<< HEAD
	desc = "It's a gun. It's pretty terrible, though."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags =  CONDUCT
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=2000)
	w_class = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	force = 5
	origin_tech = "combat=1"
	needs_permit = 1
	attack_verb = list("struck", "hit", "bashed")

	var/fire_sound = "gunshot"
	var/suppressed = 0					//whether or not a message is displayed when fired
	var/can_suppress = 0
	var/can_unsuppress = 1
	var/recoil = 0						//boom boom shake the room
	var/clumsy_check = 1
	var/obj/item/ammo_casing/chambered = null
	var/trigger_guard = TRIGGER_GUARD_NORMAL	//trigger guard on the weapon, hulks can't fire them with their big meaty fingers
	var/sawn_desc = null				//description change if weapon is sawn-off
	var/sawn_state = SAWN_INTACT
	var/burst_size = 1					//how large a burst is
	var/fire_delay = 0					//rate of fire for burst firing and semi auto
	var/firing_burst = 0				//Prevent the weapon from firing again while already firing
	var/semicd = 0						//cooldown handler
	var/weapon_weight = WEAPON_LIGHT

	var/spread = 0						//Spread induced by the gun itself.
	var/randomspread = 1				//Set to 0 for shotguns. This is used for weapons that don't fire all their bullets at once.

	var/unique_rename = 0 //allows renaming with a pen
	var/unique_reskin = 0 //allows one-time reskinning
	var/current_skin = null //the skin choice if we had a reskin
	var/list/options = list()

	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'

	var/obj/item/device/firing_pin/pin = /obj/item/device/firing_pin //standard firing pin for most guns

	var/obj/item/device/flashlight/F = null
	var/can_flashlight = 0

	var/list/upgrades = list()

	var/ammo_x_offset = 0 //used for positioning ammo count overlay on sprite
	var/ammo_y_offset = 0
	var/flight_x_offset = 0
	var/flight_y_offset = 0

	//Zooming
	var/zoomable = FALSE //whether the gun generates a Zoom action on creation
	var/zoomed = FALSE //Zoom toggle
	var/zoom_amt = 3 //Distance in TURFs to move the user's screen forward (the "zoom" effect)
	var/datum/action/toggle_scope_zoom/azoom


/obj/item/weapon/gun/New()
	..()
	if(pin)
		pin = new pin(src)
	if(F)
		verbs += /obj/item/weapon/gun/proc/toggle_gunlight
		new /datum/action/item_action/toggle_gunlight(src)
	build_zooming()


/obj/item/weapon/gun/CheckParts(list/parts_list)
	..()
	var/obj/item/weapon/gun/G = locate(/obj/item/weapon/gun) in contents
	if(G)
		G.loc = loc
		qdel(G.pin)
		G.pin = null
		visible_message("[G] can now fit a new pin, but old one was destroyed in the process.")
		qdel(src)

/obj/item/weapon/gun/examine(mob/user)
	..()
	if(pin)
		user << "It has [pin] installed."
	else
		user << "It doesn't have a firing pin installed, and won't fire."
	if(unique_reskin && !current_skin)
		user << "<span class='notice'>Alt-click it to reskin it.</span>"
	if(unique_rename)
		user << "<span class='notice'>Use a pen on it to rename it.</span>"


/obj/item/weapon/gun/proc/process_chamber()
	return 0


//check if there's enough ammo/energy/whatever to shoot one time
//i.e if clicking would make it shoot
/obj/item/weapon/gun/proc/can_shoot()
	return 1


/obj/item/weapon/gun/proc/shoot_with_empty_chamber(mob/living/user as mob|obj)
	user << "<span class='danger'>*click*</span>"
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)


/obj/item/weapon/gun/proc/shoot_live_shot(mob/living/user as mob|obj, pointblank = 0, mob/pbtarget = null, message = 1)
	if(recoil)
		shake_camera(user, recoil + 1, recoil)

	if(suppressed)
		playsound(user, fire_sound, 10, 1)
	else
		playsound(user, fire_sound, 50, 1)
		if(!message)
			return
		if(pointblank)
			user.visible_message("<span class='danger'>[user] fires [src] point blank at [pbtarget]!</span>", "<span class='danger'>You fire [src] point blank at [pbtarget]!</span>", "<span class='italics'>You hear a [istype(src, /obj/item/weapon/gun/energy) ? "laser blast" : "gunshot"]!</span>")
		else
			user.visible_message("<span class='danger'>[user] fires [src]!</span>", "<span class='danger'>You fire [src]!</span>", "You hear a [istype(src, /obj/item/weapon/gun/energy) ? "laser blast" : "gunshot"]!")

	if(weapon_weight >= WEAPON_MEDIUM)
		if(user.get_inactive_hand())
			if(prob(15))
				if(user.drop_item())
					user.visible_message("<span class='danger'>[src] flies out of [user]'s hands!</span>", "<span class='userdanger'>[src] kicks out of your grip!</span>")

=======
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'icons/obj/gun.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_METAL
	w_class = W_CLASS_MEDIUM
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5.0
	origin_tech = "combat=1"
	attack_verb = list("strikes", "hits", "bashes")
	mech_flags = MECH_SCAN_ILLEGAL
	min_harm_label = 20
	harm_label_examine = list("<span class='info'>A label is stuck to the trigger, but it is too small to get in the way.</span>", "<span class='warning'>A label firmly sticks the trigger to the guard!</span>")

	var/fire_sound = 'sound/weapons/Gunshot.ogg'
	var/empty_sound = 'sound/weapons/empty.ogg'
	var/fire_volume = 50 //the volume of the fire_sound
	var/obj/item/projectile/in_chamber = null
	var/list/caliber //the ammo the gun will accept. Now multiple types (make sure to set them to =1)
	var/silenced = 0
	var/recoil = 0
	var/ejectshell = 1

	var/clumsy_check = 1				//Whether the gun disallows clumsy users from firing it.
	var/advanced_tool_user_check = 1	//Whether the gun disallows users that cannot use advanced tools from firing it.
	var/MoMMI_check = 1					//Whether the gun disallows MoMMIs from firing it.
	var/nymph_check = 1					//Whether the gun disallows diona nymphs from firing it.
	var/hulk_check = 1					//Whether the gun disallows hulks from firing it.
	var/golem_check = 1					//Whether the gun disallows golems from firing it.

	var/tmp/list/mob/living/target //List of who yer targeting.
	var/tmp/lock_time = -100
	var/mouthshoot = 0 ///To stop people from suiciding twice... >.>
	var/automatic = 0 //Used to determine if you can target multiple people.
	var/tmp/mob/living/last_moved_mob //Used to fire faster at more than one person.
	var/tmp/told_cant_shoot = 0 //So that it doesn't spam them with the fact they cannot hit them.
	var/firerate = 1 	// 0 for one bullet after tarrget moves and aim is lowered,
						//1 for keep shooting until aim is lowered
	var/fire_delay = 2
	var/last_fired = 0

	var/conventional_firearm = 1	//Used to determine whether, when examined, an /obj/item/weapon/gun/projectile will display the amount of rounds remaining.

/obj/item/weapon/gun/proc/ready_to_fire()
	if(world.time >= last_fired + fire_delay)
		last_fired = world.time
		return 1
	else
		return 0

/obj/item/weapon/gun/proc/process_chambered()
	return 0

/obj/item/weapon/gun/proc/special_check(var/mob/M) //Placeholder for any special checks, like detective's revolver.
	return 1

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/obj/item/weapon/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

<<<<<<< HEAD

/obj/item/weapon/gun/afterattack(atom/target, mob/living/user, flag, params)
	if(firing_burst)
		return
	if(flag) //It's adjacent, is the user, or is on the user's person
		if(target in user.contents) //can't shoot stuff inside us.
			return
		if(!ismob(target) || user.a_intent == "harm") //melee attack
			return
		if(target == user && user.zone_selected != "mouth") //so we can't shoot ourselves (unless mouth selected)
			return

	if(istype(user))//Check if the user can use the gun, if the user isn't alive(turrets) assume it can.
		var/mob/living/L = user
		if(!can_trigger_gun(L))
			return

	if(!can_shoot()) //Just because you can pull the trigger doesn't mean it can't shoot.
		shoot_with_empty_chamber(user)
		return

	if(flag)
		if(user.zone_selected == "mouth")
			handle_suicide(user, target, params)
			return


	//Exclude lasertag guns from the CLUMSY check.
	if(clumsy_check)
		if(istype(user))
			if (user.disabilities & CLUMSY && prob(40))
				user << "<span class='userdanger'>You shoot yourself in the foot with \the [src]!</span>"
				var/shot_leg = pick("l_leg", "r_leg")
				process_fire(user,user,0,params, zone_override = shot_leg)
				user.drop_item()
				return

	if(weapon_weight == WEAPON_HEAVY && user.get_inactive_hand())
		user << "<span class='userdanger'>You need both hands free to fire \the [src]!</span>"
		return

	process_fire(target,user,1,params)



/obj/item/weapon/gun/proc/can_trigger_gun(var/mob/living/user)

	if(!handle_pins(user) || !user.can_use_guns(src))
		return 0

	return 1

/obj/item/weapon/gun/proc/handle_pins(mob/living/user)
	if(pin)
		if(pin.pin_auth(user) || pin.emagged)
			return 1
		else
			pin.auth_fail(user)
			return 0
	else
		user << "<span class='warning'>\The [src]'s trigger is locked. This weapon doesn't have a firing pin installed!</span>"
	return 0

obj/item/weapon/gun/proc/newshot()
	return

/obj/item/weapon/gun/proc/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override)
	add_fingerprint(user)

	if(semicd)
		return

	if(weapon_weight)
		if(user.get_inactive_hand())
			recoil = 4 //one-handed kick
		else
			recoil = initial(recoil)

	if(burst_size > 1)
		firing_burst = 1
		for(var/i = 1 to burst_size)
			if(!user)
				break
			if(!issilicon(user))
				if( i>1 && !(src in get_both_hands(user))) //for burst firing
					break
			if(chambered)
				var/sprd = 0
				if(randomspread)
					sprd = round((rand() - 0.5) * spread)
				else //Smart spread
					sprd = round((i / burst_size - 0.5) * spread)
				if(!chambered.fire(target, user, params, ,suppressed, zone_override, sprd))
					shoot_with_empty_chamber(user)
					break
				else
					if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
						shoot_live_shot(user, 1, target, message)
					else
						shoot_live_shot(user, 0, target, message)
			else
				shoot_with_empty_chamber(user)
				break
			process_chamber()
			update_icon()
			sleep(fire_delay)
		firing_burst = 0
	else
		if(chambered)
			if(!chambered.fire(target, user, params, , suppressed, zone_override, spread))
				shoot_with_empty_chamber(user)
				return
			else
				if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
					shoot_live_shot(user, 1, target, message)
				else
					shoot_live_shot(user, 0, target, message)
		else
			shoot_with_empty_chamber(user)
			return
		process_chamber()
		update_icon()
		semicd = 1
		spawn(fire_delay)
			semicd = 0

	if(user)
		if(user.hand)
			user.update_inv_l_hand()
		else
			user.update_inv_r_hand()
	feedback_add_details("gun_fired","[src.type]")

/obj/item/weapon/gun/attack(mob/M as mob, mob/user)
	if(user.a_intent == "harm") //Flogging
		..()
	else
		return

/obj/item/weapon/gun/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/flashlight/seclite))
		var/obj/item/device/flashlight/seclite/S = I
		if(can_flashlight)
			if(!F)
				if(!user.unEquip(I))
					return
				user << "<span class='notice'>You click [S] into place on [src].</span>"
				if(S.on)
					SetLuminosity(0)
				F = S
				I.loc = src
				update_icon()
				update_gunlight(user)
				verbs += /obj/item/weapon/gun/proc/toggle_gunlight
				var/datum/action/A = new /datum/action/item_action/toggle_gunlight(src)
				if(loc == user)
					A.Grant(user)

	if(istype(I, /obj/item/weapon/screwdriver))
		if(F && can_flashlight)
			for(var/obj/item/device/flashlight/seclite/S in src)
				user << "<span class='notice'>You unscrew the seclite from [src].</span>"
				F = null
				S.loc = get_turf(user)
				update_gunlight(user)
				S.update_brightness(user)
				update_icon()
				verbs -= /obj/item/weapon/gun/proc/toggle_gunlight
			for(var/datum/action/item_action/toggle_gunlight/TGL in actions)
				qdel(TGL)

	if(unique_rename)
		if(istype(I, /obj/item/weapon/pen))
			rename_gun(user)
	..()

/obj/item/weapon/gun/proc/toggle_gunlight()
	set name = "Toggle Gunlight"
	set category = "Object"
	set desc = "Click to toggle your weapon's attached flashlight."

	if(!F)
		return

	var/mob/living/carbon/human/user = usr
	if(!isturf(user.loc))
		user << "<span class='warning'>You cannot turn the light on while in this [user.loc]!</span>"
	F.on = !F.on
	user << "<span class='notice'>You toggle the gunlight [F.on ? "on":"off"].</span>"

	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_gunlight(user)
	return

/obj/item/weapon/gun/proc/update_gunlight(mob/user = null)
	if(F)
		if(F.on)
			if(loc == user)
				user.AddLuminosity(F.brightness_on)
			else if(isturf(loc))
				SetLuminosity(F.brightness_on)
		else
			if(loc == user)
				user.AddLuminosity(-F.brightness_on)
			else if(isturf(loc))
				SetLuminosity(0)
		update_icon()
	else
		if(loc == user)
			user.AddLuminosity(-5)
		else if(isturf(loc))
			SetLuminosity(0)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()


/obj/item/weapon/gun/pickup(mob/user)
	..()
	if(F)
		if(F.on)
			user.AddLuminosity(F.brightness_on)
			SetLuminosity(0)
	if(azoom)
		azoom.Grant(user)

/obj/item/weapon/gun/dropped(mob/user)
	..()
	if(F)
		if(F.on)
			user.AddLuminosity(-F.brightness_on)
			SetLuminosity(F.brightness_on)
	zoom(user,FALSE)
	if(azoom)
		azoom.Remove(user)


/obj/item/weapon/gun/AltClick(mob/user)
	..()
	if(user.incapacitated())
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	if(unique_reskin && !current_skin && loc == user)
		reskin_gun(user)


/obj/item/weapon/gun/proc/reskin_gun(mob/M)
	var/choice = input(M,"Warning, you can only reskin your weapon once!","Reskin Gun") in options

	if(src && choice && !current_skin && !M.incapacitated() && in_range(M,src))
		if(options[choice] == null)
			return
		current_skin = options[choice]
		M << "Your gun is now skinned as [choice]. Say hello to your new friend."
		update_icon()


/obj/item/weapon/gun/proc/rename_gun(mob/M)
	var/input = stripped_input(M,"What do you want to name the gun?", ,"", MAX_NAME_LEN)

	if(src && input && !M.stat && in_range(M,src) && !M.restrained() && M.canmove)
		name = input
		M << "You name the gun [input]. Say hello to your new friend."
		return


/obj/item/weapon/gun/proc/handle_suicide(mob/living/carbon/human/user, mob/living/carbon/human/target, params)
	if(!ishuman(user) || !ishuman(target))
		return

	if(semicd)
		return

	if(user == target)
		target.visible_message("<span class='warning'>[user] sticks [src] in their mouth, ready to pull the trigger...</span>", \
			"<span class='userdanger'>You stick [src] in your mouth, ready to pull the trigger...</span>")
	else
		target.visible_message("<span class='warning'>[user] points [src] at [target]'s head, ready to pull the trigger...</span>", \
			"<span class='userdanger'>[user] points [src] at your head, ready to pull the trigger...</span>")

	semicd = 1

	if(!do_mob(user, target, 120) || user.zone_selected != "mouth")
		if(user)
			if(user == target)
				user.visible_message("<span class='notice'>[user] decided life was worth living.</span>")
			else if(target && target.Adjacent(user))
				target.visible_message("<span class='notice'>[user] has decided to spare [target]'s life.</span>", "<span class='notice'>[user] has decided to spare your life!</span>")
		semicd = 0
		return

	semicd = 0

	target.visible_message("<span class='warning'>[user] pulls the trigger!</span>", "<span class='userdanger'>[user] pulls the trigger!</span>")

	if(chambered && chambered.BB)
		chambered.BB.damage *= 5

	process_fire(target, user, 1, params)

/obj/item/weapon/gun/proc/unlock() //used in summon guns and as a convience for admins
	if(pin)
		qdel(pin)
	pin = new /obj/item/device/firing_pin

/////////////
// ZOOMING //
/////////////

/datum/action/toggle_scope_zoom
	name = "Toggle Scope"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING
	button_icon_state = "sniper_zoom"
	var/obj/item/weapon/gun/gun = null

/datum/action/toggle_scope_zoom/Trigger()
	gun.zoom(owner)

/datum/action/toggle_scope_zoom/IsAvailable()
	. = ..()
	if(!. && gun)
		gun.zoom(owner, FALSE)

/datum/action/toggle_scope_zoom/Remove(mob/living/L)
	gun.zoom(L, FALSE)
	..()


/obj/item/weapon/gun/proc/zoom(mob/living/user, forced_zoom)
	if(!user || !user.client)
		return

	switch(forced_zoom)
		if(FALSE)
			zoomed = FALSE
		if(TRUE)
			zoomed = TRUE
		else
			zoomed = !zoomed

	if(zoomed)
		var/_x = 0
		var/_y = 0
		switch(user.dir)
			if(NORTH)
				_y = zoom_amt
			if(EAST)
				_x = zoom_amt
			if(SOUTH)
				_y = -zoom_amt
			if(WEST)
				_x = -zoom_amt

		user.client.pixel_x = world.icon_size*_x
		user.client.pixel_y = world.icon_size*_y
	else
		user.client.pixel_x = 0
		user.client.pixel_y = 0


//Proc, so that gun accessories/scopes/etc. can easily add zooming.
/obj/item/weapon/gun/proc/build_zooming()
	if(azoom)
		return

	if(zoomable)
		azoom = new()
		azoom.gun = src


/obj/item/weapon/gun/burn()
	if(pin)
		qdel(pin)
	.=..()
=======
/obj/item/weapon/gun/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)	return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(istype(target, /obj/machinery/recharger) && istype(src, /obj/item/weapon/gun/energy))	return//Shouldnt flag take care of this?
	if(user && user.client && user.client.gun_mode && !(A in target))
		PreFire(A,user,params, "struggle" = struggle) //They're using the new gun system, locate what they're aiming at.
	else
		Fire(A,user,params, "struggle" = struggle) //Otherwise, fire normally.

/obj/item/weapon/gun/proc/isHandgun()
	return 1

/obj/item/weapon/gun/proc/can_Fire(mob/user, var/display_message = 0)
	var/firing_dexterity = 1
	if(advanced_tool_user_check)
		if (!user.IsAdvancedToolUser())
			firing_dexterity = 0
	if(MoMMI_check)
		if(isMoMMI(user))
			firing_dexterity = 0
	if(nymph_check)
		if(istype(user, /mob/living/carbon/monkey/diona))
			firing_dexterity = 0
	if(!firing_dexterity)
		if(display_message)
			to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 0

	if(istype(user, /mob/living))
		if(hulk_check)
			var/mob/living/M = user
			if (M_HULK in M.mutations)
				if(display_message)
					to_chat(M, "<span class='warning'>Your meaty finger is much too large for the trigger guard!</span>")
				return 0
	if(ishuman(user))
		var/mob/living/carbon/human/H=user
		if(golem_check)
			if(isgolem(H) || (H.dna && (H.dna.mutantrace == "adamantine" || H.dna.mutantrace=="coalgolem"))) //leaving the mutantrace checks in just in case
				if(display_message)
					to_chat(user, "<span class='warning'>Your fat fingers don't fit in the trigger guard!</span>")
				return 0
		var/datum/organ/external/a_hand = H.get_active_hand_organ()
		if(!a_hand.can_use_advanced_tools())
			if(display_message)
				to_chat(user, "<span class='warning'>Your [a_hand] doesn't have the dexterity to do this!</span>")
			return 0
	return 1

/obj/item/weapon/gun/proc/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)//TODO: go over this
	//Exclude lasertag guns from the M_CLUMSY check.
	if(clumsy_check)
		if(istype(user, /mob/living))
			var/mob/living/M = user
			if ((M_CLUMSY in M.mutations) && prob(50))
				to_chat(M, "<span class='danger'>[src] blows up in your face.</span>")
				M.take_organ_damage(0,20)
				M.drop_item(src, force_drop = 1)
				qdel(src)
				return

	if(!can_Fire(user, 1))
		return

	add_fingerprint(user)

	var/turf/curloc = user.loc
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	if(!special_check(user))
		return

	if (!ready_to_fire())
		if (world.time % 3) //to prevent spam
			to_chat(user, "<span class='warning'>[src] is not ready to fire again!")
		return

	if(!process_chambered()) //CHECK
		return click_empty(user)

	if(!in_chamber)
		return
	if(!istype(src, /obj/item/weapon/gun/energy/laser/redtag) && !istype(src, /obj/item/weapon/gun/energy/laser/bluetag))
		log_attack("[user.name] ([user.ckey]) fired \the [src] (proj:[in_chamber.name]) at [target] [ismob(target) ? "([target:ckey])" : ""] ([target.x],[target.y],[target.z])[struggle ? " due to being disarmed." :""]" )
	in_chamber.firer = user

	if(user.zone_sel)
		in_chamber.def_zone = user.zone_sel.selecting
	else
		in_chamber.def_zone = LIMB_CHEST

	if(targloc == curloc)
		user.bullet_act(in_chamber)
		qdel(in_chamber)
		in_chamber = null
		update_icon()
		return

	if(recoil)
		spawn()
			shake_camera(user, recoil + 1, recoil)
		if(user.locked_to && isobj(user.locked_to) && !user.locked_to.anchored )
			var/direction = get_dir(user,target)
			spawn()
				var/obj/B = user.locked_to
				var/movementdirection = turn(direction,180)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(2)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(2)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(user,movementdirection), movementdirection)
		if((istype(user.loc, /turf/space)) || (user.areaMaster.has_gravity == 0))
			user.inertia_dir = get_dir(target, user)
			step(user, user.inertia_dir)

	if(silenced)
		if(fire_sound)
			playsound(user, fire_sound, fire_volume/5, 1)
		else if (in_chamber.fire_sound)
			playsound(user, in_chamber.fire_sound, fire_volume/5, 1)
	else
		if(fire_sound)
			playsound(user, fire_sound, fire_volume, 1)
		else if (in_chamber.fire_sound)
			playsound(user, in_chamber.fire_sound, fire_volume, 1)
		user.visible_message("<span class='warning'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
		"<span class='warning'>You fire [src][reflex ? "by reflex":""]!</span>", \
		"You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")

	in_chamber.original = target
	in_chamber.loc = get_turf(user)
	in_chamber.starting = get_turf(user)
	in_chamber.shot_from = src
	user.delayNextAttack(4) // TODO: Should be delayed per-gun.
	in_chamber.silenced = silenced
	in_chamber.current = curloc
	in_chamber.OnFired()
	in_chamber.yo = targloc.y - curloc.y
	in_chamber.xo = targloc.x - curloc.x
	in_chamber.inaccurate = (istype(user.locked_to, /obj/structure/bed/chair/vehicle))

	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			in_chamber.p_x = text2num(mouse_control["icon-x"])
		if(mouse_control["icon-y"])
			in_chamber.p_y = text2num(mouse_control["icon-y"])

	spawn()
		if(in_chamber)
			in_chamber.process()
	sleep(1)
	in_chamber = null

	update_icon()

	user.update_inv_hand(user.active_hand)

	return 1

/obj/item/weapon/gun/proc/can_fire()
	return process_chambered()

/obj/item/weapon/gun/proc/can_hit(var/mob/living/target as mob, var/mob/living/user as mob)
	return in_chamber.check_fire(target,user)

/obj/item/weapon/gun/proc/click_empty(mob/user = null)
	if (user)
		if(empty_sound)
			user.visible_message("*click click*", "<span class='danger'>*click*</span>")
			playsound(user, empty_sound, 100, 1)
	else
		if(empty_sound)
			src.visible_message("*click click*")
			playsound(get_turf(src), empty_sound, 100, 1)

/obj/item/weapon/gun/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	//Suicide handling.
	if (M == user && user.zone_sel.selecting == "mouth" && !mouthshoot)
		if(istype(M.wear_mask, /obj/item/clothing/mask/happy))
			to_chat(M, "<span class='sinister'>BUT WHY? I'M SO HAPPY!</span>")
			return
		mouthshoot = 1
		M.visible_message("<span class='warning'>[user] sticks their gun in their mouth, ready to pull the trigger...</span>")
		if(!do_after(user,src, 40))
			M.visible_message("<span class='notice'>[user] decided life was worth living.</span>")
			mouthshoot = 0
			return
		if (process_chambered())
			user.visible_message("<span class = 'warning'>[user] pulls the trigger.</span>")
			if(silenced)
				if(fire_sound)
					playsound(user, fire_sound, fire_volume/5, 1)
				else if (in_chamber.fire_sound)
					playsound(user, in_chamber.fire_sound, fire_volume/5, 1)
			else
				if(fire_sound)
					playsound(user, fire_sound, fire_volume, 1)
				else if (in_chamber.fire_sound)
					playsound(user, in_chamber.fire_sound, fire_volume, 1)
			in_chamber.on_hit(M)
			if (!in_chamber.nodamage)
				user.apply_damage(in_chamber.damage*2.5, in_chamber.damage_type, LIMB_HEAD, used_weapon = "Point blank shot in the mouth with \a [in_chamber]")
				user.stat=2 // Just to be sure
				user.death()
				var/suicidesound = pick('sound/misc/suicide/suicide1.ogg','sound/misc/suicide/suicide2.ogg','sound/misc/suicide/suicide3.ogg','sound/misc/suicide/suicide4.ogg','sound/misc/suicide/suicide5.ogg','sound/misc/suicide/suicide6.ogg')
				playsound(get_turf(src), pick(suicidesound), 10, channel = 125)
			else
				to_chat(user, "<span class = 'notice'>Ow...</span>")
				user.apply_effect(110,AGONY,0)
			qdel(in_chamber)
			in_chamber = null
			mouthshoot = 0
			return
		else
			click_empty(user)
			mouthshoot = 0
			return

	if (src.process_chambered())
		//Point blank shooting if on harm intent or target we were targeting.
		if(user.a_intent == I_HURT)
			user.visible_message("<span class='danger'> \The [user] fires \the [src] point blank at [M]!</span>")
			in_chamber.damage *= 1.3
			src.Fire(M,user,0,0,1)
			return
		else if(target && M in target)
			src.Fire(M,user,0,0,1) ///Otherwise, shoot!
			return
		else
			return ..() //Allows a player to choose to melee instead of shoot, by being on help intent.
	else
		return ..() //Pistolwhippin'
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
