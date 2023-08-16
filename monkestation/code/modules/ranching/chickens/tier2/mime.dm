/mob/living/basic/chicken/mime
	icon_suffix = "mime"

	breed_name = "Mime"
	egg_type = /obj/item/food/egg/mime

	book_desc = "..."

/obj/item/food/egg/mime
	name = "Mime Egg"
	icon_state = "mime-1"

	layer_hen_type = /mob/living/basic/chicken/mime

/obj/item/food/egg/mime/Initialize(mapload)
	. = ..()
	icon_state = "mime-[rand(1,3)]"
