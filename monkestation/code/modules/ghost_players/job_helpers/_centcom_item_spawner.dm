/obj/structure/centcom_item_spawner
	name = "centcom item spawner"
	desc = "This is the abstract type of an object, you should not see this."
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"
	///what do we say() when we fabricate something
	var/fabrication_phrase = "fabrication complete"
	///list of exact types this spawner will not be able to spawn
	var/list/blacklisted_items = list()
	///typesof() these types will not be able to be spawned
	var/list/blacklisted_types = list()
	/**
	 * assoc list of category name stings as keys with lists of what types they can spawn as values.
	 * category is always required, even if you only have 1. however, if there is only 1 category then it will be removed and category selection for the player will be skipped
	 **/
	var/list/items_to_spawn = list()

/obj/structure/centcom_item_spawner/Initialize(mapload)
	. = ..()
	build_items_to_spawn()

/obj/structure/centcom_item_spawner/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/choice = length(items_to_spawn) == 1 ? 1 : tgui_input_list(user, "What do you wish to fabricate?", "[src.name]", items_to_spawn) // the 1 acts as an access key

	if(!choice)
		return

	var/atom/second_choice = tgui_input_list(user, "Choose what to fabricate", "[choice]", items_to_spawn[choice])
	if(!ispath(second_choice) || (type in blacklisted_items)) //should not be visible but just be extra sure we cant print these
		return

	spawn_chosen_item(second_choice)
	say("[fabrication_phrase]")
	playsound(src, 'sound/machines/ding.ogg', 50, TRUE)

///spawn our item, used if you want to add additional logic when an item is spawned
/obj/structure/centcom_item_spawner/proc/spawn_chosen_item(type_to_spawn)
	return new type_to_spawn(get_turf(src))

///build our items to spawn, override this to generate items_to_spawn, call parent at the END of your override
/obj/structure/centcom_item_spawner/proc/build_items_to_spawn()
	for(var/type as anything in blacklisted_types)
		blacklisted_items += typesof(type)

	for(var/category in items_to_spawn)
		if(length(items_to_spawn) == 1) //if our length is 1 then turn us into a normal list that just contains our single category list
			items_to_spawn = list(items_to_spawn[category])
			break
		for(var/type in items_to_spawn[category])
			if(type in blacklisted_items)
				items_to_spawn[category] -= type
