///Do (almost) nothing - indev placeholder for switch case implementations etc
#define NOOP (.=.)
/// Copies the L from element START to elememt END if L is initialized, otherwise returns an empty list.
#define LAZYCOPY_RANGE(L, START, END) ( L ? L.Copy(START, END) : list() )
/// Cuts the L from element START to elememt END if L is initialized, otherwise returns an empty list.
#define LAZYCUT(L, START, END) ( L ? L.Cut(START, END) : NOOP )
