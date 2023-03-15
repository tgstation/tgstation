/datum/symptom/fermentation
	name = "Endogenous Ethanol Fermentation"
	desc = "This symptom causes the gut bacteria of the infected to continually produce ethanol, creating a near constant state of intoxication."
	stealth = -2
	resistance = -3
	stage_speed = -4
	transmission = 1
	level = 6
	severity = 0 				//Entirely harmless besides a waddle at first.
	symptom_delay_min = 5
	symptom_delay_max = 7
	var/ethanol_power = 3.35 	//Level of drunkenness that will be maintained, scales with Transmission & Stage Speed. This also ensures a harmful virus cannot be stealthed.
	var/drunken_healing = FALSE //Grants Drunken Resilience with a threshold
	var/has_light_drinker = FALSE //storage for existing traits
	var/has_drunk_healing = FALSE //^^^^^
	var/datum/component/is_waddling = FALSE		//For the waddle trait.
	threshold_desc = "<b>Transmission & Stage Speed:</b> The maximum amount of alcohol in the system scales based off the transmission and stage speed stat.<br>\
					<b>Resistance 8:</b> The symptom now heals the infected while drunk and makes light drinkers more capable of holding their liquor. Has no effect on those that are already resilient to alcohol."

/datum/symptom/fermentation/severityset(datum/disease/advance/A)
	ethanol_power = (A.transmission * A.stage_rate + 3)
	severity = 0 //Deliberate reset of severity to prevent it from looping every time a symptom is added
	if(ethanol_power <= 0)
		ethanol_power = 3
	if(ethanol_power >= 81)
		ethanol_power = 81
	if(ethanol_power >= 10)
		severity += round(ethanol_power / 10) //This gives this disease a severity range of -3 to 5, from just giving a trait to being blacked out drunk at all times
	if(A.resistance >= 8)
		severity -= 3

/datum/symptom/fermentation/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 8)
		drunken_healing = TRUE
	ethanol_power = (A.transmission * A.stage_rate + 3.35)
	if(ethanol_power <= 0)
		ethanol_power = 3
	if(ethanol_power >= 81)
		ethanol_power = 81

/datum/symptom/fermentation/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	var/mob/living/carbon/C = M

	if(A.stage >= 2)
		if(prob(5))
			to_chat(M, "<span class='notice'>[pick(
			"I see it on the table, gotta be a black label...",
			"Drink, drank, drunk...",
			"So pour me a glass of the pegleg potion, drink to the end of time...",
			"We drank the tavern dry, devoured all the meats...",
			"We'll dance and sing and fight until the early mornin' light...",
			"You hear a distant calling and you know it's meant for you...",
			"So I'll leave ye sitting at the bar and face the wind and rain...",
			"I first produced me pistols and then produced me rapier...",
			"But the devil take the women, for they never can be easy...",
			"Red solo cup, I fill you up...",
			"We are here to drink your beer and steal your rum at the point of a gun...",
			"Soon may the wellerman come to bring us sugar and tea and rum...",
			"Leave her, Johnny, leave her...",
			"And all the harm I've ever done, alas it was to none but me...",
			"So fill to me the parting glass and drink a health whatever befalls...",
			"Oh ho, the rattlin bog, the bog down in the valley-o...")]</span>")

	if(A.stage >= 3)
		if(!is_waddling)
			is_waddling = M.AddComponent(/datum/component/waddling) //Applies waddle
			to_chat(M, "<span class='warning'>You feel like you can't walk straight!</span>")
		if(ishuman(M) && drunken_healing)
			var/mob/living/carbon/human/H = A.affected_mob
			drunken_healing = FALSE //Only run once.
			if(HAS_TRAIT(H, TRAIT_LIGHT_DRINKER))
				has_light_drinker = TRUE
				REMOVE_TRAIT(H, TRAIT_LIGHT_DRINKER, DISEASE_TRAIT)
				return
			if(HAS_TRAIT(H, TRAIT_DRUNK_HEALING))
				has_drunk_healing = TRUE
			ADD_TRAIT(H, TRAIT_DRUNK_HEALING, DISEASE_TRAIT)

	if(A.stage >= 5)
		if(prob(20))
			M.emote(pick("clap", "laugh", "dance", "cry", "mumble", "cross", "chuckle", "flip", "grin", "grimace", "sigh", "smug", "sway", "spin"))
		C.drunkenness += (ethanol_power/8) //8 loops around to get it to cap out
		if(C.drunkenness >= ethanol_power) //A low drunkenness cap will let scientists hit the Ballmer point with a correctly made virus. 10 + 3.35!
			C.drunkenness = ethanol_power  //Keeps your drunkenness at a cap, this makes it fairly safe to drink heavily


/datum/symptom/fermentation/End(datum/disease/advance/A) //Restore traits as needed.
	. = ..()
	var/mob/living/carbon/M = A.affected_mob
	QDEL_NULL(is_waddling)
	if(has_light_drinker == TRUE)
		REMOVE_TRAIT(M, TRAIT_DRUNK_HEALING, DISEASE_TRAIT)
		ADD_TRAIT(M, TRAIT_LIGHT_DRINKER, ROUNDSTART_TRAIT)
		return
	if(has_drunk_healing == FALSE)
		REMOVE_TRAIT(M, TRAIT_DRUNK_HEALING, DISEASE_TRAIT)
