#define VAT_GROWTH_RATE 4

////////////////////////////////
//// VERTEBRATES ////
////////////////////////////////

/datum/micro_organism/cell_line/mouse //nuisance cell line designed to complicate the growing of animal type cell lines.
	desc = "Murine cells"
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)
	supplementary_reagents = list(
		/datum/reagent/growthserum = 2,
		/datum/reagent/consumable/liquidgibs = 2,
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/sugar = 1,
		/datum/reagent/consumable/nutriment/fat/oil = 2,
		/datum/reagent/consumable/rice = 1,
		/datum/reagent/consumable/eggyolk = 1)

	suppressive_reagents = list(
		/datum/reagent/toxin/heparin = -6,
		/datum/reagent/consumable/astrotame = -4, //Saccarin gives rats cancer.
		/datum/reagent/consumable/ethanol/rubberneck = -3,
		/datum/reagent/consumable/grey_bull = -1)

	virus_suspectibility = 2
	growth_rate = VAT_GROWTH_RATE
	resulting_atom = /mob/living/basic/mouse
	resulting_atom_count = 2

/datum/micro_organism/cell_line/chicken //basic cell line designed as a good source of protein and eggyolk.
	desc = "Galliform skin cells."
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)

	supplementary_reagents = list(
		/datum/reagent/consumable/rice = 4,
		/datum/reagent/growthserum = 3,
		/datum/reagent/consumable/eggyolk = 1,
		/datum/reagent/consumable/nutriment/vitamin = 2)

	suppressive_reagents = list(
		/datum/reagent/fuel/oil = -4,
		/datum/reagent/toxin = -2)

	virus_suspectibility = 1
	growth_rate = VAT_GROWTH_RATE
	resulting_atom = /mob/living/basic/chicken

/datum/micro_organism/cell_line/cow
	desc = "Bovine stem cells"
	required_reagents = list(
	/datum/reagent/consumable/nutriment/protein,
	/datum/reagent/consumable/nutriment,
	/datum/reagent/cellulose)

	supplementary_reagents = list(
	/datum/reagent/growthserum = 4,
	/datum/reagent/consumable/nutriment/vitamin = 2,
	/datum/reagent/consumable/rice = 2,
	/datum/reagent/consumable/flour = 1)

	suppressive_reagents = list(/datum/reagent/toxin = -2,
	/datum/reagent/toxin/carpotoxin = -5)

	virus_suspectibility = 1
	resulting_atom = /mob/living/basic/cow

/datum/micro_organism/cell_line/moonicorn
	desc = "Fairyland Bovine stem cells"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/nutriment,
		/datum/reagent/drug/mushroomhallucinogen,
	)

	supplementary_reagents = list(
		/datum/reagent/growthserum = 4,
		/datum/reagent/consumable/tinlux = 2,
		/datum/reagent/consumable/vitfro = 2,
		/datum/reagent/consumable/astrotame = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/toxin = -2,
		/datum/reagent/toxin/carpotoxin = -5,
		/datum/reagent/consumable/coffee = -3,
		/datum/reagent/consumable/triple_citrus = -5,
	)

	virus_suspectibility = 1
	resulting_atom = /mob/living/basic/cow/moonicorn

/datum/micro_organism/cell_line/cat
	desc = "Feliform cells"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/liquidgibs)

	supplementary_reagents = list(
		/datum/reagent/growthserum = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/medicine/oculine = 2,
		/datum/reagent/consumable/milk = 1) //milkies

	suppressive_reagents = list(
		/datum/reagent/consumable/coco = -4,
		/datum/reagent/consumable/hot_coco = -2,
		/datum/reagent/consumable/chocolatepudding = -2,
		/datum/reagent/consumable/milk/chocolate_milk = -1)

	virus_suspectibility = 1.5
	resulting_atom = /mob/living/basic/pet/cat

/datum/micro_organism/cell_line/corgi
	desc = "Canid cells"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/liquidgibs)

	supplementary_reagents = list(
		/datum/reagent/growthserum = 3,
		/datum/reagent/barbers_aid = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2)

	suppressive_reagents = list(
		/datum/reagent/consumable/garlic = -2,
		/datum/reagent/consumable/tearjuice = -3,
		/datum/reagent/consumable/coco = -2)

	virus_suspectibility = 1
	resulting_atom = /mob/living/basic/pet/dog/corgi

/datum/micro_organism/cell_line/pug
	desc = "Squat canid cells"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/liquidgibs)

	supplementary_reagents = list(
		/datum/reagent/growthserum = 2,
		/datum/reagent/consumable/nutriment/vitamin = 3)

	suppressive_reagents = list(
		/datum/reagent/consumable/garlic = -2,
		/datum/reagent/consumable/tearjuice = -3,
		/datum/reagent/consumable/coco = -2)

	virus_suspectibility = 3
	resulting_atom = /mob/living/basic/pet/dog/pug

/datum/micro_organism/cell_line/bear //bears can't really compete directly with more powerful creatures, so i made it possible to grow them real fast.
	desc = "Ursine cells"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/liquidgibs,
		/datum/reagent/medicine/c2/synthflesh) //Nuke this if the dispenser becomes xenobio meta.

	supplementary_reagents = list(
		/datum/reagent/consumable/honey = 8, //Hunny.
		/datum/reagent/growthserum = 5,
		/datum/reagent/medicine/morphine = 4, //morphine is a vital nutrient for space bears, but it is better as a supplemental for gameplay reasons.
		/datum/reagent/consumable/nutriment/vitamin = 3)

	suppressive_reagents = list(
		/datum/reagent/consumable/condensedcapsaicin = -4, //bear mace, steal it from the sec checkpoint.
		/datum/reagent/toxin/carpotoxin = -2,
		/datum/reagent/medicine/insulin = -2) //depletes hunny.

	virus_suspectibility = 2
	resulting_atom = /mob/living/basic/bear

/datum/micro_organism/cell_line/carp
	desc = "Cyprinid cells"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/nutriment)

	supplementary_reagents = list(
		/datum/reagent/consumable/nutriment/fat/oil = 4, //Carp are oily fish
		/datum/reagent/toxin/carpotoxin = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2)

	suppressive_reagents = list(
		/datum/reagent/toxin/bungotoxin = -6,
		/datum/reagent/mercury = -4,
		/datum/reagent/oxygen = -3)

	virus_suspectibility = 2
	resulting_atom = /mob/living/basic/carp

/datum/micro_organism/cell_line/megacarp
	desc = "Cartilaginous cyprinid cells"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/medicine/c2/synthflesh,
		/datum/reagent/consumable/nutriment)

	supplementary_reagents = list(
		/datum/reagent/consumable/nutriment/fat/oil = 4,
		/datum/reagent/growthserum = 3,
		/datum/reagent/toxin/carpotoxin = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2)

	suppressive_reagents = list(
		/datum/reagent/toxin/bungotoxin = -6,
		/datum/reagent/oxygen = -3)

	virus_suspectibility = 1
	resulting_atom = /mob/living/basic/carp/mega

/datum/micro_organism/cell_line/snake
	desc = "Ophidic cells"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/liquidgibs)

	supplementary_reagents = list(
		/datum/reagent/growthserum = 3,
		/datum/reagent/consumable/nutriment/peptides = 3,
		/datum/reagent/consumable/eggyolk = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2)

	suppressive_reagents = list(
		/datum/reagent/consumable/corn_syrup = -6,
		/datum/reagent/sulfur = -3) //sulfur repels snakes according to professor google.

	resulting_atom = /mob/living/basic/snake


///////////////////////////////////////////
/// SLIMES, OOZES & BLOBS ///
//////////////////////////////////////////

/datum/micro_organism/cell_line/slime
	desc = "Slime particles"
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)

	supplementary_reagents = list(
		/datum/reagent/toxin/slimejelly = 2,
		/datum/reagent/consumable/liquidgibs = 2,
		/datum/reagent/consumable/enzyme = 1)

	suppressive_reagents = list(
		/datum/reagent/consumable/frostoil = -4,
		/datum/reagent/cryostylane = -4,
		/datum/reagent/medicine/morphine = -2,
		/datum/reagent/consumable/ice = -2) //Brrr!

	virus_suspectibility = 0
	resulting_atom = /mob/living/basic/slime

/datum/micro_organism/cell_line/blob_spore //nuisance cell line
	desc = "Immature blob spores"
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)

	supplementary_reagents = list(
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/eggrot = 2,
		/datum/reagent/medicine/c2/synthflesh = 1,
		/datum/reagent/consumable/liquidgibs = 1,
		/datum/reagent/sulfur = 1)

	suppressive_reagents = list(
		/datum/reagent/consumable/tinlux = -6,
		/datum/reagent/lead = -4, //neurotoxin, works because spores are smort
		/datum/reagent/napalm = -4,
		/datum/reagent/medicine/psicodine = -2) //Blob zombies likely wouldn't appreciate psicodine so why this is here

	virus_suspectibility = 0
	resulting_atom = /mob/living/basic/blob_minion/spore/independent

/datum/micro_organism/cell_line/blobbernaut
	desc = "Blobular myocytes"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/medicine/c2/synthflesh,
		/datum/reagent/sulfur) //grind flares to get this

	supplementary_reagents = list(
		/datum/reagent/growthserum = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/liquidgibs = 2,
		/datum/reagent/consumable/eggyolk = 2,
		/datum/reagent/consumable/shamblers = 1)

	suppressive_reagents = list(/datum/reagent/consumable/tinlux = -6)

	virus_suspectibility = 0
	resulting_atom = /mob/living/basic/blob_minion/blobbernaut/independent

/datum/micro_organism/cell_line/gelatinous_cube
	desc = "Cubic ooze particles"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/toxin/slimejelly,
		/datum/reagent/yuck,
		/datum/reagent/consumable/enzyme) //Powerful enzymes helps the cube digest prey.

	supplementary_reagents = list(
		/datum/reagent/water/hollowwater = 4,
		/datum/reagent/consumable/corn_syrup = 3,
		/datum/reagent/gold = 2, //This is why they eat so many adventurers.
		/datum/reagent/consumable/nutriment/peptides = 2,
		/datum/reagent/consumable/potato_juice = 1,
		/datum/reagent/consumable/liquidgibs = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1)

	suppressive_reagents = list(
		/datum/reagent/consumable/mintextract = -3,
		/datum/reagent/consumable/frostoil = -2,
		/datum/reagent/consumable/ice = -1)

	virus_suspectibility = 0
	resulting_atom = /mob/living/simple_animal/hostile/ooze/gelatinous

/datum/micro_organism/cell_line/sholean_grapes
	desc = "Globular ooze particles"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/toxin/slimejelly,
		/datum/reagent/yuck,
		/datum/reagent/consumable/vitfro)

	supplementary_reagents = list(
		/datum/reagent/medicine/omnizine = 4,
		/datum/reagent/consumable/nutriment/peptides = 3,
		/datum/reagent/consumable/corn_syrup = 2,
		/datum/reagent/consumable/ethanol/squirt_cider = 2,
		/datum/reagent/consumable/doctor_delight = 1,
		/datum/reagent/medicine/salglu_solution = 1,
		/datum/reagent/consumable/liquidgibs = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1)

	suppressive_reagents = list(
		/datum/reagent/toxin/carpotoxin = -3,
		/datum/reagent/toxin/coffeepowder = -2,
		/datum/reagent/consumable/frostoil = -2,
		/datum/reagent/consumable/ice = -1)

	virus_suspectibility = 0
	resulting_atom = /mob/living/simple_animal/hostile/ooze/grapes

////////////////////
//// MISC ////
////////////////////
/datum/micro_organism/cell_line/cockroach //general nuisance cell line
	desc = "Blattodeoid anthropod cells"
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)
	supplementary_reagents = list(
		/datum/reagent/growthserum = 1,
		/datum/reagent/toxin/slimejelly = 2,
		/datum/reagent/yuck = 2, //Almost every fun recipe requires this. Making this value too high makes cockroaches extremely anti-fun.
		/datum/reagent/consumable/nutriment/vitamin = 1)

	suppressive_reagents = list(
		/datum/reagent/toxin/pestkiller = -2,
		/datum/reagent/consumable/salt = -3, //Some salts are toxic to cockroaches, + helps makes the cell line more manageable
		/datum/reagent/consumable/poisonberryjuice = -4,
		/datum/reagent/consumable/ethanol/bug_spray = -4)

	virus_suspectibility = 0
	resulting_atom = /mob/living/basic/cockroach
	resulting_atom_count = 5

/datum/micro_organism/cell_line/glockroach
	desc = "Gattodeoid anthropod cells"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/drug/maint/powder,
		/datum/reagent/iron)

	supplementary_reagents = list(
		/datum/reagent/gunpowder = 6,
		/datum/reagent/drug/maint/tar = 4,
		/datum/reagent/yuck = 2,
		/datum/reagent/growthserum = 2)

	suppressive_reagents = list(
		/datum/reagent/toxin/pestkiller = -2,
		/datum/reagent/consumable/coffee = -3, //a quick google search said roaches don't like coffee grounds, and I needed a different suppressive reagent
		/datum/reagent/consumable/ethanol/bug_spray = -4)

	virus_suspectibility = 0
	resulting_atom = /mob/living/basic/cockroach/glockroach
	resulting_atom_count = 2

/datum/micro_organism/cell_line/hauberoach
	desc = "Hattodeoid anthropod cells"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/ethanol/beer,
		/datum/reagent/iron)

	supplementary_reagents = list(
		/datum/reagent/gunpowder = 6,
		/datum/reagent/medicine/pen_acid = 4, //Prussian Blue is an antidote for radioactive thallium poisoning, among other things. The pickelhaube was worn by Prussian/German officers. You can tell I'm running out of ideas here.
		/datum/reagent/yuck = 2,
		/datum/reagent/blood = 2)

	suppressive_reagents = list(
		/datum/reagent/toxin/pestkiller = -2,
		/datum/reagent/consumable/coffee = -3,
		/datum/reagent/consumable/ethanol/cognac = -4)

	virus_suspectibility = 0
	resulting_atom = /mob/living/basic/cockroach/hauberoach
	resulting_atom_count = 2

/datum/micro_organism/cell_line/pine
	desc = "Coniferous plant cells"
	required_reagents = list(
		/datum/reagent/ammonia,
		/datum/reagent/ash,
		/datum/reagent/plantnutriment/robustharvestnutriment) //A proper source of phosphorous like would be thematically more appropriate but this is what we have.

	supplementary_reagents = list(
		/datum/reagent/saltpetre = 5,
		/datum/reagent/carbondioxide = 2,
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/space_cola = 2, //A little extra phosphorous
		/datum/reagent/water/holywater = 2,
		/datum/reagent/water = 1,
		/datum/reagent/cellulose = 1)

	suppressive_reagents = list(/datum/reagent/toxin/plantbgone = -8)

	virus_suspectibility = 1
	resulting_atom = /mob/living/basic/tree

/datum/micro_organism/cell_line/vat_beast
	desc = "Hypergenic xenocytes"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/nutriment/vitamin,
		/datum/reagent/consumable/nutriment/peptides,
		/datum/reagent/consumable/liquidelectricity/enriched,
		/datum/reagent/growthserum,
		/datum/reagent/yuck)

	supplementary_reagents = list(
		/datum/reagent/medicine/rezadone = 3,
		/datum/reagent/consumable/entpoly = 3,
		/datum/reagent/consumable/red_queen = 2,
		/datum/reagent/consumable/peachjuice = 2,
		/datum/reagent/uranium = 1,
		/datum/reagent/consumable/liquidgibs = 1)

	suppressive_reagents = list(
		/datum/reagent/consumable/salt = -3,
		/datum/reagent/medicine/c2/syriniver = -2)

	virus_suspectibility = 0.5
	resulting_atom = /mob/living/basic/vatbeast

/datum/micro_organism/cell_line/vat_beast/succeed_growing(obj/machinery/vatgrower/vat)
	. = ..()
	qdel(vat)

//randomizes from the netherworld pool!
/datum/micro_organism/cell_line/netherworld
	desc = "Aberrant residue"
	required_reagents = list(//theme here: very odd requirements
		/datum/reagent/water/hollowwater,//geyser reagent, so plentiful when found
		/datum/reagent/consumable/ethanol/wizz_fizz, //EZ bartender drink, like brainless
		/datum/reagent/yuck) //since the other two are easy to make tons of, this is kind of a limiter

	supplementary_reagents = list( //all of these are just geyser stuff, rated by their rarity
		/datum/reagent/wittel = 10, //stupid rare
		/datum/reagent/medicine/omnizine/protozine = 5,
		/datum/reagent/plasma_oxide = 3,
		/datum/reagent/clf3 = 1)//since this is also chemistry it's worth near nothing

	suppressive_reagents = list(//generics you would regularly put in a vat kill abberant residue
		/datum/reagent/consumable/nutriment/peptides = -6,
		/datum/reagent/consumable/nutriment/protein = -4,
		/datum/reagent/consumable/nutriment = -3,
		/datum/reagent/consumable/liquidgibs = -2)

	virus_suspectibility = 0

/datum/micro_organism/cell_line/netherworld/succeed_growing(obj/machinery/vatgrower/vat)
	resulting_atom = pick(/mob/living/basic/creature, /mob/living/basic/migo, /mob/living/basic/blankbody) //i looked myself, pretty much all of them are reasonably strong and somewhat on the same level. except migo is the jackpot and the blank body is whiff.
	return ..()

/datum/micro_organism/cell_line/clown/fuck_up_growing(obj/machinery/vatgrower/vat)
	vat.visible_message(span_warning("The biological sample in [vat] seems to have created something horrific!"))

	var/mob/selected_mob = pick(list(/mob/living/basic/clown/mutant, /mob/living/basic/clown/fleshclown))

	new selected_mob(get_turf(vat))

/datum/micro_organism/cell_line/clown/bananaclown
	desc = "Clown bits with banana chunks"

	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/banana)

	supplementary_reagents = list(
		/datum/reagent/saltpetre = 4,
		/datum/reagent/ammonia = 3,
		/datum/reagent/carbondioxide = 3,
		/datum/reagent/medicine/coagulant/banana_peel = 2,
		/datum/reagent/plantnutriment/robustharvestnutriment = 1)

	suppressive_reagents = list(
		/datum/reagent/consumable/nutriment/soup/clown_tears = -8,
		/datum/reagent/toxin/plantbgone = -4,
		/datum/reagent/consumable/ethanol/silencer = -3,
		/datum/reagent/consumable/nothing = -2,
		/datum/reagent/fuel/oil = -1)

	resulting_atom = /mob/living/basic/clown/banana

/datum/micro_organism/cell_line/clown/glutton
	desc = "hyperadipogenic clown stem cells"

	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/banana,
		/datum/reagent/medicine/c2/synthflesh)
	//r/chonkers
	supplementary_reagents = list(
		/datum/reagent/consumable/vanillapudding = 8,
		/datum/reagent/growthserum = 6,
		/datum/reagent/consumable/nutriment/peptides = 4,
		/datum/reagent/consumable/nutriment/fat/oil = 3,
		/datum/reagent/consumable/space_cola = 1)

	suppressive_reagents = list(
		/datum/reagent/consumable/nutriment/soup/clown_tears = -8,
		/datum/reagent/consumable/mintextract = -6,
		/datum/reagent/consumable/ethanol/silencer = -3,
		/datum/reagent/consumable/ethanol/fernet = -3,
		/datum/reagent/toxin/lipolicide = -3,
		/datum/reagent/consumable/nothing = -2,
		/datum/reagent/toxin/bad_food = -1)

	resulting_atom = /mob/living/basic/clown/mutant/glutton

/datum/micro_organism/cell_line/clown/longclown
	desc = "long clown bits"

	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/banana)

	supplementary_reagents = list(
		/datum/reagent/drug/happiness = 5,
		/datum/reagent/toxin/mimesbane = 4,
		/datum/reagent/consumable/laughter = 3,
		/datum/reagent/nitrous_oxide = 2)

	suppressive_reagents = list(
		/datum/reagent/consumable/nutriment/soup/clown_tears = -8,
		/datum/reagent/consumable/ethanol/beepsky_smash = -3,
		/datum/reagent/consumable/ethanol/silencer = -3,
		/datum/reagent/toxin/mutetoxin = -3,
		/datum/reagent/consumable/nothing = -2,
		/datum/reagent/sulfur = -1)

	resulting_atom = /mob/living/basic/clown/longface

/datum/micro_organism/cell_line/frog
	desc = "anura amphibian cells"
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)

	supplementary_reagents = list(
		/datum/reagent/ants = 3,
		/datum/reagent/consumable/eggwhite= 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,)

	suppressive_reagents = list(
		/datum/reagent/toxin/carpotoxin = -3,
		/datum/reagent/toxin/bungotoxin = -3,
		/datum/reagent/toxin/spore = -3,
		/datum/reagent/toxin/plantbgone = -2, //GAY FROGS
		/datum/reagent/drying_agent = -2,
		/datum/reagent/consumable/mold = -2,
		/datum/reagent/toxin = -1)

	virus_suspectibility = 0.5
	resulting_atom = /obj/effect/spawner/random/frog

/datum/micro_organism/cell_line/axolotl
	desc = "caudata amphibian cells"
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)

	supplementary_reagents = list(
		/datum/reagent/ants = 3,
		/datum/reagent/consumable/liquidgibs = 2,
		/datum/reagent/consumable/salt = 1,
		/datum/reagent/consumable/eggwhite= 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,)

	suppressive_reagents = list(
		/datum/reagent/ammonia = -3,
		/datum/reagent/toxin/bungotoxin = -3,
		/datum/reagent/toxin/spore = -3,
		/datum/reagent/toxin/plantbgone = -2, //GAY AXOLOTLS
		/datum/reagent/drying_agent = -4,
		/datum/reagent/consumable/mold = -2,
		/datum/reagent/toxin = -1)

	virus_suspectibility = 0.5
	resulting_atom = /mob/living/basic/axolotl

/datum/micro_organism/cell_line/walking_mushroom
	desc = "motile fungal hyphae"
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)

	supplementary_reagents = list(
		/datum/reagent/toxin/polonium = 6,
		/datum/reagent/consumable/corn_syrup = 3,
		/datum/reagent/consumable/mushroom_tea = 3,
		/datum/reagent/toxin/coffeepowder = 2,
		/datum/reagent/consumable/nuka_cola = 2,
		/datum/reagent/consumable/mold = 2,
		/datum/reagent/consumable/sugar = 1,
		/datum/reagent/cellulose = 1)

	suppressive_reagents = list(
		/datum/reagent/lead = -4,
		/datum/reagent/consumable/garlic = -3,
		/datum/reagent/toxin/plasma = -2,
		/datum/reagent/flash_powder = -2,
		/datum/reagent/pax = -2,
		/datum/reagent/copper = -1)

	virus_suspectibility = 0
	resulting_atom = /mob/living/basic/mushroom

/datum/micro_organism/cell_line/queen_bee
	desc = "aphid cells"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/corn_syrup)

	supplementary_reagents = list(
		/datum/reagent/consumable/honey = 4,
		/datum/reagent/consumable/korta_nectar = 3,
		/datum/reagent/consumable/red_queen = 3,
		/datum/reagent/consumable/ethanol/champagne = 2,
		/datum/reagent/consumable/ethanol/sugar_rush = 2,
		/datum/reagent/consumable/sugar = 1,
		/datum/reagent/consumable/lemonade = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1)

	suppressive_reagents = list(
		/datum/reagent/toxin/carpotoxin = -3,
		/datum/reagent/toxin/pestkiller = -2,
		/datum/reagent/consumable/potato_juice = -2,
		/datum/reagent/drug/nicotine = -1)

	virus_suspectibility = 0
	resulting_atom = /obj/item/queen_bee/bought

/datum/micro_organism/cell_line/queen_bee/fuck_up_growing(obj/machinery/vatgrower/vat) //we love job hazards
	vat.visible_message(span_warning("You hear angry buzzing coming from the inside of the vat!"))
	for(var/i in 1 to 5)
		new /mob/living/basic/bee(get_turf(vat))


/datum/micro_organism/cell_line/butterfly
	desc = "Papilionoidea cells"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
	)
	supplementary_reagents = list(
		/datum/reagent/consumable/honey = 4,
		/datum/reagent/consumable/korta_nectar = 3,
		/datum/reagent/consumable/applejuice = 2,
		/datum/reagent/water = 1,
		/datum/reagent/consumable/sugar = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/toxin/pestkiller = -3,
		/datum/reagent/toxin/carpotoxin = -2,
		/datum/reagent/toxin = -2,
	)

	virus_suspectibility = 0
	resulting_atom = /mob/living/basic/butterfly
	resulting_atom_count = 3

/datum/micro_organism/cell_line/mega_arachnid
	desc = "pseudoarachnoid cells"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/ants,
		/datum/reagent/medicine/omnizine)

	supplementary_reagents = list(
		/datum/reagent/toxin/venom = 6,
		/datum/reagent/drug/kronkaine = 4,
		/datum/reagent/consumable/nutriment/peptides = 3,
		/datum/reagent/consumable/ethanol/squirt_cider = 2,
		/datum/reagent/consumable/nutraslop = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/toxin/plasma = 1,
		/datum/reagent/consumable/nutriment/organ_tissue = 1,
		/datum/reagent/consumable/liquidgibs = 1,
		/datum/reagent/consumable/enzyme = 1)

	suppressive_reagents = list(
		/datum/reagent/consumable/ethanol/bug_spray = -3,
		/datum/reagent/drug/nicotine = -1,
		/datum/reagent/toxin/pestkiller = -1)

	resulting_atom = /mob/living/basic/mega_arachnid

/datum/micro_organism/cell_line/snail
	desc = "gastropod epithelial cells"
	required_reagents = list(
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/iron,
	)

	supplementary_reagents = list(
		/datum/reagent/yuck = 2,
		/datum/reagent/blood = 2,
		/datum/reagent/consumable/applejuice = 2,
		/datum/reagent/consumable/mold = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/toxin/pestkiller = -2,
		/datum/reagent/consumable/salt = -3,
		/datum/reagent/consumable/ethanol/bug_spray = -1,
	)
	virus_suspectibility = 0
	resulting_atom = /mob/living/basic/snail

#undef VAT_GROWTH_RATE
