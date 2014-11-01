#define SOLID 1
#define LIQUID 2
#define GAS 3
#define FOOD_METABOLISM 0.4
#define REAGENTS_OVERDOSE 30
#define REM REAGENTS_EFFECT_MULTIPLIER

//Some on_mob_life() procs check for alien races.
#define IS_DIONA 1
#define IS_VOX 2

//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.


datum
	reagent
		var/name = "Reagent"
		var/id = "reagent"
		var/description = ""
		var/datum/reagents/holder = null
		var/reagent_state = SOLID
		var/list/data = null
		var/volume = 0
		var/nutriment_factor = 0
		var/custom_metabolism = REAGENTS_METABOLISM
		var/overdose = 0
		var/overdose_dam = 1
		//var/list/viruses = list()
		var/color = "#000000" // rgb: 0, 0, 0 (does not support alpha channels - yet!)

		proc
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume) //By default we have a chance to transfer some
				if(!istype(M, /mob/living))	return 0
				var/datum/reagent/self = src
				src = null										  //of the reagent to the mob on TOUCHING it.

				if(self.holder && !istype(self.holder.my_atom, /obj/effect/effect/smoke/chem))
					// If the chemicals are in a smoke cloud, do not try to let the chemicals "penetrate" into the mob's system (balance station 13) -- Doohl

					if(method == TOUCH)

						var/chance = 1
						var/block  = 0

						for(var/obj/item/clothing/C in M.get_equipped_items())
							if(C.permeability_coefficient < chance) chance = C.permeability_coefficient
							if(istype(C, /obj/item/clothing/suit/bio_suit))
								// bio suits are just about completely fool-proof - Doohl
								// kind of a hacky way of making bio suits more resistant to chemicals but w/e
								if(prob(75))
									block = 1

							if(istype(C, /obj/item/clothing/head/bio_hood))
								if(prob(75))
									block = 1

						chance = chance * 100

						if(prob(chance) && !block)
							if(M.reagents)
								M.reagents.add_reagent(self.id,self.volume/2)
				return 1

			reaction_obj(var/obj/O, var/volume) //By default we transfer a small part of the reagent to the object
				src = null						//if it can hold reagents. nope!
				//if(O.reagents)
				//	O.reagents.add_reagent(id,volume/3)
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				return

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(!istype(M, /mob/living))
					return //Noticed runtime errors from pacid trying to damage ghosts, this should fix. --NEO
				if( (overdose > 0) && (volume >= overdose))//Overdosing, wooo
					M.adjustToxLoss(overdose_dam)

				if(!holder) return
				holder.remove_reagent(src.id, custom_metabolism) //By default it slowly disappears.
				return

			on_move(var/mob/M)
				return

			// Called after add_reagents creates a new reagent.
			on_new(var/data)
				return

			// Called when two reagents of the same are mixing.
			on_merge(var/data)
				return

			on_update(var/atom/A)
				return
		muhhardcores
			name = "Hardcores"
			id = "bustanut"
			description = "Concentrated hardcore beliefs."
			reagent_state = LIQUID
			color = "#FFF000"
			custom_metabolism = 0.01
			on_mob_life(var/mob/living/M)
				if(prob(1))
					if(prob(90))
						M << "<span class='notice'>[pick("You feel quite hardcore","Coderbased is your god", "Fucking kickscammers Bustration will be the best")]."
					else
						M.say(pick("Muh hardcores.", "Falling down is a feature", "Gorrillionaires and Booty Borgs when?"))
				..()
				return
		slimejelly
			name = "Slime Jelly"
			id = "slimejelly"
			description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
			reagent_state = LIQUID
			color = "#801E28" // rgb: 128, 30, 40
			on_mob_life(var/mob/living/M as mob,var/alien)
				if(M.dna.mutantrace != "slime" || !istype(M, /mob/living/carbon/slime))
					if(prob(10))
						M << "\red Your insides are burning!"
						M.adjustToxLoss(rand(20,60)*REM)
				if(prob(40))
					M.heal_organ_damage(5*REM,0)
				..()
				return


		blood
			data = new/list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=null,"blood_colour"= "#A10808","resistances"=null,"trace_chem"=null, "antibodies" = null)
			name = "Blood"
			id = "blood"
			reagent_state = LIQUID
			color = "#C80000" // rgb: 200, 0, 0

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				var/datum/reagent/blood/self = src
				src = null
				if(self.data && self.data["viruses"])
					for(var/datum/disease/D in self.data["viruses"])
						//var/datum/disease/virus = new D.type(0, D, 1)
						// We don't spread.
						if(D.spread_type == SPECIAL || D.spread_type == NON_CONTAGIOUS) continue

						if(method == TOUCH)
							M.contract_disease(D)
						else //injected
							M.contract_disease(D, 1, 0)
				if(self.data && self.data["virus2"] && istype(M, /mob/living/carbon))//infecting...
					if(method == TOUCH)
						infect_virus2(M,self.data["virus2"], notes="(Contact with blood)")
					else
						infect_virus2(M,self.data["virus2"],1, notes="(INJECTED)") //injected, force infection!
				if(self.data && self.data["antibodies"] && istype(M, /mob/living/carbon))//... and curing
					var/mob/living/carbon/C = M
					C.antibodies |= self.data["antibodies"]

				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = M
					H.bloody_body(self.data["donor"])
					H.bloody_hands(self.data["donor"])

			on_merge(var/data)
				if(data["blood_colour"])
					color = data["blood_colour"]
				return ..()

			on_update(var/atom/A)
				if(data["blood_colour"])
					color = data["blood_colour"]
				return ..()

			reaction_turf(var/turf/simulated/T, var/volume)//splash the blood all over the place
				if(!istype(T)) return
				var/datum/reagent/blood/self = src
				src = null
				if(!(volume >= 3)) return
				//var/datum/disease/D = self.data["virus"]
				if(!self.data["donor"] || istype(self.data["donor"], /mob/living/carbon/human))
					var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T //find some blood here
					if(!blood_prop) //first blood!
						blood_prop = new(T)
						blood_prop.blood_DNA[self.data["blood_DNA"]] = self.data["blood_type"]

					for(var/datum/disease/D in self.data["viruses"])
						var/datum/disease/newVirus = D.Copy(1)
						blood_prop.viruses += newVirus

				if(!self.data["donor"] || istype(self.data["donor"], /mob/living/carbon/human))
					blood_splatter(T,self,1)
				else if(istype(self.data["donor"], /mob/living/carbon/monkey))
					var/obj/effect/decal/cleanable/blood/B = blood_splatter(T,self,1)
					if(B) B.blood_DNA["Non-Human DNA"] = "A+"
				else if(istype(self.data["donor"], /mob/living/carbon/alien))
					var/obj/effect/decal/cleanable/blood/B = blood_splatter(T,self,1)
					if(B) B.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"
				return

/* Must check the transfering of reagents and their data first. They all can point to one disease datum.

			Destroy()
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
			color = "#C81040" // rgb: 200, 16, 64

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				var/datum/reagent/vaccine/self = src
				src = null
				if(self.data&&method == INGEST)
					for(var/datum/disease/D in M.viruses)
						if(istype(D, /datum/disease/advance))
							var/datum/disease/advance/A = D
							if(A.GetDiseaseID() == self.data)
								D.cure()
						else
							if(D.type == self.data)
								D.cure()

					M.resistances += self.data
				return


		water
			name = "Water"
			id = "water"
			description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
			reagent_state = LIQUID
			color = "#0064C8" // rgb: 0, 100, 200
			custom_metabolism = 0.01

			on_mob_life(var/mob/living/M as mob,var/alien)
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.species.name=="Grey")
						if(!M) M = holder.my_atom
						M.adjustToxLoss(1*REM)
						M.take_organ_damage(0, 1*REM)
				..()
			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if(!istype(M, /mob/living))
					return

				// Put out fire
				if(method == TOUCH)
					M.adjust_fire_stacks(-(volume / 10))
					if(M.fire_stacks <= 0)
						M.ExtinguishMob()

				// Water now directly damages slimes instead of being a turf check
				if(isslime(M))
					M.adjustToxLoss(rand(15,20))

				if(istype(M,/mob/living/simple_animal/hostile/slime))
					var/mob/living/simple_animal/hostile/slime/S = M
					S.calm()

				// Grays treat water like acid.
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.species.name=="Grey")
						if(method == TOUCH)
							if(H.wear_mask)
								H << "\red Your mask protects you from the water!"
								return

							if(H.head)
								H << "\red Your helmet protects you from the water!"
								return
							if(!M.unacidable)
								if(prob(15) && volume >= 30)
									var/datum/organ/external/affecting = H.get_organ("head")
									if(affecting)
										if(affecting.take_damage(25, 0))
											H.UpdateDamageIcon()
										H.status_flags |= DISFIGURED
										H.emote("scream",,, 1)
								else
									M.take_organ_damage(min(15, volume * 2)) // uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
						else
							if(!M.unacidable)
								M.take_organ_damage(min(15, volume * 2))

					else if(H.dna.mutantrace == "slime")
						var/chance = 1
						var/block  = 0

						for(var/obj/item/clothing/C in H.get_equipped_items())
							if(C.permeability_coefficient < chance) chance = C.permeability_coefficient
							if(istype(C, /obj/item/clothing/suit/bio_suit))
								if(prob(75))
									block = 1
							if(istype(C, /obj/item/clothing/head/bio_hood))
								if(prob(50))
									block = 1

						chance = chance * 100

						if(prob(chance) && !block)
							H.adjustToxLoss(rand(1,3))

			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return
				src = null
				if(volume >= 3)
					T.wet(800)


				var/hotspot = (locate(/obj/fire) in T)
				if(hotspot && !istype(T, /turf/space))
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					qdel(hotspot)
				return
			reaction_obj(var/obj/O, var/volume)
				src = null
				var/turf/T = get_turf(O)
				var/hotspot = (locate(/obj/fire) in T)
				if(hotspot && !istype(T, /turf/space))
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					qdel(hotspot)
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
			color = "#009CA8" // rgb: 0, 156, 168
			overdose = REAGENTS_OVERDOSE

			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return
				src = null
				if(volume >= 1)
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
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom

				if(!holder) return
				M.drowsyness = max(M.drowsyness-2*REM, 0)
				if(holder.has_reagent("toxin"))
					holder.remove_reagent("toxin", 2*REM)
				if(holder.has_reagent("stoxin"))
					holder.remove_reagent("stoxin", 2*REM)
				if(holder.has_reagent("plasma"))
					holder.remove_reagent("plasma", 1*REM)
				if(holder.has_reagent("sacid"))
					holder.remove_reagent("sacid", 1*REM)
				if(holder.has_reagent("cyanide"))
					holder.remove_reagent("cyanide", 1*REM)
				if(holder.has_reagent("amatoxin"))
					holder.remove_reagent("amatoxin", 2*REM)
				if(holder.has_reagent("chloralhydrate"))
					holder.remove_reagent("chloralhydrate", 5*REM)
				if(holder.has_reagent("carpotoxin"))
					holder.remove_reagent("carpotoxin", 1*REM)
				if(holder.has_reagent("zombiepowder"))
					holder.remove_reagent("zombiepowder", 0.5*REM)
				if(holder.has_reagent("mindbreaker"))
					holder.remove_reagent("mindbreaker", 2*REM)
				M.hallucination = max(0, M.hallucination - 5*REM)
				M.adjustToxLoss(-2*REM)
				..()
				return

		phalanximine
			name = "Phalanximine"
			id = "phalanximine"
			description = "Phalanximine is a powerful chemotherapy agent."
			reagent_state = LIQUID
			color = "#1A1A1A" // rgb:idk

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustToxLoss(-2*REM)
				M.apply_effect(4*REM,IRRADIATE,0)
				..()
				return


		toxin
			name = "Toxin"
			id = "toxin"
			description = "A Toxic chemical."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0
			custom_metabolism = 0.01

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				// Toxins are really weak, but without being treated, last very long.
				M.adjustToxLoss(0.2)
				..()
				return

		plasticide
			name = "Plasticide"
			id = "plasticide"
			description = "Liquid plastic, do not eat."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0
			custom_metabolism = 0.01

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				// Toxins are really weak, but without being treated, last very long.
				M.adjustToxLoss(0.2)
				..()
				return

		cyanide
			// Fast and lethal
			name = "Cyanide"
			id = "cyanide"
			description = "A highly toxic chemical."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0
			custom_metabolism = 0.4

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustToxLoss(4)
				M.adjustOxyLoss(4)
				M.sleeping += 1
				..()
				return

		chefspecial
			// Quiet and lethal, needs atleast 4 units in the person before they'll die
			name = "Chef's Special"
			id = "chefspecial"
			description = "An extremely toxic chemical that will surely end in death."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0
			custom_metabolism = 0.39

			on_mob_life(var/mob/living/M as mob,var/alien)
				var/random = rand(150,180)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(data)
					if(0 to 5)
						..()
				if(data >= random)
					if(M.stat != DEAD)
						M.death(0)
						M.attack_log += "\[[time_stamp()]\]<font color='red'>Died a quick and painless death by <font color='green'>Chef Excellence's Special Sauce</font>.</font>"
				data++
				return

		minttoxin
			name = "Mint Toxin"
			id = "minttoxin"
			description = "Useful for dealing with undesirable customers."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0

			on_mob_life(var/mob/living/M as mob,var/alien)
				if(!M) M = holder.my_atom
				if (M_FAT in M.mutations)
					M.gib()
				..()
				return

		slimetoxin
			name = "Mutation Toxin"
			id = "mutationtoxin"
			description = "A corruptive toxin produced by slimes."
			reagent_state = LIQUID
			color = "#13BC5E" // rgb: 19, 188, 94
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M)
					M = holder.my_atom
				if(istype(M, /mob/living/carbon/human/manifested))
					M << "<span class='warning'> You can feel intriguing reagents seeping into your body, but they don't seem to react at all.</span>"
					M.reagents.del_reagent("mutationtoxin")
					..()
					return
				if(ishuman(M))
					var/mob/living/carbon/human/human = M
					if(human.dna.mutantrace == null)
						M << "\red Your flesh rapidly mutates!"
						human.dna.mutantrace = "slime"
						human.update_mutantrace()
				..()
				return

		aslimetoxin
			name = "Advanced Mutation Toxin"
			id = "amutationtoxin"
			description = "An advanced corruptive toxin produced by slimes."
			reagent_state = LIQUID
			color = "#13BC5E" // rgb: 19, 188, 94
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(istype(M, /mob/living/carbon) && M.stat != DEAD)
					if(istype(M, /mob/living/carbon/human/manifested))
						M << "<span class='warning'> You can feel intriguing reagents seeping into your body, but they don't seem to react at all.</span>"
						M.reagents.del_reagent("amutationtoxin")
						..()
						return
					else
						M << "<span class='warning'> Your flesh rapidly mutates!</span>"
						if(M.monkeyizing)	return
						M.monkeyizing = 1
						M.canmove = 0
						M.icon = null
						M.overlays.Cut()
						M.invisibility = 101
						for(var/obj/item/W in M)
							if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
								del(W)
								continue
							W.layer = initial(W.layer)
							W.loc = M.loc
							W.dropped(M)
						var/mob/living/carbon/slime/new_mob = new /mob/living/carbon/slime(M.loc)
						new_mob.a_intent = "hurt"
						new_mob.universal_speak = 1
						if(M.mind)
							M.mind.transfer_to(new_mob)
						else
							new_mob.key = M.key
						del(M)
				..()
				return

		stoxin
			name = "Sleep Toxin"
			id = "stoxin"
			description = "An effective hypnotic used to treat insomnia."
			reagent_state = LIQUID
			color = "#E895CC" // rgb: 232, 149, 204

			custom_metabolism = 0.1

			on_mob_life(var/mob/living/M as mob,var/alien)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(data)
					if(1 to 15)
						M.eye_blurry = max(M.eye_blurry, 10)
					if(15 to 25)
						M.drowsyness  = max(M.drowsyness, 20)
					if(25 to INFINITY)
						M.Paralyse(20)
						M.drowsyness  = max(M.drowsyness, 30)
				data++
				..()
				return

		srejuvenate
			name = "Soporific Rejuvenant"
			id = "stoxin2"
			description = "Put people to sleep, and heals them."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
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
						M.drowsyness  = max(M.drowsyness, 20)
					if(25 to INFINITY)
						M.sleeping += 1
						M.adjustOxyLoss(-M.getOxyLoss())
						M.SetWeakened(0)
						M.SetStunned(0)
						M.SetParalysis(0)
						M.dizziness = 0
						M.drowsyness = 0
						M.stuttering = 0
						M.confused = 0
						M.jitteriness = 0
				..()
				return

		inaprovaline
			name = "Inaprovaline"
			id = "inaprovaline"
			description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE*2

			on_mob_life(var/mob/living/M as mob, var/alien)

				if(!holder) return
				if(!M) M = holder.my_atom

				if(alien && alien == IS_VOX)
					M.adjustToxLoss(REAGENTS_METABOLISM)
				else
					if(M.losebreath >= 10)
						M.losebreath = max(10, M.losebreath-5)

				holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
				return

		space_drugs
			name = "Space drugs"
			id = "space_drugs"
			description = "An illegal chemical compound used as drug."
			reagent_state = LIQUID
			color = "#60A584" // rgb: 96, 165, 132
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				if(isturf(M.loc) && !istype(M.loc, /turf/space))
					if(M.canmove && !M.restrained())
						if(prob(10)) step(M, pick(cardinal))
				if(prob(7)) M.emote(pick("twitch","drool","moan","giggle"))
				holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
				return

		holywater
			name = "Holy Water"
			id = "holywater"
			description = "An ashen-obsidian-water mix, this solution will alter certain sections of the brain's rationality."
			reagent_state = LIQUID
			color = "#0064C8" // rgb: 0, 100, 200


			reaction_obj(var/obj/O, var/volume)
				if(volume>=1)
					O.blessed=1

			on_mob_life(var/mob/living/M as mob,var/alien)

				if(!holder) return
				if(ishuman(M))
					if((M.mind in ticker.mode.cult) && prob(10))
						M << "\blue A cooling sensation from inside you brings you an untold calmness."
						ticker.mode.remove_cultist(M.mind)
						for(var/mob/O in viewers(M, null))
							O.show_message(text("\blue []'s eyes blink and become clearer.", M), 1) // So observers know it worked.
					// Vamps react to this like acid
					if(((M.mind in ticker.mode.vampires) || M.mind.vampire) && prob(10))
						if(!(VAMP_FULL in M.mind.vampire.powers))
							if(!M) M = holder.my_atom
							M.adjustToxLoss(1*REM)
							M.take_organ_damage(0, 1*REM)
				holder.remove_reagent(src.id, 10 * REAGENTS_METABOLISM) //high metabolism to prevent extended uncult rolls.

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with water can help put them out!
				// Vamps react to this like acid
				if(ishuman(M))
					if((M.mind in ticker.mode.vampires))
						if(!(VAMP_FULL in M.mind.vampire.powers))
							var/mob/living/carbon/human/H=M
							if(method == TOUCH)
								if(H.wear_mask)
									H << "\red Your mask protects you from the holy water!"
									return

								if(H.head)
									H << "\red Your helmet protects you from the holy water!"
									return
								if(!M.unacidable)
									if(prob(15) && volume >= 30)
										var/datum/organ/external/affecting = H.get_organ("head")
										if(affecting)
											if(affecting.take_damage(25, 0))
												H.UpdateDamageIcon()
											H.status_flags |= DISFIGURED
											H.emote("scream",,, 1)
									else
										M.take_organ_damage(min(15, volume * 2)) // uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
						else
							if(!M.unacidable)
								M.take_organ_damage(min(15, volume * 2))
				return

		serotrotium
			name = "Serotrotium"
			id = "serotrotium"
			description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
			reagent_state = LIQUID
			color = "#202040" // rgb: 20, 20, 40
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(ishuman(M))
					if(prob(7)) M.emote(pick("twitch","drool","moan","gasp"))
					holder.remove_reagent(src.id, 0.25 * REAGENTS_METABOLISM)
				return

/*		silicate
			name = "Silicate"
			id = "silicate"
			description = "A compound that can be used to reinforce glass."
			reagent_state = LIQUID
			color = "#C7FFFF" // rgb: 199, 255, 255

			reaction_obj(var/obj/O, var/volume)
				src = null
				if(istype(O,/obj/structure/window))
					if(O:silicate <= 200)

						O:silicate += volume
						O:health += volume * 3

						if(!O:silicateIcon)
							var/icon/I = icon(O.icon,O.icon_state,O.dir)

							var/r = (volume / 100) + 1
							var/g = (volume / 70) + 1
							var/b = (volume / 50) + 1
							I.SetIntensity(r,g,b)
							O.icon = I
							O:silicateIcon = I
						else
							var/icon/I = O:silicateIcon

							var/r = (volume / 100) + 1
							var/g = (volume / 70) + 1
							var/b = (volume / 50) + 1
							I.SetIntensity(r,g,b)
							O.icon = I
							O:silicateIcon = I

				return*/

		oxygen
			name = "Oxygen"
			id = "oxygen"
			description = "A colorless, odorless gas."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

			on_mob_life(var/mob/living/M as mob, var/alien)

				if(!holder) return
				if(M.stat == 2) return
				if(alien && alien == IS_VOX)
					M.adjustToxLoss(REAGENTS_METABOLISM)
					holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
					return
				..()

		copper
			name = "Copper"
			id = "copper"
			description = "A highly ductile metal."
			color = "#6E3B08" // rgb: 110, 59, 8

			custom_metabolism = 0.01

		nitrogen
			name = "Nitrogen"
			id = "nitrogen"
			description = "A colorless, odorless, tasteless gas."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

			on_mob_life(var/mob/living/M as mob, var/alien)

				if(!holder) return
				if(M.stat == 2) return
				if(alien && alien == IS_VOX)
					M.adjustOxyLoss(-2*REM)
					M.adjustToxLoss(-2*REM)
					holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
					return
				..()

		hydrogen
			name = "Hydrogen"
			id = "hydrogen"
			description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

		potassium
			name = "Potassium"
			id = "potassium"
			description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
			reagent_state = SOLID
			color = "#A0A0A0" // rgb: 160, 160, 160

			custom_metabolism = 0.01

		mercury
			name = "Mercury"
			id = "mercury"
			description = "A chemical element."
			reagent_state = LIQUID
			color = "#484848" // rgb: 72, 72, 72
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
					step(M, pick(cardinal))
				if(prob(5)) M.emote(pick("twitch","drool","moan"))
				M.adjustBrainLoss(2)
				..()
				return

		sulfur
			name = "Sulfur"
			id = "sulfur"
			description = "A chemical element with a pungent smell."
			reagent_state = SOLID
			color = "#BF8C00" // rgb: 191, 140, 0

			custom_metabolism = 0.01

		carbon
			name = "Carbon"
			id = "carbon"
			description = "A chemical element, the builing block of life."
			reagent_state = SOLID
			color = "#1C1300" // rgb: 30, 20, 0

			custom_metabolism = 0.01

			reaction_turf(var/turf/T, var/volume)
				src = null
				// Only add one dirt per turf.  Was causing people to crash.
				if(!istype(T, /turf/space) && !(locate(/obj/effect/decal/cleanable/dirt) in T))
					new /obj/effect/decal/cleanable/dirt(T)

		chlorine
			name = "Chlorine"
			id = "chlorine"
			description = "A chemical element with a characteristic odour."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.take_organ_damage(1*REM, 0)
				..()
				return

		fluorine
			name = "Fluorine"
			id = "fluorine"
			description = "A highly-reactive chemical element."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1*REM)
				..()
				return

		sodium
			name = "Sodium"
			id = "sodium"
			description = "A chemical element, readily reacts with water."
			reagent_state = SOLID
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

		phosphorus
			name = "Phosphorus"
			id = "phosphorus"
			description = "A chemical element, the backbone of biological energy carriers."
			reagent_state = SOLID
			color = "#832828" // rgb: 131, 40, 40

			custom_metabolism = 0.01

		lithium
			name = "Lithium"
			id = "lithium"
			description = "A chemical element, used as antidepressant."
			reagent_state = SOLID
			color = "#808080" // rgb: 128, 128, 128
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
					step(M, pick(cardinal))
				if(prob(5)) M.emote(pick("twitch","drool","moan"))
				..()
				return

		sugar
			name = "Sugar"
			id = "sugar"
			description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
			reagent_state = SOLID
			color = "#FFFFFF" // rgb: 255, 255, 255

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += 1*REM
				..()
				return

		sacid
			name = "Sulphuric acid"
			id = "sacid"
			description = "A strong mineral acid with the molecular formula H2SO4."
			reagent_state = LIQUID
			color = "#DB5008" // rgb: 219, 80, 8

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom

				if(ishuman(M))
					var/mob/living/carbon/human/H=M
					if(H.species.name=="Grey")
						..()
						return // Greys lurve dem some sacid

				M.adjustToxLoss(1*REM)
				M.take_organ_damage(0, 1*REM)
				..()
				return
			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M

						if(H.wear_mask)
							if(!H.wear_mask.unacidable)
								del (H.wear_mask)
								H.update_inv_wear_mask()
								H << "\red Your mask melts away but protects you from the acid!"
							else
								H << "\red Your mask protects you from the acid!"
							return

						if(H.head && !istype(H.head, /obj/item/weapon/reagent_containers/glass/bucket))
							if(prob(15) && !H.head.unacidable)
								del(H.head)
								H.update_inv_head()
								H << "\red Your helmet melts away but protects you from the acid"
							else
								H << "\red Your helmet protects you from the acid!"
							return

					else if(ismonkey(M))
						var/mob/living/carbon/monkey/MK = M
						if(MK.wear_mask)
							if(!MK.wear_mask.unacidable)
								del (MK.wear_mask)
								MK.update_inv_wear_mask()
								MK << "\red Your mask melts away but protects you from the acid!"
							else
								MK << "\red Your mask protects you from the acid!"
							return

					if(!M.unacidable)
						if(prob(15) && istype(M, /mob/living/carbon/human) && volume >= 30)
							var/mob/living/carbon/human/H = M
							if(H.species.name=="Grey")
								..()
								return // Greys lurve dem some sacid
							var/datum/organ/external/affecting = H.get_organ("head")
							if(affecting)
								if(affecting.take_damage(25, 0))
									H.UpdateDamageIcon()
								H.status_flags |= DISFIGURED
								H.emote("scream",,, 1)
						else
							M.take_organ_damage(min(15, volume * 2)) // uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
				else
					if(!M.unacidable)
						if(ishuman(M))
							var/mob/living/carbon/human/H = M
							if(H.species.name=="Grey")
								..()
								return // Greys lurve dem some sacid
						M.take_organ_damage(min(15, volume * 2))

			reaction_obj(var/obj/O, var/volume)
				if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)) && prob(10))
					if(!O.unacidable)
						var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
						I.desc = "Looks like this was \an [O] some time ago."
						for(var/mob/M in viewers(5, O))
							M << "\red \the [O] melts."
						del(O)

		pacid
			name = "Polytrinic acid"
			id = "pacid"
			description = "Polytrinic acid is a an extremely corrosive chemical substance."
			reagent_state = LIQUID
			color = "#8E18A9" // rgb: 142, 24, 169

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1*REM)
				..()
				return

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if(!istype(M, /mob/living))
					return //wooo more runtime fixin
				if(method == TOUCH)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M

						if(H.wear_mask)
							if(!H.wear_mask.unacidable)
								del (H.wear_mask)
								H.update_inv_wear_mask()
								H << "\red Your mask melts away but protects you from the acid!"
							else
								H << "\red Your mask protects you from the acid!"
							return

						if(H.head && !istype(H.head, /obj/item/weapon/reagent_containers/glass/bucket))
							if(prob(15) && !H.head.unacidable)
								del(H.head)
								H.update_inv_head()
								H << "\red Your helmet melts away but protects you from the acid"
							else
								H << "\red Your helmet protects you from the acid!"
							return

						if(!H.unacidable)
							var/datum/organ/external/affecting = H.get_organ("head")
							if(affecting.take_damage(15, 0))
								H.UpdateDamageIcon()
							H.emote("scream",,, 1)
					else if(ismonkey(M))
						var/mob/living/carbon/monkey/MK = M

						if(MK.wear_mask)
							if(!MK.wear_mask.unacidable)
								del (MK.wear_mask)
								MK.update_inv_wear_mask()
								MK << "\red Your mask melts away but protects you from the acid!"
							else
								MK << "\red Your mask protects you from the acid!"
							return

						if(!MK.unacidable)
							MK.take_organ_damage(min(15, volume * 4)) // same deal as sulphuric acid
				else
					if(!M.unacidable)
						if(ishuman(M))
							var/mob/living/carbon/human/H = M
							var/datum/organ/external/affecting = H.get_organ("head")
							if(affecting.take_damage(15, 0))
								H.UpdateDamageIcon()
							H.emote("scream",,, 1)
							H.status_flags |= DISFIGURED
						else
							M.take_organ_damage(min(15, volume * 4))

			reaction_obj(var/obj/O, var/volume)
				if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)))
					if(!O.unacidable)
						var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
						I.desc = "Looks like this was \an [O] some time ago."
						for(var/mob/M in viewers(5, O))
							M << "\red \the [O] melts."
						del(O)

		glycerol
			name = "Glycerol"
			id = "glycerol"
			description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
			reagent_state = LIQUID
			color = "#808080" // rgb: 128, 128, 128
			custom_metabolism = 0.01

		nitroglycerin
			name = "Nitroglycerin"
			id = "nitroglycerin"
			description = "Nitroglycerin is a heavy, colorless, oily, explosive liquid obtained by nitrating glycerol."
			reagent_state = LIQUID
			color = "#808080" // rgb: 128, 128, 128
			custom_metabolism = 0.01

		radium
			name = "Radium"
			id = "radium"
			description = "Radium is an alkaline earth metal. It is extremely radioactive."
			reagent_state = SOLID
			color = "#C7C7C7" // rgb: 199,199,199

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.apply_effect(2*REM,IRRADIATE,0)
				// radium may increase your chances to cure a disease
				if(istype(M,/mob/living/carbon)) // make sure to only use it on carbon mobs
					var/mob/living/carbon/C = M
					if(C.virus2.len)
						for (var/ID in C.virus2)
							var/datum/disease2/disease/V = C.virus2[ID]
							if(prob(5))
								if(prob(50))
									M.radiation += 50 // curing it that way may kill you instead
									M.adjustToxLoss(100)
								M:antibodies |= V.antigen
				..()
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 3)
					if(!istype(T, /turf/space))
						new /obj/effect/decal/cleanable/greenglow(T)
						return


		ryetalyn
			name = "Ryetalyn"
			id = "ryetalyn"
			description = "Ryetalyn can cure all genetic abnomalities."
			reagent_state = SOLID
			color = "#C8A5DC" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom

				var/needs_update = M.mutations.len > 0
				if(ishuman(M))
					M:hulk_time = 0
				for(var/datum/dna/gene/G in dna_genes)
					if(G.is_active(M))
						if(G.name == "Hulk" && ishuman(M))
							G.OnMobLife(M)
						G.deactivate(M)
				M.alpha = 255
				M.mutations = list()
				M.active_genes = list()

				M.disabilities = 0
				M.sdisabilities = 0

				// Might need to update appearance for hulk etc.
				if(needs_update && ishuman(M))
					var/mob/living/carbon/human/H = M
					H.update_mutations()

				..()
				return

		thermite
			name = "Thermite"
			id = "thermite"
			description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
			reagent_state = SOLID
			color = "#673910" // rgb: 103, 57, 16

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 5)
					if(istype(T, /turf/simulated/wall))
						T:thermite = 1
						T.overlays.Cut()
						T.overlays = image('icons/effects/effects.dmi',icon_state = "thermite")
				return

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.adjustFireLoss(1)
				..()
				return

		paracetamol
			name = "Paracetamol"
			id = "paracetamol"
			description = "Most probably know this as Tylenol, but this chemical is a mild, simple painkiller."
			reagent_state = LIQUID
			color = "#C855DC"
			overdose_dam = 0
			overdose = 60

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if (volume > overdose)
					M.hallucination = max(M.hallucination, 2)

		mutagen
			name = "Unstable mutagen"
			id = "mutagen"
			description = "Might cause unpredictable mutations. Keep away from children."
			reagent_state = LIQUID
			color = "#13BC5E" // rgb: 19, 188, 94

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if(!..())	return
				if(!M.dna) return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
				src = null
				if((method==TOUCH && prob(33)) || method==INGEST)
					randmuti(M)
					if(prob(98))
						randmutb(M)
					else
						randmutg(M)
					domutcheck(M, null)
					M.UpdateAppearance()
				return
			on_mob_life(var/mob/living/M as mob)
				if(!M.dna) return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
				if(!M) M = holder.my_atom
				M.apply_effect(10,IRRADIATE,0)
				..()
				return

		tramadol
			name = "Tramadol"
			id = "tramadol"
			description = "A simple, yet effective painkiller."
			reagent_state = LIQUID
			color = "#C8A5DC"

		oxycodone
			name = "Oxycodone"
			id = "oxycodone"
			description = "An effective and very addictive painkiller."
			reagent_state = LIQUID
			color = "#C805DC"

		virus_food
			name = "Virus Food"
			id = "virusfood"
			description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
			reagent_state = LIQUID
			nutriment_factor = 2 * REAGENTS_METABOLISM
			color = "#899613" // rgb: 137, 150, 19

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.nutrition += nutriment_factor*REM
				..()
				return

		sterilizine
			name = "Sterilizine"
			id = "sterilizine"
			description = "Sterilizes wounds in preparation for surgery."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
	/*		reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				src = null
				if (method==TOUCH)
					if(istype(M, /mob/living/carbon/human))
						if(M.health >= -100 && M.health <= 0)
							M.crit_op_stage = 0.0
				if (method==INGEST)
					usr << "Well, that was stupid."
					M.adjustToxLoss(3)
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
			color = "#C8A5DC" // rgb: 200, 165, 220
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
			color = "#F7C430" // rgb: 247, 196, 48

		silver
			name = "Silver"
			id = "silver"
			description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
			reagent_state = SOLID
			color = "#D0D0D0" // rgb: 208, 208, 208

		uranium
			name ="Uranium"
			id = "uranium"
			description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
			reagent_state = SOLID
			color = "#B8B8C0" // rgb: 184, 184, 192

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.apply_effect(1,IRRADIATE,0)
				..()
				return


			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 3)
					if(!istype(T, /turf/space))
						new /obj/effect/decal/cleanable/greenglow(T)

		aluminum
			name = "Aluminum"
			id = "aluminum"
			description = "A silvery white and ductile member of the boron group of chemical elements."
			reagent_state = SOLID
			color = "#A8A8A8" // rgb: 168, 168, 168

		silicon
			name = "Silicon"
			id = "silicon"
			description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
			reagent_state = SOLID
			color = "#A8A8A8" // rgb: 168, 168, 168

		fuel
			name = "Welding fuel"
			id = "fuel"
			description = "Required for welders. Flamable."
			reagent_state = LIQUID
			color = "#660000" // rgb: 102, 0, 0


			reaction_obj(var/obj/O, var/volume)
				var/turf/the_turf = get_turf(O)
				if(!the_turf)
					return //No sense trying to start a fire if you don't have a turf to set on fire. --NEO
				new /obj/effect/decal/cleanable/liquid_fuel(the_turf, volume)
			reaction_turf(var/turf/T, var/volume)
				new /obj/effect/decal/cleanable/liquid_fuel(T, volume)
				return
			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1)
				..()
				return


		space_cleaner
			name = "Space cleaner"
			id = "cleaner"
			description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
			reagent_state = LIQUID
			color = "#A5F0EE" // rgb: 165, 240, 238

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/effect/decal/cleanable))
					qdel(O)
				else
					if(O)
						O.clean_blood()
			reaction_turf(var/turf/T, var/volume)
				if(volume >= 1)
					T.overlays.Cut()
					T.clean_blood()
					for(var/obj/effect/decal/cleanable/C in src)
						qdel(C)

					for(var/mob/living/carbon/slime/M in T)
						M.adjustToxLoss(rand(5,10))

					for(var/mob/living/carbon/human/H in T)
						if(H.dna.mutantrace == "slime")
							H.adjustToxLoss(rand(0.5,1))

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)

				if(!holder) return
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					if(C.r_hand)
						C.r_hand.clean_blood()
					if(C.l_hand)
						C.l_hand.clean_blood()
					if(C.wear_mask)
						if(C.wear_mask.clean_blood())
							C.update_inv_wear_mask(0)
					if(ishuman(M))
						var/mob/living/carbon/human/H = C
						if(H.head)
							if(H.head.clean_blood())
								H.update_inv_head(0)
						if(H.wear_suit)
							if(H.wear_suit.clean_blood())
								H.update_inv_wear_suit(0)
						else if(H.w_uniform)
							if(H.w_uniform.clean_blood())
								H.update_inv_w_uniform(0)
						if(H.shoes)
							if(H.shoes.clean_blood())
								H.update_inv_shoes(0)
					M.clean_blood()

		//Reagents used for plant fertilizers.
		toxin/fertilizer
			name = "fertilizer"
			id = "fertilizer"
			description = "A chemical mix good for growing plants with."
			reagent_state = LIQUID

			color = "#664330" // rgb: 102, 67, 48

		toxin/fertilizer/eznutrient
			name = "EZ Nutrient"
			id = "eznutrient"

		toxin/fertilizer/left4zed
			name = "Left-4-Zed"
			id = "left4zed"

		toxin/fertilizer/robustharvest
			name = "Robust Harvest"
			id = "robustharvest"

		toxin/plantbgone
			name = "Plant-B-Gone"
			id = "plantbgone"
			description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
			reagent_state = LIQUID
			color = "#49002E" // rgb: 73, 0, 46


			// Clear off wallrot fungi
			reaction_turf(var/turf/T, var/volume)
				if(istype(T, /turf/simulated/wall))
					var/turf/simulated/wall/W = T
					if(W.rotting)
						W.rotting = 0
						for(var/obj/effect/E in W) if(E.name == "Wallrot") del E

						for(var/mob/O in viewers(W, null))
							O.show_message(text("\blue The fungi are completely dissolved by the solution!"), 1)

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/effect/alien/weeds/))
					var/obj/effect/alien/weeds/alien_weeds = O
					alien_weeds.health -= rand(15,35) // Kills alien weeds pretty fast
					alien_weeds.healthcheck()
				else if(istype(O,/obj/effect/glowshroom)) //even a small amount is enough to kill it
					del(O)
				else if(istype(O,/obj/effect/plantsegment))
					if(prob(50)) del(O) //Kills kudzu too.
				else if(istype(O,/obj/machinery/portable_atmospherics/hydroponics))
					var/obj/machinery/portable_atmospherics/hydroponics/tray = O

					if(tray.seed)
						tray.health -= rand(30,50)
						if(tray.pestlevel > 0)
							tray.pestlevel -= 2
						if(tray.weedlevel > 0)
							tray.weedlevel -= 3
						tray.toxins += 4
						tray.check_level_sanity()
						tray.update_icon()

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				src = null
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					if(!C.wear_mask) // If not wearing a mask
						C.adjustToxLoss(2) // 4 toxic damage per application, doubled for some reason
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.dna)
							if(H.species.flags & IS_PLANT) //plantmen take a LOT of damage
								H.adjustToxLoss(50)

		plasma
			name = "Plasma"
			id = "plasma"
			description = "Plasma in its liquid form."
			reagent_state = LIQUID
			color = "#E71B00" // rgb: 231, 27, 0

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(holder.has_reagent("inaprovaline"))
					holder.remove_reagent("inaprovaline", 2*REM)
				M.adjustToxLoss(3*REM)
				..()
				return
			reaction_obj(var/obj/O, var/volume)
				src = null
				/*if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg/slime))
					var/obj/item/weapon/reagent_containers/food/snacks/egg/slime/egg = O
					if (egg.grown)
						egg.Hatch()*/
				if((!O) || (!volume))	return 0
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
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(M.bodytemperature > 310)
					M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
				else if(M.bodytemperature < 311)
					M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
				..()
				return

		cryptobiolin
			name = "Cryptobiolin"
			id = "cryptobiolin"
			description = "Cryptobiolin causes confusion and dizzyness."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.make_dizzy(1)
				if(!M.confused) M.confused = 1
				M.confused = max(M.confused, 20)
				holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
				..()
				return

		lexorin
			name = "Lexorin"
			id = "lexorin"
			description = "Lexorin temporarily stops respiration. Causes tissue damage."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(prob(33))
					M.take_organ_damage(1*REM, 0)
				M.adjustOxyLoss(3)
				if(prob(20)) M.emote("gasp")
				..()
				return

		kelotane
			name = "Kelotane"
			id = "kelotane"
			description = "Kelotane is a drug used to treat burns."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				M.heal_organ_damage(0,2*REM)
				..()
				return

		dermaline
			name = "Dermaline"
			id = "dermaline"
			description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(M.stat == 2.0) //THE GUY IS **DEAD**! BEREFT OF ALL LIFE HE RESTS IN PEACE etc etc. He does NOT metabolise shit anymore, god DAMN
					return
				if(!M) M = holder.my_atom
				M.heal_organ_damage(0,3*REM)
				..()
				return

		dexalin
			name = "Dexalin"
			id = "dexalin"
			description = "Dexalin is used in the treatment of oxygen deprivation."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(M.stat == 2.0)
					return  //See above, down and around. --Agouri
				if(!M) M = holder.my_atom
				M.adjustOxyLoss(-2*REM)
				if(holder.has_reagent("lexorin"))
					holder.remove_reagent("lexorin", 2*REM)
				..()
				return

		dexalinp
			name = "Dexalin Plus"
			id = "dexalinp"
			description = "Dexalin Plus is used in the treatment of oxygen deprivation. Its highly effective."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				M.adjustOxyLoss(-M.getOxyLoss())
				if(holder.has_reagent("lexorin"))
					holder.remove_reagent("lexorin", 2*REM)
				..()
				return

		tricordrazine
			name = "Tricordrazine"
			id = "tricordrazine"
			description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(M.getOxyLoss() && prob(80)) M.adjustOxyLoss(-1*REM)
				if(M.getBruteLoss() && prob(80)) M.heal_organ_damage(1*REM,0)
				if(M.getFireLoss() && prob(80)) M.heal_organ_damage(0,1*REM)
				if(M.getToxLoss() && prob(80)) M.adjustToxLoss(-1*REM)
				..()
				return

		adminordrazine //An OP chemical for admins
			name = "Adminordrazine"
			id = "adminordrazine"
			description = "It's magic. We don't have to explain it."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/carbon/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom ///This can even heal dead people.
				M.setCloneLoss(0)
				M.setOxyLoss(0)
				M.radiation = 0
				M.heal_organ_damage(5,5)
				M.adjustToxLoss(-5)
				if(holder.has_reagent("toxin"))
					holder.remove_reagent("toxin", 5)
				if(holder.has_reagent("stoxin"))
					holder.remove_reagent("stoxin", 5)
				if(holder.has_reagent("plasma"))
					holder.remove_reagent("plasma", 5)
				if(holder.has_reagent("sacid"))
					holder.remove_reagent("sacid", 5)
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
				if(holder.has_reagent("mindbreaker"))
					holder.remove_reagent("mindbreaker", 5)
				M.hallucination = 0
				M.setBrainLoss(0)
				M.disabilities = 0
				M.sdisabilities = 0
				M.eye_blurry = 0
				M.eye_blind = 0
//				M.disabilities &= ~NEARSIGHTED		//doesn't even do anythig cos of the disabilities = 0 bit
//				M.sdisabilities &= ~BLIND			//doesn't even do anythig cos of the sdisabilities = 0 bit
				M.SetWeakened(0)
				M.SetStunned(0)
				M.SetParalysis(0)
				M.silent = 0
				M.dizziness = 0
				M.drowsyness = 0
				M.stuttering = 0
				M.confused = 0
				M.sleeping = 0
				M.jitteriness = 0
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
			description = "Synaptizine is used to treat various diseases."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			custom_metabolism = 0.01
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.drowsyness = max(M.drowsyness-5, 0)
				M.AdjustParalysis(-1)
				M.AdjustStunned(-1)
				M.AdjustWeakened(-1)
				if(holder.has_reagent("mindbreaker"))
					holder.remove_reagent("mindbreaker", 5)
				M.hallucination = max(0, M.hallucination - 10)
				if(prob(60))	M.adjustToxLoss(1)
				..()
				return

		impedrezene
			name = "Impedrezene"
			id = "impedrezene"
			description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.jitteriness = max(M.jitteriness-5,0)
				if(prob(80)) M.adjustBrainLoss(1*REM)
				if(prob(50)) M.drowsyness = max(M.drowsyness, 3)
				if(prob(10)) M.emote("drool")
				..()
				return

		hyronalin
			name = "Hyronalin"
			id = "hyronalin"
			description = "Hyronalin is a medicinal drug used to counter the effect of radiation poisoning."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			custom_metabolism = 0.05
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.radiation = max(M.radiation-3*REM,0)
				..()
				return

		arithrazine
			name = "Arithrazine"
			id = "arithrazine"
			description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			custom_metabolism = 0.05
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(M.stat == 2.0)
					return  //See above, down and around. --Agouri
				if(!M) M = holder.my_atom
				M.radiation = max(M.radiation-7*REM,0)
				M.adjustToxLoss(-1*REM)
				if(prob(15))
					M.take_organ_damage(1, 0)
				..()
				return

		alkysine
			name = "Alkysine"
			id = "alkysine"
			description = "Alkysine is a drug used to lessen the damage to neurological tissue after a catastrophic injury. Can heal brain tissue."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			custom_metabolism = 0.05
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.adjustBrainLoss(-3*REM)
				..()
				return

		imidazoline
			name = "Imidazoline"
			id = "imidazoline"
			description = "Heals eye damage"
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.eye_blurry = max(M.eye_blurry-5 , 0)
				M.eye_blind = max(M.eye_blind-5 , 0)
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
					if(E && istype(E))
						if(E.damage > 0)
							E.damage -= 1
				..()
				return

		inacusiate
			name = "Inacusiate"
			id = "inacusiate"
			description = "Rapidly heals ear damage"
			reagent_state = LIQUID
			color = "#6600FF" // rgb: 100, 165, 255
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.ear_damage = 0
				M.ear_deaf = 0
				..()
				return

		peridaxon
			name = "Peridaxon"
			id = "peridaxon"
			description = "Used to encourage recovery of internal organs and nervous systems. Medicate cautiously."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			overdose = 10

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					var/datum/organ/external/chest/C = H.get_organ("chest")
					for(var/datum/organ/internal/I in C.internal_organs)
						if(I.damage > 0)
							I.damage -= 0.20
				..()
				return

		bicaridine
			name = "Bicaridine"
			id = "bicaridine"
			description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob, var/alien)

				if(!holder) return
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(alien != IS_DIONA)
					M.heal_organ_damage(2*REM,0)
				..()
				return

		hyperzine
			name = "Hyperzine"
			id = "hyperzine"
			description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			custom_metabolism = 0.03
			overdose = REAGENTS_OVERDOSE/2

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(prob(5)) M.emote(pick("twitch","blink_r","shiver"))
				..()
				return

		cryoxadone
			name = "Cryoxadone"
			id = "cryoxadone"
			description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(M.bodytemperature < 170)
					M.adjustCloneLoss(-1)
					M.adjustOxyLoss(-1)
					M.heal_organ_damage(1,1)
					M.adjustToxLoss(-1)
				..()
				return

		clonexadone
			name = "Clonexadone"
			id = "clonexadone"
			description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' the cloning process when used in conjunction with a cryo tube."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(M.bodytemperature < 170)
					M.adjustCloneLoss(-3)
					M.adjustOxyLoss(-3)
					M.heal_organ_damage(3,3)
					M.adjustToxLoss(-3)
				..()
				return

		rezadone
			name = "Rezadone"
			id = "rezadone"
			description = "A powder derived from fish toxin, this substance can effectively treat genetic damage in humanoids, though excessive consumption has side effects."
			reagent_state = SOLID
			color = "#669900" // rgb: 102, 153, 0
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(!data) data = 1
				data++
				switch(data)
					if(1 to 15)
						M.adjustCloneLoss(-1)
						M.heal_organ_damage(1,1)
					if(15 to 35)
						M.adjustCloneLoss(-2)
						M.heal_organ_damage(2,1)
						M.status_flags &= ~DISFIGURED
					if(35 to INFINITY)
						M.adjustToxLoss(1)
						M.make_dizzy(5)
						M.make_jittery(5)

				..()
				return

		spaceacillin
			name = "Spaceacillin"
			id = "spaceacillin"
			description = "An all-purpose antiviral agent."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			custom_metabolism = 0.01
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				..()
				return

		carpotoxin
			name = "Carpotoxin"
			id = "carpotoxin"
			description = "A deadly neurotoxin produced by the dreaded spess carp."
			reagent_state = LIQUID
			color = "#003333" // rgb: 0, 51, 51

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.adjustToxLoss(2*REM)
				..()
				return

		zombiepowder
			name = "Zombie Powder"
			id = "zombiepowder"
			description = "A strong neurotoxin that puts the subject into a death-like state."
			color = "#669900" // rgb: 102, 153, 0

			on_mob_life(var/mob/living/carbon/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(volume >= 1) //Hotfix for Fakedeath never ending.
					M.status_flags |= FAKEDEATH
				else
					M.status_flags &= ~FAKEDEATH
				M.adjustOxyLoss(0.5*REM)
				M.adjustToxLoss(0.5*REM)
				M.Weaken(10)
				M.silent = max(M.silent, 10)
				M.tod = worldtime2text()
				..()
				return

			/*Del()
				if(holder && ismob(holder.my_atom))
					var/mob/M = holder.my_atom
					M.status_flags &= ~FAKEDEATH
				..()8*/

		mindbreaker
			name = "Mindbreaker Toxin"
			id = "mindbreaker"
			description = "A powerful hallucinogen. Not a thing to be messed with."
			reagent_state = LIQUID
			color = "#B31008" // rgb: 139, 166, 233
			custom_metabolism = 0.05

			on_mob_life(var/mob/living/M)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.hallucination += 10
				..()
				return

		spiritbreaker
			name = "Spiritbreaker Toxin"
			id = "spiritbreaker"
			description = "An extremely dangerous hallucinogen often used for torture. Extracted from the leaves of the rare Ambrosia Cruciatus plant."
			reagent_state = LIQUID
			color = "3B0805" // rgb: 59, 8, 5
			custom_metabolism = 0.05

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				var/sbreak = rand(150,180)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				if(data >= sbreak)
					M.adjustToxLoss(0.2)
					M.adjustBrainLoss(5)
					M.hallucination += 100
					M.dizziness += 100
					M.confused += 2
				data++
				return ..()


///////////////////////////////////////////////////////////////////////////////////////////////////////////////

		holywater
			name = "Holy Water"
			id = "holywater"
			description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
			reagent_state = LIQUID
			color = "#535E66" // rgb: 83, 94, 102

		nanites
			name = "Nanomachines"
			id = "nanites"
			description = "Microscopic construction robots."
			reagent_state = LIQUID
			color = "#535E66" // rgb: 83, 94, 102

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)

				if(!holder) return
				src = null
				if( (prob(10) && method==TOUCH) || method==INGEST)
					M.contract_disease(new /datum/disease/robotic_transformation(0),1)

		xenomicrobes
			name = "Xenomicrobes"
			id = "xenomicrobes"
			description = "Microbes with an entirely alien cellular structure."
			reagent_state = LIQUID
			color = "#535E66" // rgb: 83, 94, 102

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)

				if(!holder) return
				src = null
				if( (prob(10) && method==TOUCH) || method==INGEST)
					M.contract_disease(new /datum/disease/xeno_transformation(0),1)

//foam precursor

		fluorosurfactant
			name = "Fluorosurfactant"
			id = "fluorosurfactant"
			description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
			reagent_state = LIQUID
			color = "#9E6B38" // rgb: 158, 107, 56

// metal foaming agent
// this is lithium hydride. Add other recipies (e.g. LiH + H2O -> LiOH + H2) eventually

		foaming_agent
			name = "Foaming agent"
			id = "foaming_agent"
			description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
			reagent_state = SOLID
			color = "#664B63" // rgb: 102, 75, 99

		nicotine
			name = "Nicotine"
			id = "nicotine"
			description = "A highly addictive stimulant extracted from the tobacco plant."
			reagent_state = LIQUID
			color = "#181818" // rgb: 24, 24, 24
/*
		ethanol
			name = "Ethanol"
			id = "ethanol"
			description = "A well-known alcohol with a variety of applications."
			reagent_state = LIQUID
			color = "#404030" // rgb: 64, 64, 48

			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.make_dizzy(5)
				M.jitteriness = max(M.jitteriness-5,0)
				if(data >= 25)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 4
				if(data >= 40 && prob(33))
					if (!M.confused) M.confused = 1
					M.confused += 3
				..()
				return
			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/item/weapon/paper))
					var/obj/item/weapon/paper/paperaffected = O
					paperaffected.clearpaper()
					usr << "The solution melts away the ink on the paper."
				if(istype(O,/obj/item/weapon/book))
					if(volume >= 5)
						var/obj/item/weapon/book/affectedbook = O
						affectedbook.dat = null
						usr << "The solution melts away the ink on the book."
					else
						usr << "It wasn't enough..."
				return
*/
		ammonia
			name = "Ammonia"
			id = "ammonia"
			description = "A caustic substance commonly used in fertilizer or household cleaners."
			reagent_state = GAS
			color = "#404030" // rgb: 64, 64, 48

		ultraglue
			name = "Ultra Glue"
			id = "glue"
			description = "An extremely powerful bonding agent."
			color = "#FFFFCC" // rgb: 255, 255, 204

		diethylamine
			name = "Diethylamine"
			id = "diethylamine"
			description = "A secondary amine, mildly corrosive."
			reagent_state = LIQUID
			color = "#604030" // rgb: 96, 64, 48

		ethylredoxrazine						// FUCK YOU, ALCOHOL
			name = "Ethylredoxrazine"
			id = "ethylredoxrazine"
			description = "A powerful oxidizer that reacts with ethanol."
			reagent_state = SOLID
			color = "#605048" // rgb: 96, 80, 72

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.dizziness = 0
				M.drowsyness = 0
				M.stuttering = 0
				M.confused = 0
				..()
				return

		chloralhydrate							//Otherwise known as a "Mickey Finn"
			name = "Chloral Hydrate"
			id = "chloralhydrate"
			description = "A powerful sedative."
			reagent_state = SOLID
			color = "#000067" // rgb: 0, 0, 103

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(!data) data = 1
				data++
				switch(data)
					if(1)
						M.confused += 2
						M.drowsyness += 2
					if(2 to 80)
						M.sleeping += 1
					if(81 to INFINITY)
						M.sleeping += 1
						M:toxloss += (data - 50)
				..()

				return

		beer2							//copypasta of chloral hydrate, disguised as normal beer for use by emagged brobots
			name = "Beer"
			id = "beer2"
			description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(data)
					if(1)
						M.confused += 2
						M.drowsyness += 2
					if(2 to 50)
						M.sleeping += 1
					if(51 to INFINITY)
						M.sleeping += 1
						M.adjustToxLoss(data - 50)
				data++
				// Sleep toxins should always be consumed pretty fast
				holder.remove_reagent(src.id, 0.4)
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
			color = "#664330" // rgb: 102, 67, 48

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(prob(50)) M.heal_organ_damage(1,0)
				M.nutrition += nutriment_factor	// For hunger and fatness
/*
				// If overeaten - vomit and fall down
				// Makes you feel bad but removes reagents and some effect
				// from your body
				if (M.nutrition > 650)
					M.nutrition = rand (250, 400)
					M.weakened += rand(2, 10)
					M.jitteriness += rand(0, 5)
					M.dizziness = max (0, (M.dizziness - rand(0, 15)))
					M.druggy = max (0, (M.druggy - rand(0, 15)))
					M.adjustToxLoss(rand(-15, -5)))
					M.updatehealth()
*/
				..()
				return

		lipozine
			name = "Lipozine" // The anti-nutriment.
			id = "lipozine"
			description = "A chemical compound that causes a powerful fat-burning reaction."
			reagent_state = LIQUID
			nutriment_factor = 10 * REAGENTS_METABOLISM
			color = "#BBEDA4" // rgb: 187, 237, 164

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.nutrition -= nutriment_factor
				M.overeatduration = 0
				if(M.nutrition < 0)//Prevent from going into negatives.
					M.nutrition = 0
				..()
				return

		soysauce
			name = "Soysauce"
			id = "soysauce"
			description = "A salty sauce made from the soy plant."
			reagent_state = LIQUID
			nutriment_factor = 2 * REAGENTS_METABOLISM
			color = "#792300" // rgb: 121, 35, 0

		ketchup
			name = "Ketchup"
			id = "ketchup"
			description = "Ketchup, catsup, whatever. It's tomato paste."
			reagent_state = LIQUID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			color = "#731008" // rgb: 115, 16, 8


		capsaicin
			name = "Capsaicin Oil"
			id = "capsaicin"
			description = "This is what makes chilis hot."
			reagent_state = LIQUID
			color = "#B31008" // rgb: 179, 16, 8

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(data)
					if(1 to 15)
						M.bodytemperature += 5 * TEMPERATURE_DAMAGE_COEFFICIENT
						if(holder.has_reagent("frostoil"))
							holder.remove_reagent("frostoil", 5)
						if(istype(M, /mob/living/carbon/slime))
							M.bodytemperature += rand(5,20)
						if(M.dna.mutantrace == "slime")
							M.bodytemperature += rand(5,20)
					if(15 to 25)
						M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
						if(istype(M, /mob/living/carbon/slime))
							M.bodytemperature += rand(10,20)
						if(M.dna.mutantrace == "slime")
							M.bodytemperature += rand(10,20)
					if(25 to INFINITY)
						M.bodytemperature += 15 * TEMPERATURE_DAMAGE_COEFFICIENT
						if(istype(M, /mob/living/carbon/slime))
							M.bodytemperature += rand(15,20)
						if(M.dna.mutantrace == "slime")
							M.bodytemperature += rand(15,20)
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				data++
				..()
				return

		condensedcapsaicin
			name = "Condensed Capsaicin"
			id = "condensedcapsaicin"
			description = "This shit goes in pepperspray."
			reagent_state = LIQUID
			color = "#B31008" // rgb: 179, 16, 8

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					if(istype(M, /mob/living/carbon/human))
						var/mob/living/carbon/human/victim = M
						var/mouth_covered = 0
						var/eyes_covered = 0
						var/obj/item/safe_thing = null
						if( victim.wear_mask )
							if ( victim.wear_mask.flags & MASKCOVERSEYES )
								eyes_covered = 1
								safe_thing = victim.wear_mask
							if ( victim.wear_mask.flags & MASKCOVERSMOUTH )
								mouth_covered = 1
								safe_thing = victim.wear_mask
						if( victim.head )
							if ( victim.head.flags & MASKCOVERSEYES )
								eyes_covered = 1
								safe_thing = victim.head
							if ( victim.head.flags & MASKCOVERSMOUTH )
								mouth_covered = 1
								safe_thing = victim.head
						if(victim.glasses)
							eyes_covered = 1
							if ( !safe_thing )
								safe_thing = victim.glasses
						if ( eyes_covered && mouth_covered )
							victim << "\red Your [safe_thing] protects you from the pepperspray!"
							return
						else if ( mouth_covered )	// Reduced effects if partially protected
							victim << "\red Your [safe_thing] protect you from most of the pepperspray!"
							victim.eye_blurry = max(M.eye_blurry, 15)
							victim.eye_blind = max(M.eye_blind, 5)
							victim.Paralyse(1)
							victim.drop_item()
							return
						else if ( eyes_covered ) // Eye cover is better than mouth cover
							victim << "\red Your [safe_thing] protects your eyes from the pepperspray!"
							victim.emote("scream",,, 1)
							victim.eye_blurry = max(M.eye_blurry, 5)
							return
						else // Oh dear :D
							victim.emote("scream",,, 1)
							victim << "\red You're sprayed directly in the eyes with pepperspray!"
							victim.eye_blurry = max(M.eye_blurry, 25)
							victim.eye_blind = max(M.eye_blind, 10)
							victim.Paralyse(1)
							victim.drop_item()
			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(prob(5))
					M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")
				return

		frostoil
			name = "Frost Oil"
			id = "frostoil"
			description = "A special oil that noticably chills the body. Extraced from Icepeppers."
			reagent_state = LIQUID
			color = "#B31008" // rgb: 139, 166, 233

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(data)
					if(1 to 15)
						M.bodytemperature -= 5 * TEMPERATURE_DAMAGE_COEFFICIENT
						if(holder.has_reagent("capsaicin"))
							holder.remove_reagent("capsaicin", 5)
						if(istype(M, /mob/living/carbon/slime))
							M.bodytemperature -= rand(5,20)
						if(M.dna.mutantrace == "slime")
							M.bodytemperature -= rand(5,20)
					if(15 to 25)
						M.bodytemperature -= 10 * TEMPERATURE_DAMAGE_COEFFICIENT
						if(istype(M, /mob/living/carbon/slime))
							M.bodytemperature -= rand(10,20)
						if(M.dna.mutantrace == "slime")
							M.bodytemperature -= rand(10,20)
					if(25 to INFINITY)
						M.bodytemperature -= 15 * TEMPERATURE_DAMAGE_COEFFICIENT
						if(prob(1)) M.emote("shiver")
						if(istype(M, /mob/living/carbon/slime))
							M.bodytemperature -= rand(15,20)
						if(M.dna.mutantrace == "slime")
							M.bodytemperature -= rand(15,20)
				data++
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				..()
				return

			reaction_turf(var/turf/simulated/T, var/volume)
				for(var/mob/living/carbon/slime/M in T)
					M.adjustToxLoss(rand(15,30))
				for(var/mob/living/carbon/human/H in T)
					if(H.dna.mutantrace == "slime")
						H.adjustToxLoss(rand(5,15))

		sodiumchloride
			name = "Table Salt"
			id = "sodiumchloride"
			description = "A salt made of sodium chloride. Commonly used to season food."
			reagent_state = SOLID
			color = "#FFFFFF" // rgb: 255,255,255

		creatine
			name = "Creatine"
			id = "creatine"
			description = "Highly toxic substance that grants the user enormous strength, before their muscles seize and tear their own body to shreds."
			reagent_state = LIQUID
			color = "#6F884F" // rgb: 255,255,255
			var/has_been_hulk=0
			var/has_ripped_and_torn=0 // We've applied permanent damage.
			var/hulked_at = 0 // World.time

			custom_metabolism=0.1

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(volume)
					if(1 to 25)
						M.adjustToxLoss(1)
						M.make_dizzy(5)
						M.make_jittery(5)
						if(prob(5))
							M << "<span class='warning'>Oh god, the pain!</span>"
					if(25 to INFINITY)
						if(ishuman(M)) // Does nothing to non-humans.
							var/mob/living/carbon/human/H=M
							if(H.species.name!="Dionae") // Dionae are broken as fuck
								if(H.hulk_time<world.time && !has_been_hulk)
									H.hulk_time = world.time + (30 SECONDS)
									hulked_at = H.hulk_time
									if(!(M_HULK in H.mutations))
										has_been_hulk=1
										has_ripped_and_torn=0 // Fuck them UP after they dehulk.
										H.mutations.Add(M_HULK)
										H.update_mutations()		//update our mutation overlays
										H.update_body()
										message_admins("[key_name(M)] is TOO SWOLE TO CONTROL (on creatine)! ([formatJumpTo(M)])")
								else if(H.hulk_time<world.time && has_been_hulk) // TIME'S UP
									dehulk(H)
								else if(prob(1))
									H.say(pick("YOU TRYIN' BUILD SUM MUSSLE?","TOO SWOLE TO CONTROL","HEY MANG","HEY MAAAANG"))

				data++
				..()
				return

			proc/dehulk(var/mob/living/carbon/human/H)
				if(has_been_hulk && !has_ripped_and_torn)
					H << "<span class='warning'>You feel like your muscles are ripping apart!</span>"
					has_ripped_and_torn=1
					holder.remove_reagent(src.id) // Clean them out
					H.adjustBruteLoss(200)        // Crit

					for(var/datum/organ/external/E in H.organs)
						if(istype(E, /datum/organ/external/chest))
							continue
						if(istype(E, /datum/organ/external/head))
							continue // Permit basket cases.
						if(prob(50))
							// Override the current limb status and don't cause an explosion
							E.droplimb(1,1)

					if(H.species)
						hgibs(H.loc, H.viruses, H.dna, H.species.flesh_color, H.species.blood_color)
					else
						hgibs(H.loc, H.viruses, H.dna)

					H.hulk_time=0 // Just to be sure.
					H.mutations.Remove(M_HULK)
					//M.dna.SetSEState(HULKBLOCK,0)
					H.update_mutations()		//update our mutation overlays
					H.update_body()

		blackpepper
			name = "Black Pepper"
			id = "blackpepper"
			description = "A powder ground from peppercorns. *AAAACHOOO*"
			reagent_state = SOLID
			// no color (ie, black)

		coco
			name = "Coco Powder"
			id = "coco"
			description = "A fatty, bitter paste made from coco beans."
			reagent_state = SOLID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				M.nutrition += nutriment_factor
				..()
				return

		hot_coco
			name = "Hot Chocolate"
			id = "hot_coco"
			description = "Made with love! And coco beans."
			reagent_state = LIQUID
			nutriment_factor = 2 * REAGENTS_METABOLISM
			color = "#403010" // rgb: 64, 48, 16

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
				M.nutrition += nutriment_factor
				..()
				return

		amatoxin
			name = "Amatoxin"
			id = "amatoxin"
			description = "A powerful poison derived from certain species of mushroom."
			color = "#792300" // rgb: 121, 35, 0

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1.5)
				..()
				return

		amanatin
			name = "Alpha-Amanatin"
			id = "amanatin"
			description = "A deadly poison derived from certain species of Amanita. Sits in the victim's system for a long period of time, then ravages the body."
			color = "#792300" // rgb: 121, 35, 0
			custom_metabolism = 0.01
			var/activated = 0

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(!data) data = 1
				if(volume <= 3 && data >= 60 && !activated)	//minimum of 1 minute required to be useful
					activated = 1
				if(activated)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(prob(8))
							H << "<span class = 'warning'>You feel violently ill.</span>"
						if(prob(min(data / 10, 100)))	H.vomit()
						var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
						if (istype(L) && !L.is_broken())
							L.take_damage(data * 0.01, 0)
							H.adjustToxLoss(round(data / 20, 1))
						else
							H.adjustToxLoss(round(data / 10, 1))
							data += 4
					holder.remove_reagent(src.id, 0.02)
				switch(data)
					if(1 to 30)
						M.druggy = max(M.druggy, 10)
					if(540 to 600)	//start barfing violently after 9 minutes
						if(ishuman(M))
							var/mob/living/carbon/human/H = M
							if(prob(12))
								H << "<span class = 'warning'>You feel violently ill.</span>"
							H.adjustToxLoss(0.1)
							if(prob(8)) H.vomit()
					if(600 to INFINITY)	//ded in 10 minutes with a minimum of 6 units
						if(ishuman(M))
							var/mob/living/carbon/human/H = M
							if(prob(20))
								H << "<span class = 'sinister'>You feel deathly ill.</span>"
							var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
							if (istype(L) && !L.is_broken())
								L.take_damage(10, 0)
							else
								H.adjustToxLoss(60)
				data++
				..()
				return

		psilocybin
			name = "Psilocybin"
			id = "psilocybin"
			description = "A strong psycotropic derived from certain species of mushroom."
			color = "#E700E7" // rgb: 231, 0, 231

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 30)
				if(!data) data = 1
				switch(data)
					if(1 to 5)
						if (!M.stuttering) M.stuttering = 1
						M.make_dizzy(5)
						if(prob(10)) M.emote(pick("twitch","giggle"))
					if(5 to 10)
						if (!M.stuttering) M.stuttering = 1
						M.make_jittery(10)
						M.make_dizzy(10)
						M.druggy = max(M.druggy, 35)
						if(prob(20)) M.emote(pick("twitch","giggle"))
					if (10 to INFINITY)
						if (!M.stuttering) M.stuttering = 1
						M.make_jittery(20)
						M.make_dizzy(20)
						M.druggy = max(M.druggy, 40)
						if(prob(30)) M.emote(pick("twitch","giggle"))
				holder.remove_reagent(src.id, 0.2)
				data++
				..()
				return

		sprinkles
			name = "Sprinkles"
			id = "sprinkles"
			description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#FF00FF" // rgb: 255, 0, 255

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				M.nutrition += nutriment_factor
				if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
					if(!M) M = holder.my_atom
					M.heal_organ_damage(1,1)
					M.nutrition += nutriment_factor
					..()
					return
				..()

/*	//removed because of meta bullshit. this is why we can't have nice things.
		syndicream
			name = "Cream filling"
			id = "syndicream"
			description = "Delicious cream filling of a mysterious origin. Tastes criminally good."
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#AB7878" // rgb: 171, 120, 120

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				if(istype(M, /mob/living/carbon/human) && M.mind)
					if(M.mind.special_role)
						if(!M) M = holder.my_atom
						M.heal_organ_damage(1,1)
						M.nutrition += nutriment_factor
						..()
						return
				..()
*/
		cornoil
			name = "Corn Oil"
			id = "cornoil"
			description = "An oil derived from various types of corn."
			reagent_state = LIQUID
			nutriment_factor = 20 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				M.nutrition += nutriment_factor
				..()
				return
			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return
				src = null
				if(volume >= 3)
					T.wet(800)
				var/hotspot = (locate(/obj/fire) in T)
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
			color = "#365E30" // rgb: 54, 94, 48

		dry_ramen
			name = "Dry Ramen"
			id = "dry_ramen"
			description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
			reagent_state = SOLID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				M.nutrition += nutriment_factor
				..()
				return

		hot_ramen
			name = "Hot Ramen"
			id = "hot_ramen"
			description = "The noodles are boiled, the flavors are artificial, just like being back in school."
			reagent_state = LIQUID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				M.nutrition += nutriment_factor
				if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))
				..()
				return

		hell_ramen
			name = "Hell Ramen"
			id = "hell_ramen"
			description = "The noodles are boiled, the flavors are artificial, just like being back in school."
			reagent_state = LIQUID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				M.nutrition += nutriment_factor
				M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
				..()
				return

		flour
			name = "flour"
			id = "flour"
			description = "This is what you rub all over yourself to pretend to be a ghost."
			reagent_state = SOLID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#FFFFFF" // rgb: 0, 0, 0

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				M.nutrition += nutriment_factor
				..()
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(!istype(T, /turf/space))
					new /obj/effect/decal/cleanable/flour(T)

		rice
			name = "Rice"
			id = "rice"
			description = "Enjoy the great taste of nothing."
			reagent_state = SOLID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#FFFFFF" // rgb: 0, 0, 0

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				M.nutrition += nutriment_factor
				..()
				return

		cherryjelly
			name = "Cherry Jelly"
			id = "cherryjelly"
			description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#801E28" // rgb: 128, 30, 40

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				M.nutrition += nutriment_factor
				..()
				return

		discount
			name = "Discount Dan's Special Sauce"
			id = "discount"
			description = "You can almost feel your liver failing, just by looking at it."
			reagent_state = LIQUID
			color = "#6F884F" // rgb: 255,255,255 //to-do

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				if(!data) data = 1
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					switch(volume)
						if(1 to 20)
							if(prob(5))
								H << "<span class='warning'>You don't feel very good..</span>"
								holder.remove_reagent(src.id, 0.1 * REAGENTS_METABOLISM)
						if(20 to 35)
							if(prob(10))
								H << "<span class='warning'>You REALLY don't feel very good..</span>"
							if(prob(5))
								H.adjustToxLoss(0.1)
								H.visible_message("[H] groans.")
								holder.remove_reagent(src.id, 0.3 * REAGENTS_METABOLISM)
						if(35 to INFINITY)
							if(prob(10))
								H << "<span class='warning'>Your stomach grumbles unsettlingly..</span>"
							if(prob(5))
								H << "<span class='warning'>Something feels wrong with your body..</span>"
								var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
								if (istype(L))
									L.take_damage(0.1, 1)
								H.adjustToxLoss(0.13)
								holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
						else
							return

		irradiatedbeans
			name = "Irradiated Beans"
			id = "irradiatedbeans"
			description = "You can almost taste the lead sheet behind it!"
			reagent_state = LIQUID
			color = "#6F884F" // rgb: 255,255,255 //to-do
		toxicwaste
			name = "Toxic Waste"
			id = "toxicwaste"
			description = "Yum!"
			reagent_state = LIQUID
			color = "#6F884F" // rgb: 255,255,255 //to-do
		refriedbeans
			name = "Re-Fried Beans"
			id = "refriedbeans"
			description = "Mmm.."
			reagent_state = LIQUID
			color = "#6F884F" // rgb: 255,255,255 //to-do
		mutatedbeans
			name = "Mutated Beans"
			id = "mutatedbeans"
			description = "Mutated flavor."
			reagent_state = LIQUID
			color = "#6F884F" // rgb: 255,255,255 //to-do
		beff
			name = "Beff"
			id = "beff"
			description = "What's beff? Find out!"
			reagent_state = LIQUID
			color = "#6F884F" // rgb: 255,255,255 //to-do
		horsemeat
			name = "Horse Meat"
			id = "horsemeat"
			description = "Tastes excellent in lasagna."
			reagent_state = LIQUID
			color = "#6F884F" // rgb: 255,255,255 //to-do
		moonrocks
			name = "Moon Rocks"
			id = "moonrocks"
			description = "We don't know much about it, but we damn well know that it hates the human skeleton."
			reagent_state = LIQUID
			color = "#6F884F" // rgb: 255,255,255 //to-do
		offcolorcheese
			name = "Off-Color Cheese"
			id = "offcolorcheese"
			description = "American Cheese."
			reagent_state = LIQUID
			color = "#6F884F" // rgb: 255,255,255 //to-do
		bonemarrow
			name = "Bone Marrow"
			id = "bonemarrow"
			description = "Looks like a skeleton got stuck in the production line."
			reagent_state = LIQUID
			color = "#6F884F" // rgb: 255,255,255 //to-do
		greenramen
			name = "Greenish Ramen Noodles"
			id = "greenramen"
			description = "That green isn't organic."
			reagent_state = LIQUID
			color = "#6F884F" // rgb: 255,255,255 //to-do
		glowingramen
			name = "Glowing Ramen Noodles"
			id = "glowingramen"
			description = "That glow 'aint healthy."
			reagent_state = LIQUID
			color = "#6F884F" // rgb: 255,255,255 //to-do
		deepfriedramen
			name = "Deep Fried Ramen Noodles"
			id = "deepfriedramen"
			description = "Ramen, deep fried."
			reagent_state = LIQUID
			color = "#6F884F" // rgb: 255,255,255 //to-do

		peptobismol
			name = "Peptobismol"
			id = "peptobismol"
			description = "Jesus juice." //You're welcome, guy in the thread that rolled a 69.
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.drowsyness = max(M.drowsyness-2*REM, 0)
				if(holder.has_reagent("discount"))
					holder.remove_reagent("discount", 2*REM)
				M.hallucination = max(0, M.hallucination - 5*REM)
				M.adjustToxLoss(-2*REM)
				..()
				return
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum//////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

		drink
			name = "Drink"
			id = "drink"
			description = "Uh, some kind of drink."
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#E78108" // rgb: 231, 129, 8
			var/adj_dizzy = 0
			var/adj_drowsy = 0
			var/adj_sleepy = 0
			var/adj_temp = 0

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.nutrition += nutriment_factor
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				if (adj_dizzy) M.dizziness = max(0,M.dizziness + adj_dizzy)
				if (adj_drowsy)	M.drowsyness = max(0,M.drowsyness + adj_drowsy)
				if (adj_sleepy) M.sleeping = max(0,M.sleeping + adj_sleepy)
				if (adj_temp)
					if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
						M.bodytemperature = min(310, M.bodytemperature + (25 * TEMPERATURE_DAMAGE_COEFFICIENT))
				// Drinks should be used up faster than other reagents.
				if(!holder)
					holder = M.reagents
				if(holder)
					holder.remove_reagent(src.id, FOOD_METABOLISM)
				..()
				return

			orangejuice
				name = "Orange juice"
				id = "orangejuice"
				description = "Both delicious AND rich in Vitamin C, what more do you need?"
				color = "#E78108" // rgb: 231, 129, 8

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					..()
					if(M.getToxLoss() && prob(20)) M.adjustToxLoss(-1*REM)
					return

			tomatojuice
				name = "Tomato Juice"
				id = "tomatojuice"
				description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
				color = "#731008" // rgb: 115, 16, 8

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					..()
					if(M.getFireLoss() && prob(20)) M.heal_organ_damage(0,1)
					return

			limejuice
				name = "Lime Juice"
				id = "limejuice"
				description = "The sweet-sour juice of limes."
				color = "#365E30" // rgb: 54, 94, 48
				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					..()
					if(M.getToxLoss() && prob(20)) M.adjustToxLoss(-1)
					return

			carrotjuice
				name = "Carrot juice"
				id = "carrotjuice"
				description = "It is just like a carrot but without crunching."
				color = "#973800" // rgb: 151, 56, 0

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					..()
					M.eye_blurry = max(M.eye_blurry-1 , 0)
					M.eye_blind = max(M.eye_blind-1 , 0)
					if(!data) data = 1
					switch(data)
						if(1 to 20)
							//nothing
						if(21 to INFINITY)
							if (prob(data-10))
								M.disabilities &= ~NEARSIGHTED
					data++
					return

			berryjuice
				name = "Berry Juice"
				id = "berryjuice"
				description = "A delicious blend of several different kinds of berries."
				color = "#863333" // rgb: 134, 51, 51

			poisonberryjuice
				name = "Poison Berry Juice"
				id = "poisonberryjuice"
				description = "A tasty juice blended from various kinds of very deadly and toxic berries."
				color = "#863353" // rgb: 134, 51, 83

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					..()
					M.adjustToxLoss(1)
					return

			watermelonjuice
				name = "Watermelon Juice"
				id = "watermelonjuice"
				description = "Delicious juice made from watermelon."
				color = "#863333" // rgb: 134, 51, 51

			lemonjuice
				name = "Lemon Juice"
				id = "lemonjuice"
				description = "This juice is VERY sour."
				color = "#863333" // rgb: 175, 175, 0

			banana
				name = "Banana Juice"
				id = "banana"
				description = "The raw essence of a banana."
				color = "#863333" // rgb: 175, 175, 0

			nothing
				name = "Nothing"
				id = "nothing"
				description = "Absolutely nothing."

			potato_juice
				name = "Potato Juice"
				id = "potato"
				description = "Juice of the potato. Bleh."
				nutriment_factor = 2 * FOOD_METABOLISM
				color = "#302000" // rgb: 48, 32, 0

			milk
				name = "Milk"
				id = "milk"
				description = "An opaque white liquid produced by the mammary glands of mammals."
				color = "#DFDFDF" // rgb: 223, 223, 223

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
					if(holder.has_reagent("capsaicin"))
						holder.remove_reagent("capsaicin", 10*REAGENTS_METABOLISM)
					..()
					return

				soymilk
					name = "Soy Milk"
					id = "soymilk"
					description = "An opaque white liquid made from soybeans."
					color = "#DFDFC7" // rgb: 223, 223, 199

				cream
					name = "Cream"
					id = "cream"
					description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
					color = "#DFD7AF" // rgb: 223, 215, 175

			hot_coco
				name = "Hot Chocolate"
				id = "hot_coco"
				description = "Made with love! And coco beans."
				nutriment_factor = 2 * FOOD_METABOLISM
				color = "#403010" // rgb: 64, 48, 16
				adj_temp = 5

			coffee
				name = "Coffee"
				id = "coffee"
				description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
				color = "#482000" // rgb: 72, 32, 0
				adj_dizzy = -5
				adj_drowsy = -3
				adj_sleepy = -2
				adj_temp = 25

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					..()
					if(!holder)
						holder = M.reagents
					if(holder)
						M.make_jittery(5)
						if(adj_temp > 0 && holder.has_reagent("frostoil"))
							holder.remove_reagent("frostoil", 10*REAGENTS_METABOLISM)

						holder.remove_reagent(src.id, 0.1)
				icecoffee
					name = "Iced Coffee"
					id = "icecoffee"
					description = "Coffee and ice, refreshing and cool."
					color = "#102838" // rgb: 16, 40, 56
					adj_temp = -5

				soy_latte
					name = "Soy Latte"
					id = "soy_latte"
					description = "A nice and tasty beverage while you are reading your hippie books."
					color = "#664300" // rgb: 102, 67, 0
					adj_sleepy = 0
					adj_temp = 5

					on_mob_life(var/mob/living/M as mob)
						..()
						M.sleeping = 0
						if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
						return

				cafe_latte
					name = "Cafe Latte"
					id = "cafe_latte"
					description = "A nice, strong and tasty beverage while you are reading."
					color = "#664300" // rgb: 102, 67, 0
					adj_sleepy = 0
					adj_temp = 5

					on_mob_life(var/mob/living/M as mob)

						if(!holder) return
						..()
						M.sleeping = 0
						if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
						return

			tea
				name = "Tea"
				id = "tea"
				description = "Tasty black tea, it has antioxidants, it's good for you!"
				color = "#101000" // rgb: 16, 16, 0
				adj_dizzy = -2
				adj_drowsy = -1
				adj_sleepy = -3
				adj_temp = 20

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					..()
					if(M.getToxLoss() && prob(20))
						M.adjustToxLoss(-1)
					return

				icetea
					name = "Iced Tea"
					id = "icetea"
					description = "No relation to a certain rapper or actor."
					color = "#104038" // rgb: 16, 64, 56
					adj_temp = -5

			kahlua
				name = "Kahlua"
				id = "kahlua"
				description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
				color = "#664300" // rgb: 102, 67, 0
				adj_dizzy = -5
				adj_drowsy = -3
				adj_sleepy = -2

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					..()
					M.make_jittery(5)
					return

			cold
				name = "Cold drink"
				adj_temp = -5

				tonic
					name = "Tonic Water"
					id = "tonic"
					description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
					color = "#664300" // rgb: 102, 67, 0
					adj_dizzy = -5
					adj_drowsy = -3
					adj_sleepy = -2

				sodawater
					name = "Soda Water"
					id = "sodawater"
					description = "A can of club soda. Why not make a scotch and soda?"
					color = "#619494" // rgb: 97, 148, 148
					adj_dizzy = -5
					adj_drowsy = -3

				ice
					name = "Ice"
					id = "ice"
					description = "Frozen water, your dentist wouldn't like you chewing this."
					reagent_state = SOLID
					color = "#619494" // rgb: 97, 148, 148

				space_cola
					name = "Cola"
					id = "cola"
					description = "A refreshing beverage."
					reagent_state = LIQUID
					color = "#100800" // rgb: 16, 8, 0
					adj_drowsy 	= 	-3

				nuka_cola
					name = "Nuka Cola"
					id = "nuka_cola"
					description = "Cola, cola never changes."
					color = "#100800" // rgb: 16, 8, 0
					adj_sleepy = -2

					on_mob_life(var/mob/living/M as mob)

						if(!holder) return
						M.make_jittery(20)
						M.druggy = max(M.druggy, 30)
						M.dizziness +=5
						M.drowsyness = 0
						..()
						return

				spacemountainwind
					name = "Space Mountain Wind"
					id = "spacemountainwind"
					description = "Blows right through you like a space wind."
					color = "#102000" // rgb: 16, 32, 0
					adj_drowsy = -7
					adj_sleepy = -1

				dr_gibb
					name = "Dr. Gibb"
					id = "dr_gibb"
					description = "A delicious blend of 42 different flavours"
					color = "#102000" // rgb: 16, 32, 0
					adj_drowsy = -6

				space_up
					name = "Space-Up"
					id = "space_up"
					description = "Tastes like a hull breach in your mouth."
					color = "#202800" // rgb: 32, 40, 0
					adj_temp = -8

				lemon_lime
					name = "Lemon Lime"
					description = "A tangy substance made of 0.5% natural citrus!"
					id = "lemon_lime"
					color = "#878F00" // rgb: 135, 40, 0
					adj_temp = -8

				lemonade
					name = "Lemonade"
					description = "Oh the nostalgia..."
					id = "lemonade"
					color = "#FFFF00" // rgb: 255, 255, 0

				kiraspecial
					name = "Kira Special"
					description = "Long live the guy who everyone had mistaken for a girl. Baka!"
					id = "kiraspecial"
					color = "#CCCC99" // rgb: 204, 204, 153

				brownstar
					name = "Brown Star"
					description = "Its not what it sounds like..."
					id = "brownstar"
					color = "#9F3400" // rgb: 159, 052, 000
					adj_temp = - 2

				milkshake
					name = "Milkshake"
					description = "Glorious brainfreezing mixture."
					id = "milkshake"
					color = "#AEE5E4" // rgb" 174, 229, 228
					adj_temp = -9

					on_mob_life(var/mob/living/M as mob)

						if(!holder) return
						if(!M) M = holder.my_atom
						if(!data) data = 1
						switch(data)
							if(1 to 15)
								M.bodytemperature -= 5 * TEMPERATURE_DAMAGE_COEFFICIENT
								if(holder.has_reagent("capsaicin"))
									holder.remove_reagent("capsaicin", 5)
								if(istype(M, /mob/living/carbon/slime))
									M.bodytemperature -= rand(5,20)
								if(M.dna.mutantrace == "slime")
									M.bodytemperature -= rand(5,20)
							if(15 to 25)
								M.bodytemperature -= 10 * TEMPERATURE_DAMAGE_COEFFICIENT
								if(istype(M, /mob/living/carbon/slime))
									M.bodytemperature -= rand(10,20)
								if(M.dna.mutantrace == "slime")
									M.bodytemperature -= rand(10,20)
							if(25 to INFINITY)
								M.bodytemperature -= 15 * TEMPERATURE_DAMAGE_COEFFICIENT
								if(prob(1)) M.emote("shiver")
								if(istype(M, /mob/living/carbon/slime))
									M.bodytemperature -= rand(15,20)
								if(M.dna.mutantrace == "slime")
									M.bodytemperature -= rand(15,20)
						data++
						holder.remove_reagent(src.id, FOOD_METABOLISM)
						..()
						return

				rewriter
					name = "Rewriter"
					description = "The secert of the sanctuary of the Libarian..."
					id = "rewriter"
					color = "#485000" // rgb:72, 080, 0

					on_mob_life(var/mob/living/M as mob)

						if(!holder) return
						..()
						M.make_jittery(5)
						return

		hippies_delight
			name = "Hippie's Delight"
			id = "hippiesdelight"
			description = "You just don't get it maaaan."
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 50)
				if(!data) data = 1
				switch(data)
					if(1 to 5)
						if (!M.stuttering) M.stuttering = 1
						M.make_dizzy(10)
						if(prob(10)) M.emote(pick("twitch","giggle"))
					if(5 to 10)
						if (!M.stuttering) M.stuttering = 1
						M.make_jittery(20)
						M.make_dizzy(20)
						M.druggy = max(M.druggy, 45)
						if(prob(20)) M.emote(pick("twitch","giggle"))
					if (10 to INFINITY)
						if (!M.stuttering) M.stuttering = 1
						M.make_jittery(40)
						M.make_dizzy(40)
						M.druggy = max(M.druggy, 60)
						if(prob(30)) M.emote(pick("twitch","giggle"))
				holder.remove_reagent(src.id, 0.2)
				data++
				..()
				return

//ALCOHOL WOO
		ethanol
			name = "Ethanol" //Parent class for all alcoholic reagents.
			id = "ethanol"
			description = "A well-known alcohol with a variety of applications."
			reagent_state = LIQUID
			nutriment_factor = 0 //So alcohol can fill you up! If they want to.
			color = "#404030" // rgb: 64, 64, 48
			var/dizzy_adj = 3
			var/slurr_adj = 3
			var/confused_adj = 2
			var/slur_start = 65			//amount absorbed after which mob starts slurring
			var/confused_start = 130	//amount absorbed after which mob starts confusing directions
			var/blur_start = 260	//amount absorbed after which mob starts getting blurred vision
			var/pass_out = 325	//amount absorbed after which mob starts passing out

			on_mob_life(var/mob/living/M as mob)

				if(!holder || !M.reagents) return
				// Sobering multiplier.
				// Sober block makes it more difficult to get drunk
				var/sober_str=!(M_SOBER in M.mutations)?1:2

				M:nutrition += nutriment_factor
				if(!holder)
					holder = M.reagents
				if(holder)
					holder.remove_reagent(src.id, FOOD_METABOLISM)
				if(!src.data) data = 1
				src.data++

				var/d = data

				// make all the beverages work together
				for(var/datum/reagent/ethanol/A in holder.reagent_list)
					if(isnum(A.data)) d += A.data

				d/=sober_str

				M.dizziness +=dizzy_adj.
				if(d >= slur_start && d < pass_out)
					if (!M:slurring) M:slurring = 1
					M:slurring += slurr_adj/sober_str
				if(d >= confused_start && prob(33))
					if (!M:confused) M:confused = 1
					M.confused = max(M:confused+(confused_adj/sober_str),0)
				if(d >= blur_start)
					M.eye_blurry = max(M.eye_blurry, 10/sober_str)
					M:drowsyness  = max(M:drowsyness, 0)
				if(d >= pass_out)
					M:paralysis = max(M:paralysis, 20/sober_str)
					M:drowsyness  = max(M:drowsyness, 30/sober_str)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
						if (!L)
							H.adjustToxLoss(5)
						else if(istype(L))
							L.take_damage(0.1, 1)
						H.adjustToxLoss(0.1)
				if(!holder)
					holder = M.reagents
				if(holder)
					holder.remove_reagent(src.id, 0.4)
				..()
				return

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/item/weapon/paper))
					var/obj/item/weapon/paper/paperaffected = O
					paperaffected.clearpaper()
					usr << "The solution melts away the ink on the paper."
				if(istype(O,/obj/item/weapon/book))
					if(volume >= 5)
						var/obj/item/weapon/book/affectedbook = O
						affectedbook.dat = null
						usr << "The solution melts away the ink on the book."
					else
						usr << "It wasn't enough..."
				return

			beer	//It's really much more stronger than other drinks.
				name = "Beer"
				id = "beer"
				description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
				nutriment_factor = 2 * FOOD_METABOLISM
				color = "#664300" // rgb: 102, 67, 0
				on_mob_life(var/mob/living/M as mob)
					..()
					M:jitteriness = max(M:jitteriness-3,0)
					return

			whiskey
				name = "Whiskey"
				id = "whiskey"
				description = "A superb and well-aged single-malt whiskey. Damn."
				color = "#664300" // rgb: 102, 67, 0
				dizzy_adj = 4

			specialwhiskey
				name = "Special Blend Whiskey"
				id = "specialwhiskey"
				description = "Just when you thought regular station whiskey was good... This silky, amber goodness has to come along and ruin everything."
				color = "#664300" // rgb: 102, 67, 0
				slur_start = 30		//amount absorbed after which mob starts slurring

			gin
				name = "Gin"
				id = "gin"
				description = "It's gin. In space. I say, good sir."
				color = "#664300" // rgb: 102, 67, 0
				dizzy_adj = 3

			absinthe
				name = "Absinthe"
				id = "absinthe"
				description = "Watch out that the Green Fairy doesn't come for you!"
				color = "#33EE00" // rgb: lots, ??, ??
				dizzy_adj = 5
				slur_start = 25
				confused_start = 100

				//copy paste from LSD... shoot me
				on_mob_life(var/mob/M)

					if(!holder) return
					if(!M) M = holder.my_atom
					if(!data) data = 1
					data++
					M:hallucination += 5
					if(volume > REAGENTS_OVERDOSE)
						M:adjustToxLoss(1)
					..()
					return

			rum
				name = "Rum"
				id = "rum"
				description = "Yohoho and all that."
				color = "#664300" // rgb: 102, 67, 0

		ethanol/tequilla
			name = "Tequila"
			id = "tequilla"
			description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
			color = "#FFFF91" // rgb: 255, 255, 145
			//boozepwr = 2

		ethanol/vermouth
			name = "Vermouth"
			id = "vermouth"
			description = "You suddenly feel a craving for a martini..."
			color = "#91FF91" // rgb: 145, 255, 145
			//boozepwr = 1.5

		ethanol/wine
			name = "Wine"
			id = "wine"
			description = "An premium alchoholic beverage made from distilled grape juice."
			color = "#7E4043" // rgb: 126, 64, 67
			//boozepwr = 1.5
			dizzy_adj = 2
			slur_start = 65			//amount absorbed after which mob starts slurring
			confused_start = 145	//amount absorbed after which mob starts confusing directions

		ethanol/cognac
			name = "Cognac"
			id = "cognac"
			description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
			color = "#AB3C05" // rgb: 171, 60, 5
			//boozepwr = 1.5
			dizzy_adj = 4
			confused_start = 115	//amount absorbed after which mob starts confusing directions

		ethanol/hooch
			name = "Hooch"
			id = "hooch"
			description = "Either someone's failure at cocktail making or attempt in alchohol production. In any case, do you really want to drink that?"
			color = "#664300" // rgb: 102, 67, 0
			//boozepwr = 2
			dizzy_adj = 6
			slurr_adj = 5
			slur_start = 35			//amount absorbed after which mob starts slurring
			confused_start = 90	//amount absorbed after which mob starts confusing directions

		ethanol/ale
			name = "Ale"
			id = "ale"
			description = "A dark alchoholic beverage made by malted barley and yeast."
			color = "#664300" // rgb: 102, 67, 0
			//boozepwr = 1

		ethanol/absinthe
			name = "Absinthe"
			id = "absinthe"
			description = "Watch out that the Green Fairy doesn't come for you!"
			color = "#33EE00" // rgb: 51, 238, 0
			//boozepwr = 4
			dizzy_adj = 5
			slur_start = 15
			confused_start = 30


		ethanol/pwine
			name = "Poison Wine"
			id = "pwine"
			description = "Is this even wine? Toxic! Hallucinogenic! Probably consumed in boatloads by your superiors!"
			color = "#000000" // rgb: 0, 0, 0 SHOCKER
			//boozepwr = 1
			dizzy_adj = 1
			slur_start = 1
			confused_start = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 50)
				if(!data) data = 1
				data++
				switch(data)
					if(1 to 25)
						if (!M.stuttering) M.stuttering = 1
						M.make_dizzy(1)
						M.hallucination = max(M.hallucination, 3)
						if(prob(1)) M.emote(pick("twitch","giggle"))
					if(25 to 75)
						if (!M.stuttering) M.stuttering = 1
						M.hallucination = max(M.hallucination, 10)
						M.make_jittery(2)
						M.make_dizzy(2)
						M.druggy = max(M.druggy, 45)
						if(prob(5)) M.emote(pick("twitch","giggle"))
					if (75 to 150)
						if (!M.stuttering) M.stuttering = 1
						M.hallucination = max(M.hallucination, 60)
						M.make_jittery(4)
						M.make_dizzy(4)
						M.druggy = max(M.druggy, 60)
						if(prob(10)) M.emote(pick("twitch","giggle"))
						if(prob(30)) M.adjustToxLoss(2)
					if (150 to 300)
						if (!M.stuttering) M.stuttering = 1
						M.hallucination = max(M.hallucination, 60)
						M.make_jittery(4)
						M.make_dizzy(4)
						M.druggy = max(M.druggy, 60)
						if(prob(10)) M.emote(pick("twitch","giggle"))
						if(prob(30)) M.adjustToxLoss(2)
						if(prob(5)) if(ishuman(M))
							var/mob/living/carbon/human/H = M
							var/datum/organ/internal/heart/L = H.internal_organs_by_name["heart"]
							if (L && istype(L))
								L.take_damage(5, 0)
					if (300 to INFINITY)
						if(ishuman(M))
							var/mob/living/carbon/human/H = M
							var/datum/organ/internal/heart/L = H.internal_organs_by_name["heart"]
							if (L && istype(L))
								L.take_damage(100, 0)
				holder.remove_reagent(src.id, FOOD_METABOLISM)

		ethanol/deadrum
			name = "Deadrum"
			id = "rum"
			description = "Popular with the sailors. Not very popular with everyone else."
			color = "#664300" // rgb: 102, 67, 0
			//boozepwr = 1

			on_mob_life(var/mob/living/M as mob)

				if(!holder) return
				..()
				M.dizziness +=5
				if(volume > REAGENTS_OVERDOSE)
					M:adjustToxLoss(1)
				return

			vodka
				name = "Vodka"
				id = "vodka"
				description = "Number one drink AND fueling choice for Russians worldwide."
				color = "#664300" // rgb: 102, 67, 0

			sake
				name = "Sake"
				id = "sake"
				description = "Anime's favorite drink."
				color = "#664300" // rgb: 102, 67, 0

			tequilla
				name = "Tequila"
				id = "tequilla"
				description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
				color = "#A8B0B7" // rgb: 168, 176, 183

			vermouth
				name = "Vermouth"
				id = "vermouth"
				description = "You suddenly feel a craving for a martini..."
				color = "#664300" // rgb: 102, 67, 0

			wine
				name = "Wine"
				id = "wine"
				description = "An premium alchoholic beverage made from distilled grape juice."
				color = "#7E4043" // rgb: 126, 64, 67
				dizzy_adj = 2
				slur_start = 65			//amount absorbed after which mob starts slurring
				confused_start = 145	//amount absorbed after which mob starts confusing directions

			cognac
				name = "Cognac"
				id = "cognac"
				description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
				color = "#664300" // rgb: 102, 67, 0
				dizzy_adj = 4
				confused_start = 115	//amount absorbed after which mob starts confusing directions

			hooch
				name = "Hooch"
				id = "hooch"
				description = "Either someone's failure at cocktail making or attempt in alchohol production. In any case, do you really want to drink that?"
				color = "#664300" // rgb: 102, 67, 0
				dizzy_adj = 6
				slurr_adj = 5
				slur_start = 35			//amount absorbed after which mob starts slurring
				confused_start = 90	//amount absorbed after which mob starts confusing directions

			ale
				name = "Ale"
				id = "ale"
				description = "A dark alchoholic beverage made by malted barley and yeast."
				color = "#664300" // rgb: 102, 67, 0

			thirteenloko
				name = "Thirteen Loko"
				id = "thirteenloko"
				description = "A potent mixture of caffeine and alcohol."
				reagent_state = LIQUID
				color = "#102000" // rgb: 16, 32, 0

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					..()
					M:nutrition += nutriment_factor
					holder.remove_reagent(src.id, FOOD_METABOLISM)
					M:drowsyness = max(0,M:drowsyness-7)
					//if(!M:sleeping_willingly)
					//	M:sleeping = max(0,M.sleeping-2)
					if (M.bodytemperature > 310)
						M.bodytemperature = max(310, M.bodytemperature-5)
					M.make_jittery(1)
					return


/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////

			bilk
				name = "Bilk"
				id = "bilk"
				description = "This appears to be beer mixed with milk. Disgusting."
				reagent_state = LIQUID
				color = "#895C4C" // rgb: 137, 92, 76

			atomicbomb
				name = "Atomic Bomb"
				id = "atomicbomb"
				description = "Nuclear proliferation never tasted so good."
				reagent_state = LIQUID
				color = "#666300" // rgb: 102, 99, 0

			threemileisland
				name = "Three Mile Island Iced Tea"
				id = "threemileisland"
				description = "Made for a woman, strong enough for a man."
				reagent_state = LIQUID
				color = "#666340" // rgb: 102, 99, 64

			goldschlager
				name = "Goldschlager"
				id = "goldschlager"
				description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			patron
				name = "Patron"
				id = "patron"
				description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
				reagent_state = LIQUID
				color = "#585840" // rgb: 88, 88, 64

			gintonic
				name = "Gin and Tonic"
				id = "gintonic"
				description = "An all time classic, mild cocktail."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			cuba_libre
				name = "Cuba Libre"
				id = "cubalibre"
				description = "Rum, mixed with cola. Viva la revolution."
				reagent_state = LIQUID
				color = "#3E1B00" // rgb: 62, 27, 0

			whiskey_cola
				name = "Whiskey Cola"
				id = "whiskeycola"
				description = "Whiskey, mixed with cola. Surprisingly refreshing."
				reagent_state = LIQUID
				color = "#3E1B00" // rgb: 62, 27, 0

			martini
				name = "Classic Martini"
				id = "martini"
				description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			vodkamartini
				name = "Vodka Martini"
				id = "vodkamartini"
				description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			white_russian
				name = "White Russian"
				id = "whiterussian"
				description = "That's just, like, your opinion, man..."
				reagent_state = LIQUID
				color = "#A68340" // rgb: 166, 131, 64

			screwdrivercocktail
				name = "Screwdriver"
				id = "screwdrivercocktail"
				description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
				reagent_state = LIQUID
				color = "#A68310" // rgb: 166, 131, 16

			booger
				name = "Booger"
				id = "booger"
				description = "Ewww..."
				reagent_state = LIQUID
				color = "#A68310" // rgb: 166, 131, 16

			bloody_mary
				name = "Bloody Mary"
				id = "bloodymary"
				description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			gargle_blaster
				name = "Pan-Galactic Gargle Blaster"
				id = "gargleblaster"
				description = "Whoah, this stuff looks volatile!"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			brave_bull
				name = "Brave Bull"
				id = "bravebull"
				description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			tequilla_sunrise
				name = "Tequila Sunrise"
				id = "tequillasunrise"
				description = "Tequila and orange juice. Much like a Screwdriver, only Mexican~"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			toxins_special
				name = "Toxins Special"
				id = "toxinsspecial"
				description = "This thing is FLAMING!. CALL THE DAMN SHUTTLE!"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			beepsky_smash
				name = "Beepsky Smash"
				id = "beepskysmash"
				description = "Deny drinking this and prepare for THE LAW."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			doctor_delight
				name = "The Doctor's Delight"
				id = "doctorsdelight"
				description = "A gulp a day keeps the MediBot away. That's probably for the best."
				reagent_state = LIQUID
				nutriment_factor = 1 * FOOD_METABOLISM
				color = "#664300" // rgb: 102, 67, 0

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					M:nutrition += nutriment_factor
					holder.remove_reagent(src.id, FOOD_METABOLISM)
					if(!M) M = holder.my_atom
					if(M:getOxyLoss() && prob(50)) M:adjustOxyLoss(-2)
					if(M:getBruteLoss() && prob(60)) M:heal_organ_damage(2,0)
					if(M:getFireLoss() && prob(50)) M:heal_organ_damage(0,2)
					if(M:getToxLoss() && prob(50)) M:adjustToxLoss(-2)
					if(M.dizziness !=0) M.dizziness = max(0,M.dizziness-15)
					if(M.confused !=0) M.confused = max(0,M.confused - 5)
					..()
					return
			changelingsting
				name = "Changeling Sting"
				id = "changelingsting"
				description = "You take a tiny sip and feel a burning sensation..."
				reagent_state = LIQUID
				color = "#2E6671" // rgb: 46, 102, 113

			irish_cream
				name = "Irish Cream"
				id = "irishcream"
				description = "Whiskey-imbued cream, what else would you expect from the Irish."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			manly_dorf
				name = "The Manly Dorf"
				id = "manlydorf"
				description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			longislandicedtea
				name = "Long Island Iced Tea"
				id = "longislandicedtea"
				description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			moonshine
				name = "Moonshine"
				id = "moonshine"
				description = "You've really hit rock bottom now... your liver packed its bags and left last night."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			b52
				name = "B-52"
				id = "b52"
				description = "Coffee, Irish Cream, and congac. You will get bombed."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			irishcoffee
				name = "Irish Coffee"
				id = "irishcoffee"
				description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			margarita
				name = "Margarita"
				id = "margarita"
				description = "On the rocks with salt on the rim. Arriba~!"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			black_russian
				name = "Black Russian"
				id = "blackrussian"
				description = "For the lactose-intolerant. Still as classy as a White Russian."
				reagent_state = LIQUID
				color = "#360000" // rgb: 54, 0, 0

			manhattan
				name = "Manhattan"
				id = "manhattan"
				description = "The Detective's undercover drink of choice. He never could stomach gin..."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			manhattan_proj
				name = "Manhattan Project"
				id = "manhattan_proj"
				description = "A scienitst's drink of choice, for pondering ways to blow up the station."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			whiskeysoda
				name = "Whiskey Soda"
				id = "whiskeysoda"
				description = "Ultimate refreshment."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			antifreeze
				name = "Anti-freeze"
				id = "antifreeze"
				description = "Ultimate refreshment."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			barefoot
				name = "Barefoot"
				id = "barefoot"
				description = "Barefoot and pregnant"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			snowwhite
				name = "Snow White"
				id = "snowwhite"
				description = "A cold refreshment"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			demonsblood
				name = "Demons Blood"
				id = "demonsblood"
				description = "AHHHH!!!!"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0
				dizzy_adj = 10
				slurr_adj = 10

			vodkatonic
				name = "Vodka and Tonic"
				id = "vodkatonic"
				description = "For when a gin and tonic isn't russian enough."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0
				dizzy_adj = 4
				slurr_adj = 3

			ginfizz
				name = "Gin Fizz"
				id = "ginfizz"
				description = "Refreshingly lemony, deliciously dry."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0
				dizzy_adj = 4
				slurr_adj = 3

			bahama_mama
				name = "Bahama mama"
				id = "bahama_mama"
				description = "Tropic cocktail."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			singulo
				name = "Singulo"
				id = "singulo"
				description = "A blue-space beverage!"
				reagent_state = LIQUID
				color = "#2E6671" // rgb: 46, 102, 113
				dizzy_adj = 15
				slurr_adj = 15

			sbiten
				name = "Sbiten"
				id = "sbiten"
				description = "A spicy Vodka! Might be a little hot for the little guys!"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					..()
					if (M.bodytemperature < 360)
						M.bodytemperature = min(360, M.bodytemperature+50) //310 is the normal bodytemp. 310.055
					return

			devilskiss
				name = "Devils Kiss"
				id = "devilskiss"
				description = "Creepy time!"
				reagent_state = LIQUID
				color = "#A68310" // rgb: 166, 131, 16

			red_mead
				name = "Red Mead"
				id = "red_mead"
				description = "The true Viking drink! Even though it has a strange red color."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			mead
				name = "Mead"
				id = "mead"
				description = "A Vikings drink, though a cheap one."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			iced_beer
				name = "Iced Beer"
				id = "iced_beer"
				description = "A beer which is so cold the air around it freezes."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					..()
					if (M.bodytemperature < 270)
						M.bodytemperature = min(270, M.bodytemperature-40) //310 is the normal bodytemp. 310.055
					return

			grog
				name = "Grog"
				id = "grog"
				description = "Watered down rum, NanoTrasen approves!"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			aloe
				name = "Aloe"
				id = "aloe"
				description = "So very, very, very good."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			andalusia
				name = "Andalusia"
				id = "andalusia"
				description = "A nice, strange named drink."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			alliescocktail
				name = "Allies Cocktail"
				id = "alliescocktail"
				description = "A drink made from your allies."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			acid_spit
				name = "Acid Spit"
				id = "acidspit"
				description = "A drink by NanoTrasen. Made from live aliens."
				reagent_state = LIQUID
				color = "#365000" // rgb: 54, 80, 0

			amasec
				name = "Amasec"
				id = "amasec"
				description = "Official drink of the Imperium."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					..()
					M.stunned = 4
					return

			neurotoxin
				name = "Neurotoxin"
				id = "neurotoxin"
				description = "A strong neurotoxin that puts the subject into a death-like state."
				reagent_state = LIQUID
				color = "#2E2E61" // rgb: 46, 46, 97

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					..()
					if(!M) M = holder.my_atom
					M:adjustOxyLoss(0.5)
					M:adjustOxyLoss(0.5)
					M:weakened = max(M:weakened, 15)
					M:silent = max(M:silent, 15)
					return

			bananahonk
				name = "Banana Mama"
				id = "bananahonk"
				description = "A drink from Clown Heaven."
				nutriment_factor = 1 * FOOD_METABOLISM
				color = "#664300" // rgb: 102, 67, 0

			silencer
				name = "Silencer"
				id = "silencer"
				description = "A drink from Mime Heaven."
				nutriment_factor = 1 * FOOD_METABOLISM
				color = "#664300" // rgb: 102, 67, 0

			changelingsting
				name = "Changeling Sting"
				id = "changelingsting"
				description = "A stingy drink."
				reagent_state = LIQUID
				color = "#2E6671" // rgb: 46, 102, 113

				on_mob_life(var/mob/living/M as mob)
					..()
					M.dizziness +=5
					return

			erikasurprise
				name = "Erika Surprise"
				id = "erikasurprise"
				description = "The surprise is, it's green!"
				reagent_state = LIQUID
				color = "#2E6671" // rgb: 46, 102, 113

			irishcarbomb
				name = "Irish Car Bomb"
				id = "irishcarbomb"
				description = "Mmm, tastes like chocolate cake..."
				reagent_state = LIQUID
				color = "#2E6671" // rgb: 46, 102, 113

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					..()
					M.dizziness +=5
					return

			syndicatebomb
				name = "Syndicate Bomb"
				id = "syndicatebomb"
				description = "A Syndicate bomb"
				reagent_state = LIQUID
				color = "#2E6671" // rgb: 46, 102, 113

			erikasurprise
				name = "Erika Surprise"
				id = "erikasurprise"
				description = "The surprise is, it's green!"
				reagent_state = LIQUID
				color = "#2E6671" // rgb: 46, 102, 113

			driestmartini
				name = "Driest Martini"
				id = "driestmartini"
				description = "Only for the experienced. You think you see sand floating in the glass."
				nutriment_factor = 1 * FOOD_METABOLISM
				color = "#2E6671" // rgb: 46, 102, 113

				on_mob_life(var/mob/living/M as mob)

					if(!holder) return
					if(!data) data = 1
					data++
					M.dizziness +=10
					if(data >= 55 && data <115)
						if (!M.stuttering) M.stuttering = 1
						M.stuttering += 10
					else if(data >= 115 && prob(33))
						M.confused = max(M.confused+15,15)
					..()
					return

/datum/reagent/Destroy()
	if(holder)
		holder.reagent_list -= src
		holder = null
