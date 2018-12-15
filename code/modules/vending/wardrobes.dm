/obj/item/vending_refill/wardrobe
	icon_state = "refill_clothes"

/obj/machinery/vending/wardrobe
	default_price = 50
	extra_price = 75
	payment_department = NO_FREEBIES

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
	payment_department = ACCOUNT_SEC

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
	payment_department = ACCOUNT_MED
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
					/obj/item/clothing/under/rank/engineer/hazard = 3,
					/obj/item/clothing/suit/hazardvest = 3,
					/obj/item/clothing/shoes/workboots = 3,
					/obj/item/clothing/head/hardhat = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/engi_wardrobe
	payment_department = ACCOUNT_ENG
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
	payment_department = ACCOUNT_ENG
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
	payment_department = ACCOUNT_CAR
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
	payment_department = ACCOUNT_SCI
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
	payment_department = ACCOUNT_SCI
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
					/obj/item/clothing/mask/bandana = 3,
					/obj/item/clothing/accessory/armband/hydro = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/hydro_wardrobe
	payment_department = ACCOUNT_SRV
/obj/item/vending_refill/wardrobe/hydro_wardrobe
	machine_name = "HyDrobe"

/obj/machinery/vending/wardrobe/curator_wardrobe
	name = "CuraDrobe"
	desc = "A lowstock vendor only capable of vending clothing for curators and librarians."
	icon_state = "curadrobe"
	product_ads = "Glasses for your eyes and literature for your soul, Curadrobe has it all!; Impress & enthrall your library guests with Curadrobe's extended line of pens!"
	vend_reply = "Thank you for using the CuraDrobe!"
	products = list(/obj/item/pen = 4,
					/obj/item/pen/red = 2,
					/obj/item/pen/blue = 2,
					/obj/item/pen/fourcolor = 1,
					/obj/item/pen/fountain = 2,
					/obj/item/clothing/accessory/pocketprotector = 2,
					/obj/item/storage/backpack/satchel/explorer = 1,
					/obj/item/clothing/glasses/regular = 2,
					/obj/item/clothing/glasses/regular/jamjar = 1,
					/obj/item/storage/bag/books = 1)
	refill_canister = /obj/item/vending_refill/wardrobe/curator_wardrobe
	payment_department = ACCOUNT_CIV
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
	payment_department = ACCOUNT_SRV
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
					/obj/item/reagent_containers/glass/rag = 1,
					/obj/item/clothing/suit/hooded/wintercoat = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/chef_wardrobe
	payment_department = ACCOUNT_SRV
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
					/obj/item/soap/nanotrasen = 1,
					/obj/item/storage/bag/trash = 1,
					/obj/item/clothing/shoes/galoshes = 1,
					/obj/item/watertank/janitor = 1,
					/obj/item/storage/belt/janitor = 1)
	refill_canister = /obj/item/vending_refill/wardrobe/jani_wardrobe
	payment_department = ACCOUNT_SRV
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
	payment_department = ACCOUNT_CIV
/obj/item/vending_refill/wardrobe/law_wardrobe
	machine_name = "LawDrobe"

/obj/machinery/vending/wardrobe/chap_wardrobe
	name = "ChapDrobe"
	desc = "This most blessed and holy machine vends clothing only suitable for chaplains to gaze upon."
	icon_state = "chapdrobe"
	product_ads = "Are you being bothered by cultists or pesky revenants? Then come and dress like the holy man!;Clothes for men of the cloth!"
	vend_reply = "Thank you for using the ChapDrobe!"
	products = list(/obj/item/choice_beacon/holy = 1,
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
	payment_department = ACCOUNT_CIV
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
	payment_department = ACCOUNT_MED
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
	payment_department = ACCOUNT_MED
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
	payment_department = ACCOUNT_MED
/obj/item/vending_refill/wardrobe/viro_wardrobe
	machine_name = "ViroDrobe"


/obj/machinery/vending/wardrobe/marine_wardrobe
	name = "MarineVend"
	desc = "An automated closet hooked up to a colossal storage unit of standard-issue uniform and armor."
	icon = 'icons/marine.dmi'
	icon_state = "marineuniform"
	icon_vend = "marineuniform-vend"
	icon_deny = "marineuniform"
	product_slogans = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!"
	product_ads = "Semper Fidelis!"
	vend_reply = "Thank you for using the MarineVend!"
	products = list(/obj/item/clothing/under/marine = 50,
					/obj/item/clothing/under/marine/SO = 50,
					/obj/item/clothing/under/marine/XO = 50,
					/obj/item/clothing/under/marine/CO = 50,
					/obj/item/clothing/under/marine/RO = 50,
					/obj/item/clothing/under/marine/E = 50,
					/obj/item/clothing/under/marine/CE = 50,
					/obj/item/clothing/under/marine/MP = 50,
					/obj/item/clothing/under/marine/WO = 50,
					/obj/item/clothing/under/marine/liaison = 50,
					/obj/item/clothing/under/marine/liaison_formal = 50,
					/obj/item/clothing/under/marine/researcher = 50,
					/obj/item/clothing/shoes/marine = 50,
					/obj/item/clothing/shoes/marine/laceup = 50,
					/obj/item/clothing/head/marine/beret = 50,
					/obj/item/clothing/head/marine/beret/MP = 50,
					/obj/item/clothing/head/marine/beret/WO = 50,
					/obj/item/clothing/head/marine/bandana = 50,
					/obj/item/clothing/head/marine/headband = 50,
					/obj/item/clothing/head/marine/headband/red = 50,
					/obj/item/clothing/head/marine/cap = 50,
					/obj/item/clothing/head/marine/helmet = 50,
					/obj/item/storage/backpack/satchel/marine = 50,
					/obj/item/storage/backpack/marine = 50,
					/obj/item/clothing/gloves/marine = 50,
					/obj/item/clothing/gloves/marine/white = 50,
					/obj/item/clothing/gloves/marine/officer = 50,
					/obj/item/clothing/gloves/marine/CO = 50,
					/obj/item/clothing/suit/marine = 50,
					/obj/item/clothing/suit/marine/alt = 50,
					/obj/item/clothing/suit/marine/MP = 50,
					/obj/item/clothing/suit/marine/WO = 50,
					/obj/item/clothing/suit/marine/officer = 50)
	refill_canister = /obj/item/vending_refill/wardrobe/marine_wardrobe
	payment_department = ACCOUNT_CIV
	default_price = 0
	extra_price = 0

/obj/item/vending_refill/wardrobe/marine_wardrobe
	machine_name = "MarineVend"


/obj/item/clothing/under/marine
	name = "\improper TGMC uniform"
	desc = "A standard-issue Marine uniform. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon = 'icons/marine.dmi'
	icon_state = "marine_jumpsuit"


/obj/item/clothing/under/marine/SO
	name = "staff officer uniform"
	desc = "A uniform worn by commissioned officers of the TGMC. Do the corps proud. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon = 'icons/marine.dmi'
	icon_state = "so_jumpsuit"


/obj/item/clothing/under/marine/XO
	name = "executive officer uniform"
	desc = "A uniform typically worn by a first-lieutenant Executive Officer in the TGMC. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon = 'icons/marine.dmi'
	icon_state = "xo_jumpsuit"


/obj/item/clothing/under/marine/CO
	name = "commander uniform"
	desc = "The well-ironed uniform of a TGMC commander. Even looking at it the wrong way could result in being court-marshalled. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon = 'icons/marine.dmi'
	icon_state = "co_jumpsuit"


/obj/item/clothing/under/marine/RO
	name = "requisition officer uniform"
	desc = "A nicely-fitting military suit for a requisition officer. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon = 'icons/marine.dmi'
	icon_state = "ro_jumpsuit"


/obj/item/clothing/under/marine/E
	name = "engineer uniform"
	desc = "A uniform for a military engineer. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon = 'icons/marine.dmi'
	icon_state = "e_jumpsuit"


/obj/item/clothing/under/marine/CE
	name = "chief engineer uniform"
	desc = "A uniform for a military engineer. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon = 'icons/marine.dmi'
	icon_state = "ce_jumpsuit"


/obj/item/clothing/under/marine/MP
	name = "military police jumpsuit"
	desc = "A standard-issue Military Police uniform. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon = 'icons/marine.dmi'
	icon_state = "mp_jumpsuit"


/obj/item/clothing/under/marine/WO
	name = "warrant officer uniform"
	desc = "A uniform typically worn by a Chief MP of the TGMC. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions. This uniform includes a small EMF distributor to help nullify energy-based weapon fire, along with a hazmat chemical filter woven throughout the material to ward off biological and radiation hazards."
	icon = 'icons/marine.dmi'
	icon_state = "wo_jumpsuit"


/obj/item/clothing/under/marine/liaison
	name = "liaison's tan suit"
	desc = "A stiff, stylish tan suit commonly worn by businessmen from the Nanotrasen corporation. Expertly crafted to make you look like a prick."
	icon = 'icons/marine.dmi'
	icon_state = "liaison_regular"


/obj/item/clothing/under/marine/liaison_formal
	name = "liaison's white suit"
	desc = "A formal, white suit. Looks like something you'd wear to a funeral, a Nanotrasen corporate dinner, or both. Stiff as a board, but makes you feel like rolling out of a Rolls-Royce."
	icon = 'icons/marine.dmi'
	icon_state = "liaison_formal"


/obj/item/clothing/under/marine/researcher
	name = "researcher uniform"
	desc = "A simple set of civilian clothes worn by researchers. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon = 'icons/marine.dmi'
	icon_state = "research_jumpsuit"


/obj/item/clothing/shoes/marine
	name = "marine combat boots"
	desc = "Standard issue combat boots for combat scenarios or combat situations. All combat, all the time."
	icon = 'icons/marine.dmi'
	icon_state = "marine_shoes"


/obj/item/clothing/shoes/marine/laceup
	name = "chief officer shoes"
	desc = "Only a small amount of monkeys, kittens, and orphans were killed in making this."
	icon = 'icons/marine.dmi'
	icon_state = "marine_laceups"


/obj/item/clothing/head/marine/beret
	name = "\improper TGMC beret"
	desc = "A hat typically worn by the field-officers of the TGMC. Occasionally they find their way down the ranks into the hands of squad-leaders and decorated grunts."
	icon = 'icons/marine.dmi'
	icon_state = "marine_beret"


/obj/item/clothing/head/marine/beret/MP
	name = "\improper TGMC MP beret"
	desc = "A beret with the staff seargant insignia emblazoned on it. It shines with the glow of corrupt authority and a smudge of doughnut."
	icon = 'icons/marine.dmi'
	icon_state = "marine_beretred"


/obj/item/clothing/head/marine/beret/WO
	name = "\improper TGMC chief MP beret"
	desc = "A beret with the lieutenant insignia emblazoned on it. It shines with the glow of corrupt authority and a smudge of doughnut."
	icon = 'icons/marine.dmi'
	icon_state = "marine_beretwo"


/obj/item/clothing/head/marine/bandana
	name = "\improper TGMC bandana"
	desc = "Typically worn by heavy-weapon operators, mercenaries and scouts, the bandana serves as a lightweight and comfortable hat. Comes in two stylish colors."
	icon = 'icons/marine.dmi'
	icon_state = "marine_bandana"


/obj/item/clothing/head/marine/headband
	name = "\improper TGMC green headband"
	desc = "A rag typically worn by the less-orthodox weapons operators in the TGMC. While it offers no protection, it is certainly comfortable to wear compared to the standard helmet. Comes in two stylish colors."
	icon = 'icons/marine.dmi'
	icon_state = "marine_headband"


/obj/item/clothing/head/marine/headband/red
	name = "\improper TGMC red headband"
	desc = "A rag typically worn by the less-orthodox weapons operators in the TGMC. While it offers no protection, it is certainly comfortable to wear compared to the standard helmet. Comes in two stylish colors."
	icon = 'icons/marine.dmi'
	icon_state = "marine_headbandred"


/obj/item/clothing/head/marine/cap
	name = "\improper TGMC cap"
	desc = "A casual cap occasionally worn by Squad-leaders and Combat-Engineers. While it has limited combat functionality, some prefer to wear it instead of the standard issue helmet."
	icon = 'icons/marine.dmi'
	icon_state = "marine_cap"


/obj/item/clothing/head/marine/helmet
	name = "\improper M10 pattern marine helmet"
	desc = "A standard M10 Pattern Helmet. It reads on the label, 'The difference between an open-casket and closed-casket funeral. Wear on head for best results.'. Contains a small built-in camera."
	icon = 'icons/marine.dmi'
	icon_state = "marine_helmet"


/obj/item/storage/backpack/satchel/marine
	name = "\improper TGMC satchel"
	desc = "A heavy-duty satchel carried by some TGMC soldiers and support personnel."
	icon = 'icons/marine.dmi'
	icon_state = "marine_satchel"


/obj/item/storage/backpack/marine
	name = "\improper lightweight IMP backpack"
	desc = "The standard-issue pack of the TGMC forces. Designed to slug gear into the battlefield."
	icon = 'icons/marine.dmi'
	icon_state = "marine_backpack"


/obj/item/clothing/gloves/marine
	name = "marine combat gloves"
	desc = "Standard issue marine tactical gloves. It reads: 'knit by Marine Widows Association'."
	icon = 'icons/marine.dmi'
	icon_state = "marine_gloves"


/obj/item/clothing/gloves/marine/white
	name = "latex gloves"
	desc = "Cheap sterile gloves made from latex."
	icon = 'icons/marine.dmi'
	icon_state = "marine_glovesw"


/obj/item/clothing/gloves/marine/officer
	name = "officer gloves"
	desc = "Shiny and impressive. They look expensive."
	icon = 'icons/marine.dmi'
	icon_state = "marine_gloveso"


/obj/item/clothing/gloves/marine/CO
	name = "commander's gloves"
	desc = "You may like these gloves, but THEY think you are unworthy of them."
	icon = 'icons/marine.dmi'
	icon_state = "marine_glovesco"


/obj/item/clothing/suit/marine
	name = "\improper M3 pattern marine armor"
	desc = "A standard TerraGov Marine Corps M3 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon = 'icons/marine.dmi'
	icon_state = "marine_armor1"


/obj/item/clothing/suit/marine/alt
	name = "\improper M4 pattern marine armor"
	desc = "A standard TerraGov Marine Corps M4 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon = 'icons/marine.dmi'
	icon_state = "marine_armor2"


/obj/item/clothing/suit/marine/MP
	name = "\improper M2 pattern MP armor"
	desc = "A standard TerraGov Marine Corps M2 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon = 'icons/marine.dmi'
	icon_state = "marine_mparmor"


/obj/item/clothing/suit/marine/WO
	name = "\improper M3 pattern CMP armor"
	desc = "A well-crafted suit of M3 Pattern Armor typically distributed to Chief MPs. Useful for letting your men know who is in charge."
	icon = 'icons/marine.dmi'
	icon_state = "marine_cmparmor"


/obj/item/clothing/suit/marine/officer
	name = "\improper M3 pattern officer armor"
	desc = "A well-crafted suit of M3 Pattern Armor typically found in the hands of higher-ranking officers. Useful for letting your men know who is in charge when taking to the field"
	icon = 'icons/marine.dmi'
	icon_state = "marine_officerarmor"