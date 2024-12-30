// An unholy water flask, but for heretics.
// Heals heretics, harms non-heretics. Pretty much identical.
/obj/item/reagent_containers/cup/beaker/eldritch
	name = "flask of eldritch essence"
	desc = "Toxic to the closed minded, yet refreshing to those with knowledge of the beyond."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "eldritch_flask"
	list_reagents = list(/datum/reagent/eldritch = 50)

// Unique bottle that lets you instantly draw blood from a victim
/obj/item/reagent_containers/phylactery
	name = "phylactery of damnation"
	desc = "Used to steal blood from your soon to be victims."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "phylactery"
	base_icon_state = "phylactery"
	has_variable_transfer_amount = FALSE
	reagent_flags = TRANSPARENT
	volume = 10
	/// Cooldown before you can steal blood again
	COOLDOWN_DECLARE(drain_cooldown)

/obj/item/reagent_containers/phylactery/interact_with_atom_secondary(atom/target, mob/living/user, list/modifiers)
	if(!COOLDOWN_FINISHED(src, drain_cooldown))
		user.balloon_alert(user, "cant steal so fast!")
		return NONE
	if(!isliving(target))
		return NONE
	if(reagents.total_volume >= reagents.maximum_volume)
		to_chat(user, span_notice("[src] is full."))
		return ITEM_INTERACT_BLOCKING
	if(target == user)
		return ITEM_INTERACT_BLOCKING
	var/mob/living/living_target = target
	var/drawn_amount = max(reagents.maximum_volume - reagents.total_volume, 5)
	if(living_target.transfer_blood_to(src, drawn_amount))
		to_chat(user, span_notice("You take a blood sample from [living_target]."))
		to_chat(living_target, span_warning("You feel a tiny prick!"))
		COOLDOWN_START(src, drain_cooldown, 5 SECONDS)
	else
		to_chat(user, span_warning("You are unable to draw any blood from [living_target]!"))
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/phylactery/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(get_dist(user, interacting_with) <= 30)
		return interact_with_atom_secondary(interacting_with, user, modifiers)
	return ..()

/obj/item/reagent_containers/phylactery/update_icon_state()
	. = ..()
	switch(reagents.total_volume)
		if(0)
			icon_state = base_icon_state
		if(0.1 to 5)
			icon_state = base_icon_state + "_1"
		if(5.1 to 10)
			icon_state = base_icon_state + "_2"
