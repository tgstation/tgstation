///Mostly useless funny rite for forgiving someone, making them innocent once again.
/datum/religion_rites/forgive
	name = "Forgive"
	desc = "Forgives someone, making them no longer considered guilty. A kind gesture, all things considered!"
	invoke_msg = "You are absolved of sin."
	var/mob/living/who

/datum/religion_rites/forgive/perform_rite(mob/living/carbon/human/user, atom/religious_tool)
	if(!ishuman(user))
		return FALSE
	var/datum/brain_trauma/special/honorbound/honor = user.has_trauma_type(/datum/brain_trauma/special/honorbound)
	if(!honor)
		return FALSE
	if(!length(honor.guilty))
		to_chat(user, span_warning("[GLOB.deity] is holding no grudges to forgive."))
		return FALSE
	var/forgiven_choice = tgui_input_list(user, "Choose one of [GLOB.deity]'s guilty to forgive", "Forgive", honor.guilty)
	if(isnull(forgiven_choice))
		return FALSE
	who = forgiven_choice
	return ..()

/datum/religion_rites/forgive/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	..()
	if(in_range(user, religious_tool))
		return FALSE
	var/datum/brain_trauma/special/honorbound/honor = user.has_trauma_type(/datum/brain_trauma/special/honorbound)
	if(!honor) //edge case
		return FALSE
	honor.guilty -= who
	who = null
	playsound(get_turf(religious_tool), 'sound/effects/pray.ogg', 50, TRUE)
	return TRUE

/datum/religion_rites/summon_rules
	name = "Summon Honorbound Rules"
	desc = "Enscribes a paper with the honorbound rules and regulations."
	invoke_msg = "Bring forth the holy writ!"
	///paper to turn into holy writ
	var/obj/item/paper/writ_target

/datum/religion_rites/summon_rules/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/paper/could_writ in get_turf(religious_tool))
		if(istype(could_writ, /obj/item/paper/holy_writ))
			continue
		if(could_writ.get_total_length()) //blank paper pls
			continue
		writ_target = could_writ //PLEASE SIGN MY AUTOGRAPH
		return ..()
	to_chat(user, span_warning("You need to place blank paper on [religious_tool] to do this!"))
	return FALSE

/datum/religion_rites/summon_rules/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/obj/item/paper/autograph = writ_target
	var/turf/tool_turf = get_turf(religious_tool)
	writ_target = null
	if(QDELETED(autograph) || !(tool_turf == autograph.loc)) //check if the paper is still there
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	autograph.visible_message(span_notice("Words magically form on [autograph]!"))
	playsound(tool_turf, 'sound/effects/pray.ogg', 50, TRUE)
	new /obj/item/paper/holy_writ(tool_turf)
	qdel(autograph)
	return TRUE

/obj/item/paper/holy_writ
	icon = 'icons/obj/scrolls.dmi'
	icon_state = "honorscroll"
	slot_flags = null
	show_written_words = FALSE

//info set in here because we need GLOB.deity
/obj/item/paper/holy_writ/Initialize(mapload)
	add_filter("holy_outline", 9, list("type" = "outline", "color" = "#fdff6c"))
	name = "[GLOB.deity]'s honorbound rules"
	default_raw_text = {"[GLOB.deity]'s honorbound rules:
	<br>
	1.) Thou shalt not attack the unready!<br>
	Those who are not ready for battle should not be wrought low. The evil of this world must lose
	in a fair battle if you are to conquer them completely. Lesser creatures are given the benefit of
	being unready, keep that in mind.
	<br>
	<br>
	2.) Thou shalt not attack the just!<br>
	Those who fight for justice and good must not be harmed. Security is uncorruptable and must
	be respected. Healers are mostly uncorruptable and if you are truly sure Medical has fallen
	to the scourge of evil, use a declaration of evil.
	<br>
	<br>
	3.) Thou shalt not attack the innocent!<br>
	There is no honor on a pre-emptive strike, unless they are truly evil vermin.
	Those who are guilty will either lay a hand on you first, or you may declare their evil. Mindless, lesser
	creatures cannot be considered innocent, nor evil. They are beings of passion and function, and
	may be dispatched as such if their passions misalign with the pursuits of a better world.
	<br>
	<br>
	4.) Thou shalt not use profane magicks!<br>
	You are not a warlock, you are an honorable warrior. There is nothing more corruptive than
	the vile magicks used by witches, warlocks, and necromancers. There are exceptions to this rule.<br>
	You may use holy magic, and, if you recruit one, the mime may use holy mimery. Restoration has also
	been allowed as it is a school focused on the light and mending of this world.
	"}
	return ..()

/// how much favor is gained when someone is deaconized
#define DEACONIZE_FAVOR_GAIN 300

/**
 * Crusader deaconize
 * Along with making the person holy & being an infinite-use type, it comes with the cost
 * of enforcing an honorbound code onto convertees.
 * Earns the church favor per conversion, but convincing others to uphold the code is not easy.
 * Geneless species are not welcome for reasons
 * (The actual reason is because the honorbound trauma used to be a mutation which they couldn't get,
 * maybe it's time we let them join? idk)
 */
/datum/religion_rites/deaconize/crusader
	name = "Join Crusade"
	desc = "Converts someone to your sect. They must be willing, so the first invocation will instead prompt them to join. \
	They will become honorbound like you, and you will gain a massive favor boost!"
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"A good, honorable crusade against evil is required.",
		"We need the righteous ...",
		"... the unflinching ...",
		"... and the just.",
		"Sinners must be silenced ...",
	)
	invoke_msg = "... And the code must be upheld!"
	rite_flags = RITE_ALLOW_MULTIPLE_PERFORMS

/datum/religion_rites/deaconize/crusader/post_invoke_effects(mob/living/user, atom/religious_tool)
	. = ..()
	GLOB.religious_sect.adjust_favor(DEACONIZE_FAVOR_GAIN, user)

/datum/religion_rites/deaconize/crusader/is_valid_for_deacon(mob/living/carbon/human/possible_deacon, mob/living/user)
	if(TRAIT_GENELESS in possible_deacon.dna.species.inherent_traits)
		to_chat(user, span_warning("This species disgusts [GLOB.deity]! They would never be allowed to join the crusade!"))
		return FALSE
	return ..()

/datum/religion_rites/deaconize/crusader/invite_deacon(mob/living/carbon/human/invited)
	var/ask = tgui_alert(invited, "Join [GLOB.deity]? You will be bound to a code of honor.", "Invitation", list("Yes", "No"), 60 SECONDS)
	if(ask != "Yes")
		return
	potential_deacon = invited

#undef DEACONIZE_FAVOR_GAIN
