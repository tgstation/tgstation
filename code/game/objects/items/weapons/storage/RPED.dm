/obj/item/weapon/storage/bag/gadgets/part_replacer //Bag because disposals bin snowflake code is shit
	name = "rapid part exchange device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	icon_state = "RPED"
	item_state = "RPED"
	w_class = W_CLASS_LARGE
	use_to_pickup = 1
	fits_max_w_class = W_CLASS_MEDIUM
	max_combined_w_class = 100
	storage_slots = 50
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')

/obj/item/weapon/storage/bag/gadgets/part_replacer/proc/play_rped_sound()
	//Plays the sound for RPED exhanging or installing parts.
	playsound(src, 'sound/items/rped.ogg', 40, 1)

//Sorts items by their rating. Currently used by the RPED (did that need mentioning since this proc is in RPED.dm?)
//Only use /obj/item with this sort proc!
/proc/cmp_rped_sort(var/obj/item/A, var/obj/item/B)
	return B.get_rating() - A.get_rating()

/obj/item/weapon/storage/bag/gadgets/part_replacer/attackby(var/obj/item/weapon/W, var/mob/user)
	if(istype(W, /obj/item/weapon/storage/bag/gadgets)) //I guess this allows for moving stuff between RPEDs, honk.
		var/obj/item/weapon/storage/bag/gadgets/A = W
		if(A.contents.len <= 0)
			to_chat(user, "<span class='notify'>\the [A] is empty!</span>")
			return 1
		if(src.contents.len >= storage_slots)
			to_chat(user, "<span class='notify'>\the [src] is full!</span>")
			return 1
		A.mass_remove(src)
		to_chat(user, "<span class='notify'>You fill up \the [src] with \the [A]")
		return 1

	return ..()

/obj/item/weapon/storage/bag/gadgets/part_replacer/pre_loaded/New() //Comes preloaded with loads of parts for testing
	..()
	new /obj/item/weapon/stock_parts/manipulator/nano/pico(src)
	new /obj/item/weapon/stock_parts/manipulator/nano/pico(src)
	new /obj/item/weapon/stock_parts/manipulator/nano/pico(src)
	new /obj/item/weapon/stock_parts/manipulator/nano/pico(src)
	new /obj/item/weapon/stock_parts/manipulator/nano/pico(src)
	new /obj/item/weapon/stock_parts/manipulator/nano/pico(src)
	new /obj/item/weapon/stock_parts/manipulator/nano/pico(src)
	new /obj/item/weapon/stock_parts/manipulator/nano/pico(src)
	new /obj/item/weapon/stock_parts/matter_bin/adv/super(src)
	new /obj/item/weapon/stock_parts/matter_bin/adv/super(src)
	new /obj/item/weapon/stock_parts/matter_bin/adv/super(src)
	new /obj/item/weapon/stock_parts/matter_bin/adv/super(src)
	new /obj/item/weapon/stock_parts/matter_bin/adv/super(src)
	new /obj/item/weapon/stock_parts/matter_bin/adv/super(src)
	new /obj/item/weapon/stock_parts/matter_bin/adv/super(src)
	new /obj/item/weapon/stock_parts/matter_bin/adv/super(src)
	new /obj/item/weapon/stock_parts/micro_laser/high/ultra(src)
	new /obj/item/weapon/stock_parts/micro_laser/high/ultra(src)
	new /obj/item/weapon/stock_parts/micro_laser/high/ultra(src)
	new /obj/item/weapon/stock_parts/micro_laser/high/ultra(src)
	new /obj/item/weapon/stock_parts/micro_laser/high/ultra(src)
	new /obj/item/weapon/stock_parts/scanning_module/adv/phasic(src)
	new /obj/item/weapon/stock_parts/scanning_module/adv/phasic(src)
	new /obj/item/weapon/stock_parts/scanning_module/adv/phasic(src)
	new /obj/item/weapon/stock_parts/scanning_module/adv/phasic(src)
	new /obj/item/weapon/stock_parts/scanning_module/adv/phasic(src)
	new /obj/item/weapon/stock_parts/capacitor/adv/super(src)
	new /obj/item/weapon/stock_parts/capacitor/adv/super(src)
	new /obj/item/weapon/stock_parts/capacitor/adv/super(src)
	new /obj/item/weapon/stock_parts/capacitor/adv/super(src)
	new /obj/item/weapon/stock_parts/capacitor/adv/super(src)
	new /obj/item/weapon/stock_parts/manipulator/nano(src)
	new /obj/item/weapon/stock_parts/manipulator/nano(src)
	new /obj/item/weapon/stock_parts/manipulator/nano(src)
	new /obj/item/weapon/stock_parts/matter_bin/adv(src)
	new /obj/item/weapon/stock_parts/matter_bin/adv(src)
	new /obj/item/weapon/stock_parts/matter_bin/adv(src)
	new /obj/item/weapon/stock_parts/micro_laser/high(src)
	new /obj/item/weapon/stock_parts/micro_laser/high(src)
	new /obj/item/weapon/stock_parts/micro_laser/high(src)
	new /obj/item/weapon/stock_parts/scanning_module/adv(src)
	new /obj/item/weapon/stock_parts/scanning_module/adv(src)
	new /obj/item/weapon/stock_parts/scanning_module/adv(src)
	new /obj/item/weapon/stock_parts/capacitor/adv(src)
	new /obj/item/weapon/stock_parts/capacitor/adv(src)
	new /obj/item/weapon/stock_parts/capacitor/adv(src)
