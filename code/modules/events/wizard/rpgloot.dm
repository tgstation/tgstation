/datum/round_event_control/wizard/rpgloot //its time to minmax your shit
	name = "RPG Loot"
	weight = 3
	typepath = /datum/round_event/wizard/rpgloot
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/wizard/rpgloot/start()
	var/upgrade_scroll_chance = 0
	for(var/obj/item/I in world)
		if(!istype(I.rpg_loot))
			I.rpg_loot = new(I)

		if(istype(I, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = I
			if(prob(upgrade_scroll_chance) && S.contents.len < S.storage_slots && !S.invisibility)
				var/obj/item/upgradescroll/scroll = new
				S.handle_item_insertion(scroll,1)
				upgrade_scroll_chance = max(0,upgrade_scroll_chance-100)
			upgrade_scroll_chance += 25

	GLOB.rpg_loot_items = TRUE

/obj/item/upgradescroll
	name = "item fortification scroll"
	desc = "Somehow, this piece of paper can be applied to items to make them \"better\". Apparently there's a risk of losing the item if it's already \"too good\". <i>This all feels so arbitrary...</i>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	w_class = WEIGHT_CLASS_TINY

	var/upgrade_amount = 1
	var/can_backfire = TRUE
	var/one_use = TRUE

/obj/item/upgradescroll/afterattack(obj/item/target, mob/user , proximity)
	if(!proximity || !istype(target))
		return

	var/datum/rpg_loot/rpg_loot_datum = target.rpg_loot
	if(!istype(rpg_loot_datum))
		rpg_loot_datum = new /datum/rpg_loot(target)

	var/quality = rpg_loot_datum.quality

	if(can_backfire && (quality > 9 && prob((quality - 9)*10)))
		to_chat(user, "<span class='danger'>[target] violently glows blue for a while, then evaporates.</span>")
		target.burn()
	else
		to_chat(user, "<span class='notice'>[target] glows blue and seems vaguely \"better\"!</span>")
		rpg_loot_datum.modify(upgrade_amount)

	if(one_use)
		qdel(src)

/obj/item/upgradescroll/unlimited
	name = "unlimited foolproof item fortification scroll"
	desc = "Somehow, this piece of paper can be applied to items to make them \"better\". This scroll is made from the tongues of dead paper wizards, and can be used an unlimited number of times, with no drawbacks."
	one_use = FALSE
	can_backfire = FALSE

/datum/rpg_loot
	var/positive_prefix = "okay"
	var/negative_prefix = "weak"
	var/suffix = "something profound"
	var/quality = 0

	var/obj/item/attached
	var/original_name

/datum/rpg_loot/New(attached_item=null)
	attached = attached_item

	randomise()

/datum/rpg_loot/Destroy()
	attached = null

/datum/rpg_loot/proc/randomise()
	var/static/list/prefixespositive = list("greater", "major", "blessed", "superior", "enpowered", "honed", "true", "glorious", "robust")
	var/static/list/prefixesnegative = list("lesser", "minor", "blighted", "inferior", "enfeebled", "rusted", "unsteady", "tragic", "gimped")
	var/static/list/suffixes = list("orc slaying", "elf slaying", "corgi slaying", "strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma", "the forest", "the hills", "the plains", "the sea", "the sun", "the moon", "the void", "the world", "the fool", "many secrets", "many tales", "many colors", "rending", "sundering", "the night", "the day")

	var/new_quality = pick(1;15, 2;14, 2;13, 2;12, 3;11, 3;10, 3;9, 4;8, 4;7, 4;6, 5;5, 5;4, 5;3, 6;2, 6;1, 6;0)

	suffix = pick(suffixes)
	positive_prefix = pick(prefixespositive)
	negative_prefix = pick(prefixesnegative)

	if(prob(50))
		new_quality = -new_quality

	modify(new_quality)

/datum/rpg_loot/proc/rename()
	var/obj/item/I = attached
	if(!original_name)
		original_name = I.name
	if(quality < 0)
		I.name = "[negative_prefix] [original_name] of [suffix] [quality]"
	else if(quality == 0)
		I.name = "[original_name] of [suffix]"
	else if(quality > 0)
		I.name = "[positive_prefix] [original_name] of [suffix] +[quality]"

/datum/rpg_loot/proc/modify(quality_mod)
	var/obj/item/I = attached
	quality += quality_mod

	I.force = max(0,I.force + quality_mod)
	I.throwforce = max(0,I.throwforce + quality_mod)

	for(var/value in I.armor)
		I.armor[value] += quality

	rename()
