/obj/item/weapon/gun/siren
	name = "siren"
	desc = "Despite being entirely liquid, this gun's projectiles still pack a punch."
	icon = 'icons/obj/gun.dmi'
	icon_state = "siren"
	item_state = "siren"
	origin_tech = "combat=5"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	recoil = 1
	slot_flags = SLOT_BELT
	flags = FPRINT | NOREACT
	w_class = 3
	fire_delay = 1
	fire_sound = 'sound/weapons/shotgun.ogg'
	var/hard = 1 //When toggled on, the gun's shots will deal damage. When off, they deal no damage, but deliver five times the reagents.
	var/max_reagents = 50

/obj/item/weapon/gun/siren/isHandgun()
	return 0

/obj/item/weapon/gun/siren/New()
	..()
	create_reagents(max_reagents)
	reagents.add_reagent("water", max_reagents)

/obj/item/weapon/gun/siren/verb/flush_reagents()
	set name = "Flush siren"
	set category = "Object"
	set src in usr

	if(!reagents.total_volume)
		to_chat(usr, "<span class='warning'>\The [src] is already empty.</span>")
		return

	reagents.clear_reagents()
	to_chat(usr, "<span class='notice'>You flush out the contents of \the [src].</span>")

/obj/item/weapon/gun/siren/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It has [round(reagents.total_volume/10)] round\s remaining.</span>")
	if(hard)
		to_chat(user, "<span class='info'>It is set to \"hard liquid\".</span>")
	else
		to_chat(user, "<span class='info'>It is set to \"soft liquid\".</span>")

/obj/item/weapon/gun/siren/attack_self(mob/user as mob)
	hard = !hard
	if(hard)
		to_chat(user, "<span class='info'>You set \the [src] to fire hard liquid.</span>")
		desc = initial(desc)
		fire_sound = initial(fire_sound)
		recoil = 1
	else
		to_chat(user, "<span class='info'>You set \the [src] to fire soft liquid.</span>")
		desc = "The most efficient ranged mass reagent delivery system there is."
		fire_sound = 'sound/items/egg_squash.ogg'
		recoil = 0

/obj/item/weapon/gun/siren/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)	return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(reagents.total_volume < 10)
		return click_empty(user)
	if(in_chamber)
		if(in_chamber.reagents && in_chamber.reagents.total_volume)
			if(istype(in_chamber, /obj/item/projectile/bullet/liquid_blob))
				var/obj/item/projectile/bullet/liquid_blob/L = in_chamber
				if(!L.hard)
					for(var/datum/reagent/R in in_chamber.reagents.reagent_list)
						in_chamber.reagents.remove_reagent(R.id, reagents.get_reagent_amount(R.id)*4)
			in_chamber.reagents.trans_to(src, in_chamber.reagents.total_volume)
		qdel(in_chamber)
		in_chamber = null
	in_chamber = new/obj/item/projectile/bullet/liquid_blob(src, hard)
	reagents.trans_to(in_chamber, 10)
	if(!hard) //When set to no-damage mode, each shot has five times the reagents.
		for(var/datum/reagent/R in in_chamber.reagents.reagent_list)
			in_chamber.reagents.add_reagent(R.id, reagents.get_reagent_amount(R.id)*4)
	Fire(A,user,params, "struggle" = struggle)

/obj/item/weapon/gun/siren/process_chambered()
	if(in_chamber) return 1
	return 0