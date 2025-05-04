import { useEffect, useState } from 'react';
import { Button, Modal, Section, Stack } from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';

import { resolveAsset } from '../../assets';
import { Window } from '../../layouts';
import { logger } from '../../logging';
import { CreateObject } from './CreateObject';
import { CreateObjectData } from './types';

export function SpawnPanel() {
  const [data, setData] = useState<CreateObjectData | undefined>();
  const [advancedSettings, setAdvancedSettings] = useState(false);

  useEffect(() => {
    fetchRetry(resolveAsset('spawnpanel.json'))
      .then((response) => response.json())
      .then((data) => {
        setData(data);
      })
      .catch((error) => {
        logger.log('Failed to fetch spawnpanel.json', error);
      });
  }, []);

  return (
    <Window height={550} title="Spawn Panel" width={500} theme="admin">
      <Window.Content>
        {advancedSettings && (
          <Modal
            style={{
              padding: '6px',
              width: '30em',
              marginTop: '-15em',
            }}
          >
            <Section
              title="Advanced settings"
              buttons={
                <Button
                  color="transparent"
                  icon="close"
                  onClick={() => setAdvancedSettings(false)}
                />
              }
            >
              settings go here
            </Section>
          </Modal>
        )}
        <Stack vertical fill>
          <Stack.Item grow>
            {data && (
              <CreateObject
                objList={data}
                setAdvancedSettings={setAdvancedSettings}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
