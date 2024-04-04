
/// Implant used by the traitor Battle Royale objective, is not active immediately
/obj/item/implant/explosive/battle_royale
	name = "rumble royale implant"
	actions_types = null
	instant_explosion = FALSE
	master_implant = TRUE
	delay = 10 SECONDS
	panic_beep_sound = TRUE
	announce_activation = FALSE
	/// Where is this going to tell us to go to avoid death?
	var/target_area_name = ""
	/// Is this implant active yet?
	var/battle_started = FALSE
	/// Are we presently exploding?
	var/has_exploded = FALSE
	/// Reference to our applied camera component
	var/camera

/obj/item/implant/explosive/battle_royale/get_data()
	return "<b>Implant Specifications:</b><BR> \
		<b>Name:</b> Donk Co. 'Rumble Royale' Contestant Motivation Implant<BR> \
		<b>Life:</b> Activates upon death, or expiry of an internal timer.<BR> \
		<b>Important Notes:</b> Explodes.<BR> \
		<HR> \
		<b>Implant Details:</b><BR> \
		<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death. \
		Upon triggering the timer, the implant will begin to broadcast the surrounding area for the purposes of televised entertainment. This signal can be detected by GPS trackers.<BR> \
		<b>Special Features:</b> Exploding.<BR>"

/obj/item/implant/explosive/battle_royale/on_death(datum/source, gibbed)
	if (!battle_started)
		return
	return ..()

/obj/item/implant/explosive/battle_royale/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if (!.)
		return
	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	if (!battle_started)
		return
	name = "[name] - [imp_in.real_name]"
	camera = target.AddComponent( \
		/datum/component/simple_bodycam, \
		camera_name = "rumble royale tracker", \
		c_tag = "Competitor [target.real_name]", \
		network = BATTLE_ROYALE_CAMERA_NET, \
		emp_proof = TRUE, \
	)
	announce()

/obj/item/implant/explosive/battle_royale/removed(mob/target, silent, special)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_LIFE)
	QDEL_NULL(camera)
	if (has_exploded || QDELETED(src))
		return
	if (prob(75))
		target.visible_message(span_boldwarning("[src] beeps ominously."))
		playsound(loc, 'sound/items/timer.ogg', 50, vary = FALSE)
		explode()
	target?.mind?.remove_antag_datum(/datum/antagonist/survivalist/battle_royale)

/obj/item/implant/explosive/battle_royale/explode()
	has_exploded = TRUE
	return ..()

/// Give a slight tell
/obj/item/implant/explosive/battle_royale/proc/on_life(mob/living/source)
	SIGNAL_HANDLER
	if (prob(98))
		return
	if (!source.itch() || prob(80))
		return
	to_chat(source, span_boldwarning("You feel a lump which shouldn't be there."))

/// Start the battle royale
/obj/item/implant/explosive/battle_royale/proc/start_battle(target_area_name)
	if (isnull(imp_in))
		explode()
		return
	src.target_area_name = target_area_name
	battle_started = TRUE
	name = "[name] - [imp_in.real_name]"
	imp_in.AddComponent( \
		/datum/component/simple_bodycam, \
		camera_name = "rumble royale tracker", \
		c_tag = "Competitor [imp_in.real_name]", \
		network = BATTLE_ROYALE_CAMERA_NET, \
		emp_proof = TRUE, \
	)
	AddComponent(/datum/component/gps, "Rumble Royale - [imp_in.real_name]")
	playsound(loc, 'sound/items/timer.ogg', 50, vary = FALSE)

/// Add the antag datum to our new contestant, also printing some flavour text
/obj/item/implant/explosive/battle_royale/proc/announce()
	var/datum/antagonist/survivalist/battle_royale/royale = imp_in.mind?.add_antag_datum(/datum/antagonist/survivalist/battle_royale)
	royale?.set_target_area(target_area_name)
