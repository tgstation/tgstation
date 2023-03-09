/datum/bloodsucker_clan/nosferatu
	name = CLAN_NOSFERATU
	description = "The Nosferatu Clan is unable to blend in with the crew, with no abilities such as Masquerade and Veil. \n\
		Additionally, has a permanent bad back and looks like a Bloodsucker upon a simple examine, and is entirely unidentifiable, \n\
		they can fit in the vents regardless of their form and equipment. \n\
		The Favorite Vassal is permanetly disfigured, and can also ventcrawl, but only while entirely nude."
	clan_objective = /datum/objective/bloodsucker/kindred
	join_icon_state = "nosferatu"
	join_description = "You are permanetly disfigured, look like a Bloodsucker to all who examine you, \
		lose your Masquerade ability, but gain the ability to Ventcrawl even while clothed."
	blood_drink_type = BLOODSUCKER_DRINK_INHUMANELY

/datum/bloodsucker_clan/nosferatu/New(mob/living/carbon/user)
	. = ..()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(user)
	for(var/datum/action/bloodsucker/power in bloodsuckerdatum.powers)
		if(istype(power, /datum/action/bloodsucker/masquerade) || istype(power, /datum/action/bloodsucker/veil))
			bloodsuckerdatum.RemovePower(power)
	if(!user.has_quirk(/datum/quirk/badback))
		user.add_quirk(/datum/quirk/badback)
	ADD_TRAIT(user, TRAIT_VENTCRAWLER_ALWAYS, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_DISFIGURED, BLOODSUCKER_TRAIT)

/datum/bloodsucker_clan/nosferatu/handle_clan_life(atom/source, datum/antagonist/bloodsucker/bloodsuckerdatum)
	. = ..()
	bloodsuckerdatum.owner.current.blood_volume = BLOOD_VOLUME_SURVIVE

/datum/bloodsucker_clan/nosferatu/on_favorite_vassal(datum/source, datum/antagonist/vassal/vassaldatum, mob/living/bloodsucker)
	ADD_TRAIT(vassaldatum.owner.current, TRAIT_VENTCRAWLER_NUDE, BLOODSUCKER_TRAIT)
	ADD_TRAIT(vassaldatum.owner.current, TRAIT_DISFIGURED, BLOODSUCKER_TRAIT)
	to_chat(vassaldatum.owner.current, span_notice("Additionally, you can now ventcrawl while naked, and are permanently disfigured."))
