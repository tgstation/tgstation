#define BREADIFY_TIME (5 SECONDS)

/// Turns the target into bread
/datum/smite/bread
	name = "Bread"

/datum/smite/bread/effect(client/user, mob/living/target)
	. = ..()
	var/mutable_appearance/bread_appearance = mutable_appearance('icons/obj/food/burgerbread.dmi', "bread")
	var/mutable_appearance/transform_scanline = mutable_appearance('icons/effects/effects.dmi', "transform_effect")
	target.transformation_animation(bread_appearance, BREADIFY_TIME, transform_scanline.appearance)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(breadify), target), BREADIFY_TIME)

#undef BREADIFY_TIME
