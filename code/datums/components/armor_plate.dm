/datum/component/armor_plate
	var/amount = 0
	var/maxamount = 3
	var/obj/item/upgrade_item = /obj/item/stack/sheet/animalhide/goliath_hide
	var/datum/armor/added_armor = list("melee" = 10)

/datum/component/armor_plate/Initialize(_maxamount,obj/item/_upgrade_item,datum/armor/_added_armor)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(COMSIG_PARENT_ATTACKBY, .proc/applyplate)

	if(_maxamount)
		maxamount = _maxamount
	if(_upgrade_item)
		upgrade_item = _upgrade_item
	if(_added_armor)
		if(islist(_added_armor))
			added_armor = getArmor(arglist(_added_armor))
		else if (istype(_added_armor, /datum/armor))
			added_armor = _added_armor
		else
			stack_trace("Invalid type [_added_armor.type] passed as _armor_item argument to armorplate component")
	else
		added_armor = getArmor(arglist(added_armor))

/datum/component/armor_plate/proc/examine(mob/user)
	if(ismecha(parent))
		if(amount)
			if(amount < maxamount)
				to_chat(user, "<span class='notice'>Its armor is enhanced with [amount] [initial(upgrade_item.name)].</span>")
			else
				to_chat(user, "<span class='notice'>It's wearing a fearsome carapace entirely composed of [initial(upgrade_item.name)] - its pilot must be an experienced monster hunter.</span>")
		else
			to_chat(user, "<span class='notice'>It has attachment points for strapping monster hide on for added protection.</span>")
	else
		if(amount)
			to_chat(user, "<span class='notice'>It has been strengthened with [amount]/[maxamount] [initial(upgrade_item.name)].</span>")
		else
			to_chat(user, "<span class='notice'>It can be strengthened with up to [maxamount] [initial(upgrade_item.name)].</span>")

/datum/component/armor_plate/proc/applyplate(obj/item/I, mob/user, params)
	if(!istype(I,upgrade_item))
		return
	var/obj/O = parent
	if(ismecha(O))
		var/obj/mecha/R = O
		if(amount >= maxamount)
			to_chat(user, "<span class='warning'>You can't improve [R] any further!</span>")
			return
		amount++
		R.armor = R.armor.attachArmor(added_armor)
		R.update_icon()
		to_chat(user, "<span class='info'>You strengthen [R], improving its resistance against melee, bullet and laser damage.</span>")
		if(istype(I,/obj/item/stack))
			I.use(1)
		else
			qdel(I)
	else
		if(amount >= maxamount)
			to_chat(user, "<span class='warning'>You can't improve [O] any further!</span>")
			return
		if(istype(I,/obj/item/stack)) //could I un-indent this code and leave just one instance of it here?
			I.use(1)
		else
			if(length(I.contents))
				to_chat(user, "<span class='warning'>[I] cannot be used for armoring while there's something inside!</span>")
				return
			qdel(I)
		O.armor = O.armor.attachArmor(added_armor)
		to_chat(user, "<span class='info'>You strengthen [O], improving its resistance against melee attacks.</span>")
		amount++