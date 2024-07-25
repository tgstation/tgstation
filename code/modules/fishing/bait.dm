/obj/item/bait_can
	name = "can o bait"
	desc = "there's a lot of them in there, getting them out takes a while though"
	icon = 'icons/obj/fishing.dmi'
	icon_state = "bait_can"
	w_class = WEIGHT_CLASS_SMALL
	/// Tracking until we can take out another bait item
	COOLDOWN_DECLARE(bait_removal_cooldown)
	/// What bait item it produces
	var/bait_type
	/// Time between bait retrievals
	var/cooldown_time = 10 SECONDS

/obj/item/bait_can/attack_self(mob/user, modifiers)
	. = ..()
	var/fresh_bait = retrieve_bait(user)
	if(fresh_bait)
		user.put_in_hands(fresh_bait)

/obj/item/bait_can/proc/retrieve_bait(mob/user)
	if(!COOLDOWN_FINISHED(src, bait_removal_cooldown))
		user.balloon_alert(user, "wait a bit") //I can't think of generic ic reason.
		return
	COOLDOWN_START(src, bait_removal_cooldown, cooldown_time)
	return new bait_type(src)

/obj/item/bait_can/worm
	name = "can o' worm"
	desc = "this can got worms."
	bait_type = /obj/item/food/bait/worm

/obj/item/bait_can/worm/premium
	name = "can o' worm deluxe"
	desc = "this can got fancy worms."
	bait_type = /obj/item/food/bait/worm/premium

/// Helper proc that checks if a bait matches identifier from fav/disliked bait list
/proc/is_matching_bait(obj/item/bait, identifier)
	if(ispath(identifier)) //Just a path
		return istype(bait, identifier)
	if(islist(identifier))
		var/list/special_identifier = identifier
		switch(special_identifier["Type"])
			if("Foodtype")
				var/obj/item/food/food_bait = bait
				return istype(food_bait) && food_bait.foodtypes & special_identifier["Value"]
			if("Reagent")
				return bait.reagents?.has_reagent(special_identifier["Value"], special_identifier["Amount"], check_subtypes = TRUE)
			else
				CRASH("Unknown bait identifier in fish favourite/disliked list")
	else
		return HAS_TRAIT(bait, identifier)
