
/// Cult Bastard Sword, earned by cultists when they manage to sacrifice a heretic.
/obj/item/cult_bastard
	name = "bloody bastard sword"
	desc = "An enormous sword used by Nar'Sien cultists to rapidly harvest the souls of non-believers."
	w_class = WEIGHT_CLASS_HUGE
	block_chance = 50
	throwforce = 20
	force = 35
	armour_penetration = 45
	throw_speed = 1
	throw_range = 3
	sharpness = IS_SHARP
	light_color = "#ff0000"
	attack_verb = list("cleaved", "slashed", "torn", "hacked", "ripped", "diced", "carved")
	icon_state = "cultbastard"
	item_state = "cultbastard"
	hitsound = 'sound/weapons/bladeslice.ogg'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	actions_types = list()
	item_flags = SLOWS_WHILE_IN_HAND
	var/spinning = FALSE
	var/spin_cooldown = 250

/obj/item/cult_bastard/Initialize()
	. = ..()
	set_light(4)
	AddComponent(/datum/component/butchering, 50, 80)
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)
	AddComponent(/datum/component/soul_stealer)
	AddComponent(
		/datum/component/right_click_spin2win,
		spin_cooldown_time = 25 SECONDS,
		on_spin_callback = CALLBACK(src, .proc/on_spin),
		on_unspin_callback = null,
		start_spin_message = span_danger("%USER begins swinging [parent] around with inhuman strength!"),
		end_spin_message = span_warning("%USER's inhuman strength dissipates and the sword's runes grow cold!")
	)

/obj/item/cult_bastard/proc/on_spin(mob/living/user, duration)
	var/oldcolor = user.color
	user.color = "#ff0000"
	user.add_stun_absorption("bloody bastard sword", duration, 2, "doesn't even flinch as the sword's power courses through them!", "You shrug off the stun!", " glowing with a blazing red aura!")
	user.spin(duration, 1)
	animate(user, color = oldcolor, time = duration, easing = EASE_IN)
	addtimer(CALLBACK(user, /atom/proc/update_atom_colour), duration)

/obj/item/cult_bastard/can_be_pulled(user)
	return FALSE

/obj/item/cult_bastard/pickup(mob/living/user)
	. = ..()
	if(!iscultist(user))
		if(!IS_HERETIC(user))
			to_chat(user, "<span class='cultlarge'>\"I wouldn't advise that.\"</span>")
			force = 5
			return
		else
			to_chat(user, "<span class='cultlarge'>\"You cling to the Forgotten Gods, as if you're more than their pawn.\"</span>")
			to_chat(user, "<span class='userdanger'>A horrible force yanks at your arm!</span>")
			user.emote("scream")
			user.apply_damage(30, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
			user.dropItemToGround(src, TRUE)
			user.Paralyze(50)
			return
	force = initial(force)

/obj/item/cult_bastard/IsReflect(def_zone)
	if(!spinning)
		return FALSE
	playsound(src, pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg'), 100, 1)
	return TRUE

/obj/item/cult_bastard/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!prob(final_block_chance))
		return FALSE
	if(attack_type == PROJECTILE_ATTACK)
		owner.visible_message("<span class='danger'>[owner] deflects [attack_text] with [src]!</span>")
		playsound(src, pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg'), 100, 1)
		return TRUE
	playsound(src, 'sound/weapons/parry.ogg', 75, 1)
	owner.visible_message("<span class='danger'>[owner] parries [attack_text] with [src]!</span>")
	return TRUE

/obj/item/cult_bastard/attack_secondary(mob/living/victim, mob/living/user, params)
	. = ..()


/datum/action/innate/cult/spin2win
	name = "Geometer's Fury"
	desc = "You draw on the power of the sword's ancient runes, spinning it wildly around you as you become immune to most attacks."
	background_icon_state = "bg_demon"
	button_icon_state = "sintouch"
	var/cooldown = 0
	var/mob/living/carbon/human/holder
	var/obj/item/twohanded/required/cult_bastard/sword

/datum/action/innate/cult/spin2win/Grant(mob/user, obj/bastard)
	. = ..()
	sword = bastard
	holder = user

/datum/action/innate/cult/spin2win/IsAvailable()
	if(iscultist(holder) && cooldown <= world.time)
		return TRUE
	return FALSE

/datum/action/innate/cult/spin2win/Activate()
	cooldown = world.time + sword.spin_cooldown
	holder.changeNext_move(50)
	holder.apply_status_effect(/datum/status_effect/sword_spin)
	sword.spinning = TRUE
	sword.block_chance = 100
	sword.slowdown += 1.5
	addtimer(CALLBACK(src, .proc/stop_spinning), 5 SECONDS)
	holder.update_action_buttons_icon()

/datum/action/innate/cult/spin2win/proc/stop_spinning()
	sword.spinning = FALSE
	sword.block_chance = 50
	sword.slowdown -= 1.5
	sleep(sword.spin_cooldown)
	holder.update_action_buttons_icon()
