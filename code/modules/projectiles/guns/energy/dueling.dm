#define DUEL_IDLE 1
#define DUEL_PREPARATION 2
#define DUEL_READY 3
#define DUEL_COUNTDOWN 4
#define DUEL_FIRING 5

//paper rock scissors
#define DUEL_SETTING_A "wide"
#define DUEL_SETTING_B "cone"
#define DUEL_SETTING_C "pinpoint"

/datum/duel
	var/obj/item/gun/energy/dueling/gun_A
	var/obj/item/gun/energy/dueling/gun_B
	var/state = DUEL_IDLE
	var/required_distance = 5
	var/list/confirmations = list()
	var/list/fired = list()
	var/countdown_length = 10
	var/countdown_step = 0
	var/pairing_code = ""

/datum/duel/New(new_gun_A, new_gun_B)
	pairing_code = assign_random_name()

	gun_A = new_gun_A
	gun_B = new_gun_B
	gun_A.duel = src
	gun_B.duel = src

	. = ..()

/datum/duel/proc/try_begin()
	//Check if both guns are held and if so begin.
	var/mob/living/A = get_duelist(gun_A)
	var/mob/living/B = get_duelist(gun_B)
	if(!A || !B)
		message_duelists(span_warning("To begin the duel, both participants need to be holding paired dueling pistols."))
		return
	begin()

/datum/duel/proc/begin()
	state = DUEL_PREPARATION
	confirmations.Cut()
	fired.Cut()
	countdown_step = countdown_length

	message_duelists(span_notice("Set your gun setting and move [required_distance] steps away from your opponent."))

	START_PROCESSING(SSobj,src)

/datum/duel/proc/get_duelist(obj/gun)
	var/mob/living/G = gun.loc
	if(!istype(G) || !G.is_holding(gun))
		return null
	return G

/datum/duel/proc/message_duelists(message)
	var/mob/living/LA = get_duelist(gun_A)
	if(LA)
		to_chat(LA,message)
	var/mob/living/LB = get_duelist(gun_B)
	if(LB)
		to_chat(LB,message)

/datum/duel/proc/other_gun(obj/item/gun/energy/dueling/G)
	return G == gun_A ? gun_B : gun_A

/datum/duel/proc/end()
	message_duelists(span_notice("Duel finished. Re-engaging safety."))
	STOP_PROCESSING(SSobj,src)
	state = DUEL_IDLE

/datum/duel/process()
	switch(state)
		if(DUEL_PREPARATION)
			if(check_positioning())
				confirm_positioning()
			else if (!get_duelist(gun_A) && !get_duelist(gun_B))
				end()
		if(DUEL_READY)
			if(!check_positioning())
				back_to_prep()
			else if(confirmations.len == 2)
				confirm_ready()
		if(DUEL_COUNTDOWN)
			if(!check_positioning())
				back_to_prep()
			else
				countdown_step()
		if(DUEL_FIRING)
			if(check_fired())
				end()


/datum/duel/proc/back_to_prep()
	message_duelists(span_notice("Positions invalid. Please move to valid positions exactly [required_distance] steps away from each other to continue."))
	state = DUEL_PREPARATION
	confirmations.Cut()
	countdown_step = countdown_length

/datum/duel/proc/confirm_positioning()
	message_duelists(span_notice("Position confirmed. Confirm readiness by pulling the trigger once."))
	state = DUEL_READY

/datum/duel/proc/confirm_ready()
	message_duelists(span_notice("Readiness confirmed. Starting countdown. Commence firing at zero mark."))
	state = DUEL_COUNTDOWN

/datum/duel/proc/countdown_step()
	countdown_step--
	if(countdown_step == 0)
		state = DUEL_FIRING
		message_duelists(span_userdanger("Fire!"))
	else
		message_duelists(span_userdanger("[countdown_step]!"))

/datum/duel/proc/check_fired()
	if(fired.len == 2)
		return TRUE
	//Let's say if gun was dropped/stowed the user is finished
	if(!get_duelist(gun_A))
		return TRUE
	if(!get_duelist(gun_B))
		return TRUE
	return FALSE

/datum/duel/proc/check_positioning()
	var/mob/living/A = get_duelist(gun_A)
	var/mob/living/B = get_duelist(gun_B)
	if(!A || !B)
		return FALSE
	if(!isturf(A.loc) || !isturf(B.loc))
		return FALSE
	if(get_dist(A,B) != required_distance)
		return FALSE
	for(var/turf/T in get_line(get_turf(A),get_turf(B)))
		if(T.is_blocked_turf(TRUE))
			return FALSE
	return TRUE

///For each linked gun that still exists, clear its reference to us, then delete.
/datum/duel/proc/clear_duel()
	gun_A?.duel = null
	gun_B?.duel = null
	qdel(src)

/obj/item/gun/energy/dueling
	name = "dueling pistol"
	desc = "High-tech dueling pistol. Launches chaff and projectile according to preset settings."
	icon_state = "dueling_pistol"
	inhand_icon_state = "gun"
	ammo_x_offset = 2
	w_class = WEIGHT_CLASS_SMALL
	ammo_type = list(/obj/item/ammo_casing/energy/duel)
	automatic_charge_overlays = FALSE
	gun_flags = TURRET_INCOMPATIBLE
	var/unlocked = FALSE
	var/setting = DUEL_SETTING_A
	var/datum/duel/duel
	var/mutable_appearance/setting_overlay

/obj/item/gun/energy/dueling/Initialize(mapload)
	. = ..()
	setting_overlay = mutable_appearance(icon,setting_iconstate())
	add_overlay(setting_overlay)

/obj/item/gun/energy/dueling/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(W, /obj/item/gun/energy/dueling))
		var/obj/item/gun/energy/dueling/other_gun = W

		if(!check_valid_duel(user, FALSE) && !other_gun.check_valid_duel(user, FALSE))
			var/datum/duel/D = new(src, other_gun)
			to_chat(user,span_notice("Pairing established. Pairing code: [D.pairing_code]"))
			return

	return ..()

/obj/item/gun/energy/dueling/examine_more(mob/user)
	. = ..()
	if(check_valid_duel(user, FALSE))
		. += "The pairing code is: [duel.pairing_code]"
	else
		. += "[src] is currently unpaired."

/obj/item/gun/energy/dueling/proc/setting_iconstate()
	switch(setting)
		if(DUEL_SETTING_A)
			return "duel_red"
		if(DUEL_SETTING_B)
			return "duel_green"
		if(DUEL_SETTING_C)
			return "duel_blue"
	return "duel_red"

/obj/item/gun/energy/dueling/attack_self(mob/living/user)
	. = ..()
	if(!check_valid_duel(user, TRUE))
		return

	if(duel.state == DUEL_IDLE)
		duel.try_begin()
	else
		toggle_setting(user)

/obj/item/gun/energy/dueling/proc/toggle_setting(mob/living/user)
	switch(setting)
		if(DUEL_SETTING_A)
			setting = DUEL_SETTING_B
		if(DUEL_SETTING_B)
			setting = DUEL_SETTING_C
		if(DUEL_SETTING_C)
			setting = DUEL_SETTING_A
	to_chat(user,span_notice("You switch [src] setting to [setting] mode."))
	update_appearance()

/obj/item/gun/energy/dueling/update_overlays()
	. = ..()
	if(setting_overlay)
		setting_overlay.icon_state = setting_iconstate()
		. += setting_overlay

/obj/item/gun/energy/dueling/Destroy()
	. = ..()
	duel?.clear_duel()

/obj/item/gun/energy/dueling/can_trigger_gun(mob/living/user, akimbo_usage)
	if(akimbo_usage)
		return FALSE //not honorable.
	. = ..()
	if(!check_valid_duel(user, TRUE))
		return FALSE

	switch(duel.state)
		if(DUEL_FIRING)
			return . && !duel.fired[src]
		if(DUEL_READY)
			return .
		else
			to_chat(user,span_warning("[src] is locked. Wait for FIRE signal before shooting."))
			return FALSE

/obj/item/gun/energy/dueling/proc/is_duelist(mob/living/L)
	if(!istype(L))
		return FALSE
	if(!L.is_holding(duel.other_gun(src)))
		return FALSE
	return TRUE

/obj/item/gun/energy/dueling/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(!check_valid_duel(user, TRUE))
		return
	if(duel.state == DUEL_READY)
		duel.confirmations[src] = TRUE
		to_chat(user,span_notice("You confirm your readiness."))
		return
	else if(!is_duelist(target)) //I kinda want to leave this out just to see someone shoot a bystander or missing.
		to_chat(user,span_warning("[src] safety system prevents shooting anyone but your designated opponent."))
		return
	else
		duel.fired[src] = TRUE
		. = ..()

/obj/item/gun/energy/dueling/before_firing(target,user)
	var/obj/item/ammo_casing/energy/duel/D = chambered
	D.setting = setting

///Return a boolean of whether or not the pistol has a valid duel datum, if false optionally warn the user
/obj/item/gun/energy/dueling/proc/check_valid_duel(mob/living/user, do_warn)
	if(!duel)
		if(do_warn)
			to_chat(user,span_warning("[src] is currently unpaired."))
		return FALSE
	return TRUE

/obj/effect/temp_visual/dueling_chaff
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-old"
	duration = 30
	var/setting

/obj/effect/temp_visual/dueling_chaff/update_icon()
	. = ..()
	switch(setting)
		if(DUEL_SETTING_A)
			color = "red"
		if(DUEL_SETTING_B)
			color = "green"
		if(DUEL_SETTING_C)
			color = "blue"

//Casing

/obj/item/ammo_casing/energy/duel
	e_cost = 0 // Can't use the macro
	projectile_type = /obj/projectile/energy/duel
	var/setting

/obj/item/ammo_casing/energy/duel/ready_proj(atom/target, mob/living/user, quiet, zone_override)
	. = ..()
	var/obj/projectile/energy/duel/dueling_projectile = loaded_projectile
	dueling_projectile.setting = setting
	dueling_projectile.update_appearance()
	if(!isturf(target))
		dueling_projectile.set_homing_target(target)

/obj/item/ammo_casing/energy/duel/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	. = ..()
	var/obj/effect/temp_visual/dueling_chaff/chaff = new(get_turf(user))
	chaff.setting = setting
	chaff.update_appearance()

//Projectile

/obj/projectile/energy/duel
	name = "dueling beam"
	icon_state = "declone"
	reflectable = FALSE
	var/setting

/obj/projectile/energy/duel/update_icon()
	. = ..()
	switch(setting)
		if(DUEL_SETTING_A)
			color = "red"
		if(DUEL_SETTING_B)
			color = "green"
		if(DUEL_SETTING_C)
			color = "blue"

/obj/projectile/energy/duel/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/turf/T = get_turf(target)
	var/obj/effect/temp_visual/dueling_chaff/C = locate() in T
	if(C)
		var/counter_setting
		switch(setting)
			if(DUEL_SETTING_A)
				counter_setting = DUEL_SETTING_B
			if(DUEL_SETTING_B)
				counter_setting = DUEL_SETTING_C
			if(DUEL_SETTING_C)
				counter_setting = DUEL_SETTING_A
		if(C.setting == counter_setting)
			return BULLET_ACT_BLOCK

	var/mob/living/L = target
	if(!istype(target))
		return BULLET_ACT_BLOCK

	var/obj/item/bodypart/B = L.get_bodypart(BODY_ZONE_HEAD)
	B.dismember()
	qdel(B)

#undef DUEL_IDLE
#undef DUEL_PREPARATION
#undef DUEL_READY
#undef DUEL_COUNTDOWN
#undef DUEL_FIRING
#undef DUEL_SETTING_A
#undef DUEL_SETTING_B
#undef DUEL_SETTING_C
