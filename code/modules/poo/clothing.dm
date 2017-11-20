/obj/item/clothing
  var/poo_stained = 0
  var/pee_stained = 0

/obj/item/clothing/suit/update_clothes_damaged_state()
	. = ..()
	if(poo_stained)
		add_overlay(mutable_appearance('icons/obj/poo.dmi', "poo[blood_overlay_type]"))

/obj/item/clothing/clean_blood()
	. = ..()
	poo_stained = min(poo_stained-1, 0)
	pee_stained = min(pee_stained-1, 0)
	update_clothes_damaged_state()