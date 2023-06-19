/obj/item/scalpel
	icon = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery.dmi'

/obj/item/cautery
	icon = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery.dmi'

/obj/item/retractor
	icon = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery.dmi'

/obj/item/hemostat
	icon = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery.dmi'

/obj/item/bonesetter
	icon = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery.dmi'
	icon_state = "bonesetter" //idk why we need to do this, they just HAD to rename it

/obj/item/blood_filter
	icon = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery.dmi'

/obj/item/circular_saw
	icon = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery.dmi'

/obj/item/surgicaldrill
	icon = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery.dmi'

/obj/item/scalpel/advanced
	icon = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery.dmi'
	light_color = "#AAFF00"
	light_range = 2
	lefthand_file = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery_inhand_l.dmi'
	righthand_file = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery_inhand_r.dmi'

/obj/item/scalpel/advanced/on_transform(obj/item/source, mob/user, active)
	. = ..()
	if(active)
		set_light_range(2)
		set_light_color("#FF6600")
	else
		set_light_range(2)
		set_light_color("#AAFF00")

/obj/item/retractor/advanced
	icon = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery.dmi'
	lefthand_file = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery_inhand_l.dmi'
	righthand_file = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery_inhand_r.dmi'

/obj/item/cautery/advanced
	icon = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery.dmi'
	lefthand_file = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery_inhand_l.dmi'
	righthand_file = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery_inhand_r.dmi'
	light_color = "#AAFF00"

/obj/item/cautery/advanced/on_transform(obj/item/source, mob/user, active)
	. = ..()
	if(active)
		//set_light_range(1)
		set_light_color("#FF6600")
	else
		//set_light_range(1)
		set_light_color("#AAFF00")

/obj/item/surgical_drapes
	icon = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery.dmi'

/obj/item/storage/medkit
	icon = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery.dmi'
	lefthand_file = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery_inhand_l.dmi'
	righthand_file = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery_inhand_r.dmi'

/obj/item/storage/medkit/coroner
	icon = 'modular_skyraptor/modules/aesthetics/oldnewsurgery/oldnewsurgery.dmi'
