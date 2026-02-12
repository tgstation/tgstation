/*!
 * Tier 1 knowledge: Stealth and general utility
 */

/datum/heretic_knowledge/void_cloak
	name = "Void Cloak"
	desc = "Allows you to transmute a glass shard, a bedsheet, and any outer clothing item (such as armor or a suit jacket) \
		to create a Void Cloak. While the hood is down, the cloak functions as a focus and protects you from space. \
		While the hood is up, the cloak is completely invisible. It also provide decent armor and \
		has pockets which can hold one of your blades, various ritual components (such as organs), and small heretical trinkets."
	gain_text = "The Owl is the keeper of things that are not quite in practice, but in theory are. Many things are."
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/bedsheet = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/void)
	cost = 1
	research_tree_icon_path = 'icons/obj/clothing/suits/armor.dmi'
	research_tree_icon_state = "void_cloak"
	drafting_tier = 1

/datum/heretic_knowledge/medallion
	name = "Ashen Eyes"
	desc = "Allows you to transmute a pair of eyes, a candle, and a glass shard into an Eldritch Medallion. \
		The Eldritch Medallion grants you thermal vision while worn, and also functions as a focus."
	gain_text = "Piercing eyes guided them through the mundane. Neither darkness nor terror could stop them."
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/shard = 1,
		/obj/item/flashlight/flare/candle = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "eye_medalion"
	drafting_tier = 1

/datum/heretic_knowledge/essence // AKA Eldritch Flask
	name = "Priest's Ritual"
	desc = "Allows you to transmute a tank of water and a glass shard into a Flask of Eldritch Essence. \
		Eldritch Essence can be consumed for potent healing, or given to heathens for deadly poisoning."
	gain_text = "This is an old recipe. The Owl whispered it to me. \
		Created by the Priest - the Liquid that both was and is not."
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/item/shard = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/cup/beaker/eldritch)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "eldritch_flask"
	drafting_tier = 1

/datum/heretic_knowledge/phylactery
	name = "Phylactery of Damnation"
	desc = "Allows you to transmute a sheet of glass and a poppy into a Phylactery that can instantly draw blood, even from long distances. \
		Be warned, your target may still feel a prick."
	gain_text = "A tincture twisted into the shape of a bloodsucker vermin. \
		Whether it chose the shape for itself, or this is the humor of the sickened mind that conjured this vile implement into being is something best not pondered."
	required_atoms = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/food/grown/poppy = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/cup/phylactery)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "phylactery_2"
	drafting_tier = 1

/datum/heretic_knowledge/crucible
	name = "Mawed Crucible"
	desc = "Allows you to transmute a portable water tank and a table to create a Mawed Crucible. \
		The Mawed Crucible can brew powerful potions for combat and utility, but must be fed bodyparts and organs between uses."
	gain_text = "This is pure agony. I wasn't able to summon the figure of the Aristocrat, \
		but with the Priest's attention I stumbled upon a different recipe..."
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/structure/table = 1,
	)
	result_atoms = list(/obj/structure/destructible/eldritch_crucible)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "crucible"
	drafting_tier = 1

/datum/heretic_knowledge/eldritch_coin
	name = "Eldritch Coin"
	desc = "Allows you to transmute a sheet of plasma and a diamond to create an Eldritch Coin. \
		The coin will open or close nearby doors when landing on heads and toggle their bolts \
		when landing on tails. If you insert the coin into an airlock, it will be consumed \
		to fry its electronics, opening the airlock permanently unless bolted. "
	gain_text = "The Mansus is a place of all sorts of sins. But greed held a special role."
	required_atoms = list(
		/obj/item/stack/sheet/mineral/diamond = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/coin/eldritch)
	cost = 1
	research_tree_icon_path = 'icons/obj/economy.dmi'
	research_tree_icon_state = "coin_heretic"
	drafting_tier = 1
