//--Imported data disks for cosmetics --//
/obj/item/disk/design_disk/autodrobe_designs
	name = "Nanotrasen Fashion Archives"
	desc = "A design disk with all the latest Nanotrasen fashion. Comes with a catalog of this season's hottest attire."
	icon_state = "datadisk1"
	max_blueprints = 2
	var/list/design_contents = list(new /datum/design/uniform/assistant)

/obj/item/disk/design_disk/autodrobe_designs/Initialize()
	. = ..()
	blueprints = design_contents

//--Generic colored jumpsuits--//
/datum/design/uniform/assistant
	name = "White Jumpsuit"
	id = "whitejumpsuit"
	build_type = DROBELATHE
	materials = list(MAT_CLOTH = 3000)
	build_path = /obj/item/clothing/under/color/white
	category = list("initial","Colored Jumpsuits")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/uniform/assistant/grey
	name = "Grey Jumpsuit"
	id = "greyjumpsuit"
	materials = list(MAT_CLOTH = 3000, MAT_DYE = 1000)
	build_path = /obj/item/clothing/under/color/grey

/datum/design/uniform/assistant/black
	name = "Black Jumpsuit"
	id = "blackjumpsuit"
	materials = list(MAT_CLOTH = 3000, MAT_DYE = 1000)
	build_path = /obj/item/clothing/under/color/black

/datum/design/uniform/assistant/green
	name = "Green Jumpsuit"
	id = "greenjumpsuit"
	materials = list(MAT_CLOTH = 3000, MAT_DYE = 1000)
	build_path = /obj/item/clothing/under/color/green

/datum/design/uniform/assistant/orange
	name = "Orange Jumpsuit"
	id = "orangejumpsuit"
	materials = list(MAT_CLOTH = 3000, MAT_DYE = 1000)
	build_path = /obj/item/clothing/under/color/orange

/datum/design/uniform/assistant/pink
	name = "Pink Jumpsuit"
	id = "pinkjumpsuit"
	materials = list(MAT_CLOTH = 3000, MAT_DYE = 1000)
	build_path = /obj/item/clothing/under/color/pink

/datum/design/uniform/assistant/yellow
	name = "Yellow Jumpsuit"
	id = "yellowjumpsuit"
	materials = list(MAT_CLOTH = 3000, MAT_DYE = 1000)
	build_path = /obj/item/clothing/under/color/yellow

/datum/design/uniform/assistant/brown
	name = "Brown Jumpsuit"
	id = "brownjumpsuit"
	materials = list(MAT_CLOTH = 3000, MAT_DYE = 1000)
	build_path = /obj/item/clothing/under/color/brown

/datum/design/uniform/assistant/rainbow
	name = "Rainbow Jumpsuit"
	id = "rainbowjumpsuit"
	materials = list(MAT_CLOTH = 3000, MAT_DYE = 3000)
	build_path = /obj/item/clothing/under/color/rainbow


//--Department Uniforms--//
//cargo
/datum/design/uniform/departmental
	name = "Cargo Uniform"
	id = "cargouniform"
	build_type = DROBELATHE
	materials = list(MAT_CLOTH = 3000, MAT_DURATHREAD = 1000, MAT_DYE = 1500)
	build_path = /obj/item/clothing/under/rank/cargotech
	category = list("initial","Departmental Uniforms")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/uniform/departmental/quartermaster
	name = "Quartermaster's Uniform"
	id = "quartermasteruniform"
	materials = list(MAT_CLOTH = 3500, MAT_DURATHREAD = 1000, MAT_DYE = 1500)
	build_path = /obj/item/clothing/under/rank/cargo

/datum/design/uniform/departmental/miner
	name = "Shaft Miner's Uniform"
	id = "shaftmineruniform"
	build_path = /obj/item/clothing/under/rank/miner

/datum/design/uniform/departmental/miner/lava
	name = "Shaft Miner's Uniform (Lavaland)"
	id = "shaftminerlavalanduniform"
	build_path = /obj/item/clothing/under/rank/miner/lavaland


//service
/datum/design/uniform/departmental/bartender
	name = "Bartender's Uniform"
	id = "bartenderuniform"
	build_path = /obj/item/clothing/under/rank/bartender

/datum/design/uniform/departmental/chef
	name = "Chef's Uniform"
	id = "chefuniform"
	build_path = /obj/item/clothing/under/rank/chef

/datum/design/uniform/departmental/hydroponics
	name = "Hydroponics' Uniform"
	id = "hydroponicsuniform"
	build_path = /obj/item/clothing/under/rank/hydroponics

/datum/design/uniform/departmental/janitor
	name = "Janitor's Uniform"
	id = "janitoruniform"
	build_path = /obj/item/clothing/under/rank/janitor


//civilian
/datum/design/uniform/departmental/chaplain
	name = "Chaplain's Uniform"
	id = "chaplainuniform"
	build_path = /obj/item/clothing/under/rank/chaplain

/datum/design/uniform/departmental/curator
	name = "Curator's Uniform"
	id = "curatoruniform"
	build_path = /obj/item/clothing/under/rank/curator

/datum/design/uniform/departmental/mime
	name = "Mime's Uniform"
	id = "mimeuniform"
	build_path = /obj/item/clothing/under/rank/mime

/datum/design/uniform/departmental/clown
	name = "Clown's Uniform"
	id = "clownuniform"
	build_path = /obj/item/clothing/under/rank/clown


//engineering
/datum/design/uniform/departmental/station_engineer
	name = "Station Engineer's Uniform"
	id = "stationengineeruniform"
	materials = list(MAT_CLOTH = 4000, MAT_DURATHREAD = 2000, MAT_DYE = 1500)
	build_path = /obj/item/clothing/under/rank/engineer

/datum/design/uniform/departmental/atmos_tech
	name = "Atmospheric Technician's Uniform"
	id = "atmostechuniform"
	build_path = /obj/item/clothing/under/rank/atmospheric_technician


//medsci
/datum/design/uniform/departmental/roboticist
	name = "Roboticist's Uniform"
	id = "roboticistuniform"
	build_path = /obj/item/clothing/under/rank/roboticist

/datum/design/uniform/departmental/scientist
	name = "Scientist's Uniform"
	id = "scientistuniform"
	materials = list(MAT_CLOTH = 325, MAT_DURATHREAD = 75, MAT_DYE = 450)
	build_path = /obj/item/clothing/under/rank/scientist

/datum/design/uniform/departmental/medicaldoctor
	name = "Medical Doctor's Uniform"
	id = "medicaldoctoruniform"
	materials = list(MAT_CLOTH = 325, MAT_DURATHREAD = 75, MAT_DYE = 450)
	build_path = /obj/item/clothing/under/rank/medical

/datum/design/uniform/departmental/genetisticst
	name = "Geneticist's Uniform"
	id = "geneticistuniform"
	materials = list(MAT_CLOTH = 325, MAT_DURATHREAD = 75, MAT_DYE = 450)
	build_path = /obj/item/clothing/under/rank/geneticist

/datum/design/uniform/departmental/virologist
	name = "Virologist's Uniform"
	id = "virologistuniform"
	materials = list(MAT_CLOTH = 325, MAT_DURATHREAD = 75, MAT_DYE = 450)
	build_path = /obj/item/clothing/under/rank/virologist

/datum/design/uniform/departmental/nurse
	name = "Nurse's Uniform"
	id = "nurseuniform"
	materials = list(MAT_CLOTH = 325, MAT_DURATHREAD = 75, MAT_DYE = 450)
	build_path = /obj/item/clothing/under/rank/nursesuit


//--Backpacks--//
/datum/design/backpack
	name = "Backpack"
	id = "backpack"
	build_type = DROBELATHE
	category = list("initial","Backpacks")
	materials = list(MAT_CLOTH = 2500)
	build_path = /obj/item/storage/backpack

/datum/design/backpack/satchel
	name = "Satchel"
	id = "satchel"
	build_path = /obj/item/storage/backpack/satchel

/datum/design/backpack/satchel/leather
	name = "Leather Satchel"
	id = "leathersatchel"
	materials = list(MAT_LEATHER = 2500)
	build_path = /obj/item/storage/backpack/satchel/leather

/datum/design/backpack/duffelbag
	name = "Duffelbag"
	id = "duffelbag"
	category = list("hacked","Backpacks")
	materials = list(MAT_CLOTH = 6500)
	build_path = /obj/item/storage/backpack/duffelbag

/datum/design/backpack/medical
	name = "Medical Backpack"
	id = "medicalbackpack"
	materials = list(MAT_CLOTH = 2500, MAT_DURATHREAD = 500, MAT_DYE = 250)
	build_path = /obj/item/storage/backpack/medic

/datum/design/backpack/medical/satchel
	name = "Medical Satchel"
	id = "medicalsatchel"
	build_path = /obj/item/storage/backpack/satchel/med

/datum/design/backpack/chemistry
	name = "Chemistry Backpack"
	id = "chemistrybackpack"
	materials = list(MAT_CLOTH = 2500, MAT_DURATHREAD = 500, MAT_DYE = 250)
	build_path = /obj/item/storage/backpack/chemistry

/datum/design/backpack/chemistry/satchel
	name = "Chemistry Satchel"
	id = "chemistrysatchel"
	build_path = /obj/item/storage/backpack/satchel/chem

/datum/design/backpack/genetics
	name = "Genetics Backpack"
	id = "geneticsbackpack"
	materials = list(MAT_CLOTH = 2500, MAT_DURATHREAD = 500, MAT_DYE = 250)
	build_path = /obj/item/storage/backpack/genetics

/datum/design/backpack/genetics/satchel
	name = "Genetics Satchel"
	id = "geneticssatchel"
	build_path = /obj/item/storage/backpack/satchel/gen

/datum/design/backpack/virology
	name = "Virology Backpack"
	id = "virologybackpack"
	materials = list(MAT_CLOTH = 2500, MAT_DURATHREAD = 500, MAT_DYE = 250)
	build_path = /obj/item/storage/backpack/virology

/datum/design/backpack/virology/satchel
	name = "Virology Satchel"
	id = "virologysatchel"
	build_path = /obj/item/storage/backpack/satchel/vir

/datum/design/backpack/science
	name = "Science Backpack"
	id = "geneticsbackpack"
	materials = list(MAT_CLOTH = 2500, MAT_DURATHREAD = 500, MAT_DYE = 250)
	build_path = /obj/item/storage/backpack/science

/datum/design/backpack/science/satchel
	name = "Science Satchel"
	id = "sciencesatchel"
	build_path = /obj/item/storage/backpack/satchel/tox

/datum/design/backpack/mining
	name = "Explorer Backpack"
	id = "explorerbackpack"
	materials = list(MAT_CLOTH = 2500, MAT_DURATHREAD = 500, MAT_DYE = 250)
	build_path = /obj/item/storage/backpack/explorer

/datum/design/backpack/mining/satchel
	name = "Explorer Satchel"
	id = "explorersatchel"
	build_path = /obj/item/storage/backpack/satchel/explorer

/datum/design/backpack/engineering
	name = "Industrial Backpack"
	id = "industrialbackpack"
	materials = list(MAT_CLOTH = 2500, MAT_DURATHREAD = 500, MAT_DYE = 250)
	build_path = /obj/item/storage/backpack/industrial

/datum/design/backpack/engineering/satchel
	name = "Industrial Satchel"
	id = "industrialsatchel"
	build_path = /obj/item/storage/backpack/satchel/eng

/datum/design/backpack/botany
	name = "Botany Backpack"
	id = "botanybackpack"
	materials = list(MAT_CLOTH = 2500, MAT_DURATHREAD = 500, MAT_DYE = 250)
	build_path = /obj/item/storage/backpack/botany

/datum/design/backpack/botany/satchel
	name = "Botany Satchel"
	id = "botanysatchel"
	build_path = /obj/item/storage/backpack/satchel/hyd


//--Gloves--//
/datum/design/gloves
	name = "White Gloves"
	id = "cargouniform"
	build_type = DROBELATHE
	materials = list(MAT_CLOTH = 1000)
	build_path = /obj/item/clothing/gloves/color/white
	category = list("initial","Gloves")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/gloves/insulated
	name = "Insulated Gloves"
	id = "insulgloves"
	materials = list(MAT_CLOTH = 1000, MAT_DURATHREAD = 1000, MAT_DYE = 500)
	build_path = /obj/item/clothing/gloves/color/yellow
	category = list("hacked","Gloves")

/datum/design/gloves/black
	name = "Black Gloves"
	id = "blackgloves"
	materials = list(MAT_CLOTH = 1000, MAT_DYE = 250)
	build_path = /obj/item/clothing/gloves/color/black

/datum/design/gloves/orange
	name = "Orange Gloves"
	id = "orangegloves"
	materials = list(MAT_CLOTH = 1000, MAT_DYE = 250)
	build_path = /obj/item/clothing/gloves/color/orange

/datum/design/gloves/red
	name = "Red Gloves"
	id = "redgloves"
	materials = list(MAT_CLOTH = 1000, MAT_DYE = 250)
	build_path = /obj/item/clothing/gloves/color/red

/datum/design/gloves/orange
	name = "Orange Gloves"
	id = "orangegloves"
	materials = list(MAT_CLOTH = 1000, MAT_DYE = 250)
	build_path = /obj/item/clothing/gloves/color/orange

/datum/design/gloves/blue
	name = "Blue Gloves"
	id = "bluegloves"
	materials = list(MAT_CLOTH = 1000, MAT_DYE = 250)
	build_path = /obj/item/clothing/gloves/color/blue

/datum/design/gloves/purple
	name = "Purple Gloves"
	id = "purplegloves"
	materials = list(MAT_CLOTH = 1000, MAT_DYE = 250)
	build_path = /obj/item/clothing/gloves/color/purple

/datum/design/gloves/green
	name = "Green Gloves"
	id = "greengloves"
	materials = list(MAT_CLOTH = 1000, MAT_DYE = 250)
	build_path = /obj/item/clothing/gloves/color/green

/datum/design/gloves/grey
	name = "Grey Gloves"
	id = "greygloves"
	materials = list(MAT_CLOTH = 1000, MAT_DYE = 250)
	build_path = /obj/item/clothing/gloves/color/grey

/datum/design/gloves/brown
	name = "Brown Gloves"
	id = "browngloves"
	materials = list(MAT_CLOTH = 1000, MAT_DYE = 250)
	build_path = /obj/item/clothing/gloves/color/brown

/datum/design/gloves/rainbow
	name = "Rainbow Gloves"
	id = "rainbowgloves"
	materials = list(MAT_CLOTH = 1000, MAT_DYE = 1000)
	build_path = /obj/item/clothing/gloves/color/rainbow


//--Masks--//
/datum/design/mask
	name = "Breath Mask"
	id = "breathmask"
	build_type = DROBELATHE
	materials = list(MAT_PLASTIC = 1000)
	build_path = /obj/item/clothing/mask/breath
	category = list("initial","Masks")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/mask/gasmask
	name = "Gas Mask"
	id = "gasmask"
	materials = list(MAT_PLASTIC = 1250)
	build_path = /obj/item/clothing/mask/gas

/datum/design/mask/fakemoustache
	name = "Fake Moustache"
	id = "fakemoustache"
	materials = list(MAT_PLASTIC = 1500)
	build_path = /obj/item/clothing/mask/fakemoustache
	category = list("hacked","Masks")

/datum/design/mask/muzzle
	name = "Muzzle"
	id = "muzzle"
	materials = list(MAT_LEATHER = 1500)
	build_path = /obj/item/clothing/mask/muzzle
	category = list("hacked","Masks")

/datum/design/mask/clown
	name = "Clown Mask"
	id = "clownmask"
	materials = list(MAT_PLASTIC = 1500, MAT_DYE = 500)
	build_path = /obj/item/clothing/mask/gas/clown_hat

/datum/design/mask/mime
	name = "Mime Mask"
	id = "mimemask"
	materials = list(MAT_PLASTIC = 1500, MAT_DYE = 500)
	build_path = /obj/item/clothing/mask/gas/mime

/datum/design/mask/bandana
	name = "Botany Bandana"
	id = "botanybandana"
	materials = list(MAT_CLOTH = 1500, MAT_DYE = 500)
	build_path = /obj/item/clothing/mask/bandana

/datum/design/mask/bandana/red
	name = "Red Bandana"
	id = "redbandana"
	build_path = /obj/item/clothing/mask/bandana/red

/datum/design/mask/bandana/blue
	name = "Blue Bandana"
	id = "bluebandana"
	build_path = /obj/item/clothing/mask/bandana/blue

/datum/design/mask/bandana/blue
	name = "Blue Bandana"
	id = "bluebandana"
	build_path = /obj/item/clothing/mask/bandana/blue

/datum/design/mask/bandana/green
	name = "Green Bandana"
	id = "greenbandana"
	build_path = /obj/item/clothing/mask/bandana/green

/datum/design/mask/bandana/gold
	name = "Gold Bandana"
	id = "goldbandana"
	build_path = /obj/item/clothing/mask/bandana/gold

/datum/design/mask/bandana/black
	name = "Black Bandana"
	id = "blackbandana"
	build_path = /obj/item/clothing/mask/bandana/black

/datum/design/mask/bandana/skull
	name = "Skull Bandana"
	id = "skullbandana"
	build_path = /obj/item/clothing/mask/bandana/skull





//--Shoes--//
/datum/design/shoes
	name = "Breath Mask"
	id = "breathmask"
	build_type = DROBELATHE
	materials = list(MAT_CLOTH = 500, MAT_LEATHER = 250)
	build_path = /obj/item/clothing/mask/breath
	category = list("initial","Shoes")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE