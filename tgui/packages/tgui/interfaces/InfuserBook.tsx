import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';

type Entry = {
  name: string;
  infuse_mob_name: string;
  desc: string;
  threshold_desc: string;
  qualities: string[];
};

type DnaInfuserData = {
  entries: Entry[];
};

export const InfuserBook = (props, context) => {
  const { data } = useBackend<DnaInfuserData>(context);
  const { entries } = data;
  return (
    <Window width={620} height={340}>
      <Window.Content>
        <Section scrollable>
          <Stack vertical fill>
            {entries?.map((entry, index) => {
              <Stack.Item key={index}>
                <Stack vertical>
                  <Stack.Item>
                    <b>{entry.name}</b>
                  </Stack.Item>
                  <Stack.Item>
                    <b>{entry.infuse_mob_name}</b>
                  </Stack.Item>
                  <Stack.Item>
                    <b>{entry.desc}</b>
                  </Stack.Item>
                  <Stack.Item>
                    <b>{entry.threshold_desc}</b>
                  </Stack.Item>
                  <Section>
                    <Stack vertical>
                      {entry.qualities.map((quality) => {
                        <Stack.Item key={quality}>- {quality}</Stack.Item>;
                      })}
                    </Stack>
                  </Section>
                </Stack>
              </Stack.Item>;
            })}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
