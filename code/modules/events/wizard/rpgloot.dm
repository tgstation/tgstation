/datum/round_event_control/wizard/rpgloot //its time to minmax your shit
	name = "RPG Loot"
	weight = 3
	typepath = /datum/round_event/wizard/rpgloot
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/wizard/rpgloot/start()
	var/list/prefixespositive 	= list("greater", "major", "blessed", "superior", "enpowered", "honed", "true", "glorious", "robust")
	var/list/prefixesnegative 	= list("lesser", "minor", "blighted", "inferior", "enfeebled", "rusted", "unsteady", "tragic", "gimped")
	var/list/suffixes			= list("orc slaying", "elf slaying", "corgi slaying", "strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma", "the forest", "the hills", "the plains", "the sea", "the sun", "the moon", "the void", "the world", "the fool", "many secrets", "many tales", "many colors", "rending", "sundering", "the night", "the day")
	var/upgrade_scroll_chance	= 0
	for(var/obj/item/I in world)
		if(istype(I,/obj/item/organ/))
			continue
		var/quality = pick(1;15, 2;14, 2;13, 2;12, 3;11, 3;10, 3;9, 4;8, 4;7, 4;6, 5;5, 5;4, 5;3, 6;2, 6;1, 6;0)
		if(prob(50))
			quality = -quality
		if(quality > 0)
			I.name = "[pick(prefixespositive)] [I.name] of [pick(suffixes)] +[quality]"
		else if(quality < 0)
			I.name = "[pick(prefixesnegative)] [I.name] of [pick(suffixes)] [quality]"
		else
			I.name = "[I.name] of [pick(suffixes)]"

		I.force 		= max(0,I.force + quality)
		I.throwforce	= max(0,I.throwforce + quality)
		for(var/value in I.armor)
			I.armor[value] += quality

		if(istype(I,/obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = I
			if(prob(upgrade_scroll_chance) && S.contents.len < S.storage_slots && !S.invisibility)
				var/obj/item/upgradescroll/scroll = new
				S.handle_item_insertion(scroll,1)
				upgrade_scroll_chance = max(0,upgrade_scroll_chance-100)
			upgrade_scroll_chance += 25

/obj/item/upgradescroll
	name = "Item Fortification Scroll"
	desc = "Somehow, this piece of paper can be applied to items to make them \"better\". Apparently there's a risk of losing the item if it's already \"too good\". <i>This all feels so arbitrary...</i>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	w_class = WEIGHT_CLASS_TINY

/obj/item/upgradescroll/afterattack(obj/item/target, mob/user , proximity)
	if(!proximity || !istype(target))
		return
	var/quality = target.force - initial(target.force)
	if(quality > 9 && prob((quality - 9)*10))
		user << "<span class='danger'>[target] catches fire!</span>"
		if(target.resistance_flags & (LAVA_PROOF|FIRE_PROOF))
			target.resistance_flags &= ~(LAVA_PROOF|FIRE_PROOF)
			target.resistance_flags |= FLAMMABLE
		target.fire_act()
		qdel(src)
		return
	target.force 		+= 1
	target.throwforce	+= 1
	for(var/value in target.armor)
		target.armor[value] += 1
	user << "<span class='notice'>[target] glows blue and seems vaguely \"better\"!</span>"
	qdel(src)
