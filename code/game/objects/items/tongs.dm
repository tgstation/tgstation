/// Tongs, let you pick up and feed people food from further away.
/obj/item/kitchen/tongs
	name = "tongs"
	desc = "So you never have to touch anything with your dirty, unwashed hands."
	reach = 2
	icon_state = "tongs"
	base_icon_state = "tongs"
	inhand_icon_state = "fork" // close enough
	icon_angle = -45
	attack_verb_continuous = list("pinches", "tongs", "nips")
	attack_verb_simple = list("pinch", "tong", "nip")
	/// What are we holding in our tongs?
	var/obj/item/tonged
	/// Sound to play when we click our tongs together
	var/clack_sound = 'sound/items/handling/component_drop.ogg'
	/// Time to wait between clacking sounds
	var/clack_delay = 2 SECONDS
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
	user.visible_message(span_notice("[user] clacks [user.p_their()] [name] together like a crab. Click clack!"))
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

/// Play a clacking sound and appear closed, then open again
/obj/item/kitchen/tongs/proc/click_clack()
	COOLDOWN_START(src, clack_cooldown, clack_delay)
	playsound(src, clack_sound, vol = 100, vary = FALSE)
	icon_state = "[base_icon_state]_closed"
	var/delay = min(0.5 SECONDS, clack_delay / 2) // Just in case someone's been fucking with the cooldown
	addtimer(CALLBACK(src, PROC_REF(clack)), delay, TIMER_DELETE_ME)

/// Plays a clacking sound and appear open
/obj/item/kitchen/tongs/proc/clack()
	playsound(src, clack_sound, vol = 100, vary = FALSE)
	icon_state = base_icon_state

/obj/item/kitchen/tongs/Exited(atom/movable/leaving, direction)
	. = ..()
	if (leaving != tonged)
		return
	tonged = null
	update_appearance(UPDATE_ICON)

/obj/item/kitchen/tongs/pre_attack(obj/item/attacked, mob/living/user, list/modifiers)
	if (!isnull(tonged) && tonged.force <= 0) // prevents tongs from giving food-weapons extra range
		attacked.attackby(tonged, user)
		return TRUE
	if (isliving(attacked))
		if (COOLDOWN_FINISHED(src, clack_cooldown))
			click_clack()
		return ..()
	if (!IsEdible(attacked) || attacked.w_class > WEIGHT_CLASS_NORMAL || !isnull(tonged))
		return ..()
	tonged = attacked
	attacked.do_pickup_animation(src)
	attacked.forceMove(src)
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/item/kitchen/tongs/update_overlays()
	. = ..()
	if (isnull(tonged))
		return
	var/mutable_appearance/held_food = new /mutable_appearance(tonged.appearance)
	held_food.layer = layer
	held_food.plane = plane
	held_food.transform = held_food.transform.Scale(0.7, 0.7)
	held_food.pixel_w = 6
	held_food.pixel_z = 6
	. += held_food
