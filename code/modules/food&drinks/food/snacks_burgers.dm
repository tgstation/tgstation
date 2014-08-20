/obj/item/weapon/reagent_containers/food/snacks/burger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/burger/human
	var/hname = ""
	var/job = null
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/appendix
	name = "appendix burger"
	desc = "Tastes like appendicitis."

/obj/item/weapon/reagent_containers/food/snacks/burger/fish
	name = "fillet -o- carp sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/fish/New()
	..()
	reagents.add_reagent("carpotoxin", 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/burger/tofu
	name = "tofu burger"
	desc = "What.. is that meat?"
	icon_state = "tofuburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/roburger/New()
	..()
	reagents.add_reagent("nanites", 2)

/obj/item/weapon/reagent_containers/food/snacks/burger/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	volume = 106

/obj/item/weapon/reagent_containers/food/snacks/burger/roburgerbig/New()
	..()
	reagents.add_reagent("nanites", 100)
	bitesize = 0.1

/obj/item/weapon/reagent_containers/food/snacks/burger/xeno
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/xeno/New()
	..()
	reagents.add_reagent("nutriment", 2)

/obj/item/weapon/reagent_containers/food/snacks/burger/clown
	name = "clown burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/mime
	name = "mime burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/brain
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/brain/New()
	..()
	reagents.add_reagent("alkysine", 6)

/obj/item/weapon/reagent_containers/food/snacks/burger/ghost
	name = "ghost burger"
	desc = "Too Spooky!"
	alpha = 125

/obj/item/weapon/reagent_containers/food/snacks/burger/red
	name = "red burger"
	desc = "Perfect for hiding the fact it's burnt to a crisp."
	icon_state = "cburger"
	color = "#DA0000FF"

/obj/item/weapon/reagent_containers/food/snacks/burger/red/New()
	..()
	reagents.add_reagent("redcrayonpowder", 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/burger/orange
	name = "orange burger"
	desc = "Contains 0% juice."
	icon_state = "cburger"
	color = "#FF9300FF"

/obj/item/weapon/reagent_containers/food/snacks/burger/orange/New()
	..()
	reagents.add_reagent("orangecrayonpowder", 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/burger/yellow
	name = "yellow burger"
	desc = "Bright to the last bite."
	icon_state = "cburger"
	color = "#FFF200FF"

/obj/item/weapon/reagent_containers/food/snacks/burger/yellow/New()
	..()
	reagents.add_reagent("yellowcrayonpowder", 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/burger/green
	name = "green burger"
	desc = "It's not tainted meat, it's painted meat!"
	icon_state = "cburger"
	color = "#A8E61DFF"

/obj/item/weapon/reagent_containers/food/snacks/burger/green/New()
	..()
	reagents.add_reagent("greencrayonpowder", 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/burger/blue
	name = "blue burger"
	desc = "Is this blue rare?"
	icon_state = "cburger"
	color = "#00B7EFFF"

/obj/item/weapon/reagent_containers/food/snacks/burger/blue/New()
	..()
	reagents.add_reagent("bluecrayonpowder", 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/burger/purple
	name = "purple burger"
	desc = "Regal and low class at the same time."
	icon_state = "cburger"
	color = "#DA00FFFF"

/obj/item/weapon/reagent_containers/food/snacks/burger/purple/New()
	..()
	reagents.add_reagent("purplecrayonpowder", 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/burger/spell
	name = "spell burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/bigbite
	name = "big bite burger"
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/bigbite/New()
	..()
	reagents.add_reagent("nutriment", 8)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/burger/jelly
	name = "jelly burger"
	desc = "Culinary delight..?"
	icon_state = "jellyburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/jelly/slime/New()
	..()
	reagents.add_reagent("slimejelly", 5)

/obj/item/weapon/reagent_containers/food/snacks/burger/jelly/cherry/New()
	..()
	reagents.add_reagent("cherryjelly", 5)

/obj/item/weapon/reagent_containers/food/snacks/burger/superbite
	name = "super bite burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"

/obj/item/weapon/reagent_containers/food/snacks/burger/superbite/New()
	..()
	reagents.add_reagent("nutriment", 40)
	bitesize = 10
