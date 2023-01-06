/obj/structure/shipping_container
	name = "shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is blank, offering no clue as to its contents."
	icon = 'icons/obj/containers.dmi'
	icon_state = "container_blank"
	max_integrity = 1000
	bound_width = 96
	bound_height = 32
	density = TRUE
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE

/obj/structure/shipping_container/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/seethrough, SEE_THROUGH_MAP_SHIPPING_CONTAINER)

/obj/structure/shipping_container/conarex
	name = "\improper Conarex Aeronautics shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Conarex Aeronautics, and is probably carrying spacecraft parts (or a bribery scandal) as a result."
	icon_state = "conarex"

/obj/structure/shipping_container/deforest
	name = "\improper DeForest Medical Corp. shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from DeForest, and so is probably carrying medical supplies."
	icon_state = "deforest"

/obj/structure/shipping_container/kahraman
	name = "\improper Kahraman Heavy Industry shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Kahraman, and is reinforced for carrying ore."
	icon_state = "kahraman"

/obj/structure/shipping_container/kahraman/alt
	icon_state = "kahraman_alt"

/obj/structure/shipping_container/kosmologistika
	name = "\improper Kosmologistika shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Kosmologistika, the logistics company owned and operated by the SSC."
	icon_state = "kosmologistika"

/obj/structure/shipping_container/interdyne
	name = "\improper Interdyne shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Interdyne, a private pharmaceutical company. Probably carrying medical or research supplies, probably."
	icon_state = "interdyne"

/obj/structure/shipping_container/nakamura
	name = "\improper Nakamura Engineering shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Nakamura, presumably for transporting tools or heavy industrial equipment."
	icon_state = "nakamura"

/obj/structure/shipping_container/nanotrasen
	name = "\improper Nanotrasen shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one prominently features Nanotrasen's logo, and so presumably could be carrying anything."
	icon_state = "nanotrasen"
/obj/structure/shipping_container/nthi
	name = "\improper Nanotrasen Heavy Industries shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from NTHI: Nanotrasen's mining and refining subdivision."
	icon_state = "nthi"

/obj/structure/shipping_container/vitezstvi
	name = "\improper Vítězství Arms shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Vítězství Arms, proudly proclaiming that Vítězství weapons mean victory."
	icon_state = "vitezstvi"

//Syndies
/obj/structure/shipping_container/cybersun
	name = "\improper Cybersun Industries shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one prominently features Cybersun's logo, and so presumably could be carrying almost anything."
	icon_state = "cybersun"

/obj/structure/shipping_container/donk_co
	name = "\improper Donk Co. shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Donk Co. and so could be carrying just about anything- although it's probably Donk Pockets."
	icon_state = "donk_co"

/obj/structure/shipping_container/gorlex
	name = "\improper Gorlex Securities shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Gorlex Securities, and is probably carrying their primary export: war crimes."
	icon_state = "gorlex"

/obj/structure/shipping_container/gorlex/red
	icon_state = "gorlex_red"
