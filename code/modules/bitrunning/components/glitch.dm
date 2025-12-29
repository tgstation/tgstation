/datum/component/glitch
	/// Ref of the spawning forge
	var/datum/weakref/forge_ref
	var/datum/weakref/distort_component

/datum/component/glitch/Initialize(obj/machinery/quantum_server/server, obj/machinery/byteforge/forge)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/owner = parent
	var/health_boost = 0

	if (forge)
		RegisterSignal(forge, COMSIG_MACHINERY_POWER_RESTORED, PROC_REF(on_forge_power_restored))
		RegisterSignals(forge, list(COMSIG_MACHINERY_BROKEN, COMSIG_MACHINERY_POWER_LOST), PROC_REF(on_forge_broken))
		forge_ref = WEAKREF(forge)
		server.remove_threat(owner) // so the server doesn't dust us
		health_boost = ROUND_UP(server.threat * 0.2)

	owner.faction.Cut()
	owner.faction += list(ROLE_GLITCH)

	owner.maxHealth = clamp(owner.maxHealth + health_boost, 200, 500)
	owner.fully_heal()
	owner.create_digital_aura()

/datum/component/glitch/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	distort_component = WEAKREF(parent.AddComponent(/datum/component/holographic_nature))

/datum/component/glitch/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_DEATH)
	QDEL_NULL(distort_component)

/// We don't want digital entities just lingering around as corpses.
/datum/component/glitch/proc/on_death()
	SIGNAL_HANDLER

	if(QDELETED(parent))
		return

	var/mob/living/owner = parent
	to_chat(owner, span_userdanger("You feel a strange sensation..."))

	var/obj/machinery/byteforge/forge = forge_ref?.resolve()
	forge?.setup_particles()

	owner.fade_into_nothing(3 SECONDS, 2 SECONDS)

/// If the forge breaks, we take a massive slowdown
/datum/component/glitch/proc/on_forge_broken(datum/source)
	SIGNAL_HANDLER

	var/mob/living/player = parent
	var/atom/movable/screen/alert/bitrunning/alert = player.throw_alert(
		ALERT_BITRUNNER_GLITCH,
		/atom/movable/screen/alert/bitrunning,
		new_master = source,
	)
	alert.name = "Source Broken"
	alert.desc = "Our byteforge has been broken."

	if(!iscarbon(parent)) // Too powerful!
		return

	player.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/glitch_slowdown)
	to_chat(player, span_danger("Your body feels sluggish..."))

/// Power restored
/datum/component/glitch/proc/on_forge_power_restored(datum/source)
	SIGNAL_HANDLER

	var/obj/machinery/byteforge/forge = source
	forge.setup_particles(angry = TRUE)

	if(!iscarbon(parent))
		return

	var/mob/living/player = parent
	player.clear_alert(ALERT_BITRUNNER_GLITCH)
	player.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/glitch_slowdown)

/datum/movespeed_modifier/status_effect/glitch_slowdown
	multiplicative_slowdown = 1.5
