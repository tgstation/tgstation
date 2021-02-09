/obj/item/clothing/gloves/color
	dying_key = DYE_REGISTRY_GLOVES

/obj/item/clothing/gloves/color/yellow
	desc = "These gloves provide protection against electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	resistance_flags = NONE
	custom_price = PAYCHECK_MEDIUM * 10
	custom_premium_price = PAYCHECK_COMMAND * 6
	cut_type = /obj/item/clothing/gloves/cut

/obj/item/toy/sprayoncan
	name = "spray-on insulation applicator"
	desc = "What is the number one problem facing our station today?"
	icon = 'icons/obj/clothing/gloves.dmi'
	icon_state = "sprayoncan"

/obj/item/toy/sprayoncan/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(iscarbon(target) && proximity)
		var/mob/living/carbon/C = target
		var/mob/living/carbon/U = user
		var/success = C.equip_to_slot_if_possible(new /obj/item/clothing/gloves/color/yellow/sprayon, ITEM_SLOT_GLOVES, qdel_on_fail = TRUE, disable_warning = TRUE)
		if(success)
			if(C == user)
				C.visible_message("<span class='notice'>[U] sprays their hands with glittery rubber!</span>")
			else
				C.visible_message("<span class='warning'>[U] sprays glittery rubber on the hands of [C]!</span>")
		else
			C.visible_message("<span class='warning'>The rubber fails to stick to [C]'s hands!</span>")

/obj/item/clothing/gloves/color/yellow/sprayon
	desc = "How're you gonna get 'em off, nerd?"
	name = "spray-on insulated gloves"
	icon_state = "sprayon"
	inhand_icon_state = "sprayon"
	item_flags = DROPDEL
	permeability_coefficient = 0
	resistance_flags = ACID_PROOF
	var/charges_remaining = 10

/obj/item/clothing/gloves/color/yellow/sprayon/Initialize()
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/gloves/color/yellow/sprayon/equipped(mob/user, slot)
	. = ..()
	RegisterSignal(user, COMSIG_LIVING_SHOCK_PREVENTED, .proc/use_charge)
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, .proc/use_charge)

/obj/item/clothing/gloves/color/yellow/sprayon/proc/use_charge()
	SIGNAL_HANDLER

	charges_remaining--
	if(charges_remaining <= 0)
		var/turf/location = get_turf(src)
		location.visible_message("<span class='warning'>[src] crumble[p_s()] away into nothing.</span>") // just like my dreams after working with .dm
		qdel(src)

/obj/item/clothing/gloves/color/fyellow                             //Cheap Chinese Crap
	desc = "These gloves are cheap knockoffs of the coveted ones - no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in Initialize()
	permeability_coefficient = 0.05
	resistance_flags = NONE
	cut_type = /obj/item/clothing/gloves/cut

/obj/item/clothing/gloves/color/fyellow/Initialize()
	. = ..()
	siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)

/obj/item/clothing/gloves/color/fyellow/old
	desc = "Old and worn out insulated gloves, hopefully they still work."
	name = "worn out insulated gloves"

/obj/item/clothing/gloves/color/fyellow/old/Initialize()
	. = ..()
	siemens_coefficient = pick(0,0,0,0.5,0.5,0.5,0.75)

/obj/item/clothing/gloves/cut
	desc = "These gloves would protect the wearer from electric shock... if the fingers were covered."
	name = "fingerless insulated gloves"
	icon_state = "yellowcut"
	inhand_icon_state = "ygloves"
	transfer_prints = TRUE

/obj/item/clothing/gloves/cut/heirloom
	desc = "The old gloves your great grandfather stole from Engineering, many moons ago. They've seen some tough times recently."

/obj/item/clothing/gloves/color/black
	desc = "These gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	inhand_icon_state = "blackgloves"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	cut_type = /obj/item/clothing/gloves/fingerless

/obj/item/clothing/gloves/color/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	inhand_icon_state = "orangegloves"

/obj/item/clothing/gloves/color/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	inhand_icon_state = "redgloves"


/obj/item/clothing/gloves/color/red/insulated
	name = "insulated gloves"
	desc = "These gloves provide protection against electric shock."
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	resistance_flags = NONE

/obj/item/clothing/gloves/color/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	inhand_icon_state = "rainbowgloves"

/obj/item/clothing/gloves/color/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	inhand_icon_state = "bluegloves"

/obj/item/clothing/gloves/color/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	inhand_icon_state = "purplegloves"

/obj/item/clothing/gloves/color/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	inhand_icon_state = "greengloves"

/obj/item/clothing/gloves/color/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	inhand_icon_state = "graygloves"

/obj/item/clothing/gloves/color/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	inhand_icon_state = "lightbrowngloves"

/obj/item/clothing/gloves/color/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	inhand_icon_state = "browngloves"

/obj/item/clothing/gloves/color/captain
	desc = "Regal blue gloves, with a nice gold trim, a diamond anti-shock coating, and an integrated thermal barrier. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	inhand_icon_state = "egloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 60
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 70, ACID = 50)

/obj/item/clothing/gloves/color/infiltrator
	name = "infiltrator gloves"
	desc = "Specialized combat gloves that alter your unarmed strikes to deliver empowered or nonlethal blows. You can swap between modes using Alt-Click!"
	icon_state = "infiltrator"
	base_icon_state = "infiltrator"
	inhand_icon_state = "infiltrator"
	siemens_coefficient = 0
	permeability_coefficient = 0.3
	strip_delay = 80
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	///Have we worn these gloves?
	var/wornonce = FALSE
	///What damage do the gloves make our punches?
	var/currentdamage = BRUTE
	///What sound are we replacing our attacks with?
	var/replacing_attack_sound = 'sound/weapons/kenetic_accel.ogg'

/obj/item/clothing/gloves/color/infiltrator/examine(mob/user)
	. = ..()
	. += "<span class='notice'>\The [src] are currently set to [currentdamage].</span>"

/obj/item/clothing/gloves/color/infiltrator/AltClick(mob/living/carbon/human/user)
	switch(currentdamage)
		if(STAMINA)
			currentdamage = BRUTE
			to_chat(user, "<span class='warning'>You change the gloves to empowered kinetic blows.</span>")
			replacing_attack_sound = 'sound/weapons/kenetic_accel.ogg' //it's like a pka for your hands!
			update_icon()
		if(BRUTE)
			currentdamage = STAMINA
			to_chat(user, "<span class='warning'>You change the gloves to softened concussive blows.</span>")
			replacing_attack_sound = 'sound/weapons/egloves.ogg' //we have come full circle
			update_icon()
	
	if(wornonce)
		applyglovebuffs(user, TRUE, FALSE)

/obj/item/clothing/gloves/color/infiltrator/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		applyglovebuffs(user, TRUE, TRUE)
		wornonce = TRUE

/obj/item/clothing/gloves/color/infiltrator/dropped(mob/living/carbon/human/user)
	if(wornonce)
		applyglovebuffs(user, FALSE, FALSE)
		wornonce = FALSE
	return ..()

/obj/item/clothing/gloves/color/infiltrator/proc/applyglovebuffs(mob/living/carbon/human/user, buff, first_buff)
	if(buff)
		user.dna.species.attack_type = currentdamage
		user.dna.species.attack_sound = replacing_attack_sound
		if(first_buff)
			ADD_TRAIT(user, TRAIT_RESOLUTE_TECHNIQUE, GLOVE_TRAIT)
			ADD_TRAIT(user, TRAIT_FACEBREAKER, GLOVE_TRAIT)
	else
		REMOVE_TRAIT(user, TRAIT_RESOLUTE_TECHNIQUE, GLOVE_TRAIT)
		REMOVE_TRAIT(user, TRAIT_FACEBREAKER, GLOVE_TRAIT)
		user.dna.species.attack_type = initial(user.dna.species.attack_type)
		user.dna.species.attack_sound = initial(user.dna.species.attack_sound)

/obj/item/clothing/gloves/color/infiltrator/update_icon_state()
	if(currentdamage == STAMINA)
		icon_state = "[base_icon_state]_stamina"
	else
		icon_state = "[base_icon_state]"

/obj/item/clothing/gloves/color/latex
	name = "latex gloves"
	desc = "Cheap sterile gloves made from latex. Transfers minor paramedic knowledge to the user via budget nanochips."
	icon_state = "latex"
	inhand_icon_state = "latex"
	siemens_coefficient = 0.3
	permeability_coefficient = 0.01
	transfer_prints = TRUE
	resistance_flags = NONE

/obj/item/clothing/gloves/color/latex/nitrile
	name = "nitrile gloves"
	desc = "Pricy sterile gloves that are thicker than latex. Transfers intimate paramedic knowledge into the user via nanochips."
	icon_state = "nitrile"
	inhand_icon_state = "nitrilegloves"
	transfer_prints = FALSE

/obj/item/clothing/gloves/color/latex/engineering
	name = "tinker's gloves"
	desc = "Overdesigned engineering gloves that have automated construction subrutines dialed in, allowing for faster construction while worn."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_gauntlets"
	inhand_icon_state = "clockwork_gauntlets"
	siemens_coefficient = 0.8
	permeability_coefficient = 0.3
	clothing_traits = list(TRAIT_QUICK_BUILD)
	custom_materials = list(/datum/material/iron=2000, /datum/material/silver=1500, /datum/material/gold = 1000)

/obj/item/clothing/gloves/color/white
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"
	inhand_icon_state = "wgloves"
	custom_price = PAYCHECK_MINIMAL

/obj/effect/spawner/lootdrop/gloves
	name = "random gloves"
	desc = "These gloves are supposed to be a random color..."
	icon = 'icons/obj/clothing/gloves.dmi'
	icon_state = "random_gloves"
	loot = list(
		/obj/item/clothing/gloves/color/orange = 1,
		/obj/item/clothing/gloves/color/red = 1,
		/obj/item/clothing/gloves/color/blue = 1,
		/obj/item/clothing/gloves/color/purple = 1,
		/obj/item/clothing/gloves/color/green = 1,
		/obj/item/clothing/gloves/color/grey = 1,
		/obj/item/clothing/gloves/color/light_brown = 1,
		/obj/item/clothing/gloves/color/brown = 1,
		/obj/item/clothing/gloves/color/white = 1,
		/obj/item/clothing/gloves/color/rainbow = 1)
