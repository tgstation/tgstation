// Overmind defines

#define OVERMIND_MAX_POINTS_DEFAULT                 100         // Max point storage
#define OVERMIND_STARTING_POINTS                    60          // Points granted upon start
#define OVERMIND_STARTING_REROLLS                   1           // Free strain rerolls at the start
#define OVERMIND_STARTING_MIN_PLACE_TIME            1 MINUTES   // Minimum time before the core can be placed
#define OVERMIND_STARTING_AUTO_PLACE_TIME           6 MINUTES   // After this time, randomly place the core somewhere viable
#define OVERMIND_WIN_CONDITION_AMOUNT               400         // Blob structures required to win
#define OVERMIND_ANNOUNCEMENT_MIN_SIZE              75          // Once the blob has this many structures, announce their presence
#define OVERMIND_ANNOUNCEMENT_MAX_TIME              10 MINUTES  // If the blob hasn't reached the minimum size before this time, announce their presence
#define OVERMIND_MAX_CAMERA_STRAY                   "3x3"       // How far the overmind camera is allowed to stray from blob tiles. 3x3 is 1 tile away, 5x5 2 tiles etc

// Blob defines

#define BLOB_EXPAND_COST                            4           // Price to expand onto a new tile
#define BLOB_ATTACK_REFUND                          2           // Points 'refunded' when the expand attempt actually attacks something instead
#define BLOB_BRUTE_RESIST                           0.5
#define BLOB_FIRE_RESIST                            1
#define BLOB_EXPAND_CHANCE_MULTIPLIER               1           // Increase this value to make blobs naturally expand faster
#define BLOB_REINFORCE_CHANCE                       2.5         // The delta_time chance for cores/nodes to reinforce their surroundings



// Structure properties
#define BLOB_CORE_PULSE_RANGE                       4           // The radius up to which the core activates structures, and up to which structures can be built
#define BLOB_CORE_EXPAND_RANGE                      3           // Radius of automatic expansion
#define BLOB_NODE_PULSE_RANGE                       3           // Same, but for nodes

#define BLOB_CORE_STRONG_REINFORCE_RANGE            1           // The radius of tiles surrounding the core that get upgraded
#define BLOB_CORE_REFLECTOR_REINFORCE_RANGE         0

#define BLOB_REGULAR_MAX_HP                         30
#define BLOB_STRONG_MAX_HP                          150
#define BLOB_REFLECTOR_MAX_HP                       150
#define BLOB_RESOURCE_MAX_HP                        
#define BLOB_FACTORY_MAX_HP                         200
#define BLOB_NODE_MAX_HP
#define BLOB_CORE_MAX_HP                            400

#define BLOB_REGULAR_HP_REGEN                       1           // Health regenerated when pulsed by a node/core
#define BLOB_STRONG_HP_REGEN                        2
#define BLOB_REFLECTOR_HP_REGEN                     2       
#define BLOB_RESOURCE_HP_REGEN
#define BLOB_FACTORY_HP_REGEN                       1
#define BLOB_CORE_HP_REGEN

// Structure purchasing
#define BLOB_UPGRADE_STRONG_COST                    15          // Upgrade and build costs here
#define BLOB_UPGRADE_REFLECTOR_COST                 15
#define BLOB_STRUCTURE_RESOURCE_COST                40
#define BLOB_STRUCTURE_FACTORY_COST                 60
#define BLOB_STRUCTURE_NODE_COST                    50

#define BLOB_REFUND_STRONG_COST                     4           // Points refunded when destroying the structure
#define BLOB_REFUND_REFLECTOR_COST                  8
#define BLOB_REFUND_FACTORY_COST                    25

// Blob power properties
#define BLOB_POWER_RELOCATE_COST                    30          // Resource cost to move your core to a different node
#define BLOB_POWER_REROLL_COST                      40          // Strain reroll
#define BLOB_POWER_REROLL_FREE_TIME                 4 MINUTES   // Gain a free strain reroll every x minutes
#define BLOB_POWER_REROLL_CHOICES                   6           // Possibilities to choose from; keep in mind increasing this might fuck with the radial menu



// Mob defines

#define BLOBMOB_HEALING_MULTIPLIER                  0.0125      // Multiplies by -maxHealth and heals the blob by this amount every blob_act
#define BLOBMOB_SPORE_HEALTH                        30          // Base spore health
#define BLOBMOB_SPORE_DMG_LOWER                     2
#define BLOBMOB_SPORE_DMG_UPPER                     4
#define BLOBMOB_BLOBBERNAUT_RESOURCE_COST           40          // Purchase price for making a blobbernaut
#define BLOBMOB_BLOBBERNAUT_HEALTH                  200         // Base blobbernaut health
#define BLOBMOB_BLOBBERNAUT_DMG_SOLO_LOWER          20          // Damage without active overmind (core dead or xenobio mob)
#define BLOBMOB_BLOBBERNAUT_DMG_SOLO_UPPER          20
#define BLOBMOB_BLOBBERNAUT_DMG_LOWER               4           // Damage dealt with active overmind (most damage comes from strain chems)
#define BLOBMOB_BLOBBERNAUT_DMG_UPPER               4
#define BLOBMOB_BLOBBERNAUT_REAGENTATK_VOL          20          // Amounts of strain reagents applied on attack -- basically the main damage stat
#define BLOBMOB_BLOBBERNAUT_DMG_OBJ                 60          // Damage dealth to objects/machines
#define BLOBMOB_BLOBBERNAUT_HEALING_CORE            0.1         // Percentage multiplier HP restored on Life() when within 2 tiles of the blob core
#define BLOBMOB_BLOBBERNAUT_HEALING_NODE            0.05        // Same, but for a nearby node
#define BLOBMOB_BLOBBERNAUT_HEALTH_DECAY            0.025       // Percentage multiplier HP lost when not near blob tiles or without factory

