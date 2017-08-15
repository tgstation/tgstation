/obj/item/device/modular_computer/tablet  //Its called tablet for theme of 90ies but actually its a "big smartphone" sized
	name = "tablet computer"
	icon = 'icons/obj/modular_tablet.dmi'
	icon_state = "tablet"
	icon_state_unpowered = "tablet"
	icon_state_powered = "tablet"
	icon_state_menu = "menu"
	hardware_flag = PROGRAM_TABLET
	max_hardware_size = 1
	w_class = WEIGHT_CLASS_SMALL
	steel_sheet_cost = 1
	slot_flags = SLOT_ID | SLOT_BELT
	has_light = TRUE //LED flashlight!
	comp_light_luminosity = 2.3 //Same as the PDA
	var/finish_color = null

/obj/item/device/modular_computer/tablet/update_icon()
	..()
	if(!finish_color)
		finish_color = pick("red","blue","brown","green","black")
	icon_state = "tablet-[finish_color]"
	icon_state_unpowered = "tablet-[finish_color]"
	icon_state_powered = "tablet-[finish_color]"