/mob/living/simple_animal/pet
	icon = 'icons/mob/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	var/obj/item/clothing/neck/petcollar/pcollar = null
	var/collar = ""
	var/pettag = ""
	blood_volume = BLOOD_VOLUME_NORMAL

/mob/living/simple_animal/pet/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/clothing/neck/petcollar) && !pcollar)
		var/obj/item/clothing/neck/petcollar/P = O
		pcollar = P
		collar = "[icon_state]collar"
		pettag = "[icon_state]tag"
		regenerate_icons()
		to_chat(user, "<span class='notice'>You put the [P] around [src]'s neck.</span>")
		if(P.tagname)
			real_name = "\proper [P.tagname]"
			name = real_name
		qdel(P)
		return
	if(istype(O, /obj/item/weapon/newspaper))
		if(!stat)
			user.visible_message("[user] baps [name] on the nose with the rolled up [O].")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					setDir(i)
					sleep(1)
	else
		..()

/mob/living/simple_animal/pet/Initialize()
	..()
	if(pcollar)
		pcollar = new(src)
		regenerate_icons()

/mob/living/simple_animal/pet/revive(full_heal = 0, admin_revive = 0)
	if(..())
		regenerate_icons()
		. = 1

/mob/living/simple_animal/pet/death(gibbed)
	..(gibbed)
	regenerate_icons()

/mob/living/simple_animal/pet/regenerate_icons()
	cut_overlays()
	if(collar)
		add_overlay(collar)
	if(pettag)
		add_overlay(pettag)
