
/obj/structure/aquarium
	name = "aquarium"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/aquarium/aquarium_structure.dmi'
	icon_state = "base"
	integrity_failure = 0.3

/obj/structure/aquarium/Initialize()
	. = ..()
	AddComponent(/datum/component/aquarium, 2, 31, 10, 24)

/obj/structure/aquarium/wrench_act(mob/living/user, obj/item/I)
	if(default_unfasten_wrench(user,I))
		return TRUE
