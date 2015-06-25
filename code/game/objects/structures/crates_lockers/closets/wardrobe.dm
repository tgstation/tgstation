/obj/structure/closet/wardrobe
	name = "wardrobe"
	desc = "It's a storage unit for standard-issue Nanotrasen attire."
	icon_door = "blue"

/obj/structure/closet/wardrobe/New()
	..()
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	return


/obj/structure/closet/wardrobe/red
	name = "security wardrobe"
	icon_door = "red"

/obj/structure/closet/wardrobe/red/New()
	..()
	contents = list()
	new /obj/item/weapon/storage/backpack/security(src)
	new /obj/item/weapon/storage/backpack/satchel_sec(src)
	new /obj/item/weapon/storage/backpack/dufflebag/sec(src)
	new /obj/item/weapon/storage/backpack/dufflebag/sec(src)
	new /obj/item/clothing/under/rank/security(src)
	new /obj/item/clothing/under/rank/security(src)
	new /obj/item/clothing/under/rank/security(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/head/beret/sec(src)
	new /obj/item/clothing/head/beret/sec(src)
	new /obj/item/clothing/head/beret/sec(src)
	new /obj/item/clothing/head/soft/sec(src)
	new /obj/item/clothing/head/soft/sec(src)
	new /obj/item/clothing/head/soft/sec(src)
	new /obj/item/clothing/mask/bandana/red(src)
	new /obj/item/clothing/mask/bandana/red(src)
	return

/obj/structure/closet/wardrobe/pink
	name = "pink wardrobe"
	icon_door = "pink"

/obj/structure/closet/wardrobe/pink/New()
	..()
	contents = list()
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	return

/obj/structure/closet/wardrobe/black
	name = "black wardrobe"
	icon_door = "black"

/obj/structure/closet/wardrobe/black/New()
	..()
	contents = list()
	new /obj/item/clothing/under/color/black(src)
	new /obj/item/clothing/under/color/black(src)
	new /obj/item/clothing/under/color/black(src)
	if(prob(25))
		new /obj/item/clothing/suit/jacket/leather(src)
	if(prob(20))
		new /obj/item/clothing/suit/jacket/leather/overcoat(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/mask/bandana/black(src)
	new /obj/item/clothing/mask/bandana/black(src)
	if(prob(40))
		new /obj/item/clothing/mask/bandana/skull(src)
	return


/obj/structure/closet/wardrobe/chaplain_black
	name = "chapel wardrobe"
	desc = "It's a storage unit for Nanotrasen-approved religious attire."
	icon_door = "black"

/obj/structure/closet/wardrobe/chaplain_black/New()
	..()
	contents = list()
	new /obj/item/clothing/under/rank/chaplain(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/suit/nun(src)
	new /obj/item/clothing/head/nun_hood(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/holidaypriest(src)
	new /obj/item/weapon/storage/backpack/cultpack (src)
	new /obj/item/weapon/storage/fancy/candle_box(src)
	new /obj/item/weapon/storage/fancy/candle_box(src)
	return


/obj/structure/closet/wardrobe/green
	name = "green wardrobe"
	icon_door = "green"

/obj/structure/closet/wardrobe/green/New()
	..()
	contents = list()
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
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
	new /obj/item/clothing/under/rank/prisoner(src)
	new /obj/item/clothing/under/rank/prisoner(src)
	new /obj/item/clothing/under/rank/prisoner(src)
	new /obj/item/clothing/shoes/sneakers/orange(src)
	new /obj/item/clothing/shoes/sneakers/orange(src)
	new /obj/item/clothing/shoes/sneakers/orange(src)
	return


/obj/structure/closet/wardrobe/yellow
	name = "yellow wardrobe"
	icon_door = "yellow"

/obj/structure/closet/wardrobe/yellow/New()
	..()
	contents = list()
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/shoes/sneakers/orange(src)
	new /obj/item/clothing/shoes/sneakers/orange(src)
	new /obj/item/clothing/shoes/sneakers/orange(src)
	new /obj/item/clothing/mask/bandana/gold(src)
	new /obj/item/clothing/mask/bandana/gold(src)
	return


/obj/structure/closet/wardrobe/atmospherics_yellow
	name = "atmospherics wardrobe"
	icon_door = "atmos_wardrobe"

/obj/structure/closet/wardrobe/atmospherics_yellow/New()
	..()
	contents = list()
	new /obj/item/clothing/under/rank/atmospheric_technician(src)
	new /obj/item/clothing/under/rank/atmospheric_technician(src)
	new /obj/item/clothing/under/rank/atmospheric_technician(src)
	new /obj/item/device/analyzer(src)
	new /obj/item/device/analyzer(src)
	new /obj/item/device/analyzer(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	return



/obj/structure/closet/wardrobe/engineering_yellow
	name = "engineering wardrobe"
	icon_door = "yellow"

/obj/structure/closet/wardrobe/engineering_yellow/New()
	..()
	contents = list()
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/shoes/sneakers/orange(src)
	new /obj/item/clothing/shoes/sneakers/orange(src)
	new /obj/item/clothing/shoes/sneakers/orange(src)
	return


/obj/structure/closet/wardrobe/white
	name = "white wardrobe"
	icon_door = "white"

/obj/structure/closet/wardrobe/white/New()
	..()
	contents = list()
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/head/soft/mime(src)
	new /obj/item/clothing/head/soft/mime(src)
	new /obj/item/clothing/head/soft/mime(src)
	return

/obj/structure/closet/wardrobe/white/medical
	name = "medical doctor's wardrobe"

/obj/structure/closet/wardrobe/white/medical/New()
	..()
	contents = list()
	new /obj/item/clothing/under/rank/nursesuit (src)
	new /obj/item/clothing/head/nursehat (src)
	new /obj/item/clothing/under/rank/medical/blue(src)
	new /obj/item/clothing/under/rank/medical/green(src)
	new /obj/item/clothing/under/rank/medical/purple(src)
	new /obj/item/clothing/suit/toggle/labcoat/emt(src)
	new /obj/item/clothing/suit/toggle/labcoat/emt(src)
	new /obj/item/clothing/suit/toggle/labcoat/emt(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/head/soft/emt(src)
	new /obj/item/clothing/head/soft/emt(src)
	new /obj/item/clothing/head/soft/emt(src)
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
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	return


/obj/structure/closet/wardrobe/toxins_white
	name = "toxins wardrobe"
	icon_door = "white"

/obj/structure/closet/wardrobe/toxins_white/New()
	..()
	contents = list()
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/suit/toggle/labcoat(src)
	new /obj/item/clothing/suit/toggle/labcoat(src)
	new /obj/item/clothing/suit/toggle/labcoat(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	return


/obj/structure/closet/wardrobe/robotics_black
	name = "robotics wardrobe"
	icon_door = "black"

/obj/structure/closet/wardrobe/robotics_black/New()
	..()
	contents = list()
	new /obj/item/clothing/under/rank/roboticist(src)
	new /obj/item/clothing/under/rank/roboticist(src)
	new /obj/item/clothing/suit/toggle/labcoat(src)
	new /obj/item/clothing/suit/toggle/labcoat(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/head/soft/black(src)
	if(prob(40))
		new /obj/item/clothing/mask/bandana/skull(src)
	if(prob(40))
		new /obj/item/clothing/mask/bandana/skull(src)
	return


/obj/structure/closet/wardrobe/chemistry_white
	name = "chemistry wardrobe"
	icon_door = "white"

/obj/structure/closet/wardrobe/chemistry_white/New()
	..()
	contents = list()
	new /obj/item/clothing/under/rank/chemist(src)
	new /obj/item/clothing/under/rank/chemist(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/suit/toggle/labcoat/chemist(src)
	new /obj/item/clothing/suit/toggle/labcoat/chemist(src)
	new /obj/item/weapon/storage/backpack/chemistry(src)
	new /obj/item/weapon/storage/backpack/chemistry(src)
	new /obj/item/weapon/storage/backpack/satchel_chem(src)
	new /obj/item/weapon/storage/backpack/satchel_chem(src)
	new /obj/item/weapon/storage/bag/chemistry(src)
	new /obj/item/weapon/storage/bag/chemistry(src)
	return


/obj/structure/closet/wardrobe/genetics_white
	name = "genetics wardrobe"
	icon_door = "white"

/obj/structure/closet/wardrobe/genetics_white/New()
	..()
	contents = list()
	new /obj/item/clothing/under/rank/geneticist(src)
	new /obj/item/clothing/under/rank/geneticist(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/suit/toggle/labcoat/genetics(src)
	new /obj/item/clothing/suit/toggle/labcoat/genetics(src)
	new /obj/item/weapon/storage/backpack/genetics(src)
	new /obj/item/weapon/storage/backpack/genetics(src)
	new /obj/item/weapon/storage/backpack/satchel_gen(src)
	new /obj/item/weapon/storage/backpack/satchel_gen(src)
	return


/obj/structure/closet/wardrobe/virology_white
	name = "virology wardrobe"
	icon_door = "white"

/obj/structure/closet/wardrobe/virology_white/New()
	..()
	contents = list()
	new /obj/item/clothing/under/rank/virologist(src)
	new /obj/item/clothing/under/rank/virologist(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/suit/toggle/labcoat/virologist(src)
	new /obj/item/clothing/suit/toggle/labcoat/virologist(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/weapon/storage/backpack/virology(src)
	new /obj/item/weapon/storage/backpack/virology(src)
	new /obj/item/weapon/storage/backpack/satchel_vir(src)
	new /obj/item/weapon/storage/backpack/satchel_vir(src)
	return


/obj/structure/closet/wardrobe/grey
	name = "grey wardrobe"
	icon_door = "grey"

/obj/structure/closet/wardrobe/grey/New()
	..()
	contents = list()
	new /obj/item/clothing/under/color/grey(src)
	new /obj/item/clothing/under/color/grey(src)
	new /obj/item/clothing/under/color/grey(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/head/soft/grey(src)
	new /obj/item/clothing/head/soft/grey(src)
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
