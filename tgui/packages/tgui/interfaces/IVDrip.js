import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const IVDrip = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    transferRate,
    injectOnly,
    maxInjectRate,
    minInjectRate,
    mode,
    connected,
    beakerAttached,
    useInternalStorage,
  } = data;
  return(
    <Window resizable>
      <Window.Content scrollable>
        <Section title="IV Status">
          <LabeledList>
            <LabeledList.Item label="Status" color={connected ? 'good' : 'average'}>
            {connected ? "Conntected" : "Not Conntected"}
            </LabeledList.Item>
            <LabeledList.Item label="Mode">
              <Button
                disabled={injectOnly}
                content={(mode) => {
                  switch(mode) {
                    case 0:
                      return "Draining";
                    case 1:
                      return "Injecting";
                }}}
                icon={mode == "Injecting" ? "sign-in-alt" : "sign-out-alt"}
                onClick={() => act('changeMode')} />
            </LabeledList.Item>
            <LabeledList.Item label="Attached Container" color = {beakerAttached ? 'good' : 'average'}>
              <Box as="span" mr={2}>
                {beakerAttached ? "Container Attached" : "Container Not Attached"}
              </Box>
              <Button
                disabled = {(!beakerAttached) || useInternalStorage}
                content = "Eject"
                icon = "eject"
                onClick={() => act('eject')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  )
}