// Wintercoat
/obj/item/clothing/suit/hooded/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon = 'icons/obj/clothing/suits/wintercoat.dmi'
	worn_icon = 'icons/mob/clothing/suits/wintercoat.dmi'
	icon_state = "wintercoat"
	inhand_icon_state = "wintercoat"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list(
		/obj/item/flashlight,
		/obj/item/lighter,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
)
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

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
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

// CentCom
/obj/item/clothing/suit/hooded/wintercoat/centcom
	name = "centcom winter coat"
	desc = "A luxurious winter coat woven in the bright green and gold colours of Central Command. It has a small pin in the shape of the Nanotrasen logo for a zipper."
	icon_state = "wintercoat_cc"
	inhand_icon_state = "wintercoat_cc"
	armor = list(MELEE = 35, BULLET = 40, LASER = 40, ENERGY = 50, BOMB = 35, BIO = 10, RAD = 10, FIRE = 10, ACID = 60)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/centcom

/obj/item/clothing/suit/hooded/wintercoat/centcom/Initialize()
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/centcom
	icon_state = "winterhood_cc"
	armor = list(MELEE = 35, BULLET = 40, LASER = 40, ENERGY = 50, BOMB = 35, BIO = 10, RAD = 10, FIRE = 10, ACID = 60)

// Captain
/obj/item/clothing/suit/hooded/wintercoat/captain
	name = "captain's winter coat"
	desc = "A luxurious winter coat, stuffed with the down of the endangered Uka bird and trimmed with genuine sable. The fabric is an indulgently soft micro-fiber,\
			and the deep ultramarine colour is only one that could be achieved with minute amounts of crystalline bluespace dust woven into the thread between the plectrums.\
			Extremely lavish, and extremely durable."
	icon_state = "wintercoat_cap"
	inhand_icon_state = "wintercoat_cap"
	armor = list(MELEE = 25, BULLET = 30, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, RAD = 0, FIRE = 0, ACID = 50)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/captain

/obj/item/clothing/suit/hooded/wintercoat/captain/Initialize()
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/captain
	icon_state = "winterhood_cap"
	armor = list(MELEE = 25, BULLET = 30, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, RAD = 0, FIRE = 0, ACID = 50)

// Head of Personnel
/obj/item/clothing/suit/hooded/wintercoat/hop
	name = "head of personnel's winter coat"
	desc = "A cozy winter coat, covered in thick fur. The breast features a proud yellow chevron, reminding everyone that you're the second banana."
	icon_state = "wintercoat_hop"
	inhand_icon_state = "wintercoat_hop"
	armor = list(MELEE = 10, BULLET = 15, LASER = 15, ENERGY = 25, BOMB = 10, BIO = 0, RAD = 0, FIRE = 0, ACID = 35)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hop

/obj/item/clothing/head/hooded/winterhood/hop
	icon_state = "hood_hop"

// Botanist
/obj/item/clothing/suit/hooded/wintercoat/hydro
	name = "hydroponics winter coat"
	desc = "A green and blue winter coat. The zipper tab looks like the flower from a member of Rosa Hesperrhodos, a pretty pink-and-white rose. The colours absolutely clash."
	icon_state = "wintercoat_hydro"
	inhand_icon_state = "wintercoat_hydro"
	allowed = list(
		/obj/item/cultivator,
		/obj/item/hatchet,
		/obj/item/lighter,
		/obj/item/plant_analyzer,
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/spray/pestspray,
		/obj/item/seeds,
		/obj/item/storage/bag/plants,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hydro

/obj/item/clothing/head/hooded/winterhood/hydro
	desc = "A green winter coat hood."
	icon_state = "hood_hydro"

// Janitor
/obj/item/clothing/suit/hooded/wintercoat/janitor
	name = "janitors winter coat"
	desc = "A purple-and-beige winter coat that smells of space cleaner."
	icon_state = "wintercoat_jani"
	inhand_icon_state = "wintercoat_jani"
	allowed = list(
		/obj/item/flashlight,
		/obj/item/grenade/chem_grenade,
		/obj/item/holosign_creator,
		/obj/item/key/janitor,
		/obj/item/lighter,
		/obj/item/lightreplacer,
		/obj/item/melee/flyswatter,
		/obj/item/paint/paint_remover,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/reagent_containers/spray,
		/obj/item/soap,
		/obj/item/storage/bag/trash,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/janitor

/obj/item/clothing/head/hooded/winterhood/janitor
	desc = "A purple hood that smells of space cleaner."
	icon_state = "winterhood_jani"

// Chef
/obj/item/clothing/suit/hooded/wintercoat/chef
	name = "\improper chef's winter coat"
	desc = "A white winter coat that somehow isn't stained yet, maybe it will be one day."
	icon_state = "wintercoat_chef"
	inhand_icon_state = "wintercoat_chef"
	allowed = list(
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/plant_analyzer,
		/obj/item/seeds,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/cultivator,
		/obj/item/reagent_containers/spray/pestspray,
		/obj/item/hatchet,
		/obj/item/storage/bag/plants,
		/obj/item/graft,
		/obj/item/secateurs,
		/obj/item/geneshears
)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/chef

/obj/item/clothing/head/hooded/winterhood/chef
	desc = "A hood just as clean as the main body, smells of oil anyways."
	icon_state = "winterhood_chef"

// Mime
/obj/item/clothing/suit/hooded/wintercoat/mime
	name = "\improper mime's winter coat"
	desc = "A black and white striped coat that the mimes made for themselves, who knows what this can do..."
	icon_state = "wintercoat_mime"
	inhand_icon_state = "wintercoat_mime"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/mime

/obj/item/clothing/head/hooded/winterhood/mime
	desc = "A black and white hood that is slightly disorienting to look at, so you try not to look at it."
	icon_state = "winterhood_mime"

// Clown
/obj/item/clothing/suit/hooded/wintercoat/clown
	name = "\improper clown's winter coat"
	desc = "A winter coat made specially made for the clowns from an unknown place. All clowns have one, but not all of them wear it."
	icon_state = "wintercoat_clown"
	inhand_icon_state = "wintercoat_clown"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/clown

/obj/item/clothing/head/hooded/winterhood/clown
	desc = "A bright yellow and red hood that screams 'honk' just by looking at it, tends to temporarily blind moths with just a glance."
	icon_state = "winterhood_clown"

// Chaplain
/obj/item/clothing/suit/hooded/wintercoat/chap
	name = "\improper chaplain's winter coat"
	desc = "Warm, stylish, approved by the space pope. Everything you need in a winter coat."
	icon_state = "wintercoat_chap"
	inhand_icon_state = "wintercoat_chap"
	allowed = list(
		/obj/item/storage/book/bible,
		/obj/item/nullrod,
		/obj/item/reagent_containers/food/drinks/bottle/holywater,
		/obj/item/storage/fancy/candle_box,
		/obj/item/candle,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman
)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/chap

/obj/item/clothing/head/hooded/winterhood/chap
	desc = "The pope didn't forget to bless the most important part of the coat, thus giving off a holy feel."
	icon_state = "winterhood_chap"

// Bartender
/obj/item/clothing/suit/hooded/wintercoat/bartender
	name = "\improper bartender's winter coat"
	desc = "This is a winter coat made to look like a butler's suit."
	icon_state = "wintercoat_bar"
	inhand_icon_state = "wintercoat_bar"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/bar

/obj/item/clothing/head/hooded/winterhood/bar
	desc = "A hood tends to not be included with a butler's suit, but looks good on a bartender anyways."
	icon_state = "winterhood_bar"

// Curator
/obj/item/clothing/suit/hooded/wintercoat/curator
	name = "\improper curator's winter coat"
	desc = "One look at this coat and you would think the wearer is part of a cult. After looking at the owner, you realize that it's probably true."
	icon_state = "wintercoat_curate"
	inhand_icon_state = "wintercoat_curate"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/curator

/obj/item/clothing/head/hooded/winterhood/curator
	desc = "A red hood that matches its coat well."
	icon_state = "winterhood_curate"

// Security Officer
/obj/item/clothing/suit/hooded/wintercoat/security
	name = "security winter coat"
	desc = "A red, armour-padded winter coat. It glitters with a mild ablative coating and a robust air of authority.  The zipper tab is a pair of jingly little handcuffs that get annoying after the first ten seconds."
	icon_state = "wintercoat_sec"
	inhand_icon_state = "wintercoat_sec"
	armor = list(MELEE = 25, BULLET = 15, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, RAD = 0, FIRE = 0, ACID = 45)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security

/obj/item/clothing/suit/hooded/wintercoat/security/Initialize()
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/security
	desc = "A red, armour-padded winter hood. Definitely not bulletproof, especially not the part where your face goes."
	icon_state = "winterhood_sec"
	armor = list(MELEE = 25, BULLET = 15, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, RAD = 0, FIRE = 0, ACID = 45)

// Head of Security
/obj/item/clothing/suit/hooded/wintercoat/security/hos
	name = "head of security's winter coat"
	desc = "A red, armour-padded winter coat, lovingly woven with a Kevlar interleave and reinforced with semi-ablative polymers and a silver azide fill material. The zipper tab looks like a tiny replica of Beepsky."
	icon_state = "wintercoat_hos"
	inhand_icon_state = "wintercoat_hos"
	armor = list(MELEE = 35, BULLET = 25, LASER = 40, ENERGY = 50, BOMB = 35, BIO = 0, RAD = 0, FIRE = 0, ACID = 55)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security/hos

/obj/item/clothing/head/hooded/winterhood/security/hos
	desc = "A red, armour-padded winter hood, lovingly woven with a Kevlar interleave. Definitely not bulletproof, especially not the part where your face goes."
	icon_state = "hood_hos"

// Detective
/obj/item/clothing/suit/hooded/wintercoat/security/det
	name = "\improper detective's winter coat"
	desc = "One day, a particularly cold and bored detective decided to defy the typical trenchcoated detective stereotype and commission a winter coat for himself. The resulting winter coat design became quite popular among detectives stationed in cold environments."
	icon_state = "wintercoat_det"
	inhand_icon_state = "wintercoat_det"
	armor = list(MELEE = 25, BULLET = 10, LASER = 25, ENERGY = 35, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 45)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security/det

/obj/item/clothing/head/hooded/winterhood/security/det
	desc = "The hood looks like it was taken straight from the security personell's coat. After a second glance, you see that it's a slightly darker red."
	icon_state = "winterhood_det"

// Lawyer
/obj/item/clothing/suit/hooded/wintercoat/security/lawyer
	name = "\improper lawyer's winter coat"
	desc = "This is a winter coat custom tailored for the lawyer."
	icon_state = "wintercoat_law"
	inhand_icon_state = "wintercoat_law"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security/law

/obj/item/clothing/head/hooded/winterhood/security/law
	desc = "Even though the coat isn't standard lawyer wear, the hood makes the entire outfit look decent for a lawyer to wear."
	icon_state = "winterhood_law"

// Medical Doctor
/obj/item/clothing/suit/hooded/wintercoat/medical
	name = "medical winter coat"
	desc = "An arctic white winter coat with a small blue caduceus instead of a plastic zipper tab. Snazzy."
	icon_state = "wintercoat_med"
	inhand_icon_state = "wintercoat_med"
	allowed = list(
		/obj/item/analyzer,
		/obj/item/dnainjector,
		/obj/item/flashlight/pen,
		/obj/item/healthanalyzer,
		/obj/item/lighter,
		/obj/item/melee/classic_baton/telescopic,
		/obj/item/paper,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical,
		/obj/item/sensor_device,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 40, RAD = 0, FIRE = 10, ACID = 20)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical

/obj/item/clothing/head/hooded/winterhood/medical
	desc = "A white winter coat hood."
	icon_state = "winterhood_med"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 40, RAD = 0, FIRE = 10, ACID = 20)

// Chief Medical Officer
/obj/item/clothing/suit/hooded/wintercoat/medical/cmo
	name = "chief medical officer's winter coat"
	desc = "A winter coat in a vibrant shade of blue with a small silver caduceus instead of a plastic zipper tab. The normal liner is replaced with an exceptionally thick, soft layer of fur."
	icon_state = "wintercoat_cmo"
	inhand_icon_state = "wintercoat_cmo"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 50, RAD = 0, FIRE = 20, ACID = 30)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/cmo

/obj/item/clothing/head/hooded/winterhood/medical/cmo
	desc = "A blue winter coat hood."
	icon_state = "hood_cmo"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 50, RAD = 0, FIRE = 20, ACID = 30)

// Chemist
/obj/item/clothing/suit/hooded/wintercoat/medical/chemistry
	name = "chemistry winter coat"
	desc = "A lab-grade winter coat made with acid resistant polymers. For the enterprising chemist who was exiled to a frozen wasteland on the go."
	icon_state = "wintercoat_chem"
	inhand_icon_state = "wintercoat_chem"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/chemistry

/obj/item/clothing/head/hooded/winterhood/medical/chemistry
	desc = "A white winter coat hood."
	icon_state = "winterhood_chem"

// Virologist
/obj/item/clothing/suit/hooded/wintercoat/medical/viro
	name = "virology winter coat"
	desc = "A white winter coat with green markings. Warm, but wont fight off the common cold or any other disease. Might make people stand far away from you in the hallway. The zipper tab looks like an oversized bacteriophage."
	icon_state = "wintercoat_viro"
	inhand_icon_state = "wintercoat_viro"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/viro

/obj/item/clothing/head/hooded/winterhood/medical/viro
	desc = "A white winter coat hood with green markings."
	icon_state = "hood_viro"

// Paramedic
/obj/item/clothing/suit/hooded/wintercoat/medical/paramedic
	name = "paramedic winter coat"
	desc = "A winter coat with blue markings. Warm, but probably won't protect from biological agents. For the cozy doctor on the go."
	icon_state = "wintercoat_para"
	inhand_icon_state = "wintercoat_para"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/paramedic

/obj/item/clothing/head/hooded/winterhood/medical/paramedic
	desc = "A white winter coat hood with blue markings."
	icon_state = "winterhood_para"

// Psychologist
/obj/item/clothing/suit/hooded/wintercoat/medical/psych
	name = "\improper psychologist's winter coat"
	desc = "A simple white coat with a brown trim, perfect for its job. Just a tad bit resistant to chemicals."
	icon_state = "wintercoat_psych"
	inhand_icon_state = "wintercoat_psych"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 10)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/psych

/obj/item/clothing/head/hooded/winterhood/medical/psych
	desc = "A brown hood that is also slightly resistant to chemicals, you should probably avoid them while wearing this anyways."
	icon_state = "winterhood_psych"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 10)

// Scientist
/obj/item/clothing/suit/hooded/wintercoat/science
	name = "science winter coat"
	desc = "A white winter coat with an outdated atomic model instead of a plastic zipper tab."
	icon_state = "wintercoat_sci"
	inhand_icon_state = "wintercoat_sci"
	allowed = list(
		/obj/item/analyzer,
		/obj/item/dnainjector,
		/obj/item/flashlight/pen,
		/obj/item/healthanalyzer,
		/obj/item/lighter,
		/obj/item/melee/classic_baton/telescopic,
		/obj/item/paper,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 20, ACID = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science
	species_exception = list(/datum/species/golem)

/obj/item/clothing/head/hooded/winterhood/science
	desc = "A white winter coat hood. This one will keep your brain warm. About as much as the others, really."
	icon_state = "winterhood_sci"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 20, ACID = 0)

// Research Director
/obj/item/clothing/suit/hooded/wintercoat/science/rd
	name = "research director's winter coat"
	desc = "A thick arctic winter coat with an outdated atomic model instead of a plastic zipper tab. Most in the know are heavily aware that Bohr's model of the atom was outdated by the time of the 1930s when the Heisenbergian and Schrodinger models were generally accepted for true. Nevertheless, we still see its use in anachronism, roleplaying, and, in this case, as a zipper tab. At least it should keep you warm on your ivory pillar."
	icon_state = "wintercoat_rd"
	inhand_icon_state = "wintercoat_rd"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 20, BIO = 0, RAD = 0, FIRE = 30, ACID = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/rd

/obj/item/clothing/head/hooded/winterhood/science/rd
	desc = "A white winter coat hood. It smells faintly of hair gel."
	icon_state = "hood_rd"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 20, BIO = 0, RAD = 0, FIRE = 30, ACID = 0)

// Roboticist
/obj/item/clothing/suit/hooded/wintercoat/science/robotics
	name = "robotics winter coat"
	desc = "A black winter coat with a badass flaming robotic skull for the zipper tab. This one has bright red designs and a few useless buttons."
	icon_state = "wintercoat_robo"
	inhand_icon_state = "wintercoat_robo"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/robotics

/obj/item/clothing/head/hooded/winterhood/science/robotics
	desc = "A black winter coat hood. You can pull it down over your eyes and pretend that you're an outdated, late 1980s interpretation of a futuristic mechanized police force. They'll fix you. They fix everything."
	icon_state = "winterhood_robo"

// Geneticist
/obj/item/clothing/suit/hooded/wintercoat/science/genetics
	name = "genetics winter coat"
	desc = "A white winter coat with a DNA helix for the zipper tab."
	icon_state = "wintercoat_gene"
	inhand_icon_state = "wintercoat_gene"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/genetics

/obj/item/clothing/head/hooded/winterhood/science/genetics
	desc = "A white winter coat hood. It's warm."
	icon_state = "winterhood_gene"

// Station Engineer
/obj/item/clothing/suit/hooded/wintercoat/engineering
	name = "engineering winter coat"
	desc = "A surprisingly heavy yellow winter coat with reflective orange stripes. It has a small wrench for its zipper tab, and the inside layer is covered with a radiation-resistant silver-nylon blend. Because you're worth it."
	icon_state = "wintercoat_engie"
	inhand_icon_state = "wintercoat_engie"
	allowed = list(
		/obj/item/analyzer,
		/obj/item/construction/rcd,
		/obj/item/flashlight,
		/obj/item/lighter,
		/obj/item/pipe_dispenser,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/t_scanner,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 10, FIRE = 20, ACID = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering
	species_exception = list(/datum/species/golem/uranium)

/obj/item/clothing/head/hooded/winterhood/engineering
	desc = "A yellow winter coat hood. Definitely not a replacement for a hard hat."
	icon_state = "winterhood_engie"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 10, FIRE = 20, ACID = 0)

// Chief Engineer
/obj/item/clothing/suit/hooded/wintercoat/engineering/ce
	name = "chief engineer's winter coat"
	desc = "A white winter coat with reflective green and yellow stripes. Stuffed with asbestos, treated with fire retardant PBDE, lined with a micro thin sheet of lead foil and snugly fitted to your body's measurements. This baby's ready to save you from anything except the thyroid cancer and systemic fibrosis you'll get from wearing it. The zipper tab is a tiny golden wrench."
	icon_state = "wintercoat_ce"
	inhand_icon_state = "wintercoat_ce"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 20, FIRE = 30, ACID = 10)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/ce

/obj/item/clothing/head/hooded/winterhood/engineering/ce
	desc = "A white winter coat hood. Feels surprisingly heavy. The tag says that it's not child safe."
	icon_state = "hood_ce"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 20, FIRE = 30, ACID = 10)

// Atmospherics Technician
/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	desc = "A yellow and blue winter coat. The zipper pull-tab is made to look like a miniature breath mask."
	icon_state = "wintercoat_atmos"
	inhand_icon_state = "wintercoat_atmos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/atmos

/obj/item/clothing/head/hooded/winterhood/engineering/atmos
	desc = "A yellow and blue winter coat hood."
	icon_state = "hood_atmos"

// Cargo Technician
/obj/item/clothing/suit/hooded/wintercoat/cargo
	name = "cargo winter coat"
	desc = "A tan-and-grey winter coat. The zipper tab is a small pin resembling a MULE. It fills you with the warmth of a fierce independence."
	icon_state = "wintercoat_cargo"
	inhand_icon_state = "wintercoat_cargo"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/cargo

/obj/item/clothing/head/hooded/winterhood/cargo
	desc = "A grey hood for a winter coat."
	icon_state = "hood_cargo"

// Quartermaster
/obj/item/clothing/suit/hooded/wintercoat/qm
	name = "quartermaster's winter coat"
	desc = "A dark brown winter coat that has a golden crate pin for its zipper pully."
	icon_state = "wintercoat_qm"
	inhand_icon_state = "wintercoat_qm"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/qm

/obj/item/clothing/head/hooded/winterhood/qm
	desc = "A dark brown winter hood"
	icon_state = "hood_qm"

// Shaft Miner
/obj/item/clothing/suit/hooded/wintercoat/miner
	name = "mining winter coat"
	desc = "A dusty button up winter coat. The zipper tab looks like a tiny pickaxe."
	icon_state = "wintercoat_miner"
	inhand_icon_state = "wintercoat_miner"
	allowed = list(
		/obj/item/flashlight,
		/obj/item/lighter,
		/obj/item/pickaxe,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
)
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/miner

/obj/item/clothing/head/hooded/winterhood/miner
	desc = "A dusty winter coat hood."
	icon_state = "hood_miner"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
