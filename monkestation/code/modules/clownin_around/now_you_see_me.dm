GLOBAL_LIST_INIT(hidden_image_holders, list())


/obj/item/clothing/under/rank/civilian/clown/on_outfit_equip(mob/living/carbon/human/outfit_wearer, visuals_only, item_slot)
	SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED, outfit_wearer, item_slot)

/datum/component/hide_from_people
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///this is the image that culls players out
	var/image/the_image
	///the id we store stuff inside the global images
	var/id = "generic"
	///the require path to the trait
	var/required_trait = TRAIT_HIDDEN_IMAGE

/datum/component/hide_from_people/Initialize(...)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(!length(GLOB.hidden_image_holders[id]))
		GLOB.hidden_image_holders[id] = list()

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(move_image_loc))
	RegisterSignal(parent, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(image_loc_null))

	the_image = image('icons/effects/effects.dmi', null, "nothing", ABOVE_MOB_LAYER)
	the_image.name = "\u200b" // I HATE BYOND I HATE BYOND
	the_image.override = TRUE

	GLOB.hidden_image_holders[id] |= the_image //cache the image in the id of this

	for(var/mob/listed_mob as anything in GLOB.player_list)
		if(!HAS_TRAIT(listed_mob, required_trait))
			continue
		if(!listed_mob.client)
			continue
		add_image_to_client(the_image, listed_mob.client)

/datum/component/hide_from_people/Destroy(force, silent)
	. = ..()
	GLOB.hidden_image_holders[id] -= the_image
	for(var/mob/listed_mob as anything in GLOB.player_list)
		if(!HAS_TRAIT(listed_mob, required_trait))
			continue
		if(!listed_mob.client)
			continue
		listed_mob.client.images.Remove(the_image)
	qdel(the_image)

/datum/component/hide_from_people/proc/move_image_loc(datum/source, mob/equipper, slot)
	for(var/mob/listed_mob as anything in GLOB.player_list)
		if(!HAS_TRAIT(listed_mob, required_trait))
			continue
		if(!listed_mob.client)
			continue
		listed_mob.client.images |= the_image

	if(slot == 2)
		the_image.loc = equipper

/datum/component/hide_from_people/proc/image_loc_null()
	the_image.loc = null

/datum/component/hide_from_people/clown
	id = "clown"
	required_trait = TRAIT_HIDDEN_CLOWN
