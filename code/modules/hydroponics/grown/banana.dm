// Banana
/obj/item/weapon/reagent_containers/food/snacks/grown/banana
	seed = /obj/item/seeds/bananaseed
	name = "banana"
	desc = "It's an excellent prop for a clown."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana"
	item_state = "banana"
	trash = /obj/item/weapon/grown/bananapeel
	filling_color = "#FFFF00"
	reagents_add = list("banana" = 0.1, "vitamin" = 0.04, "nutriment" = 0.02)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/banana/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is aiming the [src.name] at themself! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/items/bikehorn.ogg', 50, 1, -1)
	sleep(25)
	user.say("BANG!")
	sleep(25)
	user.visible_message("<B>[user]</B> laughs so hard they begin to suffocate!")
	return (OXYLOSS)


// Mimana
/obj/item/weapon/reagent_containers/food/snacks/grown/banana/mime
	seed = /obj/item/seeds/mimanaseed
	name = "mimana"
	desc = "It's an excellent prop for a mime."
	icon_state = "mimana"
	trash = /obj/item/weapon/grown/bananapeel/mimanapeel
	filling_color = "#FFFFEE"
	reagents_add = list("nothing" = 0.1, "mutetoxin" = 0.1, "nutriment" = 0.02)


// Bluespace Banana
/obj/item/weapon/reagent_containers/food/snacks/grown/banana/bluespace
	seed = /obj/item/seeds/bluespacebananaseed
	name = "bluespace banana"
	icon_state = "banana_blue"
	trash = /obj/item/weapon/grown/bananapeel/bluespace
	filling_color = "#0000FF"
	origin_tech = "bluespace=3"
	reagents_add = list("singulo" = 0.2, "banana" = 0.1, "vitamin" = 0.04, "nutriment" = 0.02)