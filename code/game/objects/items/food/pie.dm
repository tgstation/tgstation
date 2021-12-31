/obj/item/food/pie
	icon = 'icons/obj/food/piecake.dmi'

	bite_consumption = 3
	atom_size = ITEM_SIZE_NORMAL
	max_volume = 80
	food_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("pie" = 1)
	foodtypes = GRAIN
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/pieslice
	name = "pie slice"
	icon = 'icons/obj/food/piecake.dmi'

	atom_size = ITEM_SIZE_TINY
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("pie" = 1, "uncertainty" = 1)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/pie/plain
	name = "plain pie"
	desc = "A simple pie, still delicious."
	icon_state = "pie"
	food_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("pie" = 1)
	foodtypes = GRAIN
	burns_in_oven = TRUE

/obj/item/food/pie/cream
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	food_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/banana = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pie" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR
	var/stunning = TRUE

/obj/item/food/pie/cream/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!.) //if we're not being caught
		splat(hit_atom)

/obj/item/food/pie/cream/proc/splat(atom/movable/hit_atom)
	if(isliving(loc)) //someone caught us!
		return
	var/turf/hit_turf = get_turf(hit_atom)
	new/obj/effect/decal/cleanable/food/pie_smudge(hit_turf)
	if(reagents?.total_volume)
		reagents.expose(hit_atom, TOUCH)
	if(isliving(hit_atom))
		var/mob/living/living_target_getting_hit = hit_atom
		if(stunning)
			living_target_getting_hit.Paralyze(20) //splat!
		living_target_getting_hit.adjust_blurriness(1)
		living_target_getting_hit.visible_message(span_warning("[living_target_getting_hit] is creamed by [src]!"), span_userdanger("You've been creamed by [src]!"))
		playsound(living_target_getting_hit, "desecration", 50, TRUE)
	if(is_type_in_typecache(hit_atom, GLOB.creamable))
		hit_atom.AddComponent(/datum/component/creamed, src)
	qdel(src)

/obj/item/food/pie/cream/nostun
	stunning = FALSE

/obj/item/food/pie/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	food_reagents = list(/datum/reagent/consumable/nutriment = 11, /datum/reagent/consumable/berryjuice = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pie" = 1, "blackberries" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/pie/bearypie
	name = "beary pie"
	desc = "No brown bears, this is a good sign."
	icon_state = "bearypie"
	food_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("pie" = 1, "meat" = 1, "salmon" = 1)
	foodtypes = GRAIN | SUGAR | MEAT | FRUIT

/obj/item/food/pie/meatpie
	name = "meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	food_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("pie" = 1, "meat" = 1)
	foodtypes = GRAIN | MEAT
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/pie/tofupie
	name = "tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	food_reagents = list(/datum/reagent/consumable/nutriment = 11, /datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("pie" = 1, "tofu" = 1)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/pie/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	bite_consumption = 4
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/toxin/amatoxin = 3, /datum/reagent/drug/mushroomhallucinogen = 1, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pie" = 1, "mushroom" = 1)
	foodtypes = GRAIN | VEGETABLES | TOXIC | GROSS

/obj/item/food/pie/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	food_reagents = list(/datum/reagent/consumable/nutriment = 11, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pie" = 1, "mushroom" = 1)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/pie/plump_pie/Initialize(mapload)
	var/fey = prob(10)
	if(fey)
		name = "exceptional plump pie"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
		food_reagents = list(/datum/reagent/consumable/nutriment = 11, /datum/reagent/medicine/omnizine = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	. = ..()

/obj/item/food/pie/xemeatpie
	name = "xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	food_reagents = list(/datum/reagent/consumable/nutriment = 11, /datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("pie" = 1, "meat" = 1, "acid" = 1)
	foodtypes = GRAIN | MEAT

/obj/item/food/pie/applepie
	name = "apple pie"
	desc = "A pie containing sweet sweet love...or apple."
	icon_state = "applepie"
	food_reagents = list(/datum/reagent/consumable/nutriment = 11, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("pie" = 1, "apple" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR

/obj/item/food/pie/cherrypie
	name = "cherry pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	food_reagents = list(/datum/reagent/consumable/nutriment = 11, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("pie" = 7, "Nicole Paige Brooks" = 2)
	foodtypes = GRAIN | FRUIT | SUGAR

/obj/item/food/pie/pumpkinpie
	name = "pumpkin pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	food_reagents = list(/datum/reagent/consumable/nutriment = 11, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("pie" = 1, "pumpkin" = 1)
	foodtypes = GRAIN | VEGETABLES | SUGAR

/obj/item/food/pie/pumpkinpie/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/pieslice/pumpkin, 5, 20)

/obj/item/food/pieslice/pumpkin
	name = "pumpkin pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("pie" = 1, "pumpkin" = 1)
	foodtypes = GRAIN | VEGETABLES | SUGAR

/obj/item/food/pie/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	food_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/gold = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pie" = 1, "apple" = 1, "expensive metal" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR

/obj/item/food/pie/grapetart
	name = "grape tart"
	desc = "A tasty dessert that reminds you of the wine you didn't make."
	icon_state = "grapetart"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pie" = 1, "grape" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR

/obj/item/food/pie/mimetart
	name = "mime tart"
	desc = "..."
	icon_state = "mimetart"
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/nothing = 10)
	tastes = list("nothing" = 3)
	foodtypes = GRAIN

/obj/item/food/pie/berrytart
	name = "berry tart"
	desc = "A tasty dessert of many different small barries on a thin pie crust."
	icon_state = "berrytart"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("pie" = 1, "berries" = 2)
	foodtypes = GRAIN | FRUIT

/obj/item/food/pie/cocolavatart
	name = "chocolate lava tart"
	desc = "A tasty dessert made of chocolate, with a liquid core." //But it doesn't even contain chocolate...
	icon_state = "cocolavatart"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pie" = 1, "dark chocolate" = 3)
	foodtypes = GRAIN | SUGAR

/obj/item/food/pie/blumpkinpie
	name = "blumpkin pie"
	desc = "An odd blue pie made with toxic blumpkin."
	icon_state = "blumpkinpie"
	food_reagents = list(/datum/reagent/consumable/nutriment = 13, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("pie" = 1, "a mouthful of pool water" = 1)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/pie/blumpkinpie/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/pieslice/blumpkin, 5, 20)

/obj/item/food/pieslice/blumpkin
	name = "blumpkin pie slice"
	desc = "A slice of blumpkin pie, with whipped cream on top. Is this edible?"
	icon_state = "blumpkinpieslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("pie" = 1, "a mouthful of pool water" = 1)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/pie/dulcedebatata
	name = "dulce de batata"
	desc = "A delicious jelly made with sweet potatoes."
	icon_state = "dulcedebatata"
	food_reagents = list(/datum/reagent/consumable/nutriment = 14, /datum/reagent/consumable/nutriment/vitamin = 8)
	tastes = list("jelly" = 1, "sweet potato" = 1)
	foodtypes = VEGETABLES | SUGAR
	venue_value = FOOD_PRICE_EXOTIC

/obj/item/food/pie/dulcedebatata/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/pieslice/dulcedebatata, 5, 20)

/obj/item/food/pieslice/dulcedebatata
	name = "dulce de batata slice"
	desc = "A slice of sweet dulce de batata jelly."
	icon_state = "dulcedebatataslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("jelly" = 1, "sweet potato" = 1)
	foodtypes = VEGETABLES | SUGAR

/obj/item/food/pie/frostypie
	name = "frosty pie"
	desc = "Tastes like blue and cold."
	icon_state = "frostypie"
	food_reagents = list(/datum/reagent/consumable/nutriment = 14, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("mint" = 1, "pie" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR

/obj/item/food/pie/baklava
	name = "baklava"
	desc = "A delightful healthy snack made of nut layers with thin bread."
	icon_state = "baklava"
	food_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("nuts" = 1, "pie" = 1)
	foodtypes = NUTS | SUGAR

/obj/item/food/pie/baklava/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/pieslice/baklava, 6, 20)

/obj/item/food/pieslice/baklava
	name = "baklava dish"
	desc = "A portion of a delightful healthy snack made of nut layers with thin bread"
	icon_state = "baklavaslice"
	tastes = list("nuts" = 1, "pie" = 1)
	foodtypes = NUTS | SUGAR
