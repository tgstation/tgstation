/datum/chemical_reaction/bone_hurting_juice
	name = "Bone Hurting Juice"
	id = "bone_hurting_juice"
	results = list("bone_hurting_juice" = 3)
	required_reagents = list("milk" = 1, "cola" = 1, "carbon" = 1) //Milk for calcium, cola because it rots your teeth and carbon because something to do with calcium carbonate.

/datum/chemical_reaction/bleach
	name = "bleach"
	id = "bleach"
	results = list("bleach" = 3)
	required_reagents = list("cleaner" = 1, "sodium" = 1, "chlorine" = 1)

/datum/chemical_reaction/isopropyl
	name = "Isopropyl Alcohol"
	id = "isopropyl"
	results = list("isopropyl" = 5)
	required_catalysts = list("aluminium" = 1)
	required_reagents = list("water" = 6, "carbon" = 3)

/datum/chemical_reaction/carbonf
	name = "Carbonic Fluoride"
	id = "carbonf"
	results = list("carbonf" = 3)
	required_reagents = list("ethanol" = 4, "fluorine" = 1)
	required_temp = 320

/datum/chemical_reaction/aus
	name = "Ausium"
	id = "aus"
	results = list("aus" = 5)
	required_reagents = list("space_drugs" = 5, "ethanol" = 3,"lithium" = 2)
	required_temp = 430
	centrifuge_recipe = TRUE

/datum/chemical_reaction/impalco
	name = "Impure Superhol"
	id = "impalco"
	results = list("impalco" = 5)
	required_reagents = list("ausium" = 2, "ethanol" = 3,"methamphetamine" = 2)
	pressure_required = 5

/datum/chemical_reaction/alco
	name = "Superhol"
	id = "alco"
	results = list("alco" = 5, "ethanol" = 5)
	required_reagents = list("impalco" = 4, "ethanol" = 3 , "isopropyl" = 3)
	centrifuge_recipe = TRUE

/datum/chemical_reaction/emote
	name = "Emotium"
	id = "emote"
	results = list("emote" = 5)
	required_reagents = list("synaptizine" = 1, "sugar" = 2,"ammonia" = 1)
	required_catalysts = list("mutagen" = 1)
	centrifuge_recipe = TRUE

/datum/chemical_reaction/over_reactible/bear
	name = "Bearium"
	id = "bear"
	results = list("bear" = 3, "radgoop" = 2)
	required_reagents = list("liquid_life" = 2, "volt" = 3,"ephedrine" = 1)
	required_temp = 460
	bluespace_recipe = TRUE
	can_overheat = TRUE
	overheat_threshold = 1000
	exothermic_gain = 350

/datum/chemical_reaction/methphos
	name = "Methylphosphonyl difluoride"
	id = "methphos"
	results = list("methphos" = 2)
	required_reagents = list("hydrogen" = 3, "carbon" = 1, "phosphorus" = 1 , "oxygen" = 1, "fluorine" = 2)
	pressure_required = 26

/datum/chemical_reaction/sarin_a
	name = "Translucent mixture"
	id = "sarina"
	results = list("sarina" = 3)
	required_reagents = list("isopropyl" = 3, "methphos" = 2)

/datum/chemical_reaction/sarin_b
	name = "Dilute sarin"
	id = "sarinb"
	results = list("sarinb" = 2)
	required_temp = 700
	pressure_required = 5
	required_reagents = list("sarina" = 2)

/datum/chemical_reaction/over_reactible/sarin
	name = "Sarin"
	id = "sarin"
	results = list("sarin" = 2)
	can_overheat = TRUE
	can_overpressure = TRUE//hehehe quickest way to get killed as a lunatic chemist
	overheat_threshold = 450
	overpressure_threshold = 100
	centrifuge_recipe = TRUE
	pressure_required = 95
	required_reagents = list("sarinb" = 5)

/datum/chemical_reaction/tabun_pa
	name = "Dimethlymine"
	id = "tabuna"
	results = list("tabuna" = 3, "oxygen" = 2)
	required_reagents = list("sodium" = 1,"water" = 3 ,"carbon" = 2, "nitrogen" = 1)
	required_temp = 420

/datum/chemical_reaction/tabun_pb
	name = "Phosphoryll"
	id = "tabunb"
	results = list("tabunb" = 1)
	required_reagents = list("chlorine" = 3,"phosphorus" = 1, "oxygen" = 1)

/datum/chemical_reaction/tabun_pc
	name = "Noxious mixture"
	id = "tabunc"
	results = list("tabunc" = 1)
	required_reagents = list("tabunb" = 2,"tabuna" = 1)

/datum/chemical_reaction/tabun
	name = "Tabun"
	id = "tabun"
	results = list("tabun" = 1, "goop" = 9)
	required_reagents = list("tabunc" = 3)
	centrifuge_recipe = TRUE

/datum/chemical_reaction/impgluco
	name = "Impure Glucosaryll"
	id = "impgluco"
	results = list("impgluco" = 1)
	required_temp = 170
	pressure_required = 45
	required_reagents = list("sugar" = 3,"isopropyl" = 1,"sodiumchloride" = 1)
	
/datum/chemical_reaction/gluco
	name = "Glucosaryll"
	id = "gluco"
	results = list("gluco" = 1)
	required_temp = 120
	pressure_required = 85
	required_reagents = list("impgluco" = 2,"cryogenic_fluid" = 1)
	centrifuge_recipe = TRUE

/datum/chemical_reaction/over_reactible/screech
	name = "Screechisol"
	id = "screech"
	results = list("screech" = 3)
	can_overheat = TRUE
	required_temp = 750
	pressure_required = 30
	overheat_threshold = 775
	required_reagents = list("emote" = 3,"ephedrine" = 1)
