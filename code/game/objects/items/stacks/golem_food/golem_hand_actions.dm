/// How long can you hold onto gibtonite before you need to let it go?
#define GIBTONITE_GOLEM_HOLD_TIME 2 MINUTES
/// ID for a filter we apply so we can remove it again
#define BLUESPACE_GLOW_FILTER "bluespace_glow_filter"

/// Lets you hold a gibtonite ore in one hand and shoot it like a gun
/obj/item/gibtonite_hand
	name = "stabilised gibtonite fist"
	desc = "You had better launch this at something before it comes out the other end of your body."
	icon = 'icons/obj/ore.dmi'
	icon_state = "Gibtonite ore"
	lefthand_file = 'icons/mob/inhands/golem_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/golem_righthand.dmi'
	inhand_icon_state = "gibtonite_hand"
	item_flags = ABSTRACT
	w_class = WEIGHT_CLASS_HUGE
	/// The bomb we're going to throw
	var/obj/item/gibtonite/held_gibtonite

/obj/item/gibtonite_hand/Initialize(mapload, obj/item/gibtonite/held_gibtonite)
	. = ..()
	if (!held_gibtonite)
		return INITIALIZE_HINT_QDEL
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	src.held_gibtonite = held_gibtonite
	held_gibtonite.forceMove(src)
	addtimer(CALLBACK(src, PROC_REF(release_gibtonite)), GIBTONITE_GOLEM_HOLD_TIME, TIMER_DELETE_ME)

/obj/item/gibtonite_hand/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/gibtonite_hand/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if (!held_gibtonite)
		to_chat(user, span_warning("[src] fizzles, it was a dud!"))
		qdel(src)
		return ITEM_INTERACT_BLOCKING

	playsound(src, 'sound/items/weapons/sonic_jackhammer.ogg', 50, TRUE)
	held_gibtonite.forceMove(get_turf(src))
	held_gibtonite.det_time = 2 SECONDS
	held_gibtonite.GibtoniteReaction(user, "A [src] has targeted [interacting_with] with a thrown and primed")
	held_gibtonite.throw_at(interacting_with, range = 10, speed = 3, thrower = user)
	held_gibtonite = null
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/// Called when you can't hold it in any longer and just drop it on the ground
/obj/item/gibtonite_hand/proc/release_gibtonite()
	held_gibtonite.forceMove(get_turf(src))
	held_gibtonite.GibtoniteReaction(isliving(loc) ? loc : null, "A [src] has dropped and primed a")
	held_gibtonite = null
	qdel(src)

/obj/item/gibtonite_hand/Destroy()
	QDEL_NULL(held_gibtonite)
	return ..()

/// Point at a target and teleport somewhere vaguely close to it
/obj/item/bluespace_finger
	name = "bluespace knot"
	desc = "Firmly grasp reality and pull yourself to a nearby location."
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "bluespace"
	lefthand_file = 'icons/mob/inhands/golem_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/golem_righthand.dmi'
	inhand_icon_state = "bluespace_hand"
	item_flags = ABSTRACT | DROPDEL
	/// How far away can you point?
	var/teleport_range = 7
	/// How long does it take to teleport?
	var/teleport_time = 2 SECONDS
	/// How accurate are you?
	var/teleport_vary = 2

/obj/item/bluespace_finger/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/bluespace_finger/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/turf/target_turf = get_turf(interacting_with)
	if (get_dist(target_turf, get_turf(src)) > teleport_range)
		balloon_alert(user, "too far!")
		return ITEM_INTERACT_BLOCKING
	if (target_turf.is_blocked_turf(exclude_mobs = TRUE))
		balloon_alert(user, "no room!")
		return ITEM_INTERACT_BLOCKING

	var/obj/effect/temp_visual/teleport_golem/landing_indicator = new(target_turf)
	user.add_filter(BLUESPACE_GLOW_FILTER, 2, list("type" = "outline", "color" = COLOR_BRIGHT_BLUE, "alpha" = 0, "size" = 1))
	var/filter = user.get_filter(BLUESPACE_GLOW_FILTER)
	animate(filter, alpha = 200, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)

	var/did_teleport = do_after(user, delay = teleport_time, target = src, interaction_key = REF(src))
	qdel(landing_indicator)
	user.remove_filter(BLUESPACE_GLOW_FILTER)
	if (!did_teleport)
		return ITEM_INTERACT_BLOCKING

	var/list/valid_landing_tiles = list(target_turf)
	for (var/turf/potential_landing in oview(teleport_vary, target_turf))
		if (potential_landing.is_blocked_turf(exclude_mobs = TRUE))
			continue
		valid_landing_tiles += potential_landing
	var/turf/final_destination = pick(valid_landing_tiles)
	for (var/mob/living/telefrag in final_destination)
		telefrag.Knockdown(2 SECONDS)
	do_teleport(user, final_destination, asoundin = 'sound/effects/phasein.ogg', no_effects = TRUE)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

#undef GIBTONITE_GOLEM_HOLD_TIME
#undef BLUESPACE_GLOW_FILTER
