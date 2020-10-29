/datum/component/wearertargeting/sitcomlaughter
	valid_slots = list(ITEM_SLOT_HANDS, ITEM_SLOT_BELT, ITEM_SLOT_ID, ITEM_SLOT_LPOCKET, ITEM_SLOT_RPOCKET, ITEM_SLOT_SUITSTORE, ITEM_SLOT_DEX_STORAGE)
	signals = list(COMSIG_MOB_CREAMED, COMSIG_ON_CARBON_SLIP, COMSIG_ON_VENDOR_CRUSH, COMSIG_MOB_CLUMSY_SHOOT_FOOT)
	proctype = .proc/EngageInComedy
	mobtype = /mob/living
	///Sounds used for when user has a sitcom action occur
	var/list/comedysounds = list('sound/items/SitcomLaugh1.ogg', 'sound/items/SitcomLaugh2.ogg', 'sound/items/SitcomLaugh3.ogg')

///Play the laugh track if any of the signals related to comedy have been sent.
/datum/component/wearertargeting/sitcomlaughter/proc/EngageInComedy(datum/source)
	SIGNAL_HANDLER
	playsound(parent, pick(comedysounds), 100, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
