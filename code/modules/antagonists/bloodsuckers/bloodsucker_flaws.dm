/////////////////////////////////////////////////////////////////////////////////////////
// Any changes to clans have to be reflected in '/obj/item/book/kindred' /search proc. //
/////////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/bloodsucker/proc/AssignClanAndBane()
	var/static/list/clans = list(
		CLAN_GANGREL,
		//CLAN_LASOMBRA,
		"None",
	)
	var/list/options = list()
	options = clans
	// Brief descriptions in case they don't read the Wiki.
	to_chat(owner, span_announce("List of all Clans:\n\
		Gangrel - Prone to Frenzy, special power.\n\
		None - Continue living without a clan."))

	var/answer = input("You have Ranked up far enough to remember your clan. Which clan are you part of?", "Our mind feels luxurious...") in options
	if(!answer || answer == "None") 
		to_chat(owner, span_warning("You have wilingfully decided to stay ignorant."))
		return
	var/mob/living/carbon/human/bloodsucker = owner.current
	//switch(answer)
	if(answer == CLAN_GANGREL)
		my_clan = CLAN_GANGREL
		to_chat(owner, span_announce("You have Ranked up enough to learn: You are part of the Gangrel Clan!\n\
			* As part of the Gangrel Clan, your inner beast has a stronger impact in your undead life.\n\
			* You are prone to falling into a frenzy, and will unleash a wild beast form when doing so,\n\
			* Though once per night you are able to unleash your inner beast to help you in combat.\n\
			* Due to growing more feral you've also strayed away from other bloodsuckers and will only be able to maintain one vassal.\n\
			* Finally, your Favorite Vassal will gain the Minor Beast Form ability to help you in combat."))
		AddHumanityLost(22.4)
		BuyPower(new /datum/action/bloodsucker/gangrel/transform)
		bloodsucker.faction |= "bloodhungry" //i love animals i love animals
		/*if(CLAN_LASOMBRA)
			my_clan = CLAN_LASOMBRA
			to_chat(owner, span_announce("You have Ranked up enough to learn: You are part of the Lasombra Clan!\n\
				* As part of the Lasombra Clan, your past teachings have taught you how to become in touch with the Abyss and practice it's prophecies.\n\
				* It'll take long before the Abyss can break through this plane's veil, but you'll try to salvage any of the energy that comes through,\n\
				* To harness it's energy a ritual must be done each night to gain a shadowpoint, shadowpoints let's you upgrades normal abilities into upgraded ones.\n\
				* The Abyss has blackened your veins and made you immune to brute damage but highly receptive to burn, so you might need to be extra careful when on Torpor.\n\
				* Finally, your Favorite Vassal will gain the Minor Glare and Shadow Walk abilities to help you in combat."))
			ADD_TRAIT(bloodsucker, TRAIT_BRUTEIMMUNE, BLOODSUCKER_TRAIT)
			ADD_TRAIT(bloodsucker, TRAIT_SCORCHED, BLOODSUCKER_TRAIT)
			ADD_TRAIT(bloodsucker, CULT_EYES, BLOODSUCKER_TRAIT)
			var/obj/item/organ/heart/nightmare/nightmarish_heart = new
			nightmarish_heart.Insert(bloodsucker)
			nightmarish_heart.Stop()
			for(var/obj/item/light_eater/blade in bloodsucker.held_items)
				QDEL_NULL(blade)
			owner.teach_crafting_recipe(/datum/crafting_recipe/meatcoffin)*/


	owner.announce_objectives() 
