//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/global/list/space_surprises = list(				/obj/item/clothing/mask/facehugger/angry			=4,
												//	/obj/effect/critter/spesscarp						=2,
													/obj/effect/critter/spesscarp/elite					=2,
												//	/obj/creature										=0,
												//	/obj/item/weapon/rcd								=0,
												//	/obj/item/weapon/rcd_ammo							=0,
												//	/obj/item/weapon/spacecash							=0,
												//	/obj/item/weapon/cloaking_device					=1,
												//	/obj/item/weapon/gun/energy/teleport_gun			=0,
												//	/obj/item/weapon/rubber_chicken						=0,
													/obj/item/weapon/melee/energy/sword/pirate			=3,
													/obj/structure/closet/syndicate/resources			=2,
												//	/obj/machinery/wish_granter							=1,  // Okayyyy... Mayyyybe Kor is kinda sorta right.  A little.  Tiny bit.  >.>
												//	/obj/item/clothing/glasses/thermal					=2,	// Could maybe be cool as its own rapid mode, sorta like wizard.  Maybe.
												//	/obj/item/weapon/storage/box/stealth/				=2

												//														=11
													)

var/global/list/spawned_surprises = list()







/obj/machinery/wish_granter
	name = "Wish Granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'device.dmi'
	icon_state = "syndbeacon"

	anchored = 1
	density = 1

	var/charges = 1
	var/insisting = 0

/obj/machinery/wish_granter/attack_hand(var/mob/user as mob)
	usr.machine = src

	if(charges <= 0)
		user << "The Wish Granter lies silent."
		return

	else if(!istype(user, /mob/living/carbon/human))
		user << "You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's."
		return

	else if(is_special_character(user))
		user << "Even to a heart as dark as yours, you know nothing good will come of this.  Something instinctual makes you pull away."

	else if (!insisting)
		user << "Your first touch makes the Wish Granter stir, listening to you.  Are you really sure you want to do this?"
		insisting++

	else
		user << "You speak.  [pick("I want the station to disappear","Humanity is corrupt, mankind must be destroyed","I want to be rich", "I want to rule the world","I want immortality.")].  The Wish Granter answers."
		user << "Your head pounds for a moment, before your vision clears.  You are the avatar of the Wish Granter, and your power is LIMITLESS!  And it's all yours.  You need to make sure no one can take it from you.  No one can know, first."

		charges--
		insisting = 0

		if (!(user.mutations & HULK))
			user.mutations |= HULK

		if (!(user.mutations & LASER))
			user.mutations |= LASER

		if (!(user.mutations & XRAY))
			user.mutations |= XRAY
			user.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
			user.see_in_dark = 8
			user.see_invisible = 2

		if (!(user.mutations & COLD_RESISTANCE))
			user.mutations |= COLD_RESISTANCE

		if (!(user.mutations & TK))
			user.mutations |= TK

		if(!(user.mutations & HEAL))
			user.mutations |= HEAL

		ticker.mode.traitors += user.mind
		user.mind.special_role = "Avatar of the Wish Granter"

		var/datum/objective/silence/silence = new
		silence.owner = user.mind
		user.mind.objectives += silence

		var/obj_count = 1
		for(var/datum/objective/OBJ in user.mind.objectives)
			user << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
			obj_count++

		world << "You have a very bad feeling about this."

	return

/obj/item/weapon/storage/box/stealth/
	name = "Infiltration Gear"
	desc = "An old box full of old equipment.  It doesn't look like it was ever opened."


/obj/item/weapon/storage/box/stealth/New()
	..()

	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/mask/gas/voice(src)
	new /obj/item/weapon/card/id/syndicate(src)
	new /obj/item/clothing/shoes/syndigaloshes(src)
	return
