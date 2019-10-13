/datum/component/decal/blood
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/decal/blood/Initialize(_icon, _icon_state, _dir, _cleanable=CLEAN_STRENGTH_BLOOD, _color, _layer=ABOVE_OBJ_LAYER)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_GET_EXAMINE_NAME, .proc/get_examine_name)

/datum/component/decal/blood/generate_appearance(_icon, _icon_state, _dir, _layer, _color)
	var/obj/item/I = parent
	I.update_icon()
	if(!_icon)
		_icon = 'icons/effects/blood.dmi'
	if(!_icon_state)
		_icon_state = "itemblood"
	var/icon = initial(I.icon)
	var/icon_state = I.icon_state
	if(!istype(I,/obj/item/stack))
		icon_state = initial(I.icon_state) //This keeps items like metal stacks and rod stacks from getting screwed with all that much.
	if(!icon || !icon_state)
		// It's something which takes on the look of other items, probably
		icon = I.icon
		icon_state = I.icon_state
	var/static/list/blood_splatter_appearances = list()
	//try to find a pre-processed blood-splatter. otherwise, make a new one
	var/index = "[REF(icon)]-[icon_state]"
	pic = blood_splatter_appearances[index]

	if(!pic)
		var/icon/blood_splatter_icon = icon(initial(I.icon), (initial(I.icon_state)), , 1)	//we only want to apply blood-splatters to the initial icon_state for each object
		if(istype(I,/obj/item/stack))
			blood_splatter_icon = icon(initial(I.icon), I.icon_state, , 1)		//As above, special case to prevent stacked items from getting messy.
		blood_splatter_icon.Blend("#fff", ICON_ADD) 			//fills the icon_state with white (except where it's transparent)
		blood_splatter_icon.Blend(icon(_icon, _icon_state), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
		if(istype(I,/obj/item/stack))
			pic = mutable_appearance(blood_splatter_icon, I.icon_state)
		else
			pic = mutable_appearance(blood_splatter_icon, initial(I.icon_state))
		blood_splatter_appearances[index] = pic
	return TRUE

/datum/component/decal/blood/proc/get_examine_name(datum/source, mob/user, list/override)
	var/atom/A = parent
	override[EXAMINE_POSITION_ARTICLE] = A.gender == PLURAL? "some" : "a"
	override[EXAMINE_POSITION_BEFORE] = " blood-stained "
	return COMPONENT_EXNAME_CHANGED

