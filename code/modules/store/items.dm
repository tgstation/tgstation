/////////////////////////////
// Store Item
/////////////////////////////
/datum/storeitem
	var/name="Thing"
	var/desc="It's a thing."
	var/typepath=/obj/item/weapon/storage/box
	var/cost=0
	var/category = "misc"

/datum/storeitem/proc/deliver(var/mob/user,var/obj/machinery/computer/merch/merchcomp)
	if(istype(typepath,/obj/item/weapon/storage))
		var/thing = new typepath(merchcomp.loc)
		user.put_in_hands(thing)
	//else if(istype(typepath,/obj/item))
	//	var/obj/item/weapon/storage/box/box=new(loc)
	//	new typepath(box)
	//	box.name="[name] package"
	//	box.desc="A special gift for doing your job."
	//	user.put_in_hands(box)
	else
		new typepath(merchcomp.loc)


/////////////////////////////
// Food
/////////////////////////////
/datum/storeitem/menu1
	name = "Fast-Food Menu"
	desc = "The normal sized average american meal. Courtesy of Nanotrasen."
	typepath = /obj/item/weapon/storage/bag/food/menu1
	cost = 50

/datum/storeitem/menu2
	name = "Fast-Food Menu (XL)"
	desc = "For when you're 100% starved and want to become fat in 1 easy step."
	typepath = /obj/item/weapon/storage/bag/food/menu2
	cost = 100

/////////////////////////////
// Tools
/////////////////////////////
/datum/storeitem/pen
	name = "Pen"
	desc = "Just a simple pen."
	typepath = /obj/item/weapon/pen
	cost = 10

/datum/storeitem/wrapping_paper
	name = "Wrapping Paper"
	desc = "Makes gifts 200% more touching."
	typepath = /obj/item/stack/package_wrap/gift
	cost = 50

/////////////////////////////
// Electronics
/////////////////////////////
/datum/storeitem/boombox
	name = "Boombox"
	desc = "I ask you a question: is a man not entitled to the beats of his own smooth jazz?"
	typepath = /obj/machinery/media/receiver/boombox
	cost = 400

/////////////////////////////
// Toys
/////////////////////////////
/datum/storeitem/snap_pops
	name = "Snap-Pops"
	desc = "Ten-thousand-year-old chinese fireworks: IN SPACE"
	typepath = /obj/item/weapon/storage/box/snappops
	cost = 100

/datum/storeitem/crayons
	name = "Crayons"
	desc = "Let security know how they're doing by scrawling lovenotes all over their hallways."
	typepath = /obj/item/weapon/storage/fancy/crayons
	cost = 150

/datum/storeitem/beachball
	name = "Beach Ball"
	desc = "Summer up your office with this cheap vinyl beachball made by prisoners!"
	typepath = /obj/item/weapon/beach_ball
	cost = 50

/////////////////////////////
// Clothing
/////////////////////////////
/datum/storeitem/robotnik_labcoat
	name = "Robotnik's Research Labcoat"
	desc = "Join the empire and display your hatred for woodland animals."
	typepath = /obj/item/clothing/suit/storage/labcoat/custom/N3X15/robotics
	cost = 200

/datum/storeitem/robotnik_jumpsuit
	name = "Robotics Interface Suit"
	desc = "A modern black and red design with reinforced seams and brass neural interface fittings."
	typepath = /obj/item/clothing/under/custom/N3X15/robotics
	cost = 200

/////////////////////////////
// Luxury
/////////////////////////////
/datum/storeitem/wallet
	name = "Wallet"
	desc = "A convenient way to carry IDs, credits, coins, papers, and a bunch of other small items."
	typepath = /obj/item/weapon/storage/wallet
	cost = 30

/datum/storeitem/photo_album
	name = "Photo Album"
	desc = "Clearly all your photos of the clown's shenanigans deserve this investment."
	typepath = /obj/item/weapon/storage/photo_album
	cost = 300

/datum/storeitem/painting
	name = "Painting"
	desc = "A random painting from Centcom's museum. For those with good taste in art."
	typepath = /obj/item/mounted/frame/painting
	cost = 700
