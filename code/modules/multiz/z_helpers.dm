
//Connects A and B (intended to be numbers, eg: 2, 3) inside SSz_levels.vercial_connections
//(Mentions vertical to avoid confusing with the existing z-transition system, which is """horizontal""")
/proc/ConnectVerticalZs(A, B)
	LAZYINITLIST(SSz_levels.vertical_connections)
	var/list/L = SSz_levels.vertical_connections["[A]"]
	LAZYINITLIST(L)
	L["[B]"] = TRUE
	SSz_levels.vertical_connections["[A]"] = L
	L = SSz_levels.vertical_connections["[B]"]
	LAZYINITLIST(L)
	L["[A]"] = TRUE
	SSz_levels.vertical_connections["[B]"] = L


//Check A and B are connected, without the need for a turf or z_open hole
//Used for sounds, explosions, etc.
/proc/AreZsConnected(A, B)
	if(!LAZYLEN(SSz_levels.vertical_connections))
		return FALSE
	var/list/L = SSz_levels.vertical_connections["[A]"] //only check one of the pairs, as it's a twoway thing A<->B so finding A->B is enough
	if(L)
		return L["[B]"]


//Are we z-connected above, and is there a turf there?
//THE TURF DOES NOT NEED TO BE Z-OPEN
/proc/GetAboveConnectedTurf(atom/A)
	var/turf/Aturf = get_turf(A) //so we always have A's x,y,z coords
	var/turf/T = get_step(A, UP)
	if(Aturf && T && AreZsConnected(Aturf.z, T.z))
		return T


//Are we z-connected below, and is there a turf there?
//THE TURF DOES NOT NEED TO BE Z-OPEN
/proc/GetBelowConnectedTurf(atom/A)
	var/turf/Aturf = get_turf(A)
	var/turf/T = get_step(A, DOWN)
	if(AreZsConnected(Aturf.z, T.z))
		return T


//Same as GetAboveConnectedTurf(), but checks the turf is z_open (used for zshadows, looking up, etc.)
/proc/GetZOpenAbove(atom/A)
	var/turf/T = GetAboveConnectedTurf(A)
	if(!T || !T.z_open)
		return
	return T


//Same as GetBelowConnectedTurf(), but checks the turf is z_open
 //I don't see much use for this one, included as a pair to the above
/proc/GetZOpenBelow(atom/A)
	var/turf/T = GetBelowConnectedTurf(A)
	if(!T || !T.z_open)
		return
	return T
