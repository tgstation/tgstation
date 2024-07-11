/obj/item/reagent_containers/cup/Initialize(mapload, vol)
	. = ..()
	AddElement(/datum/element/trash_if_empty/reagent_container/if_prefilled)
