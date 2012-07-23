//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = 0
	anchored = 1

/obj/structure/mirror/attack_hand(mob/user as mob)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		var/userloc = H.loc

		//see code/modules/mob/new_player/preferences.dm at approx line 545 for comments!
		//this is largely copypasted from there.

		//handle facial hair (if necessary)
		if(H.gender == MALE)
			var/list/all_fhairs = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair	//this would probably be better as a global list
			var/list/fhairs = list()
			for(var/x in all_fhairs)
				var/datum/sprite_accessory/facial_hair/F = new x	//this goes for the original in preferences too, but it'd
				fhairs.Add(F.name)									//be nice to avoid all this instantiation and deletion...
				del(F)

			var/new_style = input(user, "Select a facial hair style", "Grooming")  as null|anything in fhairs
			if(userloc != H.loc) return	//no tele-grooming
			if(new_style)
				for(var/x in all_fhairs)
					var/datum/sprite_accessory/facial_hair/F = new x
					if(F.name == new_style)
						H.facial_hair_style.icon_state = F.icon_state	//we only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
						break
					else
						del(F)

		//handle normal hair
		var/list/all_hairs = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair	//this would probably be better as a global list
		var/list/hairs = list()
		for(var/x in all_hairs)
			var/datum/sprite_accessory/facial_hair/F = new x
			hairs.Add(F.name)
			del(F)

		var/new_style = input(user, "Select a hair style", "Grooming")  as null|anything in hairs
		if(userloc != H.loc) return	//no tele-grooming
		if(new_style)
			for(var/x in all_hairs)
				var/datum/sprite_accessory/hair/F = new x
				if(F.name == new_style)
					H.hair_style.icon_state = F.icon_state	//we only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
					break
				else
					del(F)

		H.update_hair()