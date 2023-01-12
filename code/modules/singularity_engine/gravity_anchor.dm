/obj/item/gravity_anchor
	name = "handheld gravity anchor"
	desc = "A bulky monstrosity to be used in emergencies when the singularity needs its containment repaired, fast. Requires you to be up close and personal to the singularity, so it's not for the faint of heart."
	// MBTODO: Custom icon, different depending on if charged or not
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcl-0"
	inhand_icon_state = "rcl-0"
	force = 8
	throwforce = 6
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'

	VAR_PRIVATE
		heal_per_second = 3.4
		max_range = 5
		out_of_range_forgiveness = 3 SECONDS

		out_of_range_time = null
		wielded = FALSE

		datum/weakref/charger_ref

		datum/beam/captured_beam
		mob/living/current_user
		obj/contained_singularity/targeting_singularity

		datum/looping_sound/gravity_anchor_out_of_range/out_of_range_loop
		datum/looping_sound/gravity_anchor_loop/standard_loop

/obj/item/gravity_anchor/Initialize(mapload)
	. = ..()

	if (mapload)
		. = INITIALIZE_HINT_LATELOAD

	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_HANDS)
	AddComponent( \
		/datum/component/two_handed, \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)

	out_of_range_loop = new(src)
	standard_loop = new(src)

	return .

/obj/item/gravity_anchor/LateInitialize()
	. = ..()

	for (var/obj/machinery/gravity_anchor_charger/gravity_anchor_charger as anything in GLOB.mapload_gravity_anchor_chargers)
		if (gravity_anchor_charger.z != z)
			continue

		link_to_charger(gravity_anchor_charger)
		return

/obj/item/gravity_anchor/Destroy(force)
	halt()

	QDEL_NULL(out_of_range_loop)
	QDEL_NULL(standard_loop)

	return ..()

// MBTODO: Attack chargers
/obj/item/gravity_anchor/attack(mob/living/target_mob, mob/living/user, params)
	return ..()

/obj/item/gravity_anchor/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if (!isnull(targeting_singularity))
		return

	if (DOING_INTERACTION(user, REF(src)))
		return

	var/obj/contained_singularity/singularity = target

	if (!istype(singularity))
		return

	if (singularity.health / singularity.max_health >= 1)
		balloon_alert(user, "it's already fully contained!")
		return

	if (singularity.health <= 0)
		balloon_alert(current_user, "it's too late, run!")
		return

	if (!isnull(singularity.gravity_anchor))
		balloon_alert(user, "someone else is already anchoring the singularity, step back!")
		return

	var/obj/machinery/gravity_anchor_charger/charger = charger_ref?.resolve()
	if (isnull(charger))
		balloon_alert(user, "link to a charger!")
		return

	if (!charger.charging)
		balloon_alert(user, "charger isn't ready,\nit needs an anomaly core!")
		return

	if (!wielded)
		balloon_alert(user, "hold in two hands!")
		return

	if (!can_see(src, singularity, max_range))
		balloon_alert(user, "too far away!\nget closer, but be safe!")
		return

	if (!should_keep_going(user, singularity))
		balloon_alert(user, "get closer!")
		return

	target_singularity(user, singularity)

/obj/item/gravity_anchor/proc/target_singularity(mob/user, obj/contained_singularity/singularity)
	playsound(src, 'sound/items/gravity_anchor_charge.ogg', 70, vary = TRUE)

	balloon_alert(user, "charging up...")

	if (!isnull(captured_beam))
		stack_trace("captured_beam should've been cleared before target_singularity")
		QDEL_NULL(captured_beam)

	captured_beam = user.Beam(singularity, "medbeam")

	if (!do_after(user, 3 SECONDS, timed_action_flags = IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(should_keep_going), user, singularity), interaction_key = REF(src)))
		balloon_alert(user, "stay within range, and hold on!")
		QDEL_NULL(captured_beam)
		return

	ASSERT(!QDELETED(singularity))

	if (!singularity.set_anchor(src))
		QDEL_NULL(captured_beam)
		return

	targeting_singularity = singularity
	current_user = user

	captured_beam.set_icon_state("bsa_beam")

	standard_loop.start()

	START_PROCESSING(SSfastprocess, src)

#define LOS_CHECK_FAILED 2

/obj/item/gravity_anchor/proc/should_keep_going(mob/user, obj/contained_singularity/singularity, require_los = TRUE)
	var/static/list/los_blacklist_typecache = typecacheof(/obj/structure/railing)

	if (QDELETED(user) || QDELETED(singularity))
		return FALSE

	if (!wielded)
		return FALSE

	if (!(src in user.held_items))
		return FALSE

	if (get_dist(user, singularity) >= max_range * 5)
		return FALSE

	if (!can_see(src, singularity, max_range, los_blacklist_typecache))
		return require_los ? FALSE : LOS_CHECK_FAILED

	return TRUE

/obj/item/gravity_anchor/process(delta_time)
	if (QDELETED(targeting_singularity) || QDELETED(current_user))
		halt()
		return

	if (targeting_singularity.health / targeting_singularity.max_health >= 1)
		// MBTODO: tau_single from singularity
		balloon_alert(current_user, "singularity has reached max containment")
		halt()
		return

	if (targeting_singularity.health <= 0)
		balloon_alert(current_user, "it's too late, run!")
		halt()
		return

	var/proceed_result = should_keep_going(current_user, targeting_singularity, require_los = FALSE)

	switch (proceed_result)
		if (FALSE)
			play_break_sound()
			balloon_alert(current_user, "couldn't keep contact!")
			halt()
			return
		if (TRUE)
			if (!isnull(out_of_range_time))
				out_of_range_time = null
				out_of_range_loop.stop()
				captured_beam.set_icon_state("bsa_beam")

				balloon_alert(current_user, "hold on...")
		if (LOS_CHECK_FAILED)
			if (!isnull(out_of_range_time))
				if (world.time - out_of_range_time >= out_of_range_forgiveness)
					balloon_alert(current_user, "disconnected!")
					play_break_sound()
					halt()
				return

			out_of_range_time = world.time
			out_of_range_loop.start()
			captured_beam.set_icon_state("sendbeam")

			balloon_alert(current_user, "out of range!\nget closer quick!")
			return

	targeting_singularity.health = clamp(targeting_singularity.health + heal_per_second * delta_time, 0, targeting_singularity.max_health)

#undef LOS_CHECK_FAILED

/obj/item/gravity_anchor/proc/play_break_sound()
	playsound(src, 'sound/items/gravity_anchor_break.ogg', 70, vary = TRUE)

/obj/item/gravity_anchor/proc/halt()
	targeting_singularity?.remove_anchor()
	targeting_singularity = null
	current_user = null

	QDEL_NULL(captured_beam)
	STOP_PROCESSING(SSfastprocess, src)

	out_of_range_loop.stop()
	standard_loop.stop()

/obj/item/gravity_anchor/proc/link_to_charger(obj/machinery/gravity_anchor_charger/charger)
	charger_ref = WEAKREF(charger)
	update_appearance()

// MBTODO: Make this balloon alert if you aren't charged
/obj/item/gravity_anchor/proc/on_wield()
	wielded = TRUE
	return

/obj/item/gravity_anchor/proc/on_unwield()
	wielded = FALSE
	return

/obj/item/gravity_anchor/proc/any_singularity_in_range()
	for (var/obj/contained_singularity as anything in GLOB.contained_singularities)
		if (can_see(src, contained_singularity, max_range))
			return TRUE

	return FALSE

GLOBAL_LIST_EMPTY(mapload_gravity_anchor_chargers)

/obj/machinery/gravity_anchor_charger
	name = "gravity anchor power source"
	desc = "Powers any handheld gravity anchors wirelessly connected to it. On the surface, it's a clever use of electromagnetic induction. In reality, it's to make sure someone else can try again when you fail."
	icon = 'icons/obj/engine/tesla_coil.dmi'
	icon_state = "grounding_rod0"
	density = TRUE

	idle_power_usage = 0

	var/charging = FALSE
	var/max_range = 8

/obj/machinery/gravity_anchor_charger/Initialize(mapload)
	. = ..()

	if (mapload)
		GLOB.mapload_gravity_anchor_chargers += src

	transform = transform.Scale(1, 2)
	transform = transform.Translate(0, 16)

	begin_charging()

/obj/machinery/gravity_anchor_charger/Destroy()
	GLOB.mapload_gravity_anchor_chargers -= src

	return ..()

/obj/machinery/gravity_anchor_charger/examine(mob/user)
	. = ..()

	if (charging)
		. += span_notice("[p_they(capitalized = TRUE)] [p_are()] currently charging, and will power any handheld gravity anchor connected to it.")
	else
		. += span_notice("[p_they(capitalized = TRUE)] need[p_s()] <b>an anomaly core</b> in order to begin charging.")

/obj/machinery/gravity_anchor_charger/update_icon_state()
	. = ..()

	icon_state = charging ? "grounding_rodhit" : "grounding_rod0"

/obj/machinery/gravity_anchor_charger/proc/begin_charging()
	charging = TRUE
	use_power = ACTIVE_POWER_USE

/obj/item/paper/fluff/gravity_anchor_instructions
	name = "gravity anchor instructions"
	default_raw_text = {"
The handheld gravity anchor is a critically important piece of equipment for the containment of the singularity. Although <b>extremely</b> dangerous to use, it repairs an enormous amount of containment, such as after an overclock.

<h3>Setup</h3>
Gravity anchors are too complex to work on their own, and need to be charged from the <b>gravity anchor power source</b>. You must have <b>an anomaly core</b> slotted into the power source. Acquire one from science.

<h3>Usage</h3>
<ul>
<li>Optional: Get a coworker ready to rescue you in case of failure.</li>
<li>Turn off the emitters to the singularity.</li>
<li>Enter the singularity bay. Ensure you have EVA equipment and artificial gravity, such as from the magnetic stability module.</li>
<li>Turn off a field generator, and walk close to the singularity. Wait for the gravity anchor to shake.</li>
<li>Equip with both hands, and fire directly into the singularity.</li>
<li><u>Run like hell.</u></li>
</ul>"}

/datum/looping_sound/gravity_anchor_out_of_range
	mid_sounds = 'sound/items/gravity_anchor_out_of_range_loop.ogg'
	mid_length = 0.73 SECONDS
	volume = 50
	pressure_affected = FALSE

/datum/looping_sound/gravity_anchor_loop
	mid_sounds = 'sound/items/gravity_anchor_loop.ogg'
	mid_length = 1.1 SECONDS
	volume = 50
	pressure_affected = FALSE
