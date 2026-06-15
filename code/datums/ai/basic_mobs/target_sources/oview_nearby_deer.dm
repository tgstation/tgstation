/// Gathers nearby deer (alive or dead).
/datum/target_source/oview_typed/deer_animals
	typecache = list(/mob/living/basic/deer)

/datum/target_source/oview_typed/deer_animals/New()
	. = ..()
	typecache = typecacheof(typecache)
