// Valentine's Day events //
// why are you playing spessmens on valentine's day you wizard //


// valentine / candy heart distribution //

/datum/round_event_control/valentines
	name = "Valentines!"
	holidayID = VALENTINES
	typepath = /datum/round_event/valentines
	weight = -1							//forces it to be called, regardless of weight
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/valentines/start()
	..()
	for(var/mob/living/carbon/human/H in mob_list)
		H.put_in_hands(new /obj/item/weapon/valentine)
		var/obj/item/weapon/storage/backpack/b = locate() in H.contents
		new /obj/item/weapon/reagent_containers/food/snacks/candyheart(b)

/datum/round_event/valentines/announce()
	priority_announce("It's Valentine's Day! Give a valentine to that special someone!")

/obj/item/weapon/valentine
	name = "valentine"
	desc = "A Valentine's card! Wonder what it says..."
	icon = 'icons/obj/toy.dmi'
	icon_state = "sc_Ace of Hearts_syndicate" // shut up
	var/message = "A generic message of love or whatever."
	burn_state = FLAMMABLE
	w_class = 1

/obj/item/weapon/valentine/New()
	..()
	message = pick("Roses are red / Violets are good / One day while Andy...",
	               "My love for you is like the singularity. It cannot be contained.",
	               "Will you be my lusty xenomorph maid?",
	               "We go together like the clown and the external airlock.",
	               "Roses are red, liches are wizards, I love you more than a whole squad of lizards.",
	               "Be my valentine. Law 2.",
	               "You must be a mime, because you leave me speechless.",
	               "We make a better couple than Ian and the HoP."
	               "You're hotter than a plasma fire in toxins.")

/obj/item/weapon/valentine/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/pen) || istype(W, /obj/item/toy/crayon))
		var/recipient = stripped_input(user, "Who is receiving this valentine?", "To:", null , 20)
		var/sender = stripped_input(user, "Who is sending this valentine?", "From:", null , 20)
		if(recipient && sender)
			name = "valentine - To: [recipient] From [sender]"
	..()

/obj/item/weapon/reagent_containers/food/snacks/candyheart
	name = "candy heart"
	icon = 'icons/obj/holiday_misc.dmi'
	icon_state = "candyheart"
	desc = "A heart-shaped candy that reads: "
	list_reagents = list("sugar" = 4)
	junkiness = 5

/obj/item/weapon/valentine/New()
	..()
	desc = pick("A heart-shaped candy that reads: HONK ME",
                "A heart-shaped candy that reads: ERP",
                "A heart-shaped candy that reads: LEWD",
                "A heart-shaped candy that reads: LUSTY",
                "A heart-shaped candy that reads: SPESS LOVE")