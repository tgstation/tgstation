/datum/modpack/aesthetics
	name = "Эстетика"
	desc = "Обновление визуального ряда"
	author = "larentoun, Aylong220"

/datum/modpack/aesthetics/post_initialize()
	. = ..()
	GLOB.podstyles += list(list(POD_SHAPE_OTHER, FALSE, FALSE, FALSE, FALSE, RUBBLE_NONE, "Портал доставки", "Высокотехнологичный портал для межзвездной доставки. Обеспечивает мгновенный доступ к товарам из любой точки вселенной."))
