/obj/item/food/sandwich
	name = "sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "sandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("meat" = 2, "cheese" = 1, "bread" = 2, "lettuce" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sandwich/cheese
	name = "cheese sandwich"
	desc = "A light snack for a warm day. ...but what if you grilled it?"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("bread" = 1, "cheese" = 1)
	foodtypes = GRAIN | DAIRY
	venue_value = FOOD_PRICE_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/sandwich/cheese/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/sandwich/cheese/grilled, rand(30 SECONDS, 60 SECONDS), TRUE)

/obj/item/food/sandwich/cheese/grilled
	name = "grilled cheese sandwich"
	desc = "A warm, melty sandwich that goes perfectly with tomato soup."
	icon_state = "toastedsandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/carbon = 4,
	)
	tastes = list("toast" = 2, "cheese" = 3, "butter" = 1)
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sandwich/jelly
	name = "jelly sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	bite_consumption = 3
	tastes = list("bread" = 1, "jelly" = 1)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/sandwich/jelly/slime
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/toxin/slimejelly = 10, /datum/reagent/consumable/nutriment/vitamin = 4)
	foodtypes = GRAIN | TOXIC

/obj/item/food/sandwich/jelly/cherry
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/cherryjelly = 8, /datum/reagent/consumable/nutriment/vitamin = 4)
	foodtypes = GRAIN | FRUIT | SUGAR

/obj/item/food/sandwich/notasandwich
	name = "not-a-sandwich"
	desc = "Something seems to be wrong with this, you can't quite figure what. Maybe it's his moustache."
	icon_state = "notasandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 10,
	)
	tastes = list("nothing suspicious" = 1)
	foodtypes = GRAIN | GROSS
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/griddle_toast
	name = "griddle toast"
	desc = "Thick cut bread, griddled to perfection."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "griddle_toast"
	food_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("toast" = 1)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_MASK
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/butteredtoast
	name = "buttered toast"
	desc = "Butter lightly spread over a piece of toast."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "butteredtoast"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("butter" = 1, "toast" = 1)
	foodtypes = GRAIN | BREAKFAST
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/jelliedtoast
	name = "jellied toast"
	desc = "A slice of toast covered with delicious jam."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "jellytoast"
	bite_consumption = 3
	tastes = list("toast" = 1, "jelly" = 1)
	foodtypes = GRAIN | BREAKFAST
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/jelliedtoast/cherry
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/cherryjelly = 8, /datum/reagent/consumable/nutriment/vitamin = 4)
	foodtypes = GRAIN | FRUIT | SUGAR | BREAKFAST

/obj/item/food/jelliedtoast/slime
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/toxin/slimejelly = 8, /datum/reagent/consumable/nutriment/vitamin = 4)
	foodtypes = GRAIN | TOXIC | SUGAR | BREAKFAST

/obj/item/food/twobread
	name = "two bread"
	desc = "This seems awfully bitter."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "twobread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("bread" = 2)
	foodtypes = GRAIN
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/hotdog
	name = "hotdog"
	desc = "Fresh footlong ready to go down on."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "hotdog"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/ketchup = 3,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("bun" = 3, "meat" = 2)
	foodtypes = GRAIN | MEAT //Ketchup is not a vegetable
	w_class = WEIGHT_CLASS_SMALL
	venue_value = FOOD_PRICE_CHEAP
	crafting_complexity = FOOD_COMPLEXITY_3
	custom_price = PAYCHECK_CREW * 0.7

// Used for unit tests, do not delete
/obj/item/food/hotdog/debug
	eat_time = 0

/obj/item/food/danish_hotdog
	name = "danish hotdog"
	desc = "Appetizing bun, with a sausage in the middle, covered with sauce, fried onion and pickles rings"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "danish_hotdog"
	bite_consumption = 4
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/ketchup = 3,
		/datum/reagent/consumable/nutriment/vitamin = 7,
	)
	tastes = list("bun" = 3, "meat" = 2, "fried onion" = 1, "pickles" = 1)
	foodtypes = GRAIN | MEAT | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	venue_value = FOOD_PRICE_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_4
	custom_price = PAYCHECK_CREW

/obj/item/food/sandwich/blt
	name = "\improper BLT"
	desc = "A classic bacon, lettuce, and tomato sandwich."
	icon_state = "blt"
	bite_consumption = 4
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	tastes = list("bacon" = 3, "lettuce" = 2, "tomato" = 2, "bread" = 2)
	foodtypes = GRAIN | MEAT | VEGETABLES | BREAKFAST
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sandwich/peanut_butter_jelly
	name = "peanut butter and jelly sandwich"
	desc = "A classic PB&J sandwich, just like your mom used to make."
	icon_state = "peanut_butter_jelly_sandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("peanut butter" = 1, "jelly" = 1, "bread" = 2)
	foodtypes = GRAIN | FRUIT | NUTS
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sandwich/peanut_butter_banana
	name = "peanut butter and banana sandwich"
	desc = "A peanut butter sandwich with banana slices mixed in, a good high protein treat."
	icon_state = "peanut_butter_banana_sandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/banana = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("peanut butter" = 1, "banana" = 1, "bread" = 2)
	foodtypes = GRAIN | FRUIT | NUTS
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sandwich/philly_cheesesteak
	name = "Philly cheesesteak"
	desc = "A popular sandwich made of sliced meat, onions, melted cheese in a long hoagie roll. Mouthwatering doesn't even begin to describe it."
	icon_state = "philly_cheesesteak"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 8,
	)
	tastes = list("bread" = 1, "juicy meat" = 1, "melted cheese" = 1, "onions" = 1)
	foodtypes = GRAIN | MEAT | DAIRY | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sandwich/toast_sandwich
	name = "toast sandwich"
	desc = "A piece of buttered toast between two slices of bread. Why would you make this?"
	icon_state = "toast_sandwich"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("bread" = 2, "Britain" = 1, "butter" = 1, "toast" = 1)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/sandwich/death
	name = "death sandwich"
	desc = "Eat it right, or you die!"
	icon_state = "death_sandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/protein = 14,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("bread" = 1, "meat" = 1, "tomato sauce" = 1, "death" = 1)
	foodtypes = GRAIN | MEAT
	eat_time = 4 SECONDS // Makes it harder to force-feed this to people as a weapon, as funny as that is.

/obj/item/food/sandwich/death/Initialize(mapload)
	. = ..()
	obj_flags &= ~UNIQUE_RENAME // You shouldn't be able to disguise this on account of how it kills you

// Makes you feel disgusted if you look at it wrong.
/obj/item/food/sandwich/death/examine(mob/user)
	. = ..()
	// Only human mobs, not animals or silicons, can like/dislike by this.
	if(!ishuman(user))
		return
	if(check_liked(user) == FOOD_LIKED)
		return
	to_chat(user, span_warning("You imagine yourself eating [src]. You feel a sudden sour taste in your mouth, and a horrible feeling that you've done something wrong."))
	user.adjust_disgust(33)

// Override for after_eat and check_liked callbacks.
/obj/item/food/sandwich/death/make_edible()
	. = ..()
	AddComponent(/datum/component/edible, after_eat = CALLBACK(src, PROC_REF(after_eat)), check_liked = CALLBACK(src, PROC_REF(check_liked)))

/**
* Callback to be used with the edible component.
* If you have the right clothes and hairstyle, you like it.
* If you don't, you don't like it.
*/
/obj/item/food/sandwich/death/proc/check_liked(mob/living/carbon/human/consumer)
	// Closest thing to a mullet we have
	if(consumer.hairstyle == "Gelled Back" && istype(consumer.get_item_by_slot(ITEM_SLOT_ICLOTHING), /obj/item/clothing/under/rank/civilian/cookjorts))
		return FOOD_LIKED
	return FOOD_ALLERGIC

/**
* Callback to be used with the edible component.
* If you take a bite of the sandwich with the right clothes and hairstyle, you like it.
* If you don't, you contract a deadly disease.
*/
/obj/item/food/sandwich/death/proc/after_eat(mob/living/carbon/human/consumer)
	// If you like it, you're eating it right.
	if(check_liked(consumer) == FOOD_LIKED)
		return
	// I thought it didn't make sense for it to instantly kill you, so instead enjoy shitloads of toxin damage per bite.
	balloon_alert(consumer, "ate it wrong!")
	consumer.ForceContractDisease(new /datum/disease/death_sandwich_poisoning())

/obj/item/food/sandwich/death/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] starts to shove [src] down [user.p_their()] throat the wrong way. It looks like [user.p_theyre()] trying to commit suicide!"))
	qdel(src)
	user.gib()
	return MANUAL_SUICIDE
