GLOBAL_DATUM(current_eminence, /mob/living/eminence) //set to the current eminence, if more then one are somehow spawned then this will remain equal to the first created one

/mob/living/eminence //yes this should be a camera mob, that will not work because cameras are deaf
	name = "Eminence"
	real_name = "Eminence"
	desc = "An entity forever bound to Rat'var, acting upon his will."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_effects.dmi'
	icon_state = "eminence"
	mob_biotypes = list(MOB_SPIRIT)
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = TRUE
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	see_invisible = SEE_INVISIBLE_LIVING
	density = FALSE
	move_force = INFINITY
	move_resist = INFINITY
	status_flags = GODMODE
	sight = SEE_SELF
	incorporeal_move = INCORPOREAL_MOVE_BASIC
	initial_language_holder = /datum/language_holder/universal //lesser god, they CAN understand you
	hud_possible = list(ANTAG_HUD)

	//slight orange
	lighting_cutoff_red = 35
	lighting_cutoff_green = 20
	lighting_cutoff_blue = 0
	///how many cogs we have
	var/cogs = 0
	///our interal radio
	var/obj/item/radio/borg/eminence/internal_radio
	///a weakref to our marked servant
	var/datum/weakref/marked_servant
	///cooldown declare for our command sound, its sent on say(), so we dont want sound spam issues
	COOLDOWN_DECLARE(command_sound_cooldown)

/mob/living/eminence/Initialize(mapload)
	. = ..()
	if(!GLOB.current_eminence)
		GLOB.current_eminence = src
	cogs = GLOB.clock_installed_cogs
	AddElement(/datum/element/simple_flying)
	internal_radio = new /obj/item/radio/borg/eminence(src)

/mob/living/eminence/Destroy()
	if(GLOB.current_eminence == src)
		GLOB.current_eminence = null
	return ..()

/mob/living/eminence/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	var/turf/new_turf = get_turf(src)
	if(!istype(new_turf, /turf/open/indestructible/reebe_void/void_edge))
		return ..()

	to_chat(src, span_brass("Going this far into the void would leave you forever lost."))
	forceMove(old_loc)
	return FALSE


/mob/living/eminence/ClickOn(atom/clicked_on, params)
	. = ..()
	clicked_on.eminence_act(src)

/mob/living/eminence/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, message_range, datum/saymode/saymode)
	if(!message)
		return

	if(src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, span_boldwarning("You cannot send IC messages (muted)."))
			return
		if(!(ignore_spam || forced) && src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if(stat)
		return

	if(COOLDOWN_FINISHED(src, command_sound_cooldown))
		send_clock_message(src, span_bigbrass(message), sent_sound = 'monkestation/sound/effects/eminence_command.ogg')
		COOLDOWN_START(src, command_sound_cooldown, 40 SECONDS)
	else
		send_clock_message(src, span_bigbrass(message))

/mob/living/eminence/get_status_tab_items()
	. = ..()
	. += "Cogs: [cogs]"

/mob/living/eminence/start_pulling(atom/movable/AM, state, force, supress_message)
	return

/mob/living/eminence/canUseStorage()
	return FALSE

/mob/living/eminence/ignite_mob(silent)
	return

/mob/living/eminence/fire_act()
	return

/mob/living/eminence/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta)
	return

/mob/living/eminence/can_z_move(direction, turf/start, turf/destination, z_move_flags, mob/living/rider)
	z_move_flags |= ZMOVE_IGNORE_OBSTACLES
	return ..()

/mob/living/eminence/rad_act(intensity) //theradiationdemonisnotrealtheradiationdemoncannothurtyou
	return

/mob/living/eminence/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	return FALSE

//eminence_act() stuff, might be a better way to do this
/atom/proc/eminence_act(mob/living/eminence/user)
	SEND_SIGNAL(src, COMSIG_ATOM_EMINENCE_ACT, user)

/mob/living/eminence_act(mob/living/eminence/user)
	. = ..()
	if(IS_CLOCK(src))
		user.marked_servant = WEAKREF(src)
		to_chat(user, "You mark [src].")

/obj/structure/closet/eminence_act(mob/living/eminence/user)
	. = ..()
	if(do_after(user, 5 SECONDS, src))
		open(user, TRUE)

/obj/machinery/door/airlock/eminence_act(mob/living/eminence/user)
	. = ..()
	if(!do_after(user, 5 SECONDS, src))
		return
	if(seal)
		to_chat(user, span_warning("The [src] has been sealed and wont open!"))
		return
	if(locked)
		to_chat(user, span_warning("The airlock's bolts prevent it from being forced!"))
		return
	if(welded)
		to_chat(user, span_warning("It's welded, it won't budge!"))
		return
	if(!density)
		return

	open(BYPASS_DOOR_CHECKS)

/obj/machinery/door/window/eminence_act(mob/living/eminence/user)
	. = ..()
	if(!hasPower())
		to_chat(user, span_warning("The [src] has no power and wont open!"))
		return

	open(BYPASS_DOOR_CHECKS)

/obj/machinery/button/eminence_act(mob/living/eminence/user)
	. = ..()
	if(panel_open)
		to_chat(user, span_warning("The panel is open and preventing you from accessing the [src]!"))
		return

	use_power(5)
	icon_state = "[skin]1"

	if(device)
		device.pulsed(user)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_BUTTON_PRESSED,src)

	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/, update_appearance)), 15)

/obj/machinery/light/eminence_act(mob/living/eminence/user)
	. = ..()
	break_light_tube()

//Internal Radio
/obj/item/radio/borg/eminence
	name = "eminence internal listener"
	translate_binary = TRUE
	syndie = TRUE

/obj/item/radio/borg/eminence/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)
