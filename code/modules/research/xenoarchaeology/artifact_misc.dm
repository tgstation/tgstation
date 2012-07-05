
/obj/item/clothing/suit/bio_suit/anomaly
	name = "Anomaly Suit"
	desc = "A sealed bio suit capable of resisting exotic alien energies and low pressure environments."
	icon_state = "engspace_suit"
	item_state = "engspace_suit"
	heat_transfer_coefficient = 0.02
	protective_temperature = 1000
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen, /obj/item/weapon/pickaxe/excavationtool)

/obj/item/clothing/head/bio_hood/anomaly
	name = "Anomaly Hood"
	desc = "A sealed bio hood capable of resisting exotic alien energies and low pressure environments."
	icon_state = "engspace_helmet"
	item_state = "engspace_helmet"
	heat_transfer_coefficient = 0.02
	protective_temperature = 1000

/obj/structure/noticeboard/anomaly/New()
	notices = 5
	icon_state = "nboard05"

	//add some memos
	var/obj/item/weapon/paper/P = new()
	P.name = "Memo RE: proper analysis procedure"
	P.info = "Rose,<br>activate <i>then</i> analyse the anomalies, your results will come so much quicker. Remember to employ basic quasi-elemental forces such as heat, energy, force and various chemical mixes - who knows why those ancient aliens made such obscure activation indices.<br><br>And don't forget your suit this time, I can't afford to have any researchers out of commision for as long as that again!.<br>Ward"
	P.stamped = list(/obj/item/weapon/stamp/rd)
	P.overlays = list("paper_stamped_rd")
	src.contents += P

	P = new()
	P.name = "Memo RE: materials gathering"
	P.info = "Corasang,<br>the hands-on approach to gathering our samples may very well be slow at times, but it's safer than allowing the blundering miners to roll willy-nilly over our dig sites in their mechs, destroying everything in the process. And don't forget the escavation tools on your way out there!<br>- R.W"
	P.stamped = list(/obj/item/weapon/stamp/rd)
	P.overlays = list("paper_stamped_rd")
	src.contents += P

	P = new()
	P.name = "Memo RE: ethical quandaries"
	P.info = "Darion-<br><br>I don't care what his rank is, our business is that of science and knowledge - questions of moral application do not come into this. Sure, so there are those who would employ the energy-wave particles my modified device has managed to abscond for their own personal gain, but I can hardly see the practical benefits of some of those things our benefactors left behind. Ward--"
	P.stamped = list(/obj/item/weapon/stamp/rd)
	P.overlays = list("paper_stamped_rd")
	src.contents += P

	P = new()
	P.name = "READ ME! Before you people destroy any more samples"
	P.info = "how many times do i have to tell you people, these xeno-arch samples are del-i-cate, and should be handled so! careful application of a focussed, ceoncentrated heat or some corrosive liquids should clear away the extraneous carbon matter, while application of an energy beam will most decidedly destroy it entirely! W, <b>the one who signs your paychecks</b>"
	P.stamped = list(/obj/item/weapon/stamp/rd)
	P.overlays = list("paper_stamped_rd")
	src.contents += P

	P = new()
	P.name = "Reminder regarding the anomalous material suits"
	P.info = "Do you people think the anomaly suits are cheap to come by? I'm about a hair trigger away from instituting a log book for the damn things. Only wear them if you're going out for a dig, and for god's sake don't go tramping around the station in them unless you're field testing something, R"
	P.stamped = list(/obj/item/weapon/stamp/rd)
	P.overlays = list("paper_stamped_rd")
	src.contents += P
