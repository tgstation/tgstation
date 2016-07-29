<<<<<<< HEAD
/obj/item/clothing/suit/toggle/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon_state = "labcoat"
	item_state = "labcoat"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS
	allowed = list(/obj/item/device/analyzer,/obj/item/stack/medical,/obj/item/weapon/dnainjector,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen,/obj/item/weapon/reagent_containers/glass/bottle,/obj/item/weapon/reagent_containers/glass/beaker,/obj/item/weapon/reagent_containers/pill,/obj/item/weapon/storage/pill_bottle,/obj/item/weapon/paper,/obj/item/weapon/melee/classic_baton/telescopic,/obj/item/weapon/soap,/obj/item/device/sensor_device,/obj/item/weapon/tank/internals/emergency_oxygen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 50, rad = 0)
	togglename = "buttons"
//	pockets = /obj/item/weapon/storage/internal/pocket

/obj/item/clothing/suit/toggle/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model."
	icon_state = "labcoat_cmo"
	item_state = "labcoat_cmo"

/obj/item/clothing/suit/toggle/labcoat/emt
	name = "EMT's jacket"
	desc = "A dark blue jacket with reflective strips for emergency medical technicians."
	icon_state = "labcoat_emt"
	item_state = "labcoat_cmo"

/obj/item/clothing/suit/toggle/labcoat/mad
	name = "\improper The Mad's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labgreen"
	item_state = "labgreen"

/obj/item/clothing/suit/toggle/labcoat/genetics
	name = "geneticist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	icon_state = "labcoat_gen"

/obj/item/clothing/suit/toggle/labcoat/chemist
	name = "chemist labcoat"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder."
	icon_state = "labcoat_chem"

/obj/item/clothing/suit/toggle/labcoat/virologist
	name = "virologist labcoat"
	desc = "A suit that protects against minor chemical spills. Offers slightly more protection against biohazards than the standard model. Has a green stripe on the shoulder."
	icon_state = "labcoat_vir"

/obj/item/clothing/suit/toggle/labcoat/science
	name = "scientist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	icon_state = "labcoat_tox"
=======
/obj/item/clothing/suit/storage/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	var/base_icon_state = "labcoat"
	var/open=1
	//icon_state = "labcoat_open"
	item_state = "labcoat"
	blood_overlay_type = "coat"
	allowed = list(/obj/item/device/analyzer,/obj/item/stack/medical,/obj/item/weapon/dnainjector,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 50, rad = 0)
	species_fit = list(VOX_SHAPED)



	update_icon()
		if(open)
			icon_state="[base_icon_state]_open"
		else
			icon_state="[base_icon_state]"

	verb/toggle()
		set name = "Toggle Labcoat Buttons"
		set category = "Object"
		set src in usr

		if(usr.incapacitated())
			return 0

		if(open)
			to_chat(usr, "You button up the labcoat.")
			src.body_parts_covered |= IGNORE_INV
		else
			to_chat(usr, "You unbutton the labcoat.")
			src.body_parts_covered ^= IGNORE_INV
		open=!open
		update_icon()
		usr.update_inv_wear_suit()	//so our overlays update

/obj/item/clothing/suit/storage/labcoat/New()
	. = ..()
	update_icon()

/obj/item/clothing/suit/storage/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model."
	base_icon_state = "labcoat_cmo"
	item_state = "labcoat_cmo"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/suit/storage/labcoat/mad
	name = "The Mad's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	base_icon_state = "labgreen"
	item_state = "labgreen"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/suit/storage/labcoat/genetics
	name = "Geneticist Labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	base_icon_state = "labcoat_gen"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/suit/storage/labcoat/chemist
	name = "Chemist Labcoat"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder."
	base_icon_state = "labcoat_chem"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/suit/storage/labcoat/virologist
	name = "Virologist Labcoat"
	desc = "A suit that protects against minor chemical spills. Offers slightly more protection against biohazards than the standard model. Has a green stripe on the shoulder."
	base_icon_state = "labcoat_vir"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60, rad = 0)
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/suit/storage/labcoat/science
	name = "Scientist Labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	base_icon_state = "labcoat_tox"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/suit/storage/labcoat/oncologist
	name = "Oncologist Labcoat"
	desc = "A suit that protects against minor radiation exposure. Offers slightly more protection against radiation than the standard model. Has a black stripe on the shoulder."
	base_icon_state = "labcoat_onc"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 60)
	species_fit = list(VOX_SHAPED)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
