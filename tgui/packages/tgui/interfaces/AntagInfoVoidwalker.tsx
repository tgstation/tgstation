import { BlockQuote, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

const tipstyle = {
  color: 'white',
};

const noticestyle = {
  color: 'lightblue',
};

export const AntagInfoVoidwalker = (props) => {
  return (
    <Window width={620} height={410}>
      <Window.Content backgroundColor="#0d0d0d">
        <Stack fill>
          <Stack.Item width="46.2%">
            <Section fill>
              <Stack vertical fill>
                <Stack.Item fontSize="25px">You are a Voidwalker.</Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    You are a creature from the void between stars. You were
                    attracted to the radio signals being broadcasted by this
                    station.
                  </BlockQuote>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item textColor="label">
                  <span style={tipstyle}>Survive:&ensp;</span>
                  You have unrivaled freedom. Remain in space and no one can
                  stop you. You can move through windows, so stay near them to
                  always have a way out.
                  <br />
                  <span style={tipstyle}>Hunt:&ensp;</span>
                  Pick unfair fights. Look for inattentive targets and strike at
                  them when they don&apos;t expect you.
                  <br />
                  <span style={tipstyle}>Abduct:&ensp;</span>
                  Your Unsettle ability stuns and drains your targets. Finish
                  them with your void window and use it to pop a window, drag
                  them into space and use an empty hand to kidnap them.
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="53%">
            <Section fill title="Powers">
              <LabeledList>
                <LabeledList.Item label="Space Dive">
                  You can move under the station from space, use this to hunt
                  and get to isolated sections of space.
                </LabeledList.Item>
                <LabeledList.Item label="Void Eater">
                  Your divine appendage; it allows you to incapacitate the loud
                  ones and instantly break windows.
                </LabeledList.Item>
                <LabeledList.Item label="Cosmic Physiology">
                  Your natural camouflage makes you nearly invisible in space,
                  as well as mending any wounds your body might have sustained.
                  You can move through glass freely, but are slowed in gravity.
                </LabeledList.Item>
                <LabeledList.Item label="Unsettle">
                  Target a victim while remaining only partially in their view
                  to stun and weaken them, but also announce them your presence.
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
