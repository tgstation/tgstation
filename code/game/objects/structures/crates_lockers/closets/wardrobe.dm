/obj/structure/closet/wardrobe
	name = "wardrobe"
	desc = "It's a storage unit for standard-issue Nanotrasen attire."
	icon_door = "blue"

/obj/structure/closet/wardrobe/New()
	..()
	for(var/i in 1 to 3)
		new /obj/item/clothing/under/color/blue(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/shoes/sneakers/brown(src)
	return

/obj/structure/closet/wardrobe/pink
	name = "pink wardrobe"
	icon_door = "pink"

/obj/structure/closet/wardrobe/pink/New()
	..()
	contents = list()
	for(var/i in 1 to 3)
		new /obj/item/clothing/under/color/pink(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/shoes/sneakers/brown(src)
	return

/obj/structure/closet/wardrobe/black
	name = "black wardrobe"
	icon_door = "black"

/obj/structure/closet/wardrobe/black/New()
	..()
	contents = list()
	for(var/i in 1 to 3)
		new /obj/item/clothing/under/color/black(src)
	if(prob(25))
		new /obj/item/clothing/suit/jacket/leather(src)
	if(prob(20))
		new /obj/item/clothing/suit/jacket/leather/overcoat(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/shoes/sneakers/black(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/that(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/mask/bandana/black(src)
	new /obj/item/clothing/mask/bandana/black(src)
	if(prob(40))
		new /obj/item/clothing/mask/bandana/skull(src)
	return


/obj/structure/closet/wardrobe/green
	name = "green wardrobe"
	icon_door = "green"

/obj/structure/closet/wardrobe/green/New()
	..()
	contents = list()
	for(var/i in 1 to 3)		
		new /obj/item/clothing/under/color/green(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/mask/bandana/green(src)
	new /obj/item/clothing/mask/bandana/green(src)
	return


/obj/structure/closet/wardrobe/orange
	name = "prison wardrobe"
	desc = "It's a storage unit for Nanotrasen-regulation prisoner attire."
	icon_door = "orange"

/obj/structure/closet/wardrobe/orange/New()
	..()
	contents = list()
	for(var/i in 1 to 3)
		new /obj/item/clothing/under/rank/prisoner(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/shoes/sneakers/orange(src)
	return


/obj/structure/closet/wardrobe/yellow
	name = "yellow wardrobe"
	icon_door = "yellow"

/obj/structure/closet/wardrobe/yellow/New()
	..()
	contents = list()
	for(var/i in 1 to 3)
		new /obj/item/clothing/under/color/yellow(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/shoes/sneakers/orange(src)
	new /obj/item/clothing/mask/bandana/gold(src)
	new /obj/item/clothing/mask/bandana/gold(src)
	return


/obj/structure/closet/wardrobe/white
	name = "white wardrobe"
	icon_door = "white"

/obj/structure/closet/wardrobe/white/New()
	..()
	contents = list()
	for(var/i in 1 to 3)
		new /obj/item/clothing/under/color/white(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/shoes/sneakers/white(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/soft/mime(src)
	return

/obj/structure/closet/wardrobe/pjs
	name = "pajama wardrobe"
	icon_door = "white"

/obj/structure/closet/wardrobe/pjs/New()
	..()
	contents = list()
	new /obj/item/clothing/under/pj/red(src)
	new /obj/item/clothing/under/pj/red(src)
	new /obj/item/clothing/under/pj/blue(src)
	new /obj/item/clothing/under/pj/blue(src)
	for(var/i in 1 to 4)
		new /obj/item/clothing/shoes/sneakers/white(src)
	return


/obj/structure/closet/wardrobe/grey
	name = "grey wardrobe"
	icon_door = "grey"

/obj/structure/closet/wardrobe/grey/New()
	..()
	contents = list()
	for(var/i in 1 to 3)
		new /obj/item/clothing/under/color/grey(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/shoes/sneakers/black(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/soft/grey(src)
	if(prob(50))
		new /obj/item/weapon/storage/backpack/dufflebag(src)
	if(prob(40))
		new /obj/item/clothing/mask/bandana/black(src)
		new /obj/item/clothing/mask/bandana/black(src)
	if(prob(40))
		new /obj/item/clothing/under/assistantformal(src)
	if(prob(40))
		new /obj/item/clothing/under/assistantformal(src)
	if(prob(30))
		new /obj/item/clothing/suit/hooded/wintercoat(src)
		new /obj/item/clothing/shoes/winterboots(src)
	return


/obj/structure/closet/wardrobe/mixed
	name = "mixed wardrobe"
	icon_door = "mixed"

/obj/structure/closet/wardrobe/mixed/New()
	..()
	contents = list()
	if(prob(40))
		new /obj/item/clothing/suit/jacket(src)
	if(prob(40))
		new /obj/item/clothing/suit/jacket(src)
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/under/color/orange(src)
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/under/color/red(src)
	new /obj/item/clothing/under/color/lightblue(src)
	new /obj/item/clothing/under/color/aqua(src)
	new /obj/item/clothing/under/color/purple(src)
	new /obj/item/clothing/under/color/lightpurple(src)
	new /obj/item/clothing/under/color/lightgreen(src)
	new /obj/item/clothing/under/color/darkblue(src)
	new /obj/item/clothing/under/color/darkred(src)
	new /obj/item/clothing/under/color/lightred(src)
	new /obj/item/clothing/mask/bandana/red(src)
	new /obj/item/clothing/mask/bandana/red(src)
	new /obj/item/clothing/mask/bandana/blue(src)
	new /obj/item/clothing/mask/bandana/blue(src)
	new /obj/item/clothing/mask/bandana/gold(src)
	new /obj/item/clothing/mask/bandana/gold(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	if(prob(30))
		new /obj/item/clothing/suit/hooded/wintercoat(src)
		new /obj/item/clothing/shoes/winterboots(src)
	return
