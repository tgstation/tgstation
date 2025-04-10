import re
import glob
from colormath.color_objects import sRGBColor, HSLColor
from colormath.color_conversions import convert_color

def hex_to_hsl(hex_color):
    alpha_percent = None
    if len(hex_color) == 4 or len(hex_color) == 5: # Shorthand formats expansion
        hex_color = '#' + ''.join([c * 2 for c in hex_color[1:]])
    if len(hex_color) == 9:  # Includes '#' and alpha
        alphahex = hex_color[-2:]
        alpha_percent = (int(alphahex, 16) / 255) * 100
    rgb = sRGBColor.new_from_rgb_hex(hex_color)
    hsl = convert_color(rgb, HSLColor)
    if alpha_percent:
      return f"hsla({hsl.hsl_h:.1f}, {hsl.hsl_s * 100:.1f}%, {hsl.hsl_l * 100:.1f}%, {alpha_percent:.1f})"
    return f"hsl({hsl.hsl_h:.1f}, {hsl.hsl_s * 100:.1f}%, {hsl.hsl_l * 100:.1f}%)"

def replace_hex_with_hsl(file_path):
    with open(file_path, 'r') as file:
        content = file.read()

    hex_pattern = re.compile(r'#([0-9a-fA-F]{3,8})')
    updated_content = hex_pattern.sub(lambda match: hex_to_hsl(match.group(0)), content)

    with open(file_path, 'w') as file:
        file.write(updated_content)

def process_all_scss_files():
    scss_files = glob.glob('*.scss')
    for scss_file in scss_files:
        replace_hex_with_hsl(scss_file)

if __name__ == "__main__":
    process_all_scss_files()
