/// We only want chunk sizes that are to the power of 2. E.g: 2, 4, 8, 16, etc..
#define CHUNK_SIZE 16
/// The maximum number of chunks in any given direction. The maximum length of chunks on a z-level is CHUNK_SIZE * MAX_CHUNKS.
#define MAX_CHUNKS 256
/// Takes a position and transforms it into a chunk coordinate index. Supports up to 256 16x16 chunks in each dimension.
#define GET_CHUNK_COORDS(x, y, z) ((z << 16) | (floor(x / CHUNK_SIZE) << 8) | floor(y / CHUNK_SIZE))

//List of different camera nets, cameras are given this in the map and camera consoles can only view them if
//they share this network with them.
#define CAMERANET_NETWORK_SS13 "ss13"
#define CAMERANET_NETWORK_MINE "mine"
#define CAMERANET_NETWORK_RD "rd"
#define CAMERANET_NETWORK_LABOR "labor"
#define CAMERANET_NETWORK_ORDNANCE "ordnance"
#define CAMERANET_NETWORK_AUXBASE "auxbase"
#define CAMERANET_NETWORK_VAULT "vault"
#define CAMERANET_NETWORK_AI_CORE "aicore"
#define CAMERANET_NETWORK_AI_UPLOAD "aiupload"
#define CAMERANET_NETWORK_MINISAT "minisat"
#define CAMERANET_NETWORK_XENOBIOLOGY "xeno"
#define CAMERANET_NETWORK_TEST_CHAMBER "test"
#define CAMERANET_NETWORK_PRISON "prison"
#define CAMERANET_NETWORK_ISOLATION "isolation"
#define CAMERANET_NETWORK_MEDBAY "medbay"
#define CAMERANET_NETWORK_ENGINE "engine"
#define CAMERANET_NETWORK_WASTE "waste"
#define CAMERANET_NETWORK_TELECOMMS "tcomms"
#define CAMERANET_NETWORK_TURBINE "turbine"
#define CAMERANET_NETWORK_THUNDERDOME "thunder"
#define CAMERANET_NETWORK_BAR "bar"
#define CAMERANET_NETWORK_INTERROGATION "interrogation"
#define CAMERA_NETWORK_CARGO "cargo"
#define CAMERANET_NETWORK_ABDUCTOR "abductor"
#define OPERATIVE_CAMERA_NET "operative"
#define CAMERANET_NETWORK_CURATOR "curator"
#define CAMERANET_NETWORK_FILMSTUDIO "filmstudio"
#define CAMERANET_NETWORK_MONASTERY "monastery"

// Ruins/Away missiosn/Misc camera nets
#define CAMERANET_NETWORK_MOON19_XENO "mo19x"
#define CAMERANET_NETWORK_MOON19_RESEARCH "mo19r"
#define CAMERANET_NETWORK_UGO45_RESEARCH "uo45r"
#define CAMERANET_NETWORK_FSCI "fsci"
#define CAMERA_NETWORK_BUNKER "bunker1"
