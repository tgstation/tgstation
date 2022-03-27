// Manse link action for Raw Prophets
// Actually an action larping as a spell, because spells don't track what they're attached to.
/datum/action/cooldown/manse_link
	name = "Manse Link"
	desc = "This spell allows you to pierce through reality and connect minds to one another \
		via your Mansus Link. All minds connected to your Mansus Link will be able to communicate discreetly across great distances."
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mansus_link"
	background_icon_state = "bg_ecult"
	cooldown_time = 20 SECONDS
	text_cooldown = FALSE
	click_to_activate = TRUE
	/// The time it takes to link to a mob.
	var/link_time = 6 SECONDS
	/// The range of the cast. Expanded beyond normal view range by default, as Raw Prophets have a larger sight range.
	var/range = 10
	/// The text the caster is forced tos ay.
	var/invocation_text = "PI'RC' TH' M'ND"

/datum/action/cooldown/manse_link/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)

/datum/action/cooldown/manse_link/InterceptClickOn(mob/living/caller, params, atom/clicked_on)
	if(!isliving(clicked_on))
		return FALSE
	if(clicked_on == caller)
		return FALSE
	if(get_dist(caller, clicked_on) > range)
		to_chat(caller, span_warning("[clicked_on] is too far to establish a link.")) // Not a balloon alert due being so zoomed out.
		return FALSE

	return ..()

/datum/action/cooldown/manse_link/Activate(atom/victim)
	owner.say("#[invocation_text]", forced = "spell")

	// Short cooldown placed during the channel to prevent spam links.
	StartCooldown(10 SECONDS)

	// If we link successfuly, we can start the full cooldown duration.
	if(do_linking(victim))
		StartCooldown()

	return TRUE

/**
 * The actual process of linking [linkee] to our network.
 */
/datum/action/cooldown/manse_link/proc/do_linking(mob/living/linkee)
	var/datum/component/mind_linker/linker = target
	if(linkee.stat == DEAD)
		to_chat(owner, span_warning("They're dead!"))
		return FALSE

	to_chat(owner, span_notice("You begin linking [linkee]'s mind to yours..."))
	to_chat(linkee, span_warning("You feel your mind being pulled somewhere... connected... intertwined with the very fabric of reality..."))

	if(!do_after(owner, link_time, linkee))
		to_chat(owner, span_warning("You fail to link to [linkee]'s mind."))
		to_chat(linkee, span_warning("The foreign presence leaves your mind."))
		return FALSE

	if(QDELETED(src) || QDELETED(owner) || QDELETED(linkee))
		return FALSE

	if(!linker.link_mob(linkee))
		to_chat(owner, span_warning("You can't seem to link to [linkee]'s mind."))
		to_chat(linkee, span_warning("The foreign presence leaves your mind."))
		return FALSE

	return TRUE
