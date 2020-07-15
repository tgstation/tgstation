import { Section, Button, LabeledList, Box, NoticeBox } from "../components";
import { useBackend } from "../backend";
import { createLogger } from "../logging";
import { Fragment } from "inferno";
import { NtosWindow } from "../layouts";

export const NtosNetDos = (props, context) => {
  return (
    <NtosWindow theme="syndicate">
      <NtosWindow.Content>
        <NtosNetDosContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosNetDosContent = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    relays = [],
    focus,
    target,
    speed,
    overload,
    capacity,
    error,
  } = data;

  if (error) {
    return (
      <Fragment>
        <NoticeBox>
          {error}
        </NoticeBox>
        <Button
          fluid
          content="Reset"
          textAlign="center"
          onClick={() => act('PRG_reset')}
        />
      </Fragment>
    );
  }

  const generate10String = length => {
    let outString = "";
    const factor = (overload / capacity);
    while (outString.length < length) {
      if (Math.random() > factor) {
        outString += "0";
      } else {
        outString += "1";
      }
    }
    return outString;
  };

  const lineLength = 45;

  if (target) {
    return (
      <Section fontFamily="monospace" textAlign="center">
        <Box>
          CURRENT SPEED: {speed} GQ/s
        </Box>
        <Box>
          {/* I don't care anymore */}
          {generate10String(lineLength)}
        </Box>
        <Box>
          {generate10String(lineLength)}
        </Box>
        <Box>
          {generate10String(lineLength)}
        </Box>
        <Box>
          {generate10String(lineLength)}
        </Box>
        <Box>
          {generate10String(lineLength)}
        </Box>
      </Section>
    );
  }

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Target">
          {relays.map(relay => (
            <Button
              key={relay.id}
              content={relay.id}
              selected={focus === relay.id}
              onClick={() => act('PRG_target_relay', {
                targid: relay.id,
              })}
            />
          ))}
        </LabeledList.Item>
      </LabeledList>
      <Button
        fluid
        bold
        content="EXECUTE"
        color="bad"
        textAlign="center"
        disabled={!focus}
        mt={1}
        onClick={() => act('PRG_execute')}
      />
    </Section>
  );
};
