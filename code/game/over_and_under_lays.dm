//The deets:
//To use, edit one of the 2 sublists in overlay_list/underlay_list then call redraw_overlays or redraw_underlays
//The sublists are:
//	(overlay used as example, underlay contains the same layers, only replace overlay with underlay)
//	OVERLAY_APPEARANCE - overlay is part of the atom, and should be concidered to be defining the atom's appearance
//		(think limbs on a mob)
//
//	OVERLAY_PRIORITY
//	UNDERLAY_PRIORITY
//		Mainly for outside use. Things that edit other thing's overlays or underlays can use these
//		to keep them from getting cleared by that thing. for overlays they appear above the other overlays
//		for underlays they appear below the other underlays
//
//	clear_overlays() does not reset priority overlays, the thing that added the overlays is
//		responsable for removing the individual overlays it added when needed.
//
//	clear_overlays() does not call redraw_overlays() or redraw them, you must call redraw_overlays.
//		(This is so things that do clear->add can delay redraw until after the new overlays are added)
//
// Each of the lists can contain their own list of sublists if needed,
// Associated values are also supported and in those cases, the value is what will be added, not the key
//		(This means no more storing a seperate list of overlays for the object, you can just key it to a value)
// 		(You can ofcouse also do a sublists of associated values
//
//	(same for underlays of ofcourse)

#define OVERLAY_UNDERLAY_LIST list(list(), list())
/atom/var/list/overlay_list = OVERLAY_UNDERLAY_LIST

/atom/var/list/underlay_list = OVERLAY_UNDERLAY_LIST

//When using this proc, it is still the caller's responsibility to call redraw_overlays().
//	This keeps byond from sending out two appearance updates to clients needlessly
//	if the caller then adds overlays.
/atom/proc/clear_overlays()
	var/list/newoverlays = OVERLAY_UNDERLAY_LIST
	newoverlays[OVERLAY_PRIORITY] += overlay_list[OVERLAY_PRIORITY]
	overlay_list = newoverlays

/atom/proc/redraw_overlays()
	var/list/newoverlays = list()
	var/associated_value
	for (var/L in overlay_list)
		for (var/O in L)
			if (islist(O))
				for (var/OO in O)
					associated_value = O[OO]
					if (associated_value)
						newoverlays += associated_value
					else
						newoverlays += OO
			else
				associated_value = L[O]
				if (associated_value)
					newoverlays += associated_value
				else
					newoverlays += O
	overlays = newoverlays


//When using this proc, it is still the caller's responsibility to call redraw_underlays().
//	This keeps byond from sending out two appearance updates to clients needlessly
//	if the caller then adds underlays.
/atom/proc/clear_underlays()
	var/list/newunderlays = OVERLAY_UNDERLAY_LIST
	newunderlays[UNDERLAY_UNDER_PRIORITY] += underlay_list[UNDERLAY_UNDER_PRIORITY]
	newunderlays[UNDERLAY_ABOVE_PRIORITY] += underlay_list[UNDERLAY_ABOVE_PRIORITY]
	underlay_list = newunderlays

/atom/proc/redraw_underlays()
	var/list/newunderlays = list()
	var/associated_value
	for (var/L in underlay_list)
		for (var/U in L)
			if (islist(U))
				for (var/UU in U)
					associated_value = U[U]
					if (associated_value)
						newunderlays += associated_value
					else
						newunderlays += UU
			else
				associated_value = L[U]
				if (associated_value)
					newunderlays += associated_value
				else
					newunderlays += U
	underlays = newunderlays


#undef OVERLAY_UNDERLAY_LIST