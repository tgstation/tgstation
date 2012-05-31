//Due to how large this one is it gets its own file
/datum/job/chaplain
	title = "Chaplain"
	flag = CHAPLAIN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	alt_titles = list("Counselor")


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0

		var/obj/item/weapon/storage/bible/B = new /obj/item/weapon/storage/bible(H)
		H.equip_if_possible(B, H.slot_l_hand)
		H.equip_if_possible(new /obj/item/device/pda/chaplain(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/under/rank/chaplain(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		spawn(0)
			var/religion_name = "Christianity"
			var/new_religion = copytext(sanitize(input(H, "You are the Chaplain / Counselor. For game mechanics purposes, you need to choose a religion either way. Would you like to change your religion? Default is Christianity, in SPACE.", "Name change", religion_name)),1,MAX_NAME_LEN)

			if ((length(new_religion) == 0) || (new_religion == "Christianity"))
				new_religion = religion_name

				switch(lowertext(new_religion))
					if("christianity")
						B.name = pick("The Holy Bible","The Dead Sea Scrolls")
					if("satanism")
						B.name = "The Unholy Bible"
					if("cthulu")
						B.name = "The Necronomicon"
					if("islam")
						B.name = "Quran"
					if("scientology")
						B.name = pick("The Biography of L. Ron Hubbard","Dianetics")
					if("chaos")
						B.name = "The Book of Lorgar"
					if("imperium")
						B.name = "Uplifting Primer"
					if("science")
						B.name = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
					else
						B.name = "The Holy Book of [new_religion]"
//			feedback_set_details("religion_name","[new_religion]")

		spawn(1)
			var/deity_name = "Space Jesus"
			var/new_deity = copytext(sanitize(input(H, "Would you like to change your deity? Default is Space Jesus.", "Name change", deity_name)),1,MAX_NAME_LEN)

			if ((length(new_deity) == 0) || (new_deity == "Space Jesus") )
				new_deity = deity_name
			B.deity_name = new_deity

			var/accepted = 0
			var/outoftime = 0
			spawn(200) // 20 seconds to choose
				outoftime = 1
			var/new_book_style = "Bible"

			while(!accepted)
				if(!B) break // prevents possible runtime errors
				new_book_style = input(H,"Which bible style would you like?") in list("Bible", "Koran", "Scrapbook", "Creeper", "White Bible", "Holy Light", "Athiest", "Tome", "The King in Yellow", "Ithaqua", "Scientology", "the bible melts", "Necronomicon")
				switch(new_book_style)
					if("Koran")
						B.icon_state = "koran"
						B.item_state = "koran"
						for(var/area/chapel/main/A in world)
							for(var/turf/T in A.contents)
								if(T.icon_state == "carpetsymbol")
									T.dir = 4
					if("Scrapbook")
						B.icon_state = "scrapbook"
						B.item_state = "scrapbook"
					if("Creeper")
						B.icon_state = "creeper"
						B.item_state = "syringe_kit"
					if("White Bible")
						B.icon_state = "white"
						B.item_state = "syringe_kit"
					if("Holy Light")
						B.icon_state = "holylight"
						B.item_state = "syringe_kit"
					if("Athiest")
						B.icon_state = "athiest"
						B.item_state = "syringe_kit"
						for(var/area/chapel/main/A in world)
							for(var/turf/T in A.contents)
								if(T.icon_state == "carpetsymbol")
									T.dir = 10
					if("Tome")
						B.icon_state = "tome"
						B.item_state = "syringe_kit"
					if("The King in Yellow")
						B.icon_state = "kingyellow"
						B.item_state = "kingyellow"
					if("Ithaqua")
						B.icon_state = "ithaqua"
						B.item_state = "ithaqua"
					if("Scientology")
						B.icon_state = "scientology"
						B.item_state = "scientology"
						for(var/area/chapel/main/A in world)
							for(var/turf/T in A.contents)
								if(T.icon_state == "carpetsymbol")
									T.dir = 8
					if("the bible melts")
						B.icon_state = "melted"
						B.item_state = "melted"
					if("Necronomicon")
						B.icon_state = "necronomicon"
						B.item_state = "necronomicon"
					else
						// if christian bible, revert to default
						B.icon_state = "bible"
						B.item_state = "bible"
						for(var/area/chapel/main/A in world)
							for(var/turf/T in A.contents)
								if(T.icon_state == "carpetsymbol")
									T.dir = 2

				H:update_clothing() // so that it updates the bible's item_state in his hand

				switch(input(H,"Look at your bible - is this what you want?") in list("Yes","No"))
					if("Yes")
						accepted = 1
					if("No")
						if(outoftime)
							H << "Welp, out of time, buddy. You're stuck. Next time choose faster."
							accepted = 1

			if(ticker)
				ticker.Bible_icon_state = B.icon_state
				ticker.Bible_item_state = B.item_state
				ticker.Bible_name = B.name
				ticker.Bible_deity_name = B.deity_name
//			feedback_set_details("religion_deity","[new_deity]")
//			feedback_set_details("religion_book","[new_book_style]")
		return 1