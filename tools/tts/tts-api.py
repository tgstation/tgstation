from flask import Flask, request, send_file
import shlex
import os, shutil
import json
import math
import gc
import io
import subprocess
import torch
from torch import nn
from torch.nn import functional as F
from torch.utils.data import DataLoader

import commons
import utils
from data_utils import TextAudioLoader, TextAudioCollate, TextAudioSpeakerLoader, TextAudioSpeakerCollate
from models import SynthesizerTrn
from text.symbols import symbols
from text import text_to_sequence
from text.cleaners import english_cleaners2
from text.symbols import symbols

from scipy.io.wavfile import write

voices = {
    "Tiffany Wells": 0,
    "Marley Mason": 1,
    "Oscar Adams": 2,
    "Tanner Wise": 3,
    "Alfredo Poehl": 4,
    "Hortensia Leichter": 5,
    "Jalen Best": 6,
    "Luvenia Heckendora": 7,
    "Jasper Green": 8,
    "Shayla Semenov": 9,
    "Darcey Anderson": 10,
    "Izaiah Kelly": 11,
    "Merideth Margaret": 12,
    "Jasmine Briggs": 13,
    "Natalie Cox": 14,
    "Sabella Day": 15,
    "Tamika Briggs": 16,
    "Chelsea Tireman": 17,
    "Hal Kemerer": 18,
    "Gwenevere Picard": 19,
    "Corey Ward": 20,
    "Wynonna Catleay": 21,
    "Wynonna Pycroft": 22,
    "Nataly Allen": 23,
    "Jeremy Biery": 24,
    "Isiah Marcotte": 25,
    "Jeannine Marshall": 26,
    "Vincent Albright": 27,
    "Asher Carr": 28,
    "Raymond Richardson": 29,
    "Kale Otis": 30,
    "Randa Shaw": 31,
    "Hervey Morgan": 32,
    "Beckett Mortland": 33,
    "Edward Fryer": 34,
    "Delaney Haynes": 35,
    "Morgan Andreev": 36,
    "Casimir Foster": 37,
    "Lillie Christopher": 38,
    "Kathleen Sanders": 39,
    "Zack Clark": 40,
    "Michelle Fraser": 41,
    "Jay Fitzgerald": 42,
    "Jermaine Philips": 43,
    "Nicholas Powell": 44,
    "Taylor Perkins": 45,
    "Garret Stewart": 46,
    "Haleigh Neely": 47,
    "Blake Jones": 48,
    "Jaxson Bowchiew": 49,
    "Jocelyn Albright": 50,
    "Caitlyn Schrader": 51,
    "Rich Basinger": 52,
    "Christian Wardle": 53,
    "Santiago Rathen": 54,
    "Jaime Thompson": 55,
    "Gwenda Smirnov": 56,
    "Lindsay Palmer": 57,
    "Kellie Day": 58,
    "Wisdom Gardner": 59,
    "Kylie Woolery": 60,
    "Fiona Blyant": 61,
    "Kingston Philips": 62,
    "Zune Baker": 63,
    "Lilian Harrold": 64,
    "Nicolas Sommer": 65,
    "Winifred Osterweis": 66,
    "Daniel Bicknell": 67,
    "Valeria Greene": 68,
    "Tamsin Enderly": 69,
    "Karina Aggley": 70,
    "Candis Woollard": 71,
    "Lyndsey Lineman": 72,
    "Titus Hice": 73,
    "Jamarion Blaine": 74,
    "Autumn Gray": 75,
    "Brielle Webb": 76,
    "Claudius Demuth": 77,
    "Marley Earl": 78,
    "Maddox Styles": 79,
    "Eddie Pershing": 80,
    "Landon Hujsak": 81,
    "Marcus Eggbert": 82,
    "Ryder Levett": 83,
    "Jessica Owen": 84,
    "Gabriela Beach": 85,
    "Holden Leslie": 86,
    "Kimberley Pratt": 87,
    "Justice Vader": 88,
    "Ariel Moberly": 89,
    "Kyla Coates": 90,
    "Mallory Moberly": 91,
    "Marisol Fitzgerald": 92,
    "Brooklynn Keener": 93,
    "Ermintrude Eckhardstein": 94,
    "Nina Powell": 95,
    "Jeffrey Mathews": 96,
    "Rylie Elderson": 97,
    "Phoenix Blackburn": 98,
    "Tamika Hawking": 99,
    "Shelby Wilo": 100,
    "Davion Carr": 101,
    "Cheri Quinn": 102,
    "Esmeralda Yeskey": 103,
    "Geraldine Atweeke": 104,
    "Breanna Morgan": 105,
    "Esmeralda Baskett": 106,
    "Abel Hook": 107,
    "Jazmin Bratton": 108,
    "Alec Mckendrick": 109,
    "Rickena Zalack": 110,
    "Kassidy Riggle": 111,
    "Kelly Woolery": 112,
    "Jessica Rockwell": 113,
    "Micah Finlay": 114,
    "Gloria Mens": 115,
    "River Ray": 116,
    "Phyliss Mosser": 117,
    "Erin Lafortune": 118,
    "Dominic Patel": 119,
    "Aubrey Edwards": 120,
    "Marje Joghs": 121,
    "Jace Day": 122,
    "Melvyn Cooper": 123,
    "Keaton Stange": 124,
    "Alexandra Coates": 125,
    "Julie Minnie": 126,
    "Dustin Elderson": 127,
    "Micheal Kuznetsov": 128,
    "Kimberly Hutton": 129,
    "Emely Sidower": 130,
    "Kellen Whittier": 131,
    "Sally Ulery": 132,
    "Garret Mcfall": 133,
    "Jerry Hice": 134,
    "Elise Minnie": 135,
    "Claudia Zalack": 136,
    "Jamarion Hook": 137,
    "Ian Echard": 138,
    "Noelle Woollard": 139,
    "Loreto Summy": 140,
    "Eddie Hujsak": 141,
    "Iris Werry": 142,
    "Jameson Zalack": 143,
    "Ana Pershing": 144,
    "Rubye Newton": 145,
    "Cheyenne Elliott": 146,
    "Donny Kanaga": 147,
    "Alberto Meyers": 148,
    "Alfreda Newbern": 149,
    "Brandon Stough": 150,
    "Landon Stroh": 151,
    "Joshua Bode": 152,
    "Cheyanne Gibson": 153,
    "Gabriel Fischer": 154,
    "Percival Costello": 155,
    "Ashlynn Boyer": 156,
    "Fernanda Rathens": 157,
    "Calvin Draudy": 158,
    "Brooklyn Raub": 159,
    "Brian Poley": 160,
    "Rayner Hunt": 161,
    "Rickie Sheets": 162,
    "Brenna Smith": 163,
    "Janine Mull": 164,
    "Byrne Buttersworth": 165,
    "Cynthia Echard": 166,
    "Kassidy Jones": 167,
    "Isaias Fryer": 168,
    "Vivian Prescott": 169,
    "Alison Coldsmith": 170,
    "Ileen Feufer": 171,
    "Tony Baskett": 172,
    "Jeremy Rohtin": 173,
    "Preston Kanaga": 174,
    "Mariah Ashbaugh": 175,
    "Kadence Lombardi": 176,
    "Rosemary Stocker": 177,
    "Marcos Phillips": 178,
    "Godwin Waldron": 179,
    "Marissa Earl": 180,
    "Ashley Cook": 181,
    "Hugo Nash": 182,
    "Orlando Newbern": 183,
    "Irene Pinney": 184,
    "Jocelyn Nash": 185,
    "John Haynes": 186,
    "Pheobe David": 187,
    "Cheyanne Biery": 188,
    "Angelina Wilkerson": 189,
    "Patrick Tennant": 190,
    "Brooklynn Catherina": 191,
    "Elias Alice": 192,
    "Alfreda Gadow": 193,
    "Jaxson Petrov": 194,
    "Elijah Taylor": 195,
    "Julia Werner": 196,
    "Izaiah Hussain": 197,
    "Christobel Fraser": 198,
    "Ward Williams": 199,
    "Jayne Albright": 200,
    "Gina Wolfe": 201,
    "Isaac Wise": 202,
    "Renie Stahl": 203,
    "Jeffrey Elderson": 204,
    "Lindsay Potter": 205,
    "Damon Ali": 206,
    "Eliza Stocker": 207,
    "Madyson Gronko": 208,
    "Joi Prescott": 209,
    "Dayana Stern": 210,
    "Julius Carter": 211,
    "Leroi Buttersworth": 212,
    "Melany Mosser": 213,
    "Jeffrey Baxter": 214,
    "Leonardo Haynes": 215,
    "Jonah Murphy": 216,
    "Bill Mcmullen": 217,
    "Ernesto Mortland": 218,
    "Sheri Nickolson": 219,
    "Hayley Alliman": 220,
    "Gustavo Alekseev": 221,
    "Zelda Fulton": 222,
    "Jaye Poley": 223,
    "Alessandra Sanders": 224,
    "Leonardo Trovato": 225,
    "Zackary Schrader": 226,
    "Luvenia Jardine": 227,
    "Jenna Pavlov": 228,
    "Corbin Williams": 229,
    "Skylar Mikhaylov": 230,
    "Braylon Merryman": 231,
    "Salvador James": 232,
    "Harrison Greenwood": 233,
    "Ethan Parker": 234,
    "Levi Mcintosh": 235,
    "Hailey Randolph": 236,
    "Tony Ellis": 237,
    "Edwin Fisher": 238,
    "Lillian Jyllian": 239,
    "Emma Young": 240,
    "Dolores Keener": 241,
    "Lanny Bynum": 242,
    "Mckenna Wentzel": 243,
    "Theodore Unk": 244,
    "Camryn Thomlinson": 245,
    "Jalen Coates": 246,
    "Katelynn Gronko": 247,
    "Gary Roberts": 248,
    "Kaleigh Matthews": 249,
    "Emiliano Coates": 250,
    "Allegria Yeskey": 251,
    "Nova Reid": 252,
    "Zelda Guess": 253,
    "Martin Losey": 254,
    "Nancy Zadovsky": 255,
    "Hervey Hawker": 256,
    "Donella Lombardi": 257,
    "Bill Wilo": 258,
    "Jemmy Demuth": 259,
    "Amber Cox": 260,
    "Braeden Curry": 261,
    "Laila Evans": 262,
    "Phyllida David": 263,
    "Jakob Richter": 264,
    "Josue Houston": 265,
    "London Foster": 266,
    "Oscar Greenawalt": 267,
    "Jonas Lloyd": 268,
    "Travis Huey": 269,
    "Daniella Williams": 270,
    "Tyler Tedrow": 271,
    "Fernanda Bashline": 272,
    "Gladwyn Garratt": 273,
    "Wendi Mason": 274,
    "Lia Pennington": 275,
    "Tracey Carter": 276,
    "Emery Stafford": 277,
    "Erick Maclagan": 278,
    "Samantha Lafortune": 279,
    "Jonathan Roby": 280,
    "Jeb Bullard": 281,
    "Mason Wile": 282,
    "Braeden Beach": 283,
    "Lily Hook": 284,
    "Israel Joyce": 285,
    "Leo Addison": 286,
    "Hervey Knapenberger": 287,
    "Tania Duncan": 288,
    "Charlotte Gobbler": 289,
    "Melissa Price": 290,
    "Teagan Rathens": 291,
    "Jeremiah Mueller": 292,
    "Luvenia Woodward": 293,
    "Victoria Marshall": 294,
    "Breanne Campbell": 295,
    "Austin Keener": 296,
    "Jayce Leech": 297,
    "Ulric Sulyard": 298,
    "Juliana Nicholas": 299,
    "Tate Jesse": 300,
    "Kristina Brown": 301,
    "Adan Morris": 302,
    "Mike Bickerson": 303,
    "Dayton Wood": 304,
    "Lakeisha Bloise": 305,
    "Nathaniel Blyant": 306,
    "Maurice Weisgarber": 307,
    "Sage Bell": 308,
    "Braydon Nicholas": 309,
    "Christobel Power": 310,
    "Marco Kemerer": 311,
    "Aaliyah Pinney": 312,
    "Brooklynn Kiefer": 313,
    "Alfreda Catleay": 314,
    "Cesar Highlands": 315,
    "Anna Hynes": 316,
    "Francis Kelly": 317,
    "Clark McShain": 318,
    "Art Sholl": 319,
    "Rachel Basinger": 320,
    "Arianna Wheeler": 321,
    "Ivy Greenawalt": 322,
    "Sabrina Eckhardstein": 323,
    "Kevin Begum": 324,
    "Nathaniel Matthews": 325,
    "Brittani Finlay": 326,
    "Amber Burkett": 327,
    "Jakki Fleming": 328,
    "Seymour Milne": 329,
    "Sharalyn Reighner": 330,
    "Donald Whittier": 331,
    "Raelene Stern": 332,
    "Juliana Holdeman": 333,
    "Courtney Dennis": 334,
    "Clover Nehling": 335,
    "Jessica Moon": 336,
    "Alejandro Zadovsky": 337,
    "Everett Sullivan": 338,
    "Courtney Picard": 339,
    "Trinity Dugmore": 340,
    "Shiloh Compton": 341,
    "Dalton Beail": 342,
    "Mario Lester": 343,
    "Asher Bluetenberger": 344,
    "Omar Hawker": 345,
    "Elias Moon": 346,
    "Romayne Oppenheimer": 347,
    "Amir Roby": 348,
    "Braylon Owen": 349,
    "Alicia Edwards": 350,
    "Amanda Shafer": 351,
    "Loreto Lee": 352,
    "Camron Conrad": 353,
    "Lincoln Muggins": 354,
    "Griffin Phillips": 355,
    "Reuben Dawkins": 356,
    "Alfredo Ironmonger": 357,
    "Nikolas Zalack": 358,
    "Issac Baer": 359,
    "Serenity Dennis": 360,
    "Drake Taggart": 361,
    "Denholm Rowley": 362,
    "Paisley Holdeman": 363,
    "Pablo Magor": 364,
    "Anjelica Joghs": 365,
    "Fitz Green": 366,
    "Conner McDonohugh": 367,
    "Hedley Waldron": 368,
    "Richie Rogers": 369,
    "Pablo Smirnov": 370,
    "Joye Marcotte": 371,
    "Bianca Woollard": 372,
    "Kayden Kemerer": 373,
    "Patrick Winton": 374,
    "Driscoll Callison": 375,
    "Deangelo Smail": 376,
    "Maria Enderly": 377,
    "Drake Echard": 378,
    "Liliana Wile": 379,
    "Lyndsey Jones": 380,
    "Drake Taylor": 381,
    "Danica Franks": 382,
    "Pene Marriman": 383,
    "Amos Beach": 384,
    "Willy Sloan": 385,
    "Cristian Hegarty": 386,
    "John Swabey": 387,
    "Khalil Conrad": 388,
    "Jared Edwards": 389,
    "Iris Ramos": 390,
    "Sawyer Laurenzi": 391,
    "Josiah Ratcliff": 392,
    "Astor Northey": 393,
    "Rocco Houston": 394,
    "Maria Stroble": 395,
    "Allegra Moberly": 396,
    "Curtis Mortland": 397,
    "Sandra Webb": 398,
    "Presley Mikhaylov": 399,
    "Maynard Griffiths": 400,
    "Isiah Briggs": 401,
    "Diamond Hill": 402,
    "Nova Bousum": 403,
    "Dane Richardson": 404,
    "Emily Kemble": 405,
    "Ismael Hincken": 406,
    "Alina Reade": 407,
    "Presley Earl": 408,
    "Jaelyn Coates": 409,
    "Carolyn Bluetenberger": 410,
    "Willow Rathen": 411,
    "Amari Green": 412,
    "Pauleen McShain": 413,
    "Wesley Ewing": 414,
    "Peyton Peters": 415,
    "Seth Hynes": 416,
    "Osbert Metzer": 417,
    "Claudius Lester": 418,
    "Fay Murray": 419,
    "Uriel Wentzel": 420,
    "Erick Harrison": 421,
    "Drew Ehret": 422,
    "William Reade": 423,
    "Arthur Unk": 424,
    "Leta Costello": 425,
    "Mia Eckhardstein": 426,
    "Keith Ackerley": 427,
    "Ryleigh Wible": 428,
    "Stephany Brandenburg": 429,
    "Eleanor Thomson": 430,
    "Wendy Treeby": 431,
    "Jaylee Hussain": 432,
    "Travis Green": 433,
    "Jamie Priebe": 434,
    "Nonie Philips": 435,
    "Lynwood Mortland": 436,
    "Sean Lee": 437,
    "Myles Shafer": 438,
    "Caden Kepplinger": 439,
    "Willow Bickerson": 440,
    "Huffie Compton": 441,
    "Presley Semenov": 442,
    "Douglas Lacon": 443,
    "Moises Cypret": 444,
    "Wisdom Garneys": 445,
    "Kerensa Muller": 446,
    "Rodger Whittier": 447,
    "John McDonald": 448,
    "Ellie Houston": 449,
    "Natalie Siegrist": 450,
    "Clover Brinigh": 451,
    "Luvenia Lloyd": 452,
    "Oralie Gronko": 453,
    "Malik Mens": 454,
    "Joanna Blyant": 455,
    "Hadley Teagarden": 456,
    "Kenneth Weinstein": 457,
    "Hervey Ludwig": 458,
    "Sandra Morris": 459,
    "Meghan Dimeling": 460,
    "Autumn Coates": 461,
    "Janine Weisgarber": 462,
    "Jeremiah Hall": 463,
    "Marlowe Weinstein": 464,
    "Alicia Stough": 465,
    "Caryl Burris": 466,
    "Saul Wise": 467,
    "Ronald Robinson": 468,
    "Kat Foster": 469,
    "Allie Osterweis": 470,
    "Madyson Hegarty": 471,
    "Lynn Dimeling": 472,
    "Nyla Gibson": 473,
    "Jillie Quirin": 474,
    "Carl Christman": 475,
    "Cassandra Mccune": 476,
    "Christina Kaur": 477,
    "Emely Patel": 478,
    "Ashlyn Dimeling": 479,
    "Julie Werry": 480,
    "Jorge Langston": 481,
    "Perla Raub": 482,
    "Andrea Pershing": 483,
    "Theodore Pycroft": 484,
    "Kaylee Osterweis": 485,
    "Willow Ewing": 486,
    "Lockie Lafortune": 487,
    "Allen Vader": 488,
    "Samuel Gettemy": 489,
    "Marvin Fryer": 490,
    "Trenton Weinstein": 491,
    "Jacqueline Carmichael": 492,
    "Helen Sandys": 493,
    "Bridget Kiefer": 494,
    "Fernando Echard": 495,
    "Keziah Stough": 496,
    "Trinity Margaret": 497,
    "Rhetta Lafortune": 498,
    "Alyssia Phillips": 499,
    "Imani Mccullough": 500,
    "Sawyer Lowstetter": 501,
    "Makenna Cherry": 502,
    "Lilly Green": 503,
    "Guillermo Beedell": 504,
    "Caroline Howe": 505,
    "Baylee Mitchell": 506,
    "Timothy Ryals": 507,
    "Bethney Kimple": 508,
    "Phyllida Fields": 509,
    "Allie Losey": 510,
    "Hannah Catleay": 511,
    "Josiah Black": 512,
    "Eduardo Jerome": 513,
    "Devin Franks": 514,
    "Alana Gobbles": 515,
    "Ronnette Wolff": 516,
    "Bryan Brinigh": 517,
    "Emely Philips": 518,
    "Paige Prescott": 519,
    "Arn Kaur": 520,
    "Grady Baxter": 521,
    "Jaime Meyers": 522,
    "Meryl Lombardi": 523,
    "Nydia Scott": 524,
    "Renie Ray": 525,
    "Huffie Neely": 526,
    "Bill Greene": 527,
    "Arielle Tireman": 528,
    "Aniya Andreev": 529,
    "Cheyenne Black": 530,
    "Brodie Joghs": 531,
    "Donny Chauvin": 532,
    "Bethany Davis": 533,
    "Dayna Ellis": 534,
    "Alexandra Russell": 535,
    "Pheobe Baker": 536,
    "Kayleigh Staymates": 537,
    "Miranda Shirey": 538,
    "Hervey Quinn": 539,
    "Daisy Buttersworth": 540,
    "Luis Ironmonger": 541,
    "Trent Patel": 542,
    "Ian Andreev": 543,
    "Drake Rosensteel": 544,
    "Porsche Carter": 545,
    "Shayla Fitzgerald": 546
}

app = Flask(__name__)
vits_model_name = "./pth/vits.pth" # TODO: path to the model
def get_text(text, hps):
    text_norm = text_to_sequence(text, hps.data.text_cleaners)
    if hps.data.add_blank:
        text_norm = commons.intersperse(text_norm, 0)
    text_norm = torch.LongTensor(text_norm)
    return text_norm

hps = utils.get_hparams_from_file("./configs/tgstation.json")

net_g = SynthesizerTrn(
    len(symbols),
    hps.data.filter_length // 2 + 1,
    hps.train.segment_size // hps.data.hop_length,
    n_speakers=hps.data.n_speakers,
    **hps.model) #TODO: update for multispeaker
_ = net_g.eval()

_ = utils.load_checkpoint(vits_model_name, net_g, None)

def do_inference_orig(in_txt):
  print(in_txt)
  print(english_cleaners2(in_txt))
  stn_tst = get_text(in_txt, hps)
  with torch.no_grad():
    x_tst = stn_tst.unsqueeze(0)
    x_tst_lengths = torch.LongTensor([stn_tst.size(0)])

    audio = net_g.infer(x_tst, x_tst_lengths, noise_scale=.667, noise_scale_w=0.8, length_scale=1)
    #audio = audio[0][0,0].data.float().numpy()
    attn = audio[0].data.float().numpy()
    print(attn.shape)
    print(attn)
    audio = audio[0].squeeze().data.float().numpy()
    print(len(audio))

  return audio

def do_inference(in_txt,in_vv):
  print(in_txt)
  stn_tst = get_text(in_txt, hps)
  #print(english_cleaners2(in_txt))
  #print(stn_tst)
  len_s = make_var_durp(stn_tst,in_vv)

  with torch.no_grad():
    x_tst = stn_tst.unsqueeze(0)
    x_tst_lengths = torch.LongTensor([stn_tst.size(0)])
    len_s = len_s.unsqueeze(0)

    audio, attn = net_g.infer_ts(x_tst, x_tst_lengths, noise_scale=.667, noise_scale_w=0.8, length_scale=1.0)
    attn = attn.squeeze().data.float().numpy()
    print(attn.shape)
    audio = audio.squeeze().data.float().numpy()
    print(len(audio))

  return audio

def do_inference_gx(in_txt):
  print(in_txt)
  stn_tst = get_text(in_txt, hps)

  with torch.no_grad():
    x_tst = stn_tst.unsqueeze(0)
    x_tst_lengths = torch.LongTensor([stn_tst.size(0)])
    audio = net_gx(x_tst, x_tst_lengths, noise_scale=.667, noise_scale_w=0.8, length_scale=1)
    audio = audio.numpy()

  return audio

def do_inference_clean(in_txt, voice):
  stn_tst = get_text(in_txt, hps)

  with torch.no_grad():
    x_tst = stn_tst.unsqueeze(0)
    x_tst_lengths = torch.LongTensor([stn_tst.size(0)])
    sid = torch.LongTensor([voice])
    audio, attn = net_g.infer_ts(x_tst, x_tst_lengths, sid=sid, noise_scale=.667, noise_scale_w=0.8, length_scale=1.0)
    attn = attn.squeeze().data.float().numpy()
    audio = audio.squeeze().data.float().numpy()

  return audio

request_count = 0

@app.route("/tts")
def text_to_speech():
	global request_count
	request_count += 1

	voice = request.args.get("voice", '')
	if not voice in voices:
		return "Invalid voice", 400
	text = request.json.get("text", '')
	voice_to_use = voices[voice]
	filter_complex = request.args.get("filter", '')
	filter_complex = filter_complex.replace("\"", "")

	result = None
	with io.BytesIO() as wav_bytes:
		audio = do_inference_clean(text, voice_to_use)
		write(wav_bytes, hps.data.sampling_rate, audio)

		ffmpeg_result = None
		if filter_complex != "":
			ffmpeg_result = subprocess.run(["ffmpeg", "-f", "wav", "-i", "pipe:0", "-filter_complex", filter_complex, "-c:a", "libvorbis", "-b:a", "64k", "-f", "ogg", "pipe:1"], input=wav_bytes.getvalue(), capture_output = True)
		else:
			ffmpeg_result = subprocess.run(["ffmpeg", "-f", "wav", "-i", "pipe:0", "-c:a", "libvorbis", "-b:a", "64k", "-f", "ogg", "pipe:1"], input=wav_bytes.getvalue(), capture_output = True)
		print(f"ffmpeg result size: {len(ffmpeg_result.stdout)} stderr = \n{ffmpeg_result.stderr.decode()}")

		result = send_file(io.BytesIO(ffmpeg_result.stdout), as_attachment=True, download_name='{identifier}.ogg', mimetype="audio/ogg")

	return result

@app.route("/tts-voices")
def voices_list():
	return list(voices.keys())

@app.route("/health-check")
def tts_health_check():
	gc.collect()
	if request_count > 2048:
		return f"EXPIRED: {request_count}", 500
	return f"OK: {request_count}", 200

if __name__ == "__main__":
	if os.getenv('TTS_LD_LIBRARY_PATH', "") != "":
		os.putenv('LD_LIBRARY_PATH', os.getenv('TTS_LD_LIBRARY_PATH'))
	from waitress import serve
	serve(app, host="0.0.0.0", port=5002, threads=2, backlog=16, connection_limit=24, channel_timeout=10)
