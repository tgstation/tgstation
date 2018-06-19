
#define DUALWIELD_PENALTY_EXTRA_MULTIPLIER 1.4

/obj/item/gun
	name = "gun"
	desc = "It's a gun. It's pretty terrible, though."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL=2000)
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	force = 5
	item_flags = NEEDS_PERMIT
	attack_verb = list("struck", "hit", "bashed")

	var/fire_sound = "gunshot"
	var/suppressed = null					//whether or not a message is displayed when fired
	var/can_suppress = FALSE
	var/can_unsuppress = TRUE
	var/recoil = 0						//boom boom shake the room
	var/clumsy_check = TRUE
	var/obj/item/ammo_casing/chambered = null
	trigger_guard = TRIGGER_GUARD_NORMAL	//trigger guard on the weapon, hulks can't fire them with their big meaty fingers
	var/sawn_desc = null				//description change if weapon is sawn-off
	var/sawn_off = FALSE
	var/burst_size = 1					//how large a burst is
	var/fire_delay = 0					//rate of fire for burst firing and semi auto
	var/firing_burst = 0				//Prevent the weapon from firing again while already firing
	var/semicd = 0						//cooldown handler
	var/weapon_weight = WEAPON_LIGHT
	var/spread = 0						//Spread induced by the gun itself.
	var/randomspread = 1				//Set to 0 for shotguns. This is used for weapons that don't fire all their bullets at once.

	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'

	var/obj/item/firing_pin/pin = /obj/item/firing_pin //standard firing pin for most guns

	var/obj/item/flashlight/gun_light
	var/can_flashlight = 0
	var/obj/item/kitchen/knife/bayonet
	var/mutable_appearance/knife_overlay
	var/can_bayonet = FALSE
	var/datum/action/item_action/toggle_gunlight/alight
	var/mutable_appearance/flashlight_overlay

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

/obj/item/gun/Initialize()
	. = ..()
	if(pin)
		pin = new pin(src)
	if(gun_light)
		alight = new /datum/action/item_action/toggle_gunlight(src)
	build_zooming()


/obj/item/gun/CheckParts(list/parts_list)
	..()
	var/obj/item/gun/G = locate(/obj/item/gun) in contents
	if(G)
		G.forceMove(loc)
		QDEL_NULL(G.pin)
		visible_message("[G] can now fit a new pin, but the old one was destroyed in the process.", null, null, 3)
		qdel(src)

/obj/item/gun/examine(mob/user)
	..()
	if(pin)
		to_chat(user, "It has \a [pin] installed.")
	else
		to_chat(user, "It doesn't have a firing pin installed, and won't fire.")

/obj/item/gun/equipped(mob/living/user, slot)
	. = ..()
	if(zoomed && user.get_active_held_item() != src)
		zoom(user, FALSE) //we can only stay zoomed in if it's in our hands	//yeah and we only unzoom if we're actually zoomed using the gun!!

//called after the gun has successfully fired its chambered ammo.
/obj/item/gun/proc/process_chamber()
	return FALSE

//check if there's enough ammo/energy/whatever to shoot one time
//i.e if clicking would make it shoot
/obj/item/gun/proc/can_shoot()
	return TRUE

/obj/item/gun/proc/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, "<span class='danger'>*click*</span>")
	playsound(src, "gun_dry_fire", 30, 1)


/obj/item/gun/proc/shoot_live_shot(mob/living/user as mob|obj, pointblank = 0, mob/pbtarget = null, message = 1)
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

/obj/item/gun/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS))
		for(var/obj/O in contents)
			O.emp_act(severity)

/obj/item/gun/afterattack(atom/target, mob/living/user, flag, params)
	. = ..()
	if(firing_burst)
		return
	if(flag) //It's adjacent, is the user, or is on the user's person
		if(target in user.contents) //can't shoot stuff inside us.
			return
		if(!ismob(target) || user.a_intent == INTENT_HARM) //melee attack
			return
		if(target == user && user.zone_selected != BODY_ZONE_PRECISE_MOUTH) //so we can't shoot ourselves (unless mouth selected)
			return

	if(istype(user))//Check if the user can use the gun, if the user isn't alive(turrets) assume it can.
		var/mob/living/L = user
		if(!can_trigger_gun(L))
			return

	if(!can_shoot()) //Just because you can pull the trigger doesn't mean it can shoot.
		shoot_with_empty_chamber(user)
		return

	if(flag)
		if(user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
			handle_suicide(user, target, params)
			return


	//Exclude lasertag guns from the TRAIT_CLUMSY check.
	if(clumsy_check)
		if(istype(user))
			if (user.has_trait(TRAIT_CLUMSY) && prob(40))
				to_chat(user, "<span class='userdanger'>You shoot yourself in the foot with [src]!</span>")
				var/shot_leg = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
				process_fire(user, user, FALSE, params, shot_leg)
				user.dropItemToGround(src, TRUE)
				return

	if(weapon_weight == WEAPON_HEAVY && user.get_inactive_held_item())
		to_chat(user, "<span class='userdanger'>You need both hands free to fire [src]!</span>")
		return

	//DUAL (or more!) WIELDING
	var/bonus_spread = 0
	var/loop_counter = 0
	if(ishuman(user) && user.a_intent == INTENT_HARM)
		var/mob/living/carbon/human/H = user
		for(var/obj/item/gun/G in H.held_items)
			if(G == src || G.weapon_weight >= WEAPON_MEDIUM)
				continue
			else if(G.can_trigger_gun(user))
				bonus_spread += 24 * G.weapon_weight
				loop_counter++
				addtimer(CALLBACK(G, /obj/item/gun.proc/process_fire, target, user, TRUE, params, null, bonus_spread), loop_counter)

	process_fire(target, user, TRUE, params, null, bonus_spread)



/obj/item/gun/can_trigger_gun(mob/living/user)
	. = ..()
	if(!handle_pins(user))
		return FALSE

/obj/item/gun/proc/handle_pins(mob/living/user)
	if(pin)
		if(pin.pin_auth(user) || (pin.obj_flags & EMAGGED))
			return TRUE
		else
			pin.auth_fail(user)
			return FALSE
	else
		to_chat(user, "<span class='warning'>[src]'s trigger is locked. This weapon doesn't have a firing pin installed!</span>")
	return FALSE

/obj/item/gun/proc/recharge_newshot()
	return

/obj/item/gun/proc/process_burst(mob/living/user, atom/target, message = TRUE, params=null, zone_override = "", sprd = 0, randomized_gun_spread = 0, randomized_bonus_spread = 0, rand_spr = 0, iteration = 0)
	if(!user || !firing_burst)
		firing_burst = FALSE
		return FALSE
	if(!issilicon(user))
		if(iteration > 1 && !(user.is_holding(src))) //for burst firing
			firing_burst = FALSE
			return FALSE
	if(chambered && chambered.BB)
		if(user.has_trait(TRAIT_PACIFISM)) // If the user has the pacifist trait, then they won't be able to fire [src] if the round chambered inside of [src] is lethal.
			if(chambered.harmful) // Is the bullet chambered harmful?
				to_chat(user, "<span class='notice'> [src] is lethally chambered! You don't want to risk harming anyone...</span>")
				return
		if(randomspread)
			sprd = round((rand() - 0.5) * DUALWIELD_PENALTY_EXTRA_MULTIPLIER * (randomized_gun_spread + randomized_bonus_spread))
		else //Smart spread
			sprd = round((((rand_spr/burst_size) * iteration) - (0.5 + (rand_spr * 0.25))) * (randomized_gun_spread + randomized_bonus_spread))

		if(!chambered.fire_casing(target, user, params, ,suppressed, zone_override, sprd))
			shoot_with_empty_chamber(user)
			firing_burst = FALSE
			return FALSE
		else
			if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
				shoot_live_shot(user, 1, target, message)
			else
				shoot_live_shot(user, 0, target, message)
			if (iteration >= burst_size)
				firing_burst = FALSE
	else
		shoot_with_empty_chamber(user)
		firing_burst = FALSE
		return FALSE
	process_chamber()
	update_icon()
	return TRUE

/obj/item/gun/proc/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	add_fingerprint(user)

	if(semicd)
		return

	var/sprd = 0
	var/randomized_gun_spread = 0
	var/rand_spr = rand()
	if(spread)
		randomized_gun_spread =	rand(0,spread)
	if(user.has_trait(TRAIT_POOR_AIM)) //nice shootin' tex
		bonus_spread += 25
	var/randomized_bonus_spread = rand(0, bonus_spread)

	if(burst_size > 1)
		firing_burst = TRUE
		for(var/i = 1 to burst_size)
			addtimer(CALLBACK(src, .proc/process_burst, user, target, message, params, zone_override, sprd, randomized_gun_spread, randomized_bonus_spread, rand_spr, i), fire_delay * (i - 1))
	else
		if(chambered)
			if(user.has_trait(TRAIT_PACIFISM)) // If the user has the pacifist trait, then they won't be able to fire [src] if the round chambered inside of [src] is lethal.
				if(chambered.harmful) // Is the bullet chambered harmful?
					to_chat(user, "<span class='notice'> [src] is lethally chambered! You don't want to risk harming anyone...</span>")
					return
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
		semicd = TRUE
		addtimer(CALLBACK(src, .proc/reset_semicd), fire_delay)

	if(user)
		user.update_inv_hands()
	SSblackbox.record_feedback("tally", "gun_fired", 1, type)
	return TRUE

/obj/item/gun/update_icon()
	..()


/obj/item/gun/proc/reset_semicd()
	semicd = FALSE

/obj/item/gun/attack(mob/M as mob, mob/user)
	if(user.a_intent == INTENT_HARM) //Flogging
		if(bayonet)
			M.attackby(bayonet, user)
			return
		else
			return ..()
	return

/obj/item/gun/attack_obj(obj/O, mob/user)
	if(user.a_intent == INTENT_HARM)
		if(bayonet)
			O.attackby(bayonet, user)
			return
	return ..()

/obj/item/gun/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	else if(istype(I, /obj/item/flashlight/seclite))
		if(!can_flashlight)
			return ..()
		var/obj/item/flashlight/seclite/S = I
		if(!gun_light)
			if(!user.transferItemToLoc(I, src))
				return
			to_chat(user, "<span class='notice'>You click \the [S] into place on \the [src].</span>")
			if(S.on)
				set_light(0)
			gun_light = S
			update_gunlight(user)
			alight = new /datum/action/item_action/toggle_gunlight(src)
			if(loc == user)
				alight.Grant(user)
	else if(istype(I, /obj/item/kitchen/knife))
		if(!can_bayonet)
			return ..()
		var/obj/item/kitchen/knife/K = I
		if(!bayonet)
			if(!user.transferItemToLoc(I, src))
				return
			to_chat(user, "<span class='notice'>You attach \the [K] to the front of \the [src].</span>")
			bayonet = K
			var/state = "bayonet"							//Generic state.
			if(bayonet.icon_state in icon_states('icons/obj/guns/bayonets.dmi'))		//Snowflake state?
				state = bayonet.icon_state
			var/icon/bayonet_icons = 'icons/obj/guns/bayonets.dmi'
			knife_overlay = mutable_appearance(bayonet_icons, state)
			knife_overlay.pixel_x = knife_x_offset
			knife_overlay.pixel_y = knife_y_offset
			add_overlay(knife_overlay, TRUE)
	else if(istype(I, /obj/item/screwdriver))
		if(gun_light)
			var/obj/item/flashlight/seclite/S = gun_light
			to_chat(user, "<span class='notice'>You unscrew the seclite from \the [src].</span>")
			gun_light = null
			S.forceMove(get_turf(user))
			update_gunlight(user)
			S.update_brightness(user)
			QDEL_NULL(alight)
		if(bayonet)
			to_chat(user, "<span class='notice'>You unscrew the bayonet from \the [src].</span>")
			var/obj/item/kitchen/knife/K = bayonet
			K.forceMove(get_turf(user))
			bayonet = null
			cut_overlay(knife_overlay, TRUE)
			knife_overlay = null
	else
		return ..()

/obj/item/gun/proc/toggle_gunlight()
	if(!gun_light)
		return

	var/mob/living/carbon/human/user = usr
	gun_light.on = !gun_light.on
	to_chat(user, "<span class='notice'>You toggle the gunlight [gun_light.on ? "on":"off"].</span>")

	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_gunlight(user)
	return

/obj/item/gun/proc/update_gunlight(mob/user = null)
	if(gun_light)
		if(gun_light.on)
			set_light(gun_light.brightness_on)
		else
			set_light(0)
		cut_overlays(flashlight_overlay, TRUE)
		var/state = "flight[gun_light.on? "_on":""]"	//Generic state.
		if(gun_light.icon_state in icon_states('icons/obj/guns/flashlights.dmi'))	//Snowflake state?
			state = gun_light.icon_state
		flashlight_overlay = mutable_appearance('icons/obj/guns/flashlights.dmi', state)
		flashlight_overlay.pixel_x = flight_x_offset
		flashlight_overlay.pixel_y = flight_y_offset
		add_overlay(flashlight_overlay, TRUE)
	else
		set_light(0)
		cut_overlays(flashlight_overlay, TRUE)
		flashlight_overlay = null
	update_icon(TRUE)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/gun/pickup(mob/user)
	..()
	if(azoom)
		azoom.Grant(user)
	if(alight)
		alight.Grant(user)

/obj/item/gun/dropped(mob/user)
	..()
	if(zoomed)
		zoom(user,FALSE)
	if(azoom)
		azoom.Remove(user)
	if(alight)
		alight.Remove(user)

/obj/item/gun/proc/handle_suicide(mob/living/carbon/human/user, mob/living/carbon/human/target, params)
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

	semicd = TRUE

	if(!do_mob(user, target, 120) || user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		if(user)
			if(user == target)
				user.visible_message("<span class='notice'>[user] decided not to shoot.</span>")
			else if(target && target.Adjacent(user))
				target.visible_message("<span class='notice'>[user] has decided to spare [target]</span>", "<span class='notice'>[user] has decided to spare your life!</span>")
		semicd = FALSE
		return

	semicd = FALSE

	target.visible_message("<span class='warning'>[user] pulls the trigger!</span>", "<span class='userdanger'>[user] pulls the trigger!</span>")

	if(chambered && chambered.BB)
		chambered.BB.damage *= 5

	process_fire(target, user, TRUE, params)

/obj/item/gun/proc/unlock() //used in summon guns and as a convience for admins
	if(pin)
		qdel(pin)
	pin = new /obj/item/firing_pin

/////////////
// ZOOMING //
/////////////

/datum/action/toggle_scope_zoom
	name = "Toggle Scope"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_LYING
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	var/obj/item/gun/gun = null

/datum/action/toggle_scope_zoom/Trigger()
	gun.zoom(owner)

/datum/action/toggle_scope_zoom/IsAvailable()
	. = ..()
	if(!. && gun)
		gun.zoom(owner, FALSE)

/datum/action/toggle_scope_zoom/Remove(mob/living/L)
	gun.zoom(L, FALSE)
	..()


/obj/item/gun/proc/zoom(mob/living/user, forced_zoom)
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
		user.client.change_view(CONFIG_GET(string/default_view))
		user.client.pixel_x = 0
		user.client.pixel_y = 0
	return zoomed

//Proc, so that gun accessories/scopes/etc. can easily add zooming.
/obj/item/gun/proc/build_zooming()
	if(azoom)
		return

	if(zoomable)
		azoom = new()
		azoom.gun = src

/obj/item/gun/handle_atom_del(atom/A)
	if(A == chambered)
		chambered = null
		update_icon()
