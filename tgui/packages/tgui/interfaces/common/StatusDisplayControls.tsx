import { useBackend, useSharedState } from '../../backend';
import { Button, Flex, Input, Section } from '../../components';

type Data = {
  upperText: string;
  lowerText: string;
  maxStatusLineLength: number;
};

export const StatusDisplayControls = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    upperText: initialUpper,
    lowerText: initialLower,
    maxStatusLineLength,
  } = data;

  const [upperText, setUpperText] = useSharedState(
    'statusUpperText',
    initialUpper,
  );
  const [lowerText, setLowerText] = useSharedState(
    'statusLowerText',
    initialLower,
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
          icon="exclamation"
          content="Security Alert Level"
          onClick={() => act('setStatusPicture', { picture: 'currentalert' })}
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

        <Button
          icon="radiation"
          content="Radiation"
          onClick={() => act('setStatusPicture', { picture: 'radiation' })}
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
