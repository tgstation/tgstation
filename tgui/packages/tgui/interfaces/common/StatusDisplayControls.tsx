import { useBackend, useSharedState } from '../../backend';
import { Flex, Input, Section, Button } from '../../components';

type Data = {
  upperText: string;
  lowerText: string;
  maxStatusLineLength: number;
};

export const StatusDisplayControls = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    upperText: initialUpper,
    lowerText: initialLower,
    maxStatusLineLength,
  } = data;

  const [upperText, setUpperText] = useSharedState(
    context,
    'statusUpperText',
    initialUpper
  );
  const [lowerText, setLowerText] = useSharedState(
    context,
    'statusLowerText',
    initialLower
  );

  return (
    <>
      <Section>
        <Button
          icon="toggle-off"
          content="Off"
          color="bad"
          onClick={() => act('setStatusPicture', { picture: 'blank' })}
        />
        <Button
          icon="space-shuttle"
          content="Shuttle ETA / Off"
          color=""
          onClick={() => act('setStatusPicture', { picture: 'shuttle' })}
        />
      </Section>

      <Section title="Graphics">
        <Button
          icon="flag"
          content="Logo"
          onClick={() => act('setStatusPicture', { picture: 'default' })}
        />

        <Button
          icon="bell-o"
          content="Red Alert"
          onClick={() => act('setStatusPicture', { picture: 'redalert' })}
        />

        <Button
          icon="exclamation-triangle"
          content="Lockdown"
          onClick={() => act('setStatusPicture', { picture: 'lockdown' })}
        />

        <Button
          icon="biohazard"
          content="Biohazard"
          onClick={() => act('setStatusPicture', { picture: 'biohazard' })}
        />
      </Section>

      <Section title="Message">
        <Flex direction="column" align="stretch">
          <Flex.Item mb={1}>
            <Input
              fluid
              maxLength={maxStatusLineLength}
              value={upperText}
              onChange={(_, value) => setUpperText(value)}
            />
          </Flex.Item>

          <Flex.Item mb={1}>
            <Input
              fluid
              maxLength={maxStatusLineLength}
              value={lowerText}
              onChange={(_, value) => setLowerText(value)}
            />
          </Flex.Item>

          <Flex.Item>
            <Button
              icon="comment-o"
              onClick={() => act('setStatusMessage', { upperText, lowerText })}
              content="Send"
            />
          </Flex.Item>
        </Flex>
      </Section>
    </>
  );
};
