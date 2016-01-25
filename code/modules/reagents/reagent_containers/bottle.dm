//Not to be confused with /obj/item/weapon/reagent_containers/food/drinks/bottle

/obj/item/weapon/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon_state = null
	item_state = "atoxinbottle"
	possible_transfer_amounts = list(5,10,15,25,30)
	volume = 30

/obj/item/weapon/reagent_containers/glass/bottle/New()
	..()
	if(!icon_state)
		icon_state = "bottle[rand(1,20)]"

/obj/item/weapon/reagent_containers/glass/bottle/epinephrine
	name = "epinephrine bottle"
	desc = "A small bottle. Contains epinephrine - used to stabilize patients."
	icon_state = "bottle16"
	list_reagents = list("epinephrine" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	icon_state = "bottle12"
	list_reagents = list("toxin" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	icon_state = "bottle12"
	list_reagents = list("cyanide" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/morphine
	name = "morphine bottle"
	desc = "A small bottle of morphine."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle20"
	list_reagents = list("morphine" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate
	name = "Chloral Hydrate Bottle"
	desc = "A small bottle of Choral Hydrate. Mickey's Favorite!"
	icon_state = "bottle20"
	list_reagents = list("chloralhydrate" = 15)

/obj/item/weapon/reagent_containers/glass/bottle/charcoal
	name = "antitoxin bottle"
	desc = "A small bottle of charcoal."
	icon_state = "bottle17"
	list_reagents = list("charcoal" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	icon_state = "bottle20"
	list_reagents = list("mutagen" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/plasma
	name = "liquid plasma bottle"
	desc = "A small bottle of liquid plasma. Extremely toxic and reacts with micro-organisms inside blood."
	icon_state = "bottle8"
	list_reagents = list("plasma" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/synaptizine
	name = "synaptizine bottle"
	desc = "A small bottle of synaptizine."
	icon_state = "bottle20"
	list_reagents = list("synaptizine" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle of ammonia."
	icon_state = "bottle20"
	list_reagents = list("ammonia" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle of diethylamine."
	icon_state = "bottle17"
	list_reagents = list("diethylamine" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/facid
	name = "Fluorosulfuric Acid Bottle"
	desc = "A small bottle. Contains a small amount of Fluorosulfuric Acid"
	icon_state = "bottle17"
	list_reagents = list("facid" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	list_reagents = list("adminordrazine" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/capsaicin
	name = "Capsaicin Bottle"
	desc = "A small bottle. Contains hot sauce."
	icon_state = "bottle3"
	list_reagents = list("capsaicin" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/frostoil
	name = "Frost Oil Bottle"
	desc = "A small bottle. Contains cold sauce."
	icon_state = "bottle17"
	list_reagents = list("frostoil" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/traitor
	name = "syndicate bottle"
	desc = "A small bottle. Contains a random nasty chemical."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	var/extra_reagent = null

/obj/item/weapon/reagent_containers/glass/bottle/traitor/New()
	..()
	extra_reagent = pick("polonium", "histamine", "formaldehyde", "venom", "neurotoxin2", "cyanide")
	reagents.add_reagent("[extra_reagent]", 3)

/obj/item/weapon/reagent_containers/glass/bottle/polonium
	name = "polonium bottle"
	desc = "A small bottle. Contains Polonium."
	icon_state = "bottle16"
	list_reagents = list("polonium" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/venom
	name = "venom bottle"
	desc = "A small bottle. Contains Venom."
	icon_state = "bottle16"
	list_reagents = list("venom" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/neurotoxin2
	name = "neurotoxin bottle"
	desc = "A small bottle. Contains Neurotoxin."
	icon_state = "bottle16"
	list_reagents = list("neurotoxin2" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/formaldehyde
	name = "formaldehyde bottle"
	desc = "A small bottle. Contains Formaldehyde."
	icon_state = "bottle16"
	list_reagents = list("formaldehyde" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/initropidril
	name = "initropidril bottle"
	desc = "A small bottle. Contains initropidril."
	icon_state = "bottle16"
	list_reagents = list("initropidril" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/pancuronium
	name = "pancuronium bottle"
	desc = "A small bottle. Contains pancuronium."
	icon_state = "bottle16"
	list_reagents = list("pancuronium" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/sodium_thiopental
	name = "sodium thiopental bottle"
	desc = "A small bottle. Contains sodium thiopental."
	icon_state = "bottle16"
	list_reagents = list("sodium_thiopental" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/coniine
	name = "coniine bottle"
	desc = "A small bottle. Contains coniine."
	icon_state = "bottle16"
	list_reagents = list("coniine" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/curare
	name = "curare bottle"
	desc = "A small bottle. Contains curare."
	icon_state = "bottle16"
	list_reagents = list("curare" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/amanitin
	name = "amanitin bottle"
	desc = "A small bottle. Contains amanitin."
	icon_state = "bottle16"
	list_reagents = list("amanitin" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/histamine
	name = "histamine bottle"
	desc = "A small bottle. Contains Histamine."
	icon_state = "bottle16"
	list_reagents = list("histamine" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/diphenhydramine
	name = "antihistamine bottle"
	desc = "A small bottle of diphenhydramine."
	icon_state = "bottle20"
	list_reagents = list("diphenhydramine" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/potass_iodide
	name = "anti-radiation bottle"
	desc = "A small bottle of potassium iodide."
	icon_state = "bottle11"
	list_reagents = list("potass_iodide" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/salglu_solution
	name = "saline-glucose solution bottle"
	desc = "A small bottle of saline-glucose solution."
	icon_state = "bottle1"
	list_reagents = list("salglu_solution" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/atropine
	name = "atropine bottle"
	desc = "A small bottle of atropine."
	icon_state = "bottle12"
	list_reagents = list("atropine" = 30)