/**
 * Vibebot's vibe ability
 *
 * Given to vibebots so sentient ones can change/reset thier colors at will.
 */
#define VIBE_MOOD_TIMER 30 SECONDS
/datum/action/cooldown/mob_cooldown/bot/vibe
	name = "Vibe"
	desc = "Use on yourself to remove color!"
	click_to_activate = TRUE
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "funk"
	///cooldown to apply a new mood
	COOLDOWN_DECLARE(change_mood)

/datum/action/cooldown/mob_cooldown/bot/vibe/Grant(mob/granted_to)
	. = ..()
	if(isnull(granted_to))
		return
	RegisterSignal(granted_to, COMSIG_BOT_RESET, PROC_REF(remove_colors))

/datum/action/cooldown/mob_cooldown/bot/vibe/Activate(atom/target)
	if(target == owner)
		remove_colors()
		return TRUE
	vibe()
	StartCooldown()
	return TRUE

///Gives a random color
/datum/action/cooldown/mob_cooldown/bot/vibe/proc/vibe()
	var/mob/living/basic/bot/bot_owner = owner
	var/final_color = (bot_owner.bot_access_flags & BOT_COVER_EMAGGED) ? COLOR_GRAY : "#[random_color()]"
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	owner.add_atom_colour(final_color, TEMPORARY_COLOUR_PRIORITY)
	owner.set_light_color(owner.color)
	if(!COOLDOWN_FINISHED(src, change_mood))
		return
	var/mood_to_add = bot_owner.bot_access_flags & BOT_COVER_EMAGGED ? /datum/mood_event/depressing_party : /datum/mood_event/festive_party
	for(var/mob/living/carbon/human/human_target in oview(1, owner))
		human_target.add_mood_event("vibebot_party", mood_to_add)
	COOLDOWN_START(src, change_mood, VIBE_MOOD_TIMER)

///Removes all colors
/datum/action/cooldown/mob_cooldown/bot/vibe/proc/remove_colors()
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	owner.set_light_color(null)

/datum/mood_event/depressing_party
	description = "That was a really grim party..."
	mood_change = -1
	timeout = 30 SECONDS

/datum/mood_event/festive_party
	description = "That was a really fantastic party!"
	mood_change = 2
	timeout = 30 SECONDS

#undef VIBE_MOOD_TIMER
