/// This exists because for some reason only the combat indicator screen_loc is constantly set to initial
/atom/movable/screen/combattoggle/flashy/voidwalker
	screen_loc = ui_movi

/atom/movable/screen/space_camo
	name = "space camouflage toggle"
	icon = 'icons/hud/screen_voidwalker.dmi'
	icon_state = "camo_toggle"
	screen_loc = ui_above_movement

	/// Wheter or not we're toggled on or off
	var/invisibility_toggle = TRUE

/atom/movable/screen/space_camo/Click()
	if(!isliving(usr))
		return

	invisibility_toggle = !invisibility_toggle
	update_appearance()

	if(invisibility_toggle)
		REMOVE_TRAIT(usr, TRAIT_INVISIBILITY_BLOCKED, type)
	else
		ADD_TRAIT(usr, TRAIT_INVISIBILITY_BLOCKED, type)

/atom/movable/screen/space_camo/update_icon_state()
	icon_state = initial(icon_state) + (invisibility_toggle ? "" : "_off")
	return ..()

/atom/movable/screen/vomit_jump
	name = "vomit tracker"
	icon = 'icons/hud/screen_voidwalker.dmi'
	icon_state = "template"
	screen_loc = ui_mood
	/// So we can sort of loop through it
	var/index = 1

/atom/movable/screen/vomit_jump/Initialize(mapload, datum/hud/hud_owner)
	. = ..()

	var/icon/vomit_overlay = icon(/obj/effect/decal/cleanable/vomit/nebula::icon, pick(/obj/effect/decal/cleanable/vomit/nebula::random_icon_states))
	add_overlay(vomit_overlay)

/atom/movable/screen/vomit_jump/examine(mob/user)
	. = ..()

	var/list/vomits = get_valid_vomits()

	. += span_notice("Отслеживает все случаи рвоты туманностью, вызванные людьми, к которым вы прикасались.")
	. += span_notice("Щёлкните левой кнопкой мыши, находясь в космическом погружении, чтобы переместиться к рвоте туманности, если таковая имеется.")
	. += span_notice("Текущие рвоты туманности: [vomits.len]")


/atom/movable/screen/vomit_jump/proc/get_valid_vomits()
	var/list/valid_vomits = list()

	for(var/atom/movable/vomit as anything in GLOB.nebula_vomits)
		if(!is_station_level(vomit.z))
			continue

		valid_vomits += vomit
	return valid_vomits

/atom/movable/screen/vomit_jump/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, RIGHT_CLICK) || LAZYACCESS(modifiers, SHIFT_CLICK))
		usr.examinate(src)
		return

	if(!isliving(usr))
		return

	if(!istype(usr.loc, /obj/effect/dummy/phased_mob/space_dive))
		usr.balloon_alert(usr.declent_ru(NOMINATIVE), "должен находиться в состоянии космического погружения!")
		return

	var/list/vomits = get_valid_vomits()

	if(!vomits.len)
		usr.balloon_alert(usr.declent_ru(NOMINATIVE), "нет рвоты туманности!")
		return

	var/obj/effect/dummy/phased_mob/space_dive/holder = usr.loc

	index = (index % vomits.len) + 1

	holder.forceMove(get_step(vomits[index], pick(GLOB.alldirs)))
	usr.playsound_local(usr, 'sound/effects/phasein.ogg', 50, FALSE)
