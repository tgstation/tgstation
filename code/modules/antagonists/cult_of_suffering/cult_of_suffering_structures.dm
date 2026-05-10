// /obj/structure/destructible/cult_of_suffering
// 	icon = 'icons/obj/antags/cult_of_suffer/structures.dmi'
// 	break_sound = 'sound/effects/hallucinations/veryfar_noise.ogg'
// 	density = TRUE
// 	anchored = TRUE



// /obj/structure/destructible/cult_of_suffering/pylon
// 	name = "star"
// 	desc = "Sharp-pointy arrows.."
// 	icon_state = "pylon"


// 	light_range = 1.5
// 	light_color = COLOR_SOFT_RED
// 	break_sound = 'sound/effects/glass/glassbr2.ogg'
// 	break_message = span_warning("The blood-red crystal falls to the floor and shatters!")
// 	var/corruption_cooldown_duration = 5 SECONDS
// 	/// The cooldown for corruptions.
// 	COOLDOWN_DECLARE(corruption_cooldown)

// /obj/structure/destructible/cult_of_suffering/pylon/Initialize(mapload)
// 	. = ..()
// 	START_PROCESSING(SSfastprocess, src)

// /obj/structure/destructible/cult_of_suffering/pylon/Destroy()
// 	STOP_PROCESSING(SSfastprocess, src)
// 	return ..()

// /obj/structure/destructible/cult_of_suffering/pylon/process()
// 	if(!COOLDOWN_FINISHED(src, corruption_cooldown))
// 		return

// 	// Супер минимально: берем любой тайл вокруг
// 	var/list/nearby_turfs = circle_view_turfs(src, 5)
// 	if(length(nearby_turfs))
// 		var/turf/converted_turf = pick(nearby_turfs)
// 		converted_turf.ChangeTurf(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)

// 	COOLDOWN_START(src, corruption_cooldown, corruption_cooldown_duration)

// /obj/structure/destructible/cult_of_suffering/portal_frame
// 	name = "portal frame"
// 	desc = "Foundation of portal.."
// 	icon_state = "portal_frame"
// 	layer = ABOVE_OBJ_LAYER

// /obj/structure/destructible/cult_of_suffering/portal_frame/Initialize(mapload)
// 	. = ..()
// 	// Спавним демонический портал прямо на этом же тайле
// 	var/obj/structure/spawner/ice_moon/demonic_portal/portal = new(loc)
// 	portal.layer = BELOW_OBJ_LAYER


// /obj/structure/destructible/cult_of_suffering/wall
// 	name = "Sharp Wall"
// 	desc = "Pile of rusty wire, sharp corners and bloody arrows peaks, air-tight and better not touch.."
// 	icon_state = "wall"
// 	density = TRUE
// 	opacity = TRUE
// 	anchored = TRUE
// 	max_integrity = 200

// /obj/structure/destructible/cult_of_suffering/wall/Bumped(atom/movable/bumping_atom)
// 	. = ..()
// 	if(isliving(bumping_atom))
// 		var/mob/living/L = bumping_atom
// 		L.apply_damage(10, BRUTE)
// 		to_chat(L, span_danger("Ouch! The sharp wall cut you!"))

// /obj/structure/destructible/cult_of_suffering/wall/attack_hand(mob/living/user, list/modifiers)
// 	. = ..()
// 	if(isliving(user))
// 		user.apply_damage(10, BRUTE)
// 		to_chat(user, span_danger("The rusty blades slice your hand!"))
// 	return TRUE

// /obj/structure/destructible/cult_of_suffering/door_blocker
// 	name = "Blood-rusty blades and wire"
// 	desc = "Making the way dangerous and barely allow to something to get throuhg it, however, metal wires seems to pulsating and moving like a.. plant? Or snakes..."
// 	icon_state = "door_blocker"
// 	density = TRUE
// 	anchored = TRUE
// 	pass_flags_self = PASSSTRUCTURE
// 	max_integrity = 50

// 	CanPass(atom/movable/mover, border_dir)
// 		// Всегда позволяем пройти, но наносим урон
// 		if(isliving(mover))
// 			var/mob/living/L = mover
// 			L.apply_damage(5, BRUTE)
// 			to_chat(L, span_danger("The rusty blades cut you!"))
// 		return TRUE

// /obj/structure/destructible/cult_of_suffering/krug
// 	name = "Krug"
// 	desc = "Bloody and rusty frame with sharp blades, arrows and hooks to weight someome, or something.. Oh wait, are the metal peaks moving?"
// 	icon_state = "krug"
// 	can_buckle = TRUE
// 	buckle_lying = 180
// 	buckle_dir = SOUTH
// 	buckle_delay = 10 SECONDS
// 	max_integrity = 250

// /obj/structure/destructible/cult_of_suffering/krug/Initialize(mapload)
// 	. = ..()
// 	ADD_TRAIT(src, TRAIT_DANGEROUS_BUCKLE, INNATE_TRAIT)
