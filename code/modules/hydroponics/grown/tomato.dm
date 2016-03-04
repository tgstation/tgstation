// Tomato
/obj/item/seeds/tomato
	name = "pack of tomato seeds"
	desc = "These seeds grow into tomato plants."
	icon_state = "seed-tomato"
	species = "tomato"
	plantname = "Tomato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	maturation = 8
	mutatelist = list(/obj/item/seeds/tomato/blue, /obj/item/seeds/tomato/blood, /obj/item/seeds/tomato/killer)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	seed = /obj/item/seeds/tomato
	name = "tomato"
	desc = "I say to-mah-to, you say tom-mae-to."
	icon_state = "tomato"
	var/splat_type = /obj/effect/decal/cleanable/tomato_smudge
	filling_color = "#FF6347"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/proc/squish(atom/target)
	var/turf/T = get_turf(target)
	if(splat_type)
		new splat_type(T)
	visible_message("The [src.name] has been squashed.","<span class='italics'>You hear a smack.</span>")
	for(var/atom/A in get_turf(target))
		reagents.reaction(A)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/throw_impact(atom/hit_atom)
	if(!..()) //was it caught by a mob?
		squish(hit_atom)
		qdel(src)


// Blood Tomato
/obj/item/seeds/tomato/blood
	name = "pack of blood-tomato seeds"
	desc = "These seeds grow into blood-tomato plants."
	icon_state = "seed-bloodtomato"
	species = "bloodtomato"
	plantname = "Blood-Tomato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blood
	mutatelist = list()
	rarity = 20

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blood
	seed = /obj/item/seeds/tomato/blood
	name = "blood-tomato"
	desc = "So bloody...so...very...bloody....AHHHH!!!!"
	icon_state = "bloodtomato"
	splat_type = /obj/effect/gibspawner/generic
	filling_color = "#FF0000"
	reagents_add = list("blood" = 0.2, "vitamin" = 0.04, "nutriment" = 0.1)


// Blue Tomato
/obj/item/seeds/tomato/blue
	name = "pack of blue-tomato seeds"
	desc = "These seeds grow into blue-tomato plants."
	icon_state = "seed-bluetomato"
	species = "bluetomato"
	plantname = "Blue-Tomato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue
	yield = 2
	mutatelist = list(/obj/item/seeds/tomato/blue/bluespace)
	rarity = 20

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue
	seed = /obj/item/seeds/tomato/blue
	name = "blue-tomato"
	desc = "I say blue-mah-to, you say blue-mae-to."
	icon_state = "bluetomato"
	splat_type = /obj/effect/decal/cleanable/oil
	filling_color = "#0000FF"
	reagents_add = list("lube" = 0.2, "vitamin" = 0.04, "nutriment" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		var/stun = Clamp(potency / 10, 1, 10)
		var/weaken = Clamp(potency / 20, 0.5, 5)
		M.slip(stun, weaken, src)


// Bluespace Tomato
/obj/item/seeds/tomato/blue/bluespace
	name = "pack of blue-space tomato seeds"
	desc = "These seeds grow into blue-space tomato plants."
	icon_state = "seed-bluespacetomato"
	species = "bluespacetomato"
	plantname = "Blue-Space Tomato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue/bluespace
	yield = 2
	mutatelist = list()
	rarity = 50

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue/bluespace
	seed = /obj/item/seeds/tomato/blue/bluespace
	name = "blue-space tomato"
	desc = "So lubricated, you might slip through space-time."
	icon_state = "bluespacetomato"
	origin_tech = "bluespace=3"
	reagents_add = list("lube" = 0.2, "singulo" = 0.2, "vitamin" = 0.04, "nutriment" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue/bluespace/attack_self(mob/user)
	squish(user)
	user.unEquip(src)
	src.visible_message("[user] squashes the [src.name].","<span class='italics'>You hear a smack.</span>")
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue/bluespace/squish(atom/squishee)
	..()
	var/teleport_radius = potency / 10
	if(isliving(squishee))
		var/turf/T = get_turf(squishee)
		new /obj/effect/decal/cleanable/molten_item(T) //Leave a pile of goo behind for dramatic effect...
		do_teleport(squishee, get_turf(squishee), teleport_radius)


// Killer Tomato
/obj/item/seeds/tomato/killer
	name = "pack of killer-tomato seeds"
	desc = "These seeds grow into killer-tomato plants."
	icon_state = "seed-killertomato"
	species = "killertomato"
	plantname = "Killer-Tomato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tomato/killer
	yield = 2
	oneharvest = 1
	growthstages = 2
	mutatelist = list()
	rarity = 30

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/killer
	seed = /obj/item/seeds/tomato/killer
	name = "killer-tomato"
	desc = "I say to-mah-to, you say tom-mae-to... OH GOD IT'S EATING MY LEGS!!"
	icon_state = "killertomato"
	var/awakening = 0
	filling_color = "#FF0000"

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/killer/attack(mob/M, mob/user, def_zone)
	if(awakening)
		user << "<span class='warning'>The tomato is twitching and shaking, preventing you from eating it.</span>"
		return
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/killer/attack_self(mob/user)
	if(awakening || istype(user.loc,/turf/space))
		return
	user << "<span class='notice'>You begin to awaken the Killer Tomato...</span>"
	awakening = 1

	spawn(30)
		if(!gc_destroyed)
			var/mob/living/simple_animal/hostile/killertomato/K = new /mob/living/simple_animal/hostile/killertomato(get_turf(src.loc))
			K.maxHealth += round(endurance / 3)
			K.melee_damage_lower += round(potency / 10)
			K.melee_damage_upper += round(potency / 10)
			K.move_to_delay -= round(production / 50)
			K.health = K.maxHealth
			K.visible_message("<span class='notice'>The Killer Tomato growls as it suddenly awakens.</span>")
			if(user)
				user.unEquip(src)
			qdel(src)