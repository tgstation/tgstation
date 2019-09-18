//Reagent Container (PILL) for Charcoal in Saliferous' Chem Patch/Rework
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
	list_reagents = list(/datum/reagent/medicine/CF/styptic = 10)
	icon_state = "bandaid_brute"

/obj/item/reagent_containers/pill/patch/silversulfadiazine
	name = "Silver Sulfadiazine Patch"
	desc = "Heals burns"
	list_reagents = list(/datum/reagent/medicine/CF/silver_sulfadiazine = 10)
	icon_state = "bandaid_burn"

//Medigel
/obj/item/reagent_containers/medigel/stypticpowder
	name = "medical gel (styptic)"
	desc = "Heals bruises"
	list_reagents = list(/datum/reagent/medicine/CF/styptic = 20)
	icon_state = "brutegel"

/obj/item/reagent_containers/medigel/silversulfadiazine
	name = "medical gel (silver sulf)"
	desc = "Heals burns"
	list_reagents = list(/datum/reagent/medicine/CF/silver_sulfadiazine = 20)
	icon_state = "burngel"

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

//Hypospray

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

/obj/item/reagent_containers/hypospray/tricordrazine
	name = "Tricordrazine Hypospray"
	desc = "Advanced All-round Healing"
	list_reagents = list(/datum/reagent/medicine/CF/tricordrazine = 20)
