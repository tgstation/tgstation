/obj/item/weapon/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "meat"
	dried_type = /obj/item/weapon/reagent_containers/food/snacks/sosjerky
	bitesize = 3
	list_reagents = list("nutriment" = 3)
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/meatsteak/plain
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/rawcutlet/plain
	slices_num = 3
	filling_color = "#FF0000"

/obj/item/weapon/reagent_containers/food/snacks/meat/initialize_slice(obj/item/weapon/reagent_containers/food/snacks/slice)
	var/image/I = new(icon, "rawcutlet_coloration")
	I.color = filling_color
	slice.overlays += I
	slice.filling_color = filling_color


///////////////////////////////////// HUMAN MEATS //////////////////////////////////////////////////////


/obj/item/weapon/reagent_containers/food/snacks/meat/human
	name = "-meat"
	var/subjectname = ""
	var/subjectjob = null
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/rawcutlet/plain/human

/obj/item/weapon/reagent_containers/food/snacks/meat/human/initialize_slice(obj/item/weapon/reagent_containers/food/snacks/rawcutlet/plain/human/slice)
	..()
	if(subjectname)
		slice.subjectname = subjectname
		slice.name = "[subjectname] [initial(slice.name)]"
	else if(subjectjob)
		slice.subjectjob = subjectjob
		slice.name = "[subjectjob] [initial(slice.name)]"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/initialize_cooked_food(obj/item/weapon/reagent_containers/food/snacks/S)
	..()
	if(subjectname)
		S.name = "[subjectname] [initial(S.name)]"
	else if(subjectjob)
		S.name = "[subjectjob] [initial(S.name)]"


/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/slime
	icon_state = "slimemeat"
	desc = "Because jello wasn't offensive enough to vegans"
	list_reagents = list("nutriment" = 3, "slimejelly" = 3)
	filling_color = "#00FFFF"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/golem
	icon_state = "golemmeat"
	desc = "Edible rocks, welcome to the future"
	list_reagents = list("nutriment" = 3, "iron" = 3)
	filling_color = "#A9A9A9"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/golem/adamantine
	icon_state = "agolemmeat"
	desc = "From the slime pen to the rune to the kitchen, science"
	filling_color = "#66CDAA"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/lizard
	icon_state = "lizardmeat"
	desc = "Delicious dino damage"
	filling_color = "#6B8E23"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/plant
	icon_state = "plantmeat"
	desc = "All the joys of healthy eating with all the fun of cannibalism"
	filling_color = "#E9967A"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/shadow
	icon_state = "shadowmeat"
	desc = "Ow, the edge"
	filling_color = "#202020"

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/fly
	icon_state = "flymeat"
	desc = "Nothing says tasty like maggot filled radioactive mutant flesh"
	list_reagents = list("nutriment" = 3, "uranium" = 3)

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/skeleton
	name = "-bone"
	icon_state = "skeletonmeat"
	desc = "There's a point where this needs to stop and clearly we have passed it"
	filling_color = "#F0F0F0"
	slice_path = null  //can't slice a bone into cutlets

/obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/zombie
	name = "-meat (rotten)"
	icon_state = "lizardmeat" //Close enough.
	desc = "Halfway to becoming fertilizer for your garden."
	filling_color = "#6B8E23"






////////////////////////////////////// OTHER MEATS ////////////////////////////////////////////////////////


/obj/item/weapon/reagent_containers/food/snacks/meat/synthmeat
	name = "synthmeat"
	desc = "A synthetic slab of meat."

/obj/item/weapon/reagent_containers/food/snacks/meat/monkey
	name = "monkey meat"

/obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	name = "corgi meat"
	desc = "Tastes like... well you know..."

/obj/item/weapon/reagent_containers/food/snacks/meat/pug
	name = "pug meat"
	desc = "Tastes like... well you know..."

/obj/item/weapon/reagent_containers/food/snacks/meat/killertomato
	name = "tomato slice"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"
	list_reagents = list("nutriment" = 2)
	filling_color = "#FF0000"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/meatsteak/killertomato
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/rawcutlet/killertomato

/obj/item/weapon/reagent_containers/food/snacks/meat/bear
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	list_reagents = list("nutriment" = 12, "morphine" = 5, "vitamin" = 2)
	filling_color = "#FFB6C1"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/meatsteak/bear
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/rawcutlet/bear


/obj/item/weapon/reagent_containers/food/snacks/meat/xeno
	name = "xeno meat"
	desc = "A slab of meat"
	icon_state = "xenomeat"
	list_reagents = list("nutriment" = 3, "vitamin" = 1)
	bitesize = 4
	filling_color = "#32CD32"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/meatsteak/xeno
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/rawcutlet/xeno

/obj/item/weapon/reagent_containers/food/snacks/meat/spider
	name = "spider meat"
	desc = "A slab of spider meat."
	icon_state = "spidermeat"
	list_reagents = list("nutriment" = 3, "toxin" = 3, "vitamin" = 1)
	filling_color = "#7CFC00"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/meatsteak/spider
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/rawcutlet/spider




////////////////////////////////////// MEAT STEAKS ///////////////////////////////////////////////////////////


/obj/item/weapon/reagent_containers/food/snacks/meatsteak
	name = "meat steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatsteak"
	list_reagents = list("nutriment" = 1, "vitamin" = 1)
	trash = /obj/item/trash/plate
	filling_color = "#B22222"

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/plain

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/plain/human

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/killertomato
	name = "killer tomato steak"

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/bear
	name = "bear steak"

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/xeno
	name = "xeno steak"

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/spider
	name = "spider steak"



//////////////////////////////// MEAT CUTLETS ///////////////////////////////////////////////////////


/obj/item/weapon/reagent_containers/food/snacks/rawcutlet
	name = "raw cutlet"
	desc = "A raw meat cutlet."
	icon_state = "rawcutlet"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/cutlet/plain
	bitesize = 2
	filling_color = "#B22222"

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/plain

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/plain/human
	var/subjectname = ""
	var/subjectjob = null

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/plain/human/initialize_cooked_food(obj/item/weapon/reagent_containers/food/snacks/S)
	..()
	if(subjectname)
		S.name = "[subjectname] [initial(S.name)]"
	else if(subjectjob)
		S.name = "[subjectjob] [initial(S.name)]"

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/killertomato
	name = "raw killer tomato cutlet"

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/bear
	name = "raw bear cutlet"

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/xeno
	name = "raw xeno cutlet"

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/spider
	name = "raw spider cutlet"


/obj/item/weapon/reagent_containers/food/snacks/cutlet
	name = "cutlet"
	desc = "A cooked meat cutlet."
	icon_state = "cutlet"
	bitesize = 2
	list_reagents = list("nutriment" = 1, "vitamin" = 1)
	filling_color = "#B22222"

/obj/item/weapon/reagent_containers/food/snacks/cutlet/plain

/obj/item/weapon/reagent_containers/food/snacks/cutlet/plain/human

/obj/item/weapon/reagent_containers/food/snacks/cutlet/killertomato
	name = "killer tomato cutlet"

/obj/item/weapon/reagent_containers/food/snacks/cutlet/bear
	name = "bear cutlet"

/obj/item/weapon/reagent_containers/food/snacks/cutlet/xeno
	name = "xeno cutlet"

/obj/item/weapon/reagent_containers/food/snacks/cutlet/spider
	name = "spider cutlet"
