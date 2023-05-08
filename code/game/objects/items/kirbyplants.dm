
/obj/item/kirbyplants
	name = "potted plant"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-01"
	desc = "A little bit of nature contained in a pot."
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER
	w_class = WEIGHT_CLASS_HUGE
	force = 10
	throwforce = 13
	throw_speed = 2
	throw_range = 4
	item_flags = NO_PIXEL_RANDOM_DROP

	/// Can this plant be trimmed by someone with TRAIT_BONSAI
	var/trimmable = TRUE
	var/list/static/random_plant_states

/obj/item/kirbyplants/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/tactical)
	AddComponent(/datum/component/two_handed, require_twohands=TRUE, force_unwielded=10, force_wielded=10)
	AddElement(/datum/element/beauty, 500)

/obj/item/kirbyplants/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(trimmable && HAS_TRAIT(user,TRAIT_BONSAI) && isturf(loc) && I.get_sharpness())
		to_chat(user,span_notice("You start trimming [src]."))
		if(do_after(user,3 SECONDS,target=src))
			to_chat(user,span_notice("You finish trimming [src]."))
			change_visual()

/// Cycle basic plant visuals
/obj/item/kirbyplants/proc/change_visual()
	if(!random_plant_states)
		generate_states()
	var/current = random_plant_states.Find(icon_state)
	var/next = WRAP(current+1,1,length(random_plant_states))
	icon_state = random_plant_states[next]

/obj/item/kirbyplants/random
	icon = 'icons/obj/flora/_flora.dmi'
	icon_state = "random_plant"

/obj/item/kirbyplants/random/Initialize(mapload)
	. = ..()
	icon = 'icons/obj/flora/plants.dmi'
	if(!random_plant_states)
		generate_states()
	icon_state = pick(random_plant_states)

/obj/item/kirbyplants/proc/generate_states()
	random_plant_states = list()
	for(var/i in 1 to 25)
		var/number
		if(i < 10)
			number = "0[i]"
		else
			number = "[i]"
		random_plant_states += "plant-[number]"
	random_plant_states += "applebush"


/obj/item/kirbyplants/dead
	name = "RD's potted plant"
	desc = "A gift from the botanical staff, presented after the RD's reassignment. There's a tag on it that says \"Y'all come back now, y'hear?\"\nIt doesn't look very healthy..."
	icon_state = "plant-25"
	trimmable = FALSE

/obj/item/kirbyplants/photosynthetic
	name = "photosynthetic potted plant"
	desc = "A bioluminescent plant."
	icon_state = "plant-09"
	light_color = COLOR_BRIGHT_BLUE
	light_range = 3

/obj/item/kirbyplants/fullysynthetic
	name = "plastic potted plant"
	desc = "A fake, cheap looking, plastic tree. Perfect for people who kill every plant they touch."
	icon_state = "plant-26"
	custom_materials = (list(/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 4))
	trimmable = FALSE

/obj/item/kirbyplants/fullysynthetic/Initialize(mapload)
	. = ..()
	icon_state = "plant-[rand(26, 29)]"

/obj/item/kirbyplants/potty
	name = "Potty the Potted Plant"
	desc = "A secret agent staffed in the station's bar to protect the mystical cakehat."
	icon_state = "potty"
	trimmable = FALSE

/obj/item/kirbyplants/fern
	name = "neglected fern"
	desc = "An old botanical research sample collected on a long forgotten jungle planet."
	icon_state = "fern"
	trimmable = FALSE

/obj/item/kirbyplants/fern/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_ALGAE, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 5)
