turf/var/zone/zone

var/list/zones = list()
var/zone_controller/zone_master = new

zone_controller
	var
		current_tick = 0
	proc
		start()
			set background = 1
			while(1)
				current_tick++
				for(var/zone/Z in zones)
					if(Z.last_update < current_tick)
						Z.process()
						if(Z) Z.last_update = current_tick
				for(var/obj/fire/F)
					F.process()
				//for(var/obj/z_hotspot/H in z_hotspots)
				//	H.process()
				sleep(max(5,vsc.zone_update_delay*tick_multiplier))

zone
	var
		dbg_output = 0 //Enables debug output.
		rebuild = 0 //If 1, zone will be rebuilt on next process.
		datum/gas_mixture/air //The air contents of the zone.
		list/contents //All the tiles that are contained in this zone.
		list/connections // /connection objects which refer to connections with other zones, e.g. through a door.
		list/connected_zones //Parallels connections, but lists zones to which this one is connected and the number
							//of points they're connected at.
		list/space_tiles // Any space tiles in this list will cause air to flow out.
		last_update = 0