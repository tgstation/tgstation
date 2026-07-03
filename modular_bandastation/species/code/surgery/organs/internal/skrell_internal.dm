/obj/item/organ/brain/skrell
	icon = 'icons/bandastation/mob/species/skrell/organs.dmi'

/obj/item/organ/eyes/skrell
	name = "skrell eyeballs"
	desc = "Глаза синеватого оттенка, но по своей структуре - глаза обычного гуманоида."
	icon = 'icons/bandastation/mob/species/skrell/organs.dmi'
	synchronized_blinking = FALSE
	eye_icon_state = "skrell_eyes"

/obj/item/organ/tongue/skrell
	name = "skrell tongue"
	desc = "Склизкий язык скрелла."
	languages_native = list(/datum/language/qurvolious)
	liked_foodtypes = VEGETABLES | FRUIT
	disliked_foodtypes = SEAFOOD
	toxic_foodtypes = ALCOHOL | MEAT

/obj/item/organ/tongue/get_possible_languages()
	return ..() + /datum/language/qurvolious

/obj/item/organ/heart/skrell
	name = "skrell heart"
	icon = 'icons/bandastation/mob/species/skrell/organs.dmi'

/obj/item/organ/lungs/skrell
	name = "skrell lungs"
	icon = 'icons/bandastation/mob/species/skrell/organs.dmi'

/obj/item/organ/stomach/skrell
	name = "skrell stomach"
	icon = 'icons/bandastation/mob/species/skrell/organs.dmi'

/obj/item/organ/liver/skrell
	name = "skrell liver"
	icon = 'icons/bandastation/mob/species/skrell/organs.dmi'
	alcohol_tolerance = ALCOHOL_RATE * 4
