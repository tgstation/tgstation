#define TONG_CLACK_CD (2 SECONDS)

/// Tongs, let you pick up and feed people food from further away.
/obj/item/kitchen/tongs
	name = "tongs"
	desc = "So you never have to touch anything with your dirty, unwashed hands."
	reach = 2
	icon_state = "tongs"
	base_icon_state = "tongs"
	inhand_icon_state = "fork" // close enough
	attack_verb_continuous = list("pinches", "tongs", "nips")
	attack_verb_simple = list("pinch", "tong", "nip")
	/// What are we holding in our tongs?
	var/obj/item/tonged
	/// Sound to play when we click our tongs together
	var/clack_sound = 'sound/items/handling/component_drop.ogg'
	/// Have we clacked recently?
	COOLDOWN_DECLARE(clack_cooldown)

/obj/item/kitchen/tongs/Destroy(force)
	QDEL_NULL(tonged)
	return ..()

/obj/item/kitchen/tongs/examine(mob/user)
	. = ..()
	if (!isnull(tonged))
		. += span_notice("It is holding [tonged].")

/obj/item/kitchen/tongs/dropped(mob/user, silent)
	. = ..()
	drop_tonged()

/obj/item/kitchen/tongs/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return TRUE
	if (!isnull(tonged))
		drop_tonged()
		return TRUE
	if (!COOLDOWN_FINISHED(src, clack_cooldown))
		return TRUE
	user.visible_message(span_notice("[user] clacks [user.p_their()] [src] together like a crab. Click clack!"))
	click_clack()
	return TRUE

/// Release the food we are holding
/obj/item/kitchen/tongs/proc/drop_tonged()
	if (isnull(tonged))
		return
	visible_message(span_notice("[tonged] falls to the ground!"))
	var/turf/location = drop_location()
	tonged.forceMove(location)
	tonged.do_drop_animation(location)
	forget_tonged()

/// Call when we don't want to track our tonged thing any more
/obj/item/kitchen/tongs/proc/forget_tonged()
	UnregisterSignal(tonged, COMSIG_QDELETING)
	tonged = null
	update_appearance(UPDATE_ICON)

/// Play a clacking sound and appear closed, then open again
/obj/item/kitchen/tongs/proc/click_clack()
	COOLDOWN_START(src, clack_cooldown, TONG_CLACK_CD)
	playsound(get_turf(src), clack_sound, vol = 100, vary = FALSE)
	icon_state = "[base_icon_state]_closed"
	addtimer(CALLBACK(src, PROC_REF(clack)), 0.5 SECONDS, TIMER_DELETE_ME)

/// Plays a clacking sound and appear open
/obj/item/kitchen/tongs/proc/clack()
	playsound(get_turf(src), clack_sound, vol = 100, vary = FALSE)
	update_appearance(UPDATE_ICON)

/obj/item/kitchen/tongs/Exit(atom/movable/leaving, direction)
	. = ..()
	if (leaving != tonged)
		return
	forget_tonged()

/obj/item/kitchen/tongs/pre_attack(obj/item/attacked, mob/living/user, params)
	if (isliving(attacked))
		if (isnull(tonged))
			if (COOLDOWN_FINISHED(src, clack_cooldown))
				click_clack()
			return ..()
		attacked.attackby(tonged, user)
		return TRUE
	if (!IsEdible(attacked) || attacked.w_class > WEIGHT_CLASS_NORMAL || !isnull(tonged))
		return ..()
	tonged = attacked
	RegisterSignal(tonged, COMSIG_QDELETING, PROC_REF(tonged_deleted))
	attacked.forceMove(src)
	update_appearance(UPDATE_ICON)

/// Called if our tonged item is destroyed, like if you feed it to someone
/obj/item/kitchen/tongs/proc/tonged_deleted()
	SIGNAL_HANDLER
	forget_tonged()

/obj/item/kitchen/tongs/update_icon_state()
	. = ..()
	icon_state = base_icon_state

/obj/item/kitchen/tongs/update_overlays()
	. = ..()
	if (isnull(tonged))
		return
	var/mutable_appearance/held_food = mutable_appearance(tonged.icon, tonged.icon_state, layer, src, plane)
	held_food.transform = matrix().Scale(0.7, 0.7)
	held_food.pixel_x = 6
	held_food.pixel_y = 6
	. += held_food

#undef TONG_CLACK_CD
