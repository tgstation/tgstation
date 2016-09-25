/obj/structure/devicecrafting
	name = "large device frame"
	icon = 'icons/obj/devicecrafting.dmi'

/obj/structure/devicecrafting/New()
	..()
	add_device_holder(6)

/obj/item/devicecrafting/frame
	name = "handheld device frame"
	icon = 'icons/obj/devicecrafting.dmi'

/obj/item/devicecrafting/frame/New()
	..()
	add_device_holder(3)