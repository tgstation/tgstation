//garnishes, an item that if used on a modglass, will apply its garnish_state to it
/obj/item/garnish
	name = "garnish"
	desc = "you should not see this"
	icon = 'monkestation/code/modules/modular_bartending/icons/modglass_garnishes_items.dmi'
	icon_state = "rim"
	w_class = WEIGHT_CLASS_SMALL
	var/garnish_state = "rim"
	var/garnish_layer = GARNISH_RIM

/obj/item/garnish/Initialize(mapload, amount)
	. = ..()
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3) //randomize a little

//rim garnishes, these go on the bottom
//sprites for rim garnishes must be split into two halves, one with normal naming, the other with -top appended to it
//this will allow it to layer over things inside the glass
/obj/item/garnish/salt
	name = "salt garnish"
	desc = "Harvested from the tears of the saltiest assistant."

/obj/item/garnish/ash
	name = "ash garnish"
	desc = "But why would you do this though."
	icon_state = "drim"
	garnish_state = "drim"

/obj/item/garnish/puce
	name = "puce garnish"
	desc = "Get some puce in your drink."
	icon_state = "puce"
	garnish_state = "puce"

/obj/item/garnish/crystal
	name = "strange crystal garnish"
	desc = "I'm sure nothing could possibly go wrong."
	icon_state = "crystal"
	garnish_state = "crystal"

/obj/item/garnish/wire
	name = "stripped wire"
	desc = "This seems like a perfectly normal thing to put on your drinks."
	icon_state = "wire"
	garnish_state = "wire"

/obj/item/garnish/gold
	name = "gold trim"
	desc = "Give your drinks that first-class flair!"
	icon_state = "gold"
	garnish_state = "gold"

/obj/item/garnish/silver
	name = "silver trim"
	desc = "Give your drinks that second-class flair!"
	icon_state = "silver"
	garnish_state = "silver"

//center garnishes, none of these exist yet, but when they do, put them here

//right side garnishes, these go above the rim and center garnishes, but below all others
/obj/item/garnish/lime
	name = "lime wedge"
	desc = "A classic topping for your drink."
	icon_state = "lime"
	garnish_state = "lime"
	garnish_layer = GARNISH_RIGHT

/obj/item/garnish/lemon
	name = "lemon wedge"
	desc = "A classic topping for your drink."
	icon_state = "lemon"
	garnish_state = "lemon"
	garnish_layer = GARNISH_RIGHT

/obj/item/garnish/orange
	name = "orange wedge"
	desc = "A classic topping for your drink."
	icon_state = "orange"
	garnish_state = "orange"
	garnish_layer = GARNISH_RIGHT

/obj/item/garnish/cherry
	name = "bunch of cherries"
	desc = "A classic topping for your drink."
	icon_state = "cherry"
	garnish_state = "cherry"
	garnish_layer = GARNISH_RIGHT

//left side garnishes, these go above both the rim, center, and right side
/obj/item/garnish/olives
	name = "skewered olives"
	desc = "This would look good in a martini."
	icon_state = "olives"
	garnish_state = "olives"
	garnish_layer = GARNISH_LEFT
	force = 3
	attack_verb_continuous = list("pokes", "jabs")
	attack_verb_simple = list("poke", "jab")
	sharpness = SHARP_POINTY
	throwforce = 3
	throw_speed = 1
	embedding = EMBED_HARMLESS

/obj/item/garnish/umbrellared
	name = "red drink umbrella"
	desc = "A cute little umbrella to go in your drink. This one is light red, <i>not</i> pink."
	icon_state = "umbrellared"
	garnish_state = "umbrellared"
	garnish_layer = GARNISH_LEFT

/obj/item/garnish/umbrellablue
	name = "blue drink umbrella"
	desc = "A cute little umbrella to go in your drink. This one is blue."
	icon_state = "umbrellablue"
	garnish_state = "umbrellablue"
	garnish_layer = GARNISH_LEFT

/obj/item/garnish/umbrellagreen
	name = "green drink umbrella"
	desc = "A cute little umbrella to go in your drink. This one is green."
	icon_state = "umbrellagreen"
	garnish_state = "umbrellagreen"
	garnish_layer = GARNISH_LEFT

/obj/item/garnish/red_straw
	name = "striped straw"
	desc = "A cute straw for a drink."
	icon_state = "straw-red"
	garnish_state = "straw-red"
	garnish_layer = GARNISH_LEFT

/obj/item/garnish/straw
	name = "straw"
	desc = "A cute straw for a drink."
	icon_state = "straw"
	garnish_state = "straw"
	garnish_layer = GARNISH_RIGHT

/obj/item/garnish/foam
	name = "decorative foam"
	desc = "Some food safe fake foam to add to drinks to make them look nicer."
	icon_state = "foam"
	garnish_state = "foam"
	garnish_layer = GARNISH_ABOVE_RIM

/obj/item/garnish/cherrytopper
	name = "cherry topper"
	desc = "Some pierced cherries on a stick."
	icon_state = "cherrytopper"
	garnish_state = "cherrytopper"
	garnish_layer = GARNISH_ABOVE_RIM
