import { useContext, useState } from 'react';
import { Button, Dropdown, Modal, Section, Stack } from 'tgui-core/components';

import { PlaneDebugContext } from '.';
import { BlendModes, Plane } from './types';

export type PlaneMenuProps = {
  act: Function;
};

export function PlaneMenus(props: PlaneMenuProps) {
  const { act } = props;
  const { connectionOpen } = useContext(PlaneDebugContext);

  return (
    <>
      {!!connectionOpen && <AddConnectionModal act={act} />}
      <div />
    </>
  );
}

export function AddConnectionModal(props: PlaneMenuProps) {
  const { act } = props;
  const { activePlane, setActivePlane, setConnectionOpen, planesProcessed } =
    useContext(PlaneDebugContext);
  const currentPlane = planesProcessed[activePlane as number];
  const planeOptions: Array<string> = [];
  const optionMap: Record<string, number> = {};
  const [selectedTarget, setSelectedTarget] = useState<number>();
  const [selectedBlend, setSelectedBlend] = useState<string>('BLEND_DEFAULT');

  for (const key in planesProcessed) {
    const plane: Plane = planesProcessed[key];
    if (plane !== currentPlane) {
      planeOptions.push(plane.name);
      optionMap[plane.name] = plane.plane;
    }
  }

  return (
    <Modal p={1}>
      <Section
        fill
        title={`Add relay from ${currentPlane.name}`}
        buttons={
          <Button
            icon="close"
            color="bad"
            onClick={() => {
              setConnectionOpen(false);
              setActivePlane(undefined);
            }}
          />
        }
      >
        <Stack fill vertical>
          <Stack.Item>
            <Dropdown
              options={planeOptions}
              selected={
                selectedTarget !== undefined
                  ? planesProcessed[selectedTarget].name
                  : 'Select target'
              }
              width="300px"
              onSelected={(value) => setSelectedTarget(optionMap[value])}
            />
          </Stack.Item>
          <Stack.Item>
            <Dropdown
              options={Object.keys(BlendModes).filter((x) =>
                Number.isNaN(Number(x)),
              )}
              selected={selectedBlend}
              width="300px"
              onSelected={(value) => setSelectedBlend(value)}
            />
          </Stack.Item>
          <Stack.Item textAlign="center">
            <Button
              color="good"
              onClick={() => {
                act('connect_relay', {
                  source: activePlane,
                  target: selectedTarget,
                  mode: BlendModes[selectedBlend],
                });
                setConnectionOpen(false);
                setActivePlane(undefined);
              }}
            >
              Confirm
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
}
