/obj/item/seeds/nettle
	name = "pack of nettle seeds"
	desc = "These seeds grow into nettles."
	icon_state = "seed-nettle"
	species = "nettle"
	plantname = "Nettles"
	product = /obj/item/food/grown/nettle
	lifespan = 30
	endurance = 40 // tuff like a toiger
	yield = 4
	instability = 25
	growthstages = 5
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/plant_type/weed_hardy, /datum/plant_gene/trait/attack/nettle_attack, /datum/plant_gene/trait/backfire/nettle_burn)
	mutatelist = list(/obj/item/seeds/nettle/death)
	reagents_add = list(/datum/reagent/toxin/acid = 0.5)
	graft_gene = /datum/plant_gene/trait/plant_type/weed_hardy

/obj/item/seeds/nettle/death
	name = "pack of death-nettle seeds"
	desc = "These seeds grow into death-nettles."
	icon_state = "seed-deathnettle"
	species = "deathnettle"
	plantname = "Death Nettles"
	product = /obj/item/food/grown/nettle/death
	endurance = 25
	maturation = 8
	yield = 2
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/plant_type/weed_hardy, /datum/plant_gene/trait/stinging, /datum/plant_gene/trait/attack/nettle_attack/death, /datum/plant_gene/trait/backfire/nettle_burn/death)
	mutatelist = null
	reagents_add = list(/datum/reagent/toxin/acid/fluacid = 0.5, /datum/reagent/toxin/acid = 0.5)
	rarity = 20
	graft_gene = /datum/plant_gene/trait/stinging

/obj/item/food/grown/nettle // "snack"
	seed = /obj/item/seeds/nettle
	name = "\improper nettle"
	desc = "It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "nettle"
	bite_consumption_mod = 2
	lefthand_file = 'icons/mob/inhands/weapons/plants_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/plants_righthand.dmi'
	damtype = BURN
	force = 15
	hitsound = 'sound/weapons/bladeslice.ogg'
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3
	attack_verb_continuous = list("stings")
	attack_verb_simple = list("sting")

/obj/item/food/grown/nettle/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is eating some of [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS|TOXLOSS)

/obj/item/food/grown/nettle/death
	seed = /obj/item/seeds/nettle/death
	name = "\improper deathnettle"
	desc = "The <span class='danger'>glowing</span> nettle incites <span class='boldannounce'>rage</span> in you just from looking at it!"
	icon_state = "deathnettle"
	bite_consumption_mod = 4 // I guess if you really wanted to
	force = 30
	wound_bonus = CANT_WOUND
	throwforce = 15
