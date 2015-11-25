//Due to how large this one is, it gets its own file from civilian.dm
/datum/job/chaplain
	title = "Chaplain"
	flag = CHAPLAIN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "The God(s), the Head of Personnel too."
	selection_color = "#dddddd"
	access = list(access_morgue, access_chapel_office, access_crematorium, access_maint_tunnels)
	minimal_access = list(access_morgue, access_chapel_office, access_crematorium)
	pdaslot = slot_belt
	pdatype = /obj/item/device/pda/chaplain

/datum/job/chaplain/equip(var/mob/living/carbon/human/H)

	H.add_language("Spooky") //SPOOK
	var/obj/item/weapon/storage/bible/B = new /obj/item/weapon/storage/bible(H) //BS12 EDIT
	H.equip_or_collect(B, slot_l_hand)
	H.equip_or_collect(new /obj/item/clothing/under/rank/chaplain(H), slot_w_uniform)
	//H.equip_or_collect(new /obj/item/device/pda/chaplain(H), slot_belt)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	if(H.backbag == 1)
		H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)

	var/religion_name = "Christianity" //Default
	var/deity_name = "Space Jesus" //Also default, set below

	spawn(0) //We are done giving earthly belongings, now let's move on to spiritual matters

		var/new_religion = sanitize(stripped_input(H, "You are the crew's Religious Services Chaplain. What religion do you follow and teach? (Please put your ID in your ID slot to prevent errors)", "Name of Religion", religion_name), 1, MAX_NAME_LEN)

		if(!new_religion)
			new_religion = religion_name //Give them the default one

		var/datum/job/J = H.mind.role_alt_title

		switch(lowertext(new_religion)) //Let us begin going through the list of special religions we can give them. It's a long list, trust me. We assign them a bible name, a god and misc fun stuff
			if("christianity")
				B.name = "The Holy Bible"
				deity_name = "Space Jesus"
			if("catholic", "catholicism", "roman catholicism")
				B.name = "The Catholic Bible"
				/*
				if(H.gender == FEMALE)
					J = "Nun"
				else
					J = "Priest"
				*/
				J = "Bishop"
				deity_name = "Jesus Christ"
				H.equip_or_collect(new /obj/item/clothing/head/mitre(H), slot_head)
			if("theist", "gnosticism", "theism")
				B.name = pick("The Gnostic Bible", "The Dead Seas Scrolls")
				deity_name = "God"
			if("satan", "evil", "satanism")
				B.name = "The Satanic Bible" //What I found on Google, ergo the truth
				if(H.gender == FEMALE)
					J = "Magistra"
				else
					J = "Magister"
				deity_name = "Satan"
			if("cthulhu", "outer gods", "elder gods", "esoteric order of dagon")
				B.name = pick("The Necronomicon", "The Book of Eibon", "De Vermis Mysteriis", "Unaussprechlichen Kulten")
				deity_name = "Cthulhu" //I hope it's spelt correctly
			if("islam", "muslim")
				B.name = "The Quran"
				J = "Imam"
				deity_name = "Allah"
			if("slam")
				B.name = "Barkley: Shut Up and Jam - Gaiden"
				if(H.gender == FEMALE)
					J = "Mistress of Slam"
				else
					J = "Master of Slam"
				deity_name = "Charles Barkley"
			if("jew", "judaism")
				B.name = pick("The Torah", "The Talmud")
				J = "Rabbi"
				deity_name = "Yahweh"
			if("hindu", "hinduism")
				B.name = pick("The Vedas", "The Mahabharata")
				J = "Guru"
				deity_name = pick("Brahma", "Vishnu", "Shiva", "Ganesha") //The major ones at least, and yes it's polytheist
			if("buddha", "buddhism")
				B.name = "The Tripitaka"
				J = "Monk"
				deity_name = "Buddha"
			if("shinto", "shintoism")
				B.name = "Kojiki"
				if(H.gender == FEMALE)
					J = "Shrine Maiden"
				else
					J = "Kannushi"
				deity_name = "Kami" //Polytheist and shit, do I sound like a weeb ?
			if("mormon", "mormonism")
				B.name = "The Book of Mormon"
				J = "Apostle"
				deity_name = "God the Father-Elohim"
			if("confucianism")
				B.name = pick("The I Ching", "Great Learning")
				J = "Scholar" //I don't know honestly
				deity_name = "Tian" //I found this somewhere, I guess that's true
			if("wicca", "paganism")
				B.name = "The Book of Shadows"
				if(H.gender == FEMALE)
					J = "High Priestess"
				else
					J = "High Priest"
				deity_name = "The Gods" //Damn pagans
			if("norse")
				B.name = "The Edda"
				J = "Godi"
				deity_name = pick("Thor", "Odin") //Literally the only two I know, bite me
			if("druidism", "celtic")
				B.name = "The Book of Leinster"
				J = "Druid"
				deity_name = pick("Toutatis", "Belenus", "Britannia") //Hon
			if("atheism", "none")
				B.name = "The God Delusion"
				H.equip_or_collect(new /obj/item/clothing/head/fedora(H), slot_head)
				deity_name = "Richard Dawkins"
			if("evolution", "biology", "monkey", "monkeys")
				B.name = "The Theory of Evolution"
				J = "Biologist"
				deity_name = "Charles Darwin"
			if("scientology")
				B.name = pick("The Biography of L. Ron Hubbard", "Dianetics")
				J = "OT III"
				deity_name = "The Eighth Dynamic" //Don't ask, just don't
			if("discordianism")
				B.name = "The Principia Discordia"
				J = "Episkopos"
				deity_name = "Eris" //Thanks Google
			if("rastafarianism", "rastafari movement")
				B.name = "The Holy Piby"
				deity_name = "Haile Selassie I"
			if("hellenism") //None of that roman copypasta, incidentally
				B.name = "The Odyssey"
				J = "Oracle"
				deity_name = pick("Zeus", "Neptune", "Athena", "Persephone")
			if("pastafarianism")
				B.name = "The Gospel of the Flying Spaghetti Monster"
				deity_name = "The Flying Spaghetti Monster"
			if("chaos")
				B.name = pick("The Book of Lorgar", "The Book of Magnus")
				J = "Apostate Preacher"
				deity_name = pick("Khorne", "Nurgle", "Tzeentch", "Slaanesh")
			if("imperium", "imperial cult")
				B.name = pick("An Uplifting Primer", "Codex Astartes", "Codex Hereticus")
				if(H.gender == FEMALE)
					J = "Prioress"
				else
					J = "Confessor"
				deity_name = "The God-Emperor of Mankind"
			if("toolboxia", "toolbox")
				B.name = "The Toolbox Manifesto"
				J = "Chief Assistant"
				deity_name = "The Toolbox"
			if("homosexuality", "faggotry", "gayness")
				B.name = pick("Guys Gone Wild", "Hunk Rump")
				deity_name = "The Gays" //Fucked if I know
			if("lol", "wtf", "gay", "penis", "ass", "poo", "badmin", "shitmin", "deadmin", "cock", "cocks", "nigger", "faggot", "dickbutt", ":^)", "XD", "le")
				B.name = pick("Woody's Got Wood: The Aftermath", "War of the Cocks", "Sweet Bro and Hella Jef: Expanded Edition", "The Book of Pomf")
				H.setBrainLoss(100) //Starts off retarded as fuck, that'll teach him
				deity_name = "Brian Damag" //Ha
			if("science")
				B.name = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", \
							  "For I Have Tasted The Fruit", "Non-Linear Genetics", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
				J = "Academician"
				deity_name = pick("Albert Einstein", "Isaac Newton", "Niels Bohr", "Stephen Hawking")
			if("tribunal", "almsivi")
				B.name = "The 36 Lessons of Vivec"
				J = "Curate"
				deity_name = pick("Almalexia", "Sotha Sil", "Vivec")
			if("nine divines", "eight divines")
				B.name = "The Elder Scrolls"
				J = "Disciple of the Nine"
				deity_name = pick("Talos", "Akatosh", "Dibella", "Stendarr", "Kynareth", "Mara", "Arkay", "Julianos", "Zenithar")
			if("daedra")
				B.name = pick("The Blessings of Sheogorath", "Boethiah's Pillow Book", "Invocation of Azura")
				J = "Deadra Worshipper"
				deity_name = pick("Azura", "Boethiah", "Sheogorath", "Sanguine", "Hircine", "Meridia", "Hermaeus Mora", "Nocturnal")
			if("bokononism")
				B.name = pick("The Book of Bokonon")
				J = "Worshipper"
				deity_name = "Boko-Maru" //Completely wrong, but fuck it
			if("faith of the seven")
				B.name = "The Seven-Pointed Star"
				if(H.gender == FEMALE)
					J = "Septa"
				else
					J = "Septon"
				deity_name = pick("Father", "Mother")
			if("goa'uld")
				B.name = "The Abydos Cartouche"
				J = "First Prime"
				deity_name = "Ra"
			if("unitology")
				B.name = "Teachings of Unitology"
				J = "Vested"
				deity_name = "The Marker"
			if("zakarum")
				B.name = "The Visions of Akarat"
				J = "Disciple"
				deity_name = "The Light"
			if("ianism")
				B.name = "The Poky Little Puppy"
				J = "Veterinarian"
				deity_name = "Ian"
			if("adminism", "admintology", "admin", "admins", "adminhelp", "adminbus")
				B.name = "Breaking Through the Fourth Wall"
				J = "Trial Admin"
				deity_name = "The Adminbus"
			if("coding", "coder", "coders")
				B.name = "Guide to Github"
				J = "Coder"
				deity_name = "The Coderbus"
			if("42")
				B.name = "The Hitchhiker's Guide to the Galaxy"
				deity_name = "Arthur Dent" //Don't care
			if("spook", "spooky", "boo", "ghost")
				B.name = "The Spooky Spook" //SPOOK
				J = "Ghost"
				deity_name = "The Spook" //SPOOK
				H.equip_or_collect(new /obj/item/clothing/head/pumpkinhead(H), slot_head)
			if("medbay", "ride", "wild ride", "cryo")
				B.name = "The Wild Ride"
				if(H.gender == FEMALE)
					J = "Nurse"
				else
					J = "Doctor"
				//Give them basic medical garb
				H.equip_or_collect(new /obj/item/clothing/head/surgery/blue(H), slot_head)
				H.equip_or_collect(new /obj/item/clothing/mask/surgical(H), slot_wear_mask)
				deity_name = "The Chief Medical Officer"
			if("busta", "bustatime", "zas", "airflow", "hardcore", "hardcores")
				B.name = "The Hardcores"
				if(!(M_HARDCORE in H.mutations))
					H.mutations.Add(M_HARDCORE)
				J = "Atmospherics Technician"
				deity_name = "Bustatime"
			if("me", "i", "narcissism", "self importance", "selfishness")
				B.name = "The Teachings of [H]" //Quite literally
				J = "God"
				deity_name = "[H]" //Very literally, too
			if("alcohol", "booze", "beer", "wine", "ethanol", "c2h6o")
				B.name = "The Drunken Ramblings"
				J = "Drunkard"
				deity_name = "Hic"
			if("robust", "robustness", "strength")
				B.name = "The Rules of Robustness"
				J = "Robuster"
				deity_name = "The Robust"
			if("suicide", "death", "succumb")
				B.name = "The Sweet Release of Death"
				J = "Reaper"
				deity_name = "The Grim Reaper"
			if("communism", "socialism")
				B.name = "The Communist Manifesto"
				J = "Komrade"
				deity_name = "Karl Max"
				H.equip_or_collect(new /obj/item/clothing/head/ushanka(H), slot_head)
			if("capitalism", "free market", "liberalism")
				B.name = "The Free Market"
				J = "Stockholder"
				deity_name = "Adam Smith"
				H.equip_or_collect(new /obj/item/clothing/head/that(H), slot_head)
			if("freedom", "america", "muhrica", "usa")
				B.name = "The Constitution"
				J = "Senator"
				deity_name = "George Washington"
				H.equip_or_collect(new /obj/item/clothing/head/libertyhat(H), slot_head)
			if("fascism", "nazi", "national socialism")
				B.name = "Mein Kampf"
				J = "Feldbischof" //No seriously, that's a thing, look it up
				deity_name = "Adolf Hitler"
				H.equip_or_collect(new /obj/item/clothing/head/naziofficer(H), slot_head)
			if("security", "space law", "law", "nanotrasen", "centcomm")
				B.name = "Space Law"
				J = "Nanotrasen Officer"
				deity_name = "Nanotrasen"
				H.equip_or_collect(new /obj/item/clothing/head/centhat(H), slot_head)
			if("syndicate", "traitor", "syndie", "syndies")
				B.name = "The Syndicate Bundle"
				J = "Syndicate Agent"
				deity_name = "The Syndicate"
				H.equip_or_collect(new /obj/item/clothing/head/syndicatefake(H), slot_head)
			if("cult", "narsie", "nar'sie", "narnar")
				B.name = "The Arcane Tome"
				J = "Cultist"
				deity_name = "Nar'Sie"
			else //Boring, give them a stock name
				B.name = "The Holy Book of [new_religion]"

		//This goes down here due to problems with loading orders that took me 4 hours to identify
		var/obj/item/weapon/card/id/I = null
		if(istype(H.wear_id, /obj/item/weapon/card/id/)) //This prevents people from causing weirdness by putting other things into their slots before chosing their religion
			I = H.wear_id
			if(I.registered_name == H.real_name) //Makes sure the ID is the chaplain's own
				I.assignment = J
				I.name = text("[I.registered_name]'s ID Card ([I.assignment])")
		var/obj/item/device/pda/P = null
		if(istype(H.belt, /obj/item/device/pda)) //This prevents people from causing weirdness by putting other things into their slots before chosing their religion
			P = H.belt
			if(P.owner == H.real_name) //Makes sure the PDA is the chaplain's own
				P.ownjob = J
				P.name = text("PDA-[P.owner] ([P.ownjob])")
		data_core.manifest_modify(H.real_name, J) //Updates manifest
		feedback_set_details("religion_name","[new_religion]")

		//Allow them to change their deity if they believe the deity we gave them sucks
		var/new_deity = copytext(sanitize(input(H, "Would you like to change your deity? Your deity currently is [deity_name] (Leave empty or unchanged to keep diety name)", "Name of Deity", deity_name)), 1, MAX_NAME_LEN)

		if(!length(new_deity))
			new_deity = deity_name //Just give them what was picked for them already
		B.deity_name = new_deity

		var/accepted = 0
		var/outoftime = 0
		spawn(200) //20 seconds to choose
			outoftime = 1
		var/new_book_style = "Bible"

		while(!accepted)
			if(!B)
				break //Prevents possible runtime errors
			new_book_style = input(H, "Which bible style would you like?") in list("Bible", "Koran", "Scrapbook", "Creeper", "White Bible", "Holy Light", "Athiest", "Tome", "The King in Yellow", "Ithaqua", "Scientology", \
																				   "the bible melts", "Unaussprechlichen Kulten", "Necronomicon", "Book of Shadows", "Torah", "Burning", "Honk", "Ianism", "The Guide")
			switch(new_book_style)
				if("Koran")
					B.icon_state = "koran"
					B.item_state = "koran"
					for(var/area/chapel/main/A in areas)
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
					for(var/area/chapel/main/A in areas)
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
					for(var/area/chapel/main/A in areas)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 5
				if("Scientology")
					B.icon_state = "scientology"
					B.item_state = "scientology"
					for(var/area/chapel/main/A in areas)
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
					for(var/area/chapel/main/A in areas)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 6
				if("Torah")
					B.icon_state = "torah"
					B.item_state = "torah"
					for(var/area/chapel/main/A in areas)
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
					for(var/area/chapel/main/A in areas)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 9
				if("The Guide")
					B.icon_state = "guide"
					B.item_state = "guide"
				else
					//If christian bible, revert to default
					B.icon_state = "bible"
					B.item_state = "bible"
					for(var/area/chapel/main/A in areas)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 2

			H.update_inv_l_hand() //So that it updates the bible's item_state in his hand

			switch(input(H, "Look at your bible - is this what you want?") in list("Yes", "No"))
				if("Yes")
					accepted = 1
				if("No")
					if(outoftime)
						to_chat(H, "<span class='warning'>Welp, out of time, buddy. You're stuck with that one. Next time choose faster.</span>")
						accepted = 1

		if(ticker)
			ticker.Bible_icon_state = B.icon_state
			ticker.Bible_item_state = B.item_state
			ticker.Bible_name = B.name
			ticker.Bible_deity_name = B.deity_name
		feedback_set_details("religion_deity","[new_deity]")
		feedback_set_details("religion_book","[new_book_style]")
	return 1
