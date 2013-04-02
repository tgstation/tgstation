
/obj/item/queen_bee
	name = "queen bee packet"
	desc = "Place her into an apiary so she can get busy."
	icon = 'icons/obj/seeds.dmi'
	icon_state = "seed-kudzu"
	w_class = 1

/obj/item/weapon/bee_net
	name = "bee net"
	desc = "For catching rogue bees."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "bee_net"
	item_state = "bedsheet"
	w_class = 3
	var/caught_bees = 0

/obj/item/weapon/bee_net/attack_self(mob/user as mob)
	var/turf/T = get_step(get_turf(user), user.dir)
	for(var/mob/living/simple_animal/bee/B in T)
		if(B.feral < 0)
			caught_bees += B.strength
			del(B)
			user.visible_message("\blue [user] nets some bees.","\blue You net up some of the becalmed bees.")
		else
			user.visible_message("\red [user] swings at some bees, they don't seem to like it.","\red You swing at some bees, they don't seem to like it.")
			B.feral = 5
			B.target_mob = user

/obj/item/weapon/bee_net/verb/empty_bees()
	set src in usr
	set name = "Empty bee net"
	set category = "Object"
	var/mob/living/carbon/M
	if(iscarbon(usr))
		M = usr

	while(caught_bees > 0)
		//release a few super massive swarms
		while(caught_bees > 5)
			var/mob/living/simple_animal/bee/B = new(src.loc)
			B.feral = 5
			B.target_mob = M
			B.strength = 6
			B.icon_state = "bees_swarm"
			caught_bees -= 6

		//what's left over
		var/mob/living/simple_animal/bee/B = new(src.loc)
		B.strength = caught_bees
		B.icon_state = "bees[B.strength]"
		B.feral = 5
		B.target_mob = M

		caught_bees = 0

/obj/item/apiary
	name = "moveable apiary"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "apiary_item"
	item_state = "giftbag"
	w_class = 5

/obj/item/beezeez
	name = "bottle of BeezEez"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	flags = FPRINT |  TABLEPASS
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/weapon/reagent_containers/food/snacks/honeycomb
	name = "honeycomb"
	icon_state = "honeycomb"
	desc = "Dripping with sugary sweetness."

	New()
		..()

/obj/item/weapon/reagent_containers/food/snacks/honeycomb/New()
	..()
	reagents.add_reagent("honey",10)
	reagents.add_reagent("nutriment", 0.5)
	reagents.add_reagent("sugar", 2)
	bitesize = 2

/datum/reagent/honey
	name = "Honey"
	id = "honey"
	description = "A golden yellow syrup, loaded with sugary sweetness."
	color = "#FFFF00"

/obj/item/weapon/book/manual/hydroponics_beekeeping
	name = "The Ins and Outs of Apiculture - A Precise Art"
	icon_state ="bookHydroponicsBees"
	author = "Beekeeper Dave"
	title = "The Ins and Outs of Apiculture - A Precise Art"
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h3>Raising Bees</h3>

				Bees are loving but fickle creatures. Don't mess with their hive and stay away from any clusters of them, and you'll avoid their ire.
				Sometimes, you'll need to dig around in there for those delicious sweeties though - in that case make sure you wear sealed protection gear
				and carry an extinguisher or smoker with you - any bees chasing you, once calmed down, can thusly be netted and returned safely to the hive.<br.
				<br>
				Beezeez is a cure-all panacea for them, but use it too much and the hive may grow to apocalyptic proportions. Other than that, bees are excellent pets
				for all the family and are excellent caretakers of one's garden: having a hive or two around will aid in the longevity and growth rate of plants,
				and aid them in fighting off poisons and disease.

				</body>
				</html>
				"}
