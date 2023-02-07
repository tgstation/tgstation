// Wintercoat
/obj/item/clothing/suit/hooded/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon = 'icons/obj/clothing/suits/wintercoat.dmi'
	icon_state = "coatwinter"
	worn_icon = 'icons/mob/clothing/suits/wintercoat.dmi'
	inhand_icon_state = "coatwinter"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list()
	armor_type = /datum/armor/hooded_wintercoat

/datum/armor/hooded_wintercoat
	bio = 10

/obj/item/clothing/suit/hooded/wintercoat/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/flashlight,
		/obj/item/lighter,
		/obj/item/modular_computer/pda,
		/obj/item/radio,
		/obj/item/storage/bag/books,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
	)

/obj/item/clothing/head/hooded/winterhood
	name = "winter hood"
	desc = "A cozy winter hood attached to a heavy winter jacket."
	icon = 'icons/obj/clothing/head/winterhood.dmi'
	icon_state = "hood_winter"
	worn_icon = 'icons/mob/clothing/head/winterhood.dmi'
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS
	armor_type = /datum/armor/hooded_winterhood

// An coat intended for use for general crew EVA, with values close to those of the space suits found in EVA normally
// Slight extra armor, bulky size, slows you down, can carry a large oxygen tank, won't burn off.
/datum/armor/hooded_winterhood
	bio = 10

/obj/item/clothing/suit/hooded/wintercoat/eva
	name = "\proper Endotherm winter coat"
	desc = "A thickly padded winter coat to keep the wearer well insulated no matter the circumstances. It has a harness for a larger oxygen tank attached to the back."
	icon_state = "coateva"
	w_class = WEIGHT_CLASS_BULKY
	slowdown = 0.75
	armor_type = /datum/armor/wintercoat_eva
	strip_delay = 6 SECONDS
	equip_delay_other = 6 SECONDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT // Protects very cold.
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT // Protects a little hot.
	flags_inv = HIDEJUMPSUIT
	clothing_flags = THICKMATERIAL
	resistance_flags = NONE
	hoodtype = /obj/item/clothing/head/hooded/winterhood/eva

/datum/armor/wintercoat_eva
	melee = 10
	laser = 10
	energy = 10
	bio = 50
	fire = 50
	acid = 20

/obj/item/clothing/suit/hooded/wintercoat/eva/Initialize(mapload)
	. = ..()
	allowed += /obj/item/tank/internals

/obj/item/clothing/head/hooded/winterhood/eva
	name = "\proper Endotherm winter hood"
	desc = "A thickly padded hood attached to an even thicker coat."
	icon_state = "hood_eva"
	armor_type = /datum/armor/winterhood_eva
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	clothing_flags = THICKMATERIAL|SNUG_FIT // Snug fit doesn't really matter, but might as well
	resistance_flags = NONE

// CentCom
/datum/armor/winterhood_eva
	melee = 10
	laser = 10
	energy = 10
	bio = 50
	fire = 50
	acid = 20

/obj/item/clothing/suit/hooded/wintercoat/centcom
	name = "centcom winter coat"
	desc = "A luxurious winter coat woven in the bright green and gold colours of Central Command. It has a small pin in the shape of the Nanotrasen logo for a zipper."
	icon_state = "coatcentcom"
	inhand_icon_state = null
	armor_type = /datum/armor/wintercoat_centcom
	hoodtype = /obj/item/clothing/head/hooded/winterhood/centcom

/datum/armor/wintercoat_centcom
	melee = 35
	bullet = 40
	laser = 40
	energy = 50
	bomb = 35
	bio = 10
	fire = 10
	acid = 60

/obj/item/clothing/suit/hooded/wintercoat/centcom/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/centcom
	icon_state = "hood_centcom"
	armor_type = /datum/armor/winterhood_centcom

// Captain
/datum/armor/winterhood_centcom
	melee = 35
	bullet = 40
	laser = 40
	energy = 50
	bomb = 35
	bio = 10
	fire = 10
	acid = 60

/obj/item/clothing/suit/hooded/wintercoat/captain
	name = "captain's winter coat"
	desc = "A luxurious winter coat, stuffed with the down of the endangered Uka bird and trimmed with genuine sable. The fabric is an indulgently soft micro-fiber, \
			and the deep ultramarine colour is only one that could be achieved with minute amounts of crystalline bluespace dust woven into the thread between the plectrums. \
			Extremely lavish, and extremely durable."
	icon_state = "coatcaptain"
	inhand_icon_state = "coatcaptain"
	armor_type = /datum/armor/wintercoat_captain
	hoodtype = /obj/item/clothing/head/hooded/winterhood/captain

/datum/armor/wintercoat_captain
	melee = 25
	bullet = 30
	laser = 30
	energy = 40
	bomb = 25
	acid = 50

/obj/item/clothing/suit/hooded/wintercoat/captain/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/captain
	icon_state = "hood_captain"
	armor_type = /datum/armor/winterhood_captain

// Head of Personnel
/datum/armor/winterhood_captain
	melee = 25
	bullet = 30
	laser = 30
	energy = 40
	bomb = 25
	acid = 50

/obj/item/clothing/suit/hooded/wintercoat/hop
	name = "head of personnel's winter coat"
	desc = "A cozy winter coat, covered in thick fur. The breast features a proud yellow chevron, reminding everyone that you're the second banana."
	icon_state = "coathop"
	inhand_icon_state = null
	armor_type = /datum/armor/wintercoat_hop
	allowed = list(
		/obj/item/melee/baton/telescopic,
	)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hop

/datum/armor/wintercoat_hop
	melee = 10
	bullet = 15
	laser = 15
	energy = 25
	bomb = 10
	acid = 35

/obj/item/clothing/head/hooded/winterhood/hop
	icon_state = "hood_hop"

// Botanist
/obj/item/clothing/suit/hooded/wintercoat/hydro
	name = "hydroponics winter coat"
	desc = "A green and blue winter coat. The zipper tab looks like the flower from a member of Rosa Hesperrhodos, a pretty pink-and-white rose. The colours absolutely clash."
	icon_state = "coathydro"
	inhand_icon_state = "coathydro"
	allowed = list(
		/obj/item/cultivator,
		/obj/item/hatchet,
		/obj/item/plant_analyzer,
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/spray/pestspray,
		/obj/item/seeds,
		/obj/item/storage/bag/plants,
	)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hydro

/obj/item/clothing/head/hooded/winterhood/hydro
	desc = "A green winter coat hood."
	icon_state = "hood_hydro"

// Janitor
/obj/item/clothing/suit/hooded/wintercoat/janitor
	name = "janitors winter coat"
	desc = "A purple-and-beige winter coat that smells of space cleaner."
	icon_state = "coatjanitor"
	inhand_icon_state = null
	allowed = list(
		/obj/item/grenade/chem_grenade,
		/obj/item/holosign_creator,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/spray,
	)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/janitor

/obj/item/clothing/head/hooded/winterhood/janitor
	desc = "A purple hood that smells of space cleaner."
	icon_state = "hood_janitor"

// Security Officer
/obj/item/clothing/suit/hooded/wintercoat/security
	name = "security winter jacket"
	desc = "A red, armour-padded winter coat. It glitters with a mild ablative coating and a robust air of authority.  The zipper tab is a pair of jingly little handcuffs that get annoying after the first ten seconds."
	icon_state = "coatsecurity"
	inhand_icon_state = "coatsecurity"
	armor_type = /datum/armor/wintercoat_security
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security

/datum/armor/wintercoat_security
	melee = 25
	bullet = 15
	laser = 30
	energy = 40
	bomb = 25
	acid = 45

/obj/item/clothing/suit/hooded/wintercoat/security/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/security
	desc = "A red, armour-padded winter hood. Definitely not bulletproof, especially not the part where your face goes."
	icon_state = "hood_security"
	armor_type = /datum/armor/winterhood_security

// Medical Doctor
/datum/armor/winterhood_security
	melee = 25
	bullet = 15
	laser = 30
	energy = 40
	bomb = 25
	acid = 45

/obj/item/clothing/suit/hooded/wintercoat/medical
	name = "medical winter coat"
	desc = "An arctic white winter coat with a small blue caduceus instead of a plastic zipper tab. Snazzy."
	icon_state = "coatmedical"
	inhand_icon_state = "coatmedical"
	allowed = list(
		/obj/item/flashlight/pen,
		/obj/item/gun/syringe,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/sensor_device,
		/obj/item/storage/pill_bottle,
	)
	armor_type = /datum/armor/wintercoat_medical
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical

/datum/armor/wintercoat_medical
	bio = 40
	fire = 10
	acid = 20

/obj/item/clothing/head/hooded/winterhood/medical
	desc = "A white winter coat hood."
	icon_state = "hood_medical"
	armor_type = /datum/armor/winterhood_medical

// Chief Medical Officer
/datum/armor/winterhood_medical
	bio = 40
	fire = 10
	acid = 20

/obj/item/clothing/suit/hooded/wintercoat/medical/cmo
	name = "chief medical officer's winter coat"
	desc = "A winter coat in a vibrant shade of blue with a small silver caduceus instead of a plastic zipper tab. The normal liner is replaced with an exceptionally thick, soft layer of fur."
	icon_state = "coatcmo"
	inhand_icon_state = null
	armor_type = /datum/armor/medical_cmo
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/cmo

/datum/armor/medical_cmo
	bio = 50
	fire = 20
	acid = 30

/obj/item/clothing/suit/hooded/wintercoat/medical/cmo/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/melee/baton/telescopic,
	)

/obj/item/clothing/head/hooded/winterhood/medical/cmo
	desc = "A blue winter coat hood."
	icon_state = "hood_cmo"
	armor_type = /datum/armor/medical_cmo

// Chemist
/obj/item/clothing/suit/hooded/wintercoat/medical/chemistry
	name = "chemistry winter coat"
	desc = "A lab-grade winter coat made with acid resistant polymers. For the enterprising chemist who was exiled to a frozen wasteland on the go."
	icon_state = "coatchemistry"
	inhand_icon_state = null
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/chemistry

/obj/item/clothing/suit/hooded/wintercoat/medical/chemistry/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/chemistry

/obj/item/clothing/head/hooded/winterhood/medical/chemistry
	desc = "A white winter coat hood."
	icon_state = "hood_chemistry"

// Virologist
/obj/item/clothing/suit/hooded/wintercoat/medical/viro
	name = "virology winter coat"
	desc = "A white winter coat with green markings. Warm, but wont fight off the common cold or any other disease. Might make people stand far away from you in the hallway. The zipper tab looks like an oversized bacteriophage."
	icon_state = "coatviro"
	inhand_icon_state = null
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/viro

/obj/item/clothing/suit/hooded/wintercoat/medical/viro/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/bio

/obj/item/clothing/head/hooded/winterhood/medical/viro
	desc = "A white winter coat hood with green markings."
	icon_state = "hood_viro"

// Paramedic
/obj/item/clothing/suit/hooded/wintercoat/medical/paramedic
	name = "paramedic winter coat"
	desc = "A winter coat with blue markings. Warm, but probably won't protect from biological agents. For the cozy doctor on the go."
	icon_state = "coatparamed"
	inhand_icon_state = null
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/paramedic

/obj/item/clothing/head/hooded/winterhood/medical/paramedic
	desc = "A white winter coat hood with blue markings."
	icon_state = "hood_paramed"

// Scientist
/obj/item/clothing/suit/hooded/wintercoat/science
	name = "science winter coat"
	desc = "A white winter coat with an outdated atomic model instead of a plastic zipper tab."
	icon_state = "coatscience"
	inhand_icon_state = "coatscience"
	allowed = list(
		/obj/item/analyzer,
		/obj/item/dnainjector,
		/obj/item/paper,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/bag/xeno,
		/obj/item/storage/pill_bottle,
	)
	armor_type = /datum/armor/wintercoat_science
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science
	species_exception = list(/datum/species/golem)

/datum/armor/wintercoat_science
	bomb = 10
	fire = 20

/obj/item/clothing/head/hooded/winterhood/science
	desc = "A white winter coat hood. This one will keep your brain warm. About as much as the others, really."
	icon_state = "hood_science"
	armor_type = /datum/armor/winterhood_science

// Research Director
/datum/armor/winterhood_science
	bomb = 10
	fire = 20

/obj/item/clothing/suit/hooded/wintercoat/science/rd
	name = "research director's winter coat"
	desc = "A thick arctic winter coat with an outdated atomic model instead of a plastic zipper tab. Most in the know are heavily aware that Bohr's model of the atom was outdated by the time of the 1930s when the Heisenbergian and Schrodinger models were generally accepted for true. Nevertheless, we still see its use in anachronism, roleplaying, and, in this case, as a zipper tab. At least it should keep you warm on your ivory pillar."
	icon_state = "coatrd"
	inhand_icon_state = null
	armor_type = /datum/armor/science_rd
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/rd

/datum/armor/science_rd
	bomb = 20
	fire = 30

/obj/item/clothing/suit/hooded/wintercoat/science/rd/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/melee/baton/telescopic,
	)

/obj/item/clothing/head/hooded/winterhood/science/rd
	desc = "A white winter coat hood. It smells faintly of hair gel."
	icon_state = "hood_rd"
	armor_type = /datum/armor/science_rd

// Roboticist
/obj/item/clothing/suit/hooded/wintercoat/science/robotics
	name = "robotics winter coat"
	desc = "A black winter coat with a badass flaming robotic skull for the zipper tab. This one has bright red designs and a few useless buttons."
	icon_state = "coatrobotics"
	inhand_icon_state = null
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/robotics

/obj/item/clothing/head/hooded/winterhood/science/robotics
	desc = "A black winter coat hood. You can pull it down over your eyes and pretend that you're an outdated, late 1980s interpretation of a futuristic mechanized police force. They'll fix you. They fix everything."
	icon_state = "hood_robotics"

// Geneticist
/obj/item/clothing/suit/hooded/wintercoat/science/genetics
	name = "genetics winter coat"
	desc = "A white winter coat with a DNA helix for the zipper tab."
	icon_state = "coatgenetics"
	inhand_icon_state = null
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/genetics

/obj/item/clothing/head/hooded/winterhood/science/genetics
	desc = "A white winter coat hood. It's warm."
	icon_state = "hood_genetics"

// Station Engineer
/obj/item/clothing/suit/hooded/wintercoat/engineering
	name = "engineering winter coat"
	desc = "A surprisingly heavy yellow winter coat with reflective orange stripes. It has a small wrench for its zipper tab, and the inside layer is covered with a radiation-resistant silver-nylon blend. Because you're worth it."
	icon_state = "coatengineer"
	inhand_icon_state = "coatengineer"
	allowed = list(
		/obj/item/analyzer,
		/obj/item/construction/rcd,
		/obj/item/fireaxe/metal_h2_axe,
		/obj/item/pipe_dispenser,
		/obj/item/storage/bag/construction,
		/obj/item/t_scanner,
	)
	armor_type = /datum/armor/wintercoat_engineering
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering
	species_exception = list(/datum/species/golem/uranium)

/datum/armor/wintercoat_engineering
	fire = 20

/obj/item/clothing/suit/hooded/wintercoat/engineering/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", src, alpha = src.alpha)

/obj/item/clothing/head/hooded/winterhood/engineering
	desc = "A yellow winter coat hood. Definitely not a replacement for a hard hat."
	icon_state = "hood_engineer"
	armor_type = /datum/armor/winterhood_engineering

/datum/armor/winterhood_engineering
	fire = 20

/obj/item/clothing/head/hooded/winterhood/engineering/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", src, alpha = src.alpha)

// Chief Engineer
/obj/item/clothing/suit/hooded/wintercoat/engineering/ce
	name = "chief engineer's winter coat"
	desc = "A white winter coat with reflective green and yellow stripes. Stuffed with asbestos, treated with fire retardant PBDE, lined with a micro thin sheet of lead foil and snugly fitted to your body's measurements. This baby's ready to save you from anything except the thyroid cancer and systemic fibrosis you'll get from wearing it. The zipper tab is a tiny golden wrench."
	icon_state = "coatce"
	inhand_icon_state = null
	armor_type = /datum/armor/engineering_ce
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/ce

/datum/armor/engineering_ce
	fire = 30
	acid = 10

/obj/item/clothing/suit/hooded/wintercoat/engineering/ce/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/melee/baton/telescopic,
	)

/obj/item/clothing/head/hooded/winterhood/engineering/ce
	desc = "A white winter coat hood. Feels surprisingly heavy. The tag says that it's not child safe."
	icon_state = "hood_ce"
	armor_type = /datum/armor/engineering_ce

// Atmospherics Technician
/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	desc = "A yellow and blue winter coat. The zipper pull-tab is made to look like a miniature breath mask."
	icon_state = "coatatmos"
	inhand_icon_state = "coatatmos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/atmos

/obj/item/clothing/head/hooded/winterhood/engineering/atmos
	desc = "A yellow and blue winter coat hood."
	icon_state = "hood_atmos"

// Cargo Technician
/obj/item/clothing/suit/hooded/wintercoat/cargo
	name = "cargo winter coat"
	desc = "A tan-and-grey winter coat. The zipper tab is a small pin resembling a MULE. It fills you with the warmth of a fierce independence."
	icon_state = "coatcargo"
	inhand_icon_state = "coatcargo"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/cargo
	allowed = list(/obj/item/storage/bag/mail)

/obj/item/clothing/head/hooded/winterhood/cargo
	desc = "A grey hood for a winter coat."
	icon_state = "hood_cargo"

// Quartermaster
/obj/item/clothing/suit/hooded/wintercoat/cargo/qm
	name = "quartermaster's winter coat"
	desc = "A dark brown winter coat that has a golden crate pin for its zipper pully."
	icon_state = "coatqm"
	inhand_icon_state = null
	hoodtype = /obj/item/clothing/head/hooded/winterhood/cargo/qm

/obj/item/clothing/suit/hooded/wintercoat/cargo/qm/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/melee/baton/telescopic,
	)

/obj/item/clothing/head/hooded/winterhood/cargo/qm
	desc = "A dark brown winter hood"
	icon_state = "hood_qm"

// Shaft Miner
/obj/item/clothing/suit/hooded/wintercoat/miner
	name = "mining winter coat"
	desc = "A dusty button up winter coat. The zipper tab looks like a tiny pickaxe."
	icon_state = "coatminer"
	inhand_icon_state = "coatminer"
	allowed = list(
		/obj/item/gun/energy/recharge/kinetic_accelerator,
		/obj/item/mining_scanner,
		/obj/item/pickaxe,
		/obj/item/resonator,
		/obj/item/storage/bag/ore,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/tank/internals,
	)
	armor_type = /datum/armor/wintercoat_miner
	hoodtype = /obj/item/clothing/head/hooded/winterhood/miner

/datum/armor/wintercoat_miner
	melee = 10

/obj/item/clothing/head/hooded/winterhood/miner
	desc = "A dusty winter coat hood."
	icon_state = "hood_miner"
	armor_type = /datum/armor/winterhood_miner

/datum/armor/winterhood_miner
	melee = 10

/obj/item/clothing/suit/hooded/wintercoat/custom
	name = "tailored winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs, with custom colors."
	greyscale_colors = "#ffffff#ffffff#808080#808080#808080#808080"
	greyscale_config = /datum/greyscale_config/winter_coats
	greyscale_config_worn = /datum/greyscale_config/winter_coats/worn
	hoodtype = /obj/item/clothing/head/hooded/winterhood/custom
	flags_1 = IS_PLAYER_COLORABLE_1

//In case colors are changed after initialization
/obj/item/clothing/suit/hooded/wintercoat/custom/set_greyscale(list/colors, new_config, new_worn_config, new_inhand_left, new_inhand_right)
	. = ..()
	if(hood)
		var/list/coat_colors = SSgreyscale.ParseColorString(greyscale_colors)
		var/list/new_coat_colors = coat_colors.Copy(1,4)
		hood.set_greyscale(new_coat_colors) //Adopt the suit's grayscale coloring for visual clarity.

//But also keep old method in case the hood is (re-)created later
/obj/item/clothing/suit/hooded/wintercoat/custom/MakeHood()
	. = ..()
	var/list/coat_colors = (SSgreyscale.ParseColorString(greyscale_colors))
	var/list/new_coat_colors = coat_colors.Copy(1,4)
	hood.set_greyscale(new_coat_colors) //Adopt the suit's grayscale coloring for visual clarity.

/obj/item/clothing/head/hooded/winterhood/custom
	name = "tailored winter coat hood"
	desc = "A heavy jacket hood made from 'synthetic' animal furs, with custom colors."
	greyscale_config = /datum/greyscale_config/winter_hoods
	greyscale_config_worn = /datum/greyscale_config/winter_hoods/worn
