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

/**
 * key defines used when converting a paper to and fro' a data/json list. It's really important that they stay the same
 * lest we break persistence.
 */
#define LIST_PAPER_COLOR "paper_color"
#define LIST_PAPER_NAME "paper_name"

#define LIST_PAPER_RAW_TEXT_INPUT "raw_text_input"
#define LIST_PAPER_RAW_FIELD_INPUT "raw_field_input"
#define LIST_PAPER_RAW_STAMP_INPUT "raw_stamp_input"

#define LIST_PAPER_RAW_TEXT "raw_text"
#define LIST_PAPER_FONT "font"
#define LIST_PAPER_FIELD_COLOR "color"
#define LIST_PAPER_BOLD "bold"
#define LIST_PAPER_ADVANCED_HTML "advanced_html"

#define LIST_PAPER_FIELD_INDEX "field_index"
#define LIST_PAPER_FIELD_DATA "field_data"
#define LIST_PAPER_IS_SIGNATURE "is_signature"

#define LIST_PAPER_CLASS "class"
#define LIST_PAPER_STAMP_X "x"
#define LIST_PAPER_STAMP_Y "y"
#define LIST_PAPER_ROTATION "rotation"
