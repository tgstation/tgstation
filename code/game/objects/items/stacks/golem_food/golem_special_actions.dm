/// How long can you hold onto gibtonite before you need to let it go?
#define GIBTONITE_GOLEM_HOLD_TIME 20 SECONDS

/// Lets you hold a gibtonite ore in one hand and shoot it like a gun
/obj/item/gun/gibtonite_hand
	name = "stabilised gibtonite"
	desc = "You had better launch this at something before it comes out the other end of your body."
	icon = 'icons/obj/ore.dmi'
	icon_state = "Gibtonite ore"
	inhand_icon_state = "gibtonite_hand"
	item_flags = ABSTRACT
	w_class = WEIGHT_CLASS_HUGE
	/// The bomb we're going to throw
	var/obj/item/gibtonite/held_gibtonite

/obj/item/gun/gibtonite_hand/Initialize(mapload, obj/item/gibtonite/held_gibtonite)
	. = ..()
	if (!held_gibtonite)
		return INITIALIZE_HINT_QDEL
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	src.held_gibtonite = held_gibtonite
	held_gibtonite.forceMove(src)
	addtimer(CALLBACK(src, PROC_REF(release_gibtonite)), GIBTONITE_GOLEM_HOLD_TIME, TIMER_DELETE_ME)

/obj/item/gun/gibtonite_hand/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	. = ..()
	if (!held_gibtonite)
		qdel(src)
		return
	held_gibtonite.forceMove(get_turf(src))
	held_gibtonite.det_time = 2 SECONDS
	held_gibtonite.GibtoniteReaction(user)
	held_gibtonite.throw_at(target, range = 10, speed = 3, thrower = user)
	held_gibtonite = null
	qdel(src)

/// Called when you can't hold it in any longer and just drop it on the ground
/obj/item/gun/gibtonite_hand/proc/release_gibtonite()
	held_gibtonite.forceMove(get_turf(src))
	held_gibtonite.GibtoniteReaction(isliving(loc) ? loc : null)
	held_gibtonite = null
	qdel(src)

/obj/item/gun/gibtonite_hand/Destroy()
	if (held_gibtonite)
		QDEL_NULL(held_gibtonite)
	return ..()

#undef GIBTONITE_GOLEM_HOLD_TIME
