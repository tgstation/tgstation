import { LabeledList, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  currentTram: Tram[];
  previousTrams: Tram[];
};

type Tram = {
  serialNumber: string;
  mfgDate: string;
  distanceTravelled: number;
  tramCollisions: number;
};

export const TramPlaque = (props) => {
  const { data } = useBackend<Data>();
  const { currentTram = [], previousTrams = [] } = data;

  return (
    <Window
      title="Tram Information Plaque"
      width={600}
      height={360}
      theme="dark"
    >
      <Window.Content>
        <NoticeBox info>SkyyTram Mk VI by Nakamura Engineering</NoticeBox>
        <Section
          title={
            currentTram.map((serialNumber) => serialNumber.serialNumber) +
            ' - Constructed ' +
            currentTram.map((serialNumber) => serialNumber.mfgDate)
          }
        >
          <LabeledList>
            <LabeledList.Item label="Distance Travelled">
              {currentTram.map(
                (serialNumber) => serialNumber.distanceTravelled / 1000,
              )}{' '}
              km
            </LabeledList.Item>
            <LabeledList.Item label="Collisions">
              {currentTram.map((serialNumber) => serialNumber.tramCollisions)}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Tram History">
          <Stack fill g={0}>
            <Stack.Item m={1} grow>
              <b>Serial</b>
            </Stack.Item>
            <Stack.Item m={1} grow>
              <b>Constructed</b>
            </Stack.Item>
            <Stack.Item m={1} grow>
              <b>Distance</b>
            </Stack.Item>
            <Stack.Item m={1} grow>
              <b>Collisions</b>
            </Stack.Item>
          </Stack>
          <Stack vertical fill>
            {previousTrams.map((tram_entry) => (
              <Stack.Item key={tram_entry.serialNumber}>
                <Stack fill g={0}>
                  <Stack.Item m={1} grow>
                    {tram_entry.serialNumber}
                  </Stack.Item>
                  <Stack.Item m={1} grow>
                    {tram_entry.mfgDate}
                  </Stack.Item>
                  <Stack.Item m={1} grow>
                    {tram_entry.distanceTravelled / 1000} km
                  </Stack.Item>
                  <Stack.Item m={1} grow>
                    {tram_entry.tramCollisions}
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
