/*
 *	This file is for any additions to existing object classes that don't explicitly
 *	belong to another subject (such as checking for Vampire status on a mob).
 *
 *
 *
 */





		//  ATOMS  //

/atom
	var/use_without_hands = FALSE // Now you can use something regardless of having a hand. EX: Beefman Phobetor Tears


		// REAGENTS / FOOD //

/obj/item/reagent_containers
	var/attack_from_any_intent = FALSE		// Now reagents will continue not to splash except in HARM, but food can do it in any intent (though HELP skips and makes you eat it)
/obj/item/reagent_containers/food
	attack_from_any_intent = TRUE

		//  CLOTHING  //

/obj/item/clothing
	// icon =  'icons/mob/uniforms.dmi'   <--- This already exists! This is for the item on the floor, NOT the sprite.
	var/worn_icon = 'icons/mob/uniform.dmi'  // We created this to add to the sprite!



