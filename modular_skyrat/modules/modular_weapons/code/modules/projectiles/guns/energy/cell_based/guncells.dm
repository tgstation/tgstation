/obj/item/weaponcell
	name = "default weaponcell"
	desc = "used to add ammo types to guns"
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/upgrades.dmi'
	icon_state = "Oxy1"
	w_class = WEIGHT_CLASS_SMALL
	var/ammo_type = /obj/item/ammo_casing/energy/medical //What ammo type is added by defautl?
	var/toggle_modes = FALSE //Can the cell switch between modes? Formerly was known as safety
	var/is_toggled =  TRUE //Is the secondary mode toggled?
	var/primary_mode = /obj/item/ammo_casing/energy/medical //The default mode
	var/secondary_mode = /obj/item/ammo_casing/energy/medical //Secondary mode.
	var/shot_name //What is the name of the currently used ammo type?
	var/medicell_examine = FALSE //Gives custom examine text for medicells.

/obj/item/weaponcell/proc/refresh_cellname() //refreshes the shot name
	var/obj/item/ammo_casing/energy/shot = ammo_type
	if(initial(shot.select_name))
		shot_name = initial(shot.select_name)
		return TRUE
	else
		return FALSE

/obj/item/weaponcell/Initialize()
	. = ..()
	AddElement(/datum/element/item_scaling, 0.5, 1)
	refresh_cellname()

/obj/item/weaponcell/examine(mob/user)
	. = ..()
	if(shot_name)
		. += span_noticealien("Using this on a cell based gun will unlock the [shot_name] firing mode")
	if(!toggle_modes) //Doesn't show a description if it can't be toggled in the first place.
		return
	if(medicell_examine)
		. += span_notice("The safety measures on the Medicell, preventing clone damage, are [is_toggled ? "enabled" : "disabled"]")
		return
	else
		. += span_notice("[src] is using the [is_toggled ? "primary" : "secondary"] mode.")
	return .

/obj/item/weaponcell/attack_self(mob/living/user)
	if(!toggle_modes) //Is the cell abled to be toggled?
		return
	is_toggled = !is_toggled //Changes the toggle to the reverse of what it is.
	src.ammo_type = is_toggled ? primary_mode : secondary_mode
	playsound(loc,is_toggled ? 'sound/machines/defib_SaftyOn.ogg' : 'sound/machines/defib_saftyOff.ogg', 50)
	if(medicell_examine)
		balloon_alert(user, "safety [is_toggled ? "enabled" : "disabled"]")
		return
	else if(refresh_cellname())
		balloon_alert(user, "set to [shot_name]")
	return

