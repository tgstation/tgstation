/datum/disorder
    var/name = "Adminoid Paranoidicus"
    var/desc = "You should never see this"
    var/max_resistance = 1000
    var/current_resistance
    var/permanent = FALSE
    var/datum/mind/owner
    var/list/trait_mods = list(TRAIT_FEARLESS = -1,TRAIT_RELAXED = -1,TRAIT_TENSED = -1,TRAIT_CONTROLLED = -1)

/datum/disorder/New()
	. = ..()
	current_resistance = max_resistance

/datum/disorder/proc/on_add(mob/living/carbon/human/human_owner)
	owner = human_owner.mind

/datum/disorder/proc/on_remove(mob/living/carbon/human/human_owner)
	return

///Proc that handles life() interaction with humans, monkeys are too simple to comprehend struggles of existance
/datum/disorder/proc/on_life()

	if(permanent)
		return

	for(var/trait in trait_mods)
		if(HAS_TRAIT(owner.current,trait))
			current_resistance -= trait_mods[trait]

	if(current_resistance <= 0)
		owner.remove_disorder(src)
		return

/datum/disorder/Destroy(force, ...)
	owner = null
	return ..()
