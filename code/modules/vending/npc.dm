/obj/machinery/vending/npc
	name = "Vending NPC"
	desc = "Come buy some!"
	circuit = null
	tiltable = FALSE
	payment_department = NO_FREEBIES
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	integrity_failure = 0
	light_power = 0
	light_range = 0
	verb_say = "says"
	verb_ask = "asks"
	verb_exclaim = "exclaims"
	speech_span = null
	age_restrictions = FALSE
	use_power = NO_POWER_USE
	onstation_override = TRUE
	vending_sound = 'sound/effects/cashregister.ogg'
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "faceless"
	var/corpse

/obj/machinery/vending/npc/Initialize()
	. = ..()
	QDEL_NULL(wires)
	QDEL_NULL(coin)
	QDEL_NULL(bill)
	QDEL_NULL(Radio)

/obj/machinery/vending/npc/attackby(obj/item/I, mob/user, params)
	return

/obj/machinery/vending/npc/Destroy()
	if(corpse)
		new corpse(src)
	return ..()

/obj/machinery/vending/npc/deconstruct(disassembled = TRUE)
	if(corpse)
		new corpse(src)
	qdel(src)

/obj/machinery/vending/npc/loadingAttempt(obj/item/I, mob/user)
	return

/obj/machinery/vending/npc/emag_act(mob/user)
	return

/obj/machinery/vending/npc/mrbones
	name = "Mr. Bones"
	desc = "The ride never ends!"
	verb_say = "rattles"
	vending_sound = 'sound/voice/hiss2.ogg'
	speech_span = SPAN_SANS
	default_price = 500
	extra_price = 1000
	products = list(/obj/item/clothing/head/helmet/skull = 1,
					/obj/item/clothing/mask/bandana/skull = 1,
					/obj/item/reagent_containers/food/snacks/sugarcookie/spookyskull = 5,
					/obj/item/reagent_containers/food/condiment/milk = 5,
					/obj/item/instrument/trombone/spectral = 1
					)
	product_ads = "Why's there so little traffic, is this a skeleton crew?;You should buy like there's no to-marrow!"
	vend_reply = "Bone appetit!"
	icon_state = "skeleton"
	gender = MALE
	corpse = /obj/effect/mob_spawn/human/skeleton/mrbones

/obj/effect/mob_spawn/human/skeleton/mrbones
	mob_name = "Mr. Bones"
	mob_gender = MALE
