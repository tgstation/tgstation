/obj/effect/proc_holder/spell/targeted/lichdom
	name = "Bind Soul"
	desc = "A dark necromantic pact that can forever bind your soul to an item of your choosing. So long as both your body and the item remain intact you can revive from death, though the time between reincarnations grows steadily with use."
	school = "necromancy"
	charge_max = 10
	clothes_req = 0
	centcom_cancast = 0
	invocation = "NECREM IMORTIUM!"
	invocation_type = "shout"
	range = -1
	level_max = 0 //cannot be improved
	cooldown_min = 10
	include_user = 1

	var/obj/marked_item
	var/mob/living/current_body

	action_icon_state = "skeleton"

/obj/effect/proc_holder/spell/targeted/lichdom/New()
	if(ticker.mode.round_ends_with_antag_death)
		ticker.mode.round_ends_with_antag_death = 0

	..()
/obj/effect/proc_holder/spell/targeted/lichdom/cast(list/targets)
	for(var/mob/user in targets)
		var/list/hand_items = list()
		if(iscarbon(user))
			hand_items = list(user.get_active_hand(),user.get_inactive_hand())

		if(marked_item && !stat_allowed) //sanity, shouldn't happen without badminry
			marked_item = null
			return

		if(stat_allowed) //Death is not my end!
			if(user.stat == CONSCIOUS && iscarbon(user))
				user << "<span class='notice'>You aren't dead enough to revive!</span>" //Usually a good problem to have
				charge_counter = charge_max
				return

			if(!marked_item.loc) //Wait nevermind
				user << "<span class='warning'>Your phylactery is gone!</span>"
				return

			if(isobserver(user))
				var/mob/dead/observer/O = user
				O.reenter_corpse()

			var/mob/living/carbon/human/lich = new /mob/living/carbon/human(get_turf(marked_item))

			lich.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(lich), slot_shoes)
			lich.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(lich), slot_w_uniform)
			lich.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/black(lich), slot_wear_suit)
			lich.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/black(lich), slot_head)

			lich.real_name = user.mind.name
			user.mind.transfer_to(lich)
			hardset_dna(lich,null,null,lich.real_name,null,/datum/species/skeleton)
			lich << "<span class='warning'>Your bones clatter and shutter as they're pulled back into this world!</span>"
			charge_max += 600
			var/mob/old_body = current_body
			current_body = lich
			lich.Weaken(10)

			if(old_body && old_body.loc)
				if(iscarbon(old_body))
					var/mob/living/carbon/C = old_body
					for(var/obj/item/W in C)
						C.unEquip(W)
				var/wheres_wizdo = dir2text(get_dir(get_turf(old_body), get_turf(marked_item)))
				if(wheres_wizdo)
					old_body.visible_message("<span class='warning'>Suddenly [old_body.name]'s corpse falls to pieces! You see a strange energy rise from the remains, and speed off towards the [wheres_wizdo]!</span>")
				old_body.dust()

		if(!marked_item) //linking item to the spell
			message = "<span class='warning'>"
			for(var/obj/item in hand_items)
				if(ABSTRACT in item.flags || NODROP in item.flags)
					continue
				marked_item = 		item
				user << "<span class='warning'>You begin to focus your very being into the [item.name]...</span>"
				break

			if(!marked_item)
				user << "<span class='caution'>You must hold an item you wish to make your phylactery...</span>"

			spawn(50)
				if(marked_item.loc != user) //I changed my mind I don't want to put my soul in a cheeseburger!
					user << "<span class='warning'>Your soul snaps back to your body as you drop the [marked_item.name]!</span>"
					marked_item = null
					return
				name = "RISE!"
				desc = "Rise from the dead! You will reform at the location of your phylactery and your old body will crumble away."
				charge_max = 1800 //3 minute cooldown, if you rise in sight of someone and killed again, you're probably screwed.
				charge_counter = 1800
				stat_allowed = 1
				marked_item.name = "Ensouled [marked_item.name]"
				marked_item.desc = "A terrible aura surrounds this item, its very existence is offensive to life itself..."
				marked_item.color = "#003300"
				user << "<span class='userdanger'>With a hideous feeling of emptiness you watch in horrified fascination as skin sloughs off bone! Blood boils, nerves disintegrate, eyes boil in their sockets! As your organs crumble to dust in your fleshless chest you come to terms with your choice. You're a lich!</span>"
				hardset_dna(user, null, null, null, null, /datum/species/skeleton)
				current_body = user.mind.current
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					H.unEquip(H.wear_suit)
					H.unEquip(H.head)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/black(H), slot_wear_suit)
					H.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/black(H), slot_head)