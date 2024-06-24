
/obj/item/kirbyplants
	name = "potted plant"
	//icon = 'icons/obj/fluff/flora/plants.dmi' // ORIGINAL
	icon = 'monkestation/code/modules/blueshift/icons/obj/plants.dmi' // SKYRAT EDIT CHANGE
	icon_state = "plant-01"
	base_icon_state = "plant-01"
	desc = "A little bit of nature contained in a pot."
	layer = ABOVE_MOB_LAYER
	w_class = WEIGHT_CLASS_HUGE
	force = 10
	throwforce = 13
	throw_speed = 2
	throw_range = 4
	item_flags = NO_PIXEL_RANDOM_DROP

	/// Can this plant be trimmed by someone with TRAIT_BONSAI
	var/trimmable = TRUE
	/// Whether this plant is dead and requires a seed to revive
	var/dead = FALSE
	///If it's a special named plant, set this to true to prevent dead-name overriding.
	var/custom_plant_name = FALSE
	var/list/static/random_plant_states
	/// Maximum icon state number - KEEP THIS UP TO DATE
	var/random_state_cap = 43 // SKYRAT EDIT ADDITION

/obj/item/kirbyplants/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/tactical)
	AddComponent(/datum/component/two_handed, require_twohands = TRUE, force_unwielded = 10, force_wielded = 10)
	AddElement(/datum/element/beauty, 500)
	if(icon_state != base_icon_state && icon_state != "plant-25") //mapedit support
		base_icon_state = icon_state
	update_appearance()

/obj/item/kirbyplants/update_name(updates)
	. = ..()
	if(custom_plant_name)
		return
	name = "[dead ? "dead ":null][initial(name)]"

/obj/item/kirbyplants/update_desc(updates)
	. = ..()
	desc = dead ? "The unidentifiable plant remnants make you feel like planting something new in the pot." : initial(desc)

/obj/item/kirbyplants/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, dead))
		update_appearance()

/obj/item/kirbyplants/update_icon_state()
	. = ..()
	icon_state = dead ? "plant-25" : base_icon_state

/obj/item/kirbyplants/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(!dead && trimmable && HAS_TRAIT(user,TRAIT_BONSAI) && isturf(loc) && I.get_sharpness())
		to_chat(user,span_notice("You start trimming [src]."))
		if(do_after(user,3 SECONDS,target=src))
			to_chat(user,span_notice("You finish trimming [src]."))
			change_visual()
	if(dead && istype(I, /obj/item/seeds))
		to_chat(user,span_notice("You start planting a new seed into the pot."))
		if(do_after(user,3 SECONDS,target=src))
			qdel(I)
			dead = FALSE
			update_appearance()

/// Cycle basic plant visuals
/obj/item/kirbyplants/proc/change_visual()
	if(!random_plant_states)
		generate_states()
	var/current = random_plant_states.Find(icon_state)
	var/next = WRAP(current+1,1,length(random_plant_states))
	icon_state = random_plant_states[next]

/obj/item/kirbyplants/proc/generate_states()
	random_plant_states = list()
	for(var/i in 1 to random_state_cap) //SKYRAT EDIT CHANGE - ORIGINAL: for(var/i in 1 to 24)
		var/number
		if(i < 10)
			number = "0[i]"
		else
			number = "[i]"
		random_plant_states += "plant-[number]"
	random_plant_states += list("applebush", "monkeyplant") //SKYRAT EDIT CHANGE - ORIGINAL:random_plant_states += "applebush"

/obj/item/kirbyplants/random
	icon = 'icons/obj/flora/_flora.dmi'
	icon_state = "random_plant"

/obj/item/kirbyplants/random/Initialize(mapload)
	. = ..()
	//icon = 'icons/obj/flora/plants.dmi' // ORIGINAL
	icon = 'monkestation/code/modules/blueshift/icons/obj/plants.dmi' //SKYRAT EDIT CHANGE
	randomize_base_icon_state()

//Handles randomizing the icon during initialize()
/obj/item/kirbyplants/random/proc/randomize_base_icon_state()
	if(!random_plant_states)
		generate_states()
	base_icon_state = pick(random_plant_states)
	if(!dead) //no need to update the icon if we're already dead.
		update_appearance(UPDATE_ICON)

/obj/item/kirbyplants/random/dead
	icon = 'monkestation/code/modules/blueshift/icons/obj/plants.dmi'
	icon_state = "plant-25"
	dead = TRUE

/obj/item/kirbyplants/random/dead/research_director
	name = "RD's potted plant"
	custom_plant_name = TRUE

/obj/item/kirbyplants/random/dead/update_desc(updates)
	. = ..()
	desc = "A gift from the botanical staff, presented after the RD's reassignment. There's a tag on it that says \"Y'all come back now, y'hear?\"[dead ? "\nIt doesn't look very healthy...":null]"

/obj/item/kirbyplants/random/fullysynthetic
	icon = 'monkestation/code/modules/blueshift/icons/obj/plants.dmi'
	name = "plastic potted plant"
	desc = "A fake, cheap looking, plastic tree. Perfect for people who kill every plant they touch."
	icon_state = "plant-26"
	custom_materials = (list(/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 4))
	trimmable = FALSE

//Handles randomizing the icon during initialize()
/obj/item/kirbyplants/random/fullysynthetic/randomize_base_icon_state()
	base_icon_state = "plant-[rand(26, 29)]"
	update_appearance(UPDATE_ICON)

//SKYRAT EDIT ADDITION START
/obj/item/kirbyplants/monkey
	name = "monkey plant"
	desc = "Something that seems to have been made by the Nanotrasen science division, one might call it an abomination. It's heads seem... alive."
	icon_state = "monkeyplant"
	trimmable = FALSE
//SKYRAT EDIT ADDITION END

/obj/item/kirbyplants/photosynthetic
	name = "photosynthetic potted plant"
	desc = "A bioluminescent plant."
	icon_state = "plant-09"
	light_color = COLOR_BRIGHT_BLUE
	light_outer_range = 3

/obj/item/kirbyplants/potty
	name = "Potty the Potted Plant"
	desc = "A secret agent staffed in the station's bar to protect the mystical cakehat."
	icon_state = "potty"
	custom_plant_name = TRUE
	trimmable = FALSE

/obj/item/kirbyplants/fern
	name = "neglected fern"
	desc = "An old botanical research sample collected on a long forgotten jungle planet."
	icon_state = "fern"
	trimmable = FALSE

/obj/item/kirbyplants/fern/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_ALGAE, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 5)


/obj/item/kirbyplants/organic/applebush
	icon_state = "applebush"

/obj/item/kirbyplants/organic/plant1
	icon_state = "plant-01"

/obj/item/kirbyplants/organic/plant2
	icon_state = "plant-02"

/obj/item/kirbyplants/organic/plant3
	icon_state = "plant-03"

/obj/item/kirbyplants/organic/plant4
	icon_state = "plant-04"

/obj/item/kirbyplants/organic/plant5
	icon_state = "plant-05"

/obj/item/kirbyplants/organic/plant6
	icon_state = "plant-06"

/obj/item/kirbyplants/organic/plant7
	icon_state = "plant-07"

/obj/item/kirbyplants/organic/plant8
	icon_state = "plant-08"

/obj/item/kirbyplants/organic/plant9
	icon_state = "plant-09"

/obj/item/kirbyplants/organic/plant10
	icon_state = "plant-10"

/obj/item/kirbyplants/organic/plant11
	icon_state = "plant-11"

/obj/item/kirbyplants/organic/plant12
	icon_state = "plant-12"

/obj/item/kirbyplants/organic/plant13
	icon_state = "plant-13"

/obj/item/kirbyplants/organic/plant14
	icon_state = "plant-14"

/obj/item/kirbyplants/organic/plant15
	icon_state = "plant-15"

/obj/item/kirbyplants/organic/plant16
	icon_state = "plant-16"

/obj/item/kirbyplants/organic/plant17
	icon_state = "plant-17"

/obj/item/kirbyplants/organic/plant18
	icon_state = "plant-18"

/obj/item/kirbyplants/organic/plant19
	icon_state = "plant-19"

/obj/item/kirbyplants/organic/plant20
	icon_state = "plant-20"

/obj/item/kirbyplants/organic/plant1
	icon_state = "plant-01"

/obj/item/kirbyplants/organic/plant21
	icon_state = "plant-21"

/obj/item/kirbyplants/organic/plant22
	icon_state = "plant-22"

/obj/item/kirbyplants/organic/plant23
	icon_state = "plant-23"

/obj/item/kirbyplants/organic/plant24
	icon_state = "plant-24"

/obj/item/kirbyplants/synthetic
	name = "plastic potted plant"
	desc = "A fake, cheap looking, plastic tree. Perfect for people who kill every plant they touch."
	custom_materials = (list(/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 4))
	trimmable = FALSE

/obj/item/kirbyplants/synthetic/plant26
	icon_state = "plant-26"

/obj/item/kirbyplants/synthetic/plant27
	icon_state = "plant-27"

/obj/item/kirbyplants/synthetic/plant28
	icon_state = "plant-28"

/obj/item/kirbyplants/synthetic/plant29
	icon_state = "plant-29"
