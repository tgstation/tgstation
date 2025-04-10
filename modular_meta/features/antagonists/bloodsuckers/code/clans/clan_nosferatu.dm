/datum/bloodsucker_clan/nosferatu
	name = CLAN_NOSFERATU
	description = "The Nosferatu clan is unable to blend in with the crew, with no human mimicry abilities such as Masquerade or Veil. \n\
		Additionally, they have a permanent bad back, are completely unrecognizable, and look like a Bloodsucker at a simple glance.  \n\
		They can fit in vents regardless of their form and equipment, and they are generally known to possess a fondness for light switches. \n\
		Their favorite vassal becomes permanetly disfigured, and can also ventcrawl though only while entirely nude."
	clan_objective = /datum/objective/nosferatu_clan_objective
	join_icon_state = "nosferatu"
	join_description = "You are permanetly disfigured, look like a Bloodsucker to all who examine you, \
		lose your Masquerade ability, but become capable of ventcrawling."
	blood_drink_type = BLOODSUCKER_DRINK_INHUMANELY

/datum/bloodsucker_clan/nosferatu/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	for(var/datum/action/cooldown/bloodsucker/power as anything in bloodsuckerdatum.powers)
		if(istype(power, /datum/action/cooldown/bloodsucker/masquerade) || istype(power, /datum/action/cooldown/bloodsucker/veil))
			bloodsuckerdatum.RemovePower(power)
	if(!bloodsuckerdatum.owner.current.has_quirk(/datum/quirk/badback))
		bloodsuckerdatum.owner.current.add_quirk(/datum/quirk/badback)
	bloodsuckerdatum.owner.current.add_traits(list(TRAIT_VENTCRAWLER_ALWAYS, TRAIT_DISFIGURED), BLOODSUCKER_TRAIT)

/datum/bloodsucker_clan/nosferatu/Destroy(force)
	for(var/datum/action/cooldown/bloodsucker/power in bloodsuckerdatum.powers)
		bloodsuckerdatum.RemovePower(power)
	bloodsuckerdatum.give_starting_powers()
	bloodsuckerdatum.owner.current.remove_quirk(/datum/quirk/badback)
	bloodsuckerdatum.owner.current.remove_traits(list(TRAIT_VENTCRAWLER_ALWAYS, TRAIT_DISFIGURED), BLOODSUCKER_TRAIT)
	return ..()

/datum/bloodsucker_clan/nosferatu/handle_clan_life(datum/antagonist/bloodsucker/source)
	. = ..()
	if(!HAS_TRAIT(bloodsuckerdatum.owner.current, TRAIT_NOBLOOD))
		bloodsuckerdatum.owner.current.blood_volume = BLOOD_VOLUME_SURVIVE

	// "Who's flickering the lights?"
	for(var/obj/machinery/light_switch/our_switch in orange(1, source.owner.current))
		if(prob(33) && our_switch.is_operational)
			to_chat(source.owner.current, span_warning("You succumb to the sudden urge to flip the [our_switch.name]..."))
			our_switch.interact(source.owner.current)

/datum/bloodsucker_clan/nosferatu/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/favorite/vassaldatum)
	vassaldatum.owner.current.add_traits(list(TRAIT_VENTCRAWLER_NUDE, TRAIT_DISFIGURED), BLOODSUCKER_TRAIT)
	to_chat(vassaldatum.owner.current, span_notice("Additionally, you can now ventcrawl while naked, and are permanently disfigured."))

/**
 * Clan objective
 * Nosferatu's objective is to steal the Curator's Archives of the Kindred.
 */
/datum/objective/nosferatu_clan_objective
	name = "steal kindred"
	explanation_text = "Ensure that the <i>Archives of the Kindred</i> are stolen by a Bloodsucker."

/datum/objective/nosferatu_clan_objective/check_completion()
	for(var/datum/mind/bloodsucker_minds as anything in get_antag_minds(/datum/antagonist/bloodsucker))
		var/obj/item/book/kindred/the_book = locate() in bloodsucker_minds.current.get_all_contents()
		if(the_book)
			return TRUE
	return FALSE
