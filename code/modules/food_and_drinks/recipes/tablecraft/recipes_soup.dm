
// see code/module/crafting/table.dm

////////////////////////////////////////////////SOUP////////////////////////////////////////////////

/datum/crafting_recipe/food/meatballsoup
	name = "Meatball soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/meatball = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/potato = 1
	)
	result = /obj/item/food/soup/meatball
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/vegetablesoup
	name = "Vegetable soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/potato = 1
	)
	result = /obj/item/food/soup/vegetable
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/nettlesoup
	name = "Nettle soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/nettle = 1,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/boiledegg = 1
	)
	result = /obj/item/food/soup/nettle
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/wingfangchu
	name = "Wingfangchu"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/meat/cutlet/xeno = 2
	)
	result = /obj/item/food/soup/wingfangchu
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/wishsoup
	name = "Wish soup"
	reqs = list(
		/datum/reagent/water = 20,
		/obj/item/reagent_containers/glass/bowl = 1
	)
	result= /obj/item/food/soup/wish
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/hotchili
	name = "Hot chili"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/soup/hotchili
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/coldchili
	name = "Cold chili"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/icepepper = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/soup/coldchili
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/clownchili
	name = "Chili con carnival"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/clothing/shoes/clown_shoes = 1
	)
	result = /obj/item/food/soup/clownchili
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/tomatosoup
	name = "Tomato soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/tomato = 2
	)
	result = /obj/item/food/soup/tomato
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/eyeballsoup
	name = "Eyeball soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/tomato = 2,
		/obj/item/organ/eyes = 1
	)
	result = /obj/item/food/soup/tomato/eyeball
	subcategory = CAT_SOUP


/datum/crafting_recipe/food/misosoup
	name = "Miso soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/soydope = 2,
		/obj/item/food/tofu = 2
	)
	result = /obj/item/food/soup/miso
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/bloodsoup
	name = "Blood soup"
	reqs = list(
		/datum/reagent/blood = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/tomato/blood = 2
	)
	result = /obj/item/food/soup/blood
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/slimesoup
	name = "Slime soup"
	reqs = list(
			/datum/reagent/water = 10,
			/datum/reagent/toxin/slimejelly = 5,
			/obj/item/reagent_containers/glass/bowl = 1
	)
	result = /obj/item/food/soup/slime
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/clownstears
	name = "Clowns tears"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/banana = 1,
		/obj/item/stack/sheet/mineral/bananium = 1
	)
	result = /obj/item/food/soup/clownstears
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/mysterysoup
	name = "Mystery soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/badrecipe = 1,
		/obj/item/food/tofu = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/cheese = 1,
	)
	result = /obj/item/food/soup/mystery
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/mushroomsoup
	name = "Mushroom soup"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/water = 5,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/mushroom/chanterelle = 1
	)
	result = /obj/item/food/soup/mushroom
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/beetsoup
	name = "Beet soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/whitebeet = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/soup/beet
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/stew
	name = "Stew"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/meat/cutlet = 3,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/mushroom = 1
	)
	result = /obj/item/food/soup/stew
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/spacylibertyduff
	name = "Spacy liberty duff"
	reqs = list(
		/datum/reagent/consumable/ethanol/vodka = 5,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/mushroom/libertycap = 3
	)
	result = /obj/item/food/soup/spacylibertyduff
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/amanitajelly
	name = "Amanita jelly"
	reqs = list(
		/datum/reagent/consumable/ethanol/vodka = 5,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/mushroom/amanita = 3
	)
	result = /obj/item/food/soup/amanitajelly
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/sweetpotatosoup
	name = "Sweet potato soup"
	reqs = list(
		/datum/reagent/water = 10,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/potato/sweet = 2
	)
	result = /obj/item/food/soup/sweetpotato
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/redbeetsoup
	name = "Red beet soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/redbeet = 1,
		/obj/item/food/grown/cabbage = 1
	)
	result = /obj/item/food/soup/beet/red
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/onionsoup
	name = "French onion soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/cheese/wedge = 1,
	)
	result = /obj/item/food/soup/onion
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/bisque
	name = "Bisque"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/meat/crab = 1,
		/obj/item/food/salad/boiledrice = 1
	)
	result = /obj/item/food/soup/bisque
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/bungocurry
	name = "Bungo Curry"
	reqs = list(
		/datum/reagent/water = 5,
		/datum/reagent/consumable/cream = 5,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/bungofruit = 1
	)
	result = /obj/item/food/soup/bungocurry
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/electron
	name = "Electron Soup"
	reqs = list(
		/datum/reagent/water = 10,
		/datum/reagent/consumable/salt = 5,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/mushroom/jupitercup = 1
	)
	result = /obj/item/food/soup/electron
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/peasoup
	name = "Pea soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/food/grown/peas = 2,
		/obj/item/food/grown/parsnip = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/reagent_containers/glass/bowl = 1
	)
	result = /obj/item/food/soup/peasoup
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/indian_curry
	name = "Indian Chicken Curry"
	reqs = list(
		/obj/item/food/meat/slab/chicken = 1,
		/obj/item/food/grown/onion = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/butter = 1,
		/obj/item/food/salad/boiledrice = 1,
		/datum/reagent/consumable/cream = 5
	)
	result = /obj/item/food/soup/indian_curry
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/oatmeal
	name = "Oatmeal"
	reqs = list(
		/datum/reagent/consumable/milk = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/grown/oat = 1
	)
	result = /obj/item/food/soup/oatmeal
	subcategory = CAT_SOUP
