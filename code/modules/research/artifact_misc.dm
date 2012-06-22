
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

/area/anomaly
	name = "Anomaly Lab"
	icon_state = "anomaly"

/obj/structure/noticeboard/anomaly/New()
	notices = 3
	icon_state = "nboard03"

	//add some memos
	var/obj/item/weapon/paper/P = new()
	P.name = "Memo RE: proper analysis procedure"
	P.info = "Rose,<br>activate <i>then</i> analyse the anomalies, your results will come so much quicker. Remember to employ basic quasi-elemental forces such as heat, energy, force and various chemical mixes - who knows why those ancient aliens made such obscure activation indices.<br><br>And don't forget your suit this time, I can't afford to have any researchers out of commision for as long as that again!.<br>- Ward"
	P.stamped = list(/obj/item/weapon/stamp/rd)
	P.overlays = list("paper_stamped_rd")
	src.contents += P

	P = new()
	P.name = "Memo RE: materials gathering"
	P.info = "Corasang,<br>the hands-on approach to gathering our samples may very well be slow at times, but it's safer than allowing the blundering miners to roll willy-nilly over our dig sites in their mechs, destroying everything in the process. And don't forget the escavation tools on your way out there!<br>- Ward"
	P.stamped = list(/obj/item/weapon/stamp/rd)
	P.overlays = list("paper_stamped_rd")
	src.contents += P

	P = new()
	P.name = "Memo RE: ethical quandaries"
	P.info = "Darion-<br><br>I don't care what his rank is, our business is that of science and knowledge - questions of moral application do not come into this. Sure, so there are those who would employ the energy-wave particles my modified device has managed to abscond for their own personal gain, but I can hardly see the practical benefits of some of those things our benefactors left behind. Ward--"
	P.stamped = list(/obj/item/weapon/stamp/rd)
	P.overlays = list("paper_stamped_rd")
	src.contents += P