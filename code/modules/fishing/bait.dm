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

/obj/item/bait_can/proc/retrieve_bait(user)
	if(!COOLDOWN_FINISHED(src, bait_removal_cooldown))
		to_chat(user, span_notice("No bait left, try again in a moment.")) //I can't think of generic ic reason.
		return
	COOLDOWN_START(src, bait_removal_cooldown, cooldown_time)
	var/obj/fresh_bait = new bait_type(src)
	return fresh_bait

/obj/item/bait_can/worm
	name = "can o worm"
	bait_type = /obj/item/food/bait/worm

/obj/item/bait_can/worm/premium
	name = "can o worm deluxe"
	desc = "worms in this can are extra fancy"
	bait_type = /obj/item/food/bait/worm/premium
