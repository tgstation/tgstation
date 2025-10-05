
//legion bodies are here, and other mining related bodies

//Tendril-spawned Legion remains, the charred skeletons of those whose bodies sank into laval or fell into chasms.
/obj/effect/mob_spawn/corpse/human/charredskeleton
	name = "charred skeletal remains"
	mob_name = "ashen skeleton"
	burn_damage = 1000
	mob_species = /datum/species/skeleton

/obj/effect/mob_spawn/corpse/human/charredskeleton/special(mob/living/carbon/human/spawned_human)
	. = ..()
	spawned_human.color = "#454545"
	spawned_human.gender = NEUTER
	//don't need to set the human's body type (neuter)

/obj/effect/mob_spawn/corpse/human/charredskeleton/dragoon
	outfit = /datum/outfit/dragoon_gear

/datum/outfit/dragoon_gear
	name = "Dragoon"

	suit = /obj/item/clothing/suit/armor/dragoon
	head = /obj/item/clothing/head/helmet/dragoon
	suit_store = /obj/item/spear/skybulge

//Legion infested mobs

/// Mob spawner used by Legion to spawn costumed bodies
/obj/effect/mob_spawn/corpse/human/legioninfested
	brute_damage = 1000

/obj/effect/mob_spawn/corpse/human/legioninfested/Initialize(mapload)
	outfit = select_outfit()
	return ..()

/obj/effect/mob_spawn/corpse/human/legioninfested/special(mob/living/carbon/human/spawned_human)
	. = ..()
	var/obj/item/organ/legion_tumour/cancer = new()
	cancer.Insert(spawned_human, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/// Returns the outfit worn by our corpse
/obj/effect/mob_spawn/corpse/human/legioninfested/proc/select_outfit()
	var/corpse_theme = pick_weight(list(
		"Miner" = 64,
		"Clown" = 5,
		"Ashwalker" = 15,
		"Golem" = 10,
		pick(list(
			"Cultist",
			"Dame",
			"Operative",
			"Shadow",
		)) = 4,
	))

	switch(corpse_theme)
		if("Miner")
			return /datum/outfit/consumed_miner
		if("Ashwalker")
			return /datum/outfit/consumed_ashwalker
		if("Golem")
			return /datum/outfit/consumed_golem
		if("Clown")
			return /datum/outfit/consumed_clown
		if("Cultist")
			return /datum/outfit/consumed_cultist
		if("Dame")
			return /datum/outfit/consumed_dame
		if("Operative")
			return /datum/outfit/syndicatecommandocorpse/lessenedgear
		if("Shadow")
			return /datum/outfit/consumed_shadowperson

/// Corpse spawner used by dwarf legions to make small corpses
/obj/effect/mob_spawn/corpse/human/legioninfested/dwarf

/obj/effect/mob_spawn/corpse/human/legioninfested/dwarf/special(mob/living/carbon/human/spawned_human)
	. = ..()
	spawned_human.dna.add_mutation(/datum/mutation/dwarfism, MUTATION_SOURCE_MUTATOR)

/// Corpse spawner used by snow legions with alternate costumes
/obj/effect/mob_spawn/corpse/human/legioninfested/snow

/obj/effect/mob_spawn/corpse/human/legioninfested/snow/select_outfit()
	var/corpse_theme = pick_weight(list(
		"Miner" = 64,
		"Clown" = 5,
		"Golem" = 15,
		"Settler" = 10,
		pick(list(
			"Cultist",
			"Heremoth",
			"Operative",
			"Shadow",
		)) = 4,
	))

	switch(corpse_theme)
		if("Miner")
			return /datum/outfit/consumed_miner
		if("Settler")
			return /datum/outfit/consumed_ice_settler
		if("Heremoth")
			return /datum/outfit/consumed_heremoth
		if("Clown")
			return /datum/outfit/consumed_clown
		if("Cultist")
			return /datum/outfit/consumed_cultist
		if("Golem")
			return /datum/outfit/consumed_golem
		if("Operative")
			return /datum/outfit/syndicatecommandocorpse/lessenedgear
		if("Shadow")
			return /datum/outfit/consumed_shadowperson

/// Creates a dead legion-infested skeleton
/obj/effect/mob_spawn/corpse/human/legioninfested/skeleton
	name = "legion-infested skeleton"
	mob_name = "skeleton"
	mob_species = /datum/species/skeleton

/obj/effect/mob_spawn/corpse/human/legioninfested/skeleton/select_outfit()
	return null

/obj/effect/mob_spawn/corpse/human/legioninfested/skeleton/special(mob/living/carbon/human/spawned_human)
	. = ..()
	spawned_human.gender = NEUTER

/// Creates a dead and burned legion-infested skeleton
/obj/effect/mob_spawn/corpse/human/legioninfested/skeleton/charred
	name = "charred legion-infested skeleton"
	mob_name = "charred skeleton"
	brute_damage = 0
	burn_damage = 1000

/obj/effect/mob_spawn/corpse/human/legioninfested/skeleton/charred/special(mob/living/carbon/human/spawned_human)
	. = ..()
	spawned_human.color = "#454545"


/datum/outfit/consumed_miner
	name = "Legion-Consumed Miner"
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/gas/explorer
	shoes = /obj/item/clothing/shoes/workboots/mining

/datum/outfit/consumed_miner/pre_equip(mob/living/carbon/human/miner, visuals_only = FALSE)
	var/regular_uniform = FALSE
	if(visuals_only)
		regular_uniform = TRUE //assume human
	else
		var/new_species_type = pick_weight(list(
			/datum/species/human = 70,
			/datum/species/lizard = 26,
			/datum/species/fly = 2,
			/datum/species/plasmaman = 2,
		))
		miner.set_species(new_species_type)
		if(new_species_type != /datum/species/plasmaman)
			regular_uniform = TRUE
		else
			uniform = /obj/item/clothing/under/plasmaman
			belt = /obj/item/tank/internals/plasmaman/belt
			head = /obj/item/clothing/head/helmet/space/plasmaman
		if(new_species_type == /datum/species/lizard)
			shoes = null //digitigrade says no
	if(regular_uniform)
		uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland
		if(prob(4))
			belt = pick_weight(list(
				/obj/item/storage/belt/mining = 2,
				/obj/item/storage/belt/mining/alt = 2,
			))
		else if(prob(10))
			belt = pick_weight(list(
				/obj/item/pickaxe = 8,
				/obj/item/pickaxe/mini = 4,
				/obj/item/pickaxe/silver = 2,
				/obj/item/pickaxe/diamond = 1,
			))
		else
			belt = /obj/item/tank/internals/emergency_oxygen/engi

	if(prob(20))
		suit = pick_weight(list(
			/obj/item/clothing/suit/hooded/explorer = 18,
			/obj/item/clothing/suit/hooded/cloak/goliath = 2,
		))
	if(prob(30))
		r_pocket = pick_weight(list(
			/obj/item/stack/marker_beacon = 20,
			/obj/item/stack/spacecash/c1000 = 7,
			/obj/item/reagent_containers/hypospray/medipen/survival = 2,
			/obj/item/borg/upgrade/modkit/damage = 1,
		))
	if(prob(10))
		l_pocket = pick_weight(list(
			/obj/item/stack/spacecash/c1000 = 7,
			/obj/item/reagent_containers/hypospray/medipen/survival = 2,
			/obj/item/borg/upgrade/modkit/cooldown = 1,
		))

/datum/outfit/consumed_ashwalker
	name = "Legion-Consumed Ashwalker"
	uniform = /obj/item/clothing/under/costume/gladiator/ash_walker

/datum/outfit/consumed_ashwalker/pre_equip(mob/living/carbon/human/ashwalker, visuals_only = FALSE)
	if(!visuals_only)
		ashwalker.set_species(/datum/species/lizard/ashwalker)
	if(prob(95))
		head = /obj/item/clothing/head/helmet/gladiator
	else
		suit = /obj/item/clothing/suit/armor/bone
		gloves = /obj/item/clothing/gloves/bracer
		head = /obj/item/clothing/head/helmet/skull
	if(prob(5))
		back = pick_weight(list(
			/obj/item/spear/bonespear = 3,
			/obj/item/fireaxe/boneaxe = 2,
	))
	if(prob(10))
		belt = /obj/item/storage/belt/mining/primitive
	if(prob(30))
		l_pocket = /obj/item/knife/combat/bone
	if(prob(30))
		r_pocket = /obj/item/knife/combat/bone

//takes a lot from the clown job, notably NO PDA and different backpack loot + pocket goodies
/datum/outfit/consumed_clown
	name = "Legion-Consumed Clown"
	id_trim = /datum/id_trim/job/clown
	uniform = /obj/item/clothing/under/rank/civilian/clown
	back = /obj/item/storage/backpack/clown
	backpack_contents = list()
	ears = /obj/item/radio/headset/headset_srv
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn

	box = /obj/item/storage/box/survival/hug
	chameleon_extras = /obj/item/stamp/clown
	implants = list(/obj/item/implant/sad_trombone)
	///drops a pie cannon on post_equip. i'm so done with this stupid outfit trying to put shit that doesn't fit in the backpack!
	var/drop_a_pie_cannon = FALSE

/datum/outfit/consumed_clown/pre_equip(mob/living/carbon/human/clown, visuals_only = FALSE)
	if(!visuals_only)
		clown.fully_replace_character_name(clown.name, pick(GLOB.clown_names))
	if(prob(70))
		var/backpack_loot = pick(list(
			/obj/item/food/grown/banana = 1,
			/obj/item/megaphone/clown = 1,
			/obj/item/pneumatic_cannon/pie,
			/obj/item/reagent_containers/cup/soda_cans/canned_laughter = 1,
			/obj/item/reagent_containers/spray/waterflower = 1,
			/obj/item/stamp/clown = 1,
		))
		if(backpack_loot == /obj/item/pneumatic_cannon/pie)
			drop_a_pie_cannon = TRUE
		else
			backpack_contents += backpack_loot
	if(prob(30))
		backpack_contents += list(/obj/item/stack/sheet/mineral/bananium = pick_weight(list( 1 = 3, 2 = 2, 3 = 1)))
	if(prob(10))
		l_pocket = pick_weight(list(
			/obj/item/bikehorn/golden = 3,
			/obj/item/bikehorn/airhorn = 1,
		))
	if(prob(10))
		r_pocket = /obj/item/implanter/sad_trombone

/datum/outfit/consumed_clown/post_equip(mob/living/carbon/human/clown, visuals_only)
	. = ..()
	if(drop_a_pie_cannon)
		new /obj/item/pneumatic_cannon/pie(get_turf(clown))

/datum/outfit/consumed_golem
	name = "Legion-Consumed Golem"
	//Oops! All randomized!

/datum/outfit/consumed_golem/pre_equip(mob/living/carbon/human/golem, visuals_only = FALSE)
	if(!visuals_only)
		golem.set_species(/datum/species/golem)
	if(prob(30))
		glasses = pick_weight(list(
			/obj/item/clothing/glasses/hud/diagnostic = 2,
			/obj/item/clothing/glasses/hud/health = 2,
			/obj/item/clothing/glasses/meson = 2,
			/obj/item/clothing/glasses/science = 2,
			/obj/item/clothing/glasses/welding = 2,
			/obj/item/clothing/glasses/night = 1,
		))
	if(prob(10) && !visuals_only) //visuals_only = not a golem = can't put things in the belt slot without a jumpsuit
		belt = pick(list(
			/obj/item/crowbar/power,
			/obj/item/screwdriver/power,
			/obj/item/storage/belt/mining/vendor,
			/obj/item/storage/belt/utility/full,
			/obj/item/weldingtool/experimental,
		))
	if(prob(50))
		neck = /obj/item/bedsheet/rd/royal_cape

/datum/outfit/consumed_ice_settler
	name = "Legion-Consumed Settler"
	uniform = /obj/item/clothing/under/costume/traditional
	suit = /obj/item/clothing/suit/hooded/wintercoat
	shoes = /obj/item/clothing/shoes/winterboots
	mask = /obj/item/clothing/mask/breath

/datum/outfit/consumed_ice_settler/pre_equip(mob/living/carbon/human/ice_settler, visuals_only = FALSE)
	if(prob(40))
		r_pocket = pick_weight(list(
			/obj/item/coin/silver = 5,
			/obj/item/fishing_hook = 2,
			/obj/item/coin/gold = 2,
			/obj/item/fishing_hook/shiny = 1,
		))
	if(prob(30))
		back = pick_weight(list(
			/obj/item/pickaxe = 4,
			/obj/item/tank/internals/oxygen = 6,
		))
	else
		back = /obj/item/storage/backpack/satchel/explorer
		backpack_contents = list()
		var/backpack_loot = pick(list(
			/obj/item/food/fishmeat = 89,
			/obj/item/food/fishmeat/carp = 10,
			/obj/item/skeleton_key = 1,
		))
		backpack_contents += backpack_loot

//this is so pointlessly gendered but whatever bro i'm here to refactor not judge
/datum/outfit/consumed_dame
	name = "Legion-Consumed Dame"
	uniform = /obj/item/clothing/under/costume/maid
	suit = /obj/item/clothing/suit/armor/riot/knight
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/helmet/knight
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/tank/internals/emergency_oxygen

/datum/outfit/consumed_dame/pre_equip(mob/living/carbon/human/dame, visuals_only = FALSE)
	if(!visuals_only)
		dame.gender = FEMALE
		dame.physique = FEMALE
		dame.update_body()
	if(prob(30))
		back = /obj/item/nullrod/vibro/talking
	else
		back = /obj/item/shield/buckler
		belt = /obj/item/nullrod/claymore

/datum/outfit/consumed_shadowperson
	name = "Legion-Consumed Shadowperson"
	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/toggle/labcoat
	back = /obj/item/tank/internals/oxygen
	glasses = /obj/item/clothing/glasses/blindfold
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/sneakers/black
	r_pocket = /obj/item/reagent_containers/applicator/pill/shadowtoxin

	accessory = /obj/item/clothing/accessory/medal/plasma/nobel_science

/datum/outfit/consumed_shadowperson/pre_equip(mob/living/carbon/human/shadowperson, visuals_only = FALSE)
	if(visuals_only)
		return
	shadowperson.set_species(/datum/species/shadow)

/datum/outfit/consumed_cultist
	name = "Legion-Consumed Cultist"
	uniform = /obj/item/clothing/under/costume/roman
	suit = /obj/item/clothing/suit/hooded/cultrobes
	suit_store = /obj/item/tome
	back = /obj/item/storage/backpack/cultpack
	backpack_contents = list(
		/obj/item/cult_shift = 1,
		/obj/item/reagent_containers/cup/beaker/unholywater = 1,
		/obj/item/stack/sheet/runed_metal = 15,
		)
	r_pocket = /obj/item/clothing/glasses/hud/health/night/cultblind

/datum/outfit/consumed_heremoth
	name = "Legion-Consumed Tribal Mothman"
	uniform = /obj/item/clothing/under/costume/loincloth
	suit = /obj/item/clothing/suit/hooded/cultrobes/eldritch
	head = /obj/item/clothing/head/hooded/cult_hoodie/eldritch

/datum/outfit/consumed_heremoth/pre_equip(mob/living/carbon/human/moth, visuals_only = FALSE)
	if(!visuals_only)
		moth.set_species(/datum/species/moth)
	if(prob(70))
		glasses = /obj/item/clothing/glasses/blindfold
	if(prob(90))
		back = /obj/item/storage/backpack/cultpack
		backpack_contents = list()
		var/backpack_loot = pick(list(
			/obj/item/flashlight/lantern = 1,
			/obj/item/toy/plush/moth = 1,
			/obj/item/toy/eldritch_book = 2,
			/obj/item/knife/combat/survival = 2,
		))
		backpack_contents += backpack_loot
