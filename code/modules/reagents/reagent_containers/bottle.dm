//Not to be confused with /obj/item/reagent_containers/food/drinks/bottle

/obj/item/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon_state = "bottle"
	item_state = "atoxinbottle"
	possible_transfer_amounts = list(5,10,15,25,30)
	volume = 30


/obj/item/reagent_containers/glass/bottle/Initialize()
	. = ..()
	if(!icon_state)
		icon_state = "bottle"
	update_icon()

/obj/item/reagent_containers/glass/bottle/on_reagent_change(changetype)
	update_icon()

/obj/item/reagent_containers/glass/bottle/update_icon()
	cut_overlays()
	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[icon_state]-10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)
				filling.icon_state = "[icon_state]-10"
			if(10 to 29)
				filling.icon_state = "[icon_state]25"
			if(30 to 49)
				filling.icon_state = "[icon_state]50"
			if(50 to 69)
				filling.icon_state = "[icon_state]75"
			if(70 to INFINITY)
				filling.icon_state = "[icon_state]100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)


/obj/item/reagent_containers/glass/bottle/epinephrine
	name = "epinephrine bottle"
	desc = "A small bottle. Contains epinephrine - used to stabilize patients."
	list_reagents = list("epinephrine" = 30)

/obj/item/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	list_reagents = list("toxin" = 30)

/obj/item/reagent_containers/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	list_reagents = list("cyanide" = 30)

/obj/item/reagent_containers/glass/bottle/spewium
	name = "spewium bottle"
	desc = "A small bottle of spewium."
	list_reagents = list("spewium" = 30)

/obj/item/reagent_containers/glass/bottle/morphine
	name = "morphine bottle"
	desc = "A small bottle of morphine."
	icon = 'icons/obj/chemical.dmi'
	list_reagents = list("morphine" = 30)

/obj/item/reagent_containers/glass/bottle/chloralhydrate
	name = "Chloral Hydrate Bottle"
	desc = "A small bottle of Choral Hydrate. Mickey's Favorite!"
	icon_state = "bottle20"
	list_reagents = list("chloralhydrate" = 15)

/obj/item/reagent_containers/glass/bottle/charcoal
	name = "charcoal bottle"
	desc = "A small bottle of charcoal, which removes toxins and other chemicals from the bloodstream."
	list_reagents = list("charcoal" = 30)

/obj/item/reagent_containers/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	list_reagents = list("mutagen" = 30)

/obj/item/reagent_containers/glass/bottle/plasma
	name = "liquid plasma bottle"
	desc = "A small bottle of liquid plasma. Extremely toxic and reacts with micro-organisms inside blood."
	list_reagents = list("plasma" = 30)

/obj/item/reagent_containers/glass/bottle/synaptizine
	name = "synaptizine bottle"
	desc = "A small bottle of synaptizine."
	list_reagents = list("synaptizine" = 30)

/obj/item/reagent_containers/glass/bottle/formaldehyde
	name = "formaldehyde bottle"
	desc = "A small bottle of formaldehyde."
	list_reagents = list("formaldehyde" = 30)

/obj/item/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle of ammonia."
	list_reagents = list("ammonia" = 30)

/obj/item/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle of diethylamine."
	list_reagents = list("diethylamine" = 30)

/obj/item/reagent_containers/glass/bottle/facid
	name = "Fluorosulfuric Acid Bottle"
	desc = "A small bottle. Contains a small amount of fluorosulfuric acid."
	list_reagents = list("facid" = 30)

/obj/item/reagent_containers/glass/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	list_reagents = list("adminordrazine" = 30)

/obj/item/reagent_containers/glass/bottle/capsaicin
	name = "Capsaicin Bottle"
	desc = "A small bottle. Contains hot sauce."
	list_reagents = list("capsaicin" = 30)

/obj/item/reagent_containers/glass/bottle/frostoil
	name = "Frost Oil Bottle"
	desc = "A small bottle. Contains cold sauce."
	list_reagents = list("frostoil" = 30)

/obj/item/reagent_containers/glass/bottle/traitor
	name = "syndicate bottle"
	desc = "A small bottle. Contains a random nasty chemical."
	icon = 'icons/obj/chemical.dmi'
	var/extra_reagent = null

/obj/item/reagent_containers/glass/bottle/traitor/Initialize()
	. = ..()
	extra_reagent = pick("polonium", "histamine", "formaldehyde", "venom", "fentanyl", "cyanide")
	reagents.add_reagent("[extra_reagent]", 3)

/obj/item/reagent_containers/glass/bottle/polonium
	name = "polonium bottle"
	desc = "A small bottle. Contains Polonium."
	list_reagents = list("polonium" = 30)

/obj/item/reagent_containers/glass/bottle/magillitis
	name = "magillitis bottle"
	desc = "A small bottle. Contains a serum known only as 'magillitis'."
	list_reagents = list("magillitis" = 5)

/obj/item/reagent_containers/glass/bottle/venom
	name = "venom bottle"
	desc = "A small bottle. Contains Venom."
	list_reagents = list("venom" = 30)

/obj/item/reagent_containers/glass/bottle/fentanyl
	name = "fentanyl bottle"
	desc = "A small bottle. Contains Fentanyl."
	list_reagents = list("fentanyl" = 30)

/obj/item/reagent_containers/glass/bottle/formaldehyde
	name = "formaldehyde bottle"
	desc = "A small bottle. Contains Formaldehyde."
	list_reagents = list("formaldehyde" = 30)

/obj/item/reagent_containers/glass/bottle/initropidril
	name = "initropidril bottle"
	desc = "A small bottle. Contains initropidril."
	list_reagents = list("initropidril" = 30)

/obj/item/reagent_containers/glass/bottle/pancuronium
	name = "pancuronium bottle"
	desc = "A small bottle. Contains pancuronium."
	list_reagents = list("pancuronium" = 30)

/obj/item/reagent_containers/glass/bottle/sodium_thiopental
	name = "sodium thiopental bottle"
	desc = "A small bottle. Contains sodium thiopental."
	list_reagents = list("sodium_thiopental" = 30)

/obj/item/reagent_containers/glass/bottle/coniine
	name = "coniine bottle"
	desc = "A small bottle. Contains coniine."
	list_reagents = list("coniine" = 30)

/obj/item/reagent_containers/glass/bottle/curare
	name = "curare bottle"
	desc = "A small bottle. Contains curare."
	list_reagents = list("curare" = 30)

/obj/item/reagent_containers/glass/bottle/amanitin
	name = "amanitin bottle"
	desc = "A small bottle. Contains amanitin."
	list_reagents = list("amanitin" = 30)

/obj/item/reagent_containers/glass/bottle/histamine
	name = "histamine bottle"
	desc = "A small bottle. Contains Histamine."
	list_reagents = list("histamine" = 30)

/obj/item/reagent_containers/glass/bottle/diphenhydramine
	name = "antihistamine bottle"
	desc = "A small bottle of diphenhydramine."
	list_reagents = list("diphenhydramine" = 30)

/obj/item/reagent_containers/glass/bottle/potass_iodide
	name = "anti-radiation bottle"
	desc = "A small bottle of potassium iodide."
	list_reagents = list("potass_iodide" = 30)

/obj/item/reagent_containers/glass/bottle/salglu_solution
	name = "saline-glucose solution bottle"
	desc = "A small bottle of saline-glucose solution."
	icon_state = "bottle1"
	list_reagents = list("salglu_solution" = 30)

/obj/item/reagent_containers/glass/bottle/atropine
	name = "atropine bottle"
	desc = "A small bottle of atropine."
	list_reagents = list("atropine" = 30)

/obj/item/reagent_containers/glass/bottle/romerol
	name = "romerol bottle"
	desc = "A small bottle of Romerol. The REAL zombie powder."
	list_reagents = list("romerol" = 30)

/obj/item/reagent_containers/glass/bottle/random_virus
	name = "Experimental disease culture bottle"
	desc = "A small bottle. Contains an untested viral culture in synthblood medium."
	spawned_disease = /datum/disease/advance/random

/obj/item/reagent_containers/glass/bottle/pierrot_throat
	name = "Pierrot's Throat culture bottle"
	desc = "A small bottle. Contains H0NI<42 virion culture in synthblood medium."
	spawned_disease = /datum/disease/pierrot_throat

/obj/item/reagent_containers/glass/bottle/cold
	name = "Rhinovirus culture bottle"
	desc = "A small bottle. Contains XY-rhinovirus culture in synthblood medium."
	spawned_disease = /datum/disease/advance/cold
	
/obj/item/reagent_containers/glass/bottle/flu_virion
	name = "Flu virion culture bottle"
	desc = "A small bottle. Contains H13N1 flu virion culture in synthblood medium."
	spawned_disease = /datum/disease/advance/flu

/obj/item/reagent_containers/glass/bottle/retrovirus
	name = "Retrovirus culture bottle"
	desc = "A small bottle. Contains a retrovirus culture in a synthblood medium."
	spawned_disease = /datum/disease/dna_retrovirus

/obj/item/reagent_containers/glass/bottle/gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS+ culture in synthblood medium."//Or simply - General BullShit
	amount_per_transfer_from_this = 5
	spawned_disease = /datum/disease/gbs

/obj/item/reagent_containers/glass/bottle/fake_gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS- culture in synthblood medium."//Or simply - General BullShit
	spawned_disease = /datum/disease/fake_gbs

/obj/item/reagent_containers/glass/bottle/brainrot
	name = "Brainrot culture bottle"
	desc = "A small bottle. Contains Cryptococcus Cosmosis culture in synthblood medium."
	icon_state = "bottle3"
	spawned_disease = /datum/disease/brainrot

/obj/item/reagent_containers/glass/bottle/magnitis
	name = "Magnitis culture bottle"
	desc = "A small bottle. Contains a small dosage of Fukkos Miracos."
	spawned_disease = /datum/disease/magnitis

/obj/item/reagent_containers/glass/bottle/wizarditis
	name = "Wizarditis culture bottle"
	desc = "A small bottle. Contains a sample of Rincewindus Vulgaris."
	spawned_disease = /datum/disease/wizarditis

/obj/item/reagent_containers/glass/bottle/anxiety
	name = "Severe Anxiety culture bottle"
	desc = "A small bottle. Contains a sample of Lepidopticides."
	spawned_disease = /datum/disease/anxiety

/obj/item/reagent_containers/glass/bottle/beesease
	name = "Beesease culture bottle"
	desc = "A small bottle. Contains a sample of invasive Apidae."
	spawned_disease = /datum/disease/beesease

/obj/item/reagent_containers/glass/bottle/fluspanish
	name = "Spanish flu culture bottle"
	desc = "A small bottle. Contains a sample of Inquisitius."
	spawned_disease = /datum/disease/fluspanish

/obj/item/reagent_containers/glass/bottle/tuberculosis
	name = "Fungal Tuberculosis culture bottle"
	desc = "A small bottle. Contains a sample of Fungal Tubercle bacillus."
	spawned_disease = /datum/disease/tuberculosis

/obj/item/reagent_containers/glass/bottle/tuberculosiscure
	name = "BVAK bottle"
	desc = "A small bottle containing Bio Virus Antidote Kit."
	list_reagents = list("atropine" = 5, "epinephrine" = 5, "salbutamol" = 10, "spaceacillin" = 10)

//Oldstation.dmm chemical storage bottles

/obj/item/reagent_containers/glass/bottle/hydrogen
	name = "hydrogen bottle"
	list_reagents = list("hydrogen" = 30)

/obj/item/reagent_containers/glass/bottle/lithium
	name = "lithium bottle"
	list_reagents = list("lithium" = 30)

/obj/item/reagent_containers/glass/bottle/carbon
	name = "carbon bottle"
	list_reagents = list("carbon" = 30)

/obj/item/reagent_containers/glass/bottle/nitrogen
	name = "nitrogen bottle"
	list_reagents = list("nitrogen" = 30)

/obj/item/reagent_containers/glass/bottle/oxygen
	name = "oxygen bottle"
	list_reagents = list("oxygen" = 30)

/obj/item/reagent_containers/glass/bottle/fluorine
	name = "fluorine bottle"
	list_reagents = list("fluorine" = 30)

/obj/item/reagent_containers/glass/bottle/sodium
	name = "sodium bottle"
	list_reagents = list("sodium" = 30)

/obj/item/reagent_containers/glass/bottle/aluminium
	name = "aluminium bottle"
	list_reagents = list("aluminium" = 30)

/obj/item/reagent_containers/glass/bottle/silicon
	name = "silicon bottle"
	list_reagents = list("silicon" = 30)

/obj/item/reagent_containers/glass/bottle/phosphorus
	name = "phosphorus bottle"
	list_reagents = list("phosphorus" = 30)

/obj/item/reagent_containers/glass/bottle/sulfur
	name = "sulfur bottle"
	list_reagents = list("sulfur" = 30)

/obj/item/reagent_containers/glass/bottle/chlorine
	name = "chlorine bottle"
	list_reagents = list("chlorine" = 30)

/obj/item/reagent_containers/glass/bottle/potassium
	name = "potassium bottle"
	list_reagents = list("potassium" = 30)

/obj/item/reagent_containers/glass/bottle/iron
	name = "iron bottle"
	list_reagents = list("iron" = 30)

/obj/item/reagent_containers/glass/bottle/copper
	name = "copper bottle"
	list_reagents = list("copper" = 30)

/obj/item/reagent_containers/glass/bottle/mercury
	name = "mercury bottle"
	list_reagents = list("mercury" = 30)

/obj/item/reagent_containers/glass/bottle/radium
	name = "radium bottle"
	list_reagents = list("radium" = 30)

/obj/item/reagent_containers/glass/bottle/water
	name = "water bottle"
	list_reagents = list("water" = 30)

/obj/item/reagent_containers/glass/bottle/ethanol
	name = "ethanol bottle"
	list_reagents = list("ethanol" = 30)

/obj/item/reagent_containers/glass/bottle/sugar
	name = "sugar bottle"
	list_reagents = list("sugar" = 30)

/obj/item/reagent_containers/glass/bottle/sacid
	name = "sulphuric acid bottle"
	list_reagents = list("sacid" = 30)

/obj/item/reagent_containers/glass/bottle/welding_fuel
	name = "welding fuel bottle"
	list_reagents = list("welding_fuel" = 30)

/obj/item/reagent_containers/glass/bottle/silver
	name = "silver bottle"
	list_reagents = list("silver" = 30)

/obj/item/reagent_containers/glass/bottle/iodine
	name = "iodine bottle"
	list_reagents = list("iodine" = 30)

/obj/item/reagent_containers/glass/bottle/bromine
	name = "bromine bottle"
	list_reagents = list("bromine" = 30)
