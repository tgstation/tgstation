/// How long can you hold onto gibtonite before you need to let it go?
#define GIBTONITE_GOLEM_HOLD_TIME 2 MINUTES

/// Lets you hold a gibtonite ore in one hand and shoot it like a gun
/obj/item/gibtonite_hand
	name = "stabilised gibtonite"
	desc = "You had better launch this at something before it comes out the other end of your body."
	icon = 'icons/obj/ore.dmi'
	icon_state = "Gibtonite ore"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
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

/obj/item/gibtonite_hand/afterattack(atom/target, mob/living/user, flag, params)
	. = ..()
	if (!held_gibtonite)
		to_chat(user, span_warning("[src] fizzles, it was a dud!"))
		qdel(src)
		return TRUE | AFTERATTACK_PROCESSED_ITEM
	// TODO: sound
	held_gibtonite.forceMove(get_turf(src))
	held_gibtonite.det_time = 2 SECONDS
	held_gibtonite.GibtoniteReaction(user)
	held_gibtonite.throw_at(target, range = 10, speed = 3, thrower = user)
	held_gibtonite = null
	qdel(src)
	return TRUE | AFTERATTACK_PROCESSED_ITEM

/// Called when you can't hold it in any longer and just drop it on the ground
/obj/item/gibtonite_hand/proc/release_gibtonite()
	held_gibtonite.forceMove(get_turf(src))
	held_gibtonite.GibtoniteReaction(isliving(loc) ? loc : null)
	held_gibtonite = null
	qdel(src)

/obj/item/gibtonite_hand/Destroy()
	if (held_gibtonite)
		QDEL_NULL(held_gibtonite)
	return ..()

/// Point at a target and teleport somewhere vaguely close to it
/obj/item/bluespace_finger
	name = "bluespace knot"
	desc = "Firmly grasp reality and pull yourself to a nearby location."
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "bluespace"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_icon_state = "gibtonite_hand"
	item_flags = ABSTRACT | DROPDEL
	/// How far away can you point?
	var/teleport_range = 7
	/// How long does it take to teleport?
	var/teleport_time = 6 SECONDS
	/// How accurate are you?
	var/teleport_vary = 2

/obj/item/bluespace_finger/afterattack(atom/target, mob/living/user, flag, params)
	. = ..()
	var/turf/target_turf = get_turf(target)
	if (get_dist(target_turf, get_turf(src)) > teleport_range)
		balloon_alert(user, "too far!")
		return TRUE | AFTERATTACK_PROCESSED_ITEM
	if (target_turf.is_blocked_turf(exclude_mobs = TRUE))
		balloon_alert(user, "no room!")
		return TRUE | AFTERATTACK_PROCESSED_ITEM

	var/obj/effect/temp_visual/teleport_abductor/landing_indicator = new(target_turf)
	if (!do_after(user, delay = teleport_time, target = src, interaction_key = REF(src)))
		qdel(landing_indicator)
		return
	var/list/valid_landing_tiles = list(target_turf)
	for (var/turf/potential_landing in oview(teleport_vary, target_turf))
		if (potential_landing.is_blocked_turf(exclude_mobs = TRUE))
			continue
		valid_landing_tiles += potential_landing
	var/turf/final_destination = pick(valid_landing_tiles)
	for (var/mob/living/telefrag in final_destination)
		telefrag.Knockdown(2 SECONDS)
	do_teleport(user, final_destination, asoundin = 'sound/effects/phasein.ogg', no_effects = TRUE)
	qdel(landing_indicator)
	qdel(src)

#undef GIBTONITE_GOLEM_HOLD_TIME
