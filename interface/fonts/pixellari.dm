/// For clean results on map, use only sizing pt, multiples of 12: 12pt 24pt 48pt etc. - Not for use with px sizing
/// Can be used in TGUI etc, px sizing is pt / 0.75. 12pt = 16px, 24pt = 32px etc.

/// Base font
/datum/font/pixellari
	name = "Pixellari"
	font_family = 'interface/fonts/Pixellari_modif.ttf'

/// For icon overlays
/// Pixellari 12pt metrics generated using Lummox's dmifontsplus (https://www.byond.com/developer/LummoxJR/DmiFontsPlus)
/// Note: these variable names have been changed, so you can't straight copy/paste from dmifontsplus.exe
/datum/font/pixellari/size_12pt
	name = "Pixellari 12pt"
	height = 16
	ascent = 12
	descent = 4
	average_width = 7
	max_width = 15
	overhang = 0
	in_leading = 0
	ex_leading = 1
	default_character = 31
	start = 30
	end = 255
	metrics = list(\
		1, 5, 0,	/* char 30 */ \
		1, 5, 0,	/* char 31 */ \
		0, 1, 4,	/* char 32 */ \
		1, 2, 1,	/* char 33 */ \
		1, 5, 1,	/* char 34 */ \
		0, 8, 1,	/* char 35 */ \
		2, 6, 1,	/* char 36 */ \
		0, 13, 1,	/* char 37 */ \
		1, 8, 1,	/* char 38 */ \
		1, 2, 1,	/* char 39 */ \
		1, 3, 1,	/* char 40 */ \
		2, 3, 1,	/* char 41 */ \
		0, 6, 1,	/* char 42 */ \
		1, 6, 1,	/* char 43 */ \
		1, 2, 1,	/* char 44 */ \
		1, 6, 1,	/* char 45 */ \
		1, 2, 1,	/* char 46 */ \
		0, 6, 1,	/* char 47 */ \
		1, 7, 1,	/* char 48 */ \
		2, 6, 1,	/* char 49 */ \
		1, 6, 1,	/* char 50 */ \
		1, 6, 1,	/* char 51 */ \
		1, 7, 1,	/* char 52 */ \
		1, 6, 1,	/* char 53 */ \
		1, 6, 1,	/* char 54 */ \
		1, 7, 1,	/* char 55 */ \
		1, 6, 1,	/* char 56 */ \
		1, 6, 1,	/* char 57 */ \
		1, 2, 1,	/* char 58 */ \
		1, 2, 1,	/* char 59 */ \
		0, 10, 1,	/* char 60 */ \
		1, 6, 1,	/* char 61 */ \
		0, 10, 1,	/* char 62 */ \
		1, 6, 1,	/* char 63 */ \
		1, 12, 1,	/* char 64 */ \
		1, 8, 1,	/* char 65 */ \
		1, 8, 1,	/* char 66 */ \
		2, 7, 1,	/* char 67 */ \
		2, 8, 1,	/* char 68 */ \
		2, 6, 1,	/* char 69 */ \
		2, 6, 1,	/* char 70 */ \
		2, 7, 1,	/* char 71 */ \
		1, 8, 1,	/* char 72 */ \
		1, 4, 1,	/* char 73 */ \
		0, 7, 1,	/* char 74 */ \
		1, 8, 1,	/* char 75 */ \
		1, 6, 1,	/* char 76 */ \
		1, 10, 1,	/* char 77 */ \
		1, 9, 1,	/* char 78 */ \
		2, 8, 1,	/* char 79 */ \
		1, 7, 1,	/* char 80 */ \
		2, 9, 1,	/* char 81 */ \
		1, 8, 1,	/* char 82 */ \
		1, 8, 1,	/* char 83 */ \
		1, 8, 1,	/* char 84 */ \
		2, 8, 1,	/* char 85 */ \
		2, 8, 1,	/* char 86 */ \
		1, 10, 1,	/* char 87 */ \
		1, 8, 1,	/* char 88 */ \
		1, 8, 1,	/* char 89 */ \
		0, 10, 1,	/* char 90 */ \
		1, 3, 1,	/* char 91 */ \
		0, 6, 1,	/* char 92 */ \
		2, 3, 1,	/* char 93 */ \
		0, 7, 1,	/* char 94 */ \
		0, 8, 1,	/* char 95 */ \
		1, 3, 1,	/* char 96 */ \
		1, 6, 1,	/* char 97 */ \
		1, 7, 1,	/* char 98 */ \
		1, 6, 1,	/* char 99 */ \
		1, 7, 1,	/* char 100 */ \
		1, 6, 1,	/* char 101 */ \
		1, 4, 1,	/* char 102 */ \
		1, 7, 1,	/* char 103 */ \
		1, 7, 1,	/* char 104 */ \
		1, 2, 1,	/* char 105 */ \
		-1, 4, 1,	/* char 106 */ \
		0, 7, 1,	/* char 107 */ \
		1, 2, 1,	/* char 108 */ \
		1, 10, 1,	/* char 109 */ \
		1, 6, 1,	/* char 110 */ \
		1, 6, 1,	/* char 111 */ \
		1, 7, 1,	/* char 112 */ \
		1, 7, 1,	/* char 113 */ \
		1, 6, 1,	/* char 114 */ \
		1, 6, 1,	/* char 115 */ \
		0, 4, 1,	/* char 116 */ \
		1, 6, 1,	/* char 117 */ \
		1, 6, 1,	/* char 118 */ \
		1, 10, 1,	/* char 119 */ \
		1, 6, 1,	/* char 120 */ \
		1, 6, 1,	/* char 121 */ \
		1, 6, 1,	/* char 122 */ \
		0, 5, 1,	/* char 123 */ \
		1, 2, 1,	/* char 124 */ \
		0, 5, 1,	/* char 125 */ \
		1, 8, 1,	/* char 126 */ \
		1, 5, 0,	/* char 127 */ \
		1, 8, 1,	/* char 128 */ \
		1, 5, 0,	/* char 129 */ \
		1, 5, 0,	/* char 130 */ \
		1, 5, 0,	/* char 131 */ \
		1, 5, 0,	/* char 132 */ \
		1, 5, 0,	/* char 133 */ \
		1, 5, 0,	/* char 134 */ \
		1, 5, 0,	/* char 135 */ \
		1, 5, 0,	/* char 136 */ \
		1, 5, 0,	/* char 137 */ \
		1, 8, 1,	/* char 138 */ \
		1, 5, 0,	/* char 139 */ \
		0, 14, 1,	/* char 140 */ \
		1, 5, 0,	/* char 141 */ \
		0, 10, 1,	/* char 142 */ \
		1, 5, 0,	/* char 143 */ \
		1, 5, 0,	/* char 144 */ \
		1, 5, 0,	/* char 145 */ \
		1, 5, 0,	/* char 146 */ \
		1, 5, 0,	/* char 147 */ \
		1, 5, 0,	/* char 148 */ \
		1, 5, 0,	/* char 149 */ \
		1, 5, 0,	/* char 150 */ \
		1, 5, 0,	/* char 151 */ \
		1, 5, 0,	/* char 152 */ \
		1, 5, 0,	/* char 153 */ \
		1, 6, 1,	/* char 154 */ \
		1, 5, 0,	/* char 155 */ \
		1, 11, 1,	/* char 156 */ \
		1, 5, 0,	/* char 157 */ \
		1, 6, 1,	/* char 158 */ \
		1, 8, 1,	/* char 159 */ \
		0, 1, 4,	/* char 160 */ \
		1, 2, 1,	/* char 161 */ \
		1, 6, 1,	/* char 162 */ \
		0, 8, 1,	/* char 163 */ \
		0, 9, 1,	/* char 164 */ \
		1, 8, 1,	/* char 165 */ \
		1, 2, 1,	/* char 166 */ \
		1, 7, 1,	/* char 167 */ \
		0, 5, 1,	/* char 168 */ \
		-1, 12, 1,	/* char 169 */ \
		0, 6, 1,	/* char 170 */ \
		0, 8, 1,	/* char 171 */ \
		1, 8, 1,	/* char 172 */ \
		1, 5, 0,	/* char 173 */ \
		-1, 12, 1,	/* char 174 */ \
		2, 4, 1,	/* char 175 */ \
		0, 6, 1,	/* char 176 */ \
		1, 6, 1,	/* char 177 */ \
		0, 5, 1,	/* char 178 */ \
		0, 5, 1,	/* char 179 */ \
		1, 3, 1,	/* char 180 */ \
		1, 6, 1,	/* char 181 */ \
		1, 7, 1,	/* char 182 */ \
		1, 2, 1,	/* char 183 */ \
		1, 3, 1,	/* char 184 */ \
		1, 4, 1,	/* char 185 */ \
		0, 6, 1,	/* char 186 */ \
		0, 8, 1,	/* char 187 */ \
		1, 13, 1,	/* char 188 */ \
		1, 12, 1,	/* char 189 */ \
		0, 13, 1,	/* char 190 */ \
		1, 6, 1,	/* char 191 */ \
		1, 8, 1,	/* char 192 */ \
		1, 8, 1,	/* char 193 */ \
		1, 8, 1,	/* char 194 */ \
		1, 8, 1,	/* char 195 */ \
		1, 8, 1,	/* char 196 */ \
		1, 8, 1,	/* char 197 */ \
		0, 13, 1,	/* char 198 */ \
		2, 7, 1,	/* char 199 */ \
		2, 6, 1,	/* char 200 */ \
		2, 6, 1,	/* char 201 */ \
		2, 6, 1,	/* char 202 */ \
		2, 6, 1,	/* char 203 */ \
		1, 4, 1,	/* char 204 */ \
		1, 4, 1,	/* char 205 */ \
		1, 4, 1,	/* char 206 */ \
		1, 4, 1,	/* char 207 */ \
		0, 10, 1,	/* char 208 */ \
		1, 9, 1,	/* char 209 */ \
		2, 8, 1,	/* char 210 */ \
		2, 8, 1,	/* char 211 */ \
		2, 8, 1,	/* char 212 */ \
		2, 8, 1,	/* char 213 */ \
		2, 8, 1,	/* char 214 */ \
		1, 6, 1,	/* char 215 */ \
		-2, 14, 1,	/* char 216 */ \
		2, 8, 1,	/* char 217 */ \
		2, 8, 1,	/* char 218 */ \
		2, 8, 1,	/* char 219 */ \
		2, 8, 1,	/* char 220 */ \
		1, 8, 1,	/* char 221 */ \
		1, 8, 1,	/* char 222 */ \
		1, 8, 1,	/* char 223 */ \
		1, 6, 1,	/* char 224 */ \
		1, 6, 1,	/* char 225 */ \
		1, 6, 1,	/* char 226 */ \
		1, 6, 1,	/* char 227 */ \
		1, 6, 1,	/* char 228 */ \
		1, 6, 1,	/* char 229 */ \
		1, 11, 1,	/* char 230 */ \
		1, 6, 1,	/* char 231 */ \
		1, 6, 1,	/* char 232 */ \
		1, 6, 1,	/* char 233 */ \
		1, 6, 1,	/* char 234 */ \
		1, 6, 1,	/* char 235 */ \
		1, 2, 1,	/* char 236 */ \
		1, 2, 1,	/* char 237 */ \
		0, 4, 1,	/* char 238 */ \
		0, 4, 1,	/* char 239 */ \
		1, 7, 1,	/* char 240 */ \
		1, 6, 1,	/* char 241 */ \
		1, 6, 1,	/* char 242 */ \
		1, 6, 1,	/* char 243 */ \
		1, 6, 1,	/* char 244 */ \
		1, 6, 1,	/* char 245 */ \
		1, 6, 1,	/* char 246 */ \
		1, 6, 1,	/* char 247 */ \
		0, 10, 1,	/* char 248 */ \
		1, 6, 1,	/* char 249 */ \
		1, 6, 1,	/* char 250 */ \
		1, 6, 1,	/* char 251 */ \
		1, 6, 1,	/* char 252 */ \
		1, 6, 1,	/* char 253 */ \
		1, 8, 1,	/* char 254 */ \
		1, 6, 1,	/* char 255 */ \
		226)
