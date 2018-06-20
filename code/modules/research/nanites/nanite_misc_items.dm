/obj/item/nanite_injector
	name = "nanite injector (FOR TESTING)"
	desc = "Injects nanites into the user."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/device.dmi'
	icon_state = "nanite_remote"

/obj/item/nanite_injector/attack_self(mob/user)
	user.AddComponent(/datum/component/nanites, 150)

/obj/item/clothing/under/nanite
	name = "nano jumpsuit"
	desc = "Integrates with nanites inside the wearer, slightly boosting their replication rate."
	icon_state = "nanite_jumpsuit"
	var/regen_rate = 0.25

/obj/item/clothing/under/nanite/equipped(mob/living/user, slot)
	if(slot == SLOT_W_UNIFORM)
		START_PROCESSING(SSobj, src)

/obj/item/clothing/under/nanite/dropped(mob/living/user)
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/under/nanite/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/under/nanite/process()
	if(isliving(loc))
		var/mob/living/L = loc
		GET_COMPONENT_FROM(nanites, /datum/component/nanites, L)
		if(!nanites)
			return
		nanites.adjust_nanites(regen_rate)