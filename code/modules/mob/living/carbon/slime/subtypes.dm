
////////////////Tier 2

/mob/living/carbon/slime/purple
	colour = "purple"
	icon_state = "purple baby slime"
	primarytype = /mob/living/carbon/slime/purple
	adulttype = /mob/living/carbon/slime/adult/purple
	coretype = /obj/item/slime_extract/purple


/mob/living/carbon/slime/adult/purple
	icon_state = "purple adult slime"
	colour = "purple"
	primarytype = /mob/living/carbon/slime/purple
	adulttype = /mob/living/carbon/slime/adult/purple
	coretype = /obj/item/slime_extract/purple

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/darkpurple
		slime_mutation[2] = /mob/living/carbon/slime/darkblue
		slime_mutation[3] = /mob/living/carbon/slime/green
		slime_mutation[4] = /mob/living/carbon/slime/green

/mob/living/carbon/slime/metal
	colour = "metal"
	icon_state = "metal baby slime"
	primarytype = /mob/living/carbon/slime/metal
	adulttype = /mob/living/carbon/slime/adult/metal
	coretype = /obj/item/slime_extract/metal

/mob/living/carbon/slime/adult/metal
	icon_state = "metal adult slime"
	colour = "metal"
	primarytype = /mob/living/carbon/slime/metal
	adulttype = /mob/living/carbon/slime/adult/metal
	coretype = /obj/item/slime_extract/metal

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/silver
		slime_mutation[2] = /mob/living/carbon/slime/yellow
		slime_mutation[3] = /mob/living/carbon/slime/gold
		slime_mutation[4] = /mob/living/carbon/slime/gold

/mob/living/carbon/slime/orange
	colour = "orange"
	icon_state = "orange baby slime"
	primarytype = /mob/living/carbon/slime/orange
	adulttype = /mob/living/carbon/slime/adult/orange
	coretype = /obj/item/slime_extract/orange

/mob/living/carbon/slime/adult/orange
	colour = "orange"
	icon_state = "orange adult slime"
	primarytype = /mob/living/carbon/slime/orange
	adulttype = /mob/living/carbon/slime/adult/orange
	coretype = /obj/item/slime_extract/orange

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/red
		slime_mutation[2] = /mob/living/carbon/slime/red
		slime_mutation[3] = /mob/living/carbon/slime/darkpurple
		slime_mutation[4] = /mob/living/carbon/slime/yellow

/mob/living/carbon/slime/blue
	colour = "blue"
	icon_state = "blue baby slime"
	primarytype = /mob/living/carbon/slime/blue
	adulttype = /mob/living/carbon/slime/adult/blue
	coretype = /obj/item/slime_extract/blue

/mob/living/carbon/slime/adult/blue
	icon_state = "blue adult slime"
	colour = "blue"
	primarytype = /mob/living/carbon/slime/blue
	adulttype = /mob/living/carbon/slime/adult/blue
	coretype = /obj/item/slime_extract/blue

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/darkblue
		slime_mutation[2] = /mob/living/carbon/slime/pink
		slime_mutation[3] = /mob/living/carbon/slime/pink
		slime_mutation[4] = /mob/living/carbon/slime/silver


//Tier 3

/mob/living/carbon/slime/darkblue
	colour = "dark blue"
	icon_state = "dark blue baby slime"
	primarytype = /mob/living/carbon/slime/darkblue
	adulttype = /mob/living/carbon/slime/adult/darkblue
	coretype = /obj/item/slime_extract/darkblue

/mob/living/carbon/slime/adult/darkblue
	icon_state = "dark blue adult slime"
	colour = "dark blue"
	primarytype = /mob/living/carbon/slime/darkblue
	adulttype = /mob/living/carbon/slime/adult/darkblue
	coretype = /obj/item/slime_extract/darkblue

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/purple
		slime_mutation[2] = /mob/living/carbon/slime/cerulean
		slime_mutation[3] = /mob/living/carbon/slime/blue
		slime_mutation[4] = /mob/living/carbon/slime/cerulean

/mob/living/carbon/slime/darkpurple
	colour = "dark purple"
	icon_state = "dark purple baby slime"
	primarytype = /mob/living/carbon/slime/darkpurple
	adulttype = /mob/living/carbon/slime/adult/darkpurple
	coretype = /obj/item/slime_extract/darkpurple

/mob/living/carbon/slime/adult/darkpurple
	icon_state = "dark purple adult slime"
	colour = "dark purple"
	primarytype = /mob/living/carbon/slime/darkpurple
	adulttype = /mob/living/carbon/slime/adult/darkpurple
	coretype = /obj/item/slime_extract/darkpurple

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/purple
		slime_mutation[2] = /mob/living/carbon/slime/sepia
		slime_mutation[3] = /mob/living/carbon/slime/orange
		slime_mutation[4] = /mob/living/carbon/slime/sepia


/mob/living/carbon/slime/yellow
	icon_state = "yellow baby slime"
	colour = "yellow"
	primarytype = /mob/living/carbon/slime/yellow
	adulttype = /mob/living/carbon/slime/adult/yellow
	coretype = /obj/item/slime_extract/yellow

/mob/living/carbon/slime/adult/yellow
	icon_state = "yellow adult slime"
	colour = "yellow"
	primarytype = /mob/living/carbon/slime/yellow
	adulttype = /mob/living/carbon/slime/adult/yellow
	coretype = /obj/item/slime_extract/yellow

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/metal
		slime_mutation[2] = /mob/living/carbon/slime/bluespace
		slime_mutation[3] = /mob/living/carbon/slime/orange
		slime_mutation[4] = /mob/living/carbon/slime/bluespace


/mob/living/carbon/slime/silver
	colour = "silver"
	icon_state = "silver baby slime"
	primarytype = /mob/living/carbon/slime/silver
	adulttype = /mob/living/carbon/slime/adult/silver
	coretype = /obj/item/slime_extract/silver

/mob/living/carbon/slime/adult/silver
	icon_state = "silver adult slime"
	colour = "silver"
	primarytype = /mob/living/carbon/slime/silver
	adulttype = /mob/living/carbon/slime/adult/silver
	coretype = /obj/item/slime_extract/silver

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/metal
		slime_mutation[2] = /mob/living/carbon/slime/pyrite
		slime_mutation[3] = /mob/living/carbon/slime/blue
		slime_mutation[4] = /mob/living/carbon/slime/pyrite


/////////////Tier 4


/mob/living/carbon/slime/pink
	colour = "pink"
	icon_state = "pink baby slime"
	primarytype = /mob/living/carbon/slime/pink
	adulttype = /mob/living/carbon/slime/adult/pink
	coretype = /obj/item/slime_extract/pink

/mob/living/carbon/slime/adult/pink
	icon_state = "pink adult slime"
	colour = "pink"
	primarytype = /mob/living/carbon/slime/pink
	adulttype = /mob/living/carbon/slime/adult/pink
	coretype = /obj/item/slime_extract/pink

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/pink
		slime_mutation[2] = /mob/living/carbon/slime/pink
		slime_mutation[3] = /mob/living/carbon/slime/lightpink
		slime_mutation[4] = /mob/living/carbon/slime/lightpink

/mob/living/carbon/slime/red
	colour = "red"
	icon_state = "red baby slime"
	primarytype = /mob/living/carbon/slime/red
	adulttype = /mob/living/carbon/slime/adult/red
	coretype = /obj/item/slime_extract/red

/mob/living/carbon/slime/adult/red
	icon_state = "red adult slime"
	colour = "red"
	primarytype = /mob/living/carbon/slime/red
	adulttype = /mob/living/carbon/slime/adult/red
	coretype = /obj/item/slime_extract/red

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/red
		slime_mutation[2] = /mob/living/carbon/slime/red
		slime_mutation[3] = /mob/living/carbon/slime/oil
		slime_mutation[4] = /mob/living/carbon/slime/oil

/mob/living/carbon/slime/gold
	colour = "gold"
	icon_state = "gold baby slime"
	primarytype = /mob/living/carbon/slime/gold
	adulttype = /mob/living/carbon/slime/adult/gold
	coretype = /obj/item/slime_extract/gold

/mob/living/carbon/slime/adult/gold
	icon_state = "gold adult slime"
	colour = "gold"
	primarytype = /mob/living/carbon/slime/gold
	adulttype = /mob/living/carbon/slime/adult/gold
	coretype = /obj/item/slime_extract/gold

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/gold
		slime_mutation[2] = /mob/living/carbon/slime/gold
		slime_mutation[3] = /mob/living/carbon/slime/adamantine
		slime_mutation[4] = /mob/living/carbon/slime/adamantine

/mob/living/carbon/slime/green
	colour = "green"
	icon_state = "green baby slime"
	primarytype = /mob/living/carbon/slime/green
	adulttype = /mob/living/carbon/slime/adult/green
	coretype = /obj/item/slime_extract/green

/mob/living/carbon/slime/adult/green
	icon_state = "green adult slime"
	colour = "green"
	primarytype = /mob/living/carbon/slime/green
	adulttype = /mob/living/carbon/slime/adult/green
	coretype = /obj/item/slime_extract/green

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/green
		slime_mutation[2] = /mob/living/carbon/slime/green
		slime_mutation[3] = /mob/living/carbon/slime/black
		slime_mutation[4] = /mob/living/carbon/slime/black

// Tier 5

/mob/living/carbon/slime/lightpink
	colour = "light pink"
	icon_state = "light pink baby slime"
	primarytype = /mob/living/carbon/slime/lightpink
	adulttype = /mob/living/carbon/slime/adult/lightpink
	coretype = /obj/item/slime_extract/lightpink

/mob/living/carbon/slime/adult/lightpink
	icon_state = "light pink adult slime"
	colour = "light pink"
	primarytype = /mob/living/carbon/slime/lightpink
	adulttype = /mob/living/carbon/slime/adult/lightpink
	coretype = /obj/item/slime_extract/lightpink

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/lightpink
		slime_mutation[2] = /mob/living/carbon/slime/lightpink
		slime_mutation[3] = /mob/living/carbon/slime/lightpink
		slime_mutation[4] = /mob/living/carbon/slime/lightpink

/mob/living/carbon/slime/oil
	icon_state = "oil baby slime"
	colour = "oil"
	primarytype = /mob/living/carbon/slime/oil
	adulttype = /mob/living/carbon/slime/adult/oil
	coretype = /obj/item/slime_extract/oil

/mob/living/carbon/slime/adult/oil
	icon_state = "oil adult slime"
	colour = "oil"
	primarytype = /mob/living/carbon/slime/oil
	adulttype = /mob/living/carbon/slime/adult/oil
	coretype = /obj/item/slime_extract/oil

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/oil
		slime_mutation[2] = /mob/living/carbon/slime/oil
		slime_mutation[3] = /mob/living/carbon/slime/oil
		slime_mutation[4] = /mob/living/carbon/slime/oil

/mob/living/carbon/slime/black
	icon_state = "black baby slime"
	colour = "black"
	primarytype = /mob/living/carbon/slime/black
	adulttype = /mob/living/carbon/slime/adult/black
	coretype = /obj/item/slime_extract/black

/mob/living/carbon/slime/adult/black
	icon_state = "black adult slime"
	colour = "black"
	primarytype = /mob/living/carbon/slime/black
	adulttype = /mob/living/carbon/slime/adult/black
	coretype = /obj/item/slime_extract/black

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/black
		slime_mutation[2] = /mob/living/carbon/slime/black
		slime_mutation[3] = /mob/living/carbon/slime/black
		slime_mutation[4] = /mob/living/carbon/slime/black

/mob/living/carbon/slime/adamantine
	icon_state = "adamantine baby slime"
	colour = "adamantine"
	primarytype = /mob/living/carbon/slime/adamantine
	adulttype = /mob/living/carbon/slime/adult/adamantine
	coretype = /obj/item/slime_extract/adamantine

/mob/living/carbon/slime/adult/adamantine
	icon_state = "adamantine adult slime"
	colour = "adamantine"
	primarytype = /mob/living/carbon/slime/adamantine
	adulttype = /mob/living/carbon/slime/adult/adamantine
	coretype = /obj/item/slime_extract/adamantine

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/adamantine
		slime_mutation[2] = /mob/living/carbon/slime/adamantine
		slime_mutation[3] = /mob/living/carbon/slime/adamantine
		slime_mutation[4] = /mob/living/carbon/slime/adamantine

////////// Even in death I still code Tier //////////////

/mob/living/carbon/slime/bluespace
	icon_state = "bluespace baby slime"
	colour = "bluespace"
	primarytype = /mob/living/carbon/slime/bluespace
	adulttype = /mob/living/carbon/slime/adult/bluespace
	coretype = /obj/item/slime_extract/bluespace

/mob/living/carbon/slime/adult/bluespace
	icon_state = "bluespace adult slime"
	colour = "bluespace"
	primarytype = /mob/living/carbon/slime/bluespace
	adulttype = /mob/living/carbon/slime/adult/bluespace
	coretype = /obj/item/slime_extract/bluespace

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/bluespace
		slime_mutation[2] = /mob/living/carbon/slime/bluespace
		slime_mutation[3] = /mob/living/carbon/slime/bluespace
		slime_mutation[4] = /mob/living/carbon/slime/bluespace

/mob/living/carbon/slime/pyrite
	icon_state = "pyrite baby slime"
	colour = "pyrite"
	primarytype = /mob/living/carbon/slime/pyrite
	adulttype = /mob/living/carbon/slime/adult/pyrite
	coretype = /obj/item/slime_extract/pyrite

/mob/living/carbon/slime/adult/pyrite
	icon_state = "pyrite adult slime"
	colour = "pyrite"
	primarytype = /mob/living/carbon/slime/pyrite
	adulttype = /mob/living/carbon/slime/adult/pyrite
	coretype = /obj/item/slime_extract/pyrite

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/pyrite
		slime_mutation[2] = /mob/living/carbon/slime/pyrite
		slime_mutation[3] = /mob/living/carbon/slime/pyrite
		slime_mutation[4] = /mob/living/carbon/slime/pyrite

/mob/living/carbon/slime/cerulean
	icon_state = "cerulean baby slime"
	colour = "cerulean"
	primarytype = /mob/living/carbon/slime/cerulean
	adulttype = /mob/living/carbon/slime/adult/cerulean
	coretype = /obj/item/slime_extract/cerulean

/mob/living/carbon/slime/adult/cerulean
	icon_state = "cerulean adult slime"
	colour = "cerulean"
	primarytype = /mob/living/carbon/slime/cerulean
	adulttype = /mob/living/carbon/slime/adult/cerulean
	coretype = /obj/item/slime_extract/cerulean

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/cerulean
		slime_mutation[2] = /mob/living/carbon/slime/cerulean
		slime_mutation[3] = /mob/living/carbon/slime/cerulean
		slime_mutation[4] = /mob/living/carbon/slime/cerulean

/mob/living/carbon/slime/sepia
	icon_state = "sepia baby slime"
	colour = "sepia"
	primarytype = /mob/living/carbon/slime/sepia
	adulttype = /mob/living/carbon/slime/adult/sepia
	coretype = /obj/item/slime_extract/sepia

/mob/living/carbon/slime/adult/sepia
	icon_state = "sepia adult slime"
	colour = "sepia"
	primarytype = /mob/living/carbon/slime/sepia
	adulttype = /mob/living/carbon/slime/adult/sepia
	coretype = /obj/item/slime_extract/sepia

	New()
		..()
		slime_mutation[1] = /mob/living/carbon/slime/sepia
		slime_mutation[2] = /mob/living/carbon/slime/sepia
		slime_mutation[3] = /mob/living/carbon/slime/sepia
		slime_mutation[4] = /mob/living/carbon/slime/sepia