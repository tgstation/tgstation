'''
Handy for doing palette-swaps.

mkmetroid --analyze metroid
mkmetroid --generate-tpl standard.metroid metroid
mkmetroid --make standard.metroid
'''
import os, argparse, math, numpy

from DMI import DMI
from PIL import Image, ImageColor
import colorsys
    
def main():
    opt = argparse.ArgumentParser()
    opt.add_argument('-A', '--analyze', dest='analyze', help='Examine a file named [arg].template.dmi and create a differential pallette')
    opt.add_argument('-p', '--primary-colors', dest='colors', action='append')
    opt.add_argument('-s', '--swap', nargs=2, dest='swap', action=SwapAction)
    opt.add_argument('-C', '--change-palette', nargs=2, dest='change_palette', help='Swap palette of a file named [arg].template.dmi, given a list of --swaps.')
    
    p = opt.parse_args()
    
    if p.analyze:
        analyze(p)
    
    if p.change_palette:
        change_palette(p)

def rgb_clamp(i):
    if i<0:
        return 0
    if i>255:
        return 255
    return i        
class SwapAction(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        orig = ImageColor.getrgb(values[0])
        new = None
        if values[1]!='nil':
            new = ImageColor.getrgb(values[1])
        pcolors = [(orig,new)]
        if not getattr(namespace,self.dest):
            setattr(namespace,self.dest,[])
        ogod = getattr(namespace, self.dest)
        ogod += pcolors
        print('%r -> %r' % (values, pcolors))

def rgbtohsv(color):
    cout = colorsys.rgb_to_hsv(color[0]/255., color[1]/255., color[2]/255.)
    return (int(cout[0]*255),int(cout[1]*255),int(cout[2]*255))

def hsvtorgb(color):
    cout = colorsys.hsv_to_rgb(color[0]/255., color[1]/255., color[2]/255.)
    if len(color)==4:
        return (int(cout[0]*255),int(cout[1]*255),int(cout[2]*255),color[3])
    else:
        return (int(cout[0]*255),int(cout[1]*255),int(cout[2]*255))

def mkdelta(a,b):
    return ((a[0] - b[0]), (a[1] - b[1]), (a[2] - b[2]))

def swap_palettes(im,oldcolors,newcolors):
    data = numpy.array(im)
    r,g,b,a = data.T
    for i in range(len(oldcolors)):
        old=oldcolors[i]
        new=newcolors[i]
        if new != None:
            #selected = (r==old[0]) & (g==old[1]) & (b==old[2]) & (a==old[3])
            #data[..., :-1][selected]=new
            data[(data == old).all(axis = -1)] = new
            oldhex = '#%0.2x%0.2x%0.2x' % old[:3]
            newhex = '#%0.2x%0.2x%0.2x' % new[:3]
            print('{0} -> {1}'.format(oldhex,newhex))
    return Image.fromarray(data)

def change_palette(p):
    dmi_template = p.change_palette[0] + '.template.dmi'
    dmi = DMI(dmi_template)
    dmidir = 'tmp/' + os.path.basename(p.change_palette[0])
    if not os.path.exists(dmidir):
        os.makedirs(dmidir)
        
    dmi.extractTo(dmidir)
    with open(p.change_palette[0] + ' report.htm', 'w') as h:
        h.write('''
<html>
<head>
    <title>Palette Swap Report for {0}</title>
</head>
<body>
    <h1>Palette Swap Report for {0}</h1>
    <img src="{0}" />
    <pre>{1}</pre>
        '''.format(dmi_template,dmi.statelist))
        for statename in sorted(dmi.states):
            state = dmi.states[statename]
            h.write('<h2>{0}</h2>'.format(statename))
            for iconf in state.icons:
                iconf = iconf.replace('\\', '/')
                icon = Image.open(iconf)
                cr = icon.getcolors()
                h.write('<table><tr><td rowspan="{0}"><img src="{1}"></td>'.format(len(cr), iconf))
                first = True
                oldcolors=[]
                newcolors=[]
                # First, analysis
                for ct in cr:
                    (count, color) = ct
                    if color[3] == 0:
                        continue
                    if first:
                        first = False
                    else:
                        h.write('<tr>')
                    #print(repr(color))
                    chex = '#%0.2x%0.2x%0.2x' % color[:3]
                    h.write('<td style="background:{0};color:{0}">...</td>'.format(chex))
                    alpha = ''
                    if color[3] < 255:
                        alpha = ' (A: {0})'.format(color[3])
                    h.write('<td>{0}{1} &times; {2}</td>'.format(chex, alpha, count))
                    found = None
                    foundNew = None
                    foundDelta=None
                    closest = None
                    print(repr(p.swap))
                    for pcolor, new in p.swap:
                        hsv_old = rgbtohsv(pcolor)
                        hsv_current = rgbtohsv(color)
                        delta = mkdelta(hsv_current,hsv_old)
                        #delta = ((pcolor[0] - color[0]), (pcolor[1] - color[1]), (pcolor[2] - color[2]))
                        dist = math.sqrt(delta[0] ** 2 + delta[1] ** 2 + delta[2] ** 2)
                        if (closest is None or dist < closest) and math.fabs(delta[0]*255) < 25:
                            closest = dist
                            found = pcolor
                            foundDelta = delta
                            if new:
                                hsv_new = rgbtohsv(new)
                                #hsv_old = rgbtohsv(pcolor)
                                #hsv_current = rgbtohsv(color)
                                #delta = mkdelta(hsv_current,hsv_old)
                                hsv_new=(rgb_clamp(hsv_new[0] + delta[0]), rgb_clamp(hsv_new[1] + delta[1]), rgb_clamp(hsv_new[2] + delta[2]), color[3])
                                foundNew = hsvtorgb(hsv_new)
                            else:
                                foundNew = None
                    if found:
                        oldcolors += [color]
                        newcolors += [foundNew]
                        if foundNew:
                            hex = '#%0.2x%0.2x%0.2x' % foundNew[:3]
                            h.write('<td style="background:{0};color:{0}">...</td>'.format(hex))
                            alpha = ''
                            if foundNew[3] < 255:
                                alpha = ' (A: {0})'.format(foundNew[3])
                            h.write('<td>{0}{1} - &Delta;{2}</td>'.format(hex, alpha,foundDelta))
                        else:
                            hex = '#%0.2x%0.2x%0.2x' % found[:3]
                            h.write('<td style="background:{0};color:{0}">...</td>'.format(hex))
                            h.write('<td>(Ignore) - &Delta;{0}</td>'.format(foundDelta))
                    else:
                        h.write('<td colspan="2">N/A</td>')
                    h.write('</tr>')
                h.write('</table><hr />')
                
                # write us a new image.
                icon = swap_palettes(icon,oldcolors,newcolors)
                icon.save(iconf,'PNG')
        h.write('</body></html>')
        dmi.save(p.change_palette[1]+'.dmi')

def analyze(p):
    pcolors = []
    if p.colors is not None:
        for color in p.colors:
            pcolor = ImageColor.getrgb(color)
            pcolors += [pcolor]
            print('>>> Added %x%x%x' % pcolor)
    dmi_template = p.analyze + '.template.dmi'
    dmi = DMI(dmi_template)
    dmidir = 'tmp/' + os.path.basename(p.analyze)
    if not os.path.exists(dmidir):
        os.makedirs(dmidir)
        
    dmi.extractTo(dmidir)
    with open(p.analyze + ' report.htm', 'w') as h:
        h.write('''
<html>
<head>
    <title>Color Report for {0}</title>
</head>
<body>
    <h1>Color Report for {0}</h1>
    <img src="{0}" />
    <pre>{1}</pre>
        '''.format(dmi_template,dmi.statelist))
        for statename in sorted(dmi.states):
            state = dmi.states[statename]
            h.write('<h2>{0}</h2>'.format(statename))
            for iconf in state.icons:
                iconf = iconf.replace('\\', '/')
                icon = Image.open(iconf)
                print(icon.mode)
                #icon=icon.convert()
                newicon = Image.new("RGBA", icon.size)
                newicon.paste(icon) # 3 is the alpha channel
                icon=newicon
                print(icon.mode)
                cr = icon.getcolors()
                h.write('<table><tr><td rowspan="{0}"><img src="{1}"></td>'.format(len(cr), iconf))
                first = True
                for ct in cr:
                    (count, color) = ct
                    if color[3] == 0:
                        continue
                    if first:
                        first = False
                    else:
                        h.write('<tr>')
                    #print(repr(color))
                    chex = '#%0.2x%0.2x%0.2x' % color[:3]
                    h.write('<td style="background:{0};color:{0}">...</td>'.format(chex))
                    alpha = ''
                    if color[3] < 255:
                        alpha = ' (A: {0})'.format(color[3])
                    h.write('<td>{0}{1} &times; {2}</td>'.format(chex, alpha, count))
                    found = None
                    closest = None
                    for pcolor in pcolors:
                        dist = math.sqrt((pcolor[0] - color[0]) ** 2 + (pcolor[1] - color[1]) ** 2 + (pcolor[2] - color[2]) ** 2)
                        if closest is None or dist < closest:
                            closest = dist
                            found = pcolor
                    if found:
                        hex = '#%0.2x%0.2x%0.2x' % found
                        h.write('<td style="background:{0};color:{0}">...</td>'.format(hex))
                        h.write('<td>{0} (dist:{1})</td>'.format(hex, closest))
                    else:
                        h.write('<td colspan="2">N/A</td>')
                    h.write('</tr>')
                h.write('</table><hr />')
        h.write('</body></html>')

if __name__ == '__main__':
    main()
