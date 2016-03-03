/obj/item/weapon/reagent_containers/food/snacks/grown/corn
	seed = /obj/item/seeds/cornseed
	name = "ear of corn"
	desc = "Needs some butter!"
	icon_state = "corn"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/popcorn
	filling_color = "#FFFF00"
	trash = /obj/item/weapon/grown/corncob
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)
	bitesize_mod = 2


/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
	seed = /obj/item/seeds/cabbageseed
	name = "cabbage"
	desc = "Ewwwwwwwwww. Cabbage."
	icon_state = "cabbage"
	filling_color = "#90EE90"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)
	bitesize_mod = 2


/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod
	seed = /obj/item/seeds/cocoapodseed
	name = "cocoa pod"
	desc = "Fattening... Mmmmm... chucklate."
	icon_state = "cocoapod"
	filling_color = "#FFD700"
	reagents_add = list("cocoa" = 0.25, "nutriment" = 0.1)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/vanillapod
	seed = /obj/item/seeds/vanillapodseed
	name = "vanilla pod"
	desc = "Fattening... Mmmmm... vanilla."
	icon_state = "vanillapod"
	filling_color = "#FFD700"
	reagents_add = list("vanilla" = 0.25, "nutriment" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane
	seed = /obj/item/seeds/sugarcaneseed
	name = "sugarcane"
	desc = "Sickly sweet."
	icon_state = "sugarcane"
	filling_color = "#FFD700"
	reagents_add = list("sugar" = 0.25)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin
	seed = /obj/item/seeds/pumpkinseed
	name = "pumpkin"
	desc = "It's large and scary."
	icon_state = "pumpkin"
	filling_color = "#FFA500"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.2)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if(W.is_sharp())
		user.show_message("<span class='notice'>You carve a face into [src]!</span>", 1)
		new /obj/item/clothing/head/hardhat/pumpkinhead(user.loc)
		qdel(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/blumpkin
	seed = /obj/item/seeds/blumpkinseed
	name = "blumpkin"
	desc = "The pumpkin's toxic sibling."
	icon_state = "blumpkin"
	filling_color = "#87CEFA"
	reagents_add = list("ammonia" = 0.2, "nutriment" = 0.2)
	bitesize_mod = 2


/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
	seed = /obj/item/seeds/eggplantseed
	name = "eggplant"
	desc = "Maybe there's a chicken inside?"
	icon_state = "eggplant"
	filling_color = "#800080"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)
	bitesize_mod = 2


/obj/item/weapon/reagent_containers/food/snacks/grown/shell
	var/inside_type = null

/obj/item/weapon/reagent_containers/food/snacks/grown/shell/attack_self(mob/user as mob)
	if(inside_type)
		new inside_type(user.loc)
	user.unEquip(src)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/shell/eggy
	seed = /obj/item/seeds/eggyseed
	name = "Egg-plant"
	desc = "There MUST be a chicken inside."
	icon_state = "eggyplant"
	inside_type = /obj/item/weapon/reagent_containers/food/snacks/egg
	filling_color = "#F8F8FF"
	reagents_add = list("nutriment" = 0.1)
	bitesize_mod = 2


/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod
	seed = /obj/item/seeds/kudzuseed
	name = "kudzu pod"
	desc = "<I>Pueraria Virallis</I>: An invasive species with vines that rapidly creep and wrap around whatever they contact."
	icon_state = "kudzupod"
	var/list/mutations = list()
	filling_color = "#6B8E23"
	bitesize_mod = 2
	reagents_add = list("charcoal" = 0.04, "nutriment" = 0.02)


/obj/item/weapon/reagent_containers/food/snacks/grown/gatfruit
	seed = /obj/item/seeds/gatfruit
	name = "gatfruit"
	desc = "It smells like burning."
	icon_state = "gatfruit"
	origin_tech = "combat=3"
	trash = /obj/item/weapon/gun/projectile/revolver
	bitesize_mod = 2
	reagents_add = list("sulfur" = 0.1, "carbon" = 0.1, "nitrogen" = 0.07, "potassium" = 0.05)