
/obj/item/food/material
	name = "temporary golem material snack item"
	desc = "You shouldn't be able to see this. This is a horrible hack to allow you to eat rocks."
	bite_consumption = 2
	food_reagents = list(/datum/reagent/consumable/nutriment/mineral = 8)
	foodtypes = STONE

	/// A weak reference to the stack that created us
	var/datum/weakref/material

/obj/item/food/material/make_edible()
	. = ..()
	AddComponent(/datum/component/edible, on_consume = CALLBACK(src, PROC_REF(finished_eating)))

/obj/item/food/material/proc/finished_eating(mob/eater)
	var/obj/item/stack/resolved_material = material.resolve()
	if (resolved_material)
		resolved_material.use(used = 1)
		if (!resolved_material)
			to_chat(eater, span_warning("There is nothing left of [src], oh no!"))
	qdel(src)
