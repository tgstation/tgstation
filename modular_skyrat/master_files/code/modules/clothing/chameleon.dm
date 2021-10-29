/datum/action/chameleon_slowdown
	name = "Toggle Chameleon Slowdown"
	button_icon_state = "chameleon_outfit"
	var/savedslowdown = 0

/datum/action/chameleon_slowdown/New(Target, slowdown)
	..(Target)
	savedslowdown = slowdown

/datum/action/chameleon_slowdown/Trigger()
	var/obj/item/clothing/T = target
	var/slow = T.slowdown
	T.slowdown = savedslowdown
	savedslowdown = slow
	owner.update_equipment_speed_mods()

/datum/action/item_action/chameleon/change
	var/datum/action/chameleon_slowdown/slowtoggle

/datum/action/item_action/chameleon/change/update_look(mob/user, obj/item/picked_item)
	. = ..()
	if(isliving(user))
		owner.regenerate_icons()

/datum/action/item_action/chameleon/change/update_item(obj/item/picked_item)
	. = ..()
	if(istype(target, /obj/item/clothing/))
		var/obj/item/clothing/T = target
		var/obj/item/clothing/P = picked_item
		T.mutant_variants = initial(P.mutant_variants)
		T.worn_icon_digi = initial(P.worn_icon_digi)
		T.worn_icon_taur_snake = initial(P.worn_icon_taur_snake)
		T.worn_icon_taur_paw = initial(P.worn_icon_taur_paw)
		T.worn_icon_taur_hoof = initial(P.worn_icon_taur_hoof)
		T.worn_icon_muzzled = initial(P.worn_icon_muzzled)
		T.flags_inv = initial(P.flags_inv)
		T.visor_flags_cover = initial(P.visor_flags_cover)
		T.dynamic_hair_suffix = initial(P.dynamic_hair_suffix)
		T.dynamic_fhair_suffix = initial(P.dynamic_fhair_suffix)
		T.slowdown = 0
		// var/slow = initial(P.slowdown) /// DISABLED UNTIL YOU CAN MAKE THIS WORK WITH THE BROKEN CHAMELEON CLOTHES!!!
		// if(slow)
		// 	slowtoggle = new(T, slow)
		// 	slowtoggle.Grant(owner)
		// 	slowtoggle.target = T
		// else if(slowtoggle)
		// 	qdel(slowtoggle)

/datum/action/item_action/chameleon/change/Grant(mob/M)
	. = ..()
	if(M && (M == owner))
		if(slowtoggle)
			slowtoggle?.Grant(M)

/datum/action/item_action/chameleon/change/Remove(mob/M)
	. = ..()
	if(M && (M == owner))
		if(slowtoggle)
			slowtoggle?.Remove(M)
