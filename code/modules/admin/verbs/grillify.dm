// Made during the internet outage caused by hurricane ike
// fuck you ike
// love persh
///client/proc/grillify()
//	set category = "Debug"
//	set name = "spawn grilles"
//	set desc="it spawns grilles okay fuck if I know"
//	if(Debug2)
//		//	All admins should be authenticated, but... what if?
//		if(!src.authenticated || !src.holder)
//			src << "Only administrators may use this command."
//			return
//
//		log_admin("[src.key] used the grillify verb")
//		world << "\blue<big><B>[src.key] used the grillify verb/bitches better get yellow gloves verb!</big></B>"
//
//		for(var/turf/T in world)
//			if(!T.density)
//				spawn(-1)
//					new /obj/grille(locate(T.x,T.y,T.z))
//	else
//		alert("Debugging is disabled")
//		return