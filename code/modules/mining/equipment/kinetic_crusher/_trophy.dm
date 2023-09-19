/**
 * Base type for a crusher trophy. Does nothing except lie to you about causing errors.
 */
/obj/item/crusher_trophy
	name = "tail spike"
	desc = "A strange spike with no usage."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "tail_spike"
	///Trophies that conflict with this trophy; either upgrades or something that messes up the interactions
	var/list/denied_types = list(/obj/item/crusher_trophy)

/obj/item/crusher_trophy/examine(mob/living/user)
	. = ..()
	. += span_notice("Causes [effect_desc()] when attached to a kinetic crusher.")

/obj/item/crusher_trophy/attackby(obj/item/attack_item, mob/living/user)
	if(istype(attack_item, /obj/item/kinetic_crusher))
		add_to(attack_item, user)
	return ..()

///Returns a string describing the special effect to add into the trophy/crusher's description
/obj/item/crusher_trophy/proc/effect_desc()
	return "<b>errors</b>"

///Applies the trophy to the crusher, as well as applying any special properties
/obj/item/crusher_trophy/proc/add_to(obj/item/kinetic_crusher/crusher, mob/living/user)
	for(var/obj/item/crusher_trophy/trophy as anything in crusher.trophies)
		if((trophy in denied_types) || (src in trophy.denied_types))
			to_chat(user, span_warning("You can't seem to attach [src] to [crusher]. Maybe remove a few trophies?"))
			return FALSE
	if(!user.transferItemToLoc(src, crusher))
		return
	crusher.trophies += src
	crusher.balloon_alert(user, "trophy attached")
	playsound(crusher, 'sound/items/deconstruct.ogg', 40)
	return TRUE

/**
 * Removes the trophy from the crusher, as well as removing any special properties granted by that trophy.
 * Removing the trophy from the crusher's `trophies` is handled by the crusher's `Exited()`
 */
/obj/item/crusher_trophy/proc/remove_from(obj/item/kinetic_crusher/crusher, mob/living/user)
	balloon_alert(user, "trophy removed")
	forceMove(drop_location(crusher))
	return TRUE

///Special effect to execute upon hitting an enemy in melee with the crusher
/obj/item/crusher_trophy/proc/on_melee_hit(mob/living/target, mob/living/user)
	return

///Special effect to execute upon firing the destabilizer projectile
/obj/item/crusher_trophy/proc/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	return

///Special effect to execute upon applying a destabilizer mark on an enemy
/obj/item/crusher_trophy/proc/on_mark_application(mob/living/target, datum/status_effect/crusher_mark/mark, had_mark)
	return

///Special effect to execute upon detonating a destabilizer mark attached to an enemy
/obj/item/crusher_trophy/proc/on_mark_detonation(mob/living/target, mob/living/user)
	return
