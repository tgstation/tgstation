///////////////////////////////////////////////////////////////////////////////////
datum
	chemical_reaction
		var/name = null
		var/id = null
		var/result = null
		var/list/required_reagents = new/list()
		var/result_amount = 0

		proc
			on_reaction(var/datum/reagents/holder, var/created_volume)
				return

		//I recommend you set the result amount to the total volume of all components.

		bilk
			name = "Bilk"
			id = "bilk"
			result = "bilk"
			required_reagents = list("milk" = 1, "beer" = 1)
			result_amount = 2

		explosion_potassium
			name = "Explosion"
			id = "explosion_potassium"
			result = null
			required_reagents = list("water" = 1, "potassium" = 1)
			result_amount = 2
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				var/datum/effects/system/reagents_explosion/e = new()
				e.set_up(round (created_volume/10, 1), location, 0, 0)
				e.start()

				holder.clear_reagents()
				return

		silicate
			name = "Silicate"
			id = "silicate"
			result = "silicate"
			required_reagents = list("aluminium" = 1, "silicon" = 1, "oxygen" = 1)
			result_amount = 3

		mutagen
			name = "Unstable mutagen"
			id = "mutagen"
			result = "mutagen"
			required_reagents = list("radium" = 1, "phosphorus" = 1, "chlorine" = 1)
			result_amount = 3

		//cyanide
		//	name = "Cyanide"
		//	id = "cyanide"
		//	result = "cyanide"
		//	required_reagents = list("hydrogen" = 1, "carbon" = 1, "nitrogen" = 1)
		//	result_amount = 3

		thermite
			name = "Thermite"
			id = "thermite"
			result = "thermite"
			required_reagents = list("aluminium" = 1, "iron" = 1, "oxygen" = 1)
			result_amount = 3

		lexorin
			name = "Lexorin"
			id = "lexorin"
			result = "lexorin"
			required_reagents = list("plasma" = 1, "hydrogen" = 1, "nitrogen" = 1)
			result_amount = 3

		space_drugs
			name = "Space Drugs"
			id = "space_drugs"
			result = "space_drugs"
			required_reagents = list("mercury" = 1, "sugar" = 1, "lithium" = 1)
			result_amount = 3

		lube
			name = "Space Lube"
			id = "lube"
			result = "lube"
			required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)
			result_amount = 4

		pacid
			name = "Polytrinic acid"
			id = "pacid"
			result = "pacid"
			required_reagents = list("acid" = 1, "chlorine" = 1, "potassium" = 1)
			result_amount = 3

		synaptizine
			name = "Synaptizine"
			id = "synaptizine"
			result = "synaptizine"
			required_reagents = list("sugar" = 1, "lithium" = 1, "water" = 1)
			result_amount = 3

		hyronalin
			name = "Hyronalin"
			id = "hyronalin"
			result = "hyronalin"
			required_reagents = list("radium" = 1, "anti_toxin" = 1)
			result_amount = 2

		arithrazine
			name = "Arithrazine"
			id = "arithrazine"
			result = "arithrazine"
			required_reagents = list("hyronalin" = 1, "hydrogen" = 1)
			result_amount = 2

		impedrezene
			name = "Impedrezene"
			id = "impedrezene"
			result = "impedrezene"
			required_reagents = list("mercury" = 1, "oxygen" = 1, "sugar" = 1)
			result_amount = 2

		kelotane
			name = "Kelotane"
			id = "kelotane"
			result = "kelotane"
			required_reagents = list("silicon" = 1, "carbon" = 1)
			result_amount = 2

		leporazine
			name = "Leporazine"
			id = "leporazine"
			result = "leporazine"
			required_reagents = list("silicon" = 1, "plasma" = 1, )
			result_amount = 2

		cryptobiolin
			name = "Cryptobiolin"
			id = "cryptobiolin"
			result = "cryptobiolin"
			required_reagents = list("potassium" = 1, "oxygen" = 1, "sugar" = 1)
			result_amount = 3

		tricordrazine
			name = "Tricordrazine"
			id = "tricordrazine"
			result = "tricordrazine"
			required_reagents = list("inaprovaline" = 1, "anti_toxin" = 1)
			result_amount = 2

		alkysine
			name = "Alkysine"
			id = "alkysine"
			result = "alkysine"
			required_reagents = list("chlorine" = 1, "nitrogen" = 1, "anti_toxin" = 1)
			result_amount = 2

		dexalin
			name = "Dexalin"
			id = "dexalin"
			result = "dexalin"
			required_reagents = list("plasma" = 1, "oxygen" = 1)
			result_amount = 2

		dexalinp
			name = "Dexalin Plus"
			id = "dexalinp"
			result = "dexalinp"
			required_reagents = list("dexalin" = 1, "carbon" = 1, "iron" = 1)
			result_amount = 3

		bicaridine
			name = "Bicaridine"
			id = "bicaridine"
			result = "bicaridine"
			required_reagents = list("inaprovaline" = 1, "carbon" = 1)
			result_amount = 2

		hyperzine
			name = "Hyperzine"
			id = "hyperzine"
			result = "hyperzine"
			required_reagents = list("sugar" = 1, "phosphorus" = 1, "sulfur" = 1,)
			result_amount = 3

		ryetalyn
			name = "Ryetalyn"
			id = "ryetalyn"
			result = "ryetalyn"
			required_reagents = list("arithrazine" = 1, "carbon" = 1)
			result_amount = 2

		cryoxadone
			name = "Cryoxadone"
			id = "cryoxadone"
			result = "cryoxadone"
			required_reagents = list("dexalin" = 1, "water" = 1, "oxygen" = 1)
			result_amount = 10

		spaceacillin
			name = "Spaceacillin"
			id = "spaceacillin"
			result = "spaceacillin"
			required_reagents = list("cryptobiolin" = 1, "inaprovaline" = 1)
			result_amount = 2

		imidazoline
			name = "imidazoline"
			id = "imidazoline"
			result = "imidazoline"
			required_reagents = list("carbon" = 1, "hydrogen" = 1, "anti_toxin" = 1)
			result_amount = 2

		ethylredoxrazine
			name = "Ethylredoxrazine"
			id = "ethylredoxrazine"
			result = "ethylredoxrazine"
			required_reagents = list("oxygen" = 1, "anti_toxin" = 1, "carbon" = 1)
			result_amount = 3

		ethanoloxidation
			name = "ethanoloxidation"	//Kind of a placeholder in case someone ever changes it so that chemicals
			id = "ethanoloxidation"		//	react in the body. Also it would be silly if it didn't exist.
			result = "water"
			required_reagents = list("ethylredoxrazine" = 1, "ethanol" = 1)
			result_amount = 2

		glycerol
			name = "Glycerol"
			id = "glycerol"
			result = "glycerol"
			required_reagents = list("cornoil" = 3, "acid" = 1)
			result_amount = 1

		nitroglycerin
			name = "Nitroglycerin"
			id = "nitroglycerin"
			result = "nitroglycerin"
			required_reagents = list("glycerol" = 1, "pacid" = 1, "acid" = 1)
			result_amount = 2
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				var/datum/effects/system/reagents_explosion/e = new()
				e.set_up(round (created_volume/2, 1), location, 0, 0)
				e.start()

				holder.clear_reagents()
				return

		sodiumchloride
			name = "Sodium Chloride"
			id = "sodiumchloride"
			result = "sodiumchloride"
			required_reagents = list("sodium" = 1, "chlorine" = 1)
			result_amount = 2

		flash_powder
			name = "Flash powder"
			id = "flash_powder"
			result = null
			required_reagents = list("aluminium" = 1, "potassium" = 1, "sulfur" = 1 )
			result_amount = null
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
				s.set_up(2, 1, location)
				s.start()
				for(var/mob/living/carbon/M in viewers(world.view, location))
					switch(get_dist(M, location))
						if(0 to 3)
							if(hasvar(M, "glasses"))
								if(istype(M:glasses, /obj/item/clothing/glasses/sunglasses))
									continue

							flick("e_flash", M.flash)
							M.weakened = 15

						if(4 to 5)
							if(hasvar(M, "glasses"))
								if(istype(M:glasses, /obj/item/clothing/glasses/sunglasses))
									continue

							flick("e_flash", M.flash)
							M.stunned = 5

		napalm
			name = "Napalm"
			id = "napalm"
			result = "napalm"
			required_reagents = list("aluminium" = 1, "plasma" = 1, "acid" = 1 )
			result_amount = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom.loc)
				for(var/turf/simulated/floor/target_tile in range(1,location))
					if(target_tile.parent && target_tile.parent.group_processing)
						target_tile.parent.suspend_group_processing()

					var/datum/gas_mixture/napalm = new

					napalm.toxins = 2 * created_volume

					target_tile.assume_air(napalm)
					spawn (0) target_tile.hotspot_expose(700, 400)
				holder.del_reagent("napalm")
				return

		smoke
			name = "Smoke"
			id = "smoke"
			result = null
			required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1 )
			result_amount = null
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				var/datum/effects/system/bad_smoke_spread/S = new /datum/effects/system/bad_smoke_spread
				S.attach(location)
				S.set_up(10, 0, location)
				playsound(location, 'smoke.ogg', 50, 1, -3)
				spawn(0)
					S.start()
					sleep(10)
					S.start()
					sleep(10)
					S.start()
					sleep(10)
					S.start()
					sleep(10)
					S.start()
				return

		chloralhydrate
			name = "Chloral Hydrate"
			id = "chloralhydrate"
			result = "chloralhydrate"
			required_reagents = list("ethanol" = 1, "chlorine" = 3, "water" = 1)
			result_amount = 1

///////////////////////////////////////////////////////////////////////////////////

// foam and foam precursor

		surfactant
			name = "Foam surfactant"
			id = "foam surfactant"
			result = "fluorosurfactant"
			required_reagents = list("fluorine" = 2, "carbon" = 2, "acid" = 1)
			result_amount = 5


		foam
			name = "Foam"
			id = "foam"
			result = null
			required_reagents = list("fluorosurfactant" = 1, "water" = 1)
			result_amount = 2

			on_reaction(var/datum/reagents/holder, var/created_volume)


				var/location = get_turf(holder.my_atom)
				for(var/mob/M in viewers(5, location))
					M << "\red The solution violently bubbles!"

				location = get_turf(holder.my_atom)

				for(var/mob/M in viewers(5, location))
					M << "\red The solution spews out foam!"

				//world << "Holder volume is [holder.total_volume]"
				//for(var/datum/reagent/R in holder.reagent_list)
				//	world << "[R.name] = [R.volume]"

				var/datum/effects/system/foam_spread/s = new()
				s.set_up(created_volume, location, holder, 0)
				s.start()
				holder.clear_reagents()
				return


		metalfoam
			name = "Metal Foam"
			id = "metalfoam"
			result = null
			required_reagents = list("aluminium" = 3, "foaming_agent" = 1, "pacid" = 1)
			result_amount = 5

			on_reaction(var/datum/reagents/holder, var/created_volume)


				var/location = get_turf(holder.my_atom)

				for(var/mob/M in viewers(5, location))
					M << "\red The solution spews out a metalic foam!"

				var/datum/effects/system/foam_spread/s = new()
				s.set_up(created_volume/2, location, holder, 1)
				s.start()
				return

		ironfoam
			name = "Iron Foam"
			id = "ironlfoam"
			result = null
			required_reagents = list("iron" = 3, "foaming_agent" = 1, "pacid" = 1)
			result_amount = 5

			on_reaction(var/datum/reagents/holder, var/created_volume)


				var/location = get_turf(holder.my_atom)

				for(var/mob/M in viewers(5, location))
					M << "\red The solution spews out a metalic foam!"

				var/datum/effects/system/foam_spread/s = new()
				s.set_up(created_volume/2, location, holder, 2)
				s.start()
				return



		foaming_agent
			name = "Foaming Agent"
			id = "foaming_agent"
			result = "foaming_agent"
			required_reagents = list("lithium" = 1, "hydrogen" = 1)
			result_amount = 1

		// Synthesizing these three chemicals is pretty complex in real life, but fuck it, it's just a game!
		ammonia
			name = "Ammonia"
			id = "ammonia"
			result = "ammonia"
			required_reagents = list("hydrogen" = 3, "nitrogen" = 1)
			result_amount = 3

		space_cleaner
			name = "Space cleaner"
			id = "cleaner"
			result = "cleaner"
			required_reagents = list("ammonia" = 1, "water" = 1)
			result_amount = 1

		plantbgone
			name = "Plant-B-Gone"
			id = "plantbgone"
			result = "plantbgone"
			required_reagents = list("toxin" = 1, "water" = 4)
			result_amount = 5


//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

		tofu
			name = "Tofu"
			id = "tofu"
			result = null
			required_reagents = list("soymilk" = 10, "enzyme" = 2)
			result_amount = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				for(var/i = 1, i <= created_volume, i++)
					new /obj/item/weapon/reagent_containers/food/snacks/tofu(location)
				return

		soysauce
			name = "Soy Sauce"
			id = "soysauce"
			result = "soysauce"
			required_reagents = list("soymilk" = 1, "acid" = 1)
			result_amount = 2

		cheesewheel
			name = "Cheesewheel"
			id = "cheesewheel"
			result = null
			required_reagents = list("milk" = 40, "enzyme" = 2)
			result_amount = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				new /obj/item/weapon/reagent_containers/food/snacks/cheesewheel(location)
				return

////////////////////////////////////////// COCKTAILS //////////////////////////////////////

		moonshine
			name = "Moonshine"
			id = "moonshine"
			result = "moonshine"
			required_reagents = list("nutriment" = 10, "enzyme" = 2)
			result_amount = 5

		wine
			name = "Wine"
			id = "wine"
			result = "wine"
			required_reagents = list("berryjuice" = 10, "enzyme" = 2)
			result_amount = 5

		gin_tonic
			name = "Gin and Tonic"
			id = "gintonic"
			result = "gintonic"
			required_reagents = list("gin" = 2, "tonic" = 1)
			result_amount = 5


		cuba_libre
			name = "Cuba Libre"
			id = "cubalibre"
			result = "cubalibre"
			required_reagents = list("rum" = 2, "cola" = 1)
			result_amount = 5

		martini
			name = "Classic Martini"
			id = "martini"
			result = "martini"
			required_reagents = list("gin" = 2, "vermouth" = 1)
			result_amount = 5

		vodkamartini
			name = "Vodka Martini"
			id = "vodkamartini"
			result = "vodkamartini"
			required_reagents = list("vodka" = 2, "vermouth" = 1)
			result_amount = 5


		white_russian
			name = "White Russian"
			id = "whiterussian"
			result = "whiterussian"
			required_reagents = list("vodka" = 3, "cream" = 1, "kahlua" = 1)
			result_amount = 5

		whiskey_cola
			name = "Whiskey Cola"
			id = "whiskeycola"
			result = "whiskeycola"
			required_reagents = list("whiskey" = 2, "cola" = 1)
			result_amount = 5

		screwdriver
			name = "Screwdriver"
			id = "screwdrivercocktail"
			result = "screwdrivercocktail"
			required_reagents = list("vodka" = 2, "orangejuice" = 1)
			result_amount = 5

		bloody_mary
			name = "Bloody Mary"
			id = "bloodymary"
			result = "bloodymary"
			required_reagents = list("vodka" = 1, "tomatojuice" = 2, "limejuice" = 1)
			result_amount = 5

		gargle_blaster
			name = "Pan-Galactic Gargle Blaster"
			id = "gargleblaster"
			result = "gargleblaster"
			required_reagents = list("vodka" = 1, "gin" = 1, "whiskey" = 1, "cognac" = 1, "limejuice" = 1)
			result_amount = 5

		brave_bull
			name = "Brave Bull"
			id = "bravebull"
			result = "bravebull"
			required_reagents = list("tequilla" = 2, "kahlua" = 1)
			result_amount = 5

		tequilla_sunrise
			name = "Tequilla Sunrise"
			id = "tequillasunrise"
			result = "tequillasunrise"
			required_reagents = list("tequilla" = 2, "orangejuice" = 1)
			result_amount = 5

		toxins_special
			name = "Toxins Special"
			id = "toxinsspecial"
			result = "toxinsspecial"
			required_reagents = list("rum" = 2, "vermouth" = 1, "plasma" = 2)
			result_amount = 5

		beepsky_smash
			name = "Beepksy Smash"
			id = "beepksysmash"
			result = "beepskysmash"
			required_reagents = list("limejuice" = 2, "whiskey" = 2, "iron" = 1)
			result_amount = 5

		doctor_delight
			name = "The Doctor's Delight"
			id = "doctordelight"
			result = "doctorsdelight"
			required_reagents = list("limejuice" = 1, "tomatojuice" = 1, "orangejuice" = 1, "cream" = 1)
			result_amount = 5

		irish_cream
			name = "Irish Cream"
			id = "irishcream"
			result = "irishcream"
			required_reagents = list("whiskey" = 2, "cream" = 1)
			result_amount = 5

		manly_dorf
			name = "The Manly Dorf"
			id = "manlydorf"
			result = "manlydorf"
			required_reagents = list ("beer" = 1, "ale" = 2)
			result_amount = 5

		hooch
			name = "Hooch"
			id = "hooch"
			result = "hooch"
			required_reagents = list ("sugar" = 1, "ethanol" = 2, "fuel" = 1)
			result_amount = 5

		irish_coffee
			name = "Irish Coffee"
			id = "irishcoffee"
			result = "irishcoffee"
			required_reagents = list("irishcream" = 2, "coffee" = 2)
			result_amount = 5

		b52
			name = "B-52"
			id = "b52"
			result = "b52"
			required_reagents = list("irishcream" = 1, "kahlua" = 1, "cognac" = 1)
			result_amount = 5

		margarita
			name = "Margarita"
			id = "margarita"
			result = "margarita"
			required_reagents = list("tequilla" = 2, "limejuice" = 1)
			result_amount = 5

		longislandicedtea
			name = "Long Island Iced Tea"
			id = "longislandicedtea"
			result = "longislandicedtea"
			required_reagents = list("vodka" = 1, "gin" = 1, "tequilla" = 1, "cubalibre" = 1)
			result_amount = 5

		whiskeysoda
			name = "Whiskey Soda"
			id = "whiskeysoda"
			result = "whiskeysoda"
			required_reagents = list("whiskey" = 2, "sodawater" = 1)
			result_amount = 5

		black_russian
			name = "Black Russian"
			id = "blackrussian"
			result = "blackrussian"
			required_reagents = list("vodka" = 3, "kahlua" = 2)
			result_amount = 5

		manhattan
			name = "Manhattan"
			id = "manhattan"
			result = "manhattan"
			required_reagents = list("whiskey" = 2, "vermouth" = 1)
			result_amount = 5

		vodka_tonic
			name = "Vodka and Tonic"
			id = "vodkatonic"
			result = "vodkatonic"
			required_reagents = list("vodka" = 2, "tonic" = 1)
			result_amount = 5

		gin_fizz
			name = "Gin Fizz"
			id = "ginfizz"
			result = "ginfizz"
			required_reagents = list("gin" = 2, "sodawater" = 1, "limejuice" = 1)
			result_amount = 5