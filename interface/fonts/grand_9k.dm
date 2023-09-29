/// For clean results on map, use only sizing pt, multiples of 6: 6pt 12pt 18pt 24pt etc. - Not for use with px sizing
/// Can be used in TGUI etc, px sizing is pt / 0.75. 6pt = 8px, 12pt = 16px etc.

/// Base font
/datum/font/grand9k
	name = "Grand9K Pixel"
	font_family = 'interface/fonts/Grand9K_Pixel_modif.ttf'

/// For icon overlays
/// Grand9K 6pt metrics generated using Lummox's dmifontsplus (https://www.byond.com/developer/LummoxJR/DmiFontsPlus)
/// Note: these variable names have been changed, so you can't straight copy/paste from dmifontsplus.exe
/datum/font/grand9k/size_6pt
	name = "Grand9K Pixel 6pt"
	height = 12
	ascent = 10
	descent = 2
	average_width = 4
	max_width = 9
	overhang = 0
	in_leading = 4
	ex_leading = 1
	default_character = 31
	start = 30
	end = 255
	metrics = list(
		0, 5, 1, // char 30
		0, 5, 1, // char 31
		0, 1, 1, // char 32
		0, 1, 1, // char 33
		0, 3, 1, // char 34
		0, 6, 1, // char 35
		0, 5, 1, // char 36
		0, 7, 1, // char 37
		0, 5, 1, // char 38
		0, 1, 1, // char 39
		0, 3, 1, // char 40
		0, 3, 1, // char 41
		0, 5, 1, // char 42
		0, 5, 1, // char 43
		0, 1, 1, // char 44
		0, 4, 1, // char 45
		0, 1, 1, // char 46
		0, 3, 1, // char 47
		0, 5, 1, // char 48
		0, 2, 1, // char 49
		0, 5, 1, // char 50
		0, 4, 1, // char 51
		0, 5, 1, // char 52
		0, 5, 1, // char 53
		0, 5, 1, // char 54
		0, 5, 1, // char 55
		0, 5, 1, // char 56
		0, 5, 1, // char 57
		0, 1, 1, // char 58
		0, 1, 1, // char 59
		0, 4, 1, // char 60
		0, 4, 1, // char 61
		0, 4, 1, // char 62
		0, 4, 1, // char 63
		0, 7, 1, // char 64
		0, 5, 1, // char 65
		0, 5, 1, // char 66
		0, 4, 1, // char 67
		0, 5, 1, // char 68
		0, 4, 1, // char 69
		0, 4, 1, // char 70
		0, 5, 1, // char 71
		0, 5, 1, // char 72
		0, 1, 1, // char 73
		0, 5, 1, // char 74
		0, 5, 1, // char 75
		0, 5, 1, // char 76
		0, 5, 1, // char 77
		0, 5, 1, // char 78
		0, 5, 1, // char 79
		0, 5, 1, // char 80
		0, 6, 1, // char 81
		0, 5, 1, // char 82
		0, 5, 1, // char 83
		0, 5, 1, // char 84
		0, 5, 1, // char 85
		0, 5, 1, // char 86
		0, 5, 1, // char 87
		0, 5, 1, // char 88
		0, 5, 1, // char 89
		0, 5, 1, // char 90
		0, 3, 1, // char 91
		0, 3, 1, // char 92
		0, 3, 1, // char 93
		0, 5, 1, // char 94
		0, 4, 0, // char 95
		0, 2, 1, // char 96
		0, 4, 1, // char 97
		0, 4, 1, // char 98
		0, 3, 1, // char 99
		0, 4, 1, // char 100
		0, 4, 1, // char 101
		0, 4, 1, // char 102
		0, 4, 1, // char 103
		0, 4, 1, // char 104
		0, 1, 1, // char 105
		0, 3, 1, // char 106
		0, 4, 1, // char 107
		0, 1, 1, // char 108
		0, 5, 1, // char 109
		0, 4, 1, // char 110
		0, 4, 1, // char 111
		0, 4, 1, // char 112
		0, 4, 1, // char 113
		0, 4, 1, // char 114
		0, 4, 1, // char 115
		0, 4, 1, // char 116
		0, 4, 1, // char 117
		0, 5, 1, // char 118
		0, 5, 1, // char 119
		0, 5, 1, // char 120
		0, 4, 1, // char 121
		0, 5, 1, // char 122
		0, 4, 1, // char 123
		0, 1, 1, // char 124
		0, 4, 1, // char 125
		0, 6, 1, // char 126
		0, 5, 1, // char 127
		0, 5, 1, // char 128
		0, 5, 1, // char 129
		0, 1, 1, // char 130
		0, 5, 1, // char 131
		0, 3, 1, // char 132
		0, 5, 1, // char 133
		0, 5, 1, // char 134
		0, 5, 1, // char 135
		0, 5, 1, // char 136
		0, 5, 1, // char 137
		0, 5, 1, // char 138
		0, 3, 1, // char 139
		0, 6, 1, // char 140
		0, 5, 1, // char 141
		0, 5, 1, // char 142
		0, 5, 1, // char 143
		0, 5, 1, // char 144
		0, 1, 1, // char 145
		0, 1, 1, // char 146
		0, 3, 1, // char 147
		0, 3, 1, // char 148
		0, 1, 1, // char 149
		0, 5, 1, // char 150
		0, 5, 1, // char 151
		0, 5, 1, // char 152
		0, 8, 1, // char 153
		0, 4, 1, // char 154
		0, 3, 1, // char 155
		0, 5, 1, // char 156
		0, 5, 1, // char 157
		0, 5, 1, // char 158
		0, 5, 1, // char 159
		0, 1, 1, // char 160
		0, 1, 1, // char 161
		0, 4, 1, // char 162
		0, 5, 1, // char 163
		0, 5, 1, // char 164
		0, 5, 1, // char 165
		0, 1, 1, // char 166
		0, 5, 1, // char 167
		0, 3, 1, // char 168
		0, 8, 1, // char 169
		0, 5, 1, // char 170
		0, 6, 1, // char 171
		0, 4, 1, // char 172
		0, 5, 1, // char 173
		0, 8, 1, // char 174
		0, 5, 1, // char 175
		0, 3, 1, // char 176
		0, 5, 1, // char 177
		0, 5, 1, // char 178
		0, 5, 1, // char 179
		0, 2, 1, // char 180
		0, 4, 1, // char 181
		0, 5, 1, // char 182
		0, 1, 1, // char 183
		0, 2, 1, // char 184
		0, 5, 1, // char 185
		0, 5, 1, // char 186
		0, 6, 1, // char 187
		0, 5, 1, // char 188
		0, 5, 1, // char 189
		0, 5, 1, // char 190
		0, 4, 1, // char 191
		0, 5, 1, // char 192
		0, 5, 1, // char 193
		0, 5, 1, // char 194
		0, 6, 0, // char 195
		0, 5, 1, // char 196
		0, 5, 1, // char 197
		0, 6, 1, // char 198
		0, 4, 1, // char 199
		0, 4, 1, // char 200
		0, 4, 1, // char 201
		0, 4, 1, // char 202
		0, 4, 1, // char 203
		1, 2, 0, // char 204
		0, 2, 1, // char 205
		0, 3, 0, // char 206
		0, 3, 0, // char 207
		0, 6, 1, // char 208
		0, 6, 0, // char 209
		0, 5, 1, // char 210
		0, 5, 1, // char 211
		0, 5, 1, // char 212
		0, 6, 1, // char 213
		0, 5, 1, // char 214
		0, 5, 1, // char 215
		0, 5, 1, // char 216
		0, 5, 1, // char 217
		0, 5, 1, // char 218
		0, 5, 1, // char 219
		0, 5, 1, // char 220
		0, 5, 1, // char 221
		0, 5, 1, // char 222
		0, 5, 1, // char 223
		0, 4, 1, // char 224
		0, 4, 1, // char 225
		0, 4, 1, // char 226
		0, 4, 1, // char 227
		0, 4, 1, // char 228
		0, 4, 1, // char 229
		0, 5, 1, // char 230
		0, 3, 1, // char 231
		0, 4, 1, // char 232
		0, 4, 1, // char 233
		0, 4, 1, // char 234
		0, 4, 1, // char 235
		0, 2, 1, // char 236
		1, 2, 0, // char 237
		0, 3, 0, // char 238
		0, 3, 0, // char 239
		0, 5, 0, // char 240
		0, 4, 1, // char 241
		0, 4, 1, // char 242
		0, 4, 1, // char 243
		0, 4, 1, // char 244
		0, 4, 1, // char 245
		0, 4, 1, // char 246
		0, 5, 1, // char 247
		0, 4, 1, // char 248
		0, 4, 1, // char 249
		0, 4, 1, // char 250
		0, 4, 1, // char 251
		0, 4, 1, // char 252
		0, 4, 1, // char 253
		0, 4, 1, // char 254
		0, 4, 1, // char 255
		226
	)
