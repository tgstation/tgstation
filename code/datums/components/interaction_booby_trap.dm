/**
 * Attached to an atom, creates an explosion when it is interacted with
 */
/datum/component/interaction_booby_trap
	/// Explosion radius of light damage
	var/explosion_light_range
	/// Explosion radius of heavy damage
	var/explosion_heavy_range
	/// Sound to play when triggered
	var/triggered_sound
	/// Time to wait between being triggered and blowing up
	var/trigger_delay
	/// Looping sound to clue people in that something is up
	var/datum/looping_sound/active_sound_loop
	/// Using this tool on the atom will defuse the explosive
	var/defuse_tool
	/// List of additional signals which should make this explode
	var/list/additional_triggers
	/// Callback to run when we're going to explode
	var/datum/callback/on_triggered_callback
	/// Callback to run when we've been defused
	var/datum/callback/on_defused_callback
	/// Time until we explode
	var/explode_timer

/datum/component/interaction_booby_trap/Initialize(
	explosion_light_range = 3,
	explosion_heavy_range = 1, // So we destroy some machine components
	triggered_sound = 'sound/machines/beep/triple_beep.ogg',
	trigger_delay = 0.5 SECONDS,
	sound_loop_type = /datum/looping_sound/trapped_machine_beep,
	defuse_tool = TOOL_SCREWDRIVER,
	additional_triggers = list(),
	datum/callback/on_triggered_callback = null,
	datum/callback/on_defused_callback = null,
)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.explosion_light_range = explosion_light_range
	src.explosion_heavy_range = explosion_heavy_range
	src.triggered_sound = triggered_sound
	src.trigger_delay = trigger_delay
	src.defuse_tool = defuse_tool
	src.additional_triggers = additional_triggers
	src.on_triggered_callback = on_triggered_callback
	src.on_defused_callback = on_defused_callback
	if (sound_loop_type)
		active_sound_loop = new sound_loop_type(parent)
		active_sound_loop.start()

	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_touched))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine))
	if (defuse_tool)
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(defuse_tool), PROC_REF(on_defused))
	if (length(additional_triggers))
		RegisterSignals(parent, additional_triggers, PROC_REF(trigger_explosive))

/datum/component/interaction_booby_trap/Destroy(force)
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_TOOL_ACT(defuse_tool), COMSIG_ATOM_EXAMINE_MORE) + additional_triggers)
	QDEL_NULL(active_sound_loop)
	on_triggered_callback = null
	on_defused_callback = null
	return ..()

/// Called when someone touches the parent atom with their hands, we want to blow up
/datum/component/interaction_booby_trap/proc/on_touched(atom/source)
	SIGNAL_HANDLER
	trigger_explosive(source)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Start a countdown until destruction
/datum/component/interaction_booby_trap/proc/trigger_explosive(atom/source)
	SIGNAL_HANDLER
	if (explode_timer)
		return
	explode_timer = addtimer(CALLBACK(src, PROC_REF(explode), source), 0.5 SECONDS)
	source.balloon_alert_to_viewers("beep")
	playsound(parent, triggered_sound, 50, FALSE)
	return

/// Blow up the parent atom and delete ourselves
/datum/component/interaction_booby_trap/proc/explode(atom/source)
	on_triggered_callback?.Invoke(source)
	var/turf/origin_turf = get_turf(source)
	new /obj/effect/temp_visual/explosion/fast(origin_turf)
	EX_ACT(source, EXPLODE_HEAVY, source)
	explosion(origin = origin_turf, light_impact_range = explosion_light_range, heavy_impact_range = explosion_heavy_range, explosion_cause = src)
	qdel(src)

/// Defuse the bomb and delete ourselves
/datum/component/interaction_booby_trap/proc/on_defused(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	on_defused_callback?.Invoke(source, user, tool)
	qdel(src)
	return ITEM_INTERACT_BLOCKING

/// Give people a little hint
/datum/component/interaction_booby_trap/proc/on_examine(atom/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER
	var/defuse_hint = (defuse_tool) ? "Perhaps [tool_behaviour_name(defuse_tool)] could help..." : ""
	examine_list += span_warning("There's a light flashing red inside the maintenance panel. [defuse_hint]")
