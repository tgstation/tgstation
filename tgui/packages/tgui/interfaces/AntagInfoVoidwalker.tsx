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
    <Window width={620} height={380}>
      <Window.Content backgroundColor="#0d0d0d">
        <Stack fill>
          <Stack.Item width="46.2%">
            <Section fill>
              <Stack vertical fill>
                <Stack.Item fontSize="25px">You are a Voidwalker.</Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    You are a creature from the void between stars. You
                    were attracted to the radio signals being broadcasted by
                    this station.
                    <span style={noticestyle}>&ensp;light eater</span> to dim
                    the station, making hunting easier.
                  </BlockQuote>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item textColor="label">
                  <span style={tipstyle}>Survive:&ensp;</span>
                  You have unrivaled freedom. Remain in space and no one can
                  stop you. You can move through windows, so stay near them
                  to always have a way out.
                  <br />
                  <span style={tipstyle}>Hunt:&ensp;</span>
                  Pick unfair fights. Look for inattentive targets and strike
                  at them when they don&apos;t expect you.
                  <br />
                  <span style={tipstyle}>Abduct:&ensp;</span>
                  Your Unsettle ability stuns and drains your targets. Finish
                  them with your stamine fist, smash a window with your touch
                  and drag them into space to send them into the void.
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="53%">
            <Section fill title="Powers">
              <LabeledList>
                <LabeledList.Item label="Glassy Movement">
                  You can pass through windows and grills as if they&apos;re not
                  even there, as long as they&apos;re not electrified (ouch).
                </LabeledList.Item>
                <LabeledList.Item label="Void Fisticuffs">
                  Beat the energy out of them, and drag them into space to curse
                  them. Also you can explode windows with your hands.
                </LabeledList.Item>
                <LabeledList.Item label="Zero-Gravity Adaptation">
                  You are adapted to zero-gravity, giving you free movement
                  in space, but a slowdown in gravity.
                </LabeledList.Item>
                <LabeledList.Item label="Cosmic Physiology">
                  Your natural camouflage makes you nearly invisible in space,
                  as well as mending any wounds your body might have sustained.
                </LabeledList.Item>
                <LabeledList.Item label="Unsettle">
                  Target a stationeer while remaining only partially in their view
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
