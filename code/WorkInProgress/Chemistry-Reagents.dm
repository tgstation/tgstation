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

			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
				if(prob(10))
					M << "You don't feel too good."
					M.toxloss+=20
				else if(prob(40))
					M.bruteloss-=5
				..()



		blood
			data = new/list("donor"=null,"virus"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null)
			name = "Blood"
			id = "blood"
			reagent_state = LIQUID

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if(M.virus) return //to prevent the healing of some serious shit with common cold injection.
				var/datum/reagent/blood/self = src
				src = null
				if(self.data["virus"])
					var/datum/disease/V = self.data["virus"]
					if(M.resistances.Find(V.type)) return
					if(method == TOUCH)//respect all protective clothing...
						M.contract_disease(V)
					else //injected
						M.contract_disease(V, 1, 0)
				return


			reaction_turf(var/turf/T, var/volume)//splash the blood all over the place
				var/datum/reagent/blood/self = src
				src = null
				if(!istype(T, /turf/simulated/)) return
				var/datum/disease/D = self.data["virus"]
				if(istype(self.data["donor"], /mob/living/carbon/human) || !self.data["donor"])
					var/turf/simulated/source2 = T
					var/list/objsonturf = range(0,T)
					var/i
					for(i=1, i<=objsonturf.len, i++)
						if(istype(objsonturf[i],/obj/decal/cleanable/blood))
							return
					var/obj/decal/cleanable/blood/blood_prop = new /obj/decal/cleanable/blood(source2)
					blood_prop.blood_DNA = self.data["blood_DNA"]
					blood_prop.blood_type = self.data["blood_type"]
					if(D)
						blood_prop.virus = new D.type
						blood_prop.virus.holder = blood_prop
					if(istype(T, /turf/simulated/floor))
						blood_prop.virus.spread_type = CONTACT_FEET
					else
						blood_prop.virus.spread_type = CONTACT_HANDS

				else if(istype(self.data["donor"], /mob/living/carbon/monkey))
					var/turf/simulated/source1 = T
					var/obj/decal/cleanable/blood/blood_prop = new /obj/decal/cleanable/blood(source1)
					blood_prop.blood_DNA = self.data["blood_DNA"]
					if(D)
						blood_prop.virus = new D.type
						blood_prop.virus.holder = blood_prop
					if(istype(T, /turf/simulated/floor))
						blood_prop.virus.spread_type = CONTACT_FEET
					else
						blood_prop.virus.spread_type = CONTACT_HANDS

				else if(istype(self.data["donor"], /mob/living/carbon/alien))
					var/turf/simulated/source2 = T
					var/obj/decal/cleanable/xenoblood/blood_prop = new /obj/decal/cleanable/xenoblood(source2)
					if(D)
						blood_prop.virus = new D.type
						blood_prop.virus.holder = blood_prop
					if(istype(T, /turf/simulated/floor))
						blood_prop.virus.spread_type = CONTACT_FEET
					else
						blood_prop.virus.spread_type = CONTACT_HANDS
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
					if(M.virus && M.virus.type == self.data)
						M.virus.cure()
				return


		water
			name = "Water"
			id = "water"
			description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
			reagent_state = LIQUID

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 3)
					if(T:wet >= 1) return
					T:wet = 1
					if(T:wet_overlay)
						T:overlays -= T:wet_overlay
						T:wet_overlay = null
					T:wet_overlay = image('water.dmi',T,"wet_floor")
					T:overlays += T:wet_overlay

					spawn(800)
						if(T:wet >= 2) return
						T:wet = 0
						if(T:wet_overlay)
							T:overlays -= T:wet_overlay
							T:wet_overlay = null

				var/hotspot = (locate(/obj/hotspot) in T)
				if(hotspot)
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
				if(hotspot)
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					del(hotspot)
				return

		lube
			name = "Space Lube"
			id = "lube"
			description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
			reagent_state = LIQUID

			reaction_turf(var/turf/T, var/volume)
				if (!istype(T, /turf/space))
					src = null
					if(T:wet >= 2) return
					T:wet = 2
					spawn(800)
						T:wet = 0
						if(T:wet_overlay)
							T:overlays -= T:wet_overlay
							T:wet_overlay = null

					return

		bilk
			name = "Bilk"
			id = "bilk"
			description = "This appears to be beer mixed with milk. Disgusting."
			reagent_state = LIQUID

		anti_toxin
			name = "Anti-Toxin (Dylovene)"
			id = "anti_toxin"
			description = "Dylovene is a broad-spectrum antitoxin."
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
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
				M:toxloss = max(M:toxloss-2,0)
				..()
				return

		toxin
			name = "Toxin"
			id = "toxin"
			description = "A Toxic chemical."
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:toxloss += 1.5
				..()
				return

		cyanide
			name = "Cyanide"
			id = "cyanide"
			description = "A highly toxic chemical."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:toxloss += 3
				M:oxyloss += 3
				..()
				return

		stoxin
			name = "Sleep Toxin"
			id = "stoxin"
			description = "An effective hypnotic used to treat insomnia."
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
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

		inaprovaline
			name = "Inaprovaline"
			id = "inaprovaline"
			description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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

			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:bruteloss++
				..()
				return

		fluorine
			name = "Fluorine"
			id = "fluorine"
			description = "A highly-reactive chemical element."
			reagent_state = GAS
			on_mob_life(var/mob.M)
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

			on_mob_life(var/mob/M)
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

		acid
			name = "Sulphuric acid"
			id = "acid"
			description = "A strong mineral acid with the molecular formula H2SO4."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:toxloss++
				M:fireloss++
				..()
				return
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
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

					if(prob(75))
						var/datum/organ/external/affecting = M:organs["head"]
						affecting.take_damage(25, 0)
						M:UpdateDamage()
						M:UpdateDamageIcon()
						M:emote("scream")
						M << "\red Your face has become disfigured!"
						M.real_name = "Unknown"
					else
						M:bruteloss += 15
				else
					M:bruteloss += 15

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/item) && prob(40))
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
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:toxloss++
				M:fireloss++
				..()
				return
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
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
						M:bruteloss += 15
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
						M:bruteloss += 15

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/item))
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M.radiation += 3
				..()
				return

		iron
			name = "Iron"
			id = "iron"
			description = "Pure iron is a metal."
			reagent_state = SOLID
/*
			on_mob_life(var/mob/M)
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

		aluminium
			name = "Aluminium"
			id = "aluminium"
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
				// Damage that is done to growing plants is separately
				// at code/game/machinery/hydroponics at obj/item/hydroponics

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if(istype(M, /mob/living/carbon))
					if(!M.wear_mask) // If not wearing a mask
						M:toxloss += 2 // 4 toxic damage per application, doubled for some reason
						//if(prob(10))
							//M.make_dizzy(1) doesn't seem to do anything


		plasma
			name = "Plasma"
			id = "plasma"
			description = "Plasma in its liquid form."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < 310)
					M.bodytemperature = max(310, M.bodytemperature-10)
				else if(M.bodytemperature > 311)
					M.bodytemperature = min(310, M.bodytemperature+10)
				..()
				return

		cryptobiolin
			name = "Cryptobiolin"
			id = "cryptobiolin"
			description = "Cryptobiolin causes confusion and dizzyness."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M.make_dizzy(1)
				if(!M.confused) M.confused = 1
				M.confused = max(M.confused, 20)
				holder.remove_reagent(src.id, 0.2)
				return

		lexorin
			name = "Lexorin"
			id = "lexorin"
			description = "Lexorin temporarily stops respiration. Causes tissue damage."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(prob(33)) M.bruteloss++
				holder.remove_reagent(src.id, 0.3)
				return

		kelotane
			name = "Kelotane"
			id = "kelotane"
			description = "Kelotane is a drug used to treat burns."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:fireloss = max(M:fireloss-2,0)
				..()
				return

		dexalin
			name = "Dexalin"
			id = "dexalin"
			description = "Dexalin is used in the treatment of oxygen deprivation."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:oxyloss = max(M:oxyloss-2, 0)
				..()
				return

		dexalinp
			name = "Dexalin Plus"
			id = "dexalinp"
			description = "Dexalin Plus is used in the treatment of oxygen deprivation. Its highly effective."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:oxyloss = 0
				..()
				return

		tricordrazine
			name = "Tricordrazine"
			id = "tricordrazine"
			description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M:oxyloss && prob(40)) M:oxyloss--
				if(M:bruteloss && prob(40)) M:bruteloss--
				if(M:fireloss && prob(40)) M:fireloss--
				if(M:toxloss && prob(40)) M:toxloss--
				..()
				return

		synaptizine
			name = "Synaptizine"
			id = "synaptizine"
			description = "Synaptizine is used to treat neuroleptic shock. Can be used to help remove disabling symptoms such as paralysis."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M:radiation && prob(80)) M:radiation--
				..()
				return

		alkysine
			name = "Alkysine"
			id = "alkysine"
			description = "Alkysine is a drug used to lessen the damage to neurological tissue after a catastrophic injury. Can heal brain tissue."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:brainloss = max(M:brainloss-3 , 0)
				..()
				return

		imidazoline
			name = "imidazoline"
			id = "imidazoline"
			description = "Heals eye damage"
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:eye_blurry = max(M:eye_blurry-5 , 0)
				M:eye_blind = max(M:eye_blind-5 , 0)
				M:sdisabilities &= 1
				..()
				return

		arithrazine
			name = "Arithrazine"
			id = "arithrazine"
			description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:radiation = max(M:radiation-3,0)
				if(M:toxloss && prob(50)) M:toxloss--
				if(prob(15)) M:bruteloss++
				..()
				return

		bicaridine
			name = "Bicaridine"
			id = "bicaridine"
			description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M:bruteloss && prob(40)) M:bruteloss--
				..()
				return

		hyperzine
			name = "Hyperzine"
			id = "hyperzine"
			description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(prob(5)) M:emote(pick("twitch","blink_r","shiver"))
				holder.remove_reagent(src.id, 0.2)
				return

		cryoxadone
			name = "Cryoxadone"
			id = "cryoxadone"
			description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < 170)
					if(M:oxyloss) M:oxyloss = max(0, M:oxyloss-3)
					if(M:bruteloss) M:bruteloss = max(0, M:bruteloss-3)
					if(M:fireloss) M:fireloss = max(0, M:fireloss-3)
					if(M:toxloss) M:toxloss = max(0, M:toxloss-3)
				..()
				return

		spaceacillin
			name = "Spaceacillin"
			id = "spaceacillin"
			description = "An all-purpose antiviral agent."
			reagent_state = LIQUID

			on_mob_life(var/mob/M)//no more mr. panacea
				holder.remove_reagent(src.id, 0.2)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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

		beer2							//copypasta of chloral hydrate, disguised as normal beer for use by emagged brobots
			name = "Beer"
			id = "beer2"
			description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
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
		/*
		addiction					//Is a generic "addiction" reagent that is produced by any chemical that is addictive.
			name = "Addiction"		//	It should never be seen by the player since it only exists inside the body.
			id = "addiction"
			description = "Raw addiction. Patented by the Robust Softdrinks Corporation."
			reagent_state = SOLID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M.reagents.has_reagent("opium") || M.reagents.has_reagent("morphine"))	//Addictive substances goes here.
					M.reagents.add_reagent("addiction", 1)	//If you if have the substance, it adds another to balance out metabolism
				else										//If you don't, you start stuffering withdrawls.
					if(!M:stuttering)
						M:stuttering = 1
					M:stuttering += 2
					M:confused += 2
					if(!data) data = 1
					switch(data)
						if(10 to 30)
							M:toxloss++
							M.make_jittery(2)
						if(31 to INFINITY)
							M:toxloss++
							M.make_jittery(10)
				..()											//It also starts working out of your system.
				return

		opium
			name = "Opium"
			id = "opium"
			description = "A mildly addictive narcotic analgesic."
			reagent_state = SOLID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(prob(50)) M:fireloss	-= 2
				if(prob(50)) M:bruteloss -= 2
				M.reagents.add_reagent("addiction", 1)		//It's addictive? A shock!
				..()
				return

		morphine
			name = "Morphine"
			id = "morphine"
			description = "A refined form of opium. It is a powerful narcotic analgesic."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(prob(50)) M:fireloss -= 5
				if(prob(50)) M:bruteloss -= 5
				M.reagents.add_reagent("addiction", 2)		//2x addictive for 3x the effect.
				var/overdose = 0
				if(!data) data = 1
				if(data > 100) overdose = 1								//Oh no! An overdose
				if(overdose == 1)
					M:toxloss += 50
					data = 0
				..()
				return
*/

/////////////////////////Food Reagents////////////////////////////
// Part of the food code. Nutriment is used instead of the old "heal_amt" code. Also is where all the food
// 	condiments, additives, and such go.
		nutriment
			name = "Nutriment"
			id = "nutriment"
			description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
			reagent_state = SOLID
			nutriment_factor = 25 * REAGENTS_METABOLISM
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(prob(50)) M:bruteloss--
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
			nutriment_factor = 5 * REAGENTS_METABOLISM
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:bodytemperature += 5
				if(prob(40)) M:fireloss++
				..()
				return

		frostoil
			name = "Frost Oil"
			id = "frostoil"
			description = "A special oil that noticably chills the body. Extraced from Icepeppers."
			reagent_state = LIQUID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:bodytemperature -= 5
				if(prob(40)) M:fireloss++
				..()
				return

		sodiumchloride
			name = "Table Salt"
			id = "sodiumchloride"
			description = "A salt made of sodium chloride. Commonly used to season food."
			reagent_state = SOLID
			nutriment_factor = 1 * REAGENTS_METABOLISM

		blackpepper
			name = "Black Pepper"
			id = "blackpepper"
			description = "A power ground from peppercorns. *AAAACHOOO*"
			reagent_state = SOLID
			nutriment_factor = 1 * REAGENTS_METABOLISM

		amatoxin
			name = "Amatoxin"
			id = "amatoxin"
			description = "A powerful poison derived from certain species of mushroom."
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:toxloss++
				..()
				return

		psilocybin
			name = "Psilocybin"
			id = "psilocybin"
			description = "A strong psycotropic derived from certain species of mushroom."
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 30)
				if(M.canmove) step(M, pick(cardinal))
				if(prob(14)) M:emote(pick("twitch","drool","moan","giggle"))
				holder.remove_reagent(src.id, 0.2)
				..()
				return

		sprinkles
			name = "Sprinkles"
			id = "sprinkles"
			description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/M)
				M:nutrition += nutriment_factor
				if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Detective"))
					if(!M) M = holder.my_atom
					M:bruteloss--
					M:fireloss--
					M:nutrition += nutriment_factor
					..()
					return
				..()

		oliveoil
			name = "Olive Oil"
			id = "oliveoil"
			description = "An oil derived from various types of olives. A famous export of Space Italy."
			reagent_state = LIQUID
			nutriment_factor = 20 * REAGENTS_METABOLISM
			on_mob_life(var/mob/M)
				M:nutrition += nutriment_factor
				..()
				return
			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 3)
					if(T:wet >= 1) return
					T:wet = 1
					if(T:wet_overlay)
						T:overlays -= T:wet_overlay
						T:wet_overlay = null
					T:wet_overlay = image('water.dmi',T,"wet_floor")
					T:overlays += T:wet_overlay

					spawn(800)
						if(T:wet >= 2) return
						T:wet = 0
						if(T:wet_overlay)
							T:overlays -= T:wet_overlay
							T:wet_overlay = null
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

		berryjuice
			name = "Berry Juice"
			id = "berryjuice"
			description = "A delicious blend of several different kinds of berries."
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:nutrition += nutriment_factor
				..()
				return


/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////// DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
		milk
			name = "Milk"
			id = "milk"
			description = "An opaque white liquid produced by the mammary glands of mammals."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M:bruteloss && prob(10)) M:bruteloss--
				M:nutrition++
				..()
				return

		soymilk
			name = "Soy Milk"
			id = "soymilk"
			description = "An opaque white liquid made from soybeans."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M:bruteloss && prob(10)) M:bruteloss--
				M:nutrition++
				..()
				return

		coffee
			name = "Coffee"
			id = "coffee"
			description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				..()
				M.dizziness = max(0,M.dizziness-5)
				M:drowsyness = max(0,M:drowsyness-3)
				M:sleeping = 0
				M.bodytemperature = min(310, M.bodytemperature+5) //310 is the normal bodytemp. 310.055
				M.make_jittery(5)
				..()
				return


		space_cola
			name = "Cola"
			id = "cola"
			description = "A refreshing beverage."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				M:drowsyness = max(0,M:drowsyness-5)
				M.bodytemperature = max(310, M.bodytemperature-5) //310 is the normal bodytemp. 310.055
				M:nutrition += 5
				..()
				return

		spacemountainwind
			name = "Space Mountain Wind"
			id = "spacemountainwind"
			description = "Blows right through you like a space wind."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				M:drowsyness = max(0,M:drowsyness-7)
				M:sleeping = 0
				M.bodytemperature = max(310, M.bodytemperature-5)
				M.make_jittery(5)
				M:nutrition += 3
				..()
				return

		thirteenloko
			name = "Thirteen Loko"
			id = "thirteenloko"
			description = "A potent mixture of caffeine and alcohol."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				M:drowsyness = max(0,M:drowsyness-7)
				M:sleeping = 0
				M.bodytemperature = max(310, M.bodytemperature-5)
				M.make_jittery(5)
				M:nutrition += 2
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
			on_mob_life(var/mob/M)
				M:drowsyness = max(0,M:drowsyness-6)
				M.bodytemperature = max(310, M.bodytemperature-5) //310 is the normal bodytemp. 310.055
				M:nutrition += 5
				..()
				return

		space_up
			name = "Space-Up"
			id = "space_up"
			description = "Tastes like a hull breach in your mouth."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				M.bodytemperature = max(310, M.bodytemperature-8) //310 is the normal bodytemp. 310.055
				M:nutrition += 2
				..()
				return

		beer
			name = "Beer"
			id = "beer"
			description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
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
					M:nutrition += 2
				..()
				return

		whiskey
			name = "Whiskey"
			id = "whiskey"
			description = "A superb and well-aged single-malt whiskey. Damn."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
				M.dizziness = max(0,M.dizziness-5)
				M:drowsyness = max(0,M:drowsyness-3)
				M:sleeping = 0
				M.bodytemperature = min(310, M.bodytemperature-5)
				..()
				return

		orangejuice
			name = "Orange juice"
			id = "orangejuice"
			description = "Both delicious AND rich in Vitamin C, what more do you need?"
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M:oxyloss && prob(30)) M:oxyloss--
				if(M:bruteloss && prob(30)) M:bruteloss--
				if(M:fireloss && prob(30)) M:fireloss--
				if(M:toxloss && prob(30)) M:toxloss--
				M:nutrition++
				..()
				return

		tomatojuice
			name = "Tomato Juice"
			id = "tomatojuice"
			description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M:oxyloss && prob(20)) M:oxyloss--
				if(M:bruteloss && prob(20)) M:bruteloss--
				if(M:fireloss && prob(20)) M:fireloss--
				if(M:toxloss && prob(20)) M:toxloss--
				M:nutrition++
				..()
				return

		limejuice
			name = "Lime Juice"
			id = "limejuice"
			description = "The sweet-sour juice of limes."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M:oxyloss && prob(20)) M:oxyloss--
				if(M:bruteloss && prob(20)) M:bruteloss--
				if(M:fireloss && prob(20)) M:fireloss--
				if(M:toxloss && prob(20)) M:toxloss--
				M:nutrition++
				..()
				return


		kahlua
			name = "Kahlua"
			id = "kahlua"
			description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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

		cream
			name = "Cream"
			id = "cream"
			description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
			reagent_state = LIQUID

		hooch
			name = "Hooch"
			id = "hooch"
			description = "Either someone's failure at cocktail making or attempt in alchohol production. In any case, do you really want to drink that?"
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
				M.dizziness = max(0,M.dizziness-5)
				M:drowsyness = max(0,M:drowsyness-3)
				M:sleeping = 0
				M.bodytemperature = min(310, M.bodytemperature-5)
				..()
				return

/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////


		gintonic
			name = "Gin and Tonic"
			id = "gintonic"
			description = "An all time classic, mild cocktail."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
				spawn(5)
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
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M:oxyloss && prob(50)) M:oxyloss -= 2
				if(M:bruteloss && prob(60)) M:bruteloss -= 2
				if(M:fireloss && prob(50)) M:fireloss -= 2
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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

		whiskeysoda
			name = "Whiskey Soda"
			id = "whiskeysoda"
			description = "Ultimate refreshment."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
			on_mob_life(var/mob/M)
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
