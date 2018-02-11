//#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

#include "map_files\generic\CentCom.dmm"
#include "map_files\generic\SpaceStation.dmm"

#ifndef LOWMEMORYMODE

	#include "map_files\generic\Space.dmm"
	#include "map_files\generic\Space2.dmm"
	#include "map_files\Mining\Lavaland.dmm"
	#include "map_files\generic\City_of_Cogs.dmm"

	#ifdef ALL_MAPS
		#include "map_files\debug\runtimestation.dmm"
		#include "map_files\Deltastation\DeltaStation2.dmm"
		#include "map_files\MetaStation\MetaStation.dmm"
		#include "map_files\OmegaStation\OmegaStation.dmm"
		#include "map_files\PubbyStation\PubbyStation.dmm"
		#include "map_files\BoxStation\BoxStation.dmm"

		#ifdef TRAVISBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
