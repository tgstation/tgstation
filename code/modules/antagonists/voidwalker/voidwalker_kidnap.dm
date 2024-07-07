/// Component that lets us space kidnap people as the voidwalker with our HAAAADS
/datum/component/space_kidnap
	/// How long does it take to kidnap them?
	var/kidnap_time = 6 SECONDS
	/// Are we kidnapping right now?
	var/kidnapping = FALSE

/datum/component/space_kidnap/Initialize(...)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(try_kidnap))

/datum/component/space_kidnap/proc/try_kidnap(mob/living/parent, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return

	var/mob/living/victim = target

	if(!victim.incapacitated() || !isspaceturf(get_turf(target)))
		return

	if(!kidnapping)
		INVOKE_ASYNC(src, PROC_REF(kidnap), parent, target)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/space_kidnap/proc/kidnap(mob/living/parent, mob/living/victim)
	victim.Paralyze(kidnap_time) //so they don't get up if we already got em
	var/obj/particles = new /obj/effect/abstract/particle_holder (victim, /particles/void_kidnap)
	kidnapping = TRUE

	if(do_after(parent, kidnap_time, victim, extra_checks = CALLBACK(victim, TYPE_PROC_REF(/mob, incapacitated))))
		take_them(victim)

	qdel(particles)
	kidnapping = FALSE

/datum/component/space_kidnap/proc/take_them(mob/living/victim)
	if(ishuman(victim))
		var/mob/living/carbon/human/hewmon = victim
		hewmon.gain_trauma(/datum/brain_trauma/voided)

	victim.flash_act(INFINITY, override_blindness_check = TRUE, visual = TRUE, type = /atom/movable/screen/fullscreen/flash/black)

	if(!SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_VOIDWALKER_VOID) || !GLOB.voidwalker_void.len)
		dump(victim)
		victim.heal_overall_damage(brute = 80, burn = 20)
		CRASH("[victim] was instantly dumped after being voidwalker kidnapped due to a missing landmark!")
	else
		new /obj/effect/wisp_mobile (pick(GLOB.voidwalker_void), victim)
		addtimer(CALLBACK(src, PROC_REF(dump), victim), 60 SECONDS)

/datum/component/space_kidnap/proc/dump(mob/living/trash)
	trash.forceMove(get_random_station_turf())

/// A global assoc list for the drop of point
GLOBAL_LIST_EMPTY(voidwalker_void)

/// Lardmarks meant to designate where voidwalker kidnapees are sent
/obj/effect/landmark/voidwalker_void
	name = "default voidwalker void landmark"
	icon_state = "x"

/obj/effect/landmark/voidwalker_void/Initialize(mapload)
	. = ..()
	GLOB.voidwalker_void += src

/// Voidwalker void where the people go
/area/centcom/voidwalker_void
	name = "Voidwalker void"
	icon_state = "voidwalker"
	has_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_ENVIRONMENT_CAVE
	area_flags = UNIQUE_AREA | NOTELEPORT | HIDDEN_AREA | BLOCK_SUICIDE

/// Mini car where people drive around in in their mangled corpse to heal a bit before they get dumped back on station
/obj/effect/wisp_mobile
	name = "wisp"

	icon = 'icons/obj/weapons/voidwalker_items.dmi'
	icon_state = "wisp"

	light_system = OVERLAY_LIGHT
	light_color = COLOR_WHITE
	light_range = 4
	light_power = 1
	light_on = TRUE

	/// Delay between movements
	var/move_delay = 0.5 SECONDS
	/// when can we move again?
	var/can_move
	/// what do we eatt?
	var/food_type = /obj/effect/wisp_food
	/// how much do we heal per food?
	var/heal_per_food = 10

/obj/effect/wisp_mobile/Initialize(mapload, mob/living/driver)
	. = ..()

	if(isliving(driver))
		driver.forceMove(src)
		driver.add_traits(list(TRAIT_STASIS, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT), REF(src))
		add_atom_colour(random_color(), FIXED_COLOUR_PRIORITY)

/obj/effect/wisp_mobile/relaymove(mob/living/user, direction)
	if(can_move >= world.time)
		return
	can_move = world.time + move_delay

	if(isturf(loc))
		can_move = world.time + move_delay
		try_step_multiz(direction)

/obj/effect/wisp_mobile/Cross(atom/movable/crossed_atom)
	. = ..()

	if(!istype(crossed_atom, food_type))
		return

	qdel(crossed_atom)

	// make new food
	var/area/our_area = get_area(src)
	new food_type(pick(get_area_turfs(our_area)))

	var/mob/living/driver = locate(/mob/living) in contents
	if(driver)
		driver.heal_ordered_damage(heal_per_food, list(BRUTE, BURN, OXY))
		playsound(src, 'sound/misc/server-ready.ogg', 50, TRUE, -1)

/obj/effect/wisp_mobile/Exited(atom/movable/gone, direction)
	. = ..()

	gone.remove_traits(list(TRAIT_STASIS, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT), REF(src))
	qdel(src)

/// we only exist to be eaten by wisps for food 😔👊
/obj/effect/wisp_food
	name = "wisp"
	icon = 'icons/obj/weapons/voidwalker_items.dmi'
	icon_state = "wisp"

	color = COLOR_YELLOW

	light_system = OVERLAY_LIGHT
	light_color = COLOR_WHITE
	light_range = 4
	light_power = 1
	light_on = TRUE

