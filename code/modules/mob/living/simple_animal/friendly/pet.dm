/mob/living/simple_animal/pet
	icon = 'icons/mob/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	var/obj/item/clothing/tie/petcollar/pcollar = null
	var/image/collar = null
	var/image/pettag = null

/mob/living/simple_animal/pet/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/clothing/tie/petcollar) && !pcollar)
		var/obj/item/clothing/tie/petcollar/P = O
		pcollar = P
		collar = image('icons/mob/pets.dmi', src, "[icon_state]collar")
		pettag = image('icons/mob/pets.dmi', src, "[icon_state]tag")
		regenerate_icons()
		user << "<span class='notice'>You put the [P] around [src]'s neck.</span>"
		if(P.tagname)
			name = "\proper [P.tagname]"
		qdel(P)
		return
	if(istype(O, /obj/item/weapon/newspaper))
		if(!stat)
			user.visible_message("[user] baps [name] on the nose with the rolled up [O].")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					dir = i
					sleep(1)
	else
		..()

/mob/living/simple_animal/pet/New()
	..()
	if(pcollar)
		pcollar = new(src)
		regenerate_icons()

/mob/living/simple_animal/pet/revive()
	..()
	regenerate_icons()

/mob/living/simple_animal/pet/death(gibbed)
	..(gibbed)
	regenerate_icons()

/mob/living/simple_animal/pet/regenerate_icons()
	overlays.Cut()
	overlays += collar
	overlays += pettag