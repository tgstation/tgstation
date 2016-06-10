#define SHOWER_OPEN_LAYER OBJ_LAYER + 0.4
#define SHOWER_CLOSED_LAYER MOB_LAYER + 0.2

/obj/structure/curtain
	name = "curtain"
	icon = 'icons/obj/curtain.dmi'
	icon_state = "closed"
	layer = SHOWER_OPEN_LAYER
	opacity = 1
	density = 0

/obj/structure/curtain/open
	icon_state = "open"
	layer = SHOWER_CLOSED_LAYER
	opacity = 0

/obj/structure/curtain/bullet_act(obj/item/projectile/P, def_zone)
	if(!P.nodamage)
		visible_message("<span class='warning'>[P] tears \the [src] down!</span>")
		qdel(src)
	else
		..()

/obj/structure/curtain/attack_hand(mob/user)
	playsound(get_turf(loc), "rustle", 15, 1, -5)
	toggle()
	..()

/obj/structure/curtain/proc/toggle()
	opacity = !opacity
	if(opacity)
		icon_state = "closed"
		layer = SHOWER_CLOSED_LAYER
	else
		icon_state = "open"
		layer = SHOWER_OPEN_LAYER

/obj/structure/curtain/attackby(obj/item/W, mob/user)
	if(iswirecutter(W))
		playsound(loc, 'sound/items/Wirecutter.ogg', 50, 1)
		if(do_after(user, src, 10))
			to_chat(user, "<span class='notice'>You cut the shower curtains down.</span>")
			var/obj/item/stack/sheet/mineral/plastic/A = getFromPool(/obj/item/stack/sheet/mineral/plastic, get_turf(src))
			A.amount = 4
			qdel(src)
		return 1
	src.attack_hand(user)

/obj/structure/curtain/black
	name = "black curtain"
	color = "#222222"

/obj/structure/curtain/medical
	name = "plastic curtain"
	color = "#B8F5E3"
	alpha = 200

/obj/structure/curtain/open/bed
	name = "bed curtain"
	color = "#854636"

/obj/structure/curtain/open/privacy
	name = "privacy curtain"
	color = "#B8F5E3"

/obj/structure/curtain/open/shower
	name = "shower curtain"
	color = "#ACD1E9"
	alpha = 200

/obj/structure/curtain/open/shower/engineering
	color = "#FFA500"

/obj/structure/curtain/open/shower/medical
	color = "#B8F5E3"

/obj/structure/curtain/open/shower/security
	color = "#AA0000"

#undef SHOWER_OPEN_LAYER
#undef SHOWER_CLOSED_LAYER