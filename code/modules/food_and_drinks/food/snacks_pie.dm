
/obj/item/reagent_containers/food/snacks/pie
	icon = 'icons/obj/food/piecake.dmi'
	trash = /obj/item/trash/plate
	bitesize = 3
	w_class = WEIGHT_CLASS_NORMAL
	volume = 80
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("pie" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/pie/plain
	name = "plain pie"
	desc = "A simple pie, still delicious."
	icon_state = "pie"
	custom_food_type = /obj/item/reagent_containers/food/snacks/customizable/pie
	bonus_reagents = list("nutriment" = 8, "vitamin" = 1)
	tastes = list("pie" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/pie/cream
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 2, "vitamin" = 2)
	list_reagents = list("nutriment" = 6, "banana" = 5, "vitamin" = 2)
	tastes = list("pie" = 1)
	foodtype = GRAIN | DAIRY | SUGAR
	var/stunning = TRUE

/obj/item/reagent_containers/food/snacks/pie/cream/throw_impact(atom/hit_atom)
	. = ..()
	if(!.) //if we're not being caught
		splat(hit_atom)

/obj/item/reagent_containers/food/snacks/pie/cream/proc/splat(atom/movable/hit_atom)
	if(isliving(loc)) //someone caught us!
		return
	var/turf/T = get_turf(hit_atom)
	new/obj/effect/decal/cleanable/pie_smudge(T)
	if(reagents && reagents.total_volume)
		reagents.reaction(hit_atom, TOUCH)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		var/mutable_appearance/creamoverlay = mutable_appearance('icons/effects/creampie.dmi')
		if(H.dna.species.limbs_id == "lizard")
			creamoverlay.icon_state = "creampie_lizard"
		else
			creamoverlay.icon_state = "creampie_human"
		if(stunning)
			H.Paralyze(20) //splat!
		H.adjust_blurriness(1)
		H.visible_message("<span class='warning'>[H] is creamed by [src]!</span>", "<span class='userdanger'>You've been creamed by [src]!</span>")
		playsound(H, "desceration", 50, TRUE)
		if(!H.creamed) // one layer at a time
			H.add_overlay(creamoverlay)
			H.creamed = TRUE
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "creampie", /datum/mood_event/creampie)
	qdel(src)

/obj/item/reagent_containers/food/snacks/pie/cream/nostun
	stunning = FALSE

/obj/item/reagent_containers/food/snacks/pie/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)
	list_reagents = list("nutriment" = 10, "berryjuice" = 5, "vitamin" = 2)
	tastes = list("pie" = 1, "blackberries" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/pie/bearypie
	name = "beary pie"
	desc = "No brown bears, this is a good sign."
	icon_state = "bearypie"
	bonus_reagents = list("nutriment" = 2, "vitamin" = 3)
	list_reagents = list("nutriment" = 2, "vitamin" = 3)
	tastes = list("pie" = 1, "meat" = 1, "salmon" = 1)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/pie/meatpie
	name = "meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 5)
	tastes = list("pie" = 1, "meat" = 1)
	foodtype = GRAIN | MEAT


/obj/item/reagent_containers/food/snacks/pie/tofupie
	name = "tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)
	tastes = list("pie" = 1, "tofu" = 1)
	foodtype = GRAIN


/obj/item/reagent_containers/food/snacks/pie/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	bitesize = 4
	bonus_reagents = list("nutriment" = 1, "vitamin" = 4)
	list_reagents = list("nutriment" = 6, "amatoxin" = 3, "mushroomhallucinogen" = 1, "vitamin" = 4)
	tastes = list("pie" = 1, "mushroom" = 1)
	foodtype = GRAIN | VEGETABLES | TOXIC | GROSS


/obj/item/reagent_containers/food/snacks/pie/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 4)
	tastes = list("pie" = 1, "mushroom" = 1)
	foodtype = GRAIN | VEGETABLES


/obj/item/reagent_containers/food/snacks/pie/plump_pie/Initialize()
	. = ..()
	var/fey = prob(10)
	if(fey)
		name = "exceptional plump pie"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
		bonus_reagents = list("nutriment" = 1, "omnizine" = 5, "vitamin" = 4)
	if(fey)
		reagents.add_reagent("omnizine", 5)


/obj/item/reagent_containers/food/snacks/pie/xemeatpie
	name = "xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 1, "vitamin" = 5)
	tastes = list("pie" = 1, "meat" = 1, "acid" = 1)
	foodtype = GRAIN | MEAT


/obj/item/reagent_containers/food/snacks/pie/applepie
	name = "apple pie"
	desc = "A pie containing sweet sweet love...or apple."
	icon_state = "applepie"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 3)
	tastes = list("pie" = 1, "apple" = 1)
	foodtype = GRAIN | FRUIT | SUGAR



/obj/item/reagent_containers/food/snacks/pie/cherrypie
	name = "cherry pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)
	tastes = list("pie" = 7, "Nicole Paige Brooks" = 2)
	foodtype = GRAIN | FRUIT | SUGAR


/obj/item/reagent_containers/food/snacks/pie/pumpkinpie
	name = "pumpkin pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/reagent_containers/food/snacks/pumpkinpieslice
	slices_num = 5
	bonus_reagents = list("nutriment" = 1, "vitamin" = 5)
	tastes = list("pie" = 1, "pumpkin" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/pumpkinpieslice
	name = "pumpkin pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFA500"
	list_reagents = list("nutriment" = 2)
	tastes = list("pie" = 1, "pumpkin" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/pie/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 4)
	list_reagents = list("nutriment" = 8, "gold" = 5, "vitamin" = 4)
	tastes = list("pie" = 1, "apple" = 1, "expensive metal" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/pie/grapetart
	name = "grape tart"
	desc = "A tasty dessert that reminds you of the wine you didn't make."
	icon_state = "grapetart"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 4)
	list_reagents = list("nutriment" = 4, "vitamin" = 4)
	tastes = list("pie" = 1, "grape" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/pie/blumpkinpie
	name = "blumpkin pie"
	desc = "An odd blue pie made with toxic blumpkin."
	icon_state = "blumpkinpie"
	slice_path = /obj/item/reagent_containers/food/snacks/blumpkinpieslice
	slices_num = 5
	bonus_reagents = list("nutriment" = 3, "vitamin" = 6)
	tastes = list("pie" = 1, "a mouthful of pool water" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/blumpkinpieslice
	name = "blumpkin pie slice"
	desc = "A slice of blumpkin pie, with whipped cream on top. Is this edible?"
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "blumpkinpieslice"
	trash = /obj/item/trash/plate
	filling_color = "#1E90FF"
	list_reagents = list("nutriment" = 2)
	tastes = list("pie" = 1, "a mouthful of pool water" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/pie/dulcedebatata
	name = "dulce de batata"
	desc = "A delicious jelly made with sweet potatoes."
	icon_state = "dulcedebatata"
	slice_path = /obj/item/reagent_containers/food/snacks/dulcedebatataslice
	slices_num = 5
	bonus_reagents = list("nutriment" = 4, "vitamin" = 8)
	tastes = list("jelly" = 1, "sweet potato" = 1)
	foodtype = GRAIN | VEGETABLES | SUGAR

/obj/item/reagent_containers/food/snacks/dulcedebatataslice
	name = "dulce de batata slice"
	desc = "A slice of sweet dulce de batata jelly."
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "dulcedebatataslice"
	trash = /obj/item/trash/plate
	filling_color = "#8B4513"
	list_reagents = list("nutriment" = 2)
	tastes = list("jelly" = 1, "sweet potato" = 1)
	foodtype = GRAIN | VEGETABLES | SUGAR

/obj/item/reagent_containers/food/snacks/pie/frostypie
	name = "frosty pie"
	desc = "Tastes like blue and cold."
	icon_state = "frostypie"
	bonus_reagents = list("nutriment" = 4, "vitamin" = 6)
	tastes = list("mint" = 1, "pie" = 1)
	foodtype = GRAIN | FRUIT | SUGAR
