//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/service/janitor.dmi'
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	desc = "This is rubbish."
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	item_flags = NOBLUDGEON|SKIP_FANTASY_ON_SPAWN

/obj/item/trash/Initialize(mapload)
	var/turf/T = get_turf(src)
	if(T && is_station_level(T.z))
		SSblackbox.record_feedback("tally", "station_mess_created", 1, name)
	return ..()

/obj/item/trash/Destroy()
	var/turf/T = get_turf(src)
	if(T && is_station_level(T.z))
		SSblackbox.record_feedback("tally", "station_mess_destroyed", 1, name)
	return ..()

/obj/item/trash/raisins
	name = "\improper 4no raisins"
	icon_state= "4no_raisins"

/obj/item/trash/candy
	name = "candy"
	icon_state= "candy"

/obj/item/trash/cheesie
	name = "cheesie honkers"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "chips"
	icon_state = "chips"

/obj/item/trash/shrimp_chips
	name = "shrimp chips"
	icon_state = "shrimp_chips"

/obj/item/trash/boritos
	name = "boritos bag"
	icon_state = "boritos"
	grind_results = list(/datum/reagent/aluminium = 1) //from the mylar bag

/obj/item/trash/boritos/green
	icon_state = "boritosgreen"

/obj/item/trash/boritos/red
	icon_state = "boritosred"

/obj/item/trash/boritos/purple
	icon_state = "boritospurple"

/obj/item/trash/popcorn
	name = "popcorn"
	icon_state = "popcorn"

/obj/item/trash/popcorn/caramel
	name = "empty caramel popcorn"
	desc = "Now it's not a sweet snack, but just a sticky bag..."
	icon_state = "empty_caramel_popcorn"

/obj/item/trash/popcorn/salty
	name = "empty salty popcorn"
	desc = "It looks like there are only a few grains of salt left at the bottom of the bag..."
	icon_state = "empty_salty_popcorn"

/obj/item/trash/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"

/obj/item/trash/syndi_cakes
	name = "syndi-cakes"
	icon_state = "syndi_cakes"

/obj/item/trash/energybar
	name = "energybar wrapper"
	icon_state = "energybar"

/obj/item/trash/waffles
	name = "waffles tray"
	icon_state = "waffles"

/obj/item/trash/pistachios
	name = "pistachios pack"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "semki pack"
	icon_state = "semki_pack"

/obj/item/trash/semki/healthy
	name = "nibbled sunflower seeds"
	icon_state = "sunseeds"

/obj/item/trash/tray
	name = "tray"
	icon_state = "tray"
	resistance_flags = NONE

/obj/item/trash/candle
	name = "melted candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle4"

/obj/item/trash/flare
	name = "burnt flare"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flare-empty"

/obj/item/trash/can
	name = "crushed can"
	icon_state = "cola"
	resistance_flags = NONE
	grind_results = list(/datum/reagent/aluminium = 10)

/obj/item/trash/can/food
	icon = 'icons/obj/food/canned.dmi'
	icon_state = "peachcan_empty"

/obj/item/trash/can/food/peaches
	name = "canned peaches"
	icon_state = "peachcan_empty"

/obj/item/trash/can/food/peaches/maint
	name = "Maintenance Peaches"
	icon_state = "peachcanmaint_empty"

/obj/item/trash/can/food/beans
	name = "tin of beans"
	icon_state = "beans_empty"

/obj/item/trash/can/Initialize(mapload)
	. = ..()
	pixel_x = rand(-4,4)
	pixel_y = rand(-4,4)

/obj/item/trash/peanuts
	name = "\improper Gallery peanuts packet"
	desc = "This thread is trash!"
	icon_state = "peanuts"

/obj/item/trash/cnds
	name = "\improper C&Ds packet"
	icon_state = "cnds"

/obj/item/trash/can/food/envirochow
	name = "dog eat dog envirochow"
	icon_state = "envirochow_empty"

/obj/item/trash/can/food/tomatoes
	name = "canned San Marzano tomatoes"
	icon_state = "tomatoescan_empty"

/obj/item/trash/can/food/pine_nuts
	name = "canned pine nuts"
	icon_state = "pinenutscan_empty"

/obj/item/trash/can/food/jellyfish
	name = "canned gunner jellyfish"
	icon_state = "jellyfish_empty"

/obj/item/trash/can/food/desert_snails
	name = "canned desert snails"
	icon_state = "snails_empty"

/obj/item/trash/can/food/larvae
	name = "canned bee larva"
	icon_state = "larvae_empty"

/obj/item/trash/spacers_sidekick
	name = "\improper Spacer's Sidekick packet"
	icon_state = "spacers_sidekick"

/obj/item/trash/ready_donk
	name = "empty Ready-donk"
	desc = "It's been Donk-decimated."
	icon_state = "ready_donk"

/obj/item/trash/can/food/squid_ink
	name = "canned squid ink"
	icon_state = "squidinkcan_empty"

/obj/item/trash/can/food/chap
	name = "can of CHAP"
	icon_state = "chapcan_empty"

/obj/item/trash/hot_shots
	name = "\improper Hot Shots box"
	icon_state = "hot_shots"

/obj/item/trash/sticko
	name = "\improper Sticko box"
	icon_state = "sticko"

/obj/item/trash/sticko/matcha
	icon_state = "sticko_matcha"

/obj/item/trash/sticko/nutty
	icon_state = "sticko_nutty"

/obj/item/trash/sticko/pineapple
	icon_state = "sticko_pineapple"

/obj/item/trash/sticko/yuyake
	icon_state = "sticko_yuyake"

/obj/item/trash/shok_roks
	name = "\improper Shok-Roks packet"
	icon_state = "shok_roks"

/obj/item/trash/shok_roks/citrus
	icon_state = "shok_roks_citrus"

/obj/item/trash/shok_roks/berry
	icon_state = "shok_roks_berry"

/obj/item/trash/shok_roks/tropical
	icon_state = "shok_roks_tropical"

/obj/item/trash/shok_roks/lanternfruit
	icon_state = "shok_roks_lanternfruit"
