/obj/item/clothing/suit/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon_state = "labcoat_open"
	item_state = "labcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/device/analyzer,/obj/item/stack/medical,/obj/item/weapon/dnainjector,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 50, rad = 0)

	verb/toggle()
		set name = "Toggle Labcoat Buttons"
		set category = "Object"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		switch(icon_state)
			if("labcoat_open")
				src.icon_state = "labcoat"
				usr << "You button up the labcoat."
			if("labcoat")
				src.icon_state = "labcoat_open"
				usr << "You unbutton the labcoat."
			if("labcoat_cmo_open")
				src.icon_state = "labcoat_cmo"
				usr << "You button up the labcoat."
			if("labcoat_cmo")
				src.icon_state = "labcoat_cmo_open"
				usr << "You unbutton the labcoat."
			if("labcoat_gen_open")
				src.icon_state = "labcoat_gen"
				usr << "You button up the labcoat."
			if("labcoat_gen")
				src.icon_state = "labcoat_gen_open"
				usr << "You unbutton the labcoat."
			if("labcoat_chem_open")
				src.icon_state = "labcoat_chem"
				usr << "You button up the labcoat."
			if("labcoat_chem")
				src.icon_state = "labcoat_chem_open"
				usr << "You unbutton the labcoat."
			if("labcoat_vir_open")
				src.icon_state = "labcoat_vir"
				usr << "You button up the labcoat."
			if("labcoat_vir")
				src.icon_state = "labcoat_vir_open"
				usr << "You unbutton the labcoat."
			if("labcoat_tox_open")
				src.icon_state = "labcoat_tox"
				usr << "You button up the labcoat."
			if("labcoat_tox")
				src.icon_state = "labcoat_tox_open"
				usr << "You unbutton the labcoat."
			if("labgreen_open")
				src.icon_state = "labgreen"
				usr << "You button up the labcoat."
			if("labgreen")
				src.icon_state = "labgreen_open"
				usr << "You unbutton the labcoat."
			else
				usr << "You attempt to button-up the velcro on your [src], before promptly realising how retarded you are."
				return
		usr.update_inv_wear_suit()	//so our overlays update

/obj/item/clothing/suit/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model."
	icon_state = "labcoat_cmo_open"
	item_state = "labcoat_cmo"

/obj/item/clothing/suit/labcoat/mad
	name = "The Mad's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labgreen_open"
	item_state = "labgreen"

/obj/item/clothing/suit/labcoat/genetics
	name = "Geneticist Labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	icon_state = "labcoat_gen_open"

/obj/item/clothing/suit/labcoat/chemist
	name = "Chemist Labcoat"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder."
	icon_state = "labcoat_chem_open"

/obj/item/clothing/suit/labcoat/virologist
	name = "Virologist Labcoat"
	desc = "A suit that protects against minor chemical spills. Offers slightly more protection against biohazards than the standard model. Has a green stripe on the shoulder."
	icon_state = "labcoat_vir_open"

/obj/item/clothing/suit/labcoat/science
	name = "Scientist Labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	icon_state = "labcoat_tox_open"
