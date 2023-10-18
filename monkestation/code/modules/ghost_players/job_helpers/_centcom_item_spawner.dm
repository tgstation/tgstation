/obj/structure/centcom_item_spawner
	name = "centcom item spawner"
	desc = "This is the abstract type of an object, you should not see this."
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"
	///types this spawner will not be able to spawn
	var/list/blacklisted_items = list()
	///assoc list of category name stings as keys with lists of what types they can spawn as values
	var/list/items_to_spawn = list()

/obj/structure/centcom_item_spawner/Initialize(mapload)
	. = ..()
	build_items_to_spawn()

/obj/structure/centcom_item_spawner/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/choice = tgui_input_list(user, "What do you wish to fabricate?", "[src.name]", items_to_spawn)
	if(!choice)
		return
	var/list/choice_list =

///build our items to spawn, override this
/obj/structure/centcom_item_spawner/proc/build_items_to_spawn()
	return
