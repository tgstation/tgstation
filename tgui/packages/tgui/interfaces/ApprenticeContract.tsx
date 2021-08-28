import { BlockQuote, Button, Section, Stack } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';
import { multiline } from 'common/string';
import { useBackend } from '../backend';

export const ApprenticeContract = (props, context) => {
  return (
    <Window
      width={620}
      height={516}
      theme="wizard">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <ApprenticeSelection
              schoolTitle="destruction"
              assetName="destruction.png"
              blurb={multiline`
                Your apprentice is skilled in offensive magic.
                They know Magic Missile and Fireball.
              `} />
            <ApprenticeSelection
              schoolTitle="bluespace"
              assetName="bluespace.png"
              blurb={multiline`
              Your apprentice is able to defy physics, melting through
              solid objects and travelling great distances in the
              blink of an eye. They know Teleport and Ethereal Jaunt.
              `} />
            <ApprenticeSelection
              schoolTitle="healing"
              assetName="healing.png"
              blurb={multiline`
              Your apprentice is training to cast spells that will
              aid your survival. They know Forcewall and Charge and
              come with a Staff of Healing.
              `} />
            <ApprenticeSelection
              schoolTitle="robeless"
              assetName="robeless.png"
              blurb={multiline`
              Your apprentice is training to cast spells without
              their robes. They know Knock and Mindswap.
              `} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ApprenticeSelection = (props, context) => {
  const { act } = useBackend(context);
  const {
    schoolTitle,
    assetName,
    blurb,
  } = props;
  return (
    <Section>
      <Stack align="middle" fill>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <img
                src={resolveAsset(assetName)} />
            </Stack.Item>
            <Stack.Item>
              <Button
                textAlign="center"
                fluid
                onClick={() => act('buy', {
                  school: schoolTitle,
                })}>
                Select
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow>
          <BlockQuote height="100%" fontSize="18px">
            {blurb}
          </BlockQuote>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
