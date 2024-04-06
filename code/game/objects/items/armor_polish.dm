/obj/item/armorpolish
	name = "armor polish"
	desc = "Some canned tuna... oh wait. That's armor polish."
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "armor_polish"
	w_class = WEIGHT_CLASS_TINY
	var/remaining_uses = 2
	var/melee_armor_max = 30
	var/bullet_armor_max = 30
	var/laser_armor_max = 30
	var/energy_armor_max = 30
	var/datum/armor/armor_polish = /datum/armor/armor_plate
	var/melee_armor = null
	var/bullet_armor = null
	var/laser_armor = null
	var/energy_armor = null

/datum/armor/armor_plate
	melee = 30
	bullet = 30
	laser = 30
	energy = 30

/obj/item/armorpolish/examine(mob/user)
	. = ..()
	if(remaining_uses != -1)
		. += "It has [remaining_uses] use[remaining_uses > 1 ? "s" : ""] left."

obj/item/armorpolish/afterattack(atom/target, mob/user, proximity)
	if(istype(target, /obj/item/clothing/suit) || istype(target, /obj/item/clothing/head))
		//var/obj/item/clothing/I = target;

		var/datum/armor/armor_polish = get_armor_by_type(armor_type)
		var/melee_armor = armor_polish.get_rating(MELEE)
		var/bullet_armor = armor_polish.get_rating(BULLET)
		var/laser_armor = armor_polish.get_rating(LASER)
		var/energy_armor = armor_polish.get_rating(ENERGY)

		//make sure it's not too strong already ((busted))
		if((melee_armor < melee_armor_max) || (bullet_armor < bullet_armor_max) || (laser_armor < laser_armor_max) || (energy_armor < energy_armor_max))
			//it is weak enough to benefit
			target.set_armor(target.get_armor().add_other_armor(armor_polish))
			remaining_uses -= 1
			to_chat(user, "You apply [src] to the [target.name].")
			if(remaining_uses <= 0) {
				to_chat(user, span_warning("The [src] disintegrates into nothing..."))
				qdel(src)
			} else {
				to_chat(user, span_warning("The [src] has [remaining_uses] use[remaining_uses > 1 ? "s" : ""] left."))
			}


		else
			if(istype(target,/obj/item/clothing/suit)) {
				to_chat(user, span_warning("This suit is strong enough already! Try it on something weaker."))
			} else {
				to_chat(user, span_warning("This headgear is strong enough already! Try it on something weaker."))
			}

	else
		to_chat(user, span_warning("You can only polish suits and headgear!"))

