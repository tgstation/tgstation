/datum/bloodsucker_clan/gangrel
	name = CLAN_GANGREL
	description = "Closer to animals than bloodsuckers and often improperly characterized as werewolves: \n\
		these fearful Kindred are the most lethal to those who wield True Faith. \n\
		Full moons do not seem to affect them, despite what folklore may suggest. \n\
		Their favorite vassal turns into a werewolf whenever they do."
	joinable_clan = FALSE
	blood_drink_type = BLOODSUCKER_DRINK_INHUMANELY

/datum/bloodsucker_clan/gangrel/on_enter_frenzy(datum/antagonist/bloodsucker/source)
	ADD_TRAIT(bloodsuckerdatum.owner.current, TRAIT_STUNIMMUNE, FRENZY_TRAIT)

/datum/bloodsucker_clan/gangrel/on_exit_frenzy(datum/antagonist/bloodsucker/source)
	REMOVE_TRAIT(bloodsuckerdatum.owner.current, TRAIT_STUNIMMUNE, FRENZY_TRAIT)

/datum/bloodsucker_clan/gangrel/handle_clan_life(datum/antagonist/bloodsucker/source)
	. = ..()
	var/area/current_area = get_area(bloodsuckerdatum.owner.current)
	if(istype(current_area, /area/station/service/chapel))
		to_chat(bloodsuckerdatum.owner.current, span_warning("You don't belong in holy areas! The faith burns you to a crisp!"))
		bloodsuckerdatum.owner.current.adjustFireLoss(20)
		bloodsuckerdatum.owner.current.adjust_fire_stacks(2)
		bloodsuckerdatum.owner.current.ignite_mob()

/datum/bloodsucker_clan/toreador
	name = CLAN_TOREADOR
	description = "The most charming clan, whose members may easily conceal themselves within the crew. \n\
		More in touch with their morals, they are greatly impacted by the humanity of their actions. \n\
		Known as the most \"humane\" kind of vampire, they are perfectionists obsessed with vanity. \n\
		Their favorite vassal gains the Mesmerize ability."
	joinable_clan = FALSE
	blood_drink_type = BLOODSUCKER_DRINK_SNOBBY

/datum/bloodsucker_clan/tzimisce
	name = CLAN_TZIMISCE
	description = "Much of the information about the Tzimisce clan has yet to be reliably confirmed. \n\
		Most accounts indicate that they are amiable and often kinder than those of other clans, but when. . . \n\
		. . .are also. . . \n\
		. . .DO Ṉ̷̎O̶̯͂T UNDER ANY C̵I̸R̸C̶U̶M̷S̴T̸A̴N—. . ."
	joinable_clan = FALSE
