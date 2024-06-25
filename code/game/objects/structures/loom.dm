///This is a loom. It's usually made out of wood and used to weave fabric like durathread or cotton into their respective cloth types.
/obj/structure/loom
	name = "loom"
	desc = "A simple device used to weave cloth and other thread-based fabrics together into usable material."
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "loom"
	density = TRUE
	anchored = TRUE

/obj/structure/loom/Initialize(mapload)
	. = ..()

	var/static/list/hovering_item_typechecks = list(
		/obj/item/stack/sheet/cotton = list(
			SCREENTIP_CONTEXT_LMB = "Weave",
		),
	)

	AddElement(/datum/element/contextual_screentip_item_typechecks, hovering_item_typechecks)

/obj/structure/loom/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 0.5 SECONDS)
	return ITEM_INTERACT_SUCCESS
