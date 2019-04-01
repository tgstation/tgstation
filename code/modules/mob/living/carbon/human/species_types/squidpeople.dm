/datum/species/squid
    name = "Squidperson"
    id = "squid"
    default_color = "b8dfda"
    species_traits = list(MUTCOLORS,EYECOLOR)
    default_features = list("mcolor" = "FFF") // bald
    changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | SLIME_EXTRACT
    use_skintones = 0
    no_equip = list(SLOT_SHOES)
    skinned_type = /obj/item/stack/sheet/animalhide/human
    disliked_food = FRIED
//	nojumpsuit = TRUE

/mob/living/carbon/human/species/squid
    race = /datum/species/squid

/datum/species/squid/qualifies_for_rank(rank, list/features)
    return TRUE

/datum/species/squid/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_squid_name()

	var/randname = squid_name()

	if(lastname)
		randname += " [lastname]"

	return randname

/proc/random_unique_squid_name(attempts_to_find_unique_name=10)
    for(var/i in 1 to attempts_to_find_unique_name)
        . = capitalize(squid_name())
        if(!findname(.))
            break

/datum/mood_event/squid //april 1st only
    description = "<span class='nicegreen'>Spongebob isn't on this station with me.</span>\n" //Used for syndies, nukeops etc so they can focus on their goals
    mood_change = 0
    hidden = FALSE