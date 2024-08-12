/datum/religion_sect/maintenance
    rites_list = list(/datum/religion_rites/maint_adaptation, /datum/religion_rites/shadowascension, /datum/religion_rites/maint_loot, /datum/religion_rites/adapted_food, /datum/religion_rites/weapon_granter, /datum/religion_rites/ritual_totem)

/datum/religion_rites/weapon_granter
	name = "Maintenance Knowledge"
	desc = "Creates a tome teaching you how to make improved improvised weapons."
	favor_cost = 100 //You still have to make the weapon afterwards, might want to change this though.
	invoke_msg = "Grant me your ingenuity!"
	ritual_length = 5 SECONDS

/datum/religion_rites/weapon_granter/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	new /obj/item/book/granter/crafting_recipe/maintgodgranter(get_turf(religious_tool))
	return TRUE

/datum/religion_rites/shadowascension
	name = "Shadow Descent"
	desc = "Descends a maintenance adapted being into a shadowperson. Buckle a human to convert them, otherwise it will convert you." // Quite a bit copied from android conversion.
	ritual_length = 15 SECONDS
	invoke_msg = "I no longer want to see the light!"
	favor_cost = 300

/datum/religion_rites/shadowascension/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE

	if(!HAS_TRAIT_FROM(user, TRAIT_HOPELESSLY_ADDICTED, "maint_adaptation"))
		to_chat(user, span_warning("You need to adapt to maintenance first."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool

	if(!movable_reltool)
		return FALSE

	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("You're going to convert the one buckled on [movable_reltool]."))
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
			return FALSE
		if((is_species(user, /datum/species/shadow))) // There is no isshadow() helper
			to_chat(user, span_warning("You've already converted yourself. To convert others, they must be buckled to [movable_reltool]."))
			return FALSE
		to_chat(user, span_warning("You're going to convert yourself with this ritual."))
	return ..()

/datum/religion_rites/shadowascension/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target

	if(!length(movable_reltool.buckled_mobs))
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break

	if(!rite_target)
		return FALSE
	rite_target.set_species(/datum/species/shadow)
	rite_target.visible_message(span_notice("[rite_target] has been converted by the rite of [name]!"))
	return TRUE

/datum/religion_rites/maint_loot //Useful for when maintenance has been picked clean of anything interesting.
	name = "Maintenance apparition"
	desc = "Summons a pile of loot from the depths of maintenance."
	ritual_length = 5 SECONDS
	ritual_invocations =list( "The tunnels are an infinite bounty.",
							"They nourish us.")
	invoke_msg = "Let us reap the harvest!"
	favor_cost = 50
	var/amount = 5

/datum/religion_rites/maint_loot/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool) // Like an assistant, I steal code from other functions.
	for(var/i in 1 to amount)
		var/lootspawn = pick_weight(GLOB.good_maintenance_loot)
		while(islist(lootspawn))
			lootspawn = pick_weight(lootspawn)
		new lootspawn(altar_turf)
	return TRUE
