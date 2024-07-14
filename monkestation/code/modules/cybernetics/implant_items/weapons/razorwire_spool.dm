/obj/item/melee/razorwire
	name = "implanted razorwire"
	desc = "A long length of monomolecular filament, built into the back of your hand. \
		Impossibly thin and flawlessly sharp, it should slice through organic materials with no trouble; \
		even from a few steps away. However, results against anything more durable will heavily vary."
	icon = 'monkestation/code/modules/cybernetics/icons/implants.dmi'
	icon_state = "razorwire_weapon"
	lefthand_file = 'monkestation/code/modules/cybernetics/icons/swords_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/cybernetics/icons/swords_righthand.dmi'
	inhand_icon_state = "razorwire"
	w_class = WEIGHT_CLASS_BULKY
	sharpness = SHARP_EDGED
	force = 15
	demolition_mod = 0.25 // This thing sucks at destroying stuff
	wound_bonus = -10 // Very weak against armor.
	bare_wound_bonus = 25
	weak_against_armour = TRUE
	reach = 2
	hitsound = 'sound/weapons/whip.ogg'
	attack_verb_continuous = list("slashes", "whips", "lashes", "lacerates")
	attack_verb_simple = list("slash", "whip", "lash", "lacerate")
	var/additional_distance = 3
	var/datum/component/leash/tracked_component
	var/atom/movable/leashed_atom
	COOLDOWN_DECLARE(ensnare)

/obj/item/melee/razorwire/attack_self(mob/user, modifiers)
	. = ..()
	if(!tracked_component)
		return
	var/obj/item/some_item = user.get_inactive_held_item()
	if(some_item || !isitem(leashed_atom))
		return
	user.put_in_inactive_hand(leashed_atom)


/obj/item/melee/razorwire/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ismovable(target) || tracked_component || !COOLDOWN_FINISHED(src, ensnare))
		return

	var/atom/movable/movable = target
	if(movable.anchored)
		return

	if(proximity_flag || (get_dist(user,target) > 4 && get_dist(user,target) < reach))
		return


	var/total_dist  = get_dist(user, target) + additional_distance

	if(!CheckToolReach(user, target, 4))
		return

	tracked_component = movable.AddComponent(/datum/component/leash, src, total_dist, beam_icon_state = "razorwire", beam_icon = 'icons/effects/beam.dmi', force_teleports = FALSE)
	leashed_atom = movable
	user.visible_message(span_danger("[user] ensnares [movable] in razorwire tethering them!"))
	var/tether_time = 10 SECONDS
	if(isitem(movable))
		tether_time *= 2

	addtimer(CALLBACK(src, PROC_REF(disconnect)), tether_time)
	COOLDOWN_START(src, ensnare, 40 SECONDS)

/obj/item/melee/razorwire/proc/disconnect()
	if(!tracked_component)
		return
	QDEL_NULL(tracked_component)
