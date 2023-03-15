/obj/item/clothing/shoes/magboots/boomboots

	desc = "The ultimate in clown shoe technology."
	name = "boom boots"
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/feet.dmi'
	icon_state = "boomboot0"
	item_state = "boomboot0"
	magboot_state = "boomboot"
	slowdown = SHOES_SLOWDOWN+1
	actions_types = list(/datum/action/item_action/toggle)
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes/clown
	nodrop_message = "The boomboots anti-tamper system doesn't allow you to remove them while on!"
	var/datum/component/waddle
	var/enabled_waddle = TRUE

/obj/item/clothing/shoes/magboots/boomboots/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('monkestation/sound/misc/Boomboot1.ogg'=1), 50)

/obj/item/clothing/shoes/magboots/boomboots/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_FEET)
		if(enabled_waddle)
			waddle = user.AddComponent(/datum/component/waddling)
		if(user.mind && user.mind.assigned_role == "Clown")
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "clownshoes", /datum/mood_event/clownshoes)

/obj/item/clothing/shoes/magboots/boomboots/item_action_slot_check(slot, mob/user)
	if(slot == ITEM_SLOT_FEET)
		return 1

/obj/item/clothing/shoes/magboots/boomboots/dropped(mob/user)
	. = ..()
	QDEL_NULL(waddle)
	if(user.mind && user.mind.assigned_role == "Clown")
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "clownshoes")
	if(magpulse)//make sure they're being worn and activated
		explosion(src,2,4,8,6)//used the size of the big rubber ducky bomb

/obj/item/clothing/shoes/magboots/boomboots/attack_self(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.shoes)
			if(magpulse)
				ENABLE_BITFIELD(clothing_flags, NOSLIP)
				DISABLE_BITFIELD(clothing_flags, NOTDROPPABLE) //dont ask why these are opposite, it works, dont question it. It works.
				strip_delay = 100
			else
				DISABLE_BITFIELD(clothing_flags, NOSLIP)
				ENABLE_BITFIELD(clothing_flags, NOTDROPPABLE)
			magpulse = !magpulse
			icon_state = "[magboot_state][magpulse]"
			to_chat(user, "<span class='notice'>You [magpulse ? "enable" : "disable"] the anti-tamper system.</span>")
			user.update_inv_shoes()	//so our mob-overlays update
			user.update_gravity(user.has_gravity())
			for(var/datum/action/A in actions)
				A.UpdateButtonIcon()
		else
			to_chat(user, "<span class='userdanger'>You have to wear the boots to activate them!</span>")

/obj/item/clothing/shoes/magboots/boomboots/on_mob_death(mob/user, gibbed)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(magpulse && src == C.shoes)//only want them exploding if they're on & Equipped
			explosion(src,2,4,8,6)
