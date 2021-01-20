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
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/plant_type/weed_hardy)
	mutatelist = list(/obj/item/seeds/nettle/death)
	reagents_add = list(/datum/reagent/toxin/histamine = 0.25)
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
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/plant_type/weed_hardy, /datum/plant_gene/trait/stinging)
	mutatelist = list()
	reagents_add = list(/datum/reagent/toxin/acid = 0.5, /datum/reagent/toxin/histamine = 0.25)
	rarity = 20
	graft_gene = /datum/plant_gene/trait/stinging

/obj/item/food/grown/nettle // "snack"
	seed = /obj/item/seeds/nettle
	name = "nettle"
	desc = "It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "nettle"
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
	var/minforce = 4 //minimum force after most of the stingy bits fall off. increases with potency.
	var/bareicon = "nettle_bare" //icon used to represent nettle once all its bonus damage is used up

/obj/item/food/grown/nettle/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is lightly grasping [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS|TOXLOSS)

/obj/item/food/grown/nettle/pickup(mob/living/user)
	..()
	if(!iscarbon(user))
		return FALSE
	var/mob/living/carbon/C = user
	if(C.gloves)
		return FALSE
	if(HAS_TRAIT(C, TRAIT_PIERCEIMMUNE))
		return FALSE
	var/hit_zone = (C.held_index_to_dir(C.active_hand_index) == "l" ? "l_":"r_") + "arm"
	var/obj/item/bodypart/affecting = C.get_bodypart(hit_zone)
	if(affecting)
		if(affecting.receive_damage(0, force))
			C.update_damage_overlays()
	to_chat(C, "<span class='userdanger'>The nettle burns your bare hand!</span>")
	return TRUE

/obj/item/food/grown/nettle/afterattack(atom/A as mob|obj, mob/user,proximity)
	. = ..()
	if(!proximity)
		return
	if(force > minforce)
		force = max(force - rand(0,2),minforce) // When you whack someone with it, leaves fall off
		if(force == minforce)
			icon_state = bareicon

/obj/item/food/grown/nettle/basic
	seed = /obj/item/seeds/nettle

/obj/item/food/grown/nettle/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	minforce = round(minforce * (1 + seed.potency / 200))
	force = round((minforce + seed.potency / 10), 1)

/obj/item/food/grown/nettle/death
	seed = /obj/item/seeds/nettle/death
	name = "deathnettle"
	desc = "The <span class='danger'>glowing</span> nettle incites <span class='boldannounce'>rage</span> in you just from looking at it!"
	icon_state = "deathnettle"
	bareicon = "deathnettle_bare"
	force = 20
	minforce = 8
	wound_bonus = CANT_WOUND
	throwforce = 15

/obj/item/food/grown/nettle/death/pickup(mob/living/carbon/user)
	if(..())
		if(prob(50))
			user.Paralyze(100)
			to_chat(user, "<span class='userdanger'>You are stunned by [src] as you try picking it up!</span>")

/obj/item/food/grown/nettle/death/attack(mob/living/carbon/M, mob/user)
	if(!..())
		return
	if(isliving(M))
		to_chat(M, "<span class='danger'>You are stunned by the powerful sting of [src]!</span>")
		log_combat(user, M, "attacked", src)

		M.adjust_blurriness(force/7)
		if(prob(10))
			M.Unconscious(force / 0.3)
			M.Paralyze(force / 0.75)
		M.drop_all_held_items()
