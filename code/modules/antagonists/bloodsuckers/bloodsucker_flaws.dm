/////////////////////////////////////////////////////////////////////////////////////////
// Any changes to clans have to be reflected in '/obj/item/book/kindred' /search proc. //
/////////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/bloodsucker/proc/AssignClanAndBane()
	var/static/list/clans = list(
		CLAN_BRUJAH,
		CLAN_NOSFERATU,
		CLAN_TREMERE,
		CLAN_VENTRUE,
		CLAN_MALKAVIAN,
		"None",
	)
	var/list/options = list()
	options = clans
	// Brief descriptions in case they don't read the Wiki.
	to_chat(owner, span_announce("List of all Clans:<br> \
		Brujah - Prone to Frenzy, Brawn buffed.<br> \
		Nosferatu - Disfigured, no Masquerade, Ventcrawl.<br> \
		Tremere - Burn in the Chapel, Blood Magic.<br> \
		Ventrue - Cant drink from mindless mobs, can't level up, raise a vassal instead.<br>\
		Malkavian - Complete insanity.<br>"))

	var/answer = tgui_input_list(owner.current, "You have Ranked up far enough to remember your clan. Which clan are you part of?", "Our mind feels luxurious...", options)

	if(!answer || answer == "None")
		to_chat(owner, span_warning("You have wilingfully decided to stay ignorant."))
		return
	var/mob/living/carbon/human/bloodsucker = owner.current
	//switch(answer)
	switch(answer)
		if(CLAN_BRUJAH)
			my_clan = CLAN_BRUJAH
			to_chat(owner, span_announce("You have Ranked up enough to learn: You are part of the Brujah Clan!\n\
				* As part of the Bujah Clan, you are more prone to falling into Frenzy, though you are used to it, and can enter it whenever you want!\n\
				* Additionally, Brawn and punches deal more damage than other Bloodsuckers. Use this to your advantage!\n\
				* Finally, your Favorite Vassal will gain the Brawn ability to help you in combat."))
			/// Makes their max punch, and by extension Brawn, stronger - Stolen from SpendRank()
			if(iscarbon(owner.current))
				for(var/obj/item/bodypart/part in bloodsucker.bodyparts) //Hope that you aren't getting dismembered
					part.unarmed_damage_low += 1.5
					part.unarmed_damage_high += 1.5
			frenzy_threshold = FRENZY_THRESHOLD_HIGHER
			BuyPower(new /datum/action/bloodsucker/brujah)
			return
		if(CLAN_NOSFERATU)
			my_clan = CLAN_NOSFERATU
			to_chat(owner, "<span class='announce'>You have Ranked up enough to learn: You are part of the Nosferatu Clan!<br> \
				* As part of the Nosferatu Clan, you are less interested in disguising yourself within the crew, as such you do not know how to use the Masquerade and Veil ability.<br> \
				* Additionally, in exchange for having a bad back and not being identifiable, you can fit into vents using Alt+Click</span>")
			for(var/datum/action/bloodsucker/power in powers)
				if(istype(power, /datum/action/bloodsucker/masquerade))
					powers -= power
					power.Remove(owner.current)
				if(istype(power, /datum/action/bloodsucker/veil))
					powers -= power
					power.Remove(owner.current)
			if(!bloodsucker.has_quirk(/datum/quirk/badback))
				bloodsucker.add_quirk(/datum/quirk/badback)
			if(!HAS_TRAIT(bloodsucker, TRAIT_VENTCRAWLER_ALWAYS))
				ADD_TRAIT(bloodsucker, TRAIT_VENTCRAWLER_ALWAYS, BLOODSUCKER_TRAIT)
			if(!HAS_TRAIT(bloodsucker, TRAIT_DISFIGURED))
				ADD_TRAIT(bloodsucker, TRAIT_DISFIGURED, BLOODSUCKER_TRAIT)
			return
		if(CLAN_TREMERE)
			my_clan = CLAN_TREMERE
			to_chat(owner, span_announce("You have Ranked up enough to learn: You are part of the Tremere Clan!\n\
				* As part of the Tremere Clan, you are weak to True Faith, as such are unable to enter the Chapel.\n\
				* Additionally, you cannot learn new Powers, instead you will upgrade your Blood Magic to grow stronger.\n\
				* You have been given a spare Rank to spend immediately, and you can get more manually by Vassalizing people."))
			remove_nondefault_powers()
			bloodsucker_level_unspent++
			BuyPower(new /datum/action/bloodsucker/targeted/tremere/dominate)
			BuyPower(new /datum/action/bloodsucker/targeted/tremere/auspex)
			BuyPower(new /datum/action/bloodsucker/targeted/tremere/thaumaturgy)
			LevelUpPowers()
			return
		if(CLAN_VENTRUE) // WILLARD TODO: Make a Ventrue-unique objective to drink X amount of Blood?
			my_clan = CLAN_VENTRUE
			to_chat(owner, "<span class='announce'>You have Ranked up enough to learn: You are part of the Ventrue Clan!<br> \
				* As part of the Ventrue Clan, you are extremely snobby with your meals, and refuse to drink blood from people without a Mind.<br> \
				* Additionally, you will no longer Rank up. You are now instead able to get a Favorite vassal, by putting a Vassal on the persuasion rack and attempting to Tortute them.<br> \
				* Finally, you may Rank your Favorite Vassal (and your own powers) up by buckling them onto a Candelabrum and using it, this will cost a Rank or Blood to do.</span>")
			to_chat(owner, "<span class='announce'>* Bloodsucker Tip: Examine the Persuasion Rack/Candelabrum to see how they operate!</span>")
			return
		if(CLAN_MALKAVIAN)
			my_clan = CLAN_MALKAVIAN
			to_chat(owner, "<span class='reallybig hypnophrase'>Welcome to the Malkavian...</span>")
			to_chat(owner, span_userdanger("* Bloodsucker Malkavian: The voices will not go away. It is endless. You are trapped.\n\
			* If you get a Favorite Vassal, they will suffer a near fate as you, pick wisely."))
			// WILLARD TODO: Make Masquerade hide brain traumas? Also applies to Frenzy.
			bloodsucker.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
			bloodsucker.gain_trauma(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)
			ADD_TRAIT(bloodsucker, TRAIT_XRAY_VISION, BLOODSUCKER_TRAIT)
			return

		else
			to_chat(owner, "<span class='warning'>You have wilingfully decided to stay ignorant.</span>")
			return


	owner.announce_objectives()
