/// -- Extension of examine, examine_more, and flavortext code. --
/mob
	/// Last time a client was connected to this mob.
	var/last_connection_time = 0

/mob/Logout()
	. = ..()
	last_connection_time = world.time

/**
 *	Flavor text and Personal Records On Examine INS AND OUTS (implementation by mrmelbert from MapleStation)
 *	- Admin ghosts, when examining, are given a list of buttons for all the records of a player.
 *		(This can probably be moved to examine_more if it's too annoying)
 *	- When you examine yourself, you will always see your own records and flavor text, no matter what.
 *	- When another person examines you, the following happens:
 *		> If your face is covered (by helmet or mask), they will not see your favor text or records, unless you're wearing your ID.
 *		> If you are wearing another player's ID (In disguise as another active player), they will see the other player's records and flavor instead.
 *		> If you are not wearing another player's ID (if you are unknown, or wearing a non-player's ID), no records or flavor text will show up as if none were set.
 *		> If you do not have any flavor text or records set, nothing special happens. The examine is normal.
 *
 *	- Flavor text is displayed to other players without any pre-requisites. It displays [EXAMINE_FLAVOR_MAX_DISPLAYED] (65 by default) characters before being trimmed.
 *	- Exploitive information is displayed via link to antagonists with the proper flags.
 *
 *	Bonus: If you are not connected to the server and someone examines you...
 *	an AFK timer is shown to the examiner, which displays how long you have been disconnected for.
 */

// Carbon and human examine don't call parent
// so we need to replicate this across all three
// Really I should be using the signal but at least this guarantees order
/mob/living/examine(mob/user)
	. = ..()
	. += late_examine(user)

/mob/living/carbon/examine(mob/user)
	. = ..()
	. += late_examine(user)

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	. += late_examine(user)

/// Mob level examining that happens after the main beef of examine is done
/mob/living/proc/late_examine(mob/user)
	. = list()
	SEND_SIGNAL(src, COMSIG_LIVING_LATE_EXAMINE, user, .)

	// Who's identity are we dealing with? In most cases it's the same as [src], but it could be disguised people, or null.
	var/datum/flavor_text/known_identity = get_visible_flavor(user)
	var/expanded_examine = ""

	if(known_identity)
		expanded_examine += known_identity.format_flavor_for_examine(user)

	if(linked_flavor && user.client?.holder && isAdminObserver(user))
		// Formatted output list of records.
		var/admin_line = ""

		if(linked_flavor.flavor_text)
			admin_line += "<a href='?src=[REF(linked_flavor)];flavor_text=1'>\[FLA\]</a>"
		if(linked_flavor.expl_info)
			admin_line += "<a href='?src=[REF(linked_flavor)];exploitable_info=1'>\[EXP\]</a>"
		if(known_identity != linked_flavor)
			admin_line += "\nThey are currently [isnull(known_identity) ? "disguised and have no visible flavor":"visible as the flavor text of [known_identity.name]"]."

		if(admin_line)
			expanded_examine += "ADMIN EXAMINE: [ADMIN_LOOKUPFLW(src)] - [admin_line]\n"

	// if the mob doesn't have a client, show how long they've been disconnected for.
	if(!client && last_connection_time && stat != DEAD)
		var/formatted_afk_time = span_bold("[round((world.time - last_connection_time) / (60*60), 0.1)]")
		expanded_examine += span_italics("\n[p_Theyve()] been unresponsive for [formatted_afk_time] minute(s).\n")

	if(length(expanded_examine))
		expanded_examine = span_info(expanded_examine)
		. += expanded_examine

// This isn't even an extension of examine_more this is the only definition for /human/examine_more, isn't that neat?
/mob/living/examine_more(mob/user)
	. = ..()
	var/datum/flavor_text/known_identity = get_visible_flavor(user)

	if(known_identity)
		. += span_info(known_identity.format_flavor_for_examine(user, FALSE))
	else if(ishuman(src))
		// I hate this istype src but it's easier to handle this here
		// Not all mobs should say "YOU CAN'T MAKE OUT DETAILS OF THIS PERSON"
		. += span_smallnoticeital("You can't make out any details of this individual.\n")
