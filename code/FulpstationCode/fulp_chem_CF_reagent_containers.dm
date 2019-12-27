//Fulp SalChems (T5 Trekkie Chems and Comebacks Rework)
//@Author: Saliferous

//Pills

/obj/item/reagent_containers/pill/charcoal	//FULP [Saliferous]
	name = "charcoal pill"	//FULP
	desc = "Purges chemicals and toxins"	//FULP
	icon_state = "pill17"	//FULP
	list_reagents = list(/datum/reagent/medicine/CF/charcoal = 10)	//FULP
	rename_with_volume = TRUE	//FULP

//Patches

/obj/item/reagent_containers/pill/patch/stypticpowder
	name = "Styptic Powder Patch"
	desc = "Heals bruises"
	list_reagents = list(/datum/reagent/medicine/CF/styptic = 15)
	icon_state = "bandaid_brute"

/obj/item/reagent_containers/pill/patch/silversulfadiazine
	name = "Silver Sulfadiazine Patch"
	desc = "Heals burns"
	list_reagents = list(/datum/reagent/medicine/CF/silver_sulfadiazine = 15)
	icon_state = "bandaid_burn"

/obj/item/reagent_containers/pill/patch/synthflesh
	name = "Synthflesh"
	desc = "Heals Bruises and Burns"
	list_reagents = list(/datum/reagent/medicine/CF/synthflesh = 15)

//Bottles

/obj/item/reagent_containers/glass/bottle/charcoal
	name = "Charcoal bottle"
	desc = "A small bottle of charcoal, which removes toxins and other chemicals from the bloodstream."
	list_reagents = list(/datum/reagent/medicine/CF/charcoal = 30)

//Medigel

/obj/item/reagent_containers/medigel/stypticpowder
	name = "medical gel (styptic)"
	desc = "Heals bruises"
	list_reagents = list(/datum/reagent/medicine/CF/styptic = 60)
	icon_state = "brutegel"

/obj/item/reagent_containers/medigel/silversulfadiazine
	name = "medical gel (silver sulf)"
	desc = "Heals burns"
	list_reagents = list(/datum/reagent/medicine/CF/silver_sulfadiazine = 60)
	icon_state = "burngel"

/obj/item/reagent_containers/medigel/synthflesh
	name = "Synthflesh"
	desc = "Heals Bruises and Burns"
	list_reagents = list(/datum/reagent/medicine/CF/synthflesh = 60)
	icon_state = "synthgel"

//Syringes

/obj/item/reagent_containers/syringe/bicaridine
	name = "syringe (Bicaridine)"
	desc = "Advanced Brute Healing"
	list_reagents = list(/datum/reagent/medicine/CF/bicaridine = 15)

/obj/item/reagent_containers/syringe/kelotane
	name = "syringe (Kelotane)"
	desc = "Advanced Burn Healing"
	list_reagents = list(/datum/reagent/medicine/CF/kelotane = 15)

/obj/item/reagent_containers/syringe/antitoxin
	name = "syringe (Antitoxin)"
	desc = "Advanced Toxin Healing"
	list_reagents = list(/datum/reagent/medicine/CF/antitoxin = 15)

/obj/item/reagent_containers/syringe/tricordrazine
	name = "syringe (Tricordrazine)"
	desc = "Advanced All-round Healing"
	list_reagents = list(/datum/reagent/medicine/CF/tricordrazine = 15)

//Hypospray - Medipen

/obj/item/reagent_containers/hypospray/medipen/bicaridine
	name = "Bicaridine medipen"
	desc = "Advanced Brute Healing"
	list_reagents = list(/datum/reagent/medicine/CF/bicaridine = 10)

/obj/item/reagent_containers/hypospray/medipen/kelotane
	name = "Kelotane medipen"
	desc = "Advanced Burn Healing"
	list_reagents = list(/datum/reagent/medicine/CF/kelotane = 10)

/obj/item/reagent_containers/hypospray/medipen/antitoxin
	name = "AntiToxin medipen"
	desc = "Advanced Toxin Healing"
	list_reagents = list(/datum/reagent/medicine/CF/antitoxin = 10)

/obj/item/reagent_containers/hypospray/medipen/tricordrazine
	name = "Tricordrazine medipen"
	desc = "Advanced All-round Healing"
	list_reagents = list(/datum/reagent/medicine/CF/tricordrazine = 10)
