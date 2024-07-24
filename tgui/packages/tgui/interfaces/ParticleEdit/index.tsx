/* eslint-disable react/jsx-no-undef */
import { createContext, Dispatch, SetStateAction, useState } from 'react';

import { useBackend } from '../../backend';
import { Button, LabeledList, Section } from '../../components';
import { Window } from '../../layouts';
import { ParticleUIData } from './data';
import {
  EntryCoord,
  EntryFloat,
  EntryGradient,
  EntryIcon,
  EntryIconState,
  EntryTransform,
} from './EntriesBasic';
import {
  EntryGeneratorNumbersList,
  FloatGenerator,
  FloatGeneratorColor,
} from './EntriesGenerators';
import { ShowDesc } from './Tutorial';

type ParticleEditContext = {
  desc: string;
  setDesc: Dispatch<SetStateAction<string>>;
};

export const ParticleContext = createContext({} as ParticleEditContext);

export const ParticleEdit = (props) => {
  const { act, data } = useBackend<ParticleUIData>();
  const [desc, setDesc] = useState('');

  const {
    width,
    height,
    count,
    spawning,
    bound1,
    bound2,
    gravity,
    gradient,
    transform,

    icon,
    icon_state,
    lifespan,
    fade,
    fadein,
    color,
    color_change,
    position,
    velocity,
    scale,
    grow,
    rotation,
    spin,
    friction,

    drift,
  } = data.particle_data;

  return (
    <ParticleContext.Provider value={{ desc, setDesc }}>
      <Window
        title={data.target_name + "'s particles"}
        width={940}
        height={890}
      >
        {desc ? <ShowDesc /> : null}
        <Window.Content scrollable>
          <LabeledList>
            <Section
              title={'Affects entire set'}
              buttons={
                <>
                  <Button
                    icon={'question'}
                    onClick={() => setDesc('generator')}
                    tooltip={'Generator information'}
                  />
                  <Button
                    icon={'sync'}
                    onClick={() => act('new_type')}
                    tooltip={'Change type'}
                  />
                  <Button
                    icon={'x'}
                    color={'red'}
                    onClick={() => act('delete_and_close')}
                    tooltip={'Delete and close UI'}
                  />
                </>
              }
            >
              <EntryFloat name={'Width'} var_name={'width'} float={width} />
              <EntryFloat name={'Height'} var_name={'height'} float={height} />
              <EntryFloat name={'Count'} var_name={'count'} float={count} />
              <EntryFloat
                name={'Spawning'}
                var_name={'spawning'}
                float={spawning}
              />
              <EntryCoord
                name={'Bound corner 1'}
                var_name={'bound1'}
                coord={bound1}
              />
              <EntryCoord
                name={'Bound corner 2'}
                var_name={'bound2'}
                coord={bound2}
              />
              <EntryCoord
                name={'Gravity'}
                var_name={'gravity'}
                coord={gravity}
              />
              <EntryGradient
                name={'Gradient'}
                var_name={'gradient'}
                gradient={gradient}
              />
              <EntryTransform
                name={'Transform'}
                var_name={'transform'}
                transform={transform}
              />
            </Section>
            <Section title={'Evaluated on particle creation'}>
              <EntryIcon name={'Icon'} var_name={'icon'} icon_state={icon} />
              <EntryIconState
                name={'Icon State'}
                var_name={'icon_state'}
                icon_state={icon_state}
              />
              <FloatGenerator
                name={'Lifespan'}
                var_name={'lifespan'}
                float={lifespan}
              />
              <FloatGenerator
                name={'Fade out'}
                var_name={'fade'}
                float={fade}
              />
              <FloatGenerator
                name={'Fade in'}
                var_name={'fadein'}
                float={fadein}
              />
              <FloatGeneratorColor
                name={'Color'}
                var_name={'color'}
                float={color}
              />
              <FloatGenerator
                name={'Color change'}
                var_name={'color_change'}
                float={color_change}
              />
              <EntryGeneratorNumbersList
                name={'Position'}
                var_name={'position'}
                allow_z
                input={position}
              />
              <EntryGeneratorNumbersList
                name={'Velocity'}
                var_name={'velocity'}
                allow_z
                input={velocity}
              />
              <EntryGeneratorNumbersList
                name={'Scale'}
                var_name={'scale'}
                allow_z={false}
                input={scale}
              />
              <EntryGeneratorNumbersList
                name={'Grow'}
                var_name={'grow'}
                allow_z={false}
                input={grow}
              />
              <FloatGenerator
                name={'Rotation'}
                var_name={'rotation'}
                float={rotation}
              />
              <FloatGenerator name={'Spin'} var_name={'spin'} float={spin} />
              <FloatGenerator
                name={'Friction'}
                var_name={'friction'}
                float={friction}
              />
            </Section>
            <Section title={'Evaluated every tick'}>
              <EntryGeneratorNumbersList
                name={'Drift'}
                var_name={'drift'}
                allow_z
                input={drift}
              />
            </Section>
          </LabeledList>
        </Window.Content>
      </Window>
    </ParticleContext.Provider>
  );
};
