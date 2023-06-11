
/// Cult Bastard Sword, earned by cultists when they manage to sacrifice a heretic.
/obj/item/cult_bastard
	name = "bloody bastard sword"
	desc = "An enormous sword used by Nar'Sien cultists to rapidly harvest the souls of non-believers."
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 20
	force = 35
	armour_penetration = 45
	throw_speed = 1
	throw_range = 3
	sharpness = SHARP_EDGED
	light_color = "#ff0000"
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")
	icon = 'icons/obj/cult/items_and_weapons.dmi'
	icon_state = "cultbastard"
	inhand_icon_state = "cultbastard"
	hitsound = 'sound/weapons/bladeslice.ogg'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	actions_types = list()
	item_flags = SLOWS_WHILE_IN_HAND
	attack_style = /datum/attack_style/melee_weapon/swing // melbert todo : maybe a unique style for spin2win
	weapon_sprite_angle = 45
	blocking_ability = 1.2
	block_effect = /obj/effect/temp_visual/cult/sparks
	block_sound = 'sound/weapons/parry.ogg'

	///if we are using our attack_self ability
	var/spinning = FALSE

/obj/item/cult_bastard/Initialize(mapload)
	. = ..()
	set_light(4)
	AddComponent(/datum/component/butchering, 50, 80)
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)
	AddComponent(/datum/component/soul_stealer)
	AddComponent( \
		/datum/component/spin2win, \
		spin_cooldown_time = 25 SECONDS, \
		on_spin_callback = CALLBACK(src, PROC_REF(on_spin)), \
		on_unspin_callback = CALLBACK(src, PROC_REF(on_unspin)), \
		start_spin_message = span_danger("%USER begins swinging the sword around with inhuman strength!"), \
		end_spin_message = span_warning("%USER's inhuman strength dissipates and the sword's runes grow cold!") \
	)

/obj/item/cult_bastard/proc/on_spin(mob/living/user, duration)
	var/oldcolor = user.color
	user.color = "#ff0000"
	user.add_stun_absorption("bloody bastard sword", duration, 2, "doesn't even flinch as the sword's power courses through them!", "You shrug off the stun!", " glowing with a blazing red aura!")
	user.spin(duration, 1)
	animate(user, color = oldcolor, time = duration, easing = EASE_IN)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/atom, update_atom_colour)), duration)
	blocking_ability = 0
	user.begin_blocking(src)
	slowdown += 1.5
	spinning = TRUE

/obj/item/cult_bastard/proc/on_unspin(mob/living/user)
	blocking_ability = initial(blocking_ability)
	user.stop_blocking()
	slowdown -= 1.5
	spinning = FALSE

/obj/item/cult_bastard/can_be_pulled(user)
	return FALSE

/obj/item/cult_bastard/pickup(mob/living/user)
	. = ..()
	if(!IS_CULTIST(user))
		if(!IS_HERETIC(user))
			to_chat(user, "<span class='cultlarge'>\"I wouldn't advise that.\"</span>")
			force = 5
			return
		else
			to_chat(user, span_cultlarge("\"You cling to the Forgotten Gods, as if you're more than their pawn.\""))
			to_chat(user, span_userdanger("A horrible force yanks at your arm!"))
			user.emote("scream")
			user.apply_damage(30, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
			user.dropItemToGround(src, TRUE)
			user.Paralyze(50)
			return
	force = initial(force)

/obj/item/cult_bastard/IsReflect(def_zone)
	if(!spinning)
		return FALSE
	return TRUE

/obj/item/cult_bastard/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(!prob(final_block_chance))
		return FALSE
	owner.visible_message(span_danger("[owner] parries [attack_text] with [src]!"))
	return TRUE

/obj/item/cult_bastard/get_blocking_ability(mob/living/blocker, atom/movable/hitby, damage, attack_type, damage_type)
	if(!IS_CULTIST(blocker))
		return 100

	return blocking_ability

/obj/item/cult_bastard/on_successful_block(mob/living/blocker, atom/movable/hitby, damage, attack_text, attack_type, damage_type)
	. = ..()
	if(IS_CULTIST(blocker))
		blocker.visible_message(
			span_danger("[blocker] parries [attack_text] with [src]!"),
			span_danger("You parry [attack_text] with [src]!"),
		)
	else
		blocker.visible_message(
			span_danger("[blocker] crumples over as [blocker.p_they()] attempt to block [attack_text]!"),
			span_cultlarge("\"Did you really think that would work?\""),
		)
	return TRUE
