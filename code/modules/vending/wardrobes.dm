/obj/item/vending_refill/wardrobe
	icon_state = "refill_clothes"

/obj/machinery/vending/wardrobe
	default_price = 1050
	extra_price = 1050
	payment_department = NO_FREEBIES
	input_display_header = "Returned Clothing"
	light_mask = "wardrobe-light-mask"

/obj/machinery/vending/wardrobe/canLoadItem(obj/item/I,mob/user)
	return (I.type in products)

/obj/machinery/vending/wardrobe/sec_wardrobe
	name = "\improper SecDrobe"
	desc = "A vending machine for security and security-related clothing!"
	icon_state = "secdrobe"
	product_ads = "Beat perps in style!;It's red so you can't see the blood!;You have the right to be fashionable!;Now you can be the fashion police you always wanted to be!"
	vend_reply = "Thank you for using the SecDrobe!"
	products = list(/obj/item/clothing/under/rank/security/officer = 10,
					/obj/item/clothing/under/rank/security/officer/skirt = 10,
					/obj/item/clothing/under/rank/security/officer/grey = 10,
					/obj/item/clothing/under/pants/khaki = 10,
					/obj/item/clothing/under/rank/security/officer/blueshirt = 10,
					/obj/item/clothing/under/rank/security/officer/formal = 10,
					/obj/item/clothing/under/rank/security/constable = 10,
					/obj/item/clothing/under/rank/security/warden = 10,
					/obj/item/clothing/under/rank/security/warden/grey = 10,
					/obj/item/clothing/under/rank/security/warden/skirt = 10,
					/obj/item/clothing/under/rank/security/warden/formal = 10,
					/obj/item/clothing/under/rank/security/head_of_security = 10,
					/obj/item/clothing/under/rank/security/head_of_security/skirt = 10,
					/obj/item/clothing/under/rank/security/head_of_security/grey = 10,
					/obj/item/clothing/under/rank/security/head_of_security/alt = 10,
					/obj/item/clothing/under/rank/security/head_of_security/alt/skirt = 10,
					/obj/item/clothing/under/rank/security/head_of_security/parade = 10,
					/obj/item/clothing/under/rank/security/head_of_security/parade/female = 10,
					/obj/item/clothing/under/rank/security/head_of_security/formal = 10,
					/obj/item/clothing/under/rank/security/officer/spacepol = 10,
					/obj/item/clothing/under/rank/security/officer/beatcop = 10,
					/obj/item/clothing/under/rank/security/detective = 10,
					/obj/item/clothing/under/rank/security/detective/skirt = 10,
					/obj/item/clothing/under/rank/security/detective/grey = 10,
					/obj/item/clothing/under/rank/security/detective/grey/skirt = 10,
					/obj/item/clothing/under/trek/engsec = 10,
					/obj/item/clothing/under/trek/engsec/next = 10,
					/obj/item/clothing/under/trek/engsec/ent = 10,
					/obj/item/storage/belt/security = 10,
					/obj/item/storage/belt/security/webbing = 10,
					/obj/item/storage/belt/holster = 10,
					/obj/item/storage/backpack/security = 10,
					/obj/item/storage/backpack/satchel/sec = 10,
					/obj/item/storage/backpack/duffelbag/sec = 10,
					/obj/item/storage/backpack/duffelbag/cops = 10,
					/obj/item/clothing/shoes/jackboots = 10,
					/obj/item/clothing/shoes/laceup = 10,
					/obj/item/clothing/head/beret/sec = 10,
					/obj/item/clothing/head/soft/sec = 10,
					/obj/item/clothing/head/HoS = 10,
					/obj/item/clothing/head/HoS/beret = 10,
					/obj/item/clothing/head/warden = 10,
					/obj/item/clothing/head/warden/drill = 10,
					/obj/item/clothing/head/beret/sec/navyhos = 10,
					/obj/item/clothing/head/beret/sec/navywarden = 10,
					/obj/item/clothing/head/beret/sec/navyofficer = 10,
					/obj/item/clothing/head/fedora/det_hat = 10,
					/obj/item/clothing/head/fedora = 10,
					/obj/item/clothing/head/helmet = 10,
					/obj/item/clothing/head/helmet/alt = 10,
					/obj/item/clothing/head/helmet/justice = 10,
					/obj/item/clothing/head/helmet/police = 10,
					/obj/item/clothing/head/helmet/constable = 10,
					/obj/item/clothing/mask/bandana/red = 10,
					/obj/item/clothing/mask/gas/sechailer = 10,
					/obj/item/clothing/mask/gas/sechailer/swat = 10,
					/obj/item/clothing/mask/gas/sechailer/swat/spacepol = 10,
					/obj/item/clothing/mask/whistle = 10,
					/obj/item/clothing/gloves/color/black = 10,
					/obj/item/clothing/gloves/color/latex = 10,
					/obj/item/clothing/suit/security/officer = 10,
					/obj/item/clothing/suit/security/warden = 10,
					/obj/item/clothing/suit/security/hos = 10,
					/obj/item/clothing/suit/det_suit = 10,
					/obj/item/clothing/suit/det_suit/grey = 10,
					/obj/item/clothing/suit/det_suit/noir = 10,
					/obj/item/clothing/suit/armor/vest = 10,
					/obj/item/clothing/suit/armor/vest/alt = 10,
					/obj/item/clothing/suit/armor/vest/blueshirt = 10,
					/obj/item/clothing/suit/armor/hos = 10,
					/obj/item/clothing/suit/armor/hos/trenchcoat = 10,
					/obj/item/clothing/suit/armor/vest/warden = 10,
					/obj/item/clothing/suit/armor/vest/warden/alt = 10,
					/obj/item/clothing/suit/armor/vest/leather = 10,
					/obj/item/clothing/suit/hooded/wintercoat/security = 10,
					/obj/item/clothing/neck/cloak/hos = 10,
					/obj/item/clothing/accessory/waistcoat = 10,
					/obj/item/radio/headset/headset_sec = 10)
	premium = list()
	refill_canister = /obj/item/vending_refill/wardrobe/sec_wardrobe
	payment_department = ACCOUNT_SEC
	light_color = "#ff3300"

/obj/item/vending_refill/wardrobe/sec_wardrobe
	machine_name = "SecDrobe"

/obj/machinery/vending/wardrobe/medi_wardrobe
	name = "\improper MediDrobe"
	desc = "A vending machine rumoured to be capable of dispensing clothing for medical personnel."
	icon_state = "medidrobe"
	product_ads = "Make those blood stains look fashionable!!"
	vend_reply = "Thank you for using the MediDrobe!"
	products = list(/obj/item/clothing/under/rank/medical/chief_medical_officer = 10,
					/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt = 10,
					/obj/item/clothing/under/rank/medical/virologist = 10,
					/obj/item/clothing/under/rank/medical/virologist/skirt = 10,
					/obj/item/clothing/under/rank/medical/doctor = 10,
					/obj/item/clothing/under/rank/medical/doctor/skirt= 10,
					/obj/item/clothing/under/rank/medical/doctor/nurse = 10,
					/obj/item/clothing/under/rank/medical/doctor/blue = 10,
					/obj/item/clothing/under/rank/medical/doctor/green = 10,
					/obj/item/clothing/under/rank/medical/doctor/purple = 10,
					/obj/item/clothing/under/rank/medical/chemist = 10,
					/obj/item/clothing/under/rank/medical/chemist/skirt = 10,
					/obj/item/clothing/under/rank/medical/paramedic = 10,
					/obj/item/clothing/under/rank/medical/paramedic/skirt = 10,
					/obj/item/storage/belt/medical = 10,
					/obj/item/storage/bag/chemistry = 10,
					/obj/item/storage/backpack/duffelbag/med = 10,
					/obj/item/storage/backpack/medic = 10,
					/obj/item/storage/backpack/satchel/med = 10,
					/obj/item/storage/backpack/virology = 10,
					/obj/item/storage/backpack/satchel/vir = 10,
					/obj/item/storage/backpack/chemistry = 10,
					/obj/item/storage/backpack/satchel/chem = 10,
					/obj/item/clothing/shoes/sneakers/white = 10,
					/obj/item/clothing/head/nursehat = 10,
					/obj/item/clothing/head/soft/paramedic = 10,
					/obj/item/clothing/mask/surgical = 10,
					/obj/item/clothing/gloves/color/latex = 10,
					/obj/item/clothing/gloves/color/latex/nitrile = 10,
					/obj/item/clothing/suit/toggle/labcoat = 10,
					/obj/item/clothing/suit/toggle/labcoat/paramedic = 10,
					/obj/item/clothing/suit/toggle/labcoat/cmo = 10,
					/obj/item/clothing/suit/toggle/labcoat/chemist = 10,
					/obj/item/clothing/suit/toggle/labcoat/virologist = 10,
					/obj/item/clothing/suit/apron/surgical = 10,
					/obj/item/clothing/suit/hooded/wintercoat/medical = 10,
					/obj/item/clothing/neck/cloak/cmo = 10,
					/obj/item/radio/headset/headset_med = 10)
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
	products = list(/obj/item/clothing/under/rank/engineering/chief_engineer = 10,
					/obj/item/clothing/under/rank/engineering/chief_engineer/skirt = 10,
					/obj/item/clothing/under/rank/engineering/engineer = 10,
					/obj/item/clothing/under/rank/engineering/engineer/skirt = 10,
					/obj/item/clothing/under/rank/engineering/engineer/hazard = 10,
					/obj/item/clothing/under/rank/engineering/atmospheric_technician = 10,
					/obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt = 10,
					/obj/item/storage/belt/utility = 10,
					/obj/item/storage/belt/utility/chief = 10,
					/obj/item/storage/backpack/duffelbag/engineering = 10,
					/obj/item/storage/backpack/industrial = 10,
					/obj/item/storage/backpack/satchel/eng = 10,
					/obj/item/clothing/shoes/workboots = 10,
					/obj/item/clothing/shoes/sneakers/black = 10,
					/obj/item/clothing/head/hardhat = 10,
					/obj/item/clothing/head/hardhat/orange = 10,
					/obj/item/clothing/head/hardhat/dblue = 10,
					/obj/item/clothing/head/hardhat/red = 10,
					/obj/item/clothing/head/hardhat/red/upgraded = 10,
					/obj/item/clothing/head/hardhat/white = 10,
					/obj/item/clothing/head/hardhat/atmos = 10,
					/obj/item/clothing/head/hardhat/weldhat = 10,
					/obj/item/clothing/head/hardhat/weldhat/white = 10,
					/obj/item/clothing/head/hardhat/weldhat/orange = 10,
					/obj/item/clothing/head/hardhat/weldhat/dblue = 10,
					/obj/item/clothing/head/welding = 10,
					/obj/item/clothing/mask/gas/atmos = 10,
					/obj/item/clothing/mask/gas/welding = 10,
					/obj/item/clothing/gloves/color/yellow = 10,
					/obj/item/clothing/suit/hazardvest = 10,
					/obj/item/clothing/suit/hooded/wintercoat/engineering = 10,
					/obj/item/clothing/neck/cloak/ce = 10,
					/obj/item/radio/headset/headset_eng = 10)
	refill_canister = /obj/item/vending_refill/wardrobe/engi_wardrobe
	payment_department = ACCOUNT_ENG
	light_color = "#fbff24"

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
					/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos = 10,
					/obj/item/clothing/under/rank/engineering/atmospheric_technician = 10,
					/obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt = 10,
					/obj/item/clothing/shoes/sneakers/black = 10)
	refill_canister = /obj/item/vending_refill/wardrobe/atmos_wardrobe
	payment_department = ACCOUNT_ENG
	light_color = "#fbff24"

/obj/item/vending_refill/wardrobe/atmos_wardrobe
	machine_name = "AtmosDrobe"

/obj/machinery/vending/wardrobe/cargo_wardrobe
	name = "CargoDrobe"
	desc = "A highly advanced vending machine for buying cargo related clothing for free."
	icon_state = "cargodrobe"
	product_ads = "Upgraded Assistant Style! Pick yours today!;These shorts are comfy and easy to wear, get yours now!"
	vend_reply = "Thank you for using the CargoDrobe!"
	products = list(/obj/item/clothing/under/rank/civilian/head_of_personnel = 10,
					/obj/item/clothing/under/rank/civilian/head_of_personnel/skirt = 10,
					/obj/item/clothing/under/rank/civilian/head_of_personnel/suit = 10,
					/obj/item/clothing/under/rank/civilian/head_of_personnel/suit/skirt = 10,
					/obj/item/clothing/under/rank/cargo/qm = 10,
					/obj/item/clothing/under/rank/cargo/qm/skirt = 10,
					/obj/item/clothing/under/rank/cargo/tech = 10,
					/obj/item/clothing/under/rank/cargo/tech/skirt = 10,
					/obj/item/clothing/under/rank/cargo/miner = 10,
					/obj/item/clothing/under/rank/cargo/miner/lavaland = 10,
					/obj/item/clothing/shoes/sneakers/black = 10,
					/obj/item/storage/belt/mining = 10,
					/obj/item/storage/belt/mining/alt = 10,
					/obj/item/storage/bag/ore = 10,
					/obj/item/storage/backpack/satchel/explorer = 10,
					/obj/item/clothing/head/soft = 10,
					/obj/item/clothing/head/hopcap = 10,
					/obj/item/clothing/gloves/fingerless = 10,
					/obj/item/clothing/suit/hooded/wintercoat/cargo = 10,
					/obj/item/clothing/neck/cloak/qm = 10,
					/obj/item/clothing/neck/cloak/hop = 10,
					/obj/item/radio/headset/headset_cargo = 10,
					/obj/item/radio/headset/headset_cargo/mining = 10)
	premium = list()
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
	products = list(/obj/item/clothing/under/rank/rnd/roboticist = 2,
					/obj/item/clothing/under/rank/rnd/roboticist/skirt = 2,
					/obj/item/clothing/suit/toggle/labcoat = 2,
					/obj/item/clothing/shoes/sneakers/black = 2,
					/obj/item/clothing/gloves/fingerless = 2,
					/obj/item/clothing/head/soft/black = 2,
					/obj/item/clothing/mask/bandana/skull = 2)
	contraband = list(/obj/item/clothing/suit/hooded/techpriest = 2,
					/obj/item/organ/tongue/robot = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/robo_wardrobe
	extra_price = 1000
	payment_department = ACCOUNT_SCI
/obj/item/vending_refill/wardrobe/robo_wardrobe
	machine_name = "RoboDrobe"

/obj/machinery/vending/wardrobe/science_wardrobe
	name = "SciDrobe"
	desc = "A simple vending machine suitable to dispense well tailored science clothing. Endorsed by Space Cubans."
	icon_state = "scidrobe"
	product_ads = "Longing for the smell of plasma burnt flesh? Buy your science clothing now!;Made with 10% Auxetics, so you don't have to worry about losing your arm!"
	vend_reply = "Thank you for using the SciDrobe!"
	products = list(/obj/item/clothing/under/rank/rnd/research_director = 10,
					/obj/item/clothing/under/rank/rnd/research_director/skirt = 10,
					/obj/item/clothing/under/rank/rnd/research_director/alt = 10,
					/obj/item/clothing/under/rank/rnd/research_director/alt/skirt = 10,
					/obj/item/clothing/under/rank/rnd/research_director/turtleneck = 10,
					/obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt = 10,
					/obj/item/clothing/under/rank/rnd/scientist = 10,
					/obj/item/clothing/under/rank/rnd/scientist/skirt = 10,
					/obj/item/clothing/under/rank/rnd/roboticist = 10,
					/obj/item/clothing/under/rank/rnd/roboticist/skirt = 10,
					/obj/item/clothing/under/rank/rnd/geneticist = 10,
					/obj/item/clothing/under/rank/rnd/geneticist/skirt = 10,
					/obj/item/storage/bag/bio = 10,
					/obj/item/storage/backpack/satchel/tox = 10,
					/obj/item/storage/backpack/satchel/gen = 10,
					/obj/item/clothing/shoes/sneakers/white = 10,
					/obj/item/clothing/shoes/sneakers/black = 10,
					/obj/item/clothing/head/soft/black = 10,
					/obj/item/clothing/mask/gas = 10,
					/obj/item/clothing/mask/bandana/skull = 10,
					/obj/item/clothing/gloves/fingerless = 10,
					/obj/item/clothing/suit/toggle/labcoat/science = 10,
					/obj/item/clothing/suit/toggle/labcoat/genetics = 10,
					/obj/item/clothing/suit/hooded/wintercoat/science = 10,
					/obj/item/clothing/neck/cloak/rd = 10,
					/obj/item/radio/headset/headset_sci = 10)
	refill_canister = /obj/item/vending_refill/wardrobe/science_wardrobe
	payment_department = ACCOUNT_SCI
/obj/item/vending_refill/wardrobe/science_wardrobe
	machine_name = "SciDrobe"

/obj/machinery/vending/wardrobe/civil_wardrobe
	name = "CivilDrobe"
	desc = "A special vending machine that dispenses civilian related clothing."
	icon_state = "hydrobe"
	product_ads = "Want to forget that you're on vacation? Get some work threads here!"
	vend_reply = "Thank you for using the CivilDrobe!"
	products = list(/obj/item/clothing/under/rank/civilian/hydroponics = 10,
					/obj/item/clothing/under/rank/civilian/hydroponics/skirt = 10,
					/obj/item/clothing/under/rank/civilian/janitor = 10,
					/obj/item/clothing/under/rank/civilian/janitor/skirt = 10,
					/obj/item/clothing/under/rank/civilian/janitor/maid = 10,
					/obj/item/clothing/under/rank/civilian/chef = 10,
					/obj/item/clothing/under/rank/civilian/chef/skirt = 10,
					/obj/item/clothing/under/rank/civilian/chaplain = 10,
					/obj/item/clothing/under/rank/civilian/chaplain/skirt = 10,
					/obj/item/clothing/under/rank/civilian/bartender = 10,
					/obj/item/clothing/under/rank/civilian/bartender/skirt = 10,
					/obj/item/clothing/under/rank/civilian/bartender/purple = 10,
					/obj/item/clothing/under/rank/civilian/lawyer/black = 10,
					/obj/item/clothing/under/rank/civilian/lawyer/black/skirt = 10,
					/obj/item/clothing/under/rank/civilian/lawyer/blue = 10,
					/obj/item/clothing/under/rank/civilian/lawyer/blue/skirt = 10,
					/obj/item/clothing/under/rank/civilian/lawyer/bluesuit = 10,
					/obj/item/clothing/under/rank/civilian/lawyer/bluesuit/skirt = 10,
					/obj/item/clothing/under/rank/civilian/lawyer/female = 10,
					/obj/item/clothing/under/rank/civilian/lawyer/female/skirt = 10,
					/obj/item/clothing/under/rank/civilian/lawyer/galaxy = 10,
					/obj/item/clothing/under/rank/civilian/lawyer/galaxy/red = 10,
					/obj/item/clothing/under/rank/civilian/lawyer/purpsuit = 10,
					/obj/item/clothing/under/rank/civilian/lawyer/purpsuit/skirt = 10,
					/obj/item/clothing/under/rank/civilian/lawyer/red = 10,
					/obj/item/clothing/under/rank/civilian/lawyer/red/skirt = 10,
					/obj/item/clothing/under/rank/civilian/mime = 10,
					/obj/item/clothing/under/rank/civilian/mime/skirt = 10,
					/obj/item/clothing/under/rank/civilian/mime/sexy = 10,
					/obj/item/clothing/under/rank/civilian/clown = 10,
					/obj/item/clothing/under/rank/civilian/clown/blue = 10,
					/obj/item/clothing/under/rank/civilian/clown/green = 10,
					/obj/item/clothing/under/rank/civilian/clown/jester = 10,
					/obj/item/clothing/under/rank/civilian/clown/jester/alt = 10,
					/obj/item/clothing/under/rank/civilian/clown/orange = 10,
					/obj/item/clothing/under/rank/civilian/clown/purple = 10,
					/obj/item/clothing/under/rank/civilian/clown/rainbow = 10,
					/obj/item/clothing/under/rank/civilian/clown/sexy = 10,
					/obj/item/clothing/under/rank/civilian/clown/yellow = 10,
					/obj/item/clothing/under/rank/civilian/curator = 10,
					/obj/item/clothing/under/rank/civilian/curator/skirt = 10,
					/obj/item/storage/belt/military/snack = 10,
					/obj/item/storage/belt/janitor = 10,
					/obj/item/storage/belt/plant = 10,
					/obj/item/storage/bag/trash = 10,
					/obj/item/storage/bag/plants = 10,
					/obj/item/storage/bag/books = 10,
					/obj/item/storage/backpack/botany = 10,
					/obj/item/storage/backpack/satchel/hyd = 10,
					/obj/item/storage/backpack/satchel/explorer = 10,
					/obj/item/storage/backpack/cultpack = 10,
					/obj/item/clothing/shoes/laceup = 10,
					/obj/item/clothing/shoes/galoshes = 10,
					/obj/item/clothing/shoes/sneakers/black = 10,
					/obj/item/clothing/shoes/clown_shoes = 10,
					/obj/item/clothing/shoes/sneakers/mime = 10,
					/obj/item/clothing/head/that = 10,
					/obj/item/clothing/head/soft/black = 10,
					/obj/item/clothing/head/soft/mime = 10,
					/obj/item/clothing/head/chefhat = 10,
					/obj/item/clothing/head/soft/purple = 10,
					/obj/item/clothing/head/frenchberet = 10,
					/obj/item/clothing/mask/bandana = 10,
					/obj/item/clothing/mask/gas/clown_hat = 10,
					/obj/item/clothing/mask/gas/sexyclown = 10,
					/obj/item/clothing/mask/gas/mime = 10,
					/obj/item/clothing/mask/gas/sexymime = 10,
					/obj/item/clothing/glasses/regular = 10,
					/obj/item/clothing/glasses/regular/jamjar = 10,
					/obj/item/clothing/glasses/sunglasses/reagent = 10,
					/obj/item/clothing/glasses/sunglasses/big = 10,
					/obj/item/clothing/gloves/botanic_leather = 10,
					/obj/item/clothing/gloves/color/black = 10,
					/obj/item/clothing/gloves/color/white = 10,
					/obj/item/clothing/suit/apron = 10,
					/obj/item/clothing/suit/apron/overalls = 10,
					/obj/item/clothing/suit/apron/waders = 10,
					/obj/item/clothing/under/suit/sl = 10,
					/obj/item/clothing/accessory/waistcoat = 10,
					/obj/item/clothing/suit/apron/purple_bartender = 10,
					/obj/item/clothing/suit/armor/vest/alt = 10,
					/obj/item/clothing/suit/apron/chef = 10,
					/obj/item/clothing/suit/toggle/suspenders = 10,
					/obj/item/clothing/suit/caution = 10,
					/obj/item/clothing/suit/toggle/lawyer = 10,
					/obj/item/clothing/suit/toggle/lawyer/black = 10,
					/obj/item/clothing/suit/toggle/lawyer/purple = 10,
					/obj/item/clothing/suit/hooded/wintercoat = 10,
					/obj/item/clothing/suit/hooded/wintercoat/hydro = 10)
	premium = null
	contraband = null

/obj/item/vending_refill/wardrobe/civil_wardrobe
	machine_name = "CivilDrobe"

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
					/obj/item/clothing/suit/apron/overalls = 10,
					/obj/item/clothing/suit/apron/waders = 10,
					/obj/item/clothing/under/rank/civilian/hydroponics = 10,
					/obj/item/clothing/under/rank/civilian/hydroponics/skirt = 10,
					/obj/item/clothing/mask/bandana = 10,
					/obj/item/clothing/accessory/armband/hydro = 10)
	refill_canister = /obj/item/vending_refill/wardrobe/hydro_wardrobe
	payment_department = ACCOUNT_SRV
	light_color = "#00FF00"

/obj/item/vending_refill/wardrobe/hydro_wardrobe
	machine_name = "HyDrobe"

/obj/machinery/vending/wardrobe/curator_wardrobe
	name = "CuraDrobe"
	desc = "A lowstock vendor only capable of vending clothing for curators and librarians."
	icon_state = "curadrobe"
	product_ads = "Glasses for your eyes and literature for your soul, Curadrobe has it all!; Impress & enthrall your library guests with Curadrobe's extended line of pens!"
	vend_reply = "Thank you for using the CuraDrobe!"
	products = list(/obj/item/pen = 10,
					/obj/item/pen/red = 2,
					/obj/item/pen/blue = 2,
					/obj/item/pen/fourcolor = 1,
					/obj/item/pen/fountain = 2,
					/obj/item/clothing/accessory/pocketprotector = 2,
					/obj/item/clothing/under/rank/civilian/curator/skirt = 2,
					/obj/item/clothing/under/rank/captain/suit/skirt = 2,
					/obj/item/clothing/under/rank/civilian/head_of_personnel/suit/skirt = 2,
					/obj/item/storage/backpack/satchel/explorer = 1,
					/obj/item/clothing/glasses/regular = 2,
					/obj/item/clothing/glasses/regular/jamjar = 1,
					/obj/item/storage/bag/books = 1)
	refill_canister = /obj/item/vending_refill/wardrobe/curator_wardrobe
	payment_department = ACCOUNT_SRV
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
					/obj/item/clothing/under/suit/sl = 2,
					/obj/item/clothing/under/rank/civilian/bartender = 2,
					/obj/item/clothing/under/rank/civilian/bartender/purple = 2,
					/obj/item/clothing/under/rank/civilian/bartender/skirt = 2,
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
					/obj/item/storage/belt/bandolier = 1,
					/obj/item/storage/pill_bottle/dice/hazard = 1,
					/obj/item/storage/bag/money = 2)
	premium = list(/obj/item/storage/box/dishdrive = 1)
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
	products = list(/obj/item/clothing/under/suit/waiter = 2,
					/obj/item/radio/headset/headset_srv = 2,
					/obj/item/clothing/accessory/waistcoat = 2,
					/obj/item/clothing/suit/apron/chef = 10,
					/obj/item/clothing/head/soft/mime = 2,
					/obj/item/storage/box/mousetraps = 2,
					/obj/item/circuitboard/machine/dish_drive = 1,
					/obj/item/clothing/suit/toggle/chef = 1,
					/obj/item/clothing/under/rank/civilian/chef = 1,
					/obj/item/clothing/under/rank/civilian/chef/skirt = 2,
					/obj/item/clothing/head/chefhat = 1,
					/obj/item/clothing/under/rank/civilian/cookjorts = 2,
					/obj/item/clothing/shoes/cookflops = 2,
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
	products = list(/obj/item/clothing/under/rank/civilian/janitor = 2,
					/obj/item/cartridge/janitor = 2,
					/obj/item/clothing/under/rank/civilian/janitor/skirt = 2,
					/obj/item/clothing/gloves/color/black = 2,
					/obj/item/clothing/head/soft/purple = 2,
					/obj/item/pushbroom = 2,
					/obj/item/paint/paint_remover = 2,
					/obj/item/melee/flyswatter = 2,
					/obj/item/flashlight = 2,
					/obj/item/clothing/suit/caution = 6,
					/obj/item/holosign_creator = 2,
					/obj/item/lightreplacer = 2,
					/obj/item/soap/nanotrasen = 2,
					/obj/item/storage/bag/trash = 2,
					/obj/item/clothing/shoes/galoshes = 2,
					/obj/item/watertank/janitor = 1,
					/obj/item/storage/belt/janitor = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/jani_wardrobe
	payment_department = ACCOUNT_SRV
	light_color = "#b800b8"

/obj/item/vending_refill/wardrobe/jani_wardrobe
	machine_name = "JaniDrobe"

/obj/machinery/vending/wardrobe/law_wardrobe
	name = "LawDrobe"
	desc = "Objection! This wardrobe dispenses the rule of law... and lawyer clothing."
	icon_state = "lawdrobe"
	product_ads = "OBJECTION! Get the rule of law for yourself!"
	vend_reply = "Thank you for using the LawDrobe!"
	products = list(/obj/item/clothing/under/rank/civilian/lawyer/bluesuit = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/bluesuit/skirt = 1,
					/obj/item/clothing/suit/toggle/lawyer = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/purpsuit = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/purpsuit/skirt = 1,
					/obj/item/clothing/suit/toggle/lawyer/purple = 1,
					/obj/item/clothing/under/suit/black = 1,
					/obj/item/clothing/under/suit/black/skirt = 1,
					/obj/item/clothing/suit/toggle/lawyer/black = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/female = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/female/skirt = 1,
					/obj/item/clothing/under/suit/black_really = 1,
					/obj/item/clothing/under/suit/black_really/skirt = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/blue = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/blue/skirt = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/red = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/red/skirt = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/black = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/black/skirt = 1,
					/obj/item/clothing/shoes/laceup = 2,
					/obj/item/clothing/accessory/lawyers_badge = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/law_wardrobe
	payment_department = ACCOUNT_SRV
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
					/obj/item/clothing/under/rank/civilian/chaplain = 1,
					/obj/item/clothing/under/rank/civilian/chaplain/skirt = 2,
					/obj/item/clothing/shoes/sneakers/black = 1,
					/obj/item/clothing/suit/chaplainsuit/nun = 1,
					/obj/item/clothing/head/nun_hood = 1,
					/obj/item/clothing/suit/chaplainsuit/holidaypriest = 1,
					/obj/item/clothing/suit/hooded/chaplainsuit/monkhabit = 1,
					/obj/item/storage/fancy/candle_box = 2,
					/obj/item/clothing/head/kippah = 10,
					/obj/item/clothing/suit/chaplainsuit/whiterobe = 1,
					/obj/item/clothing/head/taqiyahwhite = 1,
					/obj/item/clothing/head/taqiyahred = 10,
					/obj/item/clothing/suit/chaplainsuit/monkrobeeast = 1,
					/obj/item/clothing/head/beanie/rasta = 1)
	contraband = list(/obj/item/toy/plush/plushvar = 1,
					/obj/item/toy/plush/narplush = 1,
					/obj/item/clothing/head/medievaljewhat = 10,
					/obj/item/clothing/suit/chaplainsuit/clownpriest = 1,
					/obj/item/clothing/head/clownmitre = 1)
	premium = list(/obj/item/clothing/suit/chaplainsuit/bishoprobe = 1,
					/obj/item/clothing/head/bishopmitre = 1)
	refill_canister = /obj/item/vending_refill/wardrobe/chap_wardrobe
	payment_department = ACCOUNT_SRV
/obj/item/vending_refill/wardrobe/chap_wardrobe
	machine_name = "ChapDrobe"

/obj/machinery/vending/wardrobe/chem_wardrobe
	name = "ChemDrobe"
	desc = "A vending machine for dispensing chemistry related clothing."
	icon_state = "chemdrobe"
	product_ads = "Our clothes are 0.5% more resistant to acid spills! Get yours now!"
	vend_reply = "Thank you for using the ChemDrobe!"
	products = list(/obj/item/clothing/under/rank/medical/chemist = 2,
					/obj/item/clothing/under/rank/medical/chemist/skirt = 2,
					/obj/item/clothing/shoes/sneakers/white = 2,
					/obj/item/clothing/suit/toggle/labcoat/chemist = 2,
					/obj/item/storage/backpack/chemistry = 2,
					/obj/item/storage/backpack/satchel/chem = 2,
					/obj/item/storage/bag/chemistry = 2)
	contraband = list(/obj/item/reagent_containers/spray/syndicate = 2)
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
	products = list(/obj/item/clothing/under/rank/rnd/geneticist = 2,
					/obj/item/clothing/under/rank/rnd/geneticist/skirt = 2,
					/obj/item/clothing/shoes/sneakers/white = 2,
					/obj/item/clothing/suit/toggle/labcoat/genetics = 2,
					/obj/item/storage/backpack/genetics = 2,
					/obj/item/storage/backpack/satchel/gen = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/gene_wardrobe
	payment_department = ACCOUNT_SCI
/obj/item/vending_refill/wardrobe/gene_wardrobe
	machine_name = "GeneDrobe"

/obj/machinery/vending/wardrobe/viro_wardrobe
	name = "ViroDrobe"
	desc = "An unsterilized machine for dispending virology related clothing."
	icon_state = "virodrobe"
	product_ads = " Viruses getting you down? Then upgrade to sterilized clothing today!"
	vend_reply = "Thank you for using the ViroDrobe"
	products = list(/obj/item/clothing/under/rank/medical/virologist = 2,
					/obj/item/clothing/under/rank/medical/virologist/skirt = 2,
					/obj/item/clothing/shoes/sneakers/white = 2,
					/obj/item/clothing/suit/toggle/labcoat/virologist = 2,
					/obj/item/clothing/mask/surgical = 2,
					/obj/item/storage/backpack/virology = 2,
					/obj/item/storage/backpack/satchel/vir = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/viro_wardrobe
	payment_department = ACCOUNT_MED
/obj/item/vending_refill/wardrobe/viro_wardrobe
	machine_name = "ViroDrobe"

/obj/machinery/vending/wardrobe/det_wardrobe
	name = "\improper DetDrobe"
	desc = "A machine for all your detective needs, as long as you need clothes."
	icon_state = "detdrobe"
	product_ads = "Apply your brilliant deductive methods in style!"
	vend_reply = "Thank you for using the DetDrobe!"
	products = list(/obj/item/clothing/under/rank/security/detective = 2,
					/obj/item/clothing/under/rank/security/detective/skirt = 2,
					/obj/item/clothing/shoes/sneakers/brown = 2,
					/obj/item/clothing/suit/det_suit = 2,
					/obj/item/clothing/head/fedora/det_hat = 2,
					/obj/item/clothing/under/rank/security/detective/grey = 2,
					/obj/item/clothing/under/rank/security/detective/grey/skirt = 2,
					/obj/item/clothing/accessory/waistcoat = 2,
					/obj/item/clothing/shoes/laceup = 2,
					/obj/item/clothing/suit/det_suit/grey = 1,
					/obj/item/clothing/suit/det_suit/noir = 1,
					/obj/item/clothing/head/fedora = 2,
					/obj/item/clothing/gloves/color/black = 2,
					/obj/item/clothing/gloves/color/latex = 2,
					/obj/item/reagent_containers/food/drinks/flask/det = 2,
					/obj/item/storage/fancy/cigarettes = 5)
	premium = list(/obj/item/clothing/head/flatcap = 1)
	refill_canister = /obj/item/vending_refill/wardrobe/det_wardrobe
	extra_price = 1050
	payment_department = ACCOUNT_SEC

/obj/item/vending_refill/wardrobe/det_wardrobe
	machine_name = "DetDrobe"
