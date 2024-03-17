/// A component for ai-controlled atoms which plays a sound if they switch to a living target which they can attack
/datum/component/aggro_emote
	/// Blackboard key in which target data is stored
	var/target_key
	/// If we want to limit emotes to only play at mobs
	var/living_only
	/// List of emotes to play
	var/list/emote_list
	/// Chance to play an emote
	var/emote_chance
	/// Chance to subtract every time we play an emote (permanently)
	var/subtract_chance
	/// Minimum chance to play an emote
	var/minimum_chance

/datum/component/aggro_emote/Initialize(
	target_key = BB_BASIC_MOB_CURRENT_TARGET,
	living_only = FALSE,
	list/emote_list,
	emote_chance = 30,
	minimum_chance = 2,
	subtract_chance = 7,
)
	. = ..()
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/atom_parent = parent
	if (!atom_parent.ai_controller)
		return COMPONENT_INCOMPATIBLE

	src.target_key = target_key
	src.emote_list = emote_list
	src.emote_chance = emote_chance
	src.minimum_chance = minimum_chance
	src.subtract_chance = subtract_chance

/datum/component/aggro_emote/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_AI_BLACKBOARD_KEY_SET(target_key), PROC_REF(on_target_changed))

/datum/component/aggro_emote/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_AI_BLACKBOARD_KEY_SET(target_key))
	return ..()

/// When we get a new target, see if we want to bark at it
/datum/component/aggro_emote/proc/on_target_changed(atom/source)
	SIGNAL_HANDLER
	var/atom/new_target = source.ai_controller.blackboard[target_key]
	if (isnull(new_target) || !prob(emote_chance))
		return
	if (living_only && !isliving(new_target))
		return // If we don't want to bark at food items or chairs or windows
	emote_chance = max(emote_chance - subtract_chance, minimum_chance)
	source.manual_emote("[pick(emote_list)] at [new_target].")
