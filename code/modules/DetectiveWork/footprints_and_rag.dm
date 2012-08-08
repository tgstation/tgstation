//CONTAINS: Bloody footprints code, code for managing blood incompatability, and a rag to wipe away evidence.

obj/item/clothing/shoes/var
	track_blood = 0
	mob/living/carbon/human/track_blood_mob
	track_blood_type
mob/var
	bloody_hands = 0
	mob/living/carbon/human/bloody_hands_mob
	track_blood
	mob/living/carbon/human/track_blood_mob
	track_blood_type
obj/item/clothing/gloves/var
	transfer_blood = 0
	mob/living/carbon/human/bloody_hands_mob


/*obj/effect/decal/cleanable/var
	track_amt = 3
	mob/blood_owner

turf/Exited(mob/living/carbon/human/M)
	if(istype(M,/mob/living) && !istype(M,/mob/living/carbon/metroid))
		if(!istype(src, /turf/space))  // Bloody tracks code starts here
			var/dofoot = 1
			if(istype(M,/mob/living/simple_animal))
				if(!(istype(M,/mob/living/simple_animal/cat) || istype(M,/mob/living/simple_animal/corgi) || istype(M,/mob/living/simple_animal/constructwraith)))
					dofoot = 0

			if(dofoot)

				if(!istype(src, /turf/space))  // Bloody tracks code starts here
					if(M.track_blood > 0)
						M.track_blood--
						src.add_bloody_footprints(M.track_blood_mob,1,M.dir,get_tracks(M),M.track_blood_type)
					else if(istype(M,/mob/living/carbon/human))
						if(M.shoes && istype(M.shoes,/obj/item/clothing/shoes))
							var/obj/item/clothing/shoes/S = M.shoes
							if(S.track_blood > 0)
								S.track_blood--
								src.add_bloody_footprints(S.track_blood_mob,1,M.dir,S.name,S.track_blood_type) // And bloody tracks end here
		. = ..()
turf/Entered(mob/living/carbon/human/M)
	if(istype(M,/mob/living) && !istype(M,/mob/living/carbon/metroid))
		var/dofoot = 1
		if(istype(M,/mob/living/simple_animal))
			if(!(istype(M,/mob/living/simple_animal/cat) || istype(M,/mob/living/simple_animal/corgi) || istype(M,/mob/living/simple_animal/constructwraith)))
				dofoot = 0

		if(dofoot)

			if(M.track_blood > 0)
				M.track_blood--
				src.add_bloody_footprints(M.track_blood_mob,0,M.dir,get_tracks(M),M.track_blood_type)
			else if(istype(M,/mob/living/carbon/human))
				if(M.shoes && istype(M.shoes,/obj/item/clothing/shoes) && !istype(src,/turf/space))
					var/obj/item/clothing/shoes/S = M.shoes
					if(S.track_blood > 0)
						S.track_blood--
						src.add_bloody_footprints(S.track_blood_mob,0,M.dir,S.name,S.track_blood_type)


			for(var/obj/effect/decal/cleanable/B in src)
				if(B:track_amt <= 0) continue
				if(B.type != /obj/effect/decal/cleanable/blood/tracks)
					if(istype(B, /obj/effect/decal/cleanable/xenoblood) || istype(B, /obj/effect/decal/cleanable/blood) || istype(B, /obj/effect/decal/cleanable/oil) || istype(B, /obj/effect/decal/cleanable/robot_debris))

						var/track_type = "blood"
						if(istype(B, /obj/effect/decal/cleanable/xenoblood))
							track_type = "xeno"
						else if(istype(B, /obj/effect/decal/cleanable/oil) || istype(B, /obj/effect/decal/cleanable/robot_debris))
							track_type = "oil"

						if(istype(M,/mob/living/carbon/human))
							if(M.shoes && istype(M.shoes,/obj/item/clothing/shoes))
								var/obj/item/clothing/shoes/S = M.shoes
								S.add_blood(B.blood_owner)
								S.track_blood_mob = B.blood_owner
								S.track_blood = max(S.track_blood,8)
								S.track_blood_type = track_type
						else
							M.add_blood(B.blood_owner)
							M.track_blood_mob = B.blood_owner
							M.track_blood = max(M.track_blood,rand(4,8))
							M.track_blood_type = track_type
						B.track_amt--
						break
	. = ..()

turf/proc/add_bloody_footprints(mob/living/carbon/human/M,leaving,d,info,bloodcolor)
	for(var/obj/effect/decal/cleanable/blood/tracks/T in src)
		if(T.dir == d && findtext(T.icon_state, bloodcolor))
			if((leaving && T.icon_state == "steps2") || (!leaving && T.icon_state == "steps1"))
				T.desc = "These bloody footprints appear to have been made by [info]."
				if(!T.blood_DNA)
					T.blood_DNA = list()
				if(istype(M,/mob/living/carbon/human))
					T.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
				else if(istype(M,/mob/living/carbon/alien))
					T.blood_DNA["UNKNOWN DNA"] = "X*"
				else if(istype(M,/mob/living/carbon/monkey))
					T.blood_DNA["Non-human DNA"] = "A+"
				return
	var/obj/effect/decal/cleanable/blood/tracks/this = new(src)
	this.icon = 'footprints.dmi'

	var/preiconstate = ""

	if(info == "animal paws")
		preiconstate = "paw"
	else if(info == "alien claws")
		preiconstate = "claw"
	else if(info == "small alien feet")
		preiconstate = "paw"

	if(leaving)
		this.icon_state = "[bloodcolor][preiconstate]2"
	else
		this.icon_state = "[bloodcolor][preiconstate]1"
	this.dir = d

	if(bloodcolor == "blood")
		this.desc = "These bloody footprints appear to have been made by [info]."
	else if(bloodcolor == "xeno")
		this.desc = "These acidic bloody footprints appear to have been made by [info]."
	else if(bloodcolor == "oil")
		this.name = "oil"
		this.desc = "These oil footprints appear to have been made by [info]."

	if(istype(M,/mob/living/carbon/human))
		if(!this.blood_DNA)
			this.blood_DNA = list()
		this.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type

proc/get_tracks(mob/M)
	if(istype(M,/mob/living))
		if(istype(M,/mob/living/carbon/human))
			. = "human feet"
		else if(istype(M,/mob/living/carbon/monkey) || istype(M,/mob/living/simple_animal/cat) || istype(M,/mob/living/simple_animal/corgi) || istype(M,/mob/living/simple_animal/crab))
			. = "animal paws"
		else if(istype(M,/mob/living/silicon/robot))
			. = "robot feet"
		else if(istype(M,/mob/living/carbon/alien/humanoid))
			. = "alien claws"
		else if(istype(M,/mob/living/carbon/alien/larva))
			. = "small alien feet"
		else
			. = "an unknown creature"*/


proc/blood_incompatible(donor,receiver)
	var
		donor_antigen = copytext(donor,1,lentext(donor))
		receiver_antigen = copytext(receiver,1,lentext(receiver))
		donor_rh = findtext("+",donor)
		receiver_rh = findtext("+",receiver)
	if(donor_rh && !receiver_rh) return 1
	switch(receiver_antigen)
		if("A")
			if(donor_antigen != "A" && donor_antigen != "O") return 1
		if("B")
			if(donor_antigen != "B" && donor_antigen != "O") return 1
		if("O")
			if(donor_antigen != "O") return 1
		//AB is a universal receiver.
	return 0

/obj/item/weapon/reagent_containers/glass/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = 1
	icon = 'toy.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5)
	volume = 5
	can_be_placed_into = null

	attack(atom/target as obj|turf|area, mob/user as mob , flag)
		if(ismob(target) && target.reagents && reagents.total_volume)
			user.visible_message("\red \The [target] has been smothered with \the [src] by \the [user]!", "\red You smother \the [target] with \the [src]!", "You hear some struggling and muffled cries of surprise")
			src.reagents.reaction(target, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return
		else
			..()

	afterattack(atom/A as obj|turf|area, mob/user as mob)
		if(istype(A) && src in user)
			user.visible_message("\The [user] starts to wipe down \a [A] with \a [src]!", "You start to wipe down \the [A].", "You hear a damp rag being rubbed against something.")
			if(do_after(user,30))
				user.visible_message("\The [user] finishes wiping off \a [A]!", "You finish wiping down \the [A].")
				A.clean_blood()
		return

	examine()
		if (!usr)
			return
		usr << "That's \a [src]."
		usr << desc
		return