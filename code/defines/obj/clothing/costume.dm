//Costume spawner

/obj/landmark/costume/New() //costume spawner, selects a random subclass and disappears

	var/list/options = typesof(/obj/landmark/costume)
	var/PICK= options[rand(1,options.len)]
	new PICK(src.loc)
	del(src)

//SUBCLASSES.  Spawn a bunch of items and disappear likewise
/obj/landmark/costume/chicken/New()
	new /obj/item/clothing/suit/chickensuit(src.loc)
	del(src)

/obj/landmark/costume/madscientist/New()
	new /obj/item/clothing/under/gimmick/rank/captain/suit(src.loc)
	new /obj/item/clothing/head/flatcap(src.loc)
	new /obj/item/clothing/suit/labcoat/mad(src.loc)
	new /obj/item/clothing/glasses/gglasses(src.loc)
	del(src)

/obj/landmark/costume/elpresidente/New()
	new /obj/item/clothing/under/gimmick/rank/captain/suit(src.loc)
	new /obj/item/clothing/head/flatcap(src.loc)
	new /obj/item/clothing/mask/cigarette/cigar/havanian(src.loc)
	new /obj/item/clothing/shoes/jackboots(src.loc)
	del(src)

/obj/landmark/costume/nyangirl/New()
	new /obj/item/clothing/under/schoolgirl(src.loc)
	new /obj/item/clothing/head/kitty(src.loc)
	del(src)

/obj/landmark/costume/maid/New()
	new /obj/item/clothing/under/blackskirt(src.loc)
	var/CHOICE = pick( /obj/item/clothing/head/beret , /obj/item/clothing/head/rabbitears )
	new CHOICE(src.loc)
	new /obj/item/clothing/glasses/blindfold(src.loc)
	del(src)

/obj/landmark/costume/butler/New()
	new /obj/item/clothing/suit/wcoat(src.loc)
	new /obj/item/clothing/under/suit_jacket(src.loc)
	new /obj/item/clothing/head/that(src.loc)
	del(src)

/obj/landmark/costume/judge/New()
	new /obj/item/clothing/suit/judgerobe(src.loc)
	new /obj/item/clothing/head/powdered_wig(src.loc)
	del(src)

/obj/landmark/costume/highlander/New()
	new /obj/item/clothing/under/kilt(src.loc)
	new /obj/item/clothing/head/beret(src.loc)
	del(src)

/obj/landmark/costume/prig/New()
	new /obj/item/clothing/suit/wcoat(src.loc)
	new /obj/item/clothing/glasses/monocle(src.loc)
	var/CHOICE= pick( /obj/item/clothing/head/bowler, /obj/item/clothing/head/that)
	new CHOICE(src.loc)
	new /obj/item/clothing/shoes/black(src.loc)
	new /obj/item/weapon/cane(src.loc)
	new /obj/item/clothing/under/sl_suit(src.loc)
	new /obj/item/clothing/mask/gas/fakemoustache(src.loc)
	del(src)

/obj/landmark/costume/plaguedoctor/New()
	new /obj/item/clothing/suit/bio_suit/plaguedoctorsuit(src.loc)
	new /obj/item/clothing/head/plaguedoctorhat(src.loc)
	del(src)

/obj/landmark/costume/fakewizard/New()
	new /obj/item/clothing/suit/wizrobe/fake(src.loc)
	new /obj/item/clothing/head/wizard/fake(src.loc)
	del(src)

/obj/landmark/costume/marisawizard/New()
	new /obj/item/clothing/head/wizard/marisa(src.loc)
	new/obj/item/clothing/suit/wizrobe/marisa(src.loc)
	del(src)

/obj/landmark/costume/nightowl/New()
	new /obj/item/clothing/under/owl(src.loc)
	new /obj/item/clothing/mask/owl_mask(src.loc)
	del(src)

/obj/landmark/costume/waiter/New()
	new /obj/item/clothing/under/waiter(src.loc)
	var/CHOICE= pick( /obj/item/clothing/head/kitty, /obj/item/clothing/head/rabbitears)
	new CHOICE(src.loc)
	new /obj/item/clothing/suit/apron(src.loc)
	del(src)

/obj/landmark/costume/pirate/New()
	new /obj/item/clothing/under/pirate(src.loc)
	new /obj/item/clothing/suit/pirate(src.loc)
	var/CHOICE = pick( /obj/item/clothing/head/pirate , /obj/item/clothing/head/bandana )
	new CHOICE(src.loc)
	new /obj/item/clothing/glasses/eyepatch(src.loc)
	del(src)

/obj/landmark/costume/commie/New()
	new /obj/item/clothing/under/soviet(src.loc)
	new /obj/item/clothing/head/ushanka(src.loc)
	del(src)

/obj/landmark/costume/nurse/New()
	new /obj/item/clothing/under/rank/nursesuit(src.loc)
	new /obj/item/clothing/head/nursehat(src.loc)
	new /obj/item/clothing/glasses/regular(src.loc)
	new /obj/item/clothing/gloves/latex(src.loc)
	new /obj/item/clothing/mask/surgical(src.loc)
	del(src)


/obj/landmark/costume/imperium_monk/New()
	new /obj/item/clothing/suit/imperium_monk(src.loc)
	if (prob(25))
		new /obj/item/clothing/mask/gas/cyborg(src.loc)
	del(src)

/obj/landmark/costume/holiday_priest/New()
	new /obj/item/clothing/suit/holidaypriest(src.loc)
	del(src)

/obj/landmark/costume/spiderman/New()
	new /obj/item/clothing/under/spiderman(src.loc)
	new /obj/item/clothing/mask/spiderman(src.loc)
	del(src)

/obj/landmark/costume/hats1/New()
	new /obj/item/clothing/head/collectable/petehat(src.loc)
	new /obj/item/clothing/head/collectable/metroid(src.loc)
	new /obj/item/clothing/head/collectable/chef(src.loc)
	new /obj/item/clothing/head/collectable/xenom(src.loc)
	del(src)

/obj/landmark/costume/hats2/New()
	new /obj/item/clothing/head/collectable/petehat(src.loc)
	new /obj/item/clothing/head/collectable/beret(src.loc)
	new /obj/item/clothing/head/collectable/police(src.loc)
	new /obj/item/clothing/head/collectable/slime(src.loc)
	del(src)

/obj/landmark/costume/hats3/New()
	new /obj/item/clothing/head/collectable/beret(src.loc)
	new /obj/item/clothing/head/collectable/tophat(src.loc)
	new /obj/item/clothing/head/collectable/paper(src.loc)
	new /obj/item/clothing/head/collectable/captain(src.loc)
	del(src)

/obj/landmark/costume/hats4/New()
	new /obj/item/clothing/head/collectable/paper(src.loc)
	new /obj/item/clothing/head/collectable/police(src.loc)
	new /obj/item/clothing/head/collectable/welding(src.loc)
	new /obj/item/clothing/head/collectable/hardhat(src.loc)
	del(src)

/obj/landmark/costume/hats5/New()
	new /obj/item/clothing/head/collectable/flatcap(src.loc)
	new /obj/item/clothing/head/collectable/pirate(src.loc)
	new /obj/item/clothing/head/collectable/kitty(src.loc)
	new /obj/item/clothing/head/collectable/hardhat(src.loc)
	del(src)

/obj/landmark/costume/hats6/New()
	new /obj/item/clothing/head/collectable/captain(src.loc)
	new /obj/item/clothing/head/collectable/police(src.loc)
	new /obj/item/clothing/head/collectable/HoS(src.loc)
	new /obj/item/clothing/head/collectable/swat(src.loc)
	del(src)

/obj/landmark/costume/hats7/New()
	new /obj/item/clothing/head/collectable/thunderdome(src.loc)
	new /obj/item/clothing/head/collectable/rabbitears(src.loc)
	new /obj/item/clothing/head/collectable/kitty(src.loc)
	new /obj/item/clothing/head/collectable/chef(src.loc)
	del(src)

/obj/landmark/costume/hats8/New()
	new /obj/item/clothing/head/collectable/paper(src.loc)
	new /obj/item/clothing/head/collectable/police(src.loc)
	new /obj/item/clothing/head/collectable/welding(src.loc)
	new /obj/item/clothing/head/collectable/hardhat(src.loc)
	del(src)




/*
/obj/landmark/costume/cyborg/New()
	new /obj/item/clothing/mask/gas/cyborg(src.loc)
	new /obj/item/clothing/shoes/cyborg(src.loc)
	new /obj/item/clothing/suit/cyborg_suit(src.loc)
	new /obj/item/clothing/gloves/cyborg(src.loc)

	var/obj/item/weapon/card/id/W = new /obj/item/weapon/card/id(src.loc)
	var/name = "Cyborg"
	name += " [pick(rand(1, 999))]"
	W.name = "Fake Cyborg Card"
	W.access = list(access_theatre)
	W.assignment = "Kill all humans! Beep. Boop."
	W.registered = name
	del(src)
	*/