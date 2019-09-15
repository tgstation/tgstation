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

///obj/item/clothing
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
	if (!linkedJobType || assignment == "Unassigned")
		return 'icons/mob/hud.dmi'
	return initial(linkedJobType.hud_icon)


		//	JOBS	//

/datum/job
	var/id_icon = 'icons/obj/card.dmi'	// Overlay on your ID
	var/hud_icon = 'icons/mob/hud.dmi'	// Sec Huds see this


	//antag disallowing//

/datum/game_mode/revolution
	protected_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Deputy")

/datum/game_mode/traitor/changeling
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Deputy")

/datum/game_mode/clockwork_cult
	protected_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Deputy")

/datum/game_mode/cult
	protected_jobs = list("Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Deputy")

/datum/game_mode/devil
	protected_jobs = list("Lawyer", "Curator", "Chaplain", "Head of Security", "Captain", "AI", "Deputy")

/datum/game_mode/traitor
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Deputy")

