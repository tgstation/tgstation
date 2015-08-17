//Not to be confused with /obj/item/weapon/reagent_containers/food/drinks/bottle

/obj/item/weapon/reagent_containers/glass/beaker/bottle
	name = "bottle"
	desc = "A small bottle."
	icon_state = null
	item_state = "atoxinbottle"
	possible_transfer_amounts = list(5,10,15,25,30)
	volume = 30

/obj/item/weapon/reagent_containers/glass/beaker/bottle/New()
	..()
	if(!icon_state)
		icon_state = "bottle[rand(1,4)]"
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/bottle/epinephrine
	name = "epinephrine bottle"
	desc = "A small bottle. Contains epinephrine - used to stabilize patients."
	list_reagents = list("epinephrine" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	list_reagents = list("toxin" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	list_reagents = list("cyanide" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/morphine
	name = "morphine bottle"
	desc = "A small bottle of morphine."
	icon = 'icons/obj/chemical.dmi'
	list_reagents = list("morphine" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/chloralhydrate
	name = "Chloral Hydrate Bottle"
	desc = "A small bottle of Choral Hydrate. Mickey's Favorite!"
	list_reagents = list("chloralhydrate" = 15)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/charcoal
	name = "antitoxin bottle"
	desc = "A small bottle of charcoal."
	list_reagents = list("charcoal" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	list_reagents = list("mutagen" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/plasma
	name = "liquid plasma bottle"
	desc = "A small bottle of liquid plasma. Extremely toxic and reacts with micro-organisms inside blood."
	list_reagents = list("plasma" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/synaptizine
	name = "synaptizine bottle"
	desc = "A small bottle of synaptizine."
	list_reagents = list("synaptizine" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle of ammonia."
	list_reagents = list("ammonia" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle of diethylamine."
	list_reagents = list("diethylamine" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/facid
	name = "Fluorosulfuric Acid Bottle"
	desc = "A small bottle. Contains a small amount of Fluorosulfuric Acid"
	list_reagents = list("facid" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	list_reagents = list("adminordrazine" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/capsaicin
	name = "Capsaicin Bottle"
	desc = "A small bottle. Contains hot sauce."
	list_reagents = list("capsaicin" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/frostoil
	name = "Frost Oil Bottle"
	desc = "A small bottle. Contains cold sauce."
	list_reagents = list("frostoil" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/traitor
	name = "syndicate bottle"
	desc = "A small bottle. Contains a random nasty chemical."
//	icon = 'icons/obj/chemical.dmi'
	var/extra_reagent = null

/obj/item/weapon/reagent_containers/glass/beaker/bottle/traitor/New()
	..()
	extra_reagent = pick("polonium", "histamine", "formaldehyde", "venom", "neurotoxin2", "cyanide")
	reagents.add_reagent("[extra_reagent]", 3)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/polonium
	name = "polonium bottle"
	desc = "A small bottle. Contains Polonium."
	list_reagents = list("polonium" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/venom
	name = "venom bottle"
	desc = "A small bottle. Contains Venom."
	list_reagents = list("venom" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/neurotoxin2
	name = "neurotoxin bottle"
	desc = "A small bottle. Contains Neurotoxin."
	list_reagents = list("neurotoxin2" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/formaldehyde
	name = "formaldehyde bottle"
	desc = "A small bottle. Contains Formaldehyde."
	list_reagents = list("formaldehyde" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/initropidril
	name = "initropidril bottle"
	desc = "A small bottle. Contains initropidril."
	list_reagents = list("initropidril" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/pancuronium
	name = "pancuronium bottle"
	desc = "A small bottle. Contains pancuronium."
	list_reagents = list("pancuronium" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/sodium_thiopental
	name = "sodium thiopental bottle"
	desc = "A small bottle. Contains sodium thiopental."
	list_reagents = list("sodium_thiopental" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/coniine
	name = "coniine bottle"
	desc = "A small bottle. Contains coniine."
	list_reagents = list("coniine" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/curare
	name = "curare bottle"
	desc = "A small bottle. Contains curare."
	list_reagents = list("curare" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/amanitin
	name = "amanitin bottle"
	desc = "A small bottle. Contains amanitin."
	list_reagents = list("amanitin" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/histamine
	name = "histamine bottle"
	desc = "A small bottle. Contains Histamine."
	list_reagents = list("histamine" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/diphenhydramine
	name = "antihistamine bottle"
	desc = "A small bottle of diphenhydramine."
	list_reagents = list("diphenhydramine" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/potass_iodide
	name = "anti-radiation bottle"
	desc = "A small bottle of potassium iodide."
	list_reagents = list("potass_iodide" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/salglu_solution
	name = "saline-glucose solution bottle"
	desc = "A small bottle of saline-glucose solution."
	list_reagents = list("salglu_solution" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/atropine
	name = "atropine bottle"
	desc = "A small bottle of atropine."
	list_reagents = list("atropine" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/bottle/flu_virion
	name = "Flu virion culture bottle"
	desc = "A small bottle. Contains H13N1 flu virion culture in synthblood medium."
	spawned_disease = /datum/disease/advance/flu

/obj/item/weapon/reagent_containers/glass/beaker/bottle/epiglottis_virion
	name = "Epiglottis virion culture bottle"
	desc = "A small bottle. Contains Epiglottis virion culture in synthblood medium."
	spawned_disease = /datum/disease/advance/voice_change

/obj/item/weapon/reagent_containers/glass/beaker/bottle/liver_enhance_virion
	name = "Liver enhancement virion culture bottle"
	desc = "A small bottle. Contains liver enhancement virion culture in synthblood medium."
	spawned_disease = /datum/disease/advance/heal

/obj/item/weapon/reagent_containers/glass/beaker/bottle/hullucigen_virion
	name = "Hullucigen virion culture bottle"
	desc = "A small bottle. Contains hullucigen virion culture in synthblood medium."
	spawned_disease = /datum/disease/advance/hullucigen

/obj/item/weapon/reagent_containers/glass/beaker/bottle/pierrot_throat
	name = "Pierrot's Throat culture bottle"
	desc = "A small bottle. Contains H0NI<42 virion culture in synthblood medium."
	spawned_disease = /datum/disease/pierrot_throat

/obj/item/weapon/reagent_containers/glass/beaker/bottle/cold
	name = "Rhinovirus culture bottle"
	desc = "A small bottle. Contains XY-rhinovirus culture in synthblood medium."
	spawned_disease = /datum/disease/advance/cold

/obj/item/weapon/reagent_containers/glass/beaker/bottle/retrovirus
	name = "Retrovirus culture bottle"
	desc = "A small bottle. Contains a retrovirus culture in a synthblood medium."
	spawned_disease = /datum/disease/dna_retrovirus

/obj/item/weapon/reagent_containers/glass/beaker/bottle/gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS+ culture in synthblood medium."//Or simply - General BullShit
	amount_per_transfer_from_this = 5
	spawned_disease = /datum/disease/gbs

/obj/item/weapon/reagent_containers/glass/beaker/bottle/fake_gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS- culture in synthblood medium."//Or simply - General BullShit
	spawned_disease = /datum/disease/fake_gbs

/obj/item/weapon/reagent_containers/glass/beaker/bottle/brainrot
	name = "Brainrot culture bottle"
	desc = "A small bottle. Contains Cryptococcus Cosmosis culture in synthblood medium."
	spawned_disease = /datum/disease/brainrot

/obj/item/weapon/reagent_containers/glass/beaker/bottle/magnitis
	name = "Magnitis culture bottle"
	desc = "A small bottle. Contains a small dosage of Fukkos Miracos."
	spawned_disease = /datum/disease/magnitis

/obj/item/weapon/reagent_containers/glass/beaker/bottle/wizarditis
	name = "Wizarditis culture bottle"
	desc = "A small bottle. Contains a sample of Rincewindus Vulgaris."
	spawned_disease = /datum/disease/wizarditis

/obj/item/weapon/reagent_containers/glass/beaker/bottle/anxiety
	name = "Severe Anxiety culture bottle"
	desc = "A small bottle. Contains a sample of Lepidopticides."
	spawned_disease = /datum/disease/anxiety

/obj/item/weapon/reagent_containers/glass/beaker/bottle/beesease
	name = "Beesease culture bottle"
	desc = "A small bottle. Contains a sample of invasive Apidae."
	spawned_disease = /datum/disease/beesease

/obj/item/weapon/reagent_containers/glass/beaker/bottle/fluspanish
	name = "Spanish flu culture bottle"
	desc = "A small bottle. Contains a sample of Inquisitius."
	spawned_disease = /datum/disease/fluspanish