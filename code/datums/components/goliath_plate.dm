/datum/component/goliath_plate
	var/amount = 0

/datum/component/goliath_plate/Initialize(obj/item/src,mob/user)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(COMSIG_PARENT_ATTACKBY, .proc/applyplate)
	applyplate(src,user) //need to call it once since the component does not start applied to the armors

/datum/component/goliath_plate/proc/examine(mob/user)
	if(amount)
		to_chat(user, "It has been strengthened with [amount] goliath plate\s.")
	else
		to_chat(user, "It can be strengthened with goliath hide plates.")

/datum/component/goliath_plate/proc/applyplate(obj/item/I, mob/user)
	if(!istype(I,/obj/item/stack/sheet/animalhide/goliath_hide))
		return
	var/obj/item/clothing/C = parent //we know it's always clothing atm but the game doesn't, typecasting
	if(!istype(C)) //but lets make sure it IS actually clothing.
		return
	if(C.armor.melee >= 60)
		to_chat(user, "<span class='warning'>You can't improve [C] any further!</span>")
		return
	C.armor = C.armor.setRating(melee = min(C.armor.melee + 10, 60))
	to_chat(user, "<span class='info'>You strengthen [C], improving its resistance against melee attacks.</span>")
	I.use(1)
	amount++