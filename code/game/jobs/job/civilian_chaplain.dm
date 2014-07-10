//Due to how large this one is it gets its own file
/datum/job/chaplain
	title = "Chaplain"
	flag = CHAPLAIN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel's father, the head of personnel's son, and the holy ghost."
	selection_color = "#dddddd"
	access = list(access_morgue, access_chapel_office, access_crematorium, access_maint_tunnels)
	minimal_access = list(access_morgue, access_chapel_office, access_crematorium)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/chaplain

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0

		var/obj/item/weapon/storage/bible/B = new /obj/item/weapon/storage/bible(H) //BS12 EDIT
		H.equip_or_collect(B, slot_l_hand)
		H.equip_or_collect(new /obj/item/clothing/under/rank/chaplain(H), slot_w_uniform)
		//H.equip_or_collect(new /obj/item/device/pda/chaplain(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		spawn(0)
			var/religion_name = "Christianity"
			var/new_religion = copytext(sanitize(input(H, "You are the crew religious services officer. Would you like to change your religion? Default is Christianity, in SPACE. (Please ensure your ID is in your ID slot before entering)", "Name change", religion_name)),1,MAX_NAME_LEN)

			if (!new_religion)
				new_religion = religion_name

			var/datum/job/J = H.mind.role_alt_title
			switch(lowertext(new_religion)) //certain religions allow unique names for bibles and titles

				if("christianity")
					B.name = "The Holy Bible"
				if("catholicism", "roman catholicism")
					B.name = "The Catholic Bible"
					if (H.gender == FEMALE)
						J = "Nun"
					else
						J = "Priest"
				if("gnosticism")
					B.name = pick("The Gnostic Bible", "The Dead Seas Scrolls")
				if("satanism")
					B.name = "The Unholy Bible"
					if (H.gender == FEMALE)
						J = "Magistra"
					else
						J = "Magister"
				if("cthulu", "outer gods", "elder gods", "esoteric order of dagon")
					B.name = pick("The Necronomicon", "The Book of Eibon", "De Vermis Mysteriis", "Unaussprechlichen Kulten")
				if("islam")
					B.name = "The Quran"
					J = "Imam"
				if("slam")
					B.name = "Barkley: Shut Up and Jam - Gaiden"
					if (H.gender == FEMALE)
						J = "Mistress of Slam"
					else
						J = "Master of Slam"
				if("judaism")
					B.name = pick("The Torah", "The Talmud")
					J = "Rabbi"
				if("hindu", "hinduism")
					B.name = pick("The Vedas", "The Mahabharata")
					J = "Guru"
				if("buddahism")
					B.name = "The Tripitaka"
					J = "Lama"
				if("shinto", "shintoism")
					B.name = "Kojiki"
					if (H.gender == FEMALE)
						J = "Shrine Maiden"
					else
						J = "Kannushi"
				if("mormonism")
					B.name = "The Book of Mormon"
				if("confucianism")
					B.name = pick("The I Ching", "Great Learning")
				if("wicca", "paganism")
					B.name = "The Book of Shadows"
					if (H.gender == FEMALE)
						J = "High Priestess"
					else
						J = "High Priest"
				if("norse")
					B.name = "The Edda"
					J = "Godi"
				if("druidism", "celtic")
					B.name = "The Book of Leinster"
					J = "Druid"
				if("atheism")
					B.name ="The God Delusion"
					H.equip_or_collect(new /obj/item/clothing/head/fedora(H), slot_head)
				if("scientology")
					B.name = pick("The Biography of L. Ron Hubbard", "Dianetics")
					J = "OT III"
				if("discordianism")
					B.name = "The Principia Discordia"
					J = "Episkopos"
				if("rastafarianism", "rastafari movement")
					B.name = "The Holy Piby"
				if("pastafarianism")
					B.name = "The Gospel of the Flying Spaghetti Monster"
				if("chaos")
					B.name = pick("The Book of Lorgar", "The Book of Magnus")
					J = "Apostate Preacher"
				if("imperium", "imperial cult")
					B.name = pick("An Uplifting Primer", "Codex Astartes", "Codex Hereticus")
					if (H.gender == FEMALE)
						J = "Prioress"
					else
						J = "Confessor"
				if("toolboxia")
					B.name = "The Toolbox Manifesto"
				if("homosexuality")
					B.name = pick("Guys Gone Wild", "Hunk Rump")
				if("lol", "wtf", "gay", "penis", "ass", "poo", "badmin", "shitmin", "deadmin", "cock", "cocks", "nigger", "faggot", "dickbutt")
					B.name = pick("Woodys Got Wood: The Aftermath", "War of the Cocks", "Sweet Bro and Hella Jef: Expanded Edition", "The Book of Pomf")
					H.setBrainLoss(100) // starts off retarded as fuck
				if("science")
					B.name = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", "For I Have Tasted The Fruit", "Non-Linear Genetics", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
					J = "Academician"
				if("tribunal", "almsivi")
					B.name = "The 36 Lessons of Vivec"
					J = "Curate"
				if("nine divines", "eight divines")
					B.name = "The Elder Scrolls"
					J = "Disciple of the Nine"
				if("daedra")
					B.name = pick("The Blessings of Sheogorath", "Boethiah's Pillow Book", "Invocation of Azura")
				if("bokononism")
					B.name = pick("The Book of Bokonon")
				if("faith of the seven")
					B.name = "The Seven-Pointed Star"
					if (H.gender == FEMALE)
						J = "Septa"
					else
						J = "Septon"
				if("goa'uld")
					B.name = "The Abydos Cartouche"
					J = "First Prime"
				if("unitology")
					B.name = "Teachings of Unitology"
					J = "Vested"
				if("zakarum")
					B.name = "The Visions of Akarat"
				if("ianism")
					B.name = "The Poky Little Puppy"
				if("adminism", "admintology")
					B.name = "Breaking Through the Fourth Wall"
				else
					B.name = "The Holy Book of [new_religion]"

			//this goes down here due to problems with loading orders that took me 4 hours to identify
			var/obj/item/weapon/card/id/I = null
			if(istype(H.wear_id, /obj/item/weapon/card/id/)) //this prevents people from causing weirdness by putting other things into their slots before chosing their religion
				I = H.wear_id
				if(I.registered_name == H.real_name) //makes sure the ID is the chaplain's own
					I.assignment = J
					I.name = text("[I.registered_name]'s ID Card ([I.assignment])")
			var/obj/item/device/pda/P = null
			if(istype(H.belt, /obj/item/device/pda)) //this prevents people from causing weirdness by putting other things into their slots before chosing their religion
				P = H.belt
				if(P.owner == H.real_name) //makes sure the PDA is the chaplain's own
					P.ownjob = J
					P.name = text("PDA-[P.owner] ([P.ownjob])")
			data_core.manifest_modify(H.real_name, J) //updates manifest
			feedback_set_details("religion_name","[new_religion]")


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
				new_book_style = input(H,"Which bible style would you like?") in list("Bible", "Koran", "Scrapbook", "Creeper", "White Bible", "Holy Light", "Athiest", "Tome", "The King in Yellow", "Ithaqua", "Scientology", "the bible melts", "Unaussprechlichen Kulten", "Necronomicon", "Book of Shadows", "Torah", "Burning", "Honk", "Ianism")
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
						for(var/area/chapel/main/A in world)
							for(var/turf/T in A.contents)
								if(T.icon_state == "carpetsymbol")
									T.dir = 5
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
					if("Unaussprechlichen Kulten")
						B.icon_state = "kulten"
						B.item_state = "kulten"
					if("Necronomicon")
						B.icon_state = "necronomicon"
						B.item_state = "necronomicon"
					if("Book of Shadows")
						B.icon_state = "shadows"
						B.item_state = "shadows"
						for(var/area/chapel/main/A in world)
							for(var/turf/T in A.contents)
								if(T.icon_state == "carpetsymbol")
									T.dir = 6
					if("Torah")
						B.icon_state = "torah"
						B.item_state = "torah"
						for(var/area/chapel/main/A in world)
							for(var/turf/T in A.contents)
								if(T.icon_state == "carpetsymbol")
									T.dir = 1
					if("Burning")
						B.icon_state = "burning"
						B.item_state = "syringe_kit"
					if("Honk")
						B.icon_state = "honkbook"
						B.item_state = "honkbook"
					if("Ianism")
						B.icon_state = "ianism"
						B.item_state = "ianism"
						for(var/area/chapel/main/A in world)
							for(var/turf/T in A.contents)
								if(T.icon_state == "carpetsymbol")
									T.dir = 9
					else
						// if christian bible, revert to default
						B.icon_state = "bible"
						B.item_state = "bible"
						for(var/area/chapel/main/A in world)
							for(var/turf/T in A.contents)
								if(T.icon_state == "carpetsymbol")
									T.dir = 2

				H.update_inv_l_hand() // so that it updates the bible's item_state in his hand

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
			feedback_set_details("religion_deity","[new_deity]")
			feedback_set_details("religion_book","[new_book_style]")
		return 1
