/// If the recipe deletes contents of the crafted item (Only works with storage items, used for ammo boxes, donut boxes, internals boxes, etc)
#define RECIPE_DELETE_CONTENTS (1<<0)
/// If the recipe deletes the crafting reagents instead of transferring them (Only works with items that have a reagent holder)
#define RECIPE_DONT_TRANSFER_REAGENTS (1<<1)
