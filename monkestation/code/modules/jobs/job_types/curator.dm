/datum/job/curator/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(spawned.mind)
		ADD_TRAIT(spawned.mind, TRAIT_OCCULTIST, JOB_TRAIT)

/obj/item/melee/curator_whip
	obj_flags = parent_type::obj_flags | UNIQUE_RENAME

/obj/item/claymore/weak/ceremonial
	obj_flags = parent_type::obj_flags | UNIQUE_RENAME

/obj/item/knife/hunting
	obj_flags = parent_type::obj_flags | UNIQUE_RENAME
