/datum/toolbox_upgrade
	var/name
	var/desc
	var/cost
	var/acquired
	var/min_sacrifices

/datum/toolbox_upgrade/proc/can_apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	if (!istype(statue) || !istype(user) || user != statue.Holder || !(user in view(1, statue)) || statue.toolbox_points < cost || statue.sacrifices < min_sacrifices)
		return 0
	return 1

/datum/toolbox_upgrade/proc/acquire(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	if (can_apply(user, statue))
		apply(user, statue)
		acquired = 1
		statue.toolbox_points -= cost
		to_chat(user, "<span class='boldnotice'>You have purchased the upgrade '<b>[name]</b>' for <b>[cost]</b> points.</span>")
		playsound(get_turf(statue.Holder), 'sound/magic/magic_missile.ogg', 100, 0)

/datum/toolbox_upgrade/proc/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)

/*
	The upgrades themselves
*/

/*
	Damage
*/
/datum/toolbox_upgrade/damage
	name = "Greater Damage"
	desc = "Puts the 'R' in Robust for your toolbox. Your toolbox deals 20 damage instead of 12."
	min_sacrifices = 1
	cost = 1

/datum/toolbox_upgrade/damage/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	statue.true_box.force = 20

/datum/toolbox_upgrade/damage2
	name = "Ultimate Damage"
	desc = "Increases damage from 20 to 50. Must have purchased Greater Damage first."
	min_sacrifices = 3
	cost = 3

/datum/toolbox_upgrade/damage2/can_apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	if (statue.true_box.force < 20)
		return 0
	return ..()

/datum/toolbox_upgrade/damage2/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	statue.true_box.force = 50

/datum/toolbox_upgrade/hulk
	name = "HULK SMASH"
	desc = "Lets you laugh at an officer emptying his taser into you as you move in to bash his head in."
	min_sacrifices = 10
	cost = 10

/datum/toolbox_upgrade/hulk/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	var/datum/mutation/human/HM = GLOB.mutations_list[HULK]
	HM.force_give(user)

/*
	Freeze Beam
*/
/datum/toolbox_upgrade/freeze
	name = "Cold Feet"
	desc = "Allows you to shoot a freezing beam from your toolbox every 10 seconds."
	min_sacrifices = 5
	cost = 5

/datum/toolbox_upgrade/freeze/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	statue.freeze_beam = 1

/datum/toolbox_upgrade/freeze2
	name = "Frozen Feet"
	desc = "Reduces your freezing beam cooldown from 10 to 5 seconds."
	min_sacrifices = 5
	cost = 2

/datum/toolbox_upgrade/freeze2/can_apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	if (statue.freeze_beam == 0) return 0
	return ..()

/datum/toolbox_upgrade/freeze2/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	statue.freeze_beam_cooldown = 50

/*
	Armor Penetration
*/

/datum/toolbox_upgrade/armorpen
	name = "Greater Armor Penetration"
	desc = "Increases armor penetration from 0 to 50, effectively reducing any block chance by 25%."
	min_sacrifices = 3
	cost = 1

/datum/toolbox_upgrade/armorpen/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	statue.armor_pen = 50

/datum/toolbox_upgrade/armorpen2
	name = "Ultimate Armor Penetration"
	desc = "Your knockdown attack cannot be stopped by shields. Must have Greater Armor Penetration to purchase."
	min_sacrifices = 3
	cost = 3

/datum/toolbox_upgrade/armorpen2/can_apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	if (statue.armor_pen != 50) return 0
	return ..()


/datum/toolbox_upgrade/armorpen2/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	statue.armor_pen = -1

/*
	Sight
*/
/datum/toolbox_upgrade/sight
	name = "The Gift of Sight"
	desc = "Lets you see your victims before they see you."
	min_sacrifices = 2
	cost = 2

datum/toolbox_upgrade/sight/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	var/datum/mutation/human/HM = GLOB.mutations_list[XRAY]
	HM.force_give(user)

/*
	Block
*/
/datum/toolbox_upgrade/block
	name = "Greater Block"
	desc = "Increases your block chance from 60% to 80%."
	min_sacrifices = 2
	cost = 2

/datum/toolbox_upgrade/block/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	statue.true_box.block_chance = 80

/datum/toolbox_upgrade/block2
	name = "Ultimate Block"
	desc = "Increases your block chance from 80% to 95%. Must have Greater Block to buy."
	min_sacrifices = 5
	cost = 5

/datum/toolbox_upgrade/block2/can_apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	if (statue.true_box.block_chance < 80) return 0
	return ..()

/datum/toolbox_upgrade/block2/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	statue.true_box.block_chance = 95

/*
	Glue
*/
/datum/toolbox_upgrade/glue
	name = "Industrial Glue"
	desc = "Your toolbox becomes permanently glued to your hand."
	min_sacrifices = 5
	cost = 5

/datum/toolbox_upgrade/glue/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	statue.true_box.flags_1 |= NODROP_1

/*
	No slips
*/
/datum/toolbox_upgrade/noslip
	name = "Clown B Gone"
	desc = "No slip shoes. Lets you laugh at the clown throwing banana peels at you as you move into bash his head in."
	min_sacrifices = 1
	cost = 1

/datum/toolbox_upgrade/noslip/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	var/obj/item/I = new /obj/item/clothing/shoes/sneakers/black(get_turf(statue.Holder))
	I.flags_1 |= NOSLIP_1
	statue.Holder.put_in_hands(I)

/*
	Access
*/
/datum/toolbox_upgrade/access
	name = "All-access Toolbox"
	desc = "Who needs ID cards anyway?"
	min_sacrifices = 3
	cost = 3

/datum/toolbox_upgrade/access/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	statue.all_access_toolbox = 1

/*
	Shuttle Upgrades
*/
/datum/toolbox_upgrade/shuttle
	name = "Recall shuttle 1"
	desc = "Recalls the emergency shuttle. Can only be used when at least 10 players are online."
	cost = 1
	min_sacrifices = 1

/datum/toolbox_upgrade/shuttle/apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	SSshuttle.cancelEvac(user)

/datum/toolbox_upgrade/shuttle/can_apply(mob/living/carbon/human/user, obj/structure/statue/toolbox/statue)
	if (!..())
		return 0
	if (GLOB.clients.len < 10)
		return 0
	return 1

/datum/toolbox_upgrade/shuttle/shuttle2
	name = "Recall shuttle 2"
	cost = 2
	min_sacrifices = 3

/datum/toolbox_upgrade/shuttle/shuttle3
	name = "Recall shuttle 3"
	cost = 3
	min_sacrifices = 5