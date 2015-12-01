//Seed packet object/procs.
/obj/item/seeds
	name = "packet of seeds"
	icon = 'icons/obj/seeds.dmi'
	icon_state = "seed"
	flags = FPRINT
	w_class = 2.0

	var/seed_type
	var/datum/seed/seed
	var/modified = 0

/obj/item/seeds/New()
	update_seed()
	..()
	pixel_x = rand(-3,3)
	pixel_y = rand(-3,3)

//Grabs the appropriate seed datum from the global list.
/obj/item/seeds/proc/update_seed()
	if(!seed && seed_type && !isnull(seed_types) && seed_types[seed_type])
		seed = seed_types[seed_type]
	update_appearance()

//Updates strings and icon appropriately based on seed datum.
/obj/item/seeds/proc/update_appearance()
	if(!seed) return
	icon_state = seed.packet_icon
	src.name = "packet of [seed.seed_name] [seed.seed_noun]"
	src.desc = "It has a picture of [seed.display_name] on the front."

/obj/item/seeds/examine(mob/user)
	..()
	if(seed && !seed.roundstart)
		to_chat(user, "It's tagged as variety <span class='info'>#[seed.uid].</span>")
	else
		to_chat(user, "Plant Yield: <span class='info'>[(seed.yield != -1) ? seed.yield : "<span class='warning'> ERROR</span>"]</span>")
		to_chat(user, "Plant Potency: <span class='info'>[(seed.potency != -1) ? seed.potency : "<span class='warning> ERROR</span>"]</span>")

/obj/item/seeds/cutting
	name = "cuttings"
	desc = "Some plant cuttings."

/obj/item/seeds/cutting/update_appearance()
	..()
	src.name = "packet of [seed.seed_name] cuttings"

/obj/item/seeds/random
	seed_type = null

/obj/item/seeds/random/New()
	seed = new()
	seed.randomize()

	seed.uid = seed_types.len + 1
	seed.name = "[seed.uid]"
	seed_types[seed.name] = seed
	..()

//the vegetable/fruit categories are made from a culinary standpoint. many of the "vegetables" in there are technically fruits. (tomatoes, pumpkins...)

/obj/item/seeds/dionanode
	seed_type = "diona"
	vending_cat = "sentient"

/obj/item/seeds/poppyseed
	seed_type = "poppies"
	vending_cat = "flowers"

/obj/item/seeds/chiliseed
	seed_type = "chili"
	vending_cat = "vegetables"

/obj/item/seeds/plastiseed
	seed_type = "plastic"

/obj/item/seeds/grapeseed
	seed_type = "grapes"
	vending_cat = "fruits"

/obj/item/seeds/greengrapeseed
	seed_type = "greengrapes"
	vending_cat = "fruits"

/obj/item/seeds/peanutseed
	seed_type = "peanut"

/obj/item/seeds/cabbageseed
	seed_type = "cabbage"
	vending_cat = "vegetables"

/obj/item/seeds/shandseed
	seed_type = "shand"

/obj/item/seeds/mtearseed
	seed_type = "mtear"

/obj/item/seeds/berryseed
	seed_type = "berries"
	vending_cat = "fruits"

/obj/item/seeds/glowberryseed
	seed_type = "glowberries"
	vending_cat = "fruits"

/obj/item/seeds/bananaseed
	seed_type = "banana"
	vending_cat = "fruits"

/obj/item/seeds/eggplantseed
	seed_type = "eggplant"
	vending_cat = "vegetables"

/obj/item/seeds/eggyseed
	seed_type = "realeggplant"

/obj/item/seeds/bloodtomatoseed
	seed_type = "bloodtomato"
	vending_cat = "vegetables"

/obj/item/seeds/tomatoseed
	seed_type = "tomato"
	vending_cat = "vegetables"

/obj/item/seeds/killertomatoseed
	seed_type = "killertomato"
	vending_cat = "sentient"

/obj/item/seeds/bluetomatoseed
	seed_type = "bluetomato"
	vending_cat = "vegetables"

/obj/item/seeds/bluespacetomatoseed
	seed_type = "bluespacetomato"
	vending_cat = "vegetables"

/obj/item/seeds/cornseed
	seed_type = "corn"
	vending_cat = "vegetables"

/obj/item/seeds/potatoseed
	seed_type = "potato"
	vending_cat = "vegetables"

/obj/item/seeds/icepepperseed
	seed_type = "icechili"
	vending_cat = "vegetables"

/obj/item/seeds/soyaseed
	seed_type = "soybean"
	vending_cat = "vegetables"

/obj/item/seeds/koiseed
	seed_type = "koibean"
	vending_cat = "vegetables"

/obj/item/seeds/wheatseed
	seed_type = "wheat"
	vending_cat = "cereals"

/obj/item/seeds/riceseed
	seed_type = "rice"
	vending_cat = "cereals"

/obj/item/seeds/carrotseed
	seed_type = "carrot"
	vending_cat = "vegetables"

/obj/item/seeds/reishimycelium
	seed_type = "reishi"
	vending_cat = "mushrooms"

/obj/item/seeds/amanitamycelium
	seed_type = "amanita"
	vending_cat = "mushrooms"

/obj/item/seeds/angelmycelium
	seed_type = "destroyingangel"
	vending_cat = "mushrooms"

/obj/item/seeds/libertymycelium
	seed_type = "libertycap"
	vending_cat = "mushrooms"

/obj/item/seeds/chantermycelium
	seed_type = "mushrooms"
	vending_cat = "mushrooms"

/obj/item/seeds/towermycelium
	seed_type = "towercap"
	vending_cat = "trees"

/obj/item/seeds/glowshroom
	seed_type = "glowshroom"
	vending_cat = "mushrooms"

/obj/item/seeds/plumpmycelium
	seed_type = "plumphelmet"
	vending_cat = "mushrooms"

/obj/item/seeds/walkingmushroommycelium
	seed_type = "walkingmushroom"
	vending_cat = "sentient"

/obj/item/seeds/nettleseed
	seed_type = "nettle"
	vending_cat = "weeds"

/obj/item/seeds/deathnettleseed
	seed_type = "deathnettle"
	vending_cat = "weeds"

/obj/item/seeds/weeds
	seed_type = "weeds"
	vending_cat = "weeds"

/obj/item/seeds/harebell
	seed_type = "harebells"
	vending_cat = "flowers"

/obj/item/seeds/sunflowerseed
	seed_type = "sunflowers"
	vending_cat = "flowers"

/obj/item/seeds/moonflowerseed
	seed_type = "moonflowers"
	vending_cat = "flowers"

/obj/item/seeds/novaflowerseed
	seed_type = "novaflowers"
	vending_cat = "flowers"

/obj/item/seeds/brownmold
	seed_type = "mold"
	vending_cat = "mushrooms"

/obj/item/seeds/appleseed
	seed_type = "apple"
	vending_cat = "fruits"

/obj/item/seeds/poisonedappleseed
	seed_type = "poisonapple"
	vending_cat = "fruits"

/obj/item/seeds/goldappleseed
	seed_type = "goldapple"
	vending_cat = "fruits"

/obj/item/seeds/ambrosiavulgarisseed
	seed_type = "ambrosia"
	vending_cat = "weeds"

/obj/item/seeds/ambrosiacruciatusseed
	seed_type = "ambrosiacruciatus"
	vending_cat = "weeds"

/obj/item/seeds/ambrosiadeusseed
	seed_type = "ambrosiadeus"
	vending_cat = "weeds"

/obj/item/seeds/whitebeetseed
	seed_type = "whitebeet"
	vending_cat = "vegetables"

/obj/item/seeds/sugarcaneseed
	seed_type = "sugarcane"

/obj/item/seeds/watermelonseed
	seed_type = "watermelon"
	vending_cat = "fruits"

/obj/item/seeds/pumpkinseed
	seed_type = "pumpkin"
	vending_cat = "vegetables"

/obj/item/seeds/limeseed
	seed_type = "lime"
	vending_cat = "fruits"

/obj/item/seeds/lemonseed
	seed_type = "lemon"
	vending_cat = "fruits"

/obj/item/seeds/orangeseed
	seed_type = "orange"
	vending_cat = "fruits"

/obj/item/seeds/poisonberryseed
	seed_type = "poisonberries"

/obj/item/seeds/deathberryseed
	seed_type = "deathberries"

/obj/item/seeds/grassseed
	seed_type = "grass"
	vending_cat = "weeds"

/obj/item/seeds/cocoapodseed
	seed_type = "cocoa"

/obj/item/seeds/cherryseed
	seed_type = "cherry"
	vending_cat = "fruits"

/obj/item/seeds/kudzuseed
	seed_type = "kudzu"
	vending_cat = "weeds"

/obj/item/seeds/cinnamomum
	seed_type = "cinnamomum"
	vending_cat = "trees"
