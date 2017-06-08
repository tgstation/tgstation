
//Intended for pathfinding operations like AStar

PROCESSING_SUBSYSTEM_DEF(pathing)
	name = "Pathfinding"
	wait = 1
	priority = 80		//No one cares about laggy pathfinding!
	stat_tag = "PF"
	runlevels = ALL

//Currently no different from other processing subsystems, but different operations should be
//in separate processing lists in the future if any are added.
