// Poppy
/obj/item/seeds/poppy
	name = "pack of poppy seeds"
	desc = "These seeds grow into poppies."
	icon_state = "seed-poppy"
	species = "poppy"
	plantname = "Poppy Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/poppy
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	oneharvest = 1
	growthstages = 3
	mutatelist = list(/obj/item/seeds/poppy/geranium, /obj/item/seeds/poppy/lily)

/obj/item/weapon/reagent_containers/food/snacks/grown/poppy
	seed = /obj/item/seeds/poppy
	name = "poppy"
	desc = "Long-used as a symbol of rest, peace, and death."
	icon_state = "poppy"
	slot_flags = SLOT_HEAD
	filling_color = "#FF6347"
	reagents_add = list("salglu_solution" = 0.05, "nutriment" = 0.05)
	bitesize_mod = 3

// Lily
/obj/item/seeds/poppy/lily
	name = "pack of lily seeds"
	desc = "These seeds grow into lilies."
	icon_state = "seed-lily"
	species = "lily"
	plantname = "Lily Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/poppy/lily
	mutatelist = list()

/obj/item/weapon/reagent_containers/food/snacks/grown/poppy/lily
	seed = /obj/item/seeds/poppy/lily
	name = "lily"
	desc = "A beautiful orange flower"
	icon_state = "lily"
	filling_color = "#FFA500"

// Geranium
/obj/item/seeds/poppy/geranium
	name = "pack of geranium seeds"
	desc = "These seeds grow into geranium."
	icon_state = "seed-geranium"
	species = "geranium"
	plantname = "Geranium Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/poppy/geranium
	mutatelist = list()

/obj/item/weapon/reagent_containers/food/snacks/grown/poppy/geranium
	seed = /obj/item/seeds/poppy/geranium
	name = "geranium"
	desc = "A beautiful blue flower"
	icon_state = "geranium"
	filling_color = "#008B8B"


// Harebell
/obj/item/seeds/harebell
	name = "pack of harebell seeds"
	desc = "These seeds grow into pretty little flowers."
	icon_state = "seed-harebell"
	species = "harebell"
	plantname = "Harebells"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/harebell
	lifespan = 100
	endurance = 20
	maturation = 7
	production = 1
	yield = 2
	potency = 30
	oneharvest = 1
	growthstages = 4
	plant_type = 1

/obj/item/weapon/reagent_containers/food/snacks/grown/harebell
	seed = /obj/item/seeds/harebell
	name = "harebell"
	desc = "\"I'll sweeten thy sad grave: thou shalt not lack the flower that's like thy face, pale primrose, nor the azured hare-bell, like thy veins; no, nor the leaf of eglantine, whom not to slander, out-sweeten'd not thy breath.\""
	icon_state = "harebell"
	slot_flags = SLOT_HEAD
	filling_color = "#E6E6FA"
	reagents_add = list("nutriment" = 0.05)
	bitesize_mod = 3


// Moonflower
/obj/item/seeds/sunflower/moonflower
	name = "pack of moonflower seeds"
	desc = "These seeds grow into moonflowers."
	icon_state = "seed-moonflower"
	species = "moonflower"
	plantname = "Moonflowers"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/moonflower
	mutatelist = list()
	rarity = 15

/obj/item/weapon/reagent_containers/food/snacks/grown/moonflower
	seed = /obj/item/seeds/sunflower/moonflower
	name = "moonflower"
	desc = "Store in a location at least 50 yards away from werewolves."
	icon_state = "moonflower"
	slot_flags = SLOT_HEAD
	filling_color = "#E6E6FA"
	reagents_add = list("moonshine" = 0.1, "vitamin" = 0.02, "nutriment" = 0.02)
	bitesize_mod = 2

// Sunflower
/obj/item/seeds/sunflower
	name = "pack of sunflower seeds"
	desc = "These seeds grow into sunflowers."
	icon_state = "seed-sunflower"
	species = "sunflower"
	plantname = "Sunflowers"
	product = /obj/item/weapon/grown/sunflower
	endurance = 20
	production = 2
	yield = 2
	oneharvest = 1
	growthstages = 3
	mutatelist = list(/obj/item/seeds/sunflower/moonflower, /obj/item/seeds/sunflower/novaflower)

/obj/item/weapon/grown/sunflower // FLOWER POWER!
	seed = /obj/item/seeds/sunflower
	name = "sunflower"
	desc = "It's beautiful! A certain person might beat you to death if you trample these."
	icon_state = "sunflower"
	damtype = "fire"
	force = 0
	slot_flags = SLOT_HEAD
	throwforce = 0
	w_class = 1
	throw_speed = 1
	throw_range = 3

/obj/item/weapon/grown/sunflower/attack(mob/M, mob/user)
	M << "<font color='green'><b> [user] smacks you with a sunflower!</font><font color='yellow'><b>FLOWER POWER<b></font>"
	user << "<font color='green'>Your sunflower's </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'>strikes [M]</font>"

// Novaflower
/obj/item/seeds/sunflower/novaflower
	name = "pack of novaflower seeds"
	desc = "These seeds grow into novaflowers."
	icon_state = "seed-novaflower"
	species = "novaflower"
	plantname = "Novaflowers"
	product = /obj/item/weapon/grown/novaflower
	mutatelist = list()
	rarity = 20

/obj/item/weapon/grown/novaflower
	seed = /obj/item/seeds/sunflower/novaflower
	name = "novaflower"
	desc = "These beautiful flowers have a crisp smokey scent, like a summer bonfire."
	icon_state = "novaflower"
	damtype = "fire"
	force = 0
	slot_flags = SLOT_HEAD
	throwforce = 0
	w_class = 1
	throw_speed = 1
	throw_range = 3
	plant_type = 0
	attack_verb = list("roasted", "scorched", "burned")

/obj/item/weapon/grown/novaflower/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1)
		reagents.add_reagent("capsaicin", round((potency / 3.5), 1))
		reagents.add_reagent("condensedcapsaicin", round((potency / 4), 1))
	force = round((5 + potency / 5), 1)

/obj/item/weapon/grown/novaflower/attack(mob/living/carbon/M, mob/user)
	if(!..()) return
	if(istype(M, /mob/living))
		M << "<span class='danger'>You are lit on fire from the intense heat of the [name]!</span>"
		M.adjust_fire_stacks(potency / 20)
		M.IgniteMob()

/obj/item/weapon/grown/novaflower/afterattack(atom/A as mob|obj, mob/user,proximity)
	if(!proximity) return
	if(endurance > 0)
		endurance -= rand(1, (endurance / 3) + 1)
	else
		usr << "<span class='warning'>All the petals have fallen off the [name] from violent whacking!</span>"
		usr.unEquip(src)
		qdel(src)

/obj/item/weapon/grown/novaflower/pickup(mob/living/carbon/human/user)
	..()
	if(!user.gloves)
		user << "<span class='danger'>The [name] burns your bare hand!</span>"
		user.adjustFireLoss(rand(1, 5))