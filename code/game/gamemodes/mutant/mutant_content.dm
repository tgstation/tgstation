//plant gear for the plant people
/obj/item/weapon/grenade/apple_bomb
	desc = "A bulbuous, disgusting apple, covered in pustules."
	name = "mutated apple"
	icon = 'icons/obj/mutant.dmi'
	icon_state = "apple_bomb"
	item_state = "flashbang"
	origin_tech = ""

/obj/item/weapon/grenade/apple_bomb/prime()
	update_mob()
	explosion(src.loc,0,0,1,3,flame_range = 0)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/banana/bananarang
	name = "mutated banana"
	desc = "A vicious, curved banana that seems to have become rather dangerous."
	icon = 'icons/obj/mutant.dmi'
	force = 10
	throwforce = 15
	icon_state = "bananarang"
	item_state = "banana"
	hitsound = 'sound/weapons/bladeslice.ogg'
	trash = /obj/item/weapon/grown/bananapeel
	dried_type = /obj/item/weapon/reagent_containers/food/snacks/grown/banana/bananarang

	New(var/loc, var/potency = 10)
		..()
		if(reagents)
			reagents.add_reagent("banana", 1+round((potency / 10), 1))
			reagents.add_reagent("mutagen", 1+round((potency / 10), 1))
			reagents.add_reagent("toxin", 1+round((potency / 10), 1))
			bitesize = 5


/mob/living/simple_animal/hostile/tomato
	name = "mutant tomato"
	desc = "It has horrid, pulsating flesh, and gnashy, bitey teeth!"
	icon_state = "tomato"
	icon_living = "tomato"
	icon_dead = "tomato_dead"
	maxHealth = 30
	health = 30
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/tomatomeat
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	ventcrawler = 2

obj/item/weapon/reagent_containers/food/snacks/grown/killertomato/mutant
	name = "mutant pod"
	desc = "A tomato covered in writhing, thick veins. It looks like it's about to burst."
	icon = 'icons/obj/mutant.dmi'
	icon_state = "killertomato"

	New(var/loc, var/potency = 10)
		..()
		if(reagents)
			reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
			reagents.add_reagent("mutagen", 1+round((potency / 10), 1))
			reagents.add_reagent("toxin", 1+round((potency / 10), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato/mutant/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/space))
		return
	new /mob/living/simple_animal/hostile/tomato(user.loc)
	qdel(src)
	user << "<span class='notice'>You burst the mutant pod.</span>"