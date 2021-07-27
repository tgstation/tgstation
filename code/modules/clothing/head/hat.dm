/obj/item/clothing/head/centhat
	name = "\improper CentCom hat"
	icon_state = "centcom"
	desc = "It's good to be emperor."
	inhand_icon_state = "that"
	flags_inv = 0
	armor = list(MELEE = 30, BULLET = 15, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	strip_delay = 80

/obj/item/clothing/head/spacepolice
	name = "space police cap"
	desc = "A blue cap for patrolling the daily beat."
	icon_state = "policecap_families"
	inhand_icon_state = "policecap_families"

/obj/item/clothing/head/canada
	name = "striped red tophat"
	desc = "It smells like fresh donut holes. / <i>Il sent comme des trous de beignets frais.</i>"
	icon_state = "canada"
	inhand_icon_state = "canada"

/obj/item/clothing/head/redcoat
	name = "redcoat's hat"
	icon_state = "redcoat"
	desc = "<i>'I guess it's a redhead.'</i>"

/obj/item/clothing/head/mailman
	name = "mailman's hat"
	icon_state = "mailman"
	desc = "<i>'Right-on-time'</i> mail service head wear."

/obj/item/clothing/head/plaguedoctorhat
	name = "plague doctor's hat"
	desc = "These were once used by plague doctors. They're pretty much useless."
	icon_state = "plaguedoctor"
	permeability_coefficient = 0.01

/obj/item/clothing/head/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/nurse

/obj/item/clothing/head/bowler
	name = "bowler-hat"
	desc = "Gentleman, elite aboard!"
	icon_state = "bowler"
	inhand_icon_state = "bowler"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/bearpelt
	name = "bear pelt hat"
	desc = "Fuzzy."
	icon_state = "bearpelt"
	inhand_icon_state = "bearpelt"

/obj/item/clothing/head/fedora
	name = "fedora"
	icon_state = "fedora"
	inhand_icon_state = "fedora"
	desc = "A really cool hat if you're a mobster. A really lame hat if you're not."
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small/fedora

/obj/item/clothing/head/fedora/white
	name = "white fedora"
	icon_state = "fedora_white"
	inhand_icon_state = "fedora_white"

/obj/item/clothing/head/fedora/beige
	name = "beige fedora"
	icon_state = "fedora_beige"
	inhand_icon_state = "fedora_beige"

/obj/item/clothing/head/fedora/suicide_act(mob/user)
	if(user.gender == FEMALE)
		return 0
	var/mob/living/carbon/human/H = user
	user.visible_message(span_suicide("[user] is donning [src]! It looks like [user.p_theyre()] trying to be nice to girls."))
	user.say("M'lady.", forced = "fedora suicide")
	sleep(10)
	H.facial_hairstyle = "Neckbeard"
	return(BRUTELOSS)

/obj/item/clothing/head/sombrero
	name = "sombrero"
	icon_state = "sombrero"
	inhand_icon_state = "sombrero"
	desc = "You can practically taste the fiesta."
	flags_inv = HIDEHAIR

	dog_fashion = /datum/dog_fashion/head/sombrero

	greyscale_config = /datum/greyscale_config/sombrero
	greyscale_config_worn = /datum/greyscale_config/sombrero/worn
	greyscale_config_inhand_left = /datum/greyscale_config/sombrero/lefthand
	greyscale_config_inhand_right = /datum/greyscale_config/sombrero/righthand

/obj/item/clothing/head/sombrero/green
	name = "green sombrero"
	desc = "As elegant as a dancing cactus."
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	dog_fashion = null
	greyscale_colors = "#13d968#ffffff"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/sombrero/shamebrero
	name = "shamebrero"
	icon_state = "shamebrero"
	inhand_icon_state = "shamebrero"
	desc = "Once it's on, it never comes off."
	dog_fashion = null
	greyscale_colors = "#d565d3#f8db18"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/sombrero/shamebrero/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SHAMEBRERO_TRAIT)

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "beret_flat"
	greyscale_config = /datum/greyscale_config/beret
	greyscale_config_worn = /datum/greyscale_config/beret/worn
	greyscale_colors = "#8F7654"
	inhand_icon_state = "detective"

/obj/item/clothing/head/hunter
	name = "bounty hunting hat"
	desc = "Ain't nobody gonna cheat the hangman in my town."
	icon_state = "cowboy"
	worn_icon_state = "hunter"
	inhand_icon_state = "hunter"
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 15, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/santa
	name = "santa hat"
	desc = "On the first day of christmas my employer gave to me!"
	icon_state = "santahatnorm"
	inhand_icon_state = "that"
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	dog_fashion = /datum/dog_fashion/head/santa

/obj/item/clothing/head/jester
	name = "jester hat"
	desc = "A hat with bells, to add some merriness to the suit."
	icon_state = "jester_hat"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/jester/alt
	icon_state = "jester2"

/obj/item/clothing/head/rice_hat
	name = "rice hat"
	desc = "Welcome to the rice fields, motherfucker."
	icon_state = "rice_hat"

/obj/item/clothing/head/lizard
	name = "lizardskin cloche hat"
	desc = "How many lizards died to make this hat? Not enough."
	icon_state = "lizard"

/obj/item/clothing/head/crown
	name = "crown"
	desc = "A crown fit for a king, a petty king maybe."
	icon_state = "crown"
	armor = list(MELEE = 15, BULLET = 0, LASER = 0,ENERGY = 10, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50, WOUND = 5)
	resistance_flags = FIRE_PROOF
	dynamic_hair_suffix = ""

/obj/item/clothing/head/crown/fancy
	name = "magnificent crown"
	desc = "A crown worn by only the highest emperors of the <s>land</s> space."
	icon_state = "fancycrown"

/obj/item/clothing/head/scarecrow_hat
	name = "scarecrow hat"
	desc = "A simple straw hat."
	icon_state = "scarecrow_hat"

/obj/item/clothing/head/pharaoh
	name = "pharaoh hat"
	desc = "Walk like an Egyptian."
	icon_state = "pharoah_hat"
	inhand_icon_state = "pharoah_hat"

/obj/item/clothing/head/nemes
	name = "headdress of Nemes"
	desc = "Lavish space tomb not included."
	icon_state = "nemes_headdress"

/obj/item/clothing/head/delinquent
	name = "delinquent hat"
	desc = "Good grief."
	icon_state = "delinquent"

/obj/item/clothing/head/clownmitre
	name = "Hat of the Honkmother"
	desc = "It's hard for parishoners to see a banana peel on the floor when they're looking up at your glorious chapeau."
	icon_state = "clownmitre"

/obj/item/clothing/head/kippah
	name = "kippah"
	desc = "Signals that you follow the Jewish Halakha. Keeps the head covered and the soul extra-Orthodox."
	icon_state = "kippah"

/obj/item/clothing/head/medievaljewhat
	name = "medieval Jewish hat"
	desc = "A silly looking hat, intended to be placed on the heads of the station's oppressed religious minorities."
	icon_state = "medievaljewhat"

/obj/item/clothing/head/taqiyahwhite
	name = "white taqiyah"
	desc = "An extra-mustahabb way of showing your devotion to Allah."
	icon_state = "taqiyahwhite"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small

/obj/item/clothing/head/taqiyahred
	name = "red taqiyah"
	desc = "An extra-mustahabb way of showing your devotion to Allah."
	icon_state = "taqiyahred"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small

/obj/item/clothing/head/intern
	name = "\improper CentCom Head Intern beancap"
	desc = "A horrifying mix of beanie and softcap in CentCom green. You'd have to be pretty desperate for power over your peers to agree to wear this."
	icon_state = "intern_hat"
	inhand_icon_state = "intern_hat"

/obj/item/clothing/head/coordinator
	name = "coordinator cap"
	desc = "A cap for a party coordinator, stylish!."
	icon_state = "capcap"
	inhand_icon_state = "that"
	armor = list(MELEE = 25, BULLET = 15, LASER = 25, ENERGY = 35, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/head/jackbros
	name = "frosty hat"
	desc = "Hee-ho!"
	icon_state = "JackFrostHat"
	inhand_icon_state = "JackFrostHat"

/obj/item/clothing/head/weddingveil
	name = "wedding veil"
	desc = "A gauzy white veil."
	icon_state = "weddingveil"
	inhand_icon_state = "weddingveil"

/obj/item/clothing/head/centcom_cap
	name = "\improper CentCom commander cap"
	icon_state = "centcom_cap"
	desc = "Worn by the finest of CentCom commanders. Inside the lining of the cap, lies two faint initials."
	inhand_icon_state = "that"
	flags_inv = 0
	armor = list(MELEE = 30, BULLET = 15, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	strip_delay = (8 SECONDS)

/obj/item/clothing/head/human_leather
	name = "human skin hat"
	desc = "This will scare them. All will know my power."
	icon_state = "human_leather"
	inhand_icon_state = "human_leather"

/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushankadown"
	inhand_icon_state = "ushankadown"
	flags_inv = HIDEEARS|HIDEHAIR
	var/earflaps = TRUE
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT

	dog_fashion = /datum/dog_fashion/head/ushanka

/obj/item/clothing/head/ushanka/attack_self(mob/user)
	if(earflaps)
		icon_state = "ushankaup"
		inhand_icon_state = "ushankaup"
		to_chat(user, span_notice("You raise the ear flaps on the ushanka."))
	else
		icon_state = "ushankadown"
		inhand_icon_state = "ushankadown"
		to_chat(user, span_notice("You lower the ear flaps on the ushanka."))
	earflaps = !earflaps
