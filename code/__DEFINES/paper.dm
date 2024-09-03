/// Maximimum number of characters that we allow on paper.
#define MAX_PAPER_LENGTH 5000
/// Max number of stamps that can be applied to the paper in tgui.
#define MAX_PAPER_STAMPS 30
/// Max number of stamp overlays that we'll add to a piece of paper's icon.
#define MAX_PAPER_STAMPS_OVERLAYS 4
/// Maximum length of input fields. Input fields greater than this length are clamped tgui-side. Input field text input greater than this length is rejected tgui-side, discarded + logged if it reaches DM-side.
#define MAX_PAPER_INPUT_FIELD_LENGTH MAX_NAME_LEN

/// Should not be able to write on or stamp paper.
#define MODE_READING 0
/// Should be able to write on paper.
#define MODE_WRITING 1
/// Should be able to stamp paper.
#define MODE_STAMPING 2

#define BARCODE_SCANNER_CHECKIN "check_in"
#define BARCODE_SCANNER_INVENTORY "inventory"

#define IS_WRITING_UTENSIL(thing) (thing?.get_writing_implement_details()?["interaction_mode"] == MODE_WRITING)
