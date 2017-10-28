/obj/item/seeds/limbseed
	name = "pack of replica limb seeds"
	desc = "Replica limbs, like arms and legs. Break a leg!"
	icon = 'hippiestation/icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed-limb"
	species = "limb"
	plantname = "Replica Limb Flower"
	product = /obj/item/reagent_containers/food/snacks/grown/limb_spawn
	lifespan = 25
	endurance = 10
	maturation = 8
	production = 6
	yield = 2
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	potency = 20
	growthstages = 3
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/limb_spawn
	icon = 'hippiestation/icons/obj/hydroponics/harvest.dmi'
	seed = /obj/item/seeds/limbseed
	name = "limbplant"
	desc = "A cluster of limbs sprouting from a stem."
	icon_state = "limbplant"

/obj/item/reagent_containers/food/snacks/grown/limb_spawn/canconsume(mob/eater, mob/user)
	return 0

/obj/item/reagent_containers/food/snacks/grown/limb_spawn/attack_self(mob/user as mob)
	if(user)
		user.dropItemToGround(src)
	var/obj/item/bodypart/limb
	limb = new /obj/item/bodypart/[pick("r_arm","l_arm","r_leg","l_leg")]
	limb.icon = 'icons/mob/human_parts_greyscale.dmi'
	limb.skin_tone = random_skin_tone()
	limb.should_draw_greyscale = TRUE
	limb.update_icon_dropped()
	qdel(src)