/datum/slime_trait/cleaner
	name = "Cleaner"
	desc = "Changes the slime to consume pollution and grime."
	menu_buttons = list(FOOD_CHANGE, DOCILE_CHANGE, BEHAVIOUR_CHANGE)
	incompatible_traits = list(/datum/slime_trait/polluter)

	///decals we can clean
	var/static/list/cleanable_decals = typecacheof(list(
		/obj/effect/decal/cleanable/ants,
		/obj/effect/decal/cleanable/ash,
		/obj/effect/decal/cleanable/confetti,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/fuel_pool,
		/obj/effect/decal/cleanable/generic,
		/obj/effect/decal/cleanable/glitter,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/cleanable/molten_object,
		/obj/effect/decal/cleanable/oil,
		/obj/effect/decal/cleanable/food,
		/obj/effect/decal/cleanable/robot_debris,
		/obj/effect/decal/cleanable/shreds,
		/obj/effect/decal/cleanable/glass,
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/wrapping,
		/obj/effect/decal/remains,
	))
	///blood we can clean
	var/static/list/cleanable_blood = typecacheof(list(
		/obj/effect/decal/cleanable/xenoblood,
		/obj/effect/decal/cleanable/blood,
		/obj/effect/decal/cleanable/trail_holder,
	))
	///pests we hunt
	var/static/list/huntable_pests = typecacheof(list(
		/mob/living/basic/cockroach,
		/mob/living/basic/mouse,
	))
	///trash we will burn
	var/static/list/huntable_trash = typecacheof(list(
		/obj/item/trash,
		/obj/item/food/deadmouse,
	))

/datum/slime_trait/cleaner/on_add(mob/living/basic/slime/parent)
	. = ..()
	parent.AddComponent(/datum/component/pollution_scrubber, 15)

	parent.slime_flags |= (CLEANER_SLIME | PASSIVE_SLIME)

	parent.ai_controller.set_blackboard_key(BB_CLEANABLE_DECALS, cleanable_decals)
	parent.ai_controller.set_blackboard_key(BB_CLEANABLE_BLOOD, cleanable_blood)
	parent.ai_controller.set_blackboard_key(BB_HUNTABLE_PESTS, huntable_pests)
	parent.ai_controller.set_blackboard_key(BB_HUNTABLE_TRASH, huntable_trash)

	ADD_TRAIT(parent, TRAIT_SLIME_DUST_IMMUNE, "trait")
	parent.recompile_ai_tree()

/datum/slime_trait/cleaner/on_remove(mob/living/basic/slime/parent)
	. = ..()

	parent.slime_flags &= ~(CLEANER_SLIME | PASSIVE_SLIME)

	parent.recompile_ai_tree()

	qdel(parent.GetComponent(/datum/component/pollution_scrubber))
	REMOVE_TRAIT(parent, TRAIT_SLIME_DUST_IMMUNE, "trait")
