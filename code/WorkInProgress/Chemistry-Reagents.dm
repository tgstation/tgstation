#define SOLID 1
#define LIQUID 2
#define GAS 3

//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.

datum
	reagent
		var/name = "Reagent"
		var/id = "reagent"
		var/description = ""
		var/datum/reagents/holder = null
		var/reagent_state = SOLID
		var/data = null
		var/volume = 0
		var/nutriment_factor = 0
		//var/list/viruses = list()

		proc
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume) //By default we have a chance to transfer some
				var/datum/reagent/self = src
				src = null										  //of the reagent to the mob on TOUCHING it.
				if(method == TOUCH)

					var/chance = 1
					for(var/obj/item/clothing/C in M.get_equipped_items())
						if(C.permeability_coefficient < chance) chance = C.permeability_coefficient
					chance = chance * 100

					if(prob(chance))
						if(M.reagents)
							M.reagents.add_reagent(self.id,self.volume/2)
				return

			reaction_obj(var/obj/O, var/volume) //By default we transfer a small part of the reagent to the object
				src = null						//if it can hold reagents. nope!
				//if(O.reagents)
				//	O.reagents.add_reagent(id,volume/3)
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				return

			on_mob_life(var/mob/living/M as mob)
				holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
				return

			on_move(var/mob/M)
				return

			on_update(var/atom/A)
				return

		metroid
			name = "Metroid Jam"
			id = "metroid"
			description = "A green semi-liquid produced from one of the deadliest lifeforms in existence."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(prob(10))
					M << "You don't feel too good."
					M.toxloss+=20
				else if(prob(40))
					M:heal_organ_damage(5,0)
				..()
				return


		blood
			data = new/list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null)
			name = "Blood"
			id = "blood"
			reagent_state = LIQUID

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				var/datum/reagent/blood/self = src
				src = null
				for(var/datum/disease/D in self.data["viruses"])
					var/datum/disease/virus = new D.type
					if(method == TOUCH)
						M.contract_disease(virus)

					else //injected
						M.contract_disease(virus, 1, 0)
				/*
				if(self.data["virus"])
					var/datum/disease/V = self.data["virus"]
					if(M.resistances.Find(V.type)) return
					if(method == TOUCH)//respect all protective clothing...
						M.contract_disease(V)
					else //injected
						M.contract_disease(V, 1, 0)
				return
				*/


			reaction_turf(var/turf/simulated/T, var/volume)//splash the blood all over the place
				if(!istype(T)) return
				var/datum/reagent/blood/self = src
				src = null
				//var/datum/disease/D = self.data["virus"]
				if(!self.data["donor"] || istype(self.data["donor"], /mob/living/carbon/human))
					var/obj/decal/cleanable/blood/blood_prop = locate() in T //find some blood here
					if(!blood_prop) //first blood!
						blood_prop = new(T)
						blood_prop.blood_DNA = self.data["blood_DNA"]
						blood_prop.blood_type = self.data["blood_type"]

					for(var/datum/disease/D in self.data["viruses"])
						var/datum/disease/newVirus = new D.type
						blood_prop.viruses += newVirus
						newVirus.holder = blood_prop

						// this makes it almost impossible for airborne diseases to spread
						// THIS SHIT HAS TO GO, SORRY!
						/*
						if(T.density==0)
							newVirus.spread_type = CONTACT_FEET
						else
							newVirus.spread_type = CONTACT_HANDS
						*/

				else if(istype(self.data["donor"], /mob/living/carbon/monkey))
					var/obj/decal/cleanable/blood/blood_prop = locate() in T
					if(!blood_prop)
						blood_prop = new(T)
						blood_prop.blood_DNA = self.data["blood_DNA"]
					for(var/datum/disease/D in self.data["viruses"])
						var/datum/disease/newVirus = new D.type
						blood_prop.viruses += newVirus
						newVirus.holder = blood_prop

						/*
						if(T.density==0)
							newVirus.spread_type = CONTACT_FEET
						else
							newVirus.spread_type = CONTACT_HANDS
						*/

				else if(istype(self.data["donor"], /mob/living/carbon/alien))
					var/obj/decal/cleanable/xenoblood/blood_prop = locate() in T
					if(!blood_prop)
						blood_prop = new(T)
						blood_prop.blood_DNA = self.data["blood_DNA"]
					for(var/datum/disease/D in self.data["viruses"])
						var/datum/disease/newVirus = new D.type
						blood_prop.viruses += newVirus
						newVirus.holder = blood_prop
						/*
						if(T.density==0)
							newVirus.spread_type = CONTACT_FEET
						else
							newVirus.spread_type = CONTACT_HANDS
						*/
				return

/* Must check the transfering of reagents and their data first. They all can point to one disease datum.

			Del()
				if(src.data["virus"])
					var/datum/disease/D = src.data["virus"]
					D.cure(0)
				..()
*/
		vaccine
			//data must contain virus type
			name = "Vaccine"
			id = "vaccine"
			reagent_state = LIQUID

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				var/datum/reagent/vaccine/self = src
				src = null
				if(self.data&&method == INGEST)
					for(var/datum/disease/D in M.viruses)
						if(D.type == self.data)
							D.cure()

					M.resistances += self.data
				return


		water
			name = "Water"
			id = "water"
			description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
			reagent_state = LIQUID

			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return
				src = null
				if(volume >= 3)
					if(T.wet >= 1) return
					T.wet = 1
					if(T.wet_overlay)
						T.overlays -= T.wet_overlay
						T.wet_overlay = null
					T.wet_overlay = image('water.dmi',T,"wet_floor")
					T.overlays += T.wet_overlay

					spawn(800)
						if (!istype(T)) return
						if(T.wet >= 2) return
						T.wet = 0
						if(T.wet_overlay)
							T.overlays -= T.wet_overlay
							T.wet_overlay = null

				for(var/mob/living/carbon/metroid/M in T)
					M.toxloss+=rand(5,10)

				var/hotspot = (locate(/obj/hotspot) in T)
				if(hotspot && !istype(T, /turf/space))
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					del(hotspot)
				return
			reaction_obj(var/obj/O, var/volume)
				src = null
				var/turf/T = get_turf(O)
				var/hotspot = (locate(/obj/hotspot) in T)
				if(hotspot && !istype(T, /turf/space))
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					del(hotspot)
				if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/monkeycube))
					var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
					if(!cube.wrapped)
						cube.Expand()
				return

		lube
			name = "Space Lube"
			id = "lube"
			description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
			reagent_state = LIQUID

			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return
				src = null
				if(T.wet >= 2) return
				T.wet = 2
				spawn(800)
					if (!istype(T)) return
					T.wet = 0
					if(T.wet_overlay)
						T.overlays -= T.wet_overlay
						T.wet_overlay = null
					return

		anti_toxin
			name = "Anti-Toxin (Dylovene)"
			id = "anti_toxin"
			description = "Dylovene is a broad-spectrum antitoxin."
			reagent_state = LIQUID

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:drowsyness = max(M:drowsyness-2, 0)
				if(holder.has_reagent("toxin"))
					holder.remove_reagent("toxin", 2)
				if(holder.has_reagent("stoxin"))
					holder.remove_reagent("stoxin", 2)
				if(holder.has_reagent("plasma"))
					holder.remove_reagent("plasma", 1)
				if(holder.has_reagent("acid"))
					holder.remove_reagent("acid", 1)
				if(holder.has_reagent("cyanide"))
					holder.remove_reagent("cyanide", 1)
				if(holder.has_reagent("amatoxin"))
					holder.remove_reagent("amatoxin", 2)
				if(holder.has_reagent("chloralhydrate"))
					holder.remove_reagent("chloralhydrate", 5)
				if(holder.has_reagent("carpotoxin"))
					holder.remove_reagent("carpotoxin", 1)
				if(holder.has_reagent("zombiepowder"))
					holder.remove_reagent("zombiepowder", 0.5)
				M:toxloss = max(M:toxloss-2,0)
				..()
				return

		toxin
			name = "Toxin"
			id = "toxin"
			description = "A Toxic chemical."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:toxloss += 1.5
				..()
				return

		cyanide
			name = "Cyanide"
			id = "cyanide"
			description = "A highly toxic chemical."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:toxloss += 3
				M:oxyloss += 3
				M:sleeping += 1
				..()
				return

		stoxin
			name = "Sleep Toxin"
			id = "stoxin"
			description = "An effective hypnotic used to treat insomnia."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(data)
					if(1 to 15)
						M.eye_blurry = max(M.eye_blurry, 10)
					if(15 to 25)
						M:drowsyness  = max(M:drowsyness, 20)
					if(25 to INFINITY)
						M:paralysis = max(M:paralysis, 20)
						M:drowsyness  = max(M:drowsyness, 30)
				data++
				..()
				return

		srejuvinate
			name = "Sleep Rejuvinate"
			id = "stoxin"
			description = "Put people to sleep, and heals them."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				data++
				if(M.losebreath >= 10)
					M.losebreath = max(10, M.losebreath-10)
				holder.remove_reagent(src.id, 0.2)
				switch(data)
					if(1 to 15)
						M.eye_blurry = max(M.eye_blurry, 10)
					if(15 to 25)
						M:drowsyness  = max(M:drowsyness, 20)
					if(25 to INFINITY)
						M:sleeping = 1
						M:oxyloss = 0
						M:weakened = 0
						M:stunned = 0
						M:paralysis = 0
						M.dizziness = 0
						M:drowsyness = 0
						M:stuttering = 0
						M:confused = 0
						M:jitteriness = 0
				..()
				return

		inaprovaline
			name = "Inaprovaline"
			id = "inaprovaline"
			description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
			reagent_state = LIQUID

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.losebreath >= 10)
					M.losebreath = max(10, M.losebreath-5)
				holder.remove_reagent(src.id, 0.2)
				return

		space_drugs
			name = "Space drugs"
			id = "space_drugs"
			description = "An illegal chemical compound used as drug."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				if(M.canmove) step(M, pick(cardinal))
				if(prob(7)) M:emote(pick("twitch","drool","moan","giggle"))
				holder.remove_reagent(src.id, 0.2)
				return

		silicate
			name = "Silicate"
			id = "silicate"
			description = "A compound that can be used to reinforce glass."
			reagent_state = LIQUID
			reaction_obj(var/obj/O, var/volume)
				src = null
				if(istype(O,/obj/window))
					O:health = O:health * 2
					var/icon/I = icon(O.icon,O.icon_state,O.dir)
					I.SetIntensity(1.15,1.50,1.75)
					O.icon = I
				return

		oxygen
			name = "Oxygen"
			id = "oxygen"
			description = "A colorless, odorless gas."
			reagent_state = GAS

		copper
			name = "Copper"
			id = "copper"
			description = "A highly ductile metal."

		nitrogen
			name = "Nitrogen"
			id = "nitrogen"
			description = "A colorless, odorless, tasteless gas."
			reagent_state = GAS

		hydrogen
			name = "Hydrogen"
			id = "hydrogen"
			description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
			reagent_state = GAS

		potassium
			name = "Potassium"
			id = "potassium"
			description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
			reagent_state = SOLID

		mercury
			name = "Mercury"
			id = "mercury"
			description = "A chemical element."
			reagent_state = LIQUID

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.canmove) step(M, pick(cardinal))
				if(prob(5)) M:emote(pick("twitch","drool","moan"))
				..()
				return

		sulfur
			name = "Sulfur"
			id = "sulfur"
			description = "A chemical element."
			reagent_state = SOLID

		carbon
			name = "Carbon"
			id = "carbon"
			description = "A chemical element."
			reagent_state = SOLID

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(!istype(T, /turf/space))
					new /obj/decal/cleanable/dirt(T)

		chlorine
			name = "Chlorine"
			id = "chlorine"
			description = "A chemical element."
			reagent_state = GAS
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.take_organ_damage(1, 0)
				..()
				return

		fluorine
			name = "Fluorine"
			id = "fluorine"
			description = "A highly-reactive chemical element."
			reagent_state = GAS
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:toxloss++
				..()
				return

		sodium
			name = "Sodium"
			id = "sodium"
			description = "A chemical element."
			reagent_state = SOLID

		phosphorus
			name = "Phosphorus"
			id = "phosphorus"
			description = "A chemical element."
			reagent_state = SOLID

		lithium
			name = "Lithium"
			id = "lithium"
			description = "A chemical element."
			reagent_state = SOLID

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.canmove) step(M, pick(cardinal))
				if(prob(5)) M:emote(pick("twitch","drool","moan"))
				..()
				return

		sugar
			name = "Sugar"
			id = "sugar"
			description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
			reagent_state = SOLID
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += 1
				..()
				return

		acid
			name = "Sulphuric acid"
			id = "acid"
			description = "A strong mineral acid with the molecular formula H2SO4."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:toxloss++
				M.take_organ_damage(0, 1)
				..()
				return
			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if(method == TOUCH)
					if(istype(M, /mob/living/carbon/human))
						if(M:wear_mask)
							del (M:wear_mask)
							M << "\red Your mask melts away but protects you from the acid!"
							return
						if(M:head)
							del (M:head)
							M << "\red Your helmet melts into uselessness but protects you from the acid!"
							return
					if(istype(M, /mob/living/carbon/monkey))
						if(M:wear_mask)
							del (M:wear_mask)
							M << "\red Your mask melts away but protects you from the acid!"
							return

					if(prob(75) && istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:organs["head"]
						if(affecting)
							affecting.take_damage(25, 0)
							M:UpdateDamage()
							M:UpdateDamageIcon()
							M:emote("scream")
							M << "\red Your face has become disfigured!"
							M.real_name = "Unknown"
					else
						M.take_organ_damage(15)
				else
					M.take_organ_damage(15)

			reaction_obj(var/obj/O, var/volume)
				if((istype(O,/obj/item) || istype(O,/obj/glowshroom)) && prob(40))
					var/obj/decal/cleanable/molten_item/I = new/obj/decal/cleanable/molten_item(O.loc)
					I.desc = "Looks like this was \an [O] some time ago."
					for(var/mob/M in viewers(5, O))
						M << "\red \the [O] melts."
					del(O)

		pacid
			name = "Polytrinic acid"
			id = "pacid"
			description = "Polytrinic acid is a an extremely corrosive chemical substance."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:toxloss++
				M.take_organ_damage(0, 1)
				..()
				return
			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if(method == TOUCH)
					if(istype(M, /mob/living/carbon/human))
						if(M:wear_mask)
							del (M:wear_mask)
							M << "\red Your mask melts away!"
							return
						if(M:head)
							del (M:head)
							M << "\red Your helmet melts into uselessness!"
							return
						var/datum/organ/external/affecting = M:organs["head"]
						affecting.take_damage(75, 0)
						M:UpdateDamage()
						M:UpdateDamageIcon()
						M:emote("scream")
						M << "\red Your face has become disfigured!"
						M.real_name = "Unknown"
					else
						if(istype(M, /mob/living/carbon/monkey) && M:wear_mask)
							del (M:wear_mask)
							M << "\red Your mask melts away but protects you from the acid!"
							return
						M.take_organ_damage(15)
				else
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:organs["head"]
						affecting.take_damage(75, 0)
						M:UpdateDamage()
						M:UpdateDamageIcon()
						M:emote("scream")
						M << "\red Your face has become disfigured!"
						M.real_name = "Unknown"
					else
						M.take_organ_damage(15)

			reaction_obj(var/obj/O, var/volume)
				if((istype(O,/obj/item) || istype(O,/obj/glowshroom)))
					var/obj/decal/cleanable/molten_item/I = new/obj/decal/cleanable/molten_item(O.loc)
					I.desc = "Looks like this was \an [O] some time ago."
					for(var/mob/M in viewers(5, O))
						M << "\red \the [O] melts."
					del(O)

		glycerol
			name = "Glycerol"
			id = "glycerol"
			description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
			reagent_state = LIQUID

		nitroglycerin
			name = "Nitroglycerin"
			id = "nitroglycerin"
			description = "Nitroglycerin is a heavy, colorless, oily, explosive liquid obtained by nitrating glycerol."
			reagent_state = LIQUID

		radium
			name = "Radium"
			id = "radium"
			description = "Radium is an alkaline earth metal. It is extremely radioactive."
			reagent_state = SOLID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.radiation += 3
				..()
				return


			reaction_turf(var/turf/T, var/volume)
				src = null
				if(!istype(T, /turf/space))
					new /obj/decal/cleanable/greenglow(T)


		ryetalyn
			name = "Ryetalyn"
			id = "ryetalyn"
			description = "Ryetalyn can cure all genetic abnomalities."
			reagent_state = SOLID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.mutations = 0
				M.disabilities = 0
				M.sdisabilities = 0
				..()
				return

		thermite
			name = "Thermite"
			id = "thermite"
			description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
			reagent_state = SOLID
			reaction_turf(var/turf/T, var/volume)
				src = null
				if(istype(T, /turf/simulated/wall))
					T:thermite = 1
					T.overlays = null
					T.overlays = image('effects.dmi',icon_state = "thermite")
				return



		mutagen
			name = "Unstable mutagen"
			id = "mutagen"
			description = "Might cause unpredictable mutations. Keep away from children."
			reagent_state = LIQUID
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if ( (method==TOUCH && prob(33)) || method==INGEST)
					randmuti(M)
					if(prob(98))
						randmutb(M)
					else
						randmutg(M)
					domutcheck(M, null)
					updateappearance(M,M.dna.uni_identity)
				return
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.radiation += 3
				..()
				return

		sterilizine
			name = "Sterilizine"
			id = "sterilizine"
			description = "Sterilizes wounds in preparation for surgery."
			reagent_state = LIQUID
	/*		reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if (method==TOUCH)
					if(istype(M, /mob/living/carbon/human))
						if(M.health >= -100 && M.health <= 0)
							M.crit_op_stage = 0.0
				if (method==INGEST)
					usr << "Well, that was stupid."
					M:toxloss += 3
				return
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
					M.radiation += 3
					..()
					return
	*/
		iron
			name = "Iron"
			id = "iron"
			description = "Pure iron is a metal."
			reagent_state = SOLID
/*
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if((M.virus) && (prob(8) && (M.virus.name=="Magnitis")))
					if(M.virus.spread == "Airborne")
						M.virus.spread = "Remissive"
					M.virus.stage--
					if(M.virus.stage <= 0)
						M.resistances += M.virus.type
						M.virus = null
				holder.remove_reagent(src.id, 0.2)
				return
*/

		gold
			name = "Gold"
			id = "gold"
			description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
			reagent_state = SOLID

		silver
			name = "Silver"
			id = "silver"
			description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
			reagent_state = SOLID

		uranium
			name ="Uranium"
			id = "uranium"
			description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
			reagent_state = SOLID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.radiation += 1
				..()
				return


			reaction_turf(var/turf/T, var/volume)
				src = null
				if(!istype(T, /turf/space))
					new /obj/decal/cleanable/greenglow(T)

		aluminum
			name = "Aluminum"
			id = "aluminum"
			description = "A silvery white and ductile member of the boron group of chemical elements."
			reagent_state = SOLID

		silicon
			name = "Silicon"
			id = "silicon"
			description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
			reagent_state = SOLID

		fuel
			name = "Welding fuel"
			id = "fuel"
			description = "Required for welders. Flamable."
			reagent_state = LIQUID
			reaction_obj(var/obj/O, var/volume)
				src = null
				var/turf/the_turf = get_turf(O)
				var/datum/gas_mixture/napalm = new
				var/datum/gas/volatile_fuel/fuel = new
				fuel.moles = 15
				napalm.trace_gases += fuel
				the_turf.assume_air(napalm)
			reaction_turf(var/turf/T, var/volume)
				src = null
				var/datum/gas_mixture/napalm = new
				var/datum/gas/volatile_fuel/fuel = new
				fuel.moles = 15
				napalm.trace_gases += fuel
				T.assume_air(napalm)
				return
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:toxloss += 1
				..()
				return

		space_cleaner
			name = "Space cleaner"
			id = "cleaner"
			description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
			reagent_state = LIQUID
			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/decal/cleanable))
					del(O)
				else
					if (O)
						O.clean_blood()
			reaction_turf(var/turf/T, var/volume)
				T.overlays = null
				T.clean_blood()
				for(var/obj/decal/cleanable/C in src)
					del(C)

				for(var/mob/living/carbon/metroid/M in T)
					M.toxloss+=rand(5,10)

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				M.clean_blood()
				if(istype(M, /mob/living/carbon))
					var/mob/living/carbon/C = M
					if(C.r_hand)
						C.r_hand.clean_blood()
					if(C.l_hand)
						C.l_hand.clean_blood()
					if(C.wear_mask)
						C.wear_mask.clean_blood()
					if(istype(M, /mob/living/carbon/human))
						if(C:w_uniform)
							C:w_uniform.clean_blood()
						if(C:wear_suit)
							C:wear_suit.clean_blood()
						if(C:shoes)
							C:shoes.clean_blood()
						if(C:gloves)
							C:gloves.clean_blood()
						if(C:head)
							C:head.clean_blood()


		plantbgone
			name = "Plant-B-Gone"
			id = "plantbgone"
			description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
			reagent_state = LIQUID
			/* Don't know if this is necessary.
			on_mob_life(var/mob/living/carbon/M)
				if(!M) M = holder.my_atom
				M:toxloss += 3.0
				..()
				return
			*/
			reaction_obj(var/obj/O, var/volume)
		//		if(istype(O,/obj/plant/vine/))
		//			O:life -= rand(15,35) // Kills vines nicely // Not tested as vines don't work in R41
				if(istype(O,/obj/alien/weeds/))
					O:health -= rand(15,35) // Kills alien weeds pretty fast
					O:healthcheck()
				else if(istype(O,/obj/glowshroom)) //even a small amount is enough to kill it
					del(O)
				// Damage that is done to growing plants is separately
				// at code/game/machinery/hydroponics at obj/item/hydroponics

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if(istype(M, /mob/living/carbon))
					if(!M.wear_mask) // If not wearing a mask
						M:toxloss += 2 // 4 toxic damage per application, doubled for some reason
					if(istype(M,/mob/living/carbon/human) && M:mutantrace == "plant") //plantmen take a LOT of damage
						M:toxloss += 10
						//if(prob(10))
							//M.make_dizzy(1) doesn't seem to do anything


		plasma
			name = "Plasma"
			id = "plasma"
			description = "Plasma in its liquid form."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(holder.has_reagent("inaprovaline"))
					holder.remove_reagent("inaprovaline", 2)
				M:toxloss++
				..()
				return
			reaction_obj(var/obj/O, var/volume)
				src = null
				var/turf/the_turf = get_turf(O)
				var/datum/gas_mixture/napalm = new
				var/datum/gas/volatile_fuel/fuel = new
				fuel.moles = 5
				napalm.trace_gases += fuel
				the_turf.assume_air(napalm)
			reaction_turf(var/turf/T, var/volume)
				src = null
				var/datum/gas_mixture/napalm = new
				var/datum/gas/volatile_fuel/fuel = new
				fuel.moles = 5
				napalm.trace_gases += fuel
				T.assume_air(napalm)
				return

		leporazine
			name = "Leporazine"
			id = "leporazine"
			description = "Leporazine can be use to stabilize an individuals body temperature."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.bodytemperature > 310)
					M.bodytemperature = max(310, M.bodytemperature-20)
				else if(M.bodytemperature < 311)
					M.bodytemperature = min(310, M.bodytemperature+20)
				..()
				return

		cryptobiolin
			name = "Cryptobiolin"
			id = "cryptobiolin"
			description = "Cryptobiolin causes confusion and dizzyness."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.make_dizzy(1)
				if(!M.confused) M.confused = 1
				M.confused = max(M.confused, 20)
				holder.remove_reagent(src.id, 0.2)
				..()
				return

		lexorin
			name = "Lexorin"
			id = "lexorin"
			description = "Lexorin temporarily stops respiration. Causes tissue damage."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(prob(33))
					M.take_organ_damage(1, 0)
				M:oxyloss += 3
				if(prob(20)) M:emote("gasp")
				..()
				return

		kelotane
			name = "Kelotane"
			id = "kelotane"
			description = "Kelotane is a drug used to treat burns."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				M:heal_organ_damage(0,2)
				..()
				return

		dermaline
			name = "Dermaline"
			id = "dermaline"
			description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0) //THE GUY IS **DEAD**! BEREFT OF ALL LIFE HE RESTS IN PEACE etc etc. He does NOT metabolise shit anymore, god DAMN
					return
				if(!M) M = holder.my_atom
				M:heal_organ_damage(0,3)
				..()
				return

		dexalin
			name = "Dexalin"
			id = "dexalin"
			description = "Dexalin is used in the treatment of oxygen deprivation."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return  //See above, down and around. --Agouri
				if(!M) M = holder.my_atom
				M:oxyloss = max(M:oxyloss-2, 0)
				if(holder.has_reagent("lexorin"))
					holder.remove_reagent("lexorin", 2)
				..()
				return

		dexalinp
			name = "Dexalin Plus"
			id = "dexalinp"
			description = "Dexalin Plus is used in the treatment of oxygen deprivation. Its highly effective."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				M:oxyloss = 0
				if(holder.has_reagent("lexorin"))
					holder.remove_reagent("lexorin", 2)
				..()
				return

		tricordrazine
			name = "Tricordrazine"
			id = "tricordrazine"
			description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(M:oxyloss && prob(40)) M:oxyloss--
				if(M:bruteloss && prob(40)) M:heal_organ_damage(1,0)
				if(M:fireloss && prob(40)) M:heal_organ_damage(0,1)
				if(M:toxloss && prob(40)) M:toxloss--
				..()
				return

		adminordrazine //An OP chemical for adminis
			name = "Adminordrazine"
			id = "adminordrazine"
			description = "It's magic. We don't have to explain it."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom ///This can even heal dead people.
				M:cloneloss = 0
				M:oxyloss = 0
				M:radiation = 0
				M:heal_organ_damage(5,5)
				if(M:toxloss) M:toxloss = max(0, M:toxloss-5)
				if(holder.has_reagent("toxin"))
					holder.remove_reagent("toxin", 5)
				if(holder.has_reagent("stoxin"))
					holder.remove_reagent("stoxin", 5)
				if(holder.has_reagent("plasma"))
					holder.remove_reagent("plasma", 5)
				if(holder.has_reagent("acid"))
					holder.remove_reagent("acid", 5)
				if(holder.has_reagent("pacid"))
					holder.remove_reagent("pacid", 5)
				if(holder.has_reagent("cyanide"))
					holder.remove_reagent("cyanide", 5)
				if(holder.has_reagent("lexorin"))
					holder.remove_reagent("lexorin", 5)
				if(holder.has_reagent("amatoxin"))
					holder.remove_reagent("amatoxin", 5)
				if(holder.has_reagent("chloralhydrate"))
					holder.remove_reagent("chloralhydrate", 5)
				if(holder.has_reagent("carpotoxin"))
					holder.remove_reagent("carpotoxin", 5)
				if(holder.has_reagent("zombiepowder"))
					holder.remove_reagent("zombiepowder", 5)
				M:brainloss = 0
				M.disabilities = 0
				M.sdisabilities = 0
				M:eye_blurry = 0
				M:eye_blind = 0
				M:disabilities &= ~1
				M:sdisabilities &= ~1
				M:weakened = 0
				M:stunned = 0
				M:paralysis = 0
				M:silent = 0
				M.dizziness = 0
				M:drowsyness = 0
				M:stuttering = 0
				M:confused = 0
				M:sleeping = 0
				M:jitteriness = 0
				for(var/datum/disease/D in M.viruses)
					D.spread = "Remissive"
					D.stage--
					if(D.stage < 1)
						D.cure()
				..()
				return

		synaptizine
			name = "Synaptizine"
			id = "synaptizine"
			description = "Synaptizine is used to treat neuroleptic shock. Can be used to help remove disabling symptoms such as paralysis."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:drowsyness = max(M:drowsyness-5, 0)
				if(M:paralysis) M:paralysis--
				if(M:stunned) M:stunned--
				if(M:weakened) M:weakened--
				..()
				return

		impedrezene
			name = "Impedrezene"
			id = "impedrezene"
			description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:jitteriness = max(M:jitteriness-5,0)
				if(prob(80)) M:brainloss++
				if(prob(50)) M:drowsyness = max(M:drowsyness, 3)
				if(prob(10)) M:emote("drool")
				..()
				return

		hyronalin
			name = "Hyronalin"
			id = "hyronalin"
			description = "Hyronalin is a medicinal drug used to counter the effects of radiation poisoning."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:radiation = max(M:radiation-3,0)
				..()
				return

		arithrazine
			name = "Arithrazine"
			id = "arithrazine"
			description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return  //See above, down and around. --Agouri
				if(!M) M = holder.my_atom
				M:radiation = max(M:radiation-7,0)
				if(M:toxloss) M:toxloss--
				if(prob(15))
					M.take_organ_damage(1, 0)
				..()
				return

		alkysine
			name = "Alkysine"
			id = "alkysine"
			description = "Alkysine is a drug used to lessen the damage to neurological tissue after a catastrophic injury. Can heal brain tissue."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:brainloss = max(M:brainloss-3 , 0)
				..()
				return

		imidazoline
			name = "Imidazoline"
			id = "imidazoline"
			description = "Heals eye damage"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:eye_blurry = max(M:eye_blurry-5 , 0)
				M:eye_blind = max(M:eye_blind-5 , 0)
				M:disabilities &= ~1
//				M:sdisabilities &= ~1		Replaced by eye surgery
				..()
				return

		bicaridine
			name = "Bicaridine"
			id = "bicaridine"
			description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				M:heal_organ_damage(2,0)
				..()
				return

		hyperzine
			name = "Hyperzine"
			id = "hyperzine"
			description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(prob(5)) M:emote(pick("twitch","blink_r","shiver"))
				holder.remove_reagent(src.id, 0.2)
				..()
				return

		cryoxadone
			name = "Cryoxadone"
			id = "cryoxadone"
			description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < 170)
					if(M:cloneloss) M:cloneloss = max(0, M:cloneloss-1)
					if(M:oxyloss) M:oxyloss = max(0, M:oxyloss-3)
					M:heal_organ_damage(3,3)
					if(M:toxloss) M:toxloss = max(0, M:toxloss-3)
				..()
				return

		clonexadone
			name = "Clonexadone"
			id = "clonexadone"
			description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' clones that get ejected early when used in conjunction with a cryo tube."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < 170)
					if(M:cloneloss) M:cloneloss = max(0, M:cloneloss-3)
					if(M:oxyloss) M:oxyloss = max(0, M:oxyloss-3)
					M:heal_organ_damage(3,3)
					if(M:toxloss) M:toxloss = max(0, M:toxloss-3)
				..()
				return

		spaceacillin
			name = "Spaceacillin"
			id = "spaceacillin"
			description = "An all-purpose antiviral agent."
			reagent_state = LIQUID

			on_mob_life(var/mob/living/M as mob)//no more mr. panacea
				holder.remove_reagent(src.id, 0.2)
				..()
				return

		carpotoxin
			name = "Carpotoxin"
			id = "carpotoxin"
			description = "A deadly neurotoxin produced by the dreaded spess carp."
			reagent_state = LIQUID

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:toxloss += 2
				..()
				return

		zombiepowder
			name = "Zombie Powder"
			id = "zombiepowder"
			description = "A strong neurotoxin that puts the subject into a death-like state."
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:oxyloss += 0.5
				M:toxloss += 0.5
				M:weakened = max(M:weakened, 10)
				M:silent = max(M:silent, 10)
				..()
				return


///////////////////////////////////////////////////////////////////////////////////////////////////////////////

		nanites
			name = "Nanomachines"
			id = "nanites"
			description = "Microscopic construction robots."
			reagent_state = LIQUID
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if( (prob(10) && method==TOUCH) || method==INGEST)
					M.contract_disease(new /datum/disease/robotic_transformation(0),1)

		xenomicrobes
			name = "Xenomicrobes"
			id = "xenomicrobes"
			description = "Microbes with an entirely alien cellular structure."
			reagent_state = LIQUID
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if( (prob(10) && method==TOUCH) || method==INGEST)
					M.contract_disease(new /datum/disease/xeno_transformation(0),1)

//foam precursor

		fluorosurfactant
			name = "Fluorosurfactant"
			id = "fluorosurfactant"
			description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
			reagent_state = LIQUID


// metal foaming agent
// this is lithium hydride. Add other recipies (e.g. LiH + H2O -> LiOH + H2) eventually

		foaming_agent
			name = "Foaming agent"
			id = "foaming_agent"
			description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
			reagent_state = SOLID

		nicotine
			name = "Nicotine"
			id = "nicotine"
			description = "A highly addictive stimulant extracted from the tobacco plant."
			reagent_state = LIQUID

		ethanol
			name = "Ethanol"
			id = "ethanol"
			description = "A well-known alcohol with a variety of applications."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.make_dizzy(5)
				M:jitteriness = max(M:jitteriness-5,0)
				if(data >= 25)
					if (!M:stuttering) M:stuttering = 1
					M:stuttering += 4
				if(data >= 40 && prob(33))
					if (!M:confused) M:confused = 1
					M:confused += 3
				..()
				return

		ammonia
			name = "Ammonia"
			id = "ammonia"
			description = "A caustic substance commonly used in fertilizer or household cleaners."
			reagent_state = GAS

		diethylamine
			name = "Diethylamine"
			id = "diethylamine"
			description = "A secondary amine, mildly corrosive."
			reagent_state = LIQUID

		ethylredoxrazine						// FUCK YOU, ALCOHOL
			name = "Ethylredoxrazine"
			id = "ethylredoxrazine"
			description = "A powerfuld oxidizer that reacts with ethanol."
			reagent_state = SOLID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.dizziness = 0
				M:drowsyness = 0
				M:stuttering = 0
				M:confused = 0
				..()
				return

		chloralhydrate							//Otherwise known as a "Mickey Finn"
			name = "Chloral Hydrate"
			id = "chloralhydrate"
			description = "A powerful sedative."
			reagent_state = SOLID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				data++
				switch(data)
					if(1)
						M:confused += 2
						M:drowsyness += 2
					if(2 to 50)
						M:sleeping += 1
					if(51 to INFINITY)
						M:sleeping += 1
						M:toxloss += (data - 50)
				..()
				return

		beer2							//copypasta of chloral hydrate, disguised as normal beer for use by emagged brobots
			name = "Beer"
			id = "beer2"
			description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(data)
					if(1)
						M:confused += 2
						M:drowsyness += 2
					if(2 to 50)
						M:sleeping += 1
					if(51 to INFINITY)
						M:sleeping += 1
						M:toxloss += (data - 50)
				data++
				..()
				return


/////////////////////////Food Reagents////////////////////////////
// Part of the food code. Nutriment is used instead of the old "heal_amt" code. Also is where all the food
// 	condiments, additives, and such go.
		nutriment
			name = "Nutriment"
			id = "nutriment"
			description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
			reagent_state = SOLID
			nutriment_factor = 15 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(prob(50)) M:heal_organ_damage(1,0)
				M:nutrition += nutriment_factor	// For hunger and fatness
/*
				// If overeaten - vomit and fall down
				// Makes you feel bad but removes reagents and some effects
				// from your body
				if (M.nutrition > 650)
					M.nutrition = rand (250, 400)
					M.weakened += rand(2, 10)
					M.jitteriness += rand(0, 5)
					M.dizziness = max (0, (M.dizziness - rand(0, 15)))
					M.druggy = max (0, (M.druggy - rand(0, 15)))
					M.toxloss = max (0, (M.toxloss - rand(5, 15)))
					M.updatehealth()
*/
				..()
				return

		soysauce
			name = "Soysauce"
			id = "soysauce"
			description = "A salty sauce made from the soy plant."
			reagent_state = LIQUID
			nutriment_factor = 2 * REAGENTS_METABOLISM

		ketchup
			name = "Ketchup"
			id = "ketchup"
			description = "Ketchup, catsup, whatever. It's tomato paste."
			reagent_state = LIQUID
			nutriment_factor = 5 * REAGENTS_METABOLISM


		capsaicin
			name = "Capsaicin Oil"
			id = "capsaicin"
			description = "This is what makes chilis hot."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:bodytemperature += 5
				if(prob(40) && !istype(M, /mob/living/carbon/metroid))
					M.take_organ_damage(0, 1)

				if(istype(M, /mob/living/carbon/metroid))
					M:bodytemperature += rand(5,20)
				..()
				return

		frostoil
			name = "Frost Oil"
			id = "frostoil"
			description = "A special oil that noticably chills the body. Extraced from Icepeppers."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:bodytemperature -= 5
				if(prob(40))
					M.take_organ_damage(0, 1)
				if(prob(80) && istype(M, /mob/living/carbon/metroid))
					M.fireloss += rand(5,20)
					M << "\red You feel a terrible chill inside your body!"
				..()
				return

			reaction_turf(var/turf/simulated/T, var/volume)
				for(var/mob/living/carbon/metroid/M in T)
					M.toxloss+=rand(15,30)

		sodiumchloride
			name = "Table Salt"
			id = "sodiumchloride"
			description = "A salt made of sodium chloride. Commonly used to season food."
			reagent_state = SOLID

		blackpepper
			name = "Black Pepper"
			id = "blackpepper"
			description = "A power ground from peppercorns. *AAAACHOOO*"
			reagent_state = SOLID

		coco
			name = "Coco Powder"
			id = "Coco Powder"
			description = "A fatty, bitter paste made from coco beans."
			reagent_state = SOLID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				..()
				return

		hot_coco
			name = "Hot Chocolate"
			id = "hot_coco"
			description = "Made with love! And coco beans."
			reagent_state = LIQUID
			nutriment_factor = 2 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature+5)
				M:nutrition += nutriment_factor
				..()
				return

		amatoxin
			name = "Amatoxin"
			id = "amatoxin"
			description = "A powerful poison derived from certain species of mushroom."
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:toxloss++
				..()
				return

		psilocybin
			name = "Psilocybin"
			id = "psilocybin"
			description = "A strong psycotropic derived from certain species of mushroom."
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 30)
				if(!data) data = 1
				switch(data)
					if(1 to 5)
						if (!M:stuttering) M:stuttering = 1
						M.make_dizzy(5)
						if(prob(10)) M:emote(pick("twitch","giggle"))
					if(5 to 10)
						if (!M:stuttering) M:stuttering = 1
						M.make_jittery(10)
						M.make_dizzy(10)
						M.druggy = max(M.druggy, 35)
						if(prob(20)) M:emote(pick("twitch","giggle"))
					if (10 to INFINITY)
						if (!M:stuttering) M:stuttering = 1
						M.make_jittery(20)
						M.make_dizzy(20)
						M.druggy = max(M.druggy, 40)
						if(prob(30)) M:emote(pick("twitch","giggle"))
				holder.remove_reagent(src.id, 0.2)
				data++
				..()
				return

		sprinkles
			name = "Sprinkles"
			id = "sprinkles"
			description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
					if(!M) M = holder.my_atom
					M:heal_organ_damage(1,1)
					M:nutrition += nutriment_factor
					..()
					return
				..()

		syndicream
			name = "Cream filling"
			id = "syndicream"
			description = "Delicious cream filling of a mysterious origin. Tastes criminally good."
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				if(istype(M, /mob/living/carbon/human) && M.mind)
					if(M.mind.special_role)
						if(!M) M = holder.my_atom
						M:heal_organ_damage(1,1)
						M:nutrition += nutriment_factor
						..()
						return
				..()

		cornoil
			name = "Corn Oil"
			id = "cornoil"
			description = "An oil derived from various types of corn."
			reagent_state = LIQUID
			nutriment_factor = 20 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				..()
				return
			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return
				src = null
				if(volume >= 3)
					if(T.wet >= 1) return
					T.wet = 1
					if(T.wet_overlay)
						T.overlays -= T.wet_overlay
						T.wet_overlay = null
					T.wet_overlay = image('water.dmi',T,"wet_floor")
					T.overlays += T.wet_overlay

					spawn(800)
						if (!istype(T)) return
						if(T.wet >= 2) return
						T.wet = 0
						if(T.wet_overlay)
							T.overlays -= T.wet_overlay
							T.wet_overlay = null
				var/hotspot = (locate(/obj/hotspot) in T)
				if(hotspot)
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					del(hotspot)

		enzyme
			name = "Universal Enzyme"
			id = "enzyme"
			description = "A universal enzyme used in the preperation of certain chemicals and foods."
			reagent_state = LIQUID

		dry_ramen
			name = "Dry Ramen"
			id = "dry_ramen"
			description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
			reagent_state = SOLID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				..()
				return

		hot_ramen
			name = "Hot Ramen"
			id = "hot_ramen"
			description = "The noodles are boiled, the flavors are artificial, just like being back in school."
			reagent_state = LIQUID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature+10)
				..()
				return

		hell_ramen
			name = "Hell Ramen"
			id = "hell_ramen"
			description = "The noodles are boiled, the flavors are artificial, just like being back in school."
			reagent_state = LIQUID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				M:bodytemperature += 10
				..()
				return


/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////// DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

		orangejuice
			name = "Orange juice"
			id = "orangejuice"
			description = "Both delicious AND rich in Vitamin C, what more do you need?"
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				if(!M) M = holder.my_atom
				if(M:oxyloss && prob(30)) M:oxyloss--
				M:nutrition++
				..()
				return

		tomatojuice
			name = "Tomato Juice"
			id = "tomatojuice"
			description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				if(!M) M = holder.my_atom
				if(M:fireloss && prob(20)) M:heal_organ_damage(0,1)
				M:nutrition++
				..()
				return

		limejuice
			name = "Lime Juice"
			id = "limejuice"
			description = "The sweet-sour juice of limes."
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				if(!M) M = holder.my_atom
				if(M:toxloss && prob(20)) M:toxloss--
				M:nutrition++
				..()
				return

		carrotjuice
			name = "Carrot juice"
			id = "carrotjuice"
			description = "It is just like a carrot but without crunching."
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:nutrition += nutriment_factor
				M:eye_blurry = max(M:eye_blurry-1 , 0)
				M:eye_blind = max(M:eye_blind-1 , 0)
				if(!data) data = 1
				switch(data)
					if(1 to 20)
						//nothing
					if(21 to INFINITY)
						if (prob(data-10))
							M:disabilities &= ~1
				data++
				..()
				return

		berryjuice
			name = "Berry Juice"
			id = "berryjuice"
			description = "A delicious blend of several different kinds of berries."
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:nutrition += nutriment_factor
				..()
				return

		poisonberryjuice
			name = "Poison Berry Juice"
			id = "poisonberryjuice"
			description = "A tasty juice blended from various kinds of very deadly and toxic berries."
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:nutrition += nutriment_factor
				M:toxloss += 1
				..()
				return

		watermelonjuice
			name = "Watermelon Juice"
			id = "watermelonjuice"
			description = "Delicious juice made from watermelon."
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:nutrition += nutriment_factor
				..()
				return

		lemonjuice
			name = "Lemon Juice"
			id = "lemonjuice"
			description = "This juice is VERY sour."
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:nutrition += nutriment_factor
				..()
				return

		banana
			name = "Banana Juice"
			id = "banana"
			description = "The raw essence of a banana. HONK"
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				if(istype(M, /mob/living/carbon/human) && M.job in list("Clown"))
					if(!M) M = holder.my_atom
					M:heal_organ_damage(1,1)
					..()
					return
				if(istype(M, /mob/living/carbon/monkey))
					if(!M) M = holder.my_atom
					M:heal_organ_damage(1,1)
					..()
					return
				..()

		nothing
			name = "Nothing"
			id = "nothing"
			description = "Absolutely nothing."
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				if(istype(M, /mob/living/carbon/human) && M.job in list("Mime"))
					if(!M) M = holder.my_atom
					M:heal_organ_damage(1,1)
					..()
					return
				..()

		potato_juice
			name = "Potato Juice"
			id = "potato"
			description = "Juice of the potato. Bleh."
			reagent_state = LIQUID
			nutriment_factor = 2 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				..()
				return

		milk
			name = "Milk"
			id = "milk"
			description = "An opaque white liquid produced by the mammary glands of mammals."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M:bruteloss && prob(20)) M:heal_organ_damage(1,0)
				M:nutrition++
				..()
				return

		soymilk
			name = "Soy Milk"
			id = "soymilk"
			description = "An opaque white liquid made from soybeans."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M:bruteloss && prob(20)) M:heal_organ_damage(1,0)
				M:nutrition++
				..()
				return

		cream
			name = "Cream"
			id = "cream"
			description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				if(M:bruteloss && prob(20)) M:heal_organ_damage(1,0)
				..()
				return

		coffee
			name = "Coffee"
			id = "coffee"
			description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				..()
				M.dizziness = max(0,M.dizziness-5)
				M:drowsyness = max(0,M:drowsyness-3)
				M:sleeping = 0
				if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature+5)
				M.make_jittery(5)
				..()
				return

		tea
			name = "Tea"
			id = "tea"
			description = "Tasty black tea, it has antioxidants, it's good for you!"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				..()
				M.dizziness = max(0,M.dizziness-2)
				M:drowsyness = max(0,M:drowsyness-1)
				M:jitteriness = max(0,M:jitteriness-3)
				M:sleeping = 0
				if(M:toxloss && prob(20))
					M:toxloss--
				if (M.bodytemperature < 310)  //310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature+5)
				..()
				return

		icecoffee
			name = "Iced Coffee"
			id = "icecoffee"
			description = "Coffee and ice, refreshing and cool."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				..()
				M.dizziness = max(0,M.dizziness-5)
				M:drowsyness = max(0,M:drowsyness-3)
				M:sleeping = 0
				if (M.bodytemperature > 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature-5)
				M.make_jittery(5)
				..()
				return

		icetea
			name = "Iced Tea"
			id = "icetea"
			description = "No relation to a certain rap artist/ actor."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				..()
				M.dizziness = max(0,M.dizziness-2)
				M:drowsyness = max(0,M:drowsyness-1)
				M:sleeping = 0
				if(M:toxloss && prob(20))
					M:toxloss--
				if (M.bodytemperature > 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature-5)
				return

		space_cola
			name = "Cola"
			id = "cola"
			description = "A refreshing beverage."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				M:drowsyness = max(0,M:drowsyness-5)
				if (M.bodytemperature > 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = max(310, M.bodytemperature-5)
				M:nutrition += 1
				..()
				return

		nuka_cola
			name = "Nuka Cola"
			id = "nuka_cola"
			description = "Cola, cola never changes."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				M.make_jittery(20)
				M.druggy = max(M.druggy, 30)
				M.dizziness +=5
				M:drowsyness = 0
				M:sleeping = 0
				if (M.bodytemperature > 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = max(310, M.bodytemperature-5)
				M:nutrition += 1
				..()
				return

		spacemountainwind
			name = "Space Mountain Wind"
			id = "spacemountainwind"
			description = "Blows right through you like a space wind."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				M:drowsyness = max(0,M:drowsyness-7)
				M:sleeping = 0
				if (M.bodytemperature > 310)
					M.bodytemperature = max(310, M.bodytemperature-5)
				M.make_jittery(5)
				M:nutrition += 1
				..()
				return

		thirteenloko
			name = "Thirteen Loko"
			id = "thirteenloko"
			description = "A potent mixture of caffeine and alcohol."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				M:drowsyness = max(0,M:drowsyness-7)
				M:sleeping = 0
				if (M.bodytemperature > 310)
					M.bodytemperature = max(310, M.bodytemperature-5)
				M.make_jittery(5)
				M:nutrition += 1
				if(!data) data = 1
				data++
				M.dizziness +=4
				if(data >= 45 && data <115)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 125 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		dr_gibb
			name = "Dr. Gibb"
			id = "dr_gibb"
			description = "A delicious blend of 42 different flavours"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				M:drowsyness = max(0,M:drowsyness-6)
				if (M.bodytemperature > 310)
					M.bodytemperature = max(310, M.bodytemperature-5) //310 is the normal bodytemp. 310.055
				M:nutrition += 1
				..()
				return

		space_up
			name = "Space-Up"
			id = "space_up"
			description = "Tastes like a hull breach in your mouth."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if (M.bodytemperature > 310)
					M.bodytemperature = max(310, M.bodytemperature-8) //310 is the normal bodytemp. 310.055
				M:nutrition += 1
				..()
				return

		lemon_lime
			name = "Lemon Lime"
			description = "A tangy substance made of 0.5% natural citrus!"
			id = "lemon_lime"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if (M.bodytemperature > 310)
					M.bodytemperature = max(310, M.bodytemperature-8) //310 is the normal bodytemp. 310.055
				M:nutrition += 1
				..()
				return

		beer
			name = "Beer"
			id = "beer"
			description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.make_dizzy(3)
				M:jitteriness = max(M:jitteriness-3,0)
				M:nutrition += 2
				if(data >= 25)
					if (!M:stuttering) M:stuttering = 1
					M:stuttering += 3
				if(data >= 40 && prob(33))
					if (!M:confused) M:confused = 1
					M:confused += 2

				..()
				return

		whiskey
			name = "Whiskey"
			id = "whiskey"
			description = "A superb and well-aged single-malt whiskey. Damn."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=4
				if(data >= 45 && data <125)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 125 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		specialwhiskey
			name = "Special Blend Whiskey"
			id = "specialwhiskey"
			description = "Just when you thought regular station whiskey was good... This silky, amber goodness has to come along and ruin everything."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <125)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 125 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return


		gin
			name = "Gin"
			id = "gin"
			description = "It's gin. In space. I say, good sir."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <125)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 125 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		rum
			name = "Rum"
			id = "rum"
			description = "Yohoho and all that."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <125)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 125 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		vodka
			name = "Vodka"
			id = "vodka"
			description = "Number one drink AND fueling choice for Russians worldwide."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <125)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 125 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		tequilla
			name = "Tequila"
			id = "tequilla"
			description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <125)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 125 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		vermouth
			name = "Vermouth"
			id = "vermouth"
			description = "You suddenly feel a craving for a martini..."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <125)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 125 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		wine
			name = "Wine"
			id = "wine"
			description = "An premium alchoholic beverage made from distilled grape juice."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=2
				if(data >= 65 && data <125)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 145 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		tonic
			name = "Tonic Water"
			id = "tonic"
			description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				M.dizziness = max(0,M.dizziness-5)
				M:drowsyness = max(0,M:drowsyness-3)
				M:sleeping = 0
				if (M.bodytemperature > 310)
					M.bodytemperature = max(310, M.bodytemperature-5)
				..()
				return

		kahlua
			name = "Kahlua"
			id = "kahlua"
			description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				M.dizziness = max(0,M.dizziness-5)
				M:drowsyness = max(0,M:drowsyness-3)
				M:sleeping = 0//Copy-paste from Coffee, derp
				M.make_jittery(5)
				..()
				return


		cognac
			name = "Cognac"
			id = "cognac"
			description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=4
				if(data >= 45 && data <115)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 115 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		hooch
			name = "Hooch"
			id = "hooch"
			description = "Either someone's failure at cocktail making or attempt in alchohol production. In any case, do you really want to drink that?"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=6
				if(data >= 35 && data <90)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 5
				else if(data >= 90 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		ale
			name = "Ale"
			id = "ale"
			description = "A dark alchoholic beverage made by malted barley and yeast."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <125)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 125 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		sodawater
			name = "Soda Water"
			id = "sodawater"
			description = "A can of club soda. Why not make a scotch and soda?"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				M.dizziness = max(0,M.dizziness-5)
				M:drowsyness = max(0,M:drowsyness-3)
				M:sleeping = 0
				if (M.bodytemperature > 310)
					M.bodytemperature = max(310, M.bodytemperature-5)
				..()
				return

		ice
			name = "Ice"
			id = "ice"
			description = "Frozen water, your dentist wouldn't like you chewing this."
			reagent_state = SOLID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:bodytemperature -= 5
				..()
				return

/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////

		bilk
			name = "Bilk"
			id = "bilk"
			description = "This appears to be beer mixed with milk. Disgusting."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(M:bruteloss && prob(10)) M:heal_organ_damage(1,0)
				M:nutrition += 2
				if(!data) data = 1
				data++
				M.make_dizzy(3)
				M:jitteriness = max(M:jitteriness-3,0)
				if(data >= 25)
					if (!M:stuttering) M:stuttering = 1
					M:stuttering += 3
				if(data >= 40 && prob(33))
					if (!M:confused) M:confused = 1
					M:confused += 2
				..()
				return

		atomicbomb
			name = "Atomic Bomb"
			id = "atomicbomb"
			description = "Nuclear proliferation never tasted so good."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				M.druggy = max(M.druggy, 50)
				M.confused = max(M:confused+2,0)
				M.make_dizzy(10)
				if (!M.stuttering) M.stuttering = 1
				M.stuttering += 3
				if(!data) data = 1
				data++
				switch(data)
					if(51 to INFINITY)
						M:sleeping += 1
				..()
				return

		threemileisland
			name = "THree Mile Island Iced Tea"
			id = "threemileisland"
			description = "Made for a woman, strong enough for a man."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				M.druggy = max(M.druggy, 50)
				if(data >= 35 && data <90)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 90)
					M.confused = max(M:confused+2,0)
				..()
				return

		goldschlager
			name = "Goldschlager"
			id = "goldschlager"
			description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <125)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 125 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		patron
			name = "Patron"
			id = "patron"
			description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <125)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 125 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		gintonic
			name = "Gin and Tonic"
			id = "gintonic"
			description = "An all time classic, mild cocktail."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <135)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 135 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		cuba_libre
			name = "Cuba Libre"
			id = "cubalibre"
			description = "Rum, mixed with cola. Viva la revolution."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <135)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 135 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		whiskey_cola
			name = "Whiskey Cola"
			id = "whiskeycola"
			description = "Whiskey, mixed with cola. Surprisingly refreshing."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 55 && data <125)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 125 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		martini
			name = "Classic Martini"
			id = "martini"
			description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <165)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 135 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		vodkamartini
			name = "Vodka Martini"
			id = "vodkamartini"
			description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <165)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 135 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		white_russian
			name = "White Russian"
			id = "whiterussian"
			description = "That's just, like, your opinion, man..."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 55 && data <165)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 165 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		screwdrivercocktail
			name = "Screwdriver"
			id = "screwdrivercocktail"
			description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 55 && data <165)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 165 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		bloody_mary
			name = "Bloody Mary"
			id = "bloodymary"
			description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 55 && data <165)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 165 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		gargle_blaster
			name = "Pan-Galactic Gargle Blaster"
			id = "gargleblaster"
			description = "Whoah, this stuff looks volatile!"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=6
				if(data >= 15 && data <45)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 45 && prob(50) && data <55)
					M.confused = max(M:confused+3,0)
				else if(data >=55)
					M.druggy = max(M.druggy, 55)
				..()
				return

		brave_bull
			name = "Brave Bull"
			id = "bravebull"
			description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <145)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 145 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		tequilla_sunrise
			name = "Tequilla Sunrise"
			id = "tequillasunrise"
			description = "Tequilla and orange juice. Much like a Screwdriver, only Mexican~"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 55 && data <165)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 165 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		toxins_special
			name = "Toxins Special"
			id = "toxinsspecial"
			description = "This thing is FLAMING!. CALL THE DAMN SHUTTLE!"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if (M.bodytemperature < 330)
					M.bodytemperature = min(330, M.bodytemperature+15) //310 is the normal bodytemp. 310.055
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 55 && data <165)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 165 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		beepsky_smash
			name = "Beepsky Smash"
			id = "beepskysmash"
			description = "Deny drinking this and prepare for THE LAW."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				M.stunned = 2
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 55 && data <165)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 165 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		doctor_delight
			name = "The Doctor's Delight"
			id = "doctorsdelight"
			description = "A gulp a day keeps the MediBot away. That's probably for the best."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M:oxyloss && prob(50)) M:oxyloss -= 2
				if(M:bruteloss && prob(60)) M:heal_organ_damage(2,0)
				if(M:fireloss && prob(50)) M:heal_organ_damage(0,2)
				if(M:toxloss && prob(50)) M:toxloss -= 2
				if(M.dizziness !=0) M.dizziness = max(0,M.dizziness-15)
				if(M.confused !=0) M.confused = max(0,M.confused - 5)
				..()
				return

		irish_cream
			name = "Irish Cream"
			id = "irishcream"
			description = "Whiskey-imbued cream, what else would you expect from the Irish."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 45 && data <145)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 145 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		manly_dorf
			name = "The Manly Dorf"
			id = "manlydorf"
			description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=5
				if(data >= 35 && data <115)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 115 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		longislandicedtea
			name = "Long Island Iced Tea"
			id = "longislandicedtea"
			description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 55 && data <165)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 165 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		moonshine
			name = "Moonshine"
			id = "moonshine"
			description = "You've really hit rock bottom now... your liver packed its bags and left last night."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=5
				if(data >= 30 && data <60)
					if (!M.stuttering) M:stuttering = 1
					M.stuttering += 4
				else if(data >= 60 && prob(40))
					M.confused = max(M:confused+5,0)
				..()
				return

		b52
			name = "B-52"
			id = "b52"
			description = "Coffee, Irish Cream, and congac. You will get bombed."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 25 && data <90)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 90 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		irishcoffee
			name = "Irish Coffee"
			id = "irishcoffee"
			description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 55 && data <150)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 150 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		margarita
			name = "Margarita"
			id = "margarita"
			description = "On the rocks with salt on the rim. Arriba~!"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=4
				if(data >= 55 && data <150)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 150 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		black_russian
			name = "Black Russian"
			id = "blackrussian"
			description = "For the lactose-intolerant. Still as classy as a White Russian."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=4
				if(data >= 55 && data <115)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 115 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		manhattan
			name = "Manhattan"
			id = "manhattan"
			description = "The Detective's undercover drink of choice. He never could stomach gin..."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=4
				if(data >= 55 && data <115)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 115 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		manhattan_proj
			name = "Manhattan Project"
			id = "manhattan_proj"
			description = "A scienitst drink of choice, for thinking how to blow up the station."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=4
				M.druggy = max(M.druggy, 30)
				if(data >= 55 && data <115)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 115 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		whiskeysoda
			name = "Whiskey Soda"
			id = "whiskeysoda"
			description = "Ultimate refreshment."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=4
				if(data >= 55 && data <115)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 115 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		vodkatonic
			name = "Vodka and Tonic"
			id = "vodkatonic"
			description = "For when a gin and tonic isn't russian enough."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=4
				if(data >= 55 && data <115)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 115 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		ginfizz
			name = "Gin Fizz"
			id = "ginfizz"
			description = "Refreshingly lemony, deliciously dry."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=4
				if(data >= 45 && data <125)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 125 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		bahama_mama
			name = "Bahama mama"
			id = "bahama_mama"
			description = "Tropic cocktail."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=3
				if(data >= 55 && data <165)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 165 && prob(33))
					M.confused = max(M:confused+2,0)
				if (M.bodytemperature > 310)
					M.bodytemperature = max(310, M.bodytemperature-5)
				..()
				return

		sbiten
			name = "Sbiten"
			id = "sbiten"
			description = "A spicy Vodka! Might be a little hot for the little guys!"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if (M.bodytemperature < 360)
					M.bodytemperature = min(360, M.bodytemperature+50) //310 is the normal bodytemp. 310.055
				if(!data) data = 1
				data++
				M.dizziness +=6
				if(data >= 45 && data <125)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 6
				else if(data >= 125 && prob(33))
					M.confused = max(M:confused+5,5)
				..()
				return

		red_mead
			name = "Red Mead"
			id = "red_mead"
			description = "The true Viking drink! Even though it has a strange red color."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=5
				if(data >= 55 && data <115)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 4
				else if(data >= 115 && prob(33))
					M.confused = max(M:confused+4,4)
				..()
				return

		mead
			name = "Mead"
			id = "mead"
			description = "A Vikings drink, though a cheap one."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.make_dizzy(3)
				M:jitteriness = max(M:jitteriness-3,0)
				M:nutrition += 2
				if(data >= 25)
					if (!M:stuttering) M:stuttering = 1
					M:stuttering += 3
				if(data >= 40 && prob(33))
					if (!M:confused) M:confused = 1
					M:confused += 2

				..()
				return

		iced_beer
			name = "Iced Beer"
			id = "iced_beer"
			description = "A beer which is so cold the air around it freezes."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if (M.bodytemperature < 270)
					M.bodytemperature = min(270, M.bodytemperature-40) //310 is the normal bodytemp. 310.055
				if(!data) data = 1
				data++
				M.make_dizzy(3)
				M:jitteriness = max(M:jitteriness-3,0)
				M:nutrition += 2
				if(data >= 25)
					if (!M:stuttering) M:stuttering = 1
					M:stuttering += 3
				if(data >= 40 && prob(33))
					if (!M:confused) M:confused = 1
					M:confused += 2

				..()
				return

		grog
			name = "Grog"
			id = "grog"
			description = "Watered down rum, Nanotrasen approves!"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=2
				if(data >= 90 && data <250)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 2
				else if(data >= 250 && prob(33))
					M.confused = max(M:confused+2,0)
				..()
				return

		soy_latte
			name = "Soy Latte"
			id = "soy_latte"
			description = "A nice and tasty beverage while you are reading your hippie books."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				..()
				M.dizziness = max(0,M.dizziness-5)
				M:drowsyness = max(0,M:drowsyness-3)
				M:sleeping = 0
				if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature+5)
				M.make_jittery(5)
				if(M:bruteloss && prob(20)) M:heal_organ_damage(1,0)
				M:nutrition++
				..()
				return

		cafe_latte
			name = "Cafe Latte"
			id = "cafe_latte"
			description = "A nice, strong and tasty beverage while you are reading."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				..()
				M.dizziness = max(0,M.dizziness-5)
				M:drowsyness = max(0,M:drowsyness-3)
				M:sleeping = 0
				if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature+5)
				M.make_jittery(5)
				if(M:bruteloss && prob(20)) M:heal_organ_damage(1,0)
				M:nutrition++
				..()
				return

		acid_spit
			name = "Acid Spit"
			id = "acidspit"
			description = "A drink by Nanotrasen. Made from live aliens."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=10
				if(data >= 55 && data <115)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 10
				else if(data >= 115 && prob(33))
					M.confused = max(M:confused+10,0)
				..()
				return

		amasec
			name = "Amasec"
			id = "amasec"
			description = "Always before COMBAT!!!"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				M.stunned = 4
				if(!data) data = 1
				data++
				M.dizziness +=4
				if(data >= 55 && data <165)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 4
				else if(data >= 165 && prob(33))
					M.confused = max(M:confused+5,0)
				..()
				return

		neurotoxin
			name = "Neurotoxin"
			id = "neurotoxin"
			description = "A strong neurotoxin that puts the subject into a death-like state."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M:oxyloss += 0.5
				M:toxloss += 0.5
				M:weakened = max(M:weakened, 15)
				M:silent = max(M:silent, 15)
				if(!data) data = 1
				data++
				M.dizziness +=6
				if(data >= 15 && data <45)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 3
				else if(data >= 45 && prob(50) && data <55)
					M.confused = max(M:confused+3,0)
				else if(data >=55)
					M.druggy = max(M.druggy, 55)
				..()

				return


		hippies_delight
			name = "Hippies Delight"
			id = "hippiesdelight"
			description = "A drink enjoyed by people during the 1960's."
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 50)
				if(!data) data = 1
				switch(data)
					if(1 to 5)
						if (!M:stuttering) M:stuttering = 1
						M.make_dizzy(10)
						if(prob(10)) M:emote(pick("twitch","giggle"))
					if(5 to 10)
						if (!M:stuttering) M:stuttering = 1
						M.make_jittery(20)
						M.make_dizzy(20)
						M.druggy = max(M.druggy, 45)
						if(prob(20)) M:emote(pick("twitch","giggle"))
					if (10 to INFINITY)
						if (!M:stuttering) M:stuttering = 1
						M.make_jittery(40)
						M.make_dizzy(40)
						M.druggy = max(M.druggy, 60)
						if(prob(30)) M:emote(pick("twitch","giggle"))
				holder.remove_reagent(src.id, 0.2)
				data++
				..()
				return

		bananahonk
			name = "Banana Honk"
			id = "bananahonk"
			description = "A drink from Clown Heaven."
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				if(!data) data = 1
				data++
				if(istype(M, /mob/living/carbon/human) && M.job in list("Clown"))
					if(!M) M = holder.my_atom
					M:heal_organ_damage(1,1)
					M.dizziness +=5
					if(data >= 55 && data <165)
						if (!M.stuttering) M.stuttering = 1
						M.stuttering += 5
					else if(data >= 165 && prob(33))
						M.confused = max(M:confused+5,0)
					..()
					return
				if(istype(M, /mob/living/carbon/monkey))
					if(!M) M = holder.my_atom
					M:heal_organ_damage(1,1)
					M.dizziness +=5
					if(data >= 55 && data <165)
						if (!M.stuttering) M.stuttering = 1
						M.stuttering += 5
					else if(data >= 165 && prob(33))
						M.confused = max(M:confused+5,0)
					..()
					return

		silencer
			name = "Silencer"
			id = "silencer"
			description = "A drink from Mime Heaven."
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/living/M as mob)
				M:nutrition += nutriment_factor
				if(!data) data = 1
				data++
				if(istype(M, /mob/living/carbon/human) && M.job in list("Mime"))
					if(!M) M = holder.my_atom
					M:heal_organ_damage(1,1)
					M.dizziness +=5
					if(data >= 55 && data <165)
						if (!M.stuttering) M.stuttering = 1
						M.stuttering += 5
					else if(data >= 165 && prob(33))
						M.confused = max(M:confused+5,0)
					..()
					return

		singulo
			name = "Singulo"
			id = "singulo"
			description = "A blue-space beverage!"
			reagent_state = LIQUID
			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=15
				if(data >= 55 && data <115)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 15
				else if(data >= 115 && prob(33))
					M.confused = max(M:confused+15,15)
				..()
				return


