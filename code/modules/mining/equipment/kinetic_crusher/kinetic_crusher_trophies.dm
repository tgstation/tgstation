/*!
 * Contains the baseline of kinetic crusher trophies.
 */

/obj/item/crusher_trophy
	name = "tail spike"
	desc = "A strange spike with no usage."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "tail_spike"
	/// if it has a bonus effect, this is how much that effect is
	var/bonus_value = 10
	/// id of the trophy to be sent by the signal
	var/trophy_id
	/// what type of trophies will block this trophy from being added, must be overriden
	var/denied_type = /obj/item/crusher_trophy
	/// what item will drop if you cut it with wildhunter's knife
	var/wildhunter_drop = null

/obj/item/crusher_trophy/examine(mob/living/user)
	. = ..()
	. += span_notice("Causes [effect_desc()] when attached to a kinetic crusher.")

/// Returns a string to get added to the examine
/obj/item/crusher_trophy/proc/effect_desc()
	SHOULD_CALL_PARENT(FALSE)
	return "errors"

/obj/item/crusher_trophy/attackby(obj/item/attacking_item, mob/living/user)
	if(!istype(attacking_item, /obj/item/kinetic_crusher))
		return ..()
	add_to(attacking_item, user)

/// Tries to add the trophy to our crusher
/obj/item/crusher_trophy/proc/add_to(obj/item/kinetic_crusher/crusher, mob/living/user)
	for(var/obj/item/crusher_trophy/trophy as anything in crusher.trophies)
		if(istype(trophy, denied_type) || istype(src, trophy.denied_type))
			to_chat(user, span_warning("You can't seem to attach [src] to [crusher]. Maybe remove a few trophies?"))
			return FALSE
	if(!user.transferItemToLoc(src, crusher))
		return
	crusher.trophies += src
	to_chat(user, span_notice("You attach [src] to [crusher]."))
	return TRUE

/// Removes the trophy from our crusher
/obj/item/crusher_trophy/proc/remove_from(obj/item/kinetic_crusher/crusher, mob/living/user)
	forceMove(get_turf(crusher))
	return TRUE

/// Does an effect when you hit a mob with a crusher
/obj/item/crusher_trophy/proc/on_melee_hit(mob/living/target, mob/living/user) //the target and the user
	return

/obj/item/crusher_trophy/proc/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user) //the projectile fired and the user
	return

/// Does an effect when you hit a mob with the projectile
/obj/item/crusher_trophy/proc/on_projectile_hit_mob(mob/living/target, mob/living/user) //the target and the user
	return

/// Does an effect when you hit a mineral turf with the projectile
/obj/item/crusher_trophy/proc/on_projectile_hit_mineral(turf/closed/mineral, mob/living/user) //the target and the user
	return

/// Does an effect when you hit a mob that is marked via the projectile
/obj/item/crusher_trophy/proc/on_mark_detonation(mob/living/target, mob/living/user) //the target and the user
	SHOULD_CALL_PARENT(TRUE)
	//if we dont have a set id, use the typepath as identifier
	SEND_SIGNAL(target, COMSIG_MOB_TROPHY_ACTIVATED(trophy_id || type), src, user)
