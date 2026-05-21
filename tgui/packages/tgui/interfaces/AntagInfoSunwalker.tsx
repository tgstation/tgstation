import { BlockQuote, LabeledList, Section, Stack } from 'tgui-core/components';

import { Window } from '../layouts';

const tipstyle = {
  color: 'white',
};

const noticestyle = {
  color: 'lightblue',
};

export const AntagInfoSunwalker = (props) => {
  return (
    <Window width={660} height={300}>
      <Window.Content backgroundColor="#0d0d0d">
        <Stack fill>
          <Stack.Item width="40%">
            <Section fill>
              <Stack vertical fill>
                <Stack.Item fontSize="25px">You are the Sunwalker</Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    You are an ancient voidwalker, having been caught in a
                    supernova. You are altered, and hateful.
                  </BlockQuote>
                  <BlockQuote>
                    There will be no lessons or enlightenment, they wont survive
                    to learn from it.
                  </BlockQuote>
                </Stack.Item>
                <Stack.Divider />
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="60%">
            <Section fill title="Powers">
              <LabeledList>
                <LabeledList.Item label="Space Dive">
                  You can move under the station from space, use this to hunt
                  and get to isolated sections of space.
                </LabeledList.Item>
                <LabeledList.Item label="Burning Slash">
                  Your attacks deal great burn damage and ignite those hit.
                </LabeledList.Item>
                <LabeledList.Item label="Burning Physiology">
                  Your very skin heats the air around you, while the vacuum of
                  space mends any wounds your body might have sustained. You can
                  move through glass freely, but are slowed in gravity.
                </LabeledList.Item>
                <LabeledList.Item label="Stellar Charge">
                  With an exploding burning speed, charge forwards, dealing
                  damage and burning the surroundings.
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
