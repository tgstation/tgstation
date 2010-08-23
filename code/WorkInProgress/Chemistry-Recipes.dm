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
			result_amount = null
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
				s.set_up(2, 1, location)
				s.start()
				for(var/mob/M in viewers(5, location))
					M << "\red The solution violently explodes."
				for(var/mob/M in viewers(1, location))
					M << "\red The explosion knocks you down."
					M:weakened += 3
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
			name = "spaceacillin"
			id = "spaceacillin"
			result = "spaceacillin"
			required_reagents = list("cryptobiolin" = 1, "inaprovaline" = 1)
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
			result = null
			required_reagents = list("aluminium" = 1, "plasma" = 1, "acid" = 1 )
			result_amount = null
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				for(var/turf/simulated/floor/target_tile in range(1,location))
					if(target_tile.parent && target_tile.parent.group_processing)
						target_tile.parent.suspend_group_processing()

					var/datum/gas_mixture/napalm = new
					var/datum/gas/volatile_fuel/fuel = new

					fuel.moles = 15
					napalm.trace_gases += fuel

					target_tile.assume_air(napalm)

					spawn (0) target_tile.hotspot_expose(700, 400)

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