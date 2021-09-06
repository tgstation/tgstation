///each cell in a spatial_hashmap is this many turfs in length and width
#define HASHMAP_CELLSIZE 5

//hashmap contents channels

///everything that is hearing sensitive is stored in this channel
#define HASHMAP_CONTENTS_TYPE_HEARING RECURSIVE_CONTENTS_HEARING_SENSITIVE
///every movable that has a client in it is stored in this channel
#define HASHMAP_CONTENTS_TYPE_CLIENTS RECURSIVE_CONTENTS_CLIENT_MOBS
