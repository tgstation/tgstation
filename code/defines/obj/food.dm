//Grown foods
/obj/item/weapon/reagent_containers/food/snacks/grown/ //New subclass so we can pass on values
	var/seed = ""
	var/plantname = ""
	var/productname = ""
	var/species = ""
	var/lifespan = 0
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0
	var/potency = -1

/obj/item/weapon/reagent_containers/food/snacks/grown/berries
	name = "berries"
	desc = "Nutritious!"
	icon_state = "berrypile"
	amount = 2
	heal_amt = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/chili
	name = "chili"
	desc = "Spicy!"
	icon_state = "chilipepper"
	amount = 1
	heal_amt = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
	name = "eggplant"
	desc = "Yum!"
	icon_state = "eggplant"
	amount = 2
	heal_amt = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	name = "soybeans"
	desc = "Pretty bland, but the possibilities..."
	icon_state = "soybeans"
	amount = 1
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	name = "tomato"
	desc = "Tom-mae-to or to-mah-to? You decide."
	icon_state = "tomato"
	amount = 2
	heal_amt = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/wheat
	name = "wheat"
	desc = "I wouldn't eat this, unless you're one of those health freaks.."
	icon_state = "wheat"
	amount = 1
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper
	name = "icepepper"
	desc = "THIS SHOULD PROBABLY DO SOMETHING BUT IT DOESN'T RIGHT NOW SO YOU CAN GO FUCK RIGHT OFF"
	icon_state = "icepepper"
	amount = 1
	heal_amt = 1