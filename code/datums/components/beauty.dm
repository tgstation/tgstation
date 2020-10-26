/**
  * Beauty component, makes indoors areas prettier/uglier depending on the tallied beauty of their contents.
  * Clean and well decorated areas lead to a positive moodlets for passerbies, while shabbier, dirtier ones
  * lead to negative moodlets exclusive to characters with the snob quirk.
  *
  * Please use MODIFY_BEAUTY() macro for both adding and removing beauty and refrain from using qdel() or RemoveComponent().
  */
/datum/component/beauty
	var/beauty = 0
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/beauty/Initialize(beautyamount)
	if(!isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE

	beauty = beautyamount

	if(ismovable(parent))
		RegisterSignal(parent, COMSIG_ENTER_AREA, .proc/enter_area)
		RegisterSignal(parent, COMSIG_EXIT_AREA, .proc/exit_area)

	var/area/A = get_area(parent)
	if(A)
		enter_area(null, A)

/datum/component/beauty/proc/enter_area(datum/source, area/A)
	SIGNAL_HANDLER

	if(A.outdoors)
		return
	A.totalbeauty += beauty
	A.update_beauty()

/datum/component/beauty/proc/exit_area(datum/source, area/A)
	SIGNAL_HANDLER

	if(A.outdoors)
		return
	A.totalbeauty -= beauty
	A.update_beauty()

/datum/component/beauty/InheritComponent(datum/component/beauty/new_comp , i_am_original, beautyamount)
	if((beauty + beautyamount) == 0)
		qdel(src)
		return
	beauty += beautyamount
	var/area/A = get_area(parent)
	if(A && !A.outdoors)
		A.totalbeauty += beautyamount
		A.update_beauty()

/datum/component/beauty/Destroy()
	. = ..()
	var/area/A = get_area(parent)
	if(A)
		exit_area(null, A)
