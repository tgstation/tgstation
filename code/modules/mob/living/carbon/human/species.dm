// This code handles different species in the game.

#define SPECIES_LAYER			23
#define BODY_LAYER				22
#define HAIR_LAYER				8

#define TINT_IMPAIR 2
#define TINT_BLIND 3

#define HUMAN_MAX_OXYLOSS 3
#define HUMAN_CRIT_MAX_OXYLOSS ( (last_tick_duration) /3)

#define HEAT_DAMAGE_LEVEL_1 2
#define HEAT_DAMAGE_LEVEL_2 3
#define HEAT_DAMAGE_LEVEL_3 8

#define COLD_DAMAGE_LEVEL_1 0.5
#define COLD_DAMAGE_LEVEL_2 1.5
#define COLD_DAMAGE_LEVEL_3 3

#define HEAT_GAS_DAMAGE_LEVEL_1 2
#define HEAT_GAS_DAMAGE_LEVEL_2 4
#define HEAT_GAS_DAMAGE_LEVEL_3 8

#define COLD_GAS_DAMAGE_LEVEL_1 0.5
#define COLD_GAS_DAMAGE_LEVEL_2 1.5
#define COLD_GAS_DAMAGE_LEVEL_3 3

/datum/species
	var/id = null		// if the game needs to manually check your race to do something not included in a proc here, it will use this
	var/name = null		// this is the fluff name. these will be left generic (such as 'Lizardperson' for the lizard race) so servers can change them to whatever
	var/roundstart = 0	// can this mob be chosen at roundstart? (assuming the config option is checked?)
	var/default_color = "#FFF"	// if alien colors are disabled, this is the color that will be used by that race

	var/eyes = "eyes"	// which eyes the race uses. at the moment, the only types of eyes are "eyes" (regular eyes) and "jelleyes" (three eyes)
	var/sexes = 1		// whether or not the race has sexual characteristics. at the moment this is only 0 for skeletons and shadows
	var/hair_color = null	// this allows races to have specific hair colors... if null, it uses the owner's hair/facial hair colors. if "mutcolor", it uses the owner's mutant_color
	var/hair_alpha = 255	// the alpha used by the hair. 255 is completely solid, 0 is transparent.
	var/use_skintones = 0	// does it use skintones or not? (spoiler alert this is only used by humans)

	var/say_mod = "says"	// affects the speech message

	var/speedmod = 0	// this affects the race's speed. positive numbers make it move slower, negative numbers make it move faster
	var/armor = 0		// overall defense for the race... or less defense, if it's negative.
	var/brutemod = 1	// multiplier for brute damage
	var/burnmod = 1		// multiplier for burn damage
	var/coldmod = 1		// multiplier for cold damage
	var/heatmod = 1		// multiplier for heat damage
	var/punchmod = 0	// adds to the punch damage

	var/invis_sight = SEE_INVISIBLE_LIVING
	var/darksight = 2

	// SPECIES FLAGS: "mutcolors", "hair", "facehair", "eyecolor", "lips", "resists_cold", "resists_heat", "rad_immune",
	// "nobreath", "noguns", "noblood", "nonflammable"
	var/list/specflags = list()

	var/attack_verb = "punch"	// punch-specific attack verb
	var/sound/attack_sound = 'sound/weapons/punch1.ogg'
	var/sound/miss_sound = 'sound/weapons/punchmiss.ogg'

	var/mob/living/list/ignored_by = list()	// list of mobs that will ignore this species

	var/mob/living/carbon/human/owner = null // the person who has this race

	New(var/mob/living/carbon/human/new_owner)
		if(new_owner)	owner = new_owner
		..()

	proc/update_base_icon_state()
		if(HUSK in owner.mutations)
			owner.remove_overlay(SPECIES_LAYER) // races lose their color
			return "husk"
		else if(sexes)
			if(use_skintones)
				return "[owner.skin_tone]_[(owner.gender == FEMALE) ? "f" : "m"]"
			else
				return "[id]_[(owner.gender == FEMALE) ? "f" : "m"]"
		else
			return "[id]"

	proc/update_color()
		owner.remove_overlay(SPECIES_LAYER)

		var/image/standing

		var/g = (owner.gender == FEMALE) ? "f" : "m"

		if("mutcolor" in specflags)
			var/image/spec_base
			spec_base = image("icon" = 'icons/mob/human.dmi', "icon_state" = "[owner.dna.species.id]_[g]_s", "layer" = -SPECIES_LAYER)
			if(!config.mutant_colors)
				owner.dna.mutant_color = default_color
			spec_base.color = "#[owner.dna.mutant_color]"
			standing = spec_base

		if(standing)
			owner.overlays_standing[SPECIES_LAYER]	= standing

		owner.apply_overlay(SPECIES_LAYER)

	proc/handle_hair()
		owner.remove_overlay(HAIR_LAYER)

		var/datum/sprite_accessory/S
		var/list/standing	= list()

		if(owner.facial_hair_style && "facehair" in specflags)
			S = facial_hair_styles_list[owner.facial_hair_style]
			if(S)
				var/image/img_facial_s

				img_facial_s = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)

				if(hair_color)
					if(hair_color == "mutcolor")
						if(!config.mutant_colors)
							img_facial_s.color = "#" + default_color
						else
							img_facial_s.color = "#" + owner.dna.mutant_color
					else
						img_facial_s.color = "#" + hair_color
				else
					img_facial_s.color = "#" + owner.facial_hair_color
				img_facial_s.alpha = hair_alpha

				standing	+= img_facial_s

		//Applies the debrained overlay if there is no brain
		if(!owner.getorgan(/obj/item/organ/brain))
			standing	+= image("icon"='icons/mob/human_face.dmi', "icon_state" = "debrained_s", "layer" = -HAIR_LAYER)

		else if(owner.hair_style && "hair" in specflags)
			S = hair_styles_list[owner.hair_style]
			if(S)
				var/image/img_hair_s = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)

				img_hair_s = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)

				if(hair_color)
					if(hair_color == "mutcolor")
						if(!config.mutant_colors)
							img_hair_s.color = "#" + default_color
						else
							img_hair_s.color = "#" + owner.dna.mutant_color
					else
						img_hair_s.color = "#" + hair_color
				else
					img_hair_s.color = "#" + owner.hair_color
				img_hair_s.alpha = hair_alpha

				standing	+= img_hair_s

		if(standing.len)
			owner.overlays_standing[HAIR_LAYER]	= standing

		owner.apply_overlay(HAIR_LAYER)

		return

	proc/handle_body()
		owner.remove_overlay(BODY_LAYER)

		var/list/standing	= list()

		// lipstick
		if(owner.lip_style && "lips" in specflags)
			standing	+= image("icon"='icons/mob/human_face.dmi', "icon_state"="lips_[owner.lip_style]_s", "layer" = -BODY_LAYER)

		// eyes
		if("eyecolor" in specflags)
			var/image/img_eyes_s = image("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[eyes]_s", "layer" = -BODY_LAYER)
			img_eyes_s.color = "#" + owner.eye_color
			standing	+= img_eyes_s

		//Underwear
		if(owner.underwear)
			var/datum/sprite_accessory/underwear/U = underwear_all[owner.underwear]
			if(U)
				standing	+= image("icon"=U.icon, "icon_state"="[U.icon_state]_s", "layer"=-BODY_LAYER)

		if(standing.len)
			owner.overlays_standing[BODY_LAYER] = standing

		owner.apply_overlay(BODY_LAYER)

		return

	proc/spec_life()
		return

	proc/spec_death(var/gibbed)
		return

	proc/auto_equip()
		// meant to handle the equipping of species-specific gear. at the moment, only adamantine golems use this (which will soon become obsolete)
		return

	proc/handle_chemicals(var/chem)
		return

	proc/handle_speech(var/message)
		return message

	////////
	//LIFE//
	////////

	proc/handle_chemicals_in_body()
		if(owner.reagents) owner.reagents.metabolize(owner)

		//The fucking FAT mutation is the dumbest shit ever. It makes the code so difficult to work with
		if(FAT in owner.mutations)
			if(owner.overeatduration < 100)
				owner << "\blue You feel fit again!"
				owner.mutations -= FAT
				owner.update_inv_w_uniform(0)
				owner.update_inv_wear_suit()
		else
			if(owner.overeatduration > 500)
				owner << "\red You suddenly feel blubbery!"
				owner.mutations |= FAT
				owner.update_inv_w_uniform(0)
				owner.update_inv_wear_suit()

		// nutrition decrease
		if (owner.nutrition > 0 && owner.stat != 2)
			owner.nutrition = max (0, owner.nutrition - HUNGER_FACTOR)

		if (owner.nutrition > 450)
			if(owner.overeatduration < 600) //capped so people don't take forever to unfat
				owner.overeatduration++
		else
			if(owner.overeatduration > 1)
				owner.overeatduration -= 2 //doubled the unfat rate

		if (owner.drowsyness)
			owner.drowsyness--
			owner.eye_blurry = max(2, owner.eye_blurry)
			if (prob(5))
				owner.sleeping += 1
				owner.Paralyse(5)

		owner.confused = max(0, owner.confused - 1)
		// decrement dizziness counter, clamped to 0
		if(owner.resting)
			owner.dizziness = max(0, owner.dizziness - 15)
			owner.jitteriness = max(0, owner.jitteriness - 15)
		else
			owner.dizziness = max(0, owner.dizziness - 3)
			owner.jitteriness = max(0, owner.jitteriness - 3)

		owner.updatehealth()

		return

	proc/handle_vision()
		if( owner.stat == DEAD )
			owner.sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
			owner.see_in_dark = 8
			if(!owner.druggy)		owner.see_invisible = SEE_INVISIBLE_LEVEL_TWO
		else
			owner.sight &= ~(SEE_TURFS|SEE_MOBS|SEE_OBJS)
			var/see_temp = owner.see_invisible
			owner.see_invisible = invis_sight
			owner.see_in_dark = darksight

			if(XRAY in owner.mutations)
				owner.sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
				owner.see_in_dark = 8
				owner.see_invisible = SEE_INVISIBLE_LEVEL_TWO

			if(owner.seer)
				owner.see_invisible = SEE_INVISIBLE_OBSERVER

			if(owner.mind && owner.mind.changeling)
				owner.hud_used.lingchemdisplay.invisibility = 0
				owner.hud_used.lingchemdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='#dd66dd'>[owner.mind.changeling.chem_charges]</font></div>"
			else
				owner.hud_used.lingchemdisplay.invisibility = 101

			if(istype(owner.wear_mask, /obj/item/clothing/mask/gas/voice/space_ninja))
				var/obj/item/clothing/mask/gas/voice/space_ninja/O = owner.wear_mask
				switch(O.mode)
					if(0)
						var/target_list[] = list()
						for(var/mob/living/target in oview(owner))
							if( target.mind&&(target.mind.special_role||issilicon(target)) )//They need to have a mind.
								target_list += target
						if(target_list.len)//Everything else is handled by the ninja mask proc.
							O.assess_targets(target_list, owner)
						owner.see_invisible = SEE_INVISIBLE_LIVING
					if(1)
						owner.see_in_dark = 5
						owner.see_invisible = SEE_INVISIBLE_LIVING
					if(2)
						owner.sight |= SEE_MOBS
						owner.see_invisible = SEE_INVISIBLE_LEVEL_TWO
					if(3)
						owner.sight |= SEE_TURFS
						owner.see_invisible = SEE_INVISIBLE_LIVING

			if(owner.glasses)
				if(istype(owner.glasses, /obj/item/clothing/glasses))
					var/obj/item/clothing/glasses/G = owner.glasses
					owner.sight |= G.vision_flags
					owner.see_in_dark = G.darkness_view
					owner.see_invisible = G.invis_view
					if(G.hud)
						G.process_hud(owner)

			if(owner.druggy)	//Override for druggy
				owner.see_invisible = see_temp

			if(owner.see_override)	//Override all
				owner.see_invisible = owner.see_override

			//	This checks how much the mob's eyewear impairs their vision
			if(owner.tinttotal >= TINT_IMPAIR)
				if(tinted_weldhelh)
					if(owner.tinttotal >= TINT_BLIND)
						owner.blinded = 1								// You get the sudden urge to learn to play keyboard
						owner.client.screen += global_hud.darkMask
					else
						owner.client.screen += global_hud.darkMask

			if(owner.blind)
				if(owner.blinded)		owner.blind.layer = 18
				else			owner.blind.layer = 0

			if( owner.disabilities & NEARSIGHTED && !istype(owner.glasses, /obj/item/clothing/glasses/regular) )
				owner.client.screen += global_hud.vimpaired
			if(owner.eye_blurry)			owner.client.screen += global_hud.blurry
			if(owner.druggy)				owner.client.screen += global_hud.druggy


			if(owner.eye_stat > 20)
				if(owner.eye_stat > 30)	owner.client.screen += global_hud.darkMask
				else				owner.client.screen += global_hud.vimpaired

		return 1

	proc/handle_hud_icons()
		if(owner.healths)
			if(owner.stat == DEAD)
				owner.healths.icon_state = "health7"
			else
				switch(owner.hal_screwyhud)
					if(1)	owner.healths.icon_state = "health6"
					if(2)	owner.healths.icon_state = "health7"
					else
						switch(owner.health - owner.staminaloss)
							if(100 to INFINITY)		owner.healths.icon_state = "health0"
							if(80 to 100)			owner.healths.icon_state = "health1"
							if(60 to 80)			owner.healths.icon_state = "health2"
							if(40 to 60)			owner.healths.icon_state = "health3"
							if(20 to 40)			owner.healths.icon_state = "health4"
							if(0 to 20)				owner.healths.icon_state = "health5"
							else					owner.healths.icon_state = "health6"

		if(owner.nutrition_icon)
			switch(owner.nutrition)
				if(450 to INFINITY)				owner.nutrition_icon.icon_state = "nutrition0"
				if(350 to 450)					owner.nutrition_icon.icon_state = "nutrition1"
				if(250 to 350)					owner.nutrition_icon.icon_state = "nutrition2"
				if(150 to 250)					owner.nutrition_icon.icon_state = "nutrition3"
				else							owner.nutrition_icon.icon_state = "nutrition4"

		if(owner.pressure)
			owner.pressure.icon_state = "pressure[owner.pressure_alert]"

		if(owner.pullin)
			if(owner.pulling)								owner.pullin.icon_state = "pull"
			else									owner.pullin.icon_state = "pull0"
//			if(rest)	//Not used with new UI
//				if(resting || lying || sleeping)		rest.icon_state = "rest1"
//				else									rest.icon_state = "rest0"
		if(owner.toxin)
			if(owner.hal_screwyhud == 4 || owner.toxins_alert)	owner.toxin.icon_state = "tox1"
			else									owner.toxin.icon_state = "tox0"
		if(owner.oxygen)
			if(owner.hal_screwyhud == 3 || owner.oxygen_alert)	owner.oxygen.icon_state = "oxy1"
			else									owner.oxygen.icon_state = "oxy0"
		if(owner.fire)
			if(owner.fire_alert)					owner.fire.icon_state = "fire[owner.fire_alert]" //fire_alert is either 0 if no alert, 1 for cold and 2 for heat.
			else									owner.fire.icon_state = "fire0"

		if(owner.bodytemp)
			if(!("resists_fire" in specflags))
				switch(owner.bodytemperature) //310.055 optimal body temp
					if(370 to INFINITY)		owner.bodytemp.icon_state = "temp4"
					if(350 to 370)			owner.bodytemp.icon_state = "temp3"
					if(335 to 350)			owner.bodytemp.icon_state = "temp2"
			switch(owner.bodytemperature)
				if(320 to 335)			owner.bodytemp.icon_state = "temp1"
				if(300 to 320)			owner.bodytemp.icon_state = "temp0"
				if(295 to 300)			owner.bodytemp.icon_state = "temp-1"
			if(!("resists_cold" in specflags))
				switch(owner.bodytemperature)
					if(280 to 295)			owner.bodytemp.icon_state = "temp-2"
					if(260 to 280)			owner.bodytemp.icon_state = "temp-3"
					if(-INFINITY to 260)	owner.bodytemp.icon_state = "temp-4"

		return 1

	proc/handle_mutations_and_radiation()
		if(owner.getFireLoss())
			if((COLD_RESISTANCE in owner.mutations) || (prob(1)))
				owner.heal_organ_damage(0,1)

		if ((HULK in owner.mutations) && owner.health <= 25)
			owner.mutations.Remove(HULK)
			owner.update_mutations()		//update our mutation overlays
			owner << "\red You suddenly feel very weak."
			owner.Weaken(3)
			owner.emote("collapse")

		if (owner.radiation && !("rad_immune" in specflags))
			if (owner.radiation > 100)
				owner.radiation = 100
				owner.Weaken(10)
				owner << "\red You feel weak."
				owner.emote("collapse")

			if (owner.radiation < 0)
				owner.radiation = 0

			else
				switch(owner.radiation)
					if(1 to 49)
						owner.radiation--
						if(prob(25))
							owner.adjustToxLoss(1)
							owner.updatehealth()

					if(50 to 74)
						owner.radiation -= 2
						owner.adjustToxLoss(1)
						if(prob(5))
							owner.radiation -= 5
							owner.Weaken(3)
							owner << "\red You feel weak."
							owner.emote("collapse")
						if(prob(15))
							if(!( owner.hair_style == "Shaved") || !(owner.hair_style == "Bald") || "hair" in specflags)
								owner << "<span class='danger'>Your hair starts to fall out in clumps...<span>"
								spawn(50)
									owner.facial_hair_style = "Shaved"
									owner.hair_style = "Bald"
									owner.update_hair()
						owner.updatehealth()

					if(75 to 100)
						owner.radiation -= 3
						owner.adjustToxLoss(3)
						if(prob(1))
							owner << "\red You mutate!"
							randmutb(owner)
							domutcheck(owner,null)
							owner.emote("gasp")
						owner.updatehealth()

	////////////////
	// MOVE SPEED //
	////////////////

	proc/movement_delay()
		var/mspeed = 0

		if(!has_gravity(owner))
			return -1	//It's hard to be slowed down in space by... anything
		else if(owner.status_flags & GOTTAGOFAST)
			return -1

		mspeed = 0
		var/health_deficiency = (100 - owner.health + owner.staminaloss)
		if(health_deficiency >= 40)
			mspeed += (health_deficiency / 25)

		var/hungry = (500 - owner.nutrition) / 5	//So overeat would be 100 and default level would be 80
		if(hungry >= 70)
			mspeed += hungry / 50

		if(owner.wear_suit)
			mspeed += owner.wear_suit.slowdown
		if(owner.shoes)
			mspeed += owner.shoes.slowdown
		if(owner.back)
			mspeed += owner.back.slowdown

		if(FAT in owner.mutations)
			mspeed += 1.5
		if(owner.bodytemperature < 283.222)
			mspeed += (283.222 - owner.bodytemperature) / 10 * 1.75

		mspeed += speedmod

		return mspeed

	//////////////////
	// ATTACK PROCS //
	//////////////////

	proc/spec_attack_hand(var/mob/living/carbon/human/M)
		if((M != owner) && owner.check_shields(0, M.name))
			add_logs(M, owner, "attempted to touch")
			owner.visible_message("<span class='warning'>[M] attempted to touch [owner]!</span>")
			return 0

		switch(M.a_intent)
			if("help")
				if(owner.health >= 0)
					owner.help_shake_act(M)
					if(owner != M)
						add_logs(M, owner, "shaked")
					return 1

				//CPR
				if((M.head && (M.head.flags & HEADCOVERSMOUTH)) || (M.wear_mask && (M.wear_mask.flags & MASKCOVERSMOUTH)))
					M << "<span class='notice'>Remove your mask!</span>"
					return 0
				if((owner.head && (owner.head.flags & HEADCOVERSMOUTH)) || (owner.wear_mask && (owner.wear_mask.flags & MASKCOVERSMOUTH)))
					M << "<span class='notice'>Remove their mask!</span>"
					return 0

				if(owner.cpr_time < world.time + 30)
					add_logs(owner, M, "CPRed")
					owner.visible_message("<span class='notice'>[M] is trying to perform CPR on [owner]!</span>")
					if(!do_mob(M, owner))
						return 0
					if((owner.health >= -99 && owner.health <= 0))
						owner.cpr_time = world.time
						var/suff = min(owner.getOxyLoss(), 7)
						owner.adjustOxyLoss(-suff)
						owner.updatehealth()
						M.visible_message("[M] performs CPR on [owner]!")
						owner << "<span class='unconscious'>You feel a breath of fresh air enter your lungs. It feels good.</span>"

			if("grab")
				if(M == owner || owner.anchored)
					return 0

				add_logs(M, owner, "grabbed", addition="passively")

				if(owner.w_uniform)
					owner.w_uniform.add_fingerprint(M)

				var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, owner)
				if(owner.buckled)
					M << "<span class='notice'>You cannot grab [owner], \he is buckled in!</span>"
				if(!G)	//the grab will delete itself in New if affecting is anchored
					return
				M.put_in_active_hand(G)
				G.synch()
				owner.LAssailant = M

				playsound(owner.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				owner.visible_message("<span class='warning'>[M] has grabbed [owner] passively!</span>")
				return 1

			if("harm")
				add_logs(M, owner, "punched")

				var/atk_verb = "punch"
				if(owner.lying)
					atk_verb = "kick"
				else if(M.dna)
					atk_verb = M.dna.species.attack_verb

				var/damage = rand(0, 9)
				damage += punchmod

				if(!damage)
					if(M.dna)
						playsound(owner.loc, M.dna.species.miss_sound, 25, 1, -1)
					else
						playsound(owner.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

					owner.visible_message("<span class='warning'>[M] has attempted to [atk_verb] [owner]!</span>")
					return 0


				var/obj/item/organ/limb/affecting = owner.get_organ(ran_zone(M.zone_sel.selecting))
				var/armor_block = owner.run_armor_check(affecting, "melee")

				if(HULK in M.mutations)
					damage += 5

				if(M.dna)
					playsound(owner.loc, M.dna.species.attack_sound, 25, 1, -1)
				else
					playsound(owner.loc, 'sound/weapons/punch1.ogg', 25, 1, -1)


				owner.visible_message("<span class='danger'>[M] has [atk_verb]ed [owner]!</span>", \
								"<span class='userdanger'>[M] has [atk_verb]ed [owner]!</span>")

				owner.apply_damage(damage, BRUTE, affecting, armor_block)
				if((owner.stat != DEAD) && damage >= 9)
					owner.visible_message("<span class='danger'>[M] has weakened [owner]!</span>", \
									"<span class='userdanger'>[M] has weakened [owner]!</span>")
					owner.apply_effect(4, WEAKEN, armor_block)
					owner.forcesay(hit_appends)
				else if(owner.lying)
					owner.forcesay(hit_appends)

			if("disarm")
				add_logs(M, owner, "disarmed")

				if(owner.w_uniform)
					owner.w_uniform.add_fingerprint(M)
				var/obj/item/organ/limb/affecting = owner.get_organ(ran_zone(M.zone_sel.selecting))
				var/randn = rand(1, 100)
				if(randn <= 25)
					owner.apply_effect(2, WEAKEN, owner.run_armor_check(affecting, "melee"))
					playsound(owner, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					owner.visible_message("<span class='danger'>[M] has pushed [owner]!</span>",
									"<span class='userdanger'>[M] has pushed [owner]!</span>")
					owner.forcesay(hit_appends)
					return

				var/talked = 0	// BubbleWrap

				if(randn <= 60)
					//BubbleWrap: Disarming breaks a pull
					if(owner.pulling)
						owner.visible_message("<span class='warning'>[M] has broken [owner]'s grip on [owner.pulling]!</span>")
						talked = 1
						owner.stop_pulling()

					//BubbleWrap: Disarming also breaks a grab - this will also stop someone being choked, won't it?
					if(istype(owner.l_hand, /obj/item/weapon/grab))
						var/obj/item/weapon/grab/lgrab = owner.l_hand
						if(lgrab.affecting)
							owner.visible_message("<span class='warning'>[M] has broken [owner]'s grip on [lgrab.affecting]!</span>")
							talked = 1
						spawn(1)
							qdel(lgrab)
					if(istype(owner.r_hand, /obj/item/weapon/grab))
						var/obj/item/weapon/grab/rgrab = owner.r_hand
						if(rgrab.affecting)
							owner.visible_message("<span class='warning'>[M] has broken [owner]'s grip on [rgrab.affecting]!</span>")
							talked = 1
						spawn(1)
							qdel(rgrab)
					//End BubbleWrap

					if(!talked)	//BubbleWrap
						if(owner.drop_item())
							owner.visible_message("<span class='danger'>[M] has disarmed [owner]!</span>", \
											"<span class='userdanger'>[M] has disarmed [owner]!</span>")
					playsound(owner, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					return


				playsound(owner, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				owner.visible_message("<span class='danger'>[M] attempted to disarm [owner]!</span>", \
								"<span class='userdanger'>[M] attemped to disarm [owner]!</span>")
		return

	proc/spec_attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone, var/obj/item/organ/limb/affecting, var/hit_area, var/intent, var/obj/item/organ/limb/target_limb, target_area)
		// Allows you to put in item-specific reactions based on species
		if((user != owner) && owner.check_shields(I.force, "the [I.name]"))
			return 0

		if(I.attack_verb && I.attack_verb.len)
			owner.visible_message("<span class='danger'>[owner] has been [pick(I.attack_verb)] in the [hit_area] with [I] by [user]!</span>", \
							"<span class='userdanger'>[owner] has been [pick(I.attack_verb)] in the [hit_area] with [I] by [user]!</span>")
		else if(I.force)
			owner.visible_message("<span class='danger'>[owner] has been attacked in the [hit_area] with [I] by [user]!</span>", \
							"<span class='userdanger'>[owner] has been attacked in the [hit_area] with [I] by [user]!</span>")
		else
			return 0

		var/armor = owner.run_armor_check(affecting, "melee", "<span class='warning'>Your armour has protected your [hit_area].</span>", "<span class='warning'>Your armour has softened a hit to your [hit_area].</span>")
		if(armor >= 100)	return 0
		var/Iforce = I.force //to avoid runtimes on the forcesay checks at the bottom. Some items might delete themselves if you drop them. (stunning yourself, ninja swords)

		apply_damage(I.force, I.damtype, affecting, armor , I)

		var/bloody = 0
		if(((I.damtype == BRUTE) && prob(25 + (I.force * 2))))
			if(affecting.status == ORGAN_ORGANIC)
				I.add_blood(owner)	//Make the weapon bloody, not the person.
				if(prob(I.force * 2))	//blood spatter!
					bloody = 1
					var/turf/location = owner.loc
					if(istype(location, /turf/simulated))
						location.add_blood(owner)
					if(ishuman(user))
						var/mob/living/carbon/human/H = user
						if(get_dist(H, owner) <= 1)	//people with TK won't get smeared with blood
							if(H.wear_suit)
								H.wear_suit.add_blood(owner)
								H.update_inv_wear_suit(0)	//updates mob overlays to show the new blood (no refresh)
							else if(H.w_uniform)
								H.w_uniform.add_blood(owner)
								H.update_inv_w_uniform(0)	//updates mob overlays to show the new blood (no refresh)
							if (H.gloves)
								var/obj/item/clothing/gloves/G = H.gloves
								G.add_blood(H)
							else
								H.add_blood(H)
								H.update_inv_gloves()	//updates on-mob overlays for bloody hands and/or bloody gloves


			switch(hit_area)
				if("head")	//Harder to score a stun but if you do it lasts a bit longer
					if(owner.stat == CONSCIOUS && prob(I.force) && armor < 50)
						owner.visible_message("<span class='danger'>[owner] has been knocked unconscious!</span>", \
										"<span class='userdanger'>[owner] has been knocked unconscious!</span>")
						owner.apply_effect(20, PARALYZE, armor)
						if(owner != user && I.damtype == BRUTE)
							ticker.mode.remove_revolutionary(owner.mind)

					if(bloody)	//Apply blood
						if(owner.wear_mask)
							owner.wear_mask.add_blood(owner)
							owner.update_inv_wear_mask(0)
						if(owner.head)
							owner.head.add_blood(owner)
							owner.update_inv_head(0)
						if(owner.glasses && prob(33))
							owner.glasses.add_blood(owner)
							owner.update_inv_glasses(0)

				if("chest")	//Easier to score a stun but lasts less time
					if(owner.stat == CONSCIOUS && prob(I.force + 10))
						owner.visible_message("<span class='danger'>[owner] has been knocked down!</span>", \
										"<span class='userdanger'>[owner] has been knocked down!</span>")
						owner.apply_effect(5, WEAKEN, armor)

					if(bloody)
						if(owner.wear_suit)
							owner.wear_suit.add_blood(owner)
							owner.update_inv_wear_suit(0)
						if(owner.w_uniform)
							owner.w_uniform.add_blood(owner)
							owner.update_inv_w_uniform(0)

			if(Iforce > 10 || Iforce >= 5 && prob(33))
				owner.forcesay(hit_appends)	//forcesay checks stat already.
			return

	proc/attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone)
		owner.apply_damage(I.force, I.damtype)
		if(I.damtype == "brute")
			if(prob(33) && I.force && !("noblood" in specflags))
				var/turf/location = owner.loc
				if(istype(location, /turf/simulated))
					location.add_blood_floor(owner)

		var/showname = "."
		if(user)
			showname = " by [user]!"
		if(!(user in viewers(I, null)))
			showname = "."

		if(I.attack_verb && I.attack_verb.len)
			owner.visible_message("<span class='danger'>[owner] has been [pick(I.attack_verb)] with [I][showname]</span>",
			"<span class='userdanger'>[owner] has been [pick(I.attack_verb)] with [I][showname]</span>")
		else if(I.force)
			owner.visible_message("<span class='danger'>[owner] has been attacked with [I][showname]</span>",
			"<span class='userdanger'>[owner] has been attacked with [I][showname]</span>")
		if(!showname && user)
			if(user.client)
				user << "\red <B>You attack [owner] with [I]. </B>"

		return

	proc/apply_damage(var/damage = 0, var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0)
		blocked = (100-(blocked+armor))/100
		if(blocked <= 0)	return 0

		var/obj/item/organ/limb/organ = null
		if(isorgan(def_zone))
			organ = def_zone
		else
			if(!def_zone)	def_zone = ran_zone(def_zone)
			organ = owner.get_organ(check_zone(def_zone))
		if(!organ)	return 0

		damage = (damage * blocked)

		switch(damagetype)
			if(BRUTE)
				owner.damageoverlaytemp = 20
				if(organ.take_damage(damage*brutemod, 0))
					owner.update_damage_overlays(0)
			if(BURN)
				owner.damageoverlaytemp = 20
				if(organ.take_damage(0, damage*burnmod))
					owner.update_damage_overlays(0)

	proc/on_hit(var/obj/item/projectile/proj_type)
		// called when hit by a projectile
		switch(proj_type)
			if(/obj/item/projectile/energy/floramut) // overwritten by plants/pods
				owner.show_message("\blue The radiation beam dissipates harmlessly through your body.")
			if(/obj/item/projectile/energy/florayield)
				owner.show_message("\blue The radiation beam dissipates harmlessly through your body.")
		return

	/////////////
	//BREATHING//
	/////////////

	proc/breathe()
		if(owner.reagents.has_reagent("lexorin")) return
		if(istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell)) return

		var/datum/gas_mixture/environment = owner.loc.return_air()
		var/datum/gas_mixture/breath
		// HACK NEED CHANGING LATER
		if(owner.health <= config.health_threshold_crit)
			owner.losebreath++

		if(owner.losebreath>0) //Suffocating so do not take a breath
			owner.losebreath--
			if (prob(10)) //Gasp per 10 ticks? Sounds about right.
				spawn owner.emote("gasp")
			if(istype(owner.loc, /obj/))
				var/obj/location_as_object = owner.loc
				location_as_object.handle_internal_lifeform(owner, 0)
		else
			//First, check for air from internal atmosphere (using an air tank and mask generally)
			breath = owner.get_breath_from_internal(BREATH_VOLUME) // Super hacky -- TLE
			//breath = get_breath_from_internal(0.5) // Manually setting to old BREATH_VOLUME amount -- TLE

			//No breath from internal atmosphere so get breath from location
			if(!breath)
				if(isobj(owner.loc))
					var/obj/location_as_object = owner.loc
					breath = location_as_object.handle_internal_lifeform(owner, BREATH_VOLUME)
				else if(isturf(owner.loc))
					var/breath_moles = 0
					/*if(environment.return_pressure() > ONE_ATMOSPHERE)
						// Loads of air around (pressure effect will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
						breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
					else*/
						// Not enough air around, take a percentage of what's there to model this properly
					breath_moles = environment.total_moles()*BREATH_PERCENTAGE

					breath = owner.loc.remove_air(breath_moles)
					// Handle chem smoke effect  -- Doohl
					var/block = 0
					if(owner.wear_mask)
						if(owner.wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT)
							block = 1
					if(owner.glasses)
						if(owner.glasses.flags & BLOCK_GAS_SMOKE_EFFECT)
							block = 1
					if(owner.head)
						if(owner.head.flags & BLOCK_GAS_SMOKE_EFFECT)
							block = 1

					if(!block)

						for(var/obj/effect/effect/chem_smoke/smoke in view(1, owner))
							if(smoke.reagents.total_volume)
								smoke.reagents.reaction(owner, INGEST)
								spawn(5)
									if(smoke)
										smoke.reagents.copy_to(owner, 10) // I dunno, maybe the reagents enter the blood stream through the lungs?
								break // If they breathe in the nasty stuff once, no need to continue checking

			else //Still give containing object the chance to interact
				if(istype(owner.loc, /obj/))
					var/obj/location_as_object = owner.loc
					location_as_object.handle_internal_lifeform(owner, 0)

		handle_breath(breath)

		if(breath)
			owner.loc.assume_air(breath)

	proc/handle_breath(datum/gas_mixture/breath)
		if((owner.status_flags & GODMODE))
			return

		if(!breath || (breath.total_moles() == 0) || owner.suiciding)
			if(owner.reagents.has_reagent("inaprovaline"))
				return
			if(owner.suiciding)
				owner.adjustOxyLoss(2)//If you are suiciding, you should die a little bit faster
				owner.failed_last_breath = 1
				owner.oxygen_alert = max(owner.oxygen_alert, 1)
				return 0
			if(owner.health >= config.health_threshold_crit)
				if("nobreath" in specflags)	return 1
				owner.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
				owner.failed_last_breath = 1
			else
				owner.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)
				owner.failed_last_breath = 1

			owner.oxygen_alert = max(owner.oxygen_alert, 1)

			return 0

		var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
		//var/safe_oxygen_max = 140 // Maximum safe partial pressure of O2, in kPa (Not used for now)
		var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
		var/safe_toxins_max = 0.005
		var/SA_para_min = 1
		var/SA_sleep_min = 5
		var/oxygen_used = 0
		var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

		//Partial pressure of the O2 in our breath
		var/O2_pp = (breath.oxygen/breath.total_moles())*breath_pressure
		// Same, but for the toxins
		var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure
		// And CO2, lets say a PP of more than 10 will be bad (It's a little less really, but eh, being passed out all round aint no fun)
		var/CO2_pp = (breath.carbon_dioxide/breath.total_moles())*breath_pressure // Tweaking to fit the hacky bullshit I've done with atmo -- TLE
		//var/CO2_pp = (breath.carbon_dioxide/breath.total_moles())*0.5 // The default pressure value

		if(O2_pp < safe_oxygen_min) // Too little oxygen
			if(!("nobreath" in specflags) || (owner.health <= config.health_threshold_crit))
				if(prob(20))
					spawn(0) owner.emote("gasp")
				if(O2_pp > 0)
					var/ratio = safe_oxygen_min/O2_pp
					owner.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!)
					owner.failed_last_breath = 1
					oxygen_used = breath.oxygen*ratio/6
				else
					owner.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
					owner.failed_last_breath = 1
				owner.oxygen_alert = max(owner.oxygen_alert, 1)
			/*else if (O2_pp > safe_oxygen_max) 		// Too much oxygen (commented this out for now, I'll deal with pressure damage elsewhere I suppose)
				spawn(0) emote("cough")
				var/ratio = O2_pp/safe_oxygen_max
				oxyloss += 5*ratio
				oxygen_used = breath.oxygen*ratio/6
				oxygen_alert = max(oxygen_alert, 1)*/
		else								// We're in safe limits
			owner.failed_last_breath = 0
			owner.adjustOxyLoss(-5)
			oxygen_used = breath.oxygen/6
			owner.oxygen_alert = 0

		breath.oxygen -= oxygen_used
		breath.carbon_dioxide += oxygen_used

		//CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2, this will hurt you, but only once per 4 ticks, instead of once per tick.
		if(CO2_pp > safe_co2_max && !("nobreath" in specflags))
			if(!owner.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
				owner.co2overloadtime = world.time
			else if(world.time - owner.co2overloadtime > 120)
				owner.Paralyse(3)
				owner.adjustOxyLoss(3) // Lets hurt em a little, let them know we mean business
				if(world.time - owner.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
					owner.adjustOxyLoss(8)
			if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
				spawn(0) owner.emote("cough")

		else
			owner.co2overloadtime = 0

		if(Toxins_pp > safe_toxins_max && !("nobreath" in specflags)) // Too much toxins
			var/ratio = (breath.toxins/safe_toxins_max) * 10
			//adjustToxLoss(Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))	//Limit amount of damage toxin exposure can do per second
			if(owner.reagents)
				owner.reagents.add_reagent("plasma", Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
			owner.toxins_alert = max(owner.toxins_alert, 1)
		else
			owner.toxins_alert = 0

		if(breath.trace_gases.len && !("nobreath" in specflags))	// If there's some other shit in the air lets deal with it here.
			for(var/datum/gas/sleeping_agent/SA in breath.trace_gases)
				var/SA_pp = (SA.moles/breath.total_moles())*breath_pressure
				if(SA_pp > SA_para_min) // Enough to make us paralysed for a bit
					owner.Paralyse(3) // 3 gives them one second to wake up and run away a bit!
					if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
						owner.sleeping = max(owner.sleeping+2, 10)
				else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
					if(prob(20))
						spawn(0) owner.emote(pick("giggle", "laugh"))

		handle_temperature(breath)

		return 1

	proc/handle_temperature(datum/gas_mixture/breath) // called by human/life, handles temperatures
		if( (abs(310.15 - breath.temperature) > 50) && !(COLD_RESISTANCE in owner.mutations) && !("resists_cold" in specflags)) // Hot air hurts :(
			if(breath.temperature < 260.15)
				if(prob(20))
					owner << "\red You feel your face freezing and an icicle forming in your lungs!"
			else if(breath.temperature > 360.15 && !("resists_heat" in specflags))
				if(prob(20))
					owner << "\red You feel your face burning and a searing heat in your lungs!"

			if(!("resists_cold" in specflags)) // COLD DAMAGE
				switch(breath.temperature)
					if(-INFINITY to 120)
						owner.apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, "head")
						owner.fire_alert = max(owner.fire_alert, 1)
					if(120 to 200)
						owner.apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, "head")
						owner.fire_alert = max(owner.fire_alert, 1)
					if(200 to 260)
						owner.apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, "head")
						owner.fire_alert = max(owner.fire_alert, 1)

			if(!("resists_heat" in specflags)) // HEAT DAMAGE
				switch(breath.temperature)
					if(360 to 400)
						owner.apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, "head")
						owner.fire_alert = max(owner.fire_alert, 2)
					if(400 to 1000)
						owner.apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, "head")
						owner.fire_alert = max(owner.fire_alert, 2)
					if(1000 to INFINITY)
						owner.apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, "head")
						owner.fire_alert = max(owner.fire_alert, 2)

		return

	proc/handle_environment(datum/gas_mixture/environment)
		if(!environment)
			return

		var/loc_temp = owner.get_temperature(environment)
		//world << "Loc temp: [loc_temp] - Body temp: [bodytemperature] - Fireloss: [getFireLoss()] - Thermal protection: [get_thermal_protection()] - Fire protection: [thermal_protection + add_fire_protection(loc_temp)] - Heat capacity: [environment_heat_capacity] - Location: [loc] - src: [src]"

		//Body temperature is adjusted in two steps. Firstly your body tries to stabilize itself a bit.
		if(owner.stat != 2)
			owner.stabilize_temperature_from_calories()

		//After then, it reacts to the surrounding atmosphere based on your thermal protection
		if(!owner.on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
			if(loc_temp < owner.bodytemperature)
				//Place is colder than we are
				var/thermal_protection = owner.get_cold_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
				if(thermal_protection < 1)
					owner.bodytemperature += min((1-thermal_protection) * ((loc_temp - owner.bodytemperature) / BODYTEMP_COLD_DIVISOR), BODYTEMP_COOLING_MAX)
			else
				//Place is hotter than we are
				var/thermal_protection = owner.get_heat_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
				if(thermal_protection < 1)
					owner.bodytemperature += min((1-thermal_protection) * ((loc_temp - owner.bodytemperature) / BODYTEMP_HEAT_DIVISOR), BODYTEMP_HEATING_MAX)

		// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
		if(owner.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT && !("resists_heat" in specflags))
			//Body temperature is too hot.
			owner.fire_alert = max(owner.fire_alert, 1)
			switch(owner.bodytemperature)
				if(360 to 400)
					owner.apply_damage(HEAT_DAMAGE_LEVEL_1*heatmod, BURN)
					owner.fire_alert = max(owner.fire_alert, 2)
				if(400 to 460)
					owner.apply_damage(HEAT_DAMAGE_LEVEL_2*heatmod, BURN)
					owner.fire_alert = max(owner.fire_alert, 2)
				if(460 to INFINITY)
					if(owner.on_fire)
						owner.apply_damage(HEAT_DAMAGE_LEVEL_3*heatmod, BURN)
						owner.fire_alert = max(owner.fire_alert, 2)
					else
						owner.apply_damage(HEAT_DAMAGE_LEVEL_2*heatmod, BURN)
						owner.fire_alert = max(owner.fire_alert, 2)

		else if(owner.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !("resists_cold" in specflags))
			owner.fire_alert = max(owner.fire_alert, 1)
			if(!istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell))
				switch(owner.bodytemperature)
					if(200 to 260)
						owner.apply_damage(COLD_DAMAGE_LEVEL_1*coldmod, BURN)
						owner.fire_alert = max(owner.fire_alert, 1)
					if(120 to 200)
						apply_damage(COLD_DAMAGE_LEVEL_2*coldmod, BURN)
						owner.fire_alert = max(owner.fire_alert, 1)
					if(-INFINITY to 120)
						apply_damage(COLD_DAMAGE_LEVEL_3*coldmod, BURN)
						owner.fire_alert = max(owner.fire_alert, 1)

		// Account for massive pressure differences.  Done by Polymorph
		// Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!

		var/pressure = environment.return_pressure()
		var/adjusted_pressure = owner.calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
		switch(adjusted_pressure)
			if(HAZARD_HIGH_PRESSURE to INFINITY)
				if(!("resists_heat" in specflags))
					owner.adjustBruteLoss( min( ( (adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
					owner.pressure_alert = 2
				else
					owner.pressure_alert = 1
			if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
				owner.pressure_alert = 1
			if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
				owner.pressure_alert = 0
			if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
				owner.pressure_alert = -1
			else
				if((COLD_RESISTANCE in owner.mutations) || ("resists_cold" in specflags))
					owner.pressure_alert = -1
				else
					owner.adjustBruteLoss( LOW_PRESSURE_DAMAGE )
					owner.pressure_alert = -2

		return

	//////////
	// FIRE //
	//////////

	proc/handle_fire()
		if("resists_heat" in specflags || "nonflammable" in specflags)
			return
		if(owner.fire_stacks < 0)
			owner.fire_stacks++ //If we've doused ourselves in water to avoid fire, dry off slowly
			owner.fire_stacks = min(0, owner.fire_stacks)//So we dry ourselves back to default, nonflammable.
		if(!owner.on_fire)
			return
		var/datum/gas_mixture/G = owner.loc.return_air() // Check if we're standing in an oxygenless environment
		if(G.oxygen < 1)
			ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
			return
		var/turf/location = get_turf(owner)
		location.hotspot_expose(700, 50, 1)

	proc/IgniteMob()
		if(owner.fire_stacks > 0 && !owner.on_fire && !("resists_heat" in specflags) && !("nonflammable" in specflags))
			owner.on_fire = 1
			owner.AddLuminosity(3)
			owner.update_fire()

	proc/ExtinguishMob()
		if(owner.on_fire)
			owner.on_fire = 0
			owner.fire_stacks = 0
			owner.AddLuminosity(-3)
			owner.update_fire()

#undef SPECIES_LAYER
#undef BODY_LAYER
#undef HAIR_LAYER

#undef HUMAN_MAX_OXYLOSS
#undef HUMAN_CRIT_MAX_OXYLOSS

#undef HEAT_DAMAGE_LEVEL_1
#undef HEAT_DAMAGE_LEVEL_2
#undef HEAT_DAMAGE_LEVEL_3

#undef COLD_DAMAGE_LEVEL_1
#undef COLD_DAMAGE_LEVEL_2
#undef COLD_DAMAGE_LEVEL_3

#undef HEAT_GAS_DAMAGE_LEVEL_1
#undef HEAT_GAS_DAMAGE_LEVEL_2
#undef HEAT_GAS_DAMAGE_LEVEL_3

#undef COLD_GAS_DAMAGE_LEVEL_1
#undef COLD_GAS_DAMAGE_LEVEL_2
#undef COLD_GAS_DAMAGE_LEVEL_3

#undef TINT_IMPAIR
#undef TINT_BLIND