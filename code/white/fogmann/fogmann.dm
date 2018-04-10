
/obj/item/banner/engineering/atmos
	name = "Kazakhstan banner"
	desc = "ГЃГ Г­Г­ГҐГ° ГЇГ°Г®Г±Г«Г ГўГ«ГїГѕГ№ГЁГ© ГўГҐГ«ГЁГЄГіГѕ Г¬Г®Г№Гј Г…Г«ГЎГ Г±Г»."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "banner_atmos"
	job_loyalties = list("Scientist", "Atmospheric Technician")
	warcry = "<b>ГЉГЂГ‡ГЂГ•Г‘Г’ГЂГЌ Г“ГѓГђГЋГ†ГЂГ…Г’ Г‚ГЂГЊ ГЃГЋГЊГЃГЂГђГ„Г€ГђГЋГ‚ГЉГЋГ‰!!</b>"


obj/item/banner/engineering/atmos/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/atmos_banner
	name = "Kazakhstan Banner"
	result = /obj/item/banner/engineering/atmos/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/atmospheric_technician = 1)
	category = CAT_MISC

/obj/item/stack/tile/carpet/peaks
	name = "peaks carpet"
	singular_name = "peaks carpet"
	desc = "A piece of carpet. It is the same size as a floor tile."
	icon = 'icons/obj/tiles.dmi'
	icon_state = "tile-carpet"
	turf_type = /turf/open/floor/carpet
	resistance_flags = FLAMMABLE

/turf/open/floor/carpet/peaks
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "carp_tp"
	floor_tile = /obj/item/stack/tile/carpet/peaks

/obj/structure/curtain/red
	name = "red curtain"
	desc = "Contains less than 1% mercury."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "closed"
	alpha = 255 //Mappers can also just set this to 255 if they want curtains that can't be seen through
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = 0
	density = FALSE
	open = TRUE

/obj/item/device/flashlight/slamp
	name = "stand lamp"
	desc = "Floor lamp in a minimalist style."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "slamp"
	item_state = "slamp"
	force = 9
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	color = LIGHT_COLOR_YELLOW
	brightness_on = 5
	w_class = WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	materials = list()
	on = TRUE
	anchored = TRUE

/obj/structure/statue/sandstone/venus/afrodita
	name = "Afrodita"
	desc = "An ancient marble statue. The subject is depicted with a floor-length braid. By Jove, it's easily the most gorgeous depiction of a woman you've ever seen. The artist must truly be a master of his craft. Shame about the broken arm, though."
	icon = 'code/white/statue_w.dmi'
	icon_state = "venus"

/obj/structure/chair/comfy/arm
	name = "Armchair"
	desc = "It looks comfy.\n<span class='notice'>Alt-click to rotate it clockwise.</span>"
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "armchair"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	var/mutable_appearance/armresttp
	buildstackamount = 2
	item_chair = null

/obj/structure/chair/comfy/arm/Initialize()
	armresttp = mutable_appearance('code/white/pieceofcrap.dmi', "comfychair_armrest")
	armresttp.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/chair/comfy/arm/Destroy()
	QDEL_NULL(armresttp)
	return ..()

/obj/structure/chair/comfy/arm/post_buckle_mob(mob/living/M)
	..()
	if(has_buckled_mobs())
		add_overlay(armresttp)
	else
		cut_overlay(armresttp)

/area/ruin/redroom
	name = "The Red Room "
	ambientsounds = list('sound/ambience/redroom.ogg')

/datum/map_template/ruin/space/redroom
 	id = "redroom"
 	suffix = "redroom.dmm"
 	name = "Red Room"

/obj/item/reagent_containers/food/snacks/carpmeat/dry/donbas
	name = "Debaltsevo fish"
	desc = "Dryed fish with tomatoes. S vodoi v samiy raz."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "roasted"
	list_reagents = list("nutriment" = 5, "carpotoxin" = 3)
	bitesize = 2
	filling_color = "#000000"
	tastes = list("fish" = 1, "tomato" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/carpmeat/dry
	name = "Dryed fish"
	desc = "Just dryed fish. S pivkom v samiy raz."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "dry"
	list_reagents = list("nutriment" = 1, "carpotoxin" = 1)
	bitesize = 2
	filling_color = "#FA8072"
	tastes = list("fish" = 1)
	foodtype = MEAT

/datum/crafting_recipe/dryfish
	name = "Dryed Fish"
	result =  /obj/item/reagent_containers/food/snacks/carpmeat/dry
	time = 80
	reqs = list(/obj/item/reagent_containers/food/snacks/carpmeat = 3,
				/datum/reagent/fuel = 5)
	category = CAT_MISC

/datum/crafting_recipe/dryfish/donbass
	name = "Debaltsevo Fish"
	result =  /obj/item/reagent_containers/food/snacks/carpmeat/dry/donbas
	time = 40
	reqs = list(/obj/item/reagent_containers/food/snacks/carpmeat/dry = 1,
				/datum/reagent/consumable/tomatojuice = 10,
				/obj/item/reagent_containers/food/snacks/grown/tomato = 1)
	category = CAT_MISC

/obj/item/reagent_containers/food/snacks/meat/slab/dach
	name = "dach meat"
	desc = "Tastes like... well you know..."
	foodtype = RAW | MEAT | GROSS

/datum/supply_pack/organic/critter/dhund
	name = "Dachshund Crate"
	cost = 1000
	contains = list(/mob/living/simple_animal/pet/dog/dhund)
	crate_name = "dachshund crate"

/mob/living/simple_animal/pet/dog/dhund
	name = "\improper Dachshund"
	real_name = "Dachshund"
	desc = "It's a dachshund."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "dachshund"
	icon_living = "dachshund"
	icon_dead = "dachshund_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/dach = 3)
	gold_core_spawnable = 2

/mob/living/simple_animal/pet/dog/shepherd
	name = "\improper Shepherd"
	real_name = "Shepherd"
	desc = "It's a Shepherd."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "shepherd"
	icon_living = "shepherd"
	icon_dead = "shepherd_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/shepherd = 3)
	gold_core_spawnable = 2

/mob/living/simple_animal/pet/dog/jack
	name = "\improper Jack"
	real_name = "Jack russell terrier"
	desc = "It's a jack russell terrier."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "jack"
	icon_living = "jack"
	icon_dead = "jack_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/jack = 3)
	gold_core_spawnable = 2

/mob/living/simple_animal/pet/dog/pug/chi
	name = "\improper ?hi"
	real_name = "Chihuahua"
	desc = "It's a chihuahua."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "chi"
	icon_living = "chi"
	icon_dead = "chi_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/chi = 1)
	gold_core_spawnable = 2

/obj/item/reagent_containers/food/snacks/meat/slab/jack
	name = "jack meat"
	desc = "Tastes like... well you know..."
	foodtype = RAW | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/chi
	name = "chihuahua meat"
	desc = "Tastes like... well you know..."
	foodtype = RAW | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/shepherd
	name = "shepherd meat"
	desc = "Tastes like... well you know..."
	foodtype = RAW | MEAT | GROSS

/datum/supply_pack/organic/critter/shepherd
	name = "German Shepherd"
	cost = 1000
	contains = list(/mob/living/simple_animal/pet/dog/shepherd)
	crate_name = "shepherd crate"

/datum/supply_pack/organic/critter/doggies
	name = "Doggies crate"
	cost = 1000
	contains = list(/mob/living/simple_animal/pet/dog/jack, /mob/living/simple_animal/pet/dog/pug/chi)
	crate_name = "doggies crate"

//doggo sprites by Arkblader

/obj/item/gun/ballistic/shotgun/sniper
	name = "Hunting rifle"
	desc = "A traditional hunting rifle with 4x scope and a four-shell capacity underneath."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "tranqshotgun"
	item_state = "sniper"
	w_class = WEIGHT_CLASS_BULKY
	force = 4
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	slot_flags = SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	casing_ejector = FALSE
	weapon_weight = WEAPON_MEDIUM

/obj/item/ammo_casing/shotgun/dart/sleeping
	name = "shotgun dart"
	desc = "A dart for use in shotguns. Filled with tranquilizers."
	icon_state = "cshell"
	projectile_type = /obj/item/projectile/bullet/dart

/obj/item/ammo_casing/shotgun/dart/sleeping/Initialize()
	. = ..()
	reagents.add_reagent("tirizene", 30)
	reagents.add_reagent("skewium", 30)
	reagents.add_reagent("spewium", 30)

/obj/item/storage/box/sleeping
	name = "box of tranquilizer darts"
	desc = "A box full of darts, filled with tranquilizers."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "tranqshot"
	illustration = null

/obj/item/storage/box/sleeping/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/dart/sleeping(src)

/obj/item/book/ruchinese
	name = "Russian-chinese dictionary"
	desc = "Apply to the moths and flies."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "slovar"
	item_state = "bible"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	force = 17
	hitsound = 'code/white/fogmann/yebal.ogg'
	dat = {"<html><body>
	<img src=https://pp.userapi.com/c638421/v638421709/50c5d/RbBWfRq8b8Q.jpg>
	</body>
	</html>"}


/obj/item/book/ruchinese/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] ебашит себя по голове книгой, видимо на станции нет мух!</span>")
	var/delay_offset = 0
	for(var/mob/M in viewers(src, 7))
		var/mob/living/carbon/human/C = M
		if (ishuman(M))
			addtimer(CALLBACK(C, /mob/.proc/emote, "blyadiada"), delay_offset * 0.3)
			delay_offset++
	return (BRUTELOSS)

/datum/uplink_item/role_restricted/ruchinese
	name = "Russian-chinese dictionary"
	desc = "Старая книга, убившая прародителя мух и мотыльков. На ней до сих пор видны их засохшие внутренности."
	item = /obj/item/book/ruchinese
	cost = 18
	restricted_roles = list("Chaplain,  Curator, Assistant")
	surplus = 5

/datum/emote/living/carbon/blyad
	key = "blyadiada"
	key_third_person = "blyads"
	message = "blyads."
	muzzle_ignore = FALSE
	restraint_check = FALSE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/blyad/run_emote(mob/living/user, params)
	. = ..()
	if (.)
		if (ishuman(user))
			if (!user.get_bodypart("tongue"))
				return
			var/blyad = pick('code/white/fogmann/blyead.ogg')
			playsound(user, blyad, 25, 1, -1)
