/obj/item/weapon/storage/satchel
	name = "Mining Satchel"
	desc = "This little bugger can be used to store and transport ores."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	slot_flags = SLOT_BELT | SLOT_POCKET
	w_class = 3
	storage_slots = 50
	max_combined_w_class = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * ore.w_class
	use_to_pickup = 1
	max_w_class = 3
	display_contents_with_number = 1
	allow_quick_empty = 1
	allow_quick_gather = 1

	can_hold = list(
		"/obj/item/weapon/ore"
	)