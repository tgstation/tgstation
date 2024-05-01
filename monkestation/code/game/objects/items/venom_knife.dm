#define VENOM_KNIFE_VOLUME 40

/obj/item/knife/venom
	name = "venom knife"
	desc = "An infamous knife of syndicate design, it has a tiny hole going through the blade to the handle which stores toxins."
	icon = 'monkestation/icons/obj/items_and_weapons.dmi'
	icon_state = "venom_knife"
	force = 12
	throwforce = 15
	throw_speed = 5
	throw_range = 7
	custom_materials = null
	/// The maximum amount of reagents per transfer that will be moved out of this reagent container
	var/amount_per_transfer_from_this = 10
	/// The different possible amounts of reagent to transfer out of the container
	var/list/possible_transfer_amounts = list(5, 10)
	/// Where we are in the possible transfer amount list.
	var/amount_list_position = 2

/obj/item/knife/venom/Initialize()
	. = ..()
	create_reagents(VENOM_KNIFE_VOLUME, OPENCONTAINER)

/obj/item/knife/venom/attack_self(mob/user)
	change_transfer_amount(user, FORWARD)

/obj/item/knife/venom/attack_self_secondary(mob/user)
	change_transfer_amount(user, BACKWARD)

/obj/item/knife/venom/attack(mob/living/target_mob, mob/living/user, params)
	. = ..()
	if(!istype(target_mob) || HAS_TRAIT(user, TRAIT_PACIFISM) || !reagents.total_volume || QDELETED(target_mob.reagents))
		return
	var/transfer_amt = amount_per_transfer_from_this
	if(!target_mob.can_inject(user))
		transfer_amt = 1
	reagents.trans_to(target_mob, transfer_amt, methods = INJECT, transfered_by = user)

/obj/item/knife/venom/proc/change_transfer_amount(mob/user, direction = FORWARD)
	var/list_len = length(possible_transfer_amounts)
	if(!list_len)
		return
	switch(direction)
		if(FORWARD)
			amount_list_position = (amount_list_position % list_len) + 1
		if(BACKWARD)
			amount_list_position = (amount_list_position - 1) || list_len
		else
			CRASH("change_transfer_amount() called with invalid direction value")
	amount_per_transfer_from_this = possible_transfer_amounts[amount_list_position]
	balloon_alert(user, "transferring [amount_per_transfer_from_this]u")

#undef VENOM_KNIFE_VOLUME
