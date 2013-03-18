
//---- Noticeboard

/obj/structure/noticeboard/anomaly/New()
	notices = 5
	icon_state = "nboard05"

	//add some memos
	var/obj/item/weapon/paper/P = new()
	P.name = "Memo RE: proper analysis procedure"
	P.info = "Rose,<br>activate <i>then</i> analyse the artifacts, the machine will have a much easier time determining their function/s. Remember to employ basic quasi-elemental forces such as heat, energy, force and various chemical mixes - who knows why those ancient aliens made such obscure activation indices.<br><br>And don't forget your suit this time, I can't afford to have any researchers out of commision for as long as that again!.<br>Ward"
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
	P.info = "Darion-<br><br>I don't care what his rank is, our business is that of science and knowledge - questions of moral application do not come into this. Sure, so there are those who would employ the energy-wave particles my modified device has managed to abscond for their own personal gain, but I can hardly see the practical benefits of some of these artifacts our benefactors left behind. Ward--"
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
	P.info = "Do you people think the anomaly suits are cheap to come by? I'm about a hair trigger away from instituting a log book for the damn things. Only wear them if you're going out for a dig, and for god's sake don't go tramping around in them unless you're field testing something, R"
	P.stamped = list(/obj/item/weapon/stamp/rd)
	P.overlays = list("paper_stamped_rd")
	src.contents += P

//---- Bookcase

/obj/structure/bookcase/manuals/xenoarchaeology
	name = "Xenoarchaeology Manuals bookcase"

	New()
		..()
		new /obj/item/weapon/book/manual/excavation(src)
		new /obj/item/weapon/book/manual/mass_spectrometry(src)
		new /obj/item/weapon/book/manual/materials_chemistry_analysis(src)
		new /obj/item/weapon/book/manual/anomaly_testing(src)
		new /obj/item/weapon/book/manual/anomaly_spectroscopy(src)
		update_icon()

//---- Lockers and closets

/obj/structure/closet/secure_closet/xenoarchaeologist
	name = "Xenoarchaeologist Locker"
	req_access = list(access_tox_storage)
	icon_state = "secureres1"
	icon_closed = "secureres"
	icon_locked = "secureres1"
	icon_opened = "secureresopen"
	icon_broken = "secureresbroken"
	icon_off = "secureresoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/under/rank/scientist(src)
		new /obj/item/clothing/suit/storage/labcoat(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/clothing/glasses/science(src)
		new /obj/item/device/radio/headset/headset_sci(src)
		new /obj/item/weapon/storage/belt/archaeology(src)
		new /obj/item/weapon/storage/box/excavation(src)
		return

/obj/structure/closet/excavation
	name = "Excavation tools"
	icon_state = "toolcloset"
	icon_closed = "toolcloset"
	icon_opened = "toolclosetopen"


	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/belt/archaeology(src)
		new /obj/item/weapon/storage/box/excavation(src)
		new /obj/item/device/flashlight/lantern(src)
		new /obj/item/device/depth_scanner(src)
		new /obj/item/device/core_sampler(src)
		new /obj/item/device/gps(src)
		new /obj/item/device/beacon_locator(src)
		new /obj/item/device/radio/beacon(src)
		new /obj/item/clothing/glasses/meson(src)
		new /obj/item/weapon/pickaxe(src)
		return

//---- Isolation room air alarms

/obj/machinery/alarm/isolation
	name = "Isolation room air control"
	req_access = list(access_research)