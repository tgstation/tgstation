/// Green eye; fully interactive
#define UI_INTERACTIVE 2
/// Orange eye; updates but is not interactive
#define UI_UPDATE 1
/// Red eye; disabled, does not update
#define UI_DISABLED 0
/// UI Should close
#define UI_CLOSE -1
/// UI is actively in the process of closing
#define UI_CLOSING -2

/// Maximum amount of simutaneously open windows before it stops recycling and always destroys
#define MAX_RECYCLED_WINDOWS 5
