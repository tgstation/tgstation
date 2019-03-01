/obj/item/seeds/aloevera
	name = "pack of aloe vera seeds"
	desc = "These seeds grow into aloe vera."
	icon_state = "seed-teaaspera"
	species = "teaaspera"
	plantname = "Tea Aspera Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/aloevera
	lifespan = 20
	maturation = 3
	production = 3
	yield = 1
	growthstages = 5
	icon_dead = "tea-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)

/obj/item/reagent_containers/food/snacks/grown/aloevera
	name = "aloe vera"
	desc = "You can crush them into healing paste."
	icon_state = "tea_astra_leaves"
	filling_color = "#4582B4"
	gender = PLURAL
	bitesize_mod = 2
	seed = /obj/item/seeds/aloevera
	foodtype = GROSS
	tastes = list("aloe vera" = 1)
	can_distill = FALSE

/obj/item/reagent_containers/food/snacks/grown/aloevera/attack_self(mob/living/user)
	user.visible_message("<span class='notice'>[user] crushes [src] into healing paste.</span>", "<span class='notice'>You crush [src] into healing paste.</span>")
	playsound(user, 'sound/effects/blobattack.ogg', 50, 1)
	var/obj/item/stack/medical/aloevera/M = new
	qdel(src)
	user.put_in_hands(M)
	return 1

/obj/item/stack/medical/aloevera
	amount = 1
	singular_name = "healing paste"
	name = "healing paste"
	icon_state = "aloevera"
	heal_burn = 10
	heal_brute = 10
	self_delay = 20
	grind_results = list("silver_sulfadiazine" = 2, "styptic_powder" = 2)

/obj/item/stack/medical/aloevera/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is squeezing \the [src] into [user.p_their()] mouth! [user.p_do(TRUE)]n't [user.p_they()] know that stuff is bad to eat?</span>")
	return TOXLOSS

