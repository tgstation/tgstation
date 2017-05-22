#ifndef ALL_MAPS
#include "map_files\generic\SpaceStation.dmm"
#include "map_files\generic\Centcomm.dmm"
#include "map_files\generic\Space.dmm"
#include "map_files\generic\SpaceDock.dmm"
<<<<<<< HEAD
#include "map_files\Mining\lavaland.dmm"
=======
#include "map_files\Mining\Lavaland.dmm"

#else

#include "map_files\debug\runtimestation.dmm"
#include "map_files\Deltastation\DeltaStation2.dmm"
#include "map_files\MetaStation\MetaStation.dmm"
#include "map_files\OmegaStation\OmegaStation.dmm"
#include "map_files\PubbyStation\PubbyStation.dmm"
#include "map_files\TgStation\tgstation.2.1.3.dmm"
#include "map_files\Cerestation\cerestation.dmm"

#include "map_files\generic\Centcomm.dmm"
#include "map_files\generic\SpaceStation.dmm"
#include "map_files\generic\Space.dmm"
#include "map_files\generic\SpaceDock.dmm"

#include "map_files\Mining\Lavaland.dmm"

#ifdef TRAVISBUILDING
#include "templates.dm"
#endif

>>>>>>> 449fb93545... Megafauna and lavaland mobs will no longer spawn directly on top of the mining base (#27476)
#endif