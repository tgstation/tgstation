/datum/component/glitch
	/// Ref of the spawning forge
	var/datum/weakref/forge_ref

/datum/component/glitch/Initialize(obj/machinery/quantum_server/server, obj/machinery/byteforge/forge)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	forge_ref = WEAKREF(forge)
	forge.setup_particles(angry = TRUE)

	var/mob/living/owner = parent

	owner.fully_heal()
	owner.maxHealth += ROUND_UP(server.threat * 0.1)
	owner.add_digital_aura()

/datum/component/glitch/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_LIVING_STATUS_UNCONSCIOUS, COMSIG_LIVING_DEATH), PROC_REF(on_death))

/datum/component/glitch/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/// Sakujo
/datum/component/glitch/proc/dust_mob()
	if(QDELETED(parent))
		return

	var/mob/living/owner = parent

	owner.dust()

	var/obj/machinery/byteforge/forge = forge_ref.resolve()
	if(forge)
		forge.setup_particles()

/// We don't want digital entities just lingering around as corpses.
/datum/component/glitch/proc/on_death()
	SIGNAL_HANDLER

	if(QDELETED(parent))
		return

	var/mob/living/owner = parent
	to_chat(owner, span_userdanger("You feel a strange sensation..."))

	addtimer(CALLBACK(src, PROC_REF(dust_mob)), 2 SECONDS, TIMER_UNIQUE|TIMER_DELETE_ME|TIMER_STOPPABLE)

/// Appearance helper proc for bitrunning glitches.
/atom/proc/add_digital_aura()
	add_atom_colour(LIGHT_COLOR_DARK_PINK, FIXED_COLOUR_PRIORITY)
	add_overlay(mutable_appearance(icon = 'icons/effects/bitrunning.dmi', icon_state = "glitch"))
	alpha = 200
	set_light(2, l_color = LIGHT_COLOR_PALE_PINK, l_on = TRUE)
	update_appearance()

/// Removes any digital aura from the mob. Used in bitrunning glitches.
/atom/proc/remove_digital_aura()
	remove_atom_colour(LIGHT_COLOR_DARK_PINK)
	cut_overlays()
	alpha = 255
	set_light_on(FALSE)
	update_appearance()

