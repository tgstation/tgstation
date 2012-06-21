//Costume spawner

/obj/effect/landmark/costume/New() //costume spawner, selects a random subclass and disappears

	var/list/options = typesof(/obj/effect/landmark/costume)
	var/PICK= options[rand(1,options.len)]
	new PICK(src.loc)
	del(src)

//SUBCLASSES.  Spawn a bunch of items and disappear likewise
/obj/effect/landmark/costume/chicken/New()
	new /obj/item/clothing/suit/chickensuit(src.loc)
	del(src)

/obj/effect/landmark/costume/gladiator/New()
	new /obj/item/clothing/under/gladiator(src.loc)
	new /obj/item/clothing/head/helmet/gladiator(src.loc)
	del(src)

/obj/effect/landmark/costume/madscientist/New()
	new /obj/item/clothing/under/gimmick/rank/captain/suit(src.loc)
	new /obj/item/clothing/head/flatcap(src.loc)
	new /obj/item/clothing/suit/storage/labcoat/mad(src.loc)
	new /obj/item/clothing/glasses/gglasses(src.loc)
	del(src)

/obj/effect/landmark/costume/elpresidente/New()
	new /obj/item/clothing/under/gimmick/rank/captain/suit(src.loc)
	new /obj/item/clothing/head/flatcap(src.loc)
	new /obj/item/clothing/mask/cigarette/cigar/havana(src.loc)
	new /obj/item/clothing/shoes/jackboots(src.loc)
	del(src)

/obj/effect/landmark/costume/nyangirl/New()
	new /obj/item/clothing/under/schoolgirl(src.loc)
	new /obj/item/clothing/head/kitty(src.loc)
	del(src)

/obj/effect/landmark/costume/maid/New()
	new /obj/item/clothing/under/blackskirt(src.loc)
	var/CHOICE = pick( /obj/item/clothing/head/beret , /obj/item/clothing/head/rabbitears )
	new CHOICE(src.loc)
	new /obj/item/clothing/glasses/blindfold(src.loc)
	del(src)

/obj/effect/landmark/costume/butler/New()
	new /obj/item/clothing/suit/storage/wcoat(src.loc)
	new /obj/item/clothing/under/suit_jacket(src.loc)
	new /obj/item/clothing/head/that(src.loc)
	del(src)

/obj/effect/landmark/costume/scratch/New()
	new /obj/item/clothing/gloves/white(src.loc)
	new /obj/item/clothing/shoes/white(src.loc)
	new /obj/item/clothing/under/scratch(src.loc)
//	if (prob(30))
//		new /obj/item/clothing/head/helmet/cueball(src.loc)
	del(src)

/obj/effect/landmark/costume/highlander/New()
	new /obj/item/clothing/under/kilt(src.loc)
	new /obj/item/clothing/head/beret(src.loc)
	del(src)

/obj/effect/landmark/costume/prig/New()
	new /obj/item/clothing/suit/storage/wcoat(src.loc)
	new /obj/item/clothing/glasses/monocle(src.loc)
	var/CHOICE= pick( /obj/item/clothing/head/bowlerhat, /obj/item/clothing/head/that)
	new CHOICE(src.loc)
	new /obj/item/clothing/shoes/black(src.loc)
	new /obj/item/weapon/cane(src.loc)
	new /obj/item/clothing/under/sl_suit(src.loc)
	new /obj/item/clothing/mask/fakemoustache(src.loc)
	del(src)

/obj/effect/landmark/costume/plaguedoctor/New()
	new /obj/item/clothing/suit/bio_suit/plaguedoctorsuit(src.loc)
	new /obj/item/clothing/head/plaguedoctorhat(src.loc)
	del(src)

/obj/effect/landmark/costume/nightowl/New()
	new /obj/item/clothing/under/owl(src.loc)
	new /obj/item/clothing/mask/owl_mask(src.loc)
	del(src)

/obj/effect/landmark/costume/waiter/New()
	new /obj/item/clothing/under/waiter(src.loc)
	var/CHOICE= pick( /obj/item/clothing/head/kitty, /obj/item/clothing/head/rabbitears)
	new CHOICE(src.loc)
	new /obj/item/clothing/suit/storage/apron(src.loc)
	del(src)

/obj/effect/landmark/costume/pirate/New()
	new /obj/item/clothing/under/pirate(src.loc)
	new /obj/item/clothing/suit/pirate(src.loc)
	var/CHOICE = pick( /obj/item/clothing/head/pirate , /obj/item/clothing/head/bandana )
	new CHOICE(src.loc)
	new /obj/item/clothing/glasses/eyepatch(src.loc)
	del(src)

/obj/effect/landmark/costume/commie/New()
	new /obj/item/clothing/under/soviet(src.loc)
	new /obj/item/clothing/head/ushanka(src.loc)
	del(src)
/*
/obj/effect/landmark/costume/nurse/New()
	new /obj/item/clothing/under/rank/nursesuit(src.loc)
	new /obj/item/clothing/head/nursehat(src.loc)
	new /obj/item/clothing/glasses/regular(src.loc)
	new /obj/item/clothing/gloves/latex(src.loc)
	new /obj/item/clothing/mask/surgical(src.loc)
	del(src)*/


/obj/effect/landmark/costume/imperium_monk/New()
	new /obj/item/clothing/suit/imperium_monk(src.loc)
	if (prob(25))
		new /obj/item/clothing/mask/gas/cyborg(src.loc)
	del(src)

/obj/effect/landmark/costume/holiday_priest/New()
	new /obj/item/clothing/suit/holidaypriest(src.loc)
	del(src)

/*
/obj/effect/landmark/costume/spiderman/New()
	new /obj/item/clothing/under/spiderman(src.loc)
	new /obj/item/clothing/mask/spiderman(src.loc)
	del(src)*/

/*
/obj/effect/landmark/costume/marisawizard/New()
	new /obj/item/clothing/head/wizard/marisa(src.loc)
	new/obj/item/clothing/suit/wizrobe/marisa(src.loc)
	del(src)*/

/obj/effect/landmark/costume/marisawizard/fake/New()
	new /obj/item/clothing/head/wizard/marisa/fake(src.loc)
	new/obj/item/clothing/suit/wizrobe/marisa/fake(src.loc)
	del(src)

/obj/effect/landmark/costume/fakewizard/New()
	new /obj/item/clothing/suit/wizrobe/fake(src.loc)
	new /obj/item/clothing/head/wizard/fake(src.loc)
	del(src)

/obj/effect/landmark/costume/sexyclown/New()
	new /obj/item/clothing/mask/gas/sexyclown(src.loc)
	new /obj/item/clothing/under/sexyclown(src.loc)
	del(src)

/obj/effect/landmark/costume/sexymime/New()
	new /obj/item/clothing/mask/gas/sexymime(src.loc)
	new /obj/item/clothing/under/sexymime(src.loc)
	del(src)


/*
/obj/effect/landmark/costume/cyborg/New()
	new /obj/item/clothing/mask/gas/cyborg(src.loc)
	new /obj/item/clothing/shoes/cyborg(src.loc)
	new /obj/item/clothing/suit/cyborg_suit(src.loc)
	new /obj/item/clothing/gloves/cyborg(src.loc)

	var/obj/item/weapon/card/id/W = new /obj/item/weapon/card/id(src.loc)
	var/name = "Cyborg"
	name += " [pick(rand(1, 999))]"
	W.name = "Fake Cyborg Card"
	W.access = list(ACCESS_THEATRE)
	W.assignment = "Kill all humans! Beep. Boop."
	W.registered_name = name
	del(src)
	*/