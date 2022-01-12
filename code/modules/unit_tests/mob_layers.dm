/// Checks if the layers of all atoms are on the proper planes.
/datum/unit_test/mob_layers

/datum/unit_test/mob_layers/Run()
	for(var/atom/movable/movable_path as anything in typesof(/atom/movable))
		var/layer = initial(movable_path.layer)
		var/plane = initial(movable_path.plane)
		if(isnull(layer) || isnull(plane)) //Some abstract atoms maybe I dont know?
			continue
		switch(layer)
			if(GAME_PLANE_FOV_HIDDEN_LAYER_START to GAME_PLANE_FOV_HIDDEN_LAYER_END)
				if(plane != GAME_PLANE_FOV_HIDDEN)
					Fail("[movable_path] with layer [layer] should be in plane [GAME_PLANE_FOV_HIDDEN] (GAME_PLANE_FOV_HIDDEN). Currently is in [plane].")
			if(ABOVE_GAME_PLANE_LAYER_START to ABOVE_GAME_PLANE_LAYER_END)
				if(plane != ABOVE_GAME_PLANE)
					Fail("[movable_path] with layer [layer] should be in plane [ABOVE_GAME_PLANE] (ABOVE_GAME_PLANE). Currently is in [plane].")
			else
				if(plane == ABOVE_GAME_PLANE || plane == GAME_PLANE_FOV_HIDDEN)
					Fail("[movable_path] with layer [layer] shouldn't be in either [ABOVE_GAME_PLANE] (ABOVE_GAME_PLANE) or [GAME_PLANE_FOV_HIDDEN] (GAME_PLANE_FOV_HIDDEN) planes.")
