/obj/structure/shipping_container
	name = "shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is blank, offering no clue as to its contents."
	icon = 'icons/obj/fluff/containers.dmi'
	icon_state = "blank"
	max_integrity = 1000
	bound_width = 96
	bound_height = 32
	density = TRUE
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE

/obj/structure/shipping_container/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/seethrough, SEE_THROUGH_MAP_SHIPPING_CONTAINER)

/obj/structure/shipping_container/amsco
	name = "\improper AMSCO shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Amundsen-Scott, and so is probably carrying prospecting gear."
	icon_state = "amsco"

/obj/structure/shipping_container/blue
	icon_state = "blue"

/obj/structure/shipping_container/conarex
	name = "\improper Conarex Aeronautics shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Conarex Aeronautics, and is probably carrying spacecraft parts (or a bribery scandal) as a result."
	icon_state = "conarex"

/obj/structure/shipping_container/defaced
	name = "defaced shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one's covered in tasteful graffiti."
	icon_state = "defaced"

/obj/structure/shipping_container/deforest
	name = "\improper Nanotrasen-DeForest shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Nanotrasen-DeForest, and so is probably carrying medical supplies."
	icon_state = "deforest"

/obj/structure/shipping_container/great_northern
	name = "\improper Great Northern shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Great Northern, and is probably carrying farming equipment."
	icon_state = "great_northern"

/obj/structure/shipping_container/green
	icon_state = "green"

/obj/structure/shipping_container/kahraman
	name = "\improper Kahraman Heavy Industry shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Kahraman, and is reinforced for carrying mining equipment."
	icon_state = "kahraman"

/obj/structure/shipping_container/kahraman/alt
	icon_state = "kahraman_alt"

/obj/structure/shipping_container/kosmologistika
	name = "\improper Kosmologistika shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Kosmologistika, the state logistics company owned and operated by the SSC."
	icon_state = "kosmologistika"

/obj/structure/shipping_container/magenta
	icon_state = "magenta"

/obj/structure/shipping_container/nakamura
	name = "\improper Nakamura Engineering shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Nakamura, presumably for transporting tools or heavy industrial equipment."
	icon_state = "nakamura"

/obj/structure/shipping_container/nanotrasen
	name = "\improper Nanotrasen shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one prominently features Nanotrasen's logo, and so presumably could be carrying anything."
	icon_state = "nanotrasen"

/obj/structure/shipping_container/ntfid
	name = "\improper Nanotrasen Futures and Innovation shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from NTFID: Nanotrasen's research and development subdivision."
	icon_state = "ntfid"

/obj/structure/shipping_container/ntfid/defaced
	desc = "A standard-measure shipping container for bulk transport of goods. Someone clearly has a bone to pick with NTFID."
	icon_state = "ntfid_defaced"

/obj/structure/shipping_container/nthi
	name = "\improper Nanotrasen Heavy Industries shipping container"
	desc = "A standard-measure shipping container for bulk transport of common metals and minerals. This one is from NTHI: Nanotrasen's mining and refining subdivision."
	icon_state = "nthi"

/obj/structure/shipping_container/nthi/minor
	desc = "A standard-measure shipping container for bulk transport of rare metals and minerals. This one is from NTHI: Nanotrasen's mining and refining subdivision."
	icon_state = "nthi_minor"

/obj/structure/shipping_container/nthi/precious
	desc = "A standard-measure shipping container for bulk transport of precious metals and minerals. This one is from NTHI: Nanotrasen's mining and refining subdivision."
	icon_state = "nthi_precious"

/obj/structure/shipping_container/orange
	icon_state = "orange"

/obj/structure/shipping_container/purple
	icon_state = "purple"

/obj/structure/shipping_container/red
	icon_state = "red"

/obj/structure/shipping_container/sunda
	name = "\improper Sunda Galaksi shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Sunda Galaksi, and could be carrying just about anything."
	icon_state = "sunda"

/obj/structure/shipping_container/vitezstvi
	name = "\improper Vítězství Arms shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Vítězství Arms, proudly proclaiming that Vítězství weapons mean victory."
	icon_state = "vitezstvi"

/obj/structure/shipping_container/vitezstvi/flags
	icon_state = "vitezstvi_flags"

/obj/structure/shipping_container/yellow
	icon_state = "yellow"

//Syndies
/obj/structure/shipping_container/biosustain
	name = "\improper Biosustain shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Biosustain, and so it's probably carrying seeds or farming equipment."
	icon_state = "biosustain"

/obj/structure/shipping_container/cybersun
	name = "\improper Cybersun Industries shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one prominently features Cybersun's logo, and so presumably could be carrying almost anything."
	icon_state = "cybersun"

/obj/structure/shipping_container/cybersun/defaced
	desc = "A standard-measure shipping container for bulk transport of goods. This one originally featured Cybersun's logo, before it was painted over by an enterprising artist."
	icon_state = "cybersun_defaced"

/obj/structure/shipping_container/donk_co
	name = "\improper Donk Co. shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Donk Co. and so could be carrying just about anything- although it's probably just Donk Pockets."
	icon_state = "donk_co"

/obj/structure/shipping_container/exagon
	name = "\improper Exagon-Ichikawa shipping container"
	desc = "A standard-measure shipping container for bulk transport of common metals and minerals. This one is from Exagon-Ichikawa, Cybersun Industries' mining and refining subdivision."
	icon_state = "exagon"

/obj/structure/shipping_container/exagon/minor
	desc = "A standard-measure shipping container for bulk transport of rare metals and minerals. This one is from Exagon-Ichikawa, Cybersun Industries' mining and refining subdivision."
	icon_state = "exagon_minor"

/obj/structure/shipping_container/exagon/precious
	desc = "A standard-measure shipping container for bulk transport of precious metals and minerals. This one is from Exagon-Ichikawa, Cybersun Industries' mining and refining subdivision."
	icon_state = "exagon_precious"

/obj/structure/shipping_container/gorlex
	name = "\improper Gorlex Securities shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Gorlex Securities, and is probably carrying their primary export: war crimes."
	icon_state = "gorlex"

/obj/structure/shipping_container/gorlex/red
	icon_state = "gorlex_red"

/obj/structure/shipping_container/interdyne
	name = "\improper Interdyne shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Interdyne, a private pharmaceutical company. Probably carrying medical or research supplies, probably."
	icon_state = "interdyne"

/obj/structure/shipping_container/oms
	name = "\improper OMS shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is from Cybersun's medical subdivision OMS (Osaka Medical Systems), and is probably carrying medical cybernetics or somesuch."
	icon_state = "oms"

/obj/structure/shipping_container/tiger_coop
	name = "suspicious shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This previously blank container has been spray-painted with the insignia of the Tiger Cooperative, meaning whatever's inside is probably dangerous."
	icon_state = "tiger_coop"

/obj/structure/shipping_container/tiger_coop/text
	icon_state = "tiger_coop_text"

// REEFER CONTAINERS (REFRIGERATED)
/obj/structure/shipping_container/reefer
	name = "reefer shipping container"
	desc = "A standard-measure reefer shipping container for bulk transport of refrigerated goods. This one is blank, offering no clue as to its contents."
	icon_state = "blank_reefer"

/obj/structure/shipping_container/reefer/deforest
	name = "\improper Nanotrasen-DeForest reefer shipping container"
	desc = "A standard-measure reefer shipping container for bulk transport of refrigerated goods. This one is from Nanotrasen-DeForest, and is probably carrying temperature sensitive biological material."
	icon_state = "deforest_reefer"

/obj/structure/shipping_container/reefer/biosustain
	name = "\improper Biosustain reefer shipping container"
	desc = "A standard-measure reefer shipping container for bulk transport of refrigerated goods. This one is from Biosustain, and so it's probably carrying GMOs or agrichemicals."
	icon_state = "biosustain_reefer"

/obj/structure/shipping_container/reefer/interdyne
	name = "\improper Interdyne reefer shipping container"
	desc = "A standard-measure reefer shipping container for bulk transport of refrigerated goods. This one is from Interdyne, a private pharmaceutical company, and is probably carrying organs or blood, maybe both."
	icon_state = "interdyne_reefer"

// GAS TANK
/obj/structure/shipping_container/gas
	name = "bulk gas tank"
	desc = "A standard-measure gas tank for bulk transport of gases. This one is rather irresponsibly blank, offering no clue as to its contents."
	icon_state = "blank_gas"

/obj/structure/shipping_container/gas/apda
	name = "\improper APdA S.p.A. bulk helium tank"
	desc = "A standard-measure gas tank for bulk transport of gases. This one is from Associato Petrochimico dell'Adriatico, containing their second most important export: helium-3 for fuel use."
	icon_state = "apda_gas_helium"

/obj/structure/shipping_container/gas/apda/hydrogen
	name = "\improper APdA S.p.A. bulk hydrogen tank"
	desc = "A standard-measure gas tank for bulk transport of gases. This one is from Associato Petrochimico dell'Adriatico, containing their most important export: hydrogen for fuel use."
	icon_state = "apda_gas_hydrogen"

/obj/structure/shipping_container/gas/nthi
	name = "\improper NTHI bulk plasma tank"
	desc = "A standard-measure gas tank for bulk transport of gases. This one is from NTHI, Nanotrasen's mining and refining subdivision, and contains high-grade gaseous plasma from the Spinward Sector."
	icon_state = "nthi_gas_plasma"

/obj/structure/shipping_container/gas/exagon
	name = "\improper Exagon-Ichikawa bulk plasma tank"
	desc = "A standard-measure gas tank for bulk transport of gases. This one is from Exagon-Ichikawa, Cybersun Industries' mining and refining subdivision, and contains gaseous plasma most likely sourced from Mars."
	icon_state = "exagon_gas_plasma"
