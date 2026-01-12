/obj/item/food/egg/raptor_egg
	name = "raptor egg"
	desc = "An uneven egg with a rough, thick shell."
	icon = 'icons/mob/simple/lavaland/raptor_baby.dmi'
	icon_state = "raptor_egg"
	resistance_flags = LAVA_PROOF|FIRE_PROOF
	/// Color typepath of the child we spawn
	var/datum/raptor_color/child_color = /datum/raptor_color
	/// Inheritance data to pass onto the child
	var/datum/raptor_inheritance/inherited_stats = null
	/// Current growth progress
	var/growth_progress = 0
	/// Minimum growth progress per second
	var/min_growth_rate = 0.5
	/// Maximum growth progress per second
	var/max_growth_rate = 1

/obj/item/food/egg/raptor_egg/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/food/egg/raptor_egg/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(inherited_stats)
	return ..()

/obj/item/food/egg/raptor_egg/examine(mob/user)
	. = ..()
	if (growth_progress >= RAPTOR_EGG_GROWTH_PROGRESS)
		. += span_boldnotice("Its noticeably shaking, ready to hatch!")

/obj/item/food/egg/raptor_egg/process(seconds_per_tick)
	if (!isturf(loc) || length(GLOB.raptor_population) >= MAX_RAPTOR_POP)
		return

	var/growth_value = rand(min_growth_rate, max_growth_rate) * seconds_per_tick * (1 + inherited_stats?.growth_modifier)
	// Slower growth off hot lavaland
	if (!SSmapping.level_trait(z, ZTRAIT_ASHSTORM))
		growth_value *= 0.75
	// Faster growth in hot hot lava
	if (islava(loc))
		growth_value *= 1.5

	growth_progress += growth_value
	// Don't hatch on lava though, or the chick will die instantly
	if (growth_progress < RAPTOR_EGG_GROWTH_PROGRESS || islava(loc))
		return

	visible_message(span_notice("[src] hatches with a quiet cracking sound."))
	new /mob/living/basic/raptor(loc, child_color, inherited_stats)
	inherited_stats = null
	qdel(src)
