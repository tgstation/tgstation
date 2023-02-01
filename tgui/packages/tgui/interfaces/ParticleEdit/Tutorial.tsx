import { useLocalState } from '../../backend';
import { Box, Button, LabeledList, Section, Modal, Stack } from '../../components';
import { resolveAsset } from '../../assets';

export const ShowDesc = (props, context) => {
  const [desc, setdesc] = useLocalState(context, 'desc', '');
  return (
    <Modal
      width={'60em'}
      align={VarExplanation[desc].dataunit ? 'center' : 'left'}>
      <Section
        title={'Var Details'}
        buttons={
          VarExplanation[desc].dataunit ? (
            <Button content="Dismiss" onClick={() => setdesc('')} />
          ) : (
            <>
              <Button
                content="Motion basics"
                selected={desc === 'motion'}
                onClick={() => setdesc('motion')}
              />
              <Button
                content="Rand types"
                selected={desc === 'randtypes'}
                onClick={() => setdesc('randtypes')}
              />
              <Button
                content="Generator types"
                selected={desc === 'gentypes'}
                onClick={() => setdesc('gentypes')}
              />
              <Button
                icon="x"
                tooltip={'Dismiss'}
                color={'red'}
                onClick={() => setdesc('')}
              />
            </>
          )
        }>
        {VarExplanation[desc].dataunit ? (
          <LabeledList>
            <LabeledList.Item label={'Data unit'}>
              {VarExplanation[desc].dataunit}
            </LabeledList.Item>
            <LabeledList.Item label={'Description'}>
              {VarExplanation[desc].desc}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          VarExplanation[desc].desc
        )}
      </Section>
    </Modal>
  );
};

/** Dictionary for all the tutorial question marks + generators guide */
const VarExplanation = {
  'width': {
    dataunit: 'Pixels',
    desc: 'This is the width of the particle "image" ie if you go out of this size the particles vanish, but if they go back into the "image" they reappear.',
  },
  'height': {
    dataunit: 'Pixels',
    desc: 'This is the height of the particle "image" ie if you go out of this size the particles vanish, but if they go back into the "image" they reappear.',
  },
  'count': {
    dataunit: 'Integer',
    desc: 'This is the maximum number of possibly active particles for this spawner. If this amount is spawned it wont spawn any more until the lifespan of the other particles ends.',
  },
  'spawning': {
    dataunit: 'Particles spawned per tick',
    desc: 'Particle spawn rate in particles per tick. Does not need to be an integer as this is the spawn RATE not spawn COUNT.',
  },
  'bound1': {
    dataunit: 'Coordinate',
    desc: 'Minimum x/y/z particle area. If a particle goes below any of these given x/y/z values it gets deleted. Can be set to a single number (bound1 = -100) but this is treated as (bound1 = list(-100,-100,-100)',
  },
  'bound2': {
    dataunit: 'Coordinate',
    desc: 'Maximum x/y/z particle area. If a particle goes above any of these given x/y/z values it gets deleted. Can be set to a single number (bound2 = 100) but this is treated as (bound2 = list(100,100,100)',
  },
  'gravity': {
    dataunit: 'Vector',
    desc: 'Constant acceleration that is applied to every particle every tick.',
  },
  'gradient': {
    dataunit: 'Byond Color gradient',
    desc: 'Color gradients are an advanced way to manipulate colors. list(0, "#f00",0.1, 0.3, "#ff0", 0.4, 0.6, "#008000", 0.7, 0.9, "#00f", "loop") for example is 10% each red, yellow, green, blue, with a 20% transition zone between each, then when it does over it loops back around. When this is active, color will need to be set to a number to use it. Ie in the previous case color = 0 means the color will be "#f00". Color is then changed by the color_change var, which means that color_change = 0.1 means the next tick color will be 0.2 and the color will be blended between 2/3 "#f00" and 1/3 "#ff0". The "space" key changes what color spaces byond should treat the colors as being in as (https://secure.byond.com/docs/ref/index.html#/{{appendix}}/color-space). This affects how the colors are blended together when switching from one color to the other.',
  },
  'transform': {
    dataunit: 'Matrix (list form)',
    desc: 'One of three byond matrix types (See reference).\n SIMPLE MATRIX:\n Standard matrix type that is used in most byond code: list(a, b, c, d, e, f). \n COMPLEX MATRIX: Like the simple matrix, but instead of just changing x and y also changes the z value. The last row is optional, and is added to the x/y/z values respectively if present: list(xx,xy,xz, yx,yy,yz, zx,zy,zz) OR list(xx,xy,xz, yx,yy,yz, zx,zy,zz, cx,cy,cz) \nPROJECTION MATRIX:\n A special particle-only matrix. Like the complex matrix, manipulates the x, y, and z, but also manipulates a fourth axis called "w", which influences how much changes in z changes in z decrease it\'s size by. Ie a lower w will make it seem like it\'s farther away from the camera faster :list(xx,xy,xz,xw, yx,yy,yz,yw, zx,zy,zz,zw, wx,wy,wz,ww)',
  },

  'icon': {
    dataunit: 'Icon file OR list(icon_file = weight)',
    desc: "Icon file to use for particles spawned. If not specified will spawn a 1x1 white dot. If an icon file reference, will apply that icon file every tick. If instead a list it will use the key as icons to choose from with their assigned values as weight. Example: list('rain.dmi' = 1, 'snow.dmi' = 2) will have 33% chance to use rain.dmi and 66% chance to use snow.dmi.",
  },
  'icon_state': {
    dataunit: 'String OR list(icon_state = weight)',
    desc: 'icon state to use for particles spawned. If instead a list it will use the key as icons to choose from with their assigned values as weight. Example: list("rain" = 1, "snow" = 2) will have 33% chance to use "rain" and 66% chance to use "snow".',
  },
  'lifespan': {
    dataunit: 'Ticks',
    desc: 'Applied to particles when it spawns; determines how many ticks before this particle starts despawning. Can use a generator.',
  },
  'fade': {
    dataunit: 'Ticks',
    desc: 'After lifespan has elapsed, how long a particle spends fading out in ticks. Can use a generator.',
  },
  'fadein': {
    dataunit: 'Ticks',
    desc: 'How long a particle spends fading in in when it is spawned in ticks. When this ends, starts ticking down lifespan. Can use a generator.',
  },
  'color': {
    dataunit: 'Number OR color string',
    desc: 'Usually a standard color string. However, when using a gradient this value can be a number. Can use a generator. See gradient for details.',
  },
  'color_change': {
    dataunit: 'Float',
    desc: 'If a gradient is defined, change the color value by this value every tick. Can use a generator. See gradient for details.',
  },
  'position': {
    dataunit: 'Coordinate',
    desc: 'X,Y,Z coordinates for where this particle spawns. Can use a generator.',
  },
  'velocity': {
    dataunit: 'Coordinate',
    desc: 'When spawned, spawns with this velocity. Can use a generator.',
  },
  'scale': {
    dataunit: 'Scale',
    desc: 'Scale that is applied to the icon when it spawns. list(x_scale, y_scale). Defaults to (1,1). Can use a generator.',
  },
  'grow': {
    dataunit: 'Scale',
    desc: 'How much the scale applied to the particle changes every tick. Can use a generator.',
  },
  'rotation': {
    dataunit: 'Number',
    desc: 'If icon is specified, this is by how many degrees this icon will be rotated clockwise when it spawns. Can use a generator.',
  },
  'spin': {
    dataunit: 'Number',
    desc: 'How much rotation is changed by every tick. Can use a generator.',
  },
  'friction': {
    dataunit: 'Float',
    desc: '% of velocity that is removed every tick. Value from 0 to 1. Can use a generator.',
  },

  'drift': {
    dataunit: 'Vector',
    desc: 'How much acceleration is added every tick to the particle. This var is re-evalutated every tick. Can use a generator.',
  },

  'motion': {
    desc: (
      <>
        The first thing to understand before we dive into how generators is
        motion. These basics assume you fell asleep during physics class so you
        can skip this if you didnt.
        <br />
        <br />
        First things off there are 3 variable you care about: POSITION, VELOCITY
        and ACCELERATION. Position is where you are in a 3D space, velocity is
        how fast you are moving in x/y/z directions, and acceleration is how
        much velocity is being changed by. Shortly summarized this is
        <br />
        <br />
        <b>position = average velocity * time</b> <br />
        <br /> <b>velocity = current velocity + acceleration * time</b>
        <br />
        <br /> So your overall position after time is
        <br />
        <br />
        <b>
          location = initial location + (initial velocity * time) + (0.5 *
          acceleration * time<sup>2</sup>)
        </b>
        <br />
        <br />
        So when talking about particles this amounts to: <br />
        <br />
        <b>
          pixel_location = position + (velocity * ticks_elapsed) +(0.5 *
          (average_drift_during_ticks + gravity - (velocity * friction
          <sup>ticks_elapsed</sup>)) * ticks_elapsed<sup>2</sup>)
        </b>
        <br />
        <br />
        Now while this is all nice and dandy how does it look like in practice?
        If you look at only one direction then movement will look like this:
        <br />
        <Box as="img" src={resolveAsset('motion')} />
        <Box />
      </>
    ),
  },

  'randtypes': {
    desc: (
      <Stack vertical fill>
        <Stack.Item>
          If you didnt sleep during statistics class you can skip this part.
          Basically the type of randomness you choose determines the probability
          curve (if you take a million samples how will they look on a chart) of
          the values to pick. The probability graphs for the byond rands are:
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Stack vertical fill>
                <Stack.Item bold>UNIFORM RAND(default):</Stack.Item>
                <Stack.Item>
                  <Box width={25} as="img" src={resolveAsset('uniform')} />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical fill>
                <Stack.Item bold>NORMAL RAND:</Stack.Item>
                <Stack.Item>
                  <Box as="img" width={28.2} src={resolveAsset('normal')} />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Stack vertical fill>
                <Stack.Item bold>LINEAR RAND:</Stack.Item>
                <Stack.Item>
                  <Box width={25} as="img" src={resolveAsset('linear')} />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical fill>
                <Stack.Item bold>SQUARE RAND:</Stack.Item>
                <Stack.Item>
                  <Box as="img" width={25} src={resolveAsset('square_rand')} />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    ),
  },

  'gentypes': {
    desc: (
      <Stack vertical fill>
        <Stack.Item height={2}>
          <Stack>
            <Stack.Item width={10} bold>
              Type
            </Stack.Item>
            <Stack.Item width={11} bold>
              Result
            </Stack.Item>
            <Stack.Item width={20} bold>
              Description
            </Stack.Item>
            <Stack.Item bold width={15}>
              Visual help
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item height={5}>
          <Stack>
            <Stack.Item width={10}>num</Stack.Item>
            <Stack.Item width={11}>num</Stack.Item>
            <Stack.Item width={20}>A random number between A and B.</Stack.Item>
            <Stack.Item>
              <Box
                as="img"
                src={resolveAsset('num')}
                width={15}
                style={{
                  'transform': 'translateY(-20%)',
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item height={5.5}>
          <Stack>
            <Stack.Item width={10}>vector</Stack.Item>
            <Stack.Item width={11}>vector</Stack.Item>
            <Stack.Item width={20}>
              A random vector on a line between A and B.
            </Stack.Item>
            <Stack.Item>
              <Box
                as="img"
                src={resolveAsset('vector')}
                width={15}
                style={{
                  'transform': 'translateY(-35%)',
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item height={7}>
          <Stack>
            <Stack.Item width={10}>box</Stack.Item>
            <Stack.Item width={11}>vector</Stack.Item>
            <Stack.Item width={20}>
              A random vector within a box whose corners are at A and B.
            </Stack.Item>
            <Stack.Item>
              <Box
                as="img"
                src={resolveAsset('box')}
                width={15}
                style={{
                  'transform': 'translateY(-10%)',
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item height={7}>
          <Stack>
            <Stack.Item width={10}>color</Stack.Item>
            <Stack.Item width={11}>color (string) or color matrix</Stack.Item>
            <Stack.Item width={20}>
              Result type depends on whether A or B are matrices or not. The
              result is interpolated between A and B; components are not
              randomized separately.
            </Stack.Item>
            <Stack.Item>
              <Box width={15} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item height={6}>
          <Stack>
            <Stack.Item width={10}>circle</Stack.Item>
            <Stack.Item width={11}>vector</Stack.Item>
            <Stack.Item width={20}>
              A random XY-only vector in a ring between radius A and B, centered
              at 0,0.
            </Stack.Item>
            <Stack.Item>
              <Box
                as="img"
                src={resolveAsset('circle')}
                width={15}
                style={{
                  'transform': 'translateY(-30%)',
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item height={6}>
          <Stack>
            <Stack.Item width={10}>sphere</Stack.Item>
            <Stack.Item width={11}>vector</Stack.Item>
            <Stack.Item width={20}>
              A random vector in a spherical shell between radius A and B,
              centered at 0,0,0.
            </Stack.Item>
            <Stack.Item>
              <Box
                as="img"
                src={resolveAsset('sphere')}
                width={15}
                style={{
                  'transform': 'translateY(15%)',
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item height={6}>
          <Stack>
            <Stack.Item width={10}>square</Stack.Item>
            <Stack.Item width={11}>vector</Stack.Item>
            <Stack.Item width={20}>
              A random XY-only vector between squares of sizes A and B. (The
              length of the square is between A*2 and B*2, centered at 0,0.)
            </Stack.Item>
            <Stack.Item>
              <Box width={15} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item height={10}>
          <Stack>
            <Stack.Item width={10}>cube</Stack.Item>
            <Stack.Item width={11}>vector</Stack.Item>
            <Stack.Item width={20}>
              A random vector between cubes of sizes A and B. (The length of the
              cube is between A*2 and B*2, centered at 0,0,0.)
            </Stack.Item>
            <Stack.Item>
              <Box
                as="img"
                src={resolveAsset('cube')}
                width={15}
                style={{
                  'transform': 'translateY(-10%)',
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    ),
  },

  'generator': {
    desc: <Box>Please select a topic</Box>,
  },
};
