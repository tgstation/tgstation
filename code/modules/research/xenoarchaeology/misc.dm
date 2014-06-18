#define XENOARCH_SPAWN_CHANCE 0.5
#define XENOARCH_SPREAD_CHANCE 15
#define ARTIFACT_SPAWN_CHANCE 20

proc/SetupXenoarch()
	for(var/turf/unsimulated/mineral/M in block(locate(1,1,1), locate(world.maxx, world.maxy, world.maxz)))
		if(!prob(XENOARCH_SPAWN_CHANCE))
			continue

		var/digsite = get_random_digsite_type()
		var/list/processed_turfs = list()
		var/list/turfs_to_process = list(M)

		while(turfs_to_process.len)
			var/turf/unsimulated/mineral/archeo_turf = turfs_to_process[1]

			for(var/turf/unsimulated/mineral/T in orange(1, archeo_turf))
				if(T.finds)
					continue

				if(T in processed_turfs)
					continue

				if(prob(XENOARCH_SPREAD_CHANCE))
					turfs_to_process.Add(T)

			turfs_to_process.Remove(archeo_turf)
			processed_turfs.Add(archeo_turf)

			if(isnull(archeo_turf.finds))
				archeo_turf.finds = list()

				if(prob(50))
					archeo_turf.finds.Add(new /datum/find(digsite, rand(5,95)))
				else if(prob(75))
					archeo_turf.finds.Add(new /datum/find(digsite, rand(5,45)))
					archeo_turf.finds.Add(new /datum/find(digsite, rand(55,95)))
				else
					archeo_turf.finds.Add(new /datum/find(digsite, rand(5,30)))
					archeo_turf.finds.Add(new /datum/find(digsite, rand(35,75)))
					archeo_turf.finds.Add(new /datum/find(digsite, rand(75,95)))

				//sometimes a find will be close enough to the surface to show
				var/datum/find/F = archeo_turf.finds[1]

				if(F.excavation_required <= F.view_range)
					archeo_turf.archaeo_overlay = "overlay_archaeo[rand(1,3)]"
					archeo_turf.overlays += archeo_turf.archaeo_overlay

		//dont create artifact machinery in animal or plant digsites, or if we already have one
		if(!M.artifact_find && digsite != 1 && digsite != 2 && prob(ARTIFACT_SPAWN_CHANCE))
			M.artifact_find = new()
			master_controller.artifact_spawning_turfs.Add(M)

		if(isnull(M.geologic_data))
			M.geologic_data = new/datum/geosample(M)

#undef XENOARCH_SPAWN_CHANCE
#undef XENOARCH_SPREAD_CHANCE
#undef ARTIFACT_SPAWN_CHANCE

//---- Noticeboard

/obj/structure/noticeboard/anomaly
	notices = 5
	icon_state = "nboard05"

/obj/structure/noticeboard/anomaly/New()
	//add some memos
	var/obj/item/weapon/paper/P = new()
	P.name = "Memo RE: proper analysis procedure"
	P.info = "<br>We keep test dummies in pens here for a reason, so standard procedure should be to activate newfound alien artifacts and place the two in close proximity. Promising items I might even approve monkey testing on."
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
	P.info = "how many times do i have to tell you people, these xeno-arch samples are del-i-cate, and should be handled so! careful application of a focussed, concentrated heat or some corrosive liquids should clear away the extraneous carbon matter, while application of an energy beam will most decidedly destroy it entirely - like someone did to the chemical dispenser! W, <b>the one who signs your paychecks</b>"
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
		new /obj/item/weapon/book/manual/stasis(src)
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
		new /obj/item/device/measuring_tape(src)
		new /obj/item/weapon/pickaxe/hand(src)
		return

//---- Isolation room air alarms

/obj/machinery/alarm/isolation
	name = "Isolation room air control"
	req_access = list(access_research)
