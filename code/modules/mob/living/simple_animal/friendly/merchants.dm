/mob/living/simple_animal/merchant
	name = "Merchant?"
	desc = "A rock. It seems to have... wares."
	icon_state = "basalt"
	icon = 'icons/obj/flora/rocks.dmi'
	maxHealth = 200
	health = 200
	del_on_death = TRUE
	stop_automated_movement = TRUE
	loot = list(/obj/effect/decal/cleanable/dirt)
	///What products are being assigned to the product list?
	var/list/product_list = list(/obj/item/food/burger/plain = 1, /obj/item/gun/ballistic/automatic/pistol = 1, /obj/item/seeds/rainbow_bunch = 1)
	///What is the base price for the products being offered?
	var/product_cost = 100

/mob/living/simple_animal/merchant/Initialize()
	. = ..()
	AddComponent(/datum/component/payment/merchant, product_cost, SSeconomy.get_dep_account(ACCOUNT_CIV), PAYMENT_FRIENDLY, product_list)

/mob/living/simple_animal/merchant/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		return SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, M)
	return ..()

/mob/living/simple_animal/merchant/gondola
	name = "Gondola Merchant"
	desc = "He speaks the language of green."
	icon = 'icons/mob/pets.dmi'
	icon = 'icons/mob/gondolas.dmi'
	icon_state = "gondola"
	icon_living = "gondola"
	loot = list(/obj/effect/decal/cleanable/blood/gibs, /obj/item/stack/sheet/animalhide/gondola = 1, /obj/item/reagent_containers/food/snacks/meat/slab/gondola = 1)
	product_list = list(/obj/item/stack/sheet/animalhide/gondola = 3, /obj/item/clothing/under/costume/gondola = 1, /obj/item/clothing/mask/gondola = 1)
	product_cost = 300

/mob/living/simple_animal/merchant/skeleton
	name = "Skeleton Merchant"
	desc = "Reanimated bones, with reanimated wares."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "skeleton"
	icon_living = "skeleton"
	icon_dead = "skeleton"
	loot = list(/obj/effect/decal/remains/human, /obj/item/stack/sheet/bone = 1)
	product_list = list(/obj/item/reagent_containers/food/snacks/sugarcookie/spookyskull = 3, /obj/item/gun/ballistic/automatic/wt550 = 1, /obj/item/reagent_containers/food/condiment/milk = 1)
	product_cost = 100
