//Buzzon, controls all the robots and honey.

/obj/item/clothing/gloves/tackler/combat/insulated/buzzon
	name = "BuzzOn gloves"
	desc = "Legendary gloves on the greatest bee superhero - BuzzOn. You can see small rocket engines installed on them."
	icon_state = "buzz"
	worn_icon_state = "buzz"
	inhand_icon_state = "ygloves"

	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

	tackle_stam_cost = 5 //Very light and fast tackles. However, if you fly into a wall or an enemy, well, you're fucked.
	base_knockdown = 0.2 SECONDS
	tackle_range = 5
	tackle_speed = 2
	min_distance = 2
	skill_mod = -5

/obj/item/clothing/gloves/tackler/combat/insulated/buzzon/cryo //Cosmetics for "Operation: Cryostung" kit
	icon_state = "buzz_cryo"
	worn_icon_state = "buzz_cryo"
	inhand_icon_state = "bluegloves"

/obj/item/clothing/shoes/sneakers/buzzon
	name = "BuzzOn shoes"
	desc = "Shoes of a bee that became human, rumors say that they buzz when you walk in them."
	greyscale_colors = "#000000#f6c61a"

	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

/obj/item/clothing/shoes/sneakers/buzzon/cryo
	icon_state = "buzz_cryo"
	worn_icon_state = "buzz_cryo"

	greyscale_colors = null
	dying_key = null
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/suit/hooded/bee_costume/buzzon
	name = "cybernetic bee suit"
	desc = "A complex cybernetic suit with black and yellow stripes. All hail the Queen!"
	icon_state = "bee_full"

	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	clothing_flags = THICKMATERIAL

	hoodtype = /obj/item/clothing/head/hooded/bee_hood/full
	actions_types = list(/datum/action/item_action/toggle_hood, /datum/action/item_action/recall_beesword)

	var/obj/item/melee/beesword/buzzon/linked_sword
	var/sword_cooldown = 0

/obj/item/clothing/suit/hooded/bee_costume/buzzon/cryo
	icon_state = "bee_full_cryo"
	hoodtype = /obj/item/clothing/head/hooded/bee_hood/full/cryo

	cold_protection = CHEST|GROIN|ARMS|LEGS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/hooded/bee_costume/buzzon/Initialize()
	. = ..()
	allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/hooded/bee_costume/buzzon/cryo/Initialize()
	. = ..()
	allowed = GLOB.security_hardsuit_allowed

/obj/item/clothing/suit/hooded/bee_costume/buzzon/proc/recall_sword()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/owner = loc
	if(locate(/obj/item/melee/beesword/buzzon) in owner.contents)
		linked_sword = locate() in owner.contents
		to_chat(owner, "<span class='notice'>You successfully link [linked_sword] to your [src].</span>")
		return

	if(owner == linked_sword.loc || sword_cooldown > world.time)
		return

	var/sword_location = get_turf(linked_sword)
	var/owner_location = get_turf(owner)
	if(get_dist(owner_location, sword_location) > 10)
		to_chat(owner,"<span class='warning'>[linked_sword] is too far away!</span>")
	else
		sword_cooldown = world.time + 20
		if(isliving(linked_sword.loc))
			var/mob/living/current_owner = linked_sword.loc
			current_owner.dropItemToGround(linked_sword)
			to_chat(current_owner, "<span class='warning'>[linked_sword]'s small rocket engine suddenly activates and rips it out of your hand!</span>")
		linked_sword.throw_at(owner, 10, 2)

/obj/item/clothing/head/hooded/bee_hood/full //It's not a helmet because I want tackles and flashbangs to fuck you up
	name = "cybernetic bee helmet"
	desc = "A cybernetic helmet attached to a suit. All hail the Queen!"
	icon_state = "bee_full"

	body_parts_covered = HEAD
	clothing_flags = THICKMATERIAL
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEARS|HIDEEYES|HIDESNOUT

/obj/item/clothing/head/hooded/bee_hood/full/cryo
	icon_state = "bee_full_cryo"

	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/head/hooded/bee_hood/full/equipped(mob/user, slot, initial)
	. = ..()
	if(!ishuman(user))
		return

	if(slot != ITEM_SLOT_HEAD)
		return

	var/mob/living/carbon/human/buzzon = user

	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
	hud.add_hud_to(buzzon)
	ADD_TRAIT(buzzon, TRAIT_DIAGNOSTIC_HUD, CLOTHING_TRAIT)
	ADD_TRAIT(buzzon, TRAIT_ROBOTIC_FRIEND, CLOTHING_TRAIT) //BuzzOn is the best roboticist ever so bots don't attack him even if emagged

/obj/item/clothing/head/hooded/bee_hood/full/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/buzzon = user

	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
	hud.remove_hud_from(buzzon)
	REMOVE_TRAIT(buzzon, TRAIT_DIAGNOSTIC_HUD, CLOTHING_TRAIT)
	REMOVE_TRAIT(buzzon, TRAIT_ROBOTIC_FRIEND, CLOTHING_TRAIT)

/obj/item/melee/beesword/buzzon
	name = "The Stinger"
	desc = "A sting of giant bee on a handle that became the fastest sword in the world thanks to high-tech components."
	icon_state = "buzzon_sword"
	inhand_icon_state = "buzzon"
	worn_icon_state = "buzzon"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	block_chance = 10 //It's about agility, not about sheer force
	///If this var is higher than world.time this means that the owner is still in the blocking stance and has a high chance to block the attack
	var/parry_time = 0

/obj/item/melee/beesword/buzzon/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(parry_time >= world.time)
		parry_time = 0
		final_block_chance += 85

	switch(attack_type)
		if(UNARMED_ATTACK)
			final_block_chance += 30

		if(PROJECTILE_ATTACK)
			final_block_chance -= 40

		if(LEAP_ATTACK)
			if(isliving(hitby))
				var/mob/living/victim = hitby
				force = 20
				attack_verb_continuous = list("penetrates", "pierces") //We pierce them in the flight.
				attack_verb_simple = list("penetrate", "pierce")
				attack(victim, owner)
				force = initial(force)
				attack_verb_continuous = initial(attack_verb_continuous)
				attack_verb_simple = initial(attack_verb_simple)
	. = ..()

/obj/item/melee/beesword/buzzon/attack_secondary(mob/living/victim, mob/living/user, params)
	user.changeNext_move(CLICK_CD_RANGE)
	parry_time = world.time + CLICK_CD_RANGE
	user.visible_message("<span class='warning'>[user] assumes blocking stance.</span>", "<span class='notice'>You assume blocking stance.</span>")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/melee/beesword/buzzon/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/victim = hit_atom
		if(istype(victim.get_item_by_slot(ITEM_SLOT_OCLOTHING), /obj/item/clothing/suit/hooded/bee_costume/buzzon))
			var/obj/item/clothing/suit/hooded/bee_costume/buzzon/suit = victim.get_item_by_slot(ITEM_SLOT_OCLOTHING)
			if(suit.linked_sword == src)
				victim.put_in_active_hand(src)
				victim.visible_message("<span class='warning'>[victim] catches [src] out of the air!</span>")
				return
	. = ..()

/mob/living/simple_animal/hostile/poison/bees/toxin_type
	var/toxin_type = /datum/reagent/toxin

/mob/living/simple_animal/hostile/poison/bees/toxin_type/Initialize()
	. = ..()
	assign_reagent(GLOB.chemical_reagents_list[toxin_type])

/mob/living/simple_animal/hostile/poison/bees/toxin_type/cryo
	toxin_type = /datum/reagent/consumable/frostoil

/obj/item/grenade/spawnergrenade/buzzkill/non_toxic
	spawner_type = /mob/living/simple_animal/hostile/poison/bees
	deliveryamt = 5

/obj/item/clothing/glasses/hud/security/sunglasses/blue
	icon_state = "sunhudmed"
	glass_colour_type = /datum/client_colour/glass_colour/blue

/obj/item/melee/beesword/buzzon/cryo
	name = "The Cryostinger"
	desc = "An advanced sword with built-in frost oil injectors."
	icon_state = "buzzon_sword_cryo"
	inhand_icon_state = "buzzon_cryo"
	worn_icon_state = "buzzon_cryo"
	force = 3 //A bit lower because we have better toxin

	toxin_type = /datum/reagent/consumable/frostoil

//The Bee Hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi/buzzon
	name = "bee hardsuit helmet"
	desc = "A dual-mode advanced helmet equipped with HUD that looks like a bee's head. It is in travel mode."
	alt_desc = "A dual-mode advanced helmet equipped with HUD that looks like a bee's head. It is in combat mode."
	icon_state = "hardsuit1-bee"
	inhand_icon_state = "s_helmet"
	hardsuit_type = "bee"
	visor_flags_inv = 0
	visor_flags = 0
	on = FALSE

	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

/obj/item/clothing/head/helmet/space/hardsuit/syndi/buzzon/equipped(mob/user, slot, initial)
	. = ..()
	if(!ishuman(user))
		return

	if(slot != ITEM_SLOT_HEAD)
		return

	var/mob/living/carbon/human/buzzon = user

	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
	hud.add_hud_to(buzzon)
	ADD_TRAIT(buzzon, TRAIT_DIAGNOSTIC_HUD, CLOTHING_TRAIT)
	ADD_TRAIT(buzzon, TRAIT_ROBOTIC_FRIEND, CLOTHING_TRAIT)

/obj/item/clothing/head/helmet/space/hardsuit/syndi/buzzon/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/buzzon = user

	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
	hud.remove_hud_from(buzzon)
	REMOVE_TRAIT(buzzon, TRAIT_DIAGNOSTIC_HUD, CLOTHING_TRAIT)
	REMOVE_TRAIT(buzzon, TRAIT_ROBOTIC_FRIEND, CLOTHING_TRAIT)

/obj/item/clothing/suit/space/hardsuit/syndi/buzzon
	name = "bee hardsuit"
	desc = "A dual-mode advanced bee hardsuit equipped with high-tech gadgets. It is in travel mode."
	alt_desc = "A dual-mode advanced beehardsuit equipped with high-tech gadgets. It is in combat mode."
	icon_state = "hardsuit1-bee"
	inhand_icon_state = "s_suit"
	hardsuit_type = "bee"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/buzzon

	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

	var/obj/item/melee/beesword/buzzon/linked_sword
	var/sword_cooldown = 0

/obj/item/clothing/suit/space/hardsuit/syndi/buzzon/proc/recall_sword()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/owner = loc
	if(locate(/obj/item/melee/beesword/buzzon) in owner.contents)
		linked_sword = locate() in owner.contents
		to_chat(owner, "<span class='notice'>You successfully link [linked_sword] to your [src].</span>")
		return

	if(owner == linked_sword.loc || sword_cooldown > world.time)
		return

	var/sword_location = get_turf(linked_sword)
	var/owner_location = get_turf(owner)
	if(get_dist(owner_location, sword_location) > 10)
		to_chat(owner,"<span class='warning'>[linked_sword] is too far away!</span>")
	else
		sword_cooldown = world.time + 20
		if(isliving(linked_sword.loc))
			var/mob/living/current_owner = linked_sword.loc
			current_owner.dropItemToGround(linked_sword)
			current_owner.visible_message("<span class='warning'>[linked_sword]'s small rocket engine suddenly activates and rips it out of your hand!</span>")
		linked_sword.throw_at(owner, 10, 2)
