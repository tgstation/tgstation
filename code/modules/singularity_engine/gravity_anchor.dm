/obj/item/gravity_anchor
	name = "handheld gravity anchor"
	desc = "A bulky monstrosity to be used in emergencies when the singularity needs its containment repaired, fast. Requires you to be up close and personal to the singularity, so it's not for the faint of heart."
	icon = 'icons/obj/singularity_content.dmi'
	icon_state = "gravity_anchor"
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
		max_range = 7
		out_of_range_forgiveness = 3 SECONDS

		out_of_range_time = null
		wielded = FALSE

		obj/machinery/gravity_anchor_charger/charger

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

	charger = null

	QDEL_NULL(out_of_range_loop)
	QDEL_NULL(standard_loop)

	return ..()

/obj/item/gravity_anchor/examine(mob/user)
	. = ..()

	if (isnull(charger))
		. += span_warning("[p_They()] need to be connected to a <b>gravity anchor charger</b>!")
	else if (charged())
		. += span_notice("[p_They()] [p_are()] infused with power, use [p_them()] while you can!")
	else
		. += span_warning("[p_They()] [p_are()] not ready to use, [p_their()] <b>gravity anchor charger</b> needs to be fitted with an <b>anomaly core</b>.")

	return .

/obj/item/gravity_anchor/pre_attack(atom/attacked_atom, mob/living/user, params)
	if (!istype(attacked_atom, /obj/machinery/gravity_anchor_charger))
		return ..()

	var/obj/machinery/gravity_anchor_charger/charger = attacked_atom

	if (src.charger == charger)
		balloon_alert(user, "already linked to this!")
		return TRUE

	balloon_alert(user, "linking to charger...")

	if (!do_after(user, 2.2 SECONDS, target = charger))
		return TRUE

	link_to_charger(charger)

	balloon_alert(user, "linked to charger[charged() ? "" : ",\nbut the charger needs an anomaly core"]")
	playsound(src, 'sound/machines/ping.ogg', 50, vary = TRUE)

	return TRUE

/obj/item/gravity_anchor/attackby(obj/item/attacking_item, mob/user, params)
	if (istype(attacking_item, /obj/item/raw_anomaly_core) || istype(attacking_item, /obj/item/assembly/signaler/anomaly))
		balloon_alert(user, "give this to the charger!")
		return TRUE

	return ..()

/obj/item/gravity_anchor/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if (!isnull(targeting_singularity))
		return NONE

	if (DOING_INTERACTION(user, REF(src)))
		return NONE

	var/obj/contained_singularity/singularity = interacting_with

	if (!istype(singularity))
		return NONE

	if (singularity.health / singularity.max_health >= 1)
		balloon_alert(user, "it's already fully contained!")
		return ITEM_INTERACT_BLOCKING

	if (singularity.health <= 0)
		balloon_alert(current_user, "it's too late, run!")
		return ITEM_INTERACT_BLOCKING

	if (!isnull(singularity.gravity_anchor))
		balloon_alert(user, "someone else is already anchoring the singularity, step back!")
		return ITEM_INTERACT_BLOCKING

	if (isnull(charger))
		balloon_alert(user, "link to a charger!")
		return ITEM_INTERACT_BLOCKING

	if (!charger.charging)
		balloon_alert(user, "charger isn't ready,\nit needs an anomaly core!")
		return ITEM_INTERACT_BLOCKING

	if (!wielded)
		balloon_alert(user, "hold in two hands!")
		return ITEM_INTERACT_BLOCKING

	if (!can_see(src, singularity, max_range))
		balloon_alert(user, "too far away!\nget closer, but be safe!")
		return ITEM_INTERACT_BLOCKING

	if (!should_keep_going(user, singularity))
		balloon_alert(user, "get closer!")
		return ITEM_INTERACT_BLOCKING

	target_singularity(user, singularity)
	return ITEM_INTERACT_SUCCESS

/obj/item/gravity_anchor/pickup(mob/user)
	. = ..()

	if (!charged())
		user.balloon_alert(user, "charge before using!")

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
		halt_with_side_effects()
		return

	if (targeting_singularity.health / targeting_singularity.max_health >= 1)
		balloon_alert(current_user, "singularity has reached max containment")
		playsound(targeting_singularity, 'sound/effects/singulo_fully_healed.ogg', 70, vary = FALSE, pressure_affected = FALSE)
		halt_with_side_effects()
		return

	if (targeting_singularity.health <= 0)
		balloon_alert(current_user, "it's too late, run!")
		halt_with_side_effects()
		return

	var/proceed_result = should_keep_going(current_user, targeting_singularity, require_los = FALSE)

	switch (proceed_result)
		if (FALSE)
			balloon_alert(current_user, "couldn't keep contact!")
			halt_with_side_effects()
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
					halt_with_side_effects()
				return

			out_of_range_time = world.time
			out_of_range_loop.start()
			captured_beam.set_icon_state("sendbeam")

			balloon_alert(current_user, "out of range!\nget closer quick!")
			return

	targeting_singularity.health = clamp(targeting_singularity.health + heal_per_second * delta_time, 0, targeting_singularity.max_health)

#undef LOS_CHECK_FAILED

/obj/item/gravity_anchor/proc/halt()
	targeting_singularity?.remove_anchor()
	targeting_singularity = null
	current_user = null

	QDEL_NULL(captured_beam)
	STOP_PROCESSING(SSfastprocess, src)

	out_of_range_loop.stop()
	standard_loop.stop()

/obj/item/gravity_anchor/proc/halt_with_side_effects()
	playsound(src, 'sound/items/gravity_anchor_break.ogg', 70, vary = TRUE)

	if (!charged())
		balloon_alert(current_user, "the last of the power putters out!")

	halt()

/obj/item/gravity_anchor/proc/link_to_charger(obj/machinery/gravity_anchor_charger/charger)
	src.charger = charger

	update_appearance()

	RegisterSignal(charger, COMSIG_GRAVITY_ANCHOR_CHARGER_CHARGED, PROC_REF(on_charger_charged))
	RegisterSignal(charger, COMSIG_GRAVITY_ANCHOR_CHARGER_LOST_CHARGE, PROC_REF(on_charger_lost_charge))
	RegisterSignal(charger, COMSIG_QDELETING, PROC_REF(on_charger_qdel))

/obj/item/gravity_anchor/update_icon_state()
	. = ..()

	icon_state = (charged() || !isnull(targeting_singularity)) ? "gravity_anchor_charged" : "gravity_anchor"

/obj/item/gravity_anchor/proc/charged()
	return charger?.charging

/obj/item/gravity_anchor/proc/on_charger_charged()
	SIGNAL_HANDLER

	if (!isnull(current_user))
		balloon_alert(current_user, "charged")

	update_appearance(UPDATE_ICON)

/obj/item/gravity_anchor/proc/on_charger_lost_charge()
	SIGNAL_HANDLER

	if (!isnull(current_user) && isnull(targeting_singularity))
		balloon_alert(current_user, "lost charge!")

	update_appearance(UPDATE_ICON)

/obj/item/gravity_anchor/proc/on_charger_qdel()
	SIGNAL_HANDLER

	charger = null
	update_appearance(UPDATE_ICON)

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
	icon = 'icons/obj/machines/engine/tesla_coil.dmi'
	icon_state = "grounding_rod0"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/gravity_anchor_charger

	idle_power_usage = 0
	processing_flags = START_PROCESSING_MANUALLY

	var/stop_timer_id
	var/charging = FALSE
	var/max_range = 8

/obj/machinery/gravity_anchor_charger/Initialize(mapload)
	. = ..()

	if (mapload)
		GLOB.mapload_gravity_anchor_chargers += src

	transform = transform.Scale(1, 2)
	transform = transform.Translate(0, 16)

/obj/machinery/gravity_anchor_charger/Destroy()
	GLOB.mapload_gravity_anchor_chargers -= src

	return ..()

/obj/machinery/gravity_anchor_charger/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if (istype(tool, /obj/item/raw_anomaly_core))
		balloon_alert(user, "needs to be refined, ask science!")
		return ITEM_INTERACT_BLOCKING

	if (!istype(tool, /obj/item/assembly/signaler/anomaly))
		return NONE

	if (DOING_INTERACTION_WITH_TARGET(user, src))
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "slotting in anomaly core...")

	if (!do_after(user, 3 SECONDS, src))
		return ITEM_INTERACT_BLOCKING

	if (QDELETED(tool))
		return ITEM_INTERACT_BLOCKING

	if (charging)
		return ITEM_INTERACT_BLOCKING

	begin_charging()

	balloon_alert_to_viewers("it charges up,\nuse it while you can")
	begin_processing()

	stop_timer_id = addtimer(CALLBACK(src, PROC_REF(stop_charging)), 3 MINUTES, TIMER_DELETE_ME | TIMER_STOPPABLE)

	qdel(tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/gravity_anchor_charger/examine(mob/user)
	. = ..()

	if (charging)
		. += span_notice("[p_They()] [p_are()] currently charging, and will power any handheld gravity anchor connected to it.")
	else
		. += span_notice("[p_They()] need[p_s()] <b>an anomaly core</b> in order to begin charging.")

/obj/machinery/gravity_anchor_charger/update_appearance(updates)
	. = ..()
	update_maptext()

/obj/machinery/gravity_anchor_charger/update_icon_state()
	. = ..()

	icon_state = charging ? "grounding_rodhit" : "grounding_rod0"

/obj/machinery/gravity_anchor_charger/process()
	update_maptext()

/obj/machinery/gravity_anchor_charger/proc/update_maptext()
	if (isnull(stop_timer_id))
		maptext = ""
	else
		var/total_time = timeleft(stop_timer_id) / (1 SECONDS)
		var/minutes = round(total_time / 60)
		var/seconds = round(total_time % 60)

		maptext = MAPTEXT("[minutes > 0 ? "[minutes]m" : ""][seconds]s")

/obj/machinery/gravity_anchor_charger/proc/begin_charging()
	charging = TRUE
	use_power = ACTIVE_POWER_USE
	update_appearance(UPDATE_ICON)
	SEND_SIGNAL(src, COMSIG_GRAVITY_ANCHOR_CHARGER_CHARGED)

/obj/machinery/gravity_anchor_charger/proc/stop_charging()
	charging = FALSE
	use_power = IDLE_POWER_USE
	update_appearance(UPDATE_ICON)
	balloon_alert_to_viewers("it's out of charge!")
	end_processing()
	SEND_SIGNAL(src, COMSIG_GRAVITY_ANCHOR_CHARGER_LOST_CHARGE)

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

/datum/design/gravity_anchor
	name = "Handheld Gravity Anchor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 6000)
	build_path = /obj/item/gravity_anchor
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MACHINERY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/gravity_anchor_charger
	name = "Gravity Anchor Power Source"
	build_path = /obj/item/circuitboard/machine/gravity_anchor_charger
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_MACHINE_ENGINEERING,
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/obj/item/circuitboard/machine/gravity_anchor_charger
	name = "Gravity Anchor Power Source"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/gravity_anchor_charger
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 2,
	)
