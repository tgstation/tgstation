//chair painter, straight up ported from urist mcstation. thank you.

/obj/item/weapon/chair_painter
	name = "chair painter"
	desc = "An advanced autopainter used to change the color of comfy chairs or couches. Select the color you want, then use it on any comfy chair or couch."
	icon = 'icons/obj/objects.dmi'
	icon_state = "paint sprayer"
	item_state = "paint sprayer"

	w_class = 2.0

	origin_tech = "engineering=1"

	flags = CONDUCT
	slot_flags = SLOT_BELT

	var/red = 0
	var/green = 0
	var/blue = 0

/obj/item/weapon/chair_painter/attack_self(mob/user)
	var/new_color = input("Please select chair color.", "Color Selection") as color
	if(new_color)
		red = hex2num(copytext(new_color, 2, 4))
		green = hex2num(copytext(new_color, 4, 6))
		blue = hex2num(copytext(new_color, 6, 8))

/obj/structure/stool/bed/chair/comfy/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/chair_painter))
		var/obj/item/weapon/chair_painter/C = W
		color = rgb(C.red,C.green,C.blue)