
/obj/item/weapon/reagent_containers/food/snacks/pie
	icon = 'icons/obj/food/piecake.dmi'
	trash = /obj/item/trash/plate
	bitesize = 3
	w_class = 3
	volume = 80
	list_reagents = list("nutriment" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/pie/plain
	name = "plain pie"
	desc = "A simple pie, still delicious."
	icon_state = "pie"
	custom_food_type = /obj/item/weapon/reagent_containers/food/snacks/customizable/pie
	bonus_reagents = list("nutriment" = 8, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pie/cream
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 2, "vitamin" = 2)
	list_reagents = list("nutriment" = 6, "banana" = 5, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/pie/cream/throw_impact(atom/hit_atom)
	if(!..()) //was it caught by a mob?
		var/turf/T = get_turf(hit_atom)
		new/obj/effect/decal/cleanable/pie_smudge(T)
		reagents.reaction(hit_atom, TOUCH)

		if(!ismob(hit_atom)) //if the creampie misses
			qdel(src)
			return

		else //if the creampie hits
			var/mob/living/H = hit_atom
			var/image/creamoverlay = image('icons/effects/creampie.dmi')

			if(istype(H, /mob/living/carbon/human))
				var/mob/living/carbon/human/S = hit_atom
				if(S.dna && S.dna.species && ("tail_lizard" in S.dna.species.mutant_bodyparts))
					creamoverlay.icon_state = "creampie_lizard"
				else creamoverlay.icon_state = "creampie_human"
			else if(istype(H, /mob/living/carbon/monkey))
				creamoverlay.icon_state = "creampie_monkey"
			else if(istype(H, /mob/living/carbon/alien))
				creamoverlay.icon_state = "creampie_xenomorph"
				if(istype(H, /mob/living/carbon/alien/humanoid/royal)) //lets not mess with queen yet
					return
			else if(istype(H, /mob/living/silicon/ai))
				creamoverlay.icon_state = "creampie_ai"
			else if(istype(H, /mob/living/simple_animal/drone))
				creamoverlay.icon_state = "creampie_drone"
			else if(istype(H, /mob/living/simple_animal/pet/dog/corgi))
				creamoverlay.icon_state = "creampie_corgi"
			else return //if the target mob isn't compatible

			if(istype(H, /mob/living/carbon/human))
				H.Weaken(1) //splat!
				H.adjust_blurriness(1)
			visible_message("<span class='userdanger'>[H] was creamed by the [src]!!</span>")
			H.overlays += creamoverlay

			qdel(src)


/obj/item/weapon/reagent_containers/food/snacks/pie/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)
	list_reagents = list("nutriment" = 10, "berryjuice" = 5, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/pie/bearypie
	name = "beary pie"
	desc = "No brown bears, this is a good sign."
	icon_state = "bearypie"
	bonus_reagents = list("nutriment" = 2, "vitamin" = 3)
	list_reagents = list("nutriment" = 2, "vitamin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/pie/meatpie
	name = "meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 5)


/obj/item/weapon/reagent_containers/food/snacks/pie/tofupie
	name = "tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)


/obj/item/weapon/reagent_containers/food/snacks/pie/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	bitesize = 4
	bonus_reagents = list("nutriment" = 1, "vitamin" = 4)
	list_reagents = list("nutriment" = 6, "amatoxin" = 3, "mushroomhallucinogen" = 1, "vitamin" = 4)


/obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie/New()
	..()
	if(prob(10))
		name = "exceptional plump pie"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
		reagents.add_reagent("omnizine", 5)
		bonus_reagents = list("nutriment" = 1, "omnizine" = 5, "vitamin" = 4)


/obj/item/weapon/reagent_containers/food/snacks/pie/xemeatpie
	name = "xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 1, "vitamin" = 5)


/obj/item/weapon/reagent_containers/food/snacks/pie/applepie
	name = "apple pie"
	desc = "A pie containing sweet sweet love...or apple."
	icon_state = "applepie"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 3)



/obj/item/weapon/reagent_containers/food/snacks/pie/cherrypie
	name = "cherry pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)


/obj/item/weapon/reagent_containers/food/snacks/pie/pumpkinpie
	name = "pumpkin pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	slices_num = 5
	bonus_reagents = list("nutriment" = 1, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	name = "pumpkin pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFA500"
	list_reagents = list("nutriment" = 2)

/obj/item/weapon/reagent_containers/food/snacks/pie/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 4)
	list_reagents = list("nutriment" = 8, "gold" = 5, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/pie/grapetart
	name = "grape tart"
	desc = "A tasty dessert that reminds you of the wine you didn't make."
	icon_state = "grapetart"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 4)
	list_reagents = list("nutriment" = 4, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/pie/blumpkinpie
	name = "blumpkin pie"
	desc = "An odd blue pie made with toxic blumpkin."
	icon_state = "blumpkinpie"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/blumpkinpieslice
	slices_num = 5
	bonus_reagents = list("nutriment" = 3, "vitamin" = 6)

/obj/item/weapon/reagent_containers/food/snacks/blumpkinpieslice
	name = "blumpkin pie slice"
	desc = "A slice of blumpkin pie, with whipped cream on top. Is this edible?"
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "blumpkinpieslice"
	trash = /obj/item/trash/plate
	filling_color = "#1E90FF"
	list_reagents = list("nutriment" = 2)

/obj/item/weapon/reagent_containers/food/snacks/pie/dulcedebatata
	name = "dulce de batata"
	desc = "A delicious jelly made with sweet potatoes."
	icon_state = "dulcedebatata"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/dulcedebatataslice
	slices_num = 5
	bonus_reagents = list("nutriment" = 4, "vitamin" = 8)

/obj/item/weapon/reagent_containers/food/snacks/dulcedebatataslice
	name = "dulce de batata slice"
	desc = "A slice of sweet dulce de batata jelly."
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "dulcedebatataslice"
	trash = /obj/item/trash/plate
	filling_color = "#8B4513"
	list_reagents = list("nutriment" = 2)

/obj/item/weapon/reagent_containers/food/snacks/pie/frostypie
	name = "frosty pie"
	desc = "Tastes like blue and cold."
	icon_state = "frostypie"
	bonus_reagents = list("nutriment" = 4, "vitamin" = 6)
