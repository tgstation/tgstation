/obj/effect/client_image_holder/white_rabbit
	name = "white rabbit"
	desc = "FEED YOUR HEAD."
	image_icon = 'massmeta/icons/monster_hunter/rabbit.dmi'
	image_state = "white_rabbit"
	image_layer = ABOVE_LIGHTING_PLANE
	image_layer = ABOVE_MOB_LAYER
	image_plane =  GAME_PLANE_UPPER
	///the rabbit's whisper
	var/description
	///has the rabbit already whispered?
	var/being_used = FALSE
	///the hunter this rabbit is tied to
	var/datum/antagonist/monsterhunter/hunter
	///is this rabbit selected to drop the mask?
	var/drop_mask = FALSE
	///is this rabbit selected to drop the gun?
	var/drop_gun = FALSE

/obj/effect/client_image_holder/white_rabbit/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_RABBIT_FOUND, .proc/spotted)

/obj/effect/client_image_holder/white_rabbit/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!(user in who_sees_us))
		return
	if(being_used)
		return
	being_used = TRUE
	SEND_SIGNAL(src, COMSIG_RABBIT_FOUND, user)
	if(!hunter)
		return
	SEND_SIGNAL(hunter, COMSIG_GAIN_INSIGHT)
	image_state = "rabbit_hole"
	update_appearance()
	QDEL_IN(src, 8 SECONDS)


/obj/effect/client_image_holder/white_rabbit/proc/spotted(datum/source, mob/user)
	SIGNAL_HANDLER

	new /obj/item/rabbit_eye(loc)
	if(drop_mask)
		new /obj/item/clothing/mask/cursed_rabbit(loc)
	if(drop_gun)
		new /obj/item/gun/ballistic/revolver/hunter_revolver(loc)
		var/datum/action/cooldown/spell/conjure_item/blood_silver/silverblood = new(user)
		silverblood.StartCooldown()
		silverblood.Grant(user)
	if(hunter)
		hunter.rabbits -= src
	UnregisterSignal(src, COMSIG_RABBIT_FOUND)
