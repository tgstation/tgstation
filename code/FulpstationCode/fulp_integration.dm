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

	var/fulp_item = FALSE

	// icon =  'icons/mob/uniforms.dmi'   <--- This already exists! This is for the item on the floor, NOT the sprite.
	//var/worn_icon = 'icon/mob/clothing/under/default.dmi' // 'icons/mob/uniform.dmi'  // We created this to add to the sprite! (human/update_icons.dm)
	// REMOVED They did it for us.


		//	ID CARDS	//

/obj/item/card
	var/datum/job/linkedJobType         // This is a TYPE, not a ref to a particular instance. We'll use this for finding the job and hud icon of each job.
	//var/job_icon = 'icons/obj/card.dmi' // This is now stored on the job.

/obj/item/card/id/proc/return_icon_job()
	if (!linkedJobType || assignment == "Unassigned")
		return 'icons/obj/card.dmi'
	return initial(linkedJobType.id_icon)
/obj/item/card/id/proc/return_icon_hud()
	if (assignment in list("Syndicate Captain", "Syndicate Medical Doctor", "Syndicate Assault Operative", "Syndicate Engineer", "Syndicate Operative", "Syndicate Overlord", "Syndicate Mastermind", "Syndicate Admiral", "Syndicate Official", "Syndicate", "Syndicate Commander", "Syndicate Ship Captain"))
		return 'icons/Fulpicons/fulphud.dmi' //Couldn't think of better solution
	if (!linkedJobType || assignment == "Unassigned")
		return 'icons/mob/hud.dmi'
	return initial(linkedJobType.hud_icon)


		//	JOBS	//

/datum/job
	var/id_icon = 'icons/obj/card.dmi'	// Overlay on your ID
	var/hud_icon = 'icons/mob/hud.dmi'	// Sec Huds see this



