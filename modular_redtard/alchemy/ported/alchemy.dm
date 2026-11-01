/datum/alch_cauldron_recipe/antidote
	name = "Antidote"
	smells_like = "wet moss"
	output_reagents = list(/datum/reagent/medicine/antidote = 100)

/datum/alch_cauldron_recipe/aphrodisiac
	name = "Aphrodisiac Wine"
	smells_like = "ardent sweetness"
	output_reagents = list(/datum/reagent/consumable/ethanol/beer/emberwine = 60)

/datum/alch_cauldron_recipe/berrypoison
	name = "Poison (Berry)"
	smells_like = "death"
	skill_required = 3
	output_reagents = list(/datum/reagent/berrypoison = 100)

/datum/alch_cauldron_recipe/big_health_potion
	name = "Elixir of Health (Strong)"
	smells_like = "berry pie"
	skill_required = 4
	output_reagents = list(/datum/reagent/medicine/stronghealth = 50)

/datum/alch_cauldron_recipe/big_mana_potion
	name = "Elixir of Mana (Strong)"
	smells_like = "fear"
	skill_required = 4
	output_reagents = list(/datum/reagent/medicine/strongmana = 100)

/datum/alch_cauldron_recipe/big_stam_poison
	name = "Stamina Poison (Strong)"
	smells_like = "stagnant air"
	skill_required = 4
	output_reagents = list(/datum/reagent/strongstampoison = 100)

/datum/alch_cauldron_recipe/big_stamina_potion
	name = "Elixir of Stamina (Strong)"
	smells_like = "clean winds"
	skill_required = 3
	output_reagents = list(/datum/reagent/medicine/strongstam = 100)

/datum/alch_cauldron_recipe/con_potion
	name = "Potion of Stone Flesh"
	smells_like = "earth"
	skill_required = 4
	output_reagents = list(/datum/reagent/buff/constitution = 30)

/datum/alch_cauldron_recipe/deadite_rot
	name = "Concentrated rot"
	smells_like = "rotten flesh"
	skill_required = 5
	output_reagents = list(/datum/reagent/deaditerot = 30)

/datum/alch_cauldron_recipe/doompoison
	name = "Poison (Doom)"
	smells_like = "doom"
	skill_required = 4
	output_reagents = list(/datum/reagent/strongpoison = 100)

/datum/alch_cauldron_recipe/end_potion
	name = "Potion of Enduring Fortitude"
	smells_like = "mountain air"
	skill_required = 4
	output_reagents = list(/datum/reagent/buff/endurance = 30)

/datum/alch_cauldron_recipe/fire_potion
	name = "Potion of Fire Warding"
	smells_like = "authority"
	skill_required = 5
	output_reagents = list(/datum/reagent/fire_resist = 30)

/datum/alch_cauldron_recipe/health_potion
	name = "Elixir of Health"
	smells_like = "sweet berries"
	output_reagents = list(/datum/reagent/medicine/healthpot = 100)

/datum/alch_cauldron_recipe/int_potion
	name = "Potion of Keen Mind"
	smells_like = "water"
	skill_required = 4
	output_reagents = list(/datum/reagent/buff/intelligence = 30)

/datum/alch_cauldron_recipe/lck_potion
	name = "Potion of Seven Clovers"
	smells_like = "calming"
	skill_required = 4
	output_reagents = list(/datum/reagent/buff/fortune = 30)

/datum/alch_cauldron_recipe/mana_potion
	name = "Elixir of Mana"
	smells_like = "power"
	output_reagents = list(/datum/reagent/medicine/manapot = 100)

/datum/alch_cauldron_recipe/per_potion
	name = "Potion of Keen Eye"
	smells_like = "fire"
	skill_required = 4
	output_reagents = list(/datum/reagent/buff/perception = 30)

/datum/alch_cauldron_recipe/spd_potion
	name = "Potion of Fleet Foot"
	smells_like = "clean air"
	skill_required = 4
	output_reagents = list(/datum/reagent/buff/speed = 30)

/datum/alch_cauldron_recipe/stam_poison
	name = "Stamina Poison"
	smells_like = "a slow breeze"
	skill_required = 3
	output_reagents = list(/datum/reagent/stampoison = 100)

/datum/alch_cauldron_recipe/stamina_potion
	name = "Elixir of Stamina"
	smells_like = "fresh air"
	output_reagents = list(/datum/reagent/medicine/stampot = 100)

/datum/alch_cauldron_recipe/str_potion
	name = "Potion of Mountain Muscles"
	smells_like = "petrichor"
	skill_required = 4
	output_reagents = list(/datum/reagent/buff/strength = 30)

/datum/alch_cauldron_recipe/strong_antidote
	name = "Antidote (Strong)"
	smells_like = "purity"
	output_reagents = list(/datum/reagent/medicine/strong_antidote = 100)

/datum/alch_cauldron_recipe/temp_potion
	name = "Potion of Equilibrium"
	smells_like = "spring time"
	skill_required = 4
	output_reagents = list(/datum/reagent/buff/temperature_normalize = 30)

/datum/alch_grind_recipe/artemisia_seed
	name = "Herb Seed (Artemisia)"
	valid_input = /obj/item/alch/artemisia
	valid_outputs = list(/obj/item/herbseed/artemisia = 1)

/datum/alch_grind_recipe/atropa_seed
	name = "Herb Seed (Atropa)"
	valid_input = /obj/item/alch/atropa
	valid_outputs = list(/obj/item/herbseed/atropa = 1)

/datum/alch_grind_recipe/benedictus_seed
	name = "Herb Seed (Benedictus)"
	valid_input = /obj/item/alch/benedictus
	valid_outputs = list(/obj/item/herbseed/benedictus = 1)

/datum/alch_grind_recipe/berrypowder
	name = "Berry Powder"
	valid_input = /obj/item/reagent_containers/food/snacks/grown/berries/rogue
	valid_outputs = list(/obj/item/alch/berrypowder = 1)
	bonus_chance_outputs = list(/obj/item/alch/waterdust = 25)

/datum/alch_grind_recipe/blessed_silver_bar
	name = "Blessed Silver Bar"
	valid_input = /obj/item/ingot/silverblessed
	valid_outputs = list(/obj/item/alch/silverdust = 1)
	bonus_chance_outputs = list(/obj/item/alch/silverdust = 33, /obj/item/alch/firedust = 25)

/datum/alch_grind_recipe/bone
	name = "Bone"
	valid_input = /obj/item/alch/bone
	valid_outputs = list(/obj/item/alch/bonemeal = 2)
	bonus_chance_outputs = list(/obj/item/alch/bonemeal = 50)

/datum/alch_grind_recipe/calendula_seed
	name = "Herb Seed (Calendula)"
	valid_input = /obj/item/alch/calendula
	valid_outputs = list(/obj/item/herbseed/calendula = 1)

/datum/alch_grind_recipe/coal_ore
	name = "Coal Ore"
	valid_input = /obj/item/rogueore/coal
	valid_outputs = list(/obj/item/alch/coaldust = 1)
	bonus_chance_outputs = list(/obj/item/alch/coaldust = 33, /obj/item/alch/firedust = 25)

/datum/alch_grind_recipe/crow
	name = "Crow"
	valid_input = /obj/item/reagent_containers/food/snacks/crow
	valid_outputs = list(/obj/item/alch/airdust = 1)
	bonus_chance_outputs = list(/obj/item/alch/airdust = 33)

/datum/alch_grind_recipe/dry_westleach
	name = "Dried Westleach"
	valid_input = /obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry
	valid_outputs = list(/obj/item/alch/tobaccodust = 1)
	bonus_chance_outputs = list(/obj/item/alch/airdust = 50, /obj/item/alch/tobaccodust = 50)

/datum/alch_grind_recipe/euphrasia_seed
	name = "Herb Seed (Euphrasia)"
	valid_input = /obj/item/alch/euphrasia
	valid_outputs = list(/obj/item/herbseed/euphrasia = 1)

/datum/alch_grind_recipe/fish
	name = "Fish"
	valid_input = /obj/item/reagent_containers/food/snacks/fish
	picky = FALSE
	valid_outputs = list(/obj/item/alch/waterdust = 1)
	bonus_chance_outputs = list(/obj/item/alch/bonemeal = 50)

/datum/alch_grind_recipe/fyritius
	name = "Fyritius"
	valid_input = /obj/item/reagent_containers/food/snacks/grown/rogue/fyritius
	valid_outputs = list(/obj/item/alch/firedust = 1)
	bonus_chance_outputs = list(/obj/item/alch/solardust = 50)

/datum/alch_grind_recipe/gold_bar
	name = "Gold Bar"
	valid_input = /obj/item/ingot/gold
	valid_outputs = list(/obj/item/alch/golddust = 1)
	bonus_chance_outputs = list(/obj/item/alch/golddust = 33, /obj/item/alch/firedust = 25)

/datum/alch_grind_recipe/gold_ore
	name = "Gold Ore"
	valid_input = /obj/item/rogueore/gold
	valid_outputs = list(/obj/item/alch/golddust = 1)
	bonus_chance_outputs = list(/obj/item/alch/golddust = 33)

/datum/alch_grind_recipe/horn
	valid_input = /obj/item/alch/horn
	valid_outputs = list(/obj/item/alch/earthdust = 1, /obj/item/alch/bonemeal = 2)
	bonus_chance_outputs = list(/obj/item/alch/earthdust = 66)

/datum/alch_grind_recipe/hypericum_seed
	name = "Herb Seed (Hypericum)"
	valid_input = /obj/item/alch/hypericum
	valid_outputs = list(/obj/item/herbseed/hypericum = 1)

/datum/alch_grind_recipe/infernaldust
	name = "Infernal Dust"
	valid_input = /obj/item/magic/infernal/fang
	valid_outputs = list(/obj/item/alch/infernaldust = 1)
	bonus_chance_outputs = list(/obj/item/alch/firedust = 25)

/datum/alch_grind_recipe/iron_bar
	name = "Iron Bar"
	valid_input = /obj/item/ingot/iron
	valid_outputs = list(/obj/item/alch/irondust = 1)
	bonus_chance_outputs = list(/obj/item/alch/irondust = 33, /obj/item/alch/runedust = 25, /obj/item/alch/firedust = 25)

/datum/alch_grind_recipe/iron_ore
	name = "Iron Ore"
	valid_input = /obj/item/rogueore/iron
	valid_outputs = list(/obj/item/alch/irondust = 1)
	bonus_chance_outputs = list(/obj/item/alch/irondust = 33, /obj/item/alch/runedust = 25)

/datum/alch_grind_recipe/manabloompowder
	name = "Manabloom Powder"
	valid_input = /obj/item/reagent_containers/food/snacks/grown/manabloom
	valid_outputs = list(/obj/item/alch/manabloompowder = 1)
	bonus_chance_outputs = list(/obj/item/alch/manabloompowder = 25)

/datum/alch_grind_recipe/matricaria_seed
	name = "Herb Seed (Matricaria)"
	valid_input = /obj/item/alch/matricaria
	valid_outputs = list(/obj/item/herbseed/matricaria = 1)

/datum/alch_grind_recipe/mentha_seed
	name = "Herb Seed (Mentha)"
	valid_input = /obj/item/alch/mentha
	valid_outputs = list(/obj/item/herbseed/mentha = 1)

/datum/alch_grind_recipe/mineraldustblue
	name = "Mineral Dust (Blortz)"
	valid_input = /obj/item/roguegem/blue
	valid_outputs = list(/obj/item/alch/mineraldust = 1, /obj/item/alch/waterdust = 2, /obj/item/alch/golddust = 4)
	bonus_chance_outputs = list(/obj/item/alch/waterdust = 66)

/datum/alch_grind_recipe/mineraldustdiamond
	name = "Mineral Dust (Diamond)"
	valid_input = /obj/item/roguegem/diamond
	valid_outputs = list(/obj/item/alch/mineraldust = 1, /obj/item/alch/golddust = 6)
	bonus_chance_outputs = list(/obj/item/alch/golddust = 66)

/datum/alch_grind_recipe/mineraldustgreen
	name = "Mineral Dust (Gemerald)"
	valid_input = /obj/item/roguegem/green
	valid_outputs = list(/obj/item/alch/mineraldust = 1, /obj/item/alch/earthdust = 1, /obj/item/alch/golddust = 2)
	bonus_chance_outputs = list(/obj/item/alch/earthdust = 66)

/datum/alch_grind_recipe/mineraldustriddle
	name = "Mineral Dust (Riddle of Steel)"
	valid_input = /obj/item/riddleofsteel
	valid_outputs = list(/obj/item/alch/mineraldust = 2, /obj/item/alch/airdust = 1, /obj/item/alch/irondust = 1, /obj/item/alch/firedust = 1, /obj/item/alch/magicdust = 1, /obj/item/alch/silverdust = 1, /obj/item/alch/coaldust = 1, /obj/item/alch/runedust = 1, /obj/item/alch/waterdust = 1)
	bonus_chance_outputs = list(/obj/item/alch/mineraldust = 25, /obj/item/alch/airdust = 25, /obj/item/alch/irondust = 25, /obj/item/alch/firedust = 25, /obj/item/alch/magicdust = 25, /obj/item/alch/silverdust = 25, /obj/item/alch/coaldust = 25, /obj/item/alch/runedust = 25, /obj/item/alch/waterdust = 25)

/datum/alch_grind_recipe/mineraldustviolet
	name = "Mineral Dust (Saffira)"
	valid_input = /obj/item/roguegem/violet
	valid_outputs = list(/obj/item/alch/mineraldust = 1, /obj/item/alch/magicdust = 1, /obj/item/alch/golddust = 3)
	bonus_chance_outputs = list(/obj/item/alch/magicdust = 66)

/datum/alch_grind_recipe/mineraldustyellow
	name = "Mineral Dust (Toper)"
	valid_input = /obj/item/roguegem/yellow
	valid_outputs = list(/obj/item/alch/mineraldust = 1, /obj/item/alch/golddust = 1)
	bonus_chance_outputs = list(/obj/item/alch/golddust = 66)

/datum/alch_grind_recipe/natural_bone
	name = "Natural Bone"
	valid_input = /obj/item/natural/bone
	valid_outputs = list(/obj/item/alch/bonemeal = 1)
	bonus_chance_outputs = list(/obj/item/alch/bonemeal = 2)

/datum/alch_grind_recipe/ozium
	name = "Ozium"
	valid_input = /obj/item/reagent_containers/powder/ozium
	valid_outputs = list(/obj/item/alch/ozium = 1)
	bonus_chance_outputs = list(/obj/item/alch/airdust = 25, /obj/item/alch/ozium = 25)

/datum/alch_grind_recipe/paris_seed
	name = "Herb Seed (Paris)"
	valid_input = /obj/item/alch/paris
	valid_outputs = list(/obj/item/herbseed/paris = 1)

/datum/alch_grind_recipe/poppy
	name = "Poppy"
	valid_input = /obj/item/reagent_containers/food/snacks/grown/rogue/poppy
	valid_outputs = list(/obj/item/reagent_containers/powder/ozium = 1)
	bonus_chance_outputs = list(/obj/item/alch/airdust = 33, /obj/item/alch/earthdust = 33)

/datum/alch_grind_recipe/puresalt
	name = "Pure Salt"
	valid_input = /obj/item/reagent_containers/powder/salt
	valid_outputs = list(/obj/item/alch/puresalt = 1)

/datum/alch_grind_recipe/rosa_seed
	name = "Herb Seed (Rosa)"
	valid_input = /obj/item/alch/rosa
	valid_outputs = list(/obj/item/herbseed/rosa = 1)

/datum/alch_grind_recipe/salvia_seed
	name = "Herb Seed (Salvia)"
	valid_input = /obj/item/alch/salvia
	valid_outputs = list(/obj/item/herbseed/salvia = 1)

/datum/alch_grind_recipe/seeds
	name = "Seeds"
	valid_input = /obj/item/seeds
	picky = FALSE
	valid_outputs = list(/obj/item/alch/seeddust = 1)
	bonus_chance_outputs = list(/obj/item/alch/airdust = 25, /obj/item/alch/earthdust = 25)

/datum/alch_grind_recipe/seedsherb
	name = "Herb Seeds"
	valid_input = /obj/item/herbseed
	picky = FALSE
	valid_outputs = list(/obj/item/alch/seeddust = 1)
	bonus_chance_outputs = list(/obj/item/alch/airdust = 25, /obj/item/alch/earthdust = 25)

/datum/alch_grind_recipe/silver_bar
	name = "Silver Bar"
	valid_input = /obj/item/ingot/silver
	valid_outputs = list(/obj/item/alch/silverdust = 1)
	bonus_chance_outputs = list(/obj/item/alch/silverdust = 33, /obj/item/alch/firedust = 25)

/datum/alch_grind_recipe/silver_ore
	name = "Silver Ore"
	valid_input = /obj/item/rogueore/silver
	valid_outputs = list(/obj/item/alch/silverdust = 1)
	bonus_chance_outputs = list(/obj/item/alch/silverdust = 33)

/datum/alch_grind_recipe/sinew
	valid_input = /obj/item/alch/sinew
	valid_outputs = list(/obj/item/alch/viscera = 1)
	bonus_chance_outputs = list(/obj/item/alch/viscera = 75)

/datum/alch_grind_recipe/stone_dust
	name = "Stone"
	valid_input = /obj/item/natural/stone
	valid_outputs = list(/obj/item/alch/stonedust = 1)
	bonus_chance_outputs = list(/obj/item/alch/stonedust = 50)

/datum/alch_grind_recipe/sunflower
	name = "Sunflower"
	valid_input = /obj/item/reagent_containers/food/snacks/grown/sunflower
	valid_outputs = list(/obj/item/alch/solardust = 1)
	bonus_chance_outputs = list(/obj/item/alch/firedust = 25)

/datum/alch_grind_recipe/swampweed
	name = "Swampweed"
	valid_input = /obj/item/reagent_containers/food/snacks/grown/rogue/swampweed
	valid_outputs = list(/obj/item/alch/swampdust = 1)
	bonus_chance_outputs = list(/obj/item/alch/earthdust = 33)

/datum/alch_grind_recipe/swampweed_dried
	name = "Dried Swampweed"
	valid_input = /obj/item/reagent_containers/food/snacks/grown/rogue/swampweeddry
	valid_outputs = list(/obj/item/alch/swampdust = 1)
	bonus_chance_outputs = list(/obj/item/alch/earthdust = 50, /obj/item/alch/swampdust = 50)

/datum/alch_grind_recipe/symphitum_seed
	name = "Herb Seed (Symphitum)"
	valid_input = /obj/item/alch/symphitum
	valid_outputs = list(/obj/item/herbseed/symphitum = 1)

/datum/alch_grind_recipe/taraxacum_seed
	name = "Herb Seed (Taraxacum)"
	valid_input = /obj/item/alch/taraxacum
	valid_outputs = list(/obj/item/herbseed/taraxacum = 1)

/datum/alch_grind_recipe/urtica_seed
	name = "Herb Seed (Urtica)"
	valid_input = /obj/item/alch/urtica
	valid_outputs = list(/obj/item/herbseed/urtica = 1)

/datum/alch_grind_recipe/valeriana_seed
	name = "Herb Seed (Valeriana)"
	valid_input = /obj/item/alch/valeriana
	valid_outputs = list(/obj/item/herbseed/valeriana = 1)

/datum/alch_grind_recipe/westleach
	name = "Westleach"
	valid_input = /obj/item/reagent_containers/food/snacks/grown/rogue/pipeweed
	valid_outputs = list(/obj/item/alch/tobaccodust = 1)
	bonus_chance_outputs = list(/obj/item/alch/airdust = 33)

/obj/item/alch/airdust
	major_pot = /datum/alch_cauldron_recipe/spd_potion
	med_pot = /datum/alch_cauldron_recipe/stamina_potion
	minor_pot = /datum/alch_cauldron_recipe/int_potion

/obj/item/alch/artemisia
	major_pot = /datum/alch_cauldron_recipe/lck_potion
	med_pot = /datum/alch_cauldron_recipe/spd_potion
	minor_pot = /datum/alch_cauldron_recipe/aphrodisiac

/obj/item/alch/atropa
	major_pot = /datum/alch_cauldron_recipe/doompoison
	med_pot = /datum/alch_cauldron_recipe/berrypoison
	minor_pot = /datum/alch_cauldron_recipe/deadite_rot

/obj/item/alch/benedictus
	major_pot = /datum/alch_cauldron_recipe/big_stamina_potion
	med_pot = /datum/alch_cauldron_recipe/stamina_potion
	minor_pot = /datum/alch_cauldron_recipe/int_potion

/obj/item/alch/berrypowder
	major_pot = /datum/alch_cauldron_recipe/berrypoison
	med_pot = /datum/alch_cauldron_recipe/mana_potion
	minor_pot = /datum/alch_cauldron_recipe/big_mana_potion

/obj/item/alch/bone
	major_pot = /datum/alch_cauldron_recipe/strong_antidote
	med_pot = /datum/alch_cauldron_recipe/health_potion
	minor_pot = /datum/alch_cauldron_recipe/con_potion

/obj/item/alch/bonemeal
	major_pot = /datum/alch_cauldron_recipe/mana_potion
	med_pot = /datum/alch_cauldron_recipe/per_potion
	minor_pot = /datum/alch_cauldron_recipe/antidote

/obj/item/alch/calendula
	major_pot = /datum/alch_cauldron_recipe/big_health_potion
	med_pot = /datum/alch_cauldron_recipe/end_potion
	minor_pot = /datum/alch_cauldron_recipe/health_potion

/obj/item/alch/coaldust
	major_pot = /datum/alch_cauldron_recipe/antidote
	med_pot = /datum/alch_cauldron_recipe/deadite_rot
	minor_pot = /datum/alch_cauldron_recipe/str_potion

/obj/item/alch/earthdust
	major_pot = /datum/alch_cauldron_recipe/con_potion
	med_pot = /datum/alch_cauldron_recipe/end_potion
	minor_pot = /datum/alch_cauldron_recipe/str_potion

/obj/item/alch/euphrasia
	major_pot = /datum/alch_cauldron_recipe/spd_potion
	med_pot = /datum/alch_cauldron_recipe/aphrodisiac
	minor_pot = /datum/alch_cauldron_recipe/int_potion

/obj/item/alch/feaudust
	major_pot = /datum/alch_cauldron_recipe/spd_potion
	med_pot = /datum/alch_cauldron_recipe/big_mana_potion
	minor_pot = /datum/alch_cauldron_recipe/strong_antidote

/obj/item/alch/firedust
	major_pot = /datum/alch_cauldron_recipe/str_potion
	med_pot = /datum/alch_cauldron_recipe/con_potion
	minor_pot = /datum/alch_cauldron_recipe/fire_potion

/obj/item/alch/golddust
	major_pot = /datum/alch_cauldron_recipe/big_mana_potion
	med_pot = /datum/alch_cauldron_recipe/con_potion
	minor_pot = /datum/alch_cauldron_recipe/per_potion

/obj/item/alch/horn
	major_pot = /datum/alch_cauldron_recipe/str_potion
	med_pot = /datum/alch_cauldron_recipe/con_potion
	minor_pot = /datum/alch_cauldron_recipe/end_potion

/obj/item/alch/hypericum
	major_pot = /datum/alch_cauldron_recipe/stamina_potion
	med_pot = /datum/alch_cauldron_recipe/big_mana_potion
	minor_pot = /datum/alch_cauldron_recipe/antidote

/obj/item/alch/infernaldust
	major_pot = /datum/alch_cauldron_recipe/fire_potion
	med_pot = /datum/alch_cauldron_recipe/big_stam_poison
	minor_pot = /datum/alch_cauldron_recipe/int_potion

/obj/item/alch/irondust
	major_pot = /datum/alch_cauldron_recipe/end_potion
	med_pot = /datum/alch_cauldron_recipe/con_potion
	minor_pot = /datum/alch_cauldron_recipe/str_potion

/obj/item/alch/magicdust
	major_pot = /datum/alch_cauldron_recipe/big_mana_potion
	med_pot = /datum/alch_cauldron_recipe/end_potion
	minor_pot = /datum/alch_cauldron_recipe/con_potion

/obj/item/alch/manabloompowder
	major_pot = /datum/alch_cauldron_recipe/mana_potion
	med_pot = /datum/alch_cauldron_recipe/int_potion
	minor_pot = /datum/alch_cauldron_recipe/big_mana_potion

/obj/item/alch/matricaria
	major_pot = /datum/alch_cauldron_recipe/berrypoison
	med_pot = /datum/alch_cauldron_recipe/per_potion
	minor_pot = /datum/alch_cauldron_recipe/doompoison

/obj/item/alch/mentha
	major_pot = /datum/alch_cauldron_recipe/per_potion
	med_pot = /datum/alch_cauldron_recipe/int_potion
	minor_pot = /datum/alch_cauldron_recipe/stamina_potion

/obj/item/alch/mineraldust
	major_pot = /datum/alch_cauldron_recipe/doompoison
	med_pot = /datum/alch_cauldron_recipe/big_mana_potion
	minor_pot = /datum/alch_cauldron_recipe/big_stam_poison

/obj/item/alch/ozium
	major_pot = /datum/alch_cauldron_recipe/big_stamina_potion
	med_pot = /datum/alch_cauldron_recipe/lck_potion
	minor_pot = /datum/alch_cauldron_recipe/int_potion

/obj/item/alch/paris
	major_pot = /datum/alch_cauldron_recipe/big_stam_poison
	med_pot = /datum/alch_cauldron_recipe/berrypoison
	minor_pot = /datum/alch_cauldron_recipe/stam_poison

/obj/item/alch/puresalt
	major_pot = /datum/alch_cauldron_recipe/antidote
	med_pot = /datum/alch_cauldron_recipe/strong_antidote
	minor_pot = /datum/alch_cauldron_recipe/big_mana_potion

/obj/item/alch/rosa
	major_pot = /datum/alch_cauldron_recipe/temp_potion
	med_pot = /datum/alch_cauldron_recipe/aphrodisiac
	minor_pot = /datum/alch_cauldron_recipe/stamina_potion

/obj/item/alch/runedust
	major_pot = /datum/alch_cauldron_recipe/int_potion
	med_pot = /datum/alch_cauldron_recipe/big_mana_potion
	minor_pot = /datum/alch_cauldron_recipe/per_potion

/obj/item/alch/salvia
	major_pot = /datum/alch_cauldron_recipe/con_potion
	med_pot = /datum/alch_cauldron_recipe/str_potion
	minor_pot = /datum/alch_cauldron_recipe/end_potion

/obj/item/alch/seeddust
	major_pot = /datum/alch_cauldron_recipe/big_stamina_potion
	med_pot = /datum/alch_cauldron_recipe/stamina_potion
	minor_pot = /datum/alch_cauldron_recipe/strong_antidote

/obj/item/alch/silverdust
	major_pot = /datum/alch_cauldron_recipe/strong_antidote
	med_pot = /datum/alch_cauldron_recipe/antidote
	minor_pot = /datum/alch_cauldron_recipe/big_health_potion

/obj/item/alch/sinew
	major_pot = /datum/alch_cauldron_recipe/aphrodisiac
	med_pot = /datum/alch_cauldron_recipe/end_potion
	minor_pot = /datum/alch_cauldron_recipe/health_potion

/obj/item/alch/solardust
	major_pot = /datum/alch_cauldron_recipe/fire_potion
	med_pot = /datum/alch_cauldron_recipe/int_potion
	minor_pot = /datum/alch_cauldron_recipe/per_potion

/obj/item/alch/stonedust
	major_pot = /datum/alch_cauldron_recipe/antidote
	med_pot = /datum/alch_cauldron_recipe/end_potion
	minor_pot = /datum/alch_cauldron_recipe/stam_poison

/obj/item/alch/swampdust
	major_pot = /datum/alch_cauldron_recipe/temp_potion
	med_pot = /datum/alch_cauldron_recipe/aphrodisiac
	minor_pot = /datum/alch_cauldron_recipe/end_potion

/obj/item/alch/symphitum
	major_pot = /datum/alch_cauldron_recipe/health_potion
	med_pot = /datum/alch_cauldron_recipe/stam_poison
	minor_pot = /datum/alch_cauldron_recipe/antidote

/obj/item/alch/taraxacum
	major_pot = /datum/alch_cauldron_recipe/stam_poison
	med_pot = /datum/alch_cauldron_recipe/health_potion
	minor_pot = /datum/alch_cauldron_recipe/antidote

/obj/item/alch/tobaccodust
	major_pot = /datum/alch_cauldron_recipe/per_potion
	med_pot = /datum/alch_cauldron_recipe/stamina_potion
	minor_pot = /datum/alch_cauldron_recipe/spd_potion

/obj/item/alch/urtica
	major_pot = /datum/alch_cauldron_recipe/health_potion
	med_pot = /datum/alch_cauldron_recipe/spd_potion
	minor_pot = /datum/alch_cauldron_recipe/aphrodisiac

/obj/item/alch/valeriana
	major_pot = /datum/alch_cauldron_recipe/health_potion
	med_pot = /datum/alch_cauldron_recipe/spd_potion
	minor_pot = /datum/alch_cauldron_recipe/stam_poison

/obj/item/alch/viscera
	major_pot = /datum/alch_cauldron_recipe/big_health_potion
	med_pot = /datum/alch_cauldron_recipe/deadite_rot
	minor_pot = /datum/alch_cauldron_recipe/health_potion

/obj/item/alch/waterdust
	major_pot = /datum/alch_cauldron_recipe/int_potion
	med_pot = /datum/alch_cauldron_recipe/big_mana_potion
	minor_pot = /datum/alch_cauldron_recipe/per_potion
