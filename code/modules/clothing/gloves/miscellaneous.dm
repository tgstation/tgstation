
/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "Plain black gloves without fingertips for the hard working."
	icon_state = "fingerless"
	inhand_icon_state = "fingerless"
	transfer_prints = TRUE
	strip_delay = 40
	equip_delay_other = 20
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	custom_price = PAYCHECK_ASSISTANT * 1.5
	undyeable = TRUE

/obj/item/clothing/gloves/botanic_leather
	name = "botanist's leather gloves"
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin.  They're also quite warm."
	icon_state = "leather"
	inhand_icon_state = "ggloves"
	permeability_coefficient = 0.9
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 70, ACID = 30)

/obj/item/clothing/gloves/combat
	name = "combat gloves"
	desc = "These tactical gloves are fireproof and electrically insulated."
	icon_state = "black"
	inhand_icon_state = "blackgloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 50)

/obj/item/clothing/gloves/bracer
	name = "bone bracers"
	desc = "For when you're expecting to get slapped on the wrist. Offers modest protection to your arms."
	icon_state = "bracers"
	inhand_icon_state = "bracers"
	transfer_prints = TRUE
	strip_delay = 40
	equip_delay_other = 20
	body_parts_covered = ARMS
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 15, BULLET = 25, LASER = 15, ENERGY = 15, BOMB = 20, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/gloves/rapid
	name = "Gloves of the North Star"
	desc = "Just looking at these fills you with an urge to beat the shit out of people."
	icon_state = "rapid"
	inhand_icon_state = "rapid"
	transfer_prints = TRUE

/obj/item/clothing/gloves/rapid/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/wearertargeting/punchcooldown)


/obj/item/clothing/gloves/color/plasmaman
	desc = "Covers up those scandalous boney hands."
	name = "plasma envirogloves"
	icon_state = "plasmaman"
	inhand_icon_state = "plasmaman"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	permeability_coefficient = 0.05
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 95, ACID = 95)

/obj/item/clothing/gloves/color/plasmaman/black
	name = "black envirogloves"
	icon_state = "blackplasma"
	inhand_icon_state = "blackplasma"

/obj/item/clothing/gloves/color/plasmaman/white
	name = "white envirogloves"
	icon_state = "whiteplasma"
	inhand_icon_state = "whiteplasma"

/obj/item/clothing/gloves/color/plasmaman/robot
	name = "roboticist envirogloves"
	icon_state = "robotplasma"
	inhand_icon_state = "robotplasma"

/obj/item/clothing/gloves/color/plasmaman/janny
	name = "janitor envirogloves"
	icon_state = "jannyplasma"
	inhand_icon_state = "jannyplasma"

/obj/item/clothing/gloves/color/plasmaman/cargo
	name = "cargo envirogloves"
	icon_state = "cargoplasma"
	inhand_icon_state = "cargoplasma"

/obj/item/clothing/gloves/color/plasmaman/engineer
	name = "engineering envirogloves"
	icon_state = "engieplasma"
	inhand_icon_state = "engieplasma"
	siemens_coefficient = 0

/obj/item/clothing/gloves/color/plasmaman/atmos
	name = "atmos envirogloves"
	icon_state = "atmosplasma"
	inhand_icon_state = "atmosplasma"
	siemens_coefficient = 0

/obj/item/clothing/gloves/color/plasmaman/explorer
	name = "explorer envirogloves"
	icon_state = "explorerplasma"
	inhand_icon_state = "explorerplasma"

/obj/item/clothing/gloves/color/botanic_leather/plasmaman
	name = "botany envirogloves"
	desc = "Covers up those scandalous boney hands."
	icon_state = "botanyplasma"
	inhand_icon_state = "botanyplasma"
	permeability_coefficient = 0.05
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 95, ACID = 95)

/obj/item/clothing/gloves/color/plasmaman/prototype
	name = "prototype envirogloves"
	icon_state = "protoplasma"
	inhand_icon_state = "protoplasma"

/obj/item/clothing/gloves/color/plasmaman/clown
	name = "clown envirogloves"
	icon_state = "clownplasma"
	inhand_icon_state = "clownplasma"

/obj/item/clothing/gloves/combat/wizard
	name = "enchanted gloves"
	desc = "These gloves have been enchanted with a spell that makes them electrically insulated and fireproof."
	icon_state = "wizard"
	inhand_icon_state = "purplegloves"

/obj/item/clothing/gloves/radio
	name = "translation gloves"
	desc = "A pair of electronic gloves which connect to nearby radios wirelessly. Allows for sign language users to 'speak' over comms."
	icon_state = "radio_g"
	inhand_icon_state = "radio_g"

/obj/item/clothing/gloves/color/plasmaman/head_of_personnel
	name = "head of personnel's envirogloves"
	desc = "Covers up those scandalous, bony hands. Appears to be an attempt at making a replica of the captain's gloves."
	icon_state = "hopplasma"
	inhand_icon_state = "hopplasma"

/obj/item/clothing/gloves/color/plasmaman/chief_engineer
	name = "chief engineer's envirogloves"
	icon_state = "ceplasma"
	inhand_icon_state = "ceplasma"
	siemens_coefficient = 0

/obj/item/clothing/gloves/color/plasmaman/research_director
	name = "research director's envirogloves"
	icon_state = "rdplasma"
	inhand_icon_state = "rdplasma"

/obj/item/clothing/gloves/color/plasmaman/centcom_commander
	name = "CentCom commander envirogloves"
	icon_state = "commanderplasma"
	inhand_icon_state = "commanderplasma"

/obj/item/clothing/gloves/color/plasmaman/centcom_official
	name = "CentCom official envirogloves"
	icon_state = "officialplasma"
	inhand_icon_state = "officialplasma"

/obj/item/clothing/gloves/color/plasmaman/centcom_intern
	name = "CentCom intern envirogloves"
	icon_state = "internplasma"
	inhand_icon_state = "internplasma"

//Nemesis Solutions Gloves

/obj/item/clothing/gloves/rapid/nemesis
	name = "rapid stun gloves"
	desc = "A pair of high-tech gloves with \"Nemesis Solutions\" written on the inside."
	icon_state = "nemesis"
	inhand_icon_state = "black"
	transfer_prints = FALSE

	actions_types = list(/datum/action/item_action/nemesis_shield)

	var/charge = 0
	var/datum/martial_art/nemesis/style
	//To prevent spam from overcharge warnings
	var/antispam = 0

	var/obj/item/shield/energy/nemesis/shield

	//NS suit
	var/obj/item/clothing/suit/armor/vest/nemesis/suit

/obj/item/clothing/gloves/rapid/nemesis/Initialize()
	. = ..()
	var/datum/component/wearertargeting/punchcooldown/punch_cooldown = GetComponent(/datum/component/wearertargeting/punchcooldown)
	punch_cooldown.warcry = null
	punch_cooldown.UnregisterSignal(src, COMSIG_ITEM_ATTACK_SELF)
	style = new()
	shield = new(src)

/obj/item/clothing/gloves/rapid/nemesis/equipped(mob/user, slot)
	. = ..()

	if(!ishuman(user))
		return

	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/student = user
		style.teach(student, 1)
		ADD_TRAIT(student, TRAIT_NOGUNS, NEMESIS_TRAIT)

/obj/item/clothing/gloves/rapid/nemesis/dropped(mob/user)
	. = ..()

	if(!ishuman(user))
		return

	var/mob/living/owner = user
	style.remove(owner)
	REMOVE_TRAIT(owner, TRAIT_NOGUNS, NEMESIS_TRAIT)

	if(shield.loc == src)
		return

	if(shield.active)
		shield.active = FALSE
		shield.icon_state = "[shield.base_icon_state][shield.active]"
		shield.force = initial(shield.force)
		shield.w_class = WEIGHT_CLASS_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 35, TRUE)
		shield.slowdown = 0

	playsound(loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	user.dropItemToGround(shield, TRUE)
	shield.forceMove(src)

	addtimer(CALLBACK(src, .proc/check_location), 2)

/obj/item/clothing/gloves/rapid/nemesis/proc/check_location()
	if(loc != suit)
		playsound(src, 'sound/mecha/mechmove03.ogg', 50, TRUE)
		forceMove(suit)

/obj/item/clothing/gloves/rapid/nemesis/proc/lose_charge(amount_to_lose = 1)
	if(ishuman(loc))
		var/mob/living/carbon/human/owner = loc
		if(istype(owner.get_item_by_slot(ITEM_SLOT_BELT), /obj/item/storage/belt/security/nemesis)) //Just in case you somehow get rid of the belt while using nemesis suit
			var/obj/item/storage/belt/security/nemesis/belt = owner.get_item_by_slot(ITEM_SLOT_BELT)
			for(var/tick = 1 to amount_to_lose)
				if(belt.overcharge)
					belt.overcharge--
					amount_to_lose--
				else
					break
	charge = max(0, charge - amount_to_lose)
	update_charge()

/obj/item/clothing/gloves/rapid/nemesis/proc/gain_charge(amount_to_gain = 1)
	charge += amount_to_gain
	if(ishuman(loc))
		var/mob/living/carbon/human/owner = loc
		if(charge > NEMESIS_MAX_CHARGE) //Overcharge will be turned into stamina damage and stored in the belt. Use your brain and gadgets, not gloves only

			owner.apply_damage(5 * (charge - NEMESIS_MAX_CHARGE), STAMINA)

			if(world.time > antispam + 10 SECONDS)
				antispam = world.time
				to_chat(owner, "<span class='userdanger'>OVERCHARGE DETECTED. Process to deplete the charge to avoid possible shocks.</span>")

			if(istype(owner.get_item_by_slot(ITEM_SLOT_BELT), /obj/item/storage/belt/security/nemesis))
				var/obj/item/storage/belt/security/nemesis/belt = owner.get_item_by_slot(ITEM_SLOT_BELT)
				belt.overcharge += (charge - NEMESIS_MAX_CHARGE)

			charge = NEMESIS_MAX_CHARGE
	else
		charge = min(charge, NEMESIS_MAX_CHARGE) //...how did we get here?
	update_charge()

/obj/item/clothing/gloves/rapid/nemesis/proc/update_charge()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/owner = loc
	if(istype(owner.get_item_by_slot(ITEM_SLOT_OCLOTHING), /obj/item/clothing/suit/armor/vest/nemesis))
		var/obj/item/clothing/suit/armor/vest/nemesis/suit = owner.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		suit.update_charge(charge)

	if(istype(owner.get_item_by_slot(ITEM_SLOT_BELT), /obj/item/storage/belt/security/nemesis))
		var/obj/item/storage/belt/security/nemesis/belt = owner.get_item_by_slot(ITEM_SLOT_BELT)
		belt.update_charge(charge)

/obj/item/clothing/gloves/rapid/nemesis/attack_hand(mob/user, list/modifiers)
	if(shield.loc != src)
		return ..()

	if(!ishuman(user) || user != loc)
		return ..()

	var/mob/living/carbon/human/owner = user

	shield.forceMove(get_turf(owner))
	owner.put_in_hands(shield)
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)

/obj/item/clothing/gloves/rapid/nemesis/ui_action_click(mob/user, action)
	if(!ishuman(user) || user != loc)
		return ..()

	var/mob/living/carbon/human/owner = user
	if(shield.loc == src)
		shield.forceMove(get_turf(owner))
		owner.put_in_hands(shield)
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)
		shield.attack_self(owner)
		return

	if(shield.active)
		shield.active = FALSE
		shield.icon_state = "[shield.base_icon_state][shield.active]"
		shield.force = initial(shield.force)
		shield.w_class = WEIGHT_CLASS_TINY
		playsound(owner, 'sound/weapons/saberoff.ogg', 35, TRUE)
		shield.slowdown = 0

	playsound(src, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	user.dropItemToGround(shield, TRUE)
	forceMove(src)


/obj/item/clothing/gloves/rapid/nemesis/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return

	switch(rand(1, 6))
		if(1)
			if(isliving(loc))
				var/mob/living/owner = loc
				to_chat(owner, "<span class='notice'>[src] absorbed the EMP and gained some charge from it!</span>")
				gain_charge(rand(1, 3))
		if(2)
			if(isliving(loc))
				var/mob/living/owner = loc
				to_chat(owner, "<span class='warning'>[src] malfunctions and loses some charge!</span>")
				lose_charge(rand(1, 3))
		if(3 to 5)
			if(isliving(loc))
				var/mob/living/owner = loc
				to_chat(owner, "<span class='warning'>[src] malfunctions and depletes all of it's charge!</span>")
				lose_charge(charge)
		if(6)
			if(isliving(loc))
				var/mob/living/owner = loc
				to_chat(owner, "<span class='warning'>[src] malfunctions and electrocutes you!</span>") //Fuck you specifically
				lose_charge(charge)
				owner.electrocute_act(35, src, flags = SHOCK_NOGLOVES)
				owner.Paralyze(3 SECONDS)
				owner.Jitter(3 SECONDS)
