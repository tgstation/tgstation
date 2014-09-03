
//Apprenticeship contract - moved to antag_spawner.dm

///////////////////////////Veil Render//////////////////////

/obj/item/weapon/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	force = 15
	throwforce = 10
	w_class = 3
	var/charged = 1
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	density = 1
	unacidable = 1
	anchored = 1.0

/obj/effect/rend/New()
	spawn(50)
		new /obj/machinery/singularity/narsie/wizard(get_turf(src))
		del(src)
		return
	return

/obj/item/weapon/veilrender/attack_self(mob/user as mob)
	if(charged == 1)
		new /obj/effect/rend(get_turf(usr))
		charged = 0
		visible_message("\red <B>[src] hums with power as [usr] deals a blow to reality itself!</B>")
	else
		user << "\red The unearthly energies that powered the blade are now dormant."



/obj/item/weapon/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."

/obj/item/weapon/veilrender/vealrender/attack_self(mob/user as mob)
	if(charged)
		new /obj/effect/rend/cow(get_turf(usr))
		charged = 0
		visible_message("\red <B>[src] hums with power as [usr] deals a blow to hunger itself!</B>")
	else
		user << "\red The unearthly energies that powered the blade are now dormant."

/obj/effect/rend/cow
	desc = "Reverberates with the sound of ten thousand moos."
	var/cowsleft = 20

/obj/effect/rend/cow/New()
	processing_objects.Add(src)
	return

/obj/effect/rend/cow/process()
	if(locate(/mob) in loc) return
	new /mob/living/simple_animal/cow(loc)
	cowsleft--
	if(cowsleft <= 0)
		del src

/obj/effect/rend/cow/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/nullrod))
		visible_message("\red <b>[I] strikes a blow against \the [src], banishing it!</b>")
		spawn(1)
			del src
		return
	..()


/////////////////////////////////////////Scrying///////////////////

/obj/item/weapon/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, staring into it gives you vision beyond mortal means."
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 7
	throw_range = 15
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/items/welder2.ogg'

/obj/item/weapon/scrying/attack_self(mob/user as mob)
	user << "\blue You can see...everything!"
	visible_message("\red <B>[usr] stares into [src], their eyes glazing over.</B>")
	user.ghostize(1)
	return