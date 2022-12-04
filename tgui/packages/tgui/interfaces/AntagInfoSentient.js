import { useBackend } from '../backend';
import { BlockQuote, Section, Stack } from '../components';
import { Window } from '../layouts';

export const AntagInfoSentient = (props, context) => {
  const { act, data } = useBackend(context);
  const { enslaved_to, holographic, p_them, p_their } = data;
  return (
    <Window width={400} height={400} theme="neutral">
      <Window.Content>
        <Section fill>
          <Stack vertical fill textAlign="center">
            <Stack.Item fontSize="20px">
              You are a sentient creature!
            </Stack.Item>
            <Stack.Item>
              <BlockQuote>
                All at once it makes sense: you know what you are and who you
                are! Self awareness is yours!
                {!!enslaved_to &&
                  ' You are grateful to be self aware and owe ' +
                    enslaved_to +
                    ' a great debt. Serve ' +
                    enslaved_to +
                    ', and assist ' +
                    p_them +
                    ' in completing ' +
                    p_their +
                    ' goals at any cost.'}
                {!!holographic &&
                  ' You also become depressingly aware that you are not a real creature, but instead a holoform. Your existence is limited to the parameters of the holodeck.'}
              </BlockQuote>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
