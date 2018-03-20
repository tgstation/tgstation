/mob/living/simple_animal/pet
	icon = 'icons/mob/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	var/obj/item/clothing/neck/petcollar/pcollar
	var/collar_type
	var/unique_pet = FALSE
	blood_volume = BLOOD_VOLUME_NORMAL

/mob/living/simple_animal/pet/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/clothing/neck/petcollar) && !pcollar && collar_type)
		var/obj/item/clothing/neck/petcollar/P = O
		pcollar = P.type
		regenerate_icons()
		to_chat(user, "<span class='notice'>You put the [P] around [src]'s neck.</span>")
		if(P.tagname && !unique_pet)
			real_name = "\proper [P.tagname]"
			name = real_name
		qdel(P)
		return

	if(istype(O, /obj/item/newspaper))
		if(!stat)
			user.visible_message("[user] baps [name] on the nose with the rolled up [O].")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					setDir(i)
					sleep(1)
	else
		..()

/mob/living/simple_animal/pet/Initialize()
	. = ..()
	if(pcollar)
		pcollar = new(src)
		regenerate_icons()

/mob/living/simple_animal/pet/revive(full_heal = 0, admin_revive = 0)
	if(..())
		if(collar_type)
			collar_type = "[initial(collar_type)]"
		regenerate_icons()
		. = TRUE

/mob/living/simple_animal/pet/death(gibbed)
	..(gibbed)
	if(collar_type)
		collar_type = "[initial(collar_type)]_dead"
	regenerate_icons()

/mob/living/simple_animal/pet/gib()
	if(pcollar)
		new pcollar(drop_location())
	..()

/mob/living/simple_animal/pet/regenerate_icons()
	cut_overlays()
	if(pcollar && collar_type)
		add_overlay("[collar_type]collar")
		add_overlay("[collar_type]tag")

