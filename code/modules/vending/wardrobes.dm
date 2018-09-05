/obj/item/vending_refill/wardrobe
	icon_state = "refill_clothes"

/obj/machinery/vending/wardrobe/sec_wardrobe
	name = "\improper SecDrobe"
	desc = "A vending machine for security and security-related clothing!"
	icon_state = "secdrobe"
	product_ads = "Beat perps in style!;It's red so you can't see the blood!;You have the right to be fashionable!;Now you can be the fashion police you always wanted to be!"
	vend_reply = "Thank you for using the SecDrobe!"
	products = list(/obj/item/clothing/suit/hooded/wintercoat/security = 3,
					/obj/item/storage/backpack/security = 3,
					/obj/item/storage/backpack/satchel/sec = 3,
					/obj/item/storage/backpack/duffelbag/sec = 3,
					/obj/item/clothing/under/rank/security = 3,
					/obj/item/clothing/shoes/jackboots = 3,
					/obj/item/clothing/head/beret/sec = 3,
					/obj/item/clothing/head/soft/sec = 3,
					/obj/item/clothing/mask/bandana/red = 3,
					/obj/item/clothing/under/rank/security/skirt = 3,
					/obj/item/clothing/under/rank/security/grey = 3,
					/obj/item/clothing/under/pants/khaki = 3,
					/obj/item/clothing/under/rank/security/blueshirt = 3)
	premium = list(/obj/item/clothing/under/rank/security/navyblue = 3,
					/obj/item/clothing/suit/security/officer = 3,
					/obj/item/clothing/head/beret/sec/navyofficer = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/sec_wardrobe

/obj/item/vending_refill/wardrobe/sec_wardrobe
	machine_name = "SecDrobe"

/obj/machinery/vending/wardrobe/medi_wardrobe
	name = "\improper MediDrobe"
	desc = "A vending machine rumoured to be capable of dispensing clothing for medical personnel."
	icon_state = "medidrobe"
	product_ads = "Make those blood stains look fashionable!!"
	vend_reply = "Thank you for using the MediDrobe!"
	products = list(/obj/item/clothing/accessory/pocketprotector = 4,
					/obj/item/storage/backpack/duffelbag/med = 4,
					/obj/item/storage/backpack/medic = 4,
					/obj/item/storage/backpack/satchel/med = 4,
					/obj/item/clothing/suit/hooded/wintercoat/medical = 4,
					/obj/item/clothing/under/rank/nursesuit = 4,
					/obj/item/clothing/head/nursehat = 4,
					/obj/item/clothing/under/rank/medical/blue = 4,
					/obj/item/clothing/under/rank/medical/green = 4,
					/obj/item/clothing/under/rank/medical/purple = 4,
					/obj/item/clothing/under/rank/medical = 4,
					/obj/item/clothing/suit/toggle/labcoat = 4,
					/obj/item/clothing/suit/toggle/labcoat/emt = 4,
					/obj/item/clothing/shoes/sneakers/white = 4,
					/obj/item/clothing/head/soft/emt = 4,
					/obj/item/clothing/suit/apron/surgical = 4,
					/obj/item/clothing/mask/surgical = 4)
	refill_canister = /obj/item/vending_refill/wardrobe/medi_wardrobe

/obj/item/vending_refill/wardrobe/medi_wardrobe
	machine_name = "MediDrobe"

/obj/machinery/vending/wardrobe/engi_wardrobe
	name = "EngiDrobe"
	desc = "A vending machine renowned for vending industrial grade clothing."
	icon_state = "engidrobe"
	product_ads = "Guaranteed to protect your feet from industrial accidents!;Afraid of radiation? Then wear yellow!"
	vend_reply = "Thank you for using the EngiDrobe!"
	products = list(/obj/item/clothing/accessory/pocketprotector = 3,
					/obj/item/storage/backpack/duffelbag/engineering = 3,
					/obj/item/storage/backpack/industrial = 3,
					/obj/item/storage/backpack/satchel/eng = 3,
					/obj/item/clothing/suit/hooded/wintercoat/engineering = 3,
					/obj/item/clothing/under/rank/engineer = 3,
					/obj/item/clothing/suit/hazardvest = 3,
					/obj/item/clothing/shoes/workboots = 3,
					/obj/item/clothing/head/hardhat = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/engi_wardrobe

/obj/item/vending_refill/wardrobe/engi_wardrobe
	machine_name = "EngiDrobe"

/obj/machinery/vending/wardrobe/atmos_wardrobe
	name = "AtmosDrobe"
	desc = "This relatively unknown vending machine delivers clothing for Atmospherics Technicians, an equally unknown job."
	icon_state = "atmosdrobe"
	product_ads = "Get your inflammable clothing right here!!!"
	vend_reply = "Thank you for using the AtmosDrobe!"
	products = list(/obj/item/clothing/accessory/pocketprotector = 2,
					/obj/item/storage/backpack/duffelbag/engineering = 2,
					/obj/item/storage/backpack/satchel/eng = 2,
					/obj/item/storage/backpack/industrial = 2,
					/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos = 3,
					/obj/item/clothing/under/rank/atmospheric_technician = 3,
					/obj/item/clothing/shoes/sneakers/black = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/atmos_wardrobe

/obj/item/vending_refill/wardrobe/atmos_wardrobe
	machine_name = "AtmosDrobe"

/obj/machinery/vending/wardrobe/cargo_wardrobe
	name = "CargoDrobe"
	desc = "A highly advanced vending machine for buying cargo related clothing for free."
	icon_state = "cargodrobe"
	product_ads = "Upgraded Assistant Style! Pick yours today!;These shorts are comfy and easy to wear, get yours now!"
	vend_reply = "Thank you for using the CargoDrobe!"
	products = list(/obj/item/clothing/suit/hooded/wintercoat/cargo = 3,
					/obj/item/clothing/under/rank/cargotech = 3,
					/obj/item/clothing/shoes/sneakers/black = 3,
					/obj/item/clothing/gloves/fingerless = 3,
					/obj/item/clothing/head/soft = 3,
					/obj/item/radio/headset/headset_cargo = 3)
	premium = list(/obj/item/clothing/under/rank/miner = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/cargo_wardrobe

/obj/item/vending_refill/wardrobe/cargo_wardrobe
	machine_name = "CargoDrobe"

/obj/machinery/vending/wardrobe/robo_wardrobe
	name = "RoboDrobe"
	desc = "A vending machine designed to dispense clothing known only to roboticists."
	icon_state = "robodrobe"
	product_ads = "You turn me TRUE, use defines!;0110001101101100011011110111010001101000011001010111001101101000011001010111001001100101"
	vend_reply = "Thank you for using the RoboDrobe!"
	products = list(/obj/item/clothing/glasses/hud/diagnostic = 2,
					/obj/item/clothing/under/rank/roboticist = 2,
					/obj/item/clothing/suit/toggle/labcoat = 2,
					/obj/item/clothing/shoes/sneakers/black = 2,
					/obj/item/clothing/gloves/fingerless = 2,
					/obj/item/clothing/head/soft/black = 2,
					/obj/item/clothing/mask/bandana/skull = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/robo_wardrobe

/obj/item/vending_refill/wardrobe/robo_wardrobe
	machine_name = "RoboDrobe"

/obj/machinery/vending/wardrobe/science_wardrobe
	name = "SciDrobe"
	desc = "A simple vending machine suitable to dispense well tailored science clothing. Endorsed by Space Cubans."
	icon_state = "scidrobe"
	product_ads = "Longing for the smell of plasma burnt flesh? Buy your science clothing now!;Made with 10% Auxetics, so you don't have to worry about losing your arm!"
	vend_reply = "Thank you for using the SciDrobe!"
	products = list(/obj/item/clothing/accessory/pocketprotector = 3,
					/obj/item/storage/backpack/science = 3,
					/obj/item/storage/backpack/satchel/tox = 3,
					/obj/item/clothing/suit/hooded/wintercoat/science = 3,
					/obj/item/clothing/under/rank/scientist = 3,
					/obj/item/clothing/suit/toggle/labcoat/science = 3,
					/obj/item/clothing/shoes/sneakers/white = 3,
					/obj/item/radio/headset/headset_sci = 3,
					/obj/item/clothing/mask/gas = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/science_wardrobe

/obj/item/vending_refill/wardrobe/science_wardrobe
	machine_name = "SciDrobe"

/obj/machinery/vending/wardrobe/hydro_wardrobe
	name = "Hydrobe"
	desc = "A machine with a catchy name. It dispenses botany related clothing and gear."
	icon_state = "hydrobe"
	product_ads = "Do you love soil? Then buy our clothes!;Get outfits to match your green thumb here!"
	vend_reply = "Thank you for using the Hydrobe!"
	products = list(/obj/item/storage/backpack/botany = 2,
					/obj/item/storage/backpack/satchel/hyd = 2,
					/obj/item/clothing/suit/hooded/wintercoat/hydro = 2,
					/obj/item/clothing/suit/apron = 2,
					/obj/item/clothing/suit/apron/overalls = 3,
					/obj/item/clothing/under/rank/hydroponics = 3,
					/obj/item/clothing/mask/bandana = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/hydro_wardrobe

/obj/item/vending_refill/wardrobe/hydro_wardrobe
	machine_name = "HyDrobe"

/obj/machinery/vending/wardrobe/curator_wardrobe
	name = "CuraDrobe"
	desc = "A lowstock vendor only capable of vending clothing for curators and librarians."
	icon_state = "curadrobe"
	product_ads = "Our clothes are endorsed by treasure hunters everywhere!"
	vend_reply = "Thank you for using the CuraDrobe!"
	products = list(/obj/item/clothing/head/fedora/curator = 1,
					/obj/item/clothing/suit/curator = 1,
					/obj/item/clothing/under/rank/curator/treasure_hunter = 1,
					/obj/item/clothing/shoes/workboots/mining = 1,
					/obj/item/storage/backpack/satchel/explorer = 1,
					/obj/item/storage/bag/books = 1)
	refill_canister = /obj/item/vending_refill/wardrobe/curator_wardrobe

/obj/item/vending_refill/wardrobe/curator_wardrobe
	machine_name = "CuraDrobe"

/obj/machinery/vending/wardrobe/bar_wardrobe
	name = "BarDrobe"
	desc = "A stylish vendor to dispense the most stylish bar clothing!"
	icon_state = "bardrobe"
	product_ads = "Guaranteed to prevent stains from spilled drinks!"
	vend_reply = "Thank you for using the BarDrobe!"
	products = list(/obj/item/clothing/head/that = 2,
					/obj/item/radio/headset/headset_srv = 2,
					/obj/item/clothing/under/sl_suit = 2,
					/obj/item/clothing/under/rank/bartender = 2,
					/obj/item/clothing/under/rank/bartender/purple = 2,
					/obj/item/clothing/accessory/waistcoat = 2,
					/obj/item/clothing/suit/apron/purple_bartender = 2,
					/obj/item/clothing/head/soft/black = 2,
					/obj/item/clothing/shoes/sneakers/black = 2,
					/obj/item/reagent_containers/glass/rag = 2,
					/obj/item/storage/box/beanbag = 1,
					/obj/item/clothing/suit/armor/vest/alt = 1,
					/obj/item/circuitboard/machine/dish_drive = 1,
					/obj/item/clothing/glasses/sunglasses/reagent = 1,
					/obj/item/clothing/neck/petcollar = 1,
					/obj/item/storage/belt/bandolier = 1)
	refill_canister = /obj/item/vending_refill/wardrobe/bar_wardrobe

/obj/item/vending_refill/wardrobe/bar_wardrobe
	machine_name = "BarDrobe"

/obj/machinery/vending/wardrobe/chef_wardrobe
	name = "ChefDrobe"
	desc = "This vending machine might not dispense meat, but it certainly dispenses chef related clothing."
	icon_state = "chefdrobe"
	product_ads = "Our clothes are guaranteed to protect you from food splatters!"
	vend_reply = "Thank you for using the ChefDrobe!"
	products = list(/obj/item/clothing/under/waiter = 2,
					/obj/item/radio/headset/headset_srv = 2,
					/obj/item/clothing/accessory/waistcoat = 2,
					/obj/item/clothing/suit/apron/chef = 3,
					/obj/item/clothing/head/soft/mime = 2,
					/obj/item/storage/box/mousetraps = 2,
					/obj/item/circuitboard/machine/dish_drive = 1,
					/obj/item/clothing/suit/toggle/chef = 1,
					/obj/item/clothing/under/rank/chef = 1,
					/obj/item/clothing/head/chefhat = 1,
					/obj/item/reagent_containers/glass/rag = 1)
	refill_canister = /obj/item/vending_refill/wardrobe/chef_wardrobe

/obj/item/vending_refill/wardrobe/chef_wardrobe
	machine_name = "ChefDrobe"

/obj/machinery/vending/wardrobe/jani_wardrobe
	name = "JaniDrobe"
	desc = "A self cleaning vending machine capable of dispensing clothing for janitors."
	icon_state = "janidrobe"
	product_ads = "Come and get your janitorial clothing, now endorsed by lizard janitors everywhere!"
	vend_reply = "Thank you for using the JaniDrobe!"
	products = list(/obj/item/clothing/under/rank/janitor = 1,
					/obj/item/cartridge/janitor = 1,
					/obj/item/clothing/gloves/color/black = 1,
					/obj/item/clothing/head/soft/purple = 1,
					/obj/item/paint/paint_remover = 1,
					/obj/item/melee/flyswatter = 1,
					/obj/item/flashlight = 1,
					/obj/item/caution = 6,
					/obj/item/holosign_creator = 1,
					/obj/item/lightreplacer = 1,
					/obj/item/soap = 1,
					/obj/item/storage/bag/trash = 1,
					/obj/item/clothing/shoes/galoshes = 1,
					/obj/item/watertank/janitor = 1,
					/obj/item/storage/belt/janitor = 1)
	refill_canister = /obj/item/vending_refill/wardrobe/jani_wardrobe

/obj/item/vending_refill/wardrobe/jani_wardrobe
	machine_name = "JaniDrobe"

/obj/machinery/vending/wardrobe/law_wardrobe
	name = "LawDrobe"
	desc = "Objection! This wardrobe dispenses the rule of law... and lawyer clothing."
	icon_state = "lawdrobe"
	product_ads = "OBJECTION! Get the rule of law for yourself!"
	vend_reply = "Thank you for using the LawDrobe!"
	products = list(/obj/item/clothing/under/lawyer/female = 1,
					/obj/item/clothing/under/lawyer/black = 1,
					/obj/item/clothing/under/lawyer/red = 1,
					/obj/item/clothing/under/lawyer/bluesuit = 1,
					/obj/item/clothing/suit/toggle/lawyer = 1,
					/obj/item/clothing/under/lawyer/purpsuit = 1,
					/obj/item/clothing/suit/toggle/lawyer/purple = 1,
					/obj/item/clothing/under/lawyer/blacksuit = 1,
					/obj/item/clothing/suit/toggle/lawyer/black = 1,
					/obj/item/clothing/shoes/laceup = 2,
					/obj/item/clothing/accessory/lawyers_badge = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/law_wardrobe

/obj/item/vending_refill/wardrobe/law_wardrobe
	machine_name = "LawDrobe"

/obj/machinery/vending/wardrobe/chap_wardrobe
	name = "ChapDrobe"
	desc = "This most blessed and holy machine vends clothing only suitable for chaplains to gaze upon."
	icon_state = "chapdrobe"
	product_ads = "Are you being bothered by cultists or pesky revenants? Then come and dress like the holy man!;Clothes for men of the cloth!"
	vend_reply = "Thank you for using the ChapDrobe!"
	products = list(/obj/item/holybeacon = 1,
					/obj/item/storage/backpack/cultpack = 1,
					/obj/item/clothing/accessory/pocketprotector/cosmetology = 1,
					/obj/item/clothing/under/rank/chaplain = 1,
					/obj/item/clothing/shoes/sneakers/black = 1,
					/obj/item/clothing/suit/nun = 1,
					/obj/item/clothing/head/nun_hood = 1,
					/obj/item/clothing/suit/holidaypriest = 1,
					/obj/item/storage/fancy/candle_box = 2)
	contraband = list(/obj/item/toy/plush/plushvar = 1,
					/obj/item/toy/plush/narplush = 1)				
	refill_canister = /obj/item/vending_refill/wardrobe/chap_wardrobe

/obj/item/vending_refill/wardrobe/chap_wardrobe
	machine_name = "ChapDrobe"

/obj/machinery/vending/wardrobe/chem_wardrobe
	name = "ChemDrobe"
	desc = "A vending machine for dispensing chemistry related clothing."
	icon_state = "chemdrobe"
	product_ads = "Our clothes are 0.5% more resistant to acid spills! Get yours now!"
	vend_reply = "Thank you for using the ChemDrobe!"
	products = list(/obj/item/clothing/under/rank/chemist = 2,
					/obj/item/clothing/shoes/sneakers/white = 2,
					/obj/item/clothing/suit/toggle/labcoat/chemist = 2,
					/obj/item/storage/backpack/chemistry = 2,
					/obj/item/storage/backpack/satchel/chem = 2,
					/obj/item/storage/bag/chemistry = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/chem_wardrobe

/obj/item/vending_refill/wardrobe/chem_wardrobe
	machine_name = "ChemDrobe"

/obj/machinery/vending/wardrobe/gene_wardrobe
	name = "GeneDrobe"
	desc = "A machine for dispensing clothing related to genetics."
	icon_state = "genedrobe"
	product_ads = "Perfect for the mad scientist in you!"
	vend_reply = "Thank you for using the GeneDrobe!"
	products = list(/obj/item/clothing/under/rank/geneticist = 2,
					/obj/item/clothing/shoes/sneakers/white = 2,
					/obj/item/clothing/suit/toggle/labcoat/genetics = 2,
					/obj/item/storage/backpack/genetics = 2,
					/obj/item/storage/backpack/satchel/gen = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/gene_wardrobe

/obj/item/vending_refill/wardrobe/gene_wardrobe
	machine_name = "GeneDrobe"

/obj/machinery/vending/wardrobe/viro_wardrobe
	name = "ViroDrobe"
	desc = "An unsterilized machine for dispending virology related clothing."
	icon_state = "virodrobe"
	product_ads = " Viruses getting you down? Then upgrade to sterilized clothing today!"
	vend_reply = "Thank you for using the ViroDrobe"
	products = list(/obj/item/clothing/under/rank/virologist = 2,
					/obj/item/clothing/shoes/sneakers/white = 2,
					/obj/item/clothing/suit/toggle/labcoat/virologist = 2,
					/obj/item/clothing/mask/surgical = 2,
					/obj/item/storage/backpack/virology = 2,
					/obj/item/storage/backpack/satchel/vir = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/viro_wardrobe

/obj/item/vending_refill/wardrobe/viro_wardrobe
	machine_name = "ViroDrobe"
