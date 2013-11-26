import os
import sys
import inspect
import shutil

def add_to_path(path):
  if path not in sys.path:
    sys.path.insert(0, path)
    os.environ['PATH'] = path + ';' + os.environ['PATH']
    print "Added", path

current_dir = os.path.split(inspect.getfile(inspect.currentframe()))[0]

add_to_path(os.path.abspath(os.path.join(current_dir, "third_party/Imaging-1.1.7/PIL")))
add_to_path(os.path.abspath(os.path.join(current_dir, "third_party/zlib")))

import Image
import _imaging

root_dir = os.path.abspath(os.path.join(current_dir, "../../"))

i = 0

def pngsave(im, file):
  # these can be automatically added to Image.info dict
  # they are not user-added metadata
  reserved = ('interlace', 'gamma', 'dpi', 'transparency', 'aspect')

  # undocumented class
  import PngImagePlugin
  meta = PngImagePlugin.PngInfo()

  # copy metadata into new object
  for k,v in im.info.iteritems():
      if k in reserved: continue
      meta.add_text(k, v, 0)

  # and save
  im.save(file, "PNG", pnginfo=meta)

def process_file(path):
  global i
  name, ext = os.path.splitext(path)
  ext = ext.lower()
  if (ext != ".dmi" and ext != ".png") or os.path.splitext(name)[1] == ".new":
    return

  try:
    im = Image.open(f)
    print f + ": " + im.format, im.size, im.mode
    if im.mode != "RGBA":
      return
    width, height = im.size
    pix = im.load()

    n_transparent = 0

    make_opaque = []

    def check(x, y):
      if pix[x, y][3] == 0:
        make_opaque.append((x, y))

    for x in range(0, width):
      for y in range(0, height):
        if pix[x, y][3] > 0:
          if x > 0:
            check(x - 1, y)
          if x < width - 1:
            check(x + 1, y)
          if y > 0:
            check(x, y - 1)
          if y < height - 1:
            check(x, y + 1)
        else:
          n_transparent += 1

#    print "Making " + str(len(make_opaque)) + " pixels opaque, out of " + str(n_transparent) + " transparent pixels."
    for coords in make_opaque:
      pix[coords] = (0, 0, 0, 1)

    pngsave(im, f)
  except:
    print "Could not process " + f

  #if i > 5:
  #  exit(0)
  #i += 1


### Main:
icons_dir = os.path.join(root_dir, "icons")
raw_icons_dir = os.path.join(root_dir, "icons_raw")

shutil.rmtree(icons_dir, True)
shutil.copytree(raw_icons_dir, icons_dir)

for root, subdirs, files in os.walk(icons_dir):
  for file in files:
    f = os.path.join(root,file)
    process_file(f)
