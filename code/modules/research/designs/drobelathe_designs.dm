//--Imported data disks for cosmetics --//
/obj/item/disk/design_disk/autodrobe_designs
	name = "Nanotrasen Fashion Archives"
	desc = "A design disk with all the latest Nanotrasen fashion. Comes with a catalog of this season's hottest attire."
	icon_state = "datadisk1"
	max_blueprints = 1

/obj/item/disk/design_disk/autodrobe_designs/Initialize()
	. = ..()
	var/datum/design/uniform/assistant/F = new
	blueprints[1] = F

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