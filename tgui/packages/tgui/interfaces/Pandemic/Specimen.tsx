import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, NoticeBox, Section, Stack, Tabs } from 'tgui-core/components';

import { SymptomDisplay } from './Symptom';
import type { Data } from './types';
import { VirusDisplay } from './Virus';

export const SpecimenDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { is_ready, viruses = [] } = data;

  const [tab, setTab] = useState(0);
  const virus = viruses[tab];

  return (
    <Section
      fill
      scrollable
      title="Specimen"
      buttons={
        <Stack>
          {viruses.length > 1 && (
            <Stack.Item>
              <Tabs>
                {viruses.map((virus, index) => {
                  return (
                    <Tabs.Tab
                      selected={tab === index}
                      onClick={() => setTab(index)}
                      key={index}
                    >
                      {virus.name}
                    </Tabs.Tab>
                  );
                })}
              </Tabs>
            </Stack.Item>
          )}
          <Stack.Item>
            <Button
              icon="flask"
              disabled={!is_ready || !virus}
              tooltip={virus ? '' : 'No virus culture found.'}
              onClick={() =>
                act('create_culture_bottle', {
                  index: virus.index,
                })
              }
            >
              Create Culture Bottle
            </Button>
          </Stack.Item>
        </Stack>
      }
    >
      {!virus ? (
        <NoticeBox success>Nothing detected.</NoticeBox>
      ) : (
        <Stack fill vertical>
          <Stack.Item>
            <VirusDisplay virus={virus} />
          </Stack.Item>
          <Stack.Item>
            {virus?.symptoms && <SymptomDisplay symptoms={virus.symptoms} />}
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};
