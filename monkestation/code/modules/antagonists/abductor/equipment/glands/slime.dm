/obj/item/organ/internal/heart/gland/slime
	/// Whether the slime faction was given to the owner of this gland or not.
	/// Used so we don't take the slime faction away from someone who had it anyways
	var/gave_faction = FALSE

/obj/item/organ/internal/heart/gland/slime/on_insert(mob/living/carbon/gland_owner)
	. = ..()
	if(!(FACTION_SLIME in gland_owner.faction))
		gland_owner.faction |= FACTION_SLIME
		gave_faction = TRUE

/obj/item/organ/internal/heart/gland/slime/on_remove(mob/living/carbon/gland_owner)
	. = ..()
	if(gave_faction)
		gland_owner.faction -= FACTION_SLIME

/obj/item/organ/internal/heart/gland/slime/activate()
	owner.balloon_alert(owner, "you feel nauseous")
	owner.vomit(20)

	var/mob/living/basic/slime/friend = new(owner.drop_location())
	friend.slime_flags |= NOOOZE_SLIME
	SEND_SIGNAL(friend, COMSIG_FRIENDSHIP_CHANGE, owner, 110)
