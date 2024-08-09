# Based off the script found in https://github.com/goonstation/goonstation/pull/14322 by Mister-Moriarty
# Modified by LemonInTheDark to make copy pasting segments easier
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image, ImageOps

# Modify this to create slices that you can stitch together later
array_width = 32
array_height = 32

def create_array(upperleft, upperright, lowerleft, lowerright):
    array = np.linspace(
        np.linspace(upperleft, upperright, array_width),
        np.linspace(lowerleft, lowerright, array_width),
        array_height, dtype = np.uint8)

    return array[:, :, None]

r = create_array(0, 0, 255, 0)
g = create_array(0, 0, 0, 255)
b = create_array(255, 0, 0, 0)
# Needs 1 so byond doesn't yeet it
a = create_array(1, 255, 1, 1)

image = np.concatenate([r, g, b, a], axis=2)

plt.imshow(image)
plt.axis("off")
# we're doing a bunch of bullshit here to try to get a clean drop in image we can stitch together
# it sometimes has alpha artifacting issues depending on how it's copied, I'm sorry IDK how else to deal w it
fig = plt.figure(frameon=False)
fig.set_size_inches(array_width / 100, array_height / 100)
ax = plt.Axes(fig, [0., 0., 1., 1.])
ax.set_axis_off()
fig.add_axes(ax)
ax.imshow(image, aspect='auto')
fig.savefig("output.png", transparent = True)
