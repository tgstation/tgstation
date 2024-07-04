//for the wound converter component, higher values will take priority over lower ones
#define WOUND_CONVERSION_PRIORITY_ITEM 1
#define WOUND_CONVERSION_PRIORITY_ITEM_HIGH 2
#define WOUND_CONVERSION_PRIORITY_MOB 3
#define WOUND_CONVERSION_PRIORITY_HIGH 4
///NEVER USE THIS PRIORITY LEVEL OR HAVE ANYTHING HIGHER, this is used to make sure we dont try and act on wounds we have already handled
#define WOUND_CONVERSION_PRIORITY_CONVERTED 5
