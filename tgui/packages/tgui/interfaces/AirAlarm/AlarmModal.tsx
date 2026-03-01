import { Box, Button, Modal, NumberInput, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { AirAlarmData, EditingModalProps } from './types';

export function AlarmEditingModal(props: EditingModalProps) {
  const { act } = useBackend<AirAlarmData>();
  const { id, name, type, typeName, unit, oldValue, finish, typeVar } = props;

  return (
    <Modal>
      <Section
        title="Threshold Value Editor"
        buttons={<Button onClick={() => finish()} icon="times" color="red" />}
      >
        <Box mb={1.5}>
          Editing the {typeName.toLowerCase()} value for {name.toLowerCase()}
          ...
        </Box>
        {oldValue === -1 ? (
          <Button
            onClick={() =>
              act('set_threshold', {
                threshold: id,
                threshold_type: type,
                value: 0,
              })
            }
          >
            Enable
          </Button>
        ) : (
          <>
            <NumberInput
              onChange={(value) =>
                act('set_threshold', {
                  threshold: id,
                  threshold_type: type,
                  value: value,
                })
              }
              unit={unit}
              value={oldValue}
              minValue={0}
              maxValue={100000}
              step={10}
            />
            <Button
              onClick={() =>
                act('set_threshold', {
                  threshold: id,
                  threshold_type: type,
                  value: -1,
                })
              }
            >
              Disable
            </Button>
          </>
        )}
      </Section>
    </Modal>
  );
}
