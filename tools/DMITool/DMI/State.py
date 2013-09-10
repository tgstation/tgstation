import os
from byond import directions
from PIL import Image
class State:
    name = ''
    hotspot = ''
    frames = 0
    dirs = 1
    movement = 0
    loop = 0
    rewind = 0
    delay = []
    icons = []
    
    def __init__(self, nm):
        self.name = nm
        self.hotspot = ''
        self.frames = 0
        self.dirs = 1
        self.movement = 0
        self.loop = 0
        self.rewind = 0
        self.delay = []
        self.icons = []
        
    def genManifest(self):
        '''
state = "void"
        dirs = 4
        frames = 4
        delay = 2,2,2,2
        '''
        o = '\r\nstate = "{0}"'.format(self.name)
        o += self.genManifestLine('hotspot',self.hotspot,'')
        o += self.genManifestLine('frames',self.frames,-1)
        o += self.genManifestLine('dirs',self.dirs,-1)
        o += self.genManifestLine('movement',self.movement,0)
        o += self.genManifestLine('loop',self.loop,0)
        o += self.genManifestLine('rewind',self.rewind,0)
        o += self.genManifestLine('delay',self.delay,[])
        
        return o
    
    def genDMIH(self):
        o = '\r\nstate "%s" {' % self.name
        o += self.genDMIHLine('hotspot',self.hotspot,'')
        o += self.genDMIHLine('frames',self.frames,-1)
        tdirs = 'ONE'
        if self.dirs == 4:
            tdirs='CARDINAL'
        elif self.dirs == 8:
            tdirs='ALL'
        o += self.genDMIHLine('dirs',tdirs,'')
        o += self.genDMIHLine('movement',self.movement,0)
        o += self.genDMIHLine('loop',self.loop,0)
        o += self.genDMIHLine('rewind',self.rewind,0)
        o += self.genDMIHLine('delay',self.delay,[])
        
        o += '\n\timport pngs {' 
        for vdir in range(self.dirs):
            dir = directions.IMAGE_INDICES[vdir]
            o += '\n\t\tdirection "%s" {' %  directions.getNameFromDir(dir)
            for f in range(self.frames):
                o += '\n\t\t\t"%s"' % self.getFrame(dir, f)
            o += '\n\t\t}'
        o += '\n\t}'
        o += "\n}"
        return o
        
    def genDMIHLine(self,name,value,default):
        if value != default:
            if type(value) is list:
                value = ','.join(value)
            return '\n\t{0} = {1}'.format(name,value)
        return ''
        
    def genManifestLine(self,name,value,default):
        if value != default:
            if type(value) is list:
                value = ','.join(value)
            return '\r\n        {0} = {1}'.format(name,value)
        return ''
    
    def ToString(self):
        o = '%s: %d frames, ' % (self.name, self.frames)
        o += '%d directions' % self.dirs
        o += ' icons: ' + repr(self.icons)
        return o
    
    def numIcons(self):
        return self.frames * self.dirs
    
    def getFrame(self,direction,frame):
        dir = 0
        if self.dirs == 4 or self.dirs == 8:
            dir = directions.IMAGE_INDICES.index(direction)
            
        frame=dir+(frame*self.dirs)
        return self.icons[frame]
    
    def postProcess(self):
        filetype = "png"
        if(self.frames > 0):
            filetype = "gif"
        if(self.frames == 1 and self.dirs == 1):
            oldfilename = self.icons[0]
            self.icons[0] = self.icons[0].split('[')[0] + '.png'
            if os.path.isfile(self.icons[0]):
                os.remove(self.icons[0])
            os.rename(oldfilename, self.icons[0])
            return
        # print('  * POSTPROCESSING %s...'%self.name)
        frames = [None] * self.dirs
        frameFiles = [None] * self.dirs
        for dir in range(self.dirs):
            frames[dir] = []
            frameFiles[dir] = []
        i = 0
        for frame in range(self.frames):
            for dir in range(self.dirs):
                frames[dir] += [Image.open(self.icons[i])]
                frameFiles[dir] += [self.icons[i]]
                i += 1
        for dir in range(self.dirs):
            if(len(frames[dir]) <= 1):
                continue
            filename = '%s-ANIM[%d].apng' % (self.icons[0].split('[')[0], dir)
            if(len(self.delay) == 0):
                self.delay = [1] * self.frames
            if len(frames[dir]) != len(self.delay):
                print('Delay count doesn\'t match frame count (%d != %d)' % (len(frames[dir]), len(self.delay)))
            else:
                if os.path.isfile(filename):
                    os.remove(filename)
                # print('    >>> Consolidating %d frames into %s...' % (len(frameFiles[dir]),filename))
                fixedDelays = []
                fi = 0
                for delay in self.delay:
                    d = float(delay) / 10
                    fi += 1
                    # print ('Frame %d delay = %s' % (fi,d))
                    fixedDelays += [d]  # Required in order to work properly.
                # writeGif(filename, frames[dir], duration=fixedDelays, dither=0)
                # apng = APNG()
                # for fi in range(len(frames[dir])):
                #     apng.addFrame(frameFiles[dir][fi],fixedDelays[fi]*1000, 1000)
                # apng.save(filename)
                # for nukeMe in frameFiles[dir]:
                #     if os.path.isfile(nukeMe):
                #         os.remove(nukeMe)
