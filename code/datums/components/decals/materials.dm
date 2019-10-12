/datum/component/decal/gold
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/decal/gold/Initialize(_icon, _icon_state, _dir, _cleanable=CLEAN_STRENGTH_FIBERS, _color, _layer=ABOVE_OBJ_LAYER)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_GET_EXAMINE_NAME, .proc/get_examine_name)

/datum/component/decal/gold/generate_appearance(_icon, _icon_state, _dir, _layer, _color)
	var/obj/item/I = parent
	if(!_icon)
		_icon = 'icons/effects/materials.dmi'
	if(!_icon_state)
		_icon_state = "shimmer"
	var/icon = initial(I.icon)
	var/icon_state = initial(I.icon_state)
	if(!icon || !icon_state)
		// It's something which takes on the look of other items, probably
		icon = I.icon
		icon_state = I.icon_state
	var/static/list/gold_shimmer_appearances = list()
	//try to find a pre-processed gold shimmer. otherwise, make a new one
	var/index = "[REF(icon)]-[icon_state]"
	pic = gold_shimmer_appearances[index]

	if(!pic)
		var/icon/gold_shimmer_icon = icon(initial(I.icon), initial(I.icon_state), , 1)		//we only want to apply blood-splatters to the initial icon_state for each object
		gold_shimmer_icon.Blend("#fff", ICON_ADD) 			//fills the icon_state with white (except where it's transparent)
		gold_shimmer_icon.Blend(icon(_icon, _icon_state), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
		pic = mutable_appearance(gold_shimmer_icon, initial(I.icon_state))
		gold_shimmer_appearances[index] = pic
	return TRUE

/datum/component/decal/gold/proc/get_examine_name(datum/source, mob/user, list/override)
	var/atom/A = parent
	override[EXAMINE_POSITION_ARTICLE] = A.gender == PLURAL? "some" : "a"
	override[EXAMINE_POSITION_BEFORE] = " expensive-looking "
	return COMPONENT_EXNAME_CHANGED
