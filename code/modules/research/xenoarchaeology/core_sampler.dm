//device to take core samples from mineral turfs - used for various types of analysis

/obj/item/weapon/storage/samplebag
	name = "sample bag"
	desc = "A geological sample bag."
	icon_state = "evidenceobj"
	w_class = 1
	max_w_class = 1
	max_combined_w_class = 7
	storage_slots = 7

//////////////////////////////////////////////////////////////////

/obj/item/device/core_sampler
	name = "core sampler"
	desc = "Used to extract geological core samples."
	icon = 'device.dmi'
	icon_state = "sampler0"
	item_state = "screwdriver_brown"
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	//slot_flags = SLOT_BELT
	var/sampled_turf = ""
	var/num_stored_bags = 10
	var/obj/item/weapon/storage/samplebag/filled_bag

/obj/item/device/core_sampler/New()
	/*for(var/i=0, i<num_stored_bags, i++)
		src.contents += new/obj/item/weapon/storage/samplebag(src)*/

/obj/item/device/core_sampler/attack_hand(var/mob/user)
	user << "\blue The core sampler is [sampled_turf ? "full" : "empty"], and has [num_stored_bags] sample bag[num_stored_bags != 1] remaining."

/obj/item/device/core_sampler/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/storage/samplebag))
		if(num_stored_bags < 10)
			del(W)
			num_stored_bags += 1
			user << "\blue You insert the sample bag into the core sampler."
		else
			user << "\red The core sampler can not fit any more sample bags!"
	else
		return ..()

/obj/item/device/core_sampler/proc/sample_turf(var/turf/simulated/mineral/T, var/mob/user as mob)
	if(filled_bag)
		user << "\red The core sampler is full!"
	else if(num_stored_bags < 1)
		user << "\red The core sampler is out of sample bags!"
	else
		filled_bag = new /obj/item/weapon/storage/samplebag(src)
		icon_state = "sampler1"

		for(var/i=0, i<7, i++)
			var/obj/item/weapon/rocksliver/R = new(filled_bag)
			R.source_rock = T.type
			R.geological_data = T.geological_data

		user << "\blue You take a core sample of the [T]."

/obj/item/device/core_sampler/examine()
	if (!( usr ))
		return
	if(get_dist(src, usr) < 2)
		usr << "That's \a [src]."
		usr << "\blue Used to extract geological core samples - this one is [sampled_turf ? "full" : "empty"], and has [num_stored_bags] sample bag[num_stored_bags != 1] remaining."
	else
		return ..()
