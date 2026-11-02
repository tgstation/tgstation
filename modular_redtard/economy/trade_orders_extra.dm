// Ratwood's standing orders of finished goods (code/modules/roguetown/roguestock/standing_order.dm): arms, harness, tunics,
// finery, jewelry, curios, potions, prosthetics, trophies and the two-part orders. Their goods are delivered at the warehouse
// docks (economy/petitions.dm) and priced by the pricing engine. The regions that post them are in
// economy/trade_extra_data.dm (rogue_region_order_templates). Ratwood picks its pools in code; each "goods" entry here is one
// such pool, "or" the pool it takes instead by chance. Not ported: the arcane commission (enchantment scrolls).

/// Orders posted together: the first template of a pair -> its sibling (Ratwood pair_sibling_type).
GLOBAL_LIST_INIT(rogue_order_pairs, list(
	"demand_great_feast_proteins" = "demand_great_feast_carbs",
	"demand_tournament_arms" = "demand_tournament_provisions",
))

/datum/rogue_order_template/demand_equipment_armaments
	title = "ARMS ORDER"
	description = "A garrison at %REGION% requires finished arms, to be left at the warehouse."
	project_description = "%PROJECT% at %REGION% requires finished arms, to be left at the warehouse."
	projects = list(
		"bleakcoast" = list("a privateer captain outfitting", "a corsair's company", "a harbor watch armsmaster"),
		"northfort" = list("a frontier garrison", "a watch sergeant outfitting", "a band of border irregulars"),
		"heartfelt" = list("the count's retinue", "a local mercenary band", "a warband outfitting for the road"),
		"kingsfield" = list("a market armsmaster", "a knight-errant outfitting", "a back-room arms-broker"),
	)
	roll_weight = 3
	mix = list(
		list("goods" = list("STEEL_ARMING_SWORD", "STEEL_SHORTSWORD", "STEEL_FALCHION", "STEEL_MESSER", "STEEL_SABRE", "STEEL_MACE", "STEEL_FLAIL"), "min" = 3, "max" = 5, "prob" = 100),
		list("goods" = list("STEEL_LONGSWORD", "STEEL_WARHAMMER", "STEEL_BATTLEAXE"), "min" = 1, "max" = 2, "prob" = 55),
		list("goods" = list("RECURVE_BOW"), "min" = 3, "max" = 6, "prob" = 55),
	)

/datum/rogue_order_template/demand_equipment_armor_heavy
	title = "HARNESS ORDER"
	description = "A garrison at %REGION% requires finished plate harness, to be left at the warehouse."
	project_description = "%PROJECT% at %REGION% requires finished plate harness, to be left at the warehouse."
	projects = list(
		"bleakcoast" = list("a galley's fighting men", "a privateer captain outfitting", "a harbor watch armsmaster"),
		"northfort" = list("a frontier garrison", "a watch sergeant outfitting", "a relieved company restocking"),
		"heartfelt" = list("the count's retinue", "a local mercenary band", "a knightly house outfitting"),
		"kingsfield" = list("a market armsmaster", "a knightly house", "a tournament-bound knight"),
	)
	roll_weight = 3
	mix = list(
		list("goods" = list("STEEL_CHAINMAIL", "STEEL_HAUBERK", "BRIGANDINE", "BRIGANDINE_HEAVY"), "or" = list("STEEL_COATPLATES", "STEEL_HALFPLATE", "STEEL_FULLPLATE"), "or_prob" = 40, "min" = 1, "max" = 2, "prob" = 100),
		list("goods" = list("STEEL_HELM_KNIGHT", "STEEL_HELM_BASCINET", "STEEL_HELM_KETTLE"), "min" = 1, "max" = 2, "prob" = 65),
		list("goods" = list("STEEL_MASK", "CHAIN_GLOVES", "PLATE_GAUNTLETS", "STEEL_PLATE_LEGS"), "min" = 1, "max" = 3, "prob" = 50),
	)

/datum/rogue_order_template/demand_equipment_armor_light
	title = "COMPANY TUNICS"
	description = "A company at %REGION% requires sewn and boiled-leather kit, to be left at the warehouse."
	project_description = "%PROJECT% at %REGION% requires sewn and boiled-leather kit, to be left at the warehouse."
	projects = list(
		"bleakcoast" = list("the harbor watch", "a coastal levy mustering", "a corsair's company outfitting"),
		"northfort" = list("a watch sergeant outfitting", "a band of border irregulars", "a frontier reservist call-up"),
		"heartfelt" = list("a roving warden party", "the count's footsergeants", "a local adventuring fellowship"),
		"kingsfield" = list("a country muster", "a market company", "a yeoman captain outfitting"),
	)
	roll_weight = 3
	mix = list(
		list("goods" = list("PADDED_GAMBESON", "HEAVY_LEATHER_COAT"), "min" = 2, "max" = 3, "prob" = 100),
		list("goods" = list("PADDED_GAMBESON", "HEAVY_LEATHER_COAT"), "min" = 1, "max" = 2, "prob" = 55),
		list("goods" = list("HARDENED_LEATHER_HELMET"), "min" = 1, "max" = 2, "prob" = 65),
		list("goods" = list("HARDENED_LEATHER_GORGET"), "min" = 1, "max" = 2, "prob" = 50),
		list("goods" = list("HEAVY_LEATHER_GLOVES"), "min" = 1, "max" = 3, "prob" = 45),
		list("goods" = list("CURED_LEATHER"), "min" = 4, "max" = 8, "prob" = 50),
		list("goods" = list("CLOTH"), "min" = 4, "max" = 8, "prob" = 40),
	)

/datum/rogue_order_template/demand_frontier_gear
	title = "FRONTIER GARRISON KIT"
	description = "A frontier muster at %REGION% requires light kit for the watch."
	project_description = "%PROJECT% at %REGION% requires light kit fit for irregular service."
	projects = list(
		"northfort" = list("a watch sergeant outfitting", "a band of border irregulars", "a frontier reservist call-up"),
		"bleakcoast" = list("the harbor watch", "a coastal patrol mustering", "a privateer's crew outfitting"),
		"heartfelt" = list("a roving warden party", "a temple's guard", "a local adventuring fellowship"),
		"kingsfield" = list("a country sheriff's posse", "a local muster", "a yeoman captain outfitting"),
	)
	roll_weight = 3
	mix = list(
		list("goods" = list("PADDED_GAMBESON", "HEAVY_LEATHER_COAT"), "min" = 2, "max" = 4, "prob" = 100),
		list("goods" = list("HARDENED_LEATHER_HELMET"), "min" = 2, "max" = 4, "prob" = 70),
		list("goods" = list("HEAVY_LEATHER_GLOVES"), "min" = 2, "max" = 4, "prob" = 55),
		list("goods" = list("RECURVE_BOW"), "min" = 3, "max" = 6, "prob" = 45),
	)

/datum/rogue_order_template/demand_court_finery
	title = "COURT FINERY ORDER"
	description = "A noble household at %REGION% commissions finished tailoring."
	project_description = "%PROJECT% at %REGION% commissions finished tailoring for the season."
	projects = list(
		"kingsfield" = list("a noble household's wardrobe", "a court tailor's commission", "a market tailor"),
		"heartfelt" = list("the count's wardrobe", "a noble investiture", "a wedding-bound house"),
		"rockhill" = list("a country estate's spring wardrobe", "a noble's name-day finery", "a sun-shy aristocrat's seasonal fitting"),
	)
	roll_weight = 2
	mix = list(
		list("goods" = list("NOBLECOAT", "SILK_TUNIC", "SEASONAL_GOWN", "MAID_DRESS", "NOBLE_DRESS", "VELVET_DRESS", "ORNATE_SILK_DRESS", "SILKY_DRESS", "SPRING_GOWN", "FALL_GOWN", "WINTER_GOWN"), "min" = 2, "max" = 4, "prob" = 100),
		list("goods" = list("NOBLECOAT", "SILK_TUNIC", "SEASONAL_GOWN", "MAID_DRESS", "NOBLE_DRESS", "VELVET_DRESS", "ORNATE_SILK_DRESS", "SILKY_DRESS", "SPRING_GOWN", "FALL_GOWN", "WINTER_GOWN"), "min" = 1, "max" = 3, "prob" = 50),
		list("goods" = list("LORDLY_CLOAK", "LADY_SHORTCLOAK", "FUR_OVERCOAT", "FANCY_HAT", "NOBLE_CHAPERON"), "min" = 1, "max" = 2, "prob" = 45),
		list("goods" = list("ROYAL_DRESS", "PRISTINE_DRESS", "GILDED_DRESS_SHIRT"), "min" = 1, "max" = 1, "prob" = 20),
	)

/datum/rogue_order_template/demand_jewelry
	title = "JEWELERS' COMMISSION"
	description = "A jeweler at %REGION% is buying finished jewelry - rings, amulets, bracelets, and circlets."
	project_description = "%PROJECT% at %REGION% requires finished jewelry - rings, amulets, bracelets, and circlets - for their stock."
	projects = list(
		"kingsfield" = list("a court jeweler", "a master goldsmith", "a noble household's wardrobe"),
		"heartfelt" = list("the count's jeweler", "a temple reliquary's commission", "a wedding-bound house"),
		"rockhill" = list("a country estate's jeweler", "a name-day finery commission", "a sun-shy aristocrat's heirloom resetting"),
	)
	roll_weight = 3
	mix = list(
		list("goods" = list("GOLD_RING", "EMERALD_RING", "AMBER_RING", "JADE_RING", "SHELL_RING", "ROSE_RING", "ONYXA_RING", "TURQ_RING", "CORAL_RING", "OPAL_RING"), "min" = 2, "max" = 4, "prob" = 100),
		list("goods" = list("AMBER_AMULET", "JADE_AMULET", "SHELL_AMULET", "ROSE_AMULET", "ONYXA_AMULET", "TURQ_AMULET", "CORAL_AMULET", "OPAL_AMULET"), "min" = 1, "max" = 3, "prob" = 60),
		list("goods" = list("AMBER_BRACELETS", "JADE_BRACELETS", "SHELL_BRACELETS", "ROSE_BRACELETS", "ONYXA_BRACELETS", "TURQ_BRACELETS", "CORAL_BRACELETS", "OPAL_BRACELETS"), "min" = 1, "max" = 3, "prob" = 45),
		list("goods" = list("AMBER_CIRCLET", "JADE_CIRCLET", "SHELL_CIRCLET", "ROSE_CIRCLET", "ONYXA_CIRCLET", "TURQ_CIRCLET", "CORAL_CIRCLET", "OPAL_CIRCLET"), "min" = 1, "max" = 1, "prob" = 30),
		list("goods" = list("DIAMOND_RING"), "min" = 1, "max" = 1, "prob" = 15),
	)

/datum/rogue_order_template/demand_curio_collection
	title = "COLLECTOR'S COMMISSION"
	description = "A collector at %REGION% commissions carved gemstone curios - any stone will serve."
	project_description = "%PROJECT% at %REGION% commissions carved gemstone curios - any stone will serve."
	projects = list(
		"kingsfield" = list("a court curio collector", "a guildhall's display commission", "a merchant prince's parlor"),
		"rockhill" = list("a grandee's trophy room", "a country estate's parlor", "an oddly pale-skinned aristocrat's gallery"),
		"heartfelt" = list("the count's manor hall", "a temple reliquary's commission", "a wedding-bound house"),
		"rosawood" = list("a woodland shrine's offering", "a reclusive collector's agent"),
	)
	roll_weight = 2
	mix = list(
		list("goods" = list("CARVED_CAMEO", "CARVED_FIGURINE", "CARVED_VASE"), "min" = 2, "max" = 4, "prob" = 100),
		list("goods" = list("CARVED_CAMEO", "CARVED_FIGURINE", "CARVED_VASE"), "min" = 1, "max" = 3, "prob" = 50),
		list("goods" = list("CARVED_FANCY_VASE", "CARVED_BUST", "CARVED_STATUE"), "min" = 1, "max" = 1, "prob" = 40),
	)

/datum/rogue_order_template/demand_birthday_gift
	title = "BIRTHDAY TRIBUTE"
	description = "A noble of %REGION% keeps a name-day. Their household commissions a fitting tribute."
	roll_weight = 1
	mix = list(
		list("goods" = list("SILK"), "min" = 3, "max" = 6, "prob" = 100),
		list("goods" = list("JACKSBERRY"), "min" = 8, "max" = 14, "prob" = 100),
		list("goods" = list("LEMON", "LIME", "TANGERINE", "PLUM"), "min" = 3, "max" = 6, "prob" = 70),
		list("goods" = list("AMBER_RING", "GOLD_RING", "JADE_RING", "OPAL_RING", "AMBER_AMULET", "JADE_AMULET", "TURQ_AMULET", "ROSE_BRACELETS", "SHELL_BRACELETS"), "min" = 1, "max" = 1, "prob" = 70),
		list("goods" = list("NOBLECOAT", "SILK_TUNIC", "SEASONAL_GOWN"), "min" = 1, "max" = 1, "prob" = 60),
	)

/datum/rogue_order_template/demand_alchemical
	title = "APOTHECARY ORDER"
	description = "An apothecary at %REGION% will pay handsomely for finished potions, left at the warehouse."
	project_description = "%PROJECT% at %REGION% requires finished potions, to be left at the warehouse."
	projects = list(
		"heartfelt" = list("a chapel infirmary", "a hospitaller buying for the road", "a garrison surgeon"),
		"blackholt" = list("a wizards' coven", "a hermit reagent-buyer", "an oddly red-eyed aristocrat"),
		"bleakcoast" = list("a galley's surgeon", "a privateer's crew laying in stores", "a coastal garrison's apothecary"),
		"northfort" = list("a frontier surgeon", "a watch sergeant restocking", "a band of border irregulars"),
		"kingsfield" = list("a market apothecary", "a village healer", "a travelling herbalist"),
	)
	roll_weight = 3
	mix = list(
		list("goods" = list("HEALTH_POTION", "STAM_POTION", "ANTIDOTE_POTION"), "min" = 4, "max" = 8, "prob" = 100),
		list("goods" = list("STRONG_HEALTH_POTION", "STRONG_MANA_POTION", "STRONG_STAM_POTION", "STRONG_ANTIDOTE_POTION", "MANA_POTION"), "min" = 3, "max" = 6, "prob" = 60),
	)

/datum/rogue_order_template/demand_alchemical_warband
	title = "WARBAND DRAUGHTS"
	description = "An elite party at %REGION% commissions draughts of stat and strong potion."
	project_description = "%PROJECT% at %REGION% commissions draughts of stat and strong potion."
	projects = list(
		"blackholt" = list("a wizards' coven", "a battle-mage's hireling outfit", "a sun-starved aristocrat's hunting party"),
		"heartfelt" = list("the count's chosen retinue", "a temple's champions", "a roving warden party"),
		"kingsfield" = list("a knight-errants' convocation", "a mercenary captain's warband", "a noble's hunting party"),
		"northfort" = list("a frontier strike-band", "a watch sergeant's chosen", "a local adventuring fellowship"),
	)
	roll_weight = 1
	mix = list(
		list("goods" = list("PERCEPTION_POTION", "INTELLIGENCE_POTION", "SPEED_POTION"), "min" = 2, "max" = 3, "prob" = 100),
		list("goods" = list("PERCEPTION_POTION", "INTELLIGENCE_POTION", "SPEED_POTION"), "min" = 2, "max" = 3, "prob" = 55),
		list("goods" = list("STRONG_HEALTH_POTION", "STRONG_MANA_POTION", "STRONG_STAM_POTION", "STRONG_ANTIDOTE_POTION"), "min" = 2, "max" = 3, "prob" = 100),
	)

/datum/rogue_order_template/demand_prosthetic_run
	title = "INFIRMARY'S ORDER"
	description = "An infirmary at %REGION% tends to wounded soldiers and pilgrims."
	project_description = "%PROJECT% at %REGION% tends many wounded - prosthetics and draughts are needed."
	projects = list(
		"heartfelt" = list("a chapel infirmary", "a hospitaller's wounded-house", "a battlefield surgeon's bulk order"),
		"northfort" = list("a frontier surgeon", "a garrison infirmary", "a band of border irregulars come back broken"),
		"bleakcoast" = list("a galley's surgeon", "a harbor wounded-house", "a privateer's crew limping in"),
	)
	roll_weight = 2
	mix = list(
		list("goods" = list("BRONZE_PROSTHETIC", "IRON_PROSTHETIC"), "min" = 2, "max" = 3, "prob" = 100),
		list("goods" = list("HEALTH_POTION"), "min" = 4, "max" = 7, "prob" = 100),
		list("goods" = list("CURED_LEATHER"), "min" = 4, "max" = 8, "prob" = 60),
	)

/datum/rogue_order_template/demand_artificed_panoply
	title = "ARTIFICED PANOPLY"
	description = "A patron at %REGION% commissions a panoply of artificed plate."
	project_description = "%PROJECT% at %REGION% commissions a panoply of artificed plate. Masterwork pays masterwork's price."
	projects = list(
		"kingsfield" = list("a duke's master-of-arms", "a knight-artificer's commission", "a tournament-bound champion"),
		"daftsmarch" = list("a master smith's signature contract", "a foundry-master's masterpiece", "a guild's exhibition piece"),
		"heartfelt" = list("the count's chosen champion", "a knightly investiture", "a roving warden captain"),
	)
	roll_weight = 1
	mix = list(
		list("goods" = list("STEEL_FULLPLATE"), "min" = 1, "max" = 1, "prob" = 100),
		list("goods" = list("VOLTIC_GAUNTLETS"), "min" = 1, "max" = 1, "prob" = 55),
		list("goods" = list("STEEL_INGOT"), "min" = 8, "max" = 14, "prob" = 100),
		list("goods" = list("GOLD_INGOT"), "min" = 2, "max" = 4, "prob" = 50),
	)

/datum/rogue_order_template/demand_tournament_arms
	title = "TOURNAMENT ARMS"
	description = "A great tournament at %REGION% requires arms and armor for the lists. The patrons pay accordingly."
	project_description = "%PROJECT% at %REGION% requires arms and armor for the lists. The patrons pay accordingly."
	projects = list(
		"kingsfield" = list("the Tournament of the Three Hills", "the lists at Cherrybrook", "a knight-errants' convocation"),
		"heartfelt" = list("the March Tourney", "the count's lists at Heartfelt"),
		"rockhill" = list("the Orchard Lists", "a midsummer tourney at the county seat"),
	)
	roll_weight = 2
	mix = list(
		list("goods" = list("STEEL_ARMING_SWORD", "STEEL_LONGSWORD", "STEEL_MACE", "STEEL_SABRE"), "min" = 3, "max" = 5, "prob" = 100),
		list("goods" = list("STEEL_CHAINMAIL", "STEEL_HAUBERK", "BRIGANDINE"), "min" = 2, "max" = 3, "prob" = 100),
		list("goods" = list("RECURVE_BOW"), "min" = 3, "max" = 5, "prob" = 50),
	)

/datum/rogue_order_template/demand_tournament_provisions
	title = "TOURNAMENT PROVISIONS"
	description = "The same tournament at %REGION% calls for draughts, feast-fare, and finery for the champions."
	roll_weight = 2
	mix = list(
		list("goods" = list("HEALTH_POTION"), "min" = 6, "max" = 10, "prob" = 100),
		list("goods" = list("MANA_POTION"), "min" = 3, "max" = 5, "prob" = 100),
		list("goods" = list("GRAIN"), "min" = 20, "max" = 35, "prob" = 100),
		list("goods" = list("MEAT"), "min" = 10, "max" = 18, "prob" = 100),
		list("goods" = list("BUTTER"), "min" = 5, "max" = 10, "prob" = 100),
		list("goods" = list("NOBLECOAT"), "min" = 1, "max" = 2, "prob" = 60),
	)

/datum/rogue_order_template/demand_trophy_heads
	title = "TROPHY COMMISSION"
	description = "A noble house at %REGION% commissions trophies for their gallery - heads of the wild brought to heel."
	project_description = "%PROJECT% at %REGION% commissions trophies for their gallery - heads of the wild brought to heel."
	projects = list(
		"heartfelt" = list("the count's manor hall", "a marcher lord's gallery", "a heralds' lodge"),
		"rockhill" = list("a hunt-master's trophy hall", "the master of hounds at the great lodge", "a grandee's trophy room"),
	)
	roll_weight = 1
	mix = list(
		list("goods" = list("TROPHY_MINOTAUR"), "or" = list("TROPHY_TROLL"), "or_prob" = 50, "min" = 3, "max" = 6, "prob" = 100),
		list("goods" = list("TROPHY_DIREBEAR"), "min" = 1, "max" = 2, "prob" = 30),
	)
