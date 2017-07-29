
#define DUALWIELD_PENALTY_EXTRA_MULTIPLIER 1.4

/obj/item/weapon/gun
	name = "gun"
	desc = "It's a gun. It's pretty terrible, though."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags =  CONDUCT
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=2000)
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	force = 5
	origin_tech = "combat=1"
	needs_permit = 1
	unique_rename = 0
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

	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'

	var/obj/item/device/firing_pin/pin = /obj/item/device/firing_pin //standard firing pin for most guns

	var/obj/item/device/flashlight/gun_light
	var/can_flashlight = 0
	var/obj/item/weapon/kitchen/knife/bayonet
	var/can_bayonet = FALSE
	var/datum/action/item_action/toggle_gunlight/alight

	var/list/upgrades = list()

	var/ammo_x_offset = 0 //used for positioning ammo count overlay on sprite
	var/ammo_y_offset = 0
	var/flight_x_offset = 0
	var/flight_y_offset = 0
	var/knife_x_offset = 0
	var/knife_y_offset = 0

	//Zooming
	var/zoomable = FALSE //whether the gun generates a Zoom action on creation
	var/zoomed = FALSE //Zoom toggle
	var/zoom_amt = 3 //Distance in TURFs to move the user's screen forward (the "zoom" effect)
	var/zoom_out_amt = 0
	var/datum/action/toggle_scope_zoom/azoom

/obj/item/weapon/gun/Initialize()
	. = ..()
	if(pin)
		pin = new pin(src)
	if(gun_light)
		alight = new /datum/action/item_action/toggle_gunlight(src)
	build_zooming()


/obj/item/weapon/gun/CheckParts(list/parts_list)
	..()
	var/obj/item/weapon/gun/G = locate(/obj/item/weapon/gun) in contents
	if(G)
		G.loc = loc
		qdel(G.pin)
		G.pin = null
		visible_message("[G] can now fit a new pin, but the old one was destroyed in the process.", null, null, 3)
		qdel(src)

/obj/item/weapon/gun/examine(mob/user)
	..()
	if(pin)
		to_chat(user, "It has [pin] installed.")
	else
		to_chat(user, "It doesn't have a firing pin installed, and won't fire.")

/obj/item/weapon/gun/equipped(mob/living/user, slot)
	. = ..()
	if(zoomable && user.get_active_held_item() != src)
		zoom(user, FALSE) //we can only stay zoomed in if it's in our hands

//called after the gun has successfully fired its chambered ammo.
/obj/item/weapon/gun/proc/process_chamber()
	return 0


//check if there's enough ammo/energy/whatever to shoot one time
//i.e if clicking would make it shoot
/obj/item/weapon/gun/proc/can_shoot()
	return 1


/obj/item/weapon/gun/proc/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, "<span class='danger'>*click*</span>")
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)


/obj/item/weapon/gun/proc/shoot_live_shot(mob/living/user as mob|obj, pointblank = 0, mob/pbtarget = null, message = 1)
	if(recoil)
		shake_camera(user, recoil + 1, recoil)

	if(suppressed)
		playsound(user, fire_sound, 10, 1)
	else
		playsound(user, fire_sound, 50, 1)
		if(message)
			if(pointblank)
				user.visible_message("<span class='danger'>[user] fires [src] point blank at [pbtarget]!</span>", null, null, COMBAT_MESSAGE_RANGE)
			else
				user.visible_message("<span class='danger'>[user] fires [src]!</span>", null, null, COMBAT_MESSAGE_RANGE)

/obj/item/weapon/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)


/obj/item/weapon/gun/afterattack(atom/target, mob/living/user, flag, params)
	if(firing_burst)
		return
	if(flag) //It's adjacent, is the user, or is on the user's person
		if(target in user.contents) //can't shoot stuff inside us.
			return
		if(!ismob(target) || user.a_intent == INTENT_HARM) //melee attack
			return
		if(target == user && user.zone_selected != "mouth") //so we can't shoot ourselves (unless mouth selected)
			return

	if(istype(user))//Check if the user can use the gun, if the user isn't alive(turrets) assume it can.
		var/mob/living/L = user
		if(!can_trigger_gun(L))
			return

	if(!can_shoot()) //Just because you can pull the trigger doesn't mean it can shoot.
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
				to_chat(user, "<span class='userdanger'>You shoot yourself in the foot with [src]!</span>")
				var/shot_leg = pick("l_leg", "r_leg")
				process_fire(user,user,0,params, zone_override = shot_leg)
				user.drop_item()
				return

	if(weapon_weight == WEAPON_HEAVY && user.get_inactive_held_item())
		to_chat(user, "<span class='userdanger'>You need both hands free to fire [src]!</span>")
		return

	//DUAL (or more!) WIELDING
	var/bonus_spread = 0
	var/loop_counter = 0
	if(ishuman(user) && user.a_intent == INTENT_HARM)
		var/mob/living/carbon/human/H = user
		for(var/obj/item/weapon/gun/G in H.held_items)
			if(G == src || G.weapon_weight >= WEAPON_MEDIUM)
				continue
			else if(G.can_trigger_gun(user))
				bonus_spread += 24 * G.weapon_weight
				loop_counter++
				addtimer(CALLBACK(G, /obj/item/weapon/gun.proc/process_fire, target, user, 1, params, null, bonus_spread), loop_counter)

	process_fire(target,user,1,params, null, bonus_spread)



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
		to_chat(user, "<span class='warning'>[src]'s trigger is locked. This weapon doesn't have a firing pin installed!</span>")
	return 0

/obj/item/weapon/gun/proc/recharge_newshot()
	return

/obj/item/weapon/gun/proc/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override, bonus_spread = 0)
	add_fingerprint(user)

	if(semicd)
		return

	var/sprd = 0
	var/randomized_gun_spread = 0
	var/rand_spr = rand()
	if(spread)
		randomized_gun_spread =	rand(0,spread)
	var/randomized_bonus_spread = rand(0, bonus_spread)

	if(burst_size > 1)
		firing_burst = 1
		for(var/i = 1 to burst_size)
			if(!user)
				break
			if(!issilicon(user))
				if( i>1 && !(user.is_holding(src))) //for burst firing
					break
			if(chambered && chambered.BB)
				if(randomspread)
					sprd = round((rand() - 0.5) * DUALWIELD_PENALTY_EXTRA_MULTIPLIER * (randomized_gun_spread + randomized_bonus_spread))
				else //Smart spread
					sprd = round((((rand_spr/burst_size) * i) - (0.5 + (rand_spr * 0.25))) * (randomized_gun_spread + randomized_bonus_spread))

				if(!chambered.fire_casing(target, user, params, ,suppressed, zone_override, sprd))
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
			sprd = round((rand() - 0.5) * DUALWIELD_PENALTY_EXTRA_MULTIPLIER * (randomized_gun_spread + randomized_bonus_spread))
			if(!chambered.fire_casing(target, user, params, , suppressed, zone_override, sprd))
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
		user.update_inv_hands()
	SSblackbox.add_details("gun_fired","[src.type]")
	return 1

/obj/item/weapon/gun/update_icon()
	..()
	cut_overlays()
	if(gun_light && can_flashlight)
		var/state = "flight[gun_light.on? "_on":""]"	//Generic state.
		if(gun_light.icon_state in icon_states('icons/obj/guns/flashlights.dmi'))	//Snowflake state?
			state = gun_light.icon_state
		var/mutable_appearance/flashlight_overlay = mutable_appearance('icons/obj/guns/flashlights.dmi', state)
		flashlight_overlay.pixel_x = flight_x_offset
		flashlight_overlay.pixel_y = flight_y_offset
		add_overlay(flashlight_overlay)
	if(bayonet && can_bayonet)
		var/state = "bayonet"							//Generic state.
		if(bayonet.icon_state in icon_states('icons/obj/guns/bayonets.dmi'))		//Snowflake state?
			state = bayonet.icon_state
		var/mutable_appearance/knife_overlay = mutable_appearance('icons/obj/guns/bayonets.dmi', state)
		knife_overlay.pixel_x = knife_x_offset
		knife_overlay.pixel_y = knife_y_offset
		add_overlay(knife_overlay)

/obj/item/weapon/gun/attack(mob/M as mob, mob/user)
	if(user.a_intent == INTENT_HARM) //Flogging
		if(bayonet)
			M.attackby(bayonet, user)
			return
		else
			return ..()
	return

/obj/item/weapon/gun/attack_obj(obj/O, mob/user)
	if(user.a_intent == INTENT_HARM)
		if(bayonet)
			O.attackby(bayonet, user)
			return
	return ..()

/obj/item/weapon/gun/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	else if(istype(I, /obj/item/device/flashlight/seclite))
		if(!can_flashlight)
			return ..()
		var/obj/item/device/flashlight/seclite/S = I
		if(!gun_light)
			if(!user.transferItemToLoc(I, src))
				return
			to_chat(user, "<span class='notice'>You click \the [S] into place on \the [src].</span>")
			if(S.on)
				set_light(0)
			gun_light = S
			update_icon()
			update_gunlight(user)
			alight = new /datum/action/item_action/toggle_gunlight(src)
			if(loc == user)
				alight.Grant(user)
	else if(istype(I, /obj/item/weapon/kitchen/knife))
		if(!can_bayonet)
			return ..()
		var/obj/item/weapon/kitchen/knife/K = I
		if(!bayonet)
			if(!user.transferItemToLoc(I, src))
				return
			to_chat(user, "<span class='notice'>You attach \the [K] to the front of \the [src].</span>")
			bayonet = K
			update_icon()
	else if(istype(I, /obj/item/weapon/screwdriver))
		if(gun_light)
			var/obj/item/device/flashlight/seclite/S = gun_light
			to_chat(user, "<span class='notice'>You unscrew the seclite from \the [src].</span>")
			gun_light = null
			S.forceMove(get_turf(user))
			update_gunlight(user)
			S.update_brightness(user)
			update_icon()
			QDEL_NULL(alight)
		if(bayonet)
			var/obj/item/weapon/kitchen/knife/K = bayonet
			K.forceMove(get_turf(user))
			bayonet = null
			update_icon()
	else
		return ..()

/obj/item/weapon/gun/proc/toggle_gunlight()
	if(!gun_light)
		return

	var/mob/living/carbon/human/user = usr
	gun_light.on = !gun_light.on
	to_chat(user, "<span class='notice'>You toggle the gunlight [gun_light.on ? "on":"off"].</span>")

	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_gunlight(user)
	return

/obj/item/weapon/gun/proc/update_gunlight(mob/user = null)
	if(gun_light)
		if(gun_light.on)
			set_light(gun_light.brightness_on)
		else
			set_light(0)
		update_icon()
	else
		set_light(0)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()


/obj/item/weapon/gun/pickup(mob/user)
	..()
	if(azoom)
		azoom.Grant(user)
	if(alight)
		alight.Grant(user)

/obj/item/weapon/gun/dropped(mob/user)
	..()
	zoom(user,FALSE)
	if(azoom)
		azoom.Remove(user)
	if(alight)
		alight.Remove(user)

/obj/item/weapon/gun/proc/handle_suicide(mob/living/carbon/human/user, mob/living/carbon/human/target, params)
	if(!ishuman(user) || !ishuman(target))
		return

	if(semicd)
		return

	if(user == target)
		target.visible_message("<span class='warning'>[user] sticks [src] in [user.p_their()] mouth, ready to pull the trigger...</span>", \
			"<span class='userdanger'>You stick [src] in your mouth, ready to pull the trigger...</span>")
	else
		target.visible_message("<span class='warning'>[user] points [src] at [target]'s head, ready to pull the trigger...</span>", \
			"<span class='userdanger'>[user] points [src] at your head, ready to pull the trigger...</span>")

	semicd = 1

	if(!do_mob(user, target, 120) || user.zone_selected != "mouth")
		if(user)
			if(user == target)
				user.visible_message("<span class='notice'>[user] decided not to shoot.</span>")
			else if(target && target.Adjacent(user))
				target.visible_message("<span class='notice'>[user] has decided to spare [target]</span>", "<span class='notice'>[user] has decided to spare your life!</span>")
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
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_LYING
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

		user.client.change_view(zoom_out_amt)
		user.client.pixel_x = world.icon_size*_x
		user.client.pixel_y = world.icon_size*_y
	else
		user.client.change_view(world.view)
		user.client.pixel_x = 0
		user.client.pixel_y = 0
	return zoomed

//Proc, so that gun accessories/scopes/etc. can easily add zooming.
/obj/item/weapon/gun/proc/build_zooming()
	if(azoom)
		return

	if(zoomable)
		azoom = new()
		azoom.gun = src
