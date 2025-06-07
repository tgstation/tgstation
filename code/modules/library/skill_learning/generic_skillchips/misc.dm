//Contains generic skillchips that are fairly short and simple

/obj/item/skillchip/basketweaving
	name = "Basketsoft 3000 skillchip"
	desc = "Underwater edition."
	auto_traits = list(TRAIT_UNDERWATER_BASKETWEAVING_KNOWLEDGE)
	skill_name = "Underwater Basketweaving"
	skill_description = "Master intricate art of using twine to create perfect baskets while submerged."
	skill_icon = "shopping-basket"
	activate_message = span_notice("You're one with the twine and the sea.")
	deactivate_message = span_notice("Higher mysteries of underwater basketweaving leave your mind.")

/obj/item/skillchip/wine_taster
	name = "WINE skillchip"
	desc = "Wine.Is.Not.Equal version 5."
	auto_traits = list(TRAIT_WINE_TASTER)
	skill_name = "Wine Tasting"
	skill_description = "Recognize wine vintage from taste alone. Never again lack an opinion when presented with an unknown drink."
	skill_icon = "wine-bottle"
	activate_message = span_notice("You recall wine taste.")
	deactivate_message = span_notice("Your memories of wine evaporate.")

/obj/item/skillchip/bonsai
	name = "Hedge 3 skillchip"
	desc = "\"Learn how to trim hedges and potted plants into new shapes. Third edition.\""
	auto_traits = list(TRAIT_BONSAI)
	skill_name = "Hedgetrimming"
	skill_description = "Trim hedges and potted plants into marvelous new shapes with any old knife. Not applicable to plastic plants."
	skill_icon = "spa"
	activate_message = span_notice("Your mind is filled with plant arrangments.")
	deactivate_message = span_notice("You can't remember what a hedge looks like anymore.")

/obj/item/skillchip/useless_adapter
	name = "Skillchip adapter"
	desc = "Yo dawg, heard you like skillchips so we put a skillchip in your skillchip so you can... uuuh..."
	skill_name = "Useless adapter"
	skill_description = "Allows you to insert another skillchip into this adapter after it has been inserted into your brain..."
	skill_icon = "plug"
	activate_message = span_notice("You can now activate another chip through this adapter, but you're not sure why you did this...")
	deactivate_message = span_notice("You no longer have the useless skillchip adapter.")
	skillchip_flags = SKILLCHIP_ALLOWS_MULTIPLE
	// Literally does nothing.
	complexity = 0
	slot_use = 0

/obj/item/skillchip/light_remover
	name = "N16H7M4R3 skillchip"
	desc = "A skillchip about safe lightbulb removal. Whoever came up with that awful name should be fired."
	auto_traits = list(TRAIT_LIGHTBULB_REMOVER)
	skill_name = "Lightbulb Removing"
	skill_description = "Stop failing taking out lightbulbs today, no gloves needed!"
	skill_icon = "lightbulb"
	activate_message = span_notice("Your feel like your pain receptors are less sensitive to hot objects.")
	deactivate_message = span_notice("You feel like hot objects could stop you again...")

/obj/item/skillchip/disk_verifier
	name = "K33P-TH4T-D15K skillchip"
	desc = "A skillchip with a tiny print of a nuclear authentification disk stamped onto it."
	auto_traits = list(TRAIT_DISK_VERIFIER)
	skill_name = "Nuclear Disk Verification"
	skill_description = "Nuclear authentication disks have an extremely long serial number for verification. This skillchip stores that number, which allows the user to automatically spot forgeries."
	skill_icon = "save"
	activate_message = span_notice("You feel your mind automatically verifying long serial numbers on disk shaped objects.")
	deactivate_message = span_notice("The innate recognition of absurdly long disk-related serial numbers fades from your mind.")

/obj/item/skillchip/entrails_reader
	name = "3NTR41LS skillchip"
	auto_traits = list(TRAIT_ENTRAILS_READER)
	skill_name = "Entrails Reader"
	skill_description = "Be able to learn about a person's life, by looking at their internal organs. Not to be confused with looking into the future."
	skill_icon = "lungs"
	activate_message = span_notice("You feel that you know a lot about interpreting organs.")
	deactivate_message = span_notice("Knowledge of liver damage, heart strain and lung scars fades from your mind.")

/obj/item/skillchip/appraiser
	name = "GENUINE ID Appraisal Now! skillchip"
	desc = "The name couldn't be any more desperate and self-explainatory, by skillchip naming standards."
	auto_traits = list(TRAIT_ID_APPRAISER)
	skill_name = "ID Appraisal"
	skill_description = "Appraise an ID and see if it's issued from centcom, or just a cruddy station-printed one."
	skill_icon = "magnifying-glass"
	activate_message = span_notice("You feel that you can recognize special, minute details on ID cards.")
	deactivate_message = span_notice("Was there something special about certain IDs?")

/obj/item/skillchip/sabrage
	name = "Le S48R4G3 skillchip"
	desc = "A skillchip faintly smelling of alcohol. Best used in conjuction with a sabre or otherwise a sharp blade."
	auto_traits = list(TRAIT_SABRAGE_PRO)
	skill_name = "Sabrage Proficiency"
	skill_description = "Grants the user knowledge of the intricate structure of a champagne bottle's structural weakness at the neck, \
	improving their proficiency at being a show-off at officer parties."
	skill_icon = "bottle-droplet"
	activate_message = span_notice("You feel a new understanding of champagne bottles and methods on how to remove their corks.")
	deactivate_message = span_notice("The knowledge of the subtle physics residing inside champagne bottles fades from your mind.")

/obj/item/skillchip/brainwashing
	name = "suspicious skillchip"
	auto_traits = list(TRAIT_BRAINWASHING)
	skill_name = "Brainwashing"
	skill_description = "WARNING: The integrity of this chip is compromised. Please discard this skillchip."
	skill_icon = "soap"
	activate_message = span_notice("...But all at once it comes to you... something involving putting a brain in a washing machine?")
	deactivate_message = span_warning("All knowledge of the secret brainwashing technique is GONE.")

/obj/item/skillchip/brainwashing/examine(mob/user)
	. = ..()
	. += span_warning("It seems to have been corroded over time, putting this in your head may not be the best idea...")

/obj/item/skillchip/brainwashing/on_activate(mob/living/carbon/user, silent = FALSE)
	to_chat(user, span_danger("You get a pounding headache as the chip sends corrupt memories into your head!"))
	user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
	. = ..()

/obj/item/skillchip/chefs_kiss
	name = "K1SS skillchip"
	desc = "This skillchip faintly smells of apple pie, how lovely. Consult a dietician before use."
	auto_traits = list(TRAIT_CHEF_KISS)
	skill_name = "Chef's Kiss"
	skill_description = "Allows you to kiss food you've created to make them with love."
	skill_icon = "cookie"
	activate_message = span_notice("You recall learning from your grandmother how they baked their cookies with love.")
	deactivate_message = span_notice("You forget all memories imparted upon you by your grandmother. Were they even your real grandma?")

/obj/item/skillchip/intj
	name = "Integrated Intuitive Thinking and Judging skillchip"
	auto_traits = list(TRAIT_REMOTE_TASTING)
	skill_name = "Mental Flavour Calculus"
	skill_description = "When examining food, you can experience the flavours just as well as if you were eating it."
	skill_icon = FA_ICON_DRUMSTICK_BITE
	activate_message = span_notice("You think of your favourite food and realise that you can rotate its flavour in your mind.")
	deactivate_message = span_notice("You feel your food-based mind palace crumbling...")

/obj/item/skillchip/drunken_brawler
	name = "F0RC3 4DD1CT10N skillchip"
	desc = "A skillchip reeking of alcohol, said to improve one's fighting prowess while inebriated, as if that will save you from liver cirrhosis."
	auto_traits = list(TRAIT_DRUNKEN_BRAWLER)
	skill_name = "Drunken Unarmed Proficiency"
	skill_description = "When intoxicated, you gain increased unarmed effectiveness."
	skill_icon = "wine-bottle"
	activate_message = span_notice("You honestly could do with a drink. Never know when someone might try and jump you around here.")
	deactivate_message = span_notice("You suddenly feel a lot safer going around the station sober... ")

/obj/item/skillchip/master_angler
	name = "Mast-Angl-Er skillchip"
	desc = "A skillchip brimmed with encyclopedic excerpts and factoids about fishing and fishes."
	auto_traits = list(TRAIT_REVEAL_FISH, TRAIT_EXAMINE_FISHING_SPOT, TRAIT_EXAMINE_FISH, TRAIT_EXAMINE_DEEPER_FISH)
	skill_name = "Fisherman's Discernment"
	skill_description = "Lists fishes when examining a fishing spot, gives a hint of whatever thing's biting the hook and more."
	skill_icon = "fish"
	activate_message = span_notice("You feel the knowledge and passion of several sunbaked, seasoned fishermen burn within you.")
	deactivate_message = span_notice("You no longer feel like casting a fishing rod by the sunny riverside.")

	actions_types = list(/datum/action/cooldown/fishing_tip)

/datum/action/cooldown/fishing_tip
	name = "Dispense Fishing Tip"
	desc = "Recall a pearl of wisdom about fishing."
	button_icon = 'icons/hud/radial_fishing.dmi'
	button_icon_state = "river"
	background_icon_state = "bg_default"
	overlay_icon_state = "bg_default_border"
	cooldown_time = 2.5 SECONDS //enough time to skim through tips.

/datum/action/cooldown/fishing_tip/Activate(atom/target_atom)
	. = ..()
	send_tip_of_the_round(owner, pick(GLOB.fishing_tips), source = "Ancient fishing wisdom")
