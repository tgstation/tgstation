import { useBackend } from "../backend";
import {
  Slider,
  Button,
  Stack,
  NoticeBox,
  ProgressBar,
  Section,
  Box,
} from "../components";
import { Window } from "../layouts";

export const ArtifactXray = (props, context) => {
  const { act, data } = useBackend(context);
  const { is_open, artifact_name, pulsing, current_strength, max_strength } =
    data;
  return (
    <Window width={400} height={150}>
      <Window.Content>
        <Section
          title="X-Ray status"
          textAlign="center"
          buttons={
            <Button
              content={is_open ? "Close" : "Open"}
              selected={!is_open}
              onClick={() => act("toggleopen")}
            />
          }
        >
          {(!artifact_name && <NoticeBox>No artifact detected.</NoticeBox>) || (
            <>
              <Box color="label" mt={1}>
                <b>Currently loaded object:</b> {artifact_name}
              </Box>
			  <Stack fill>
            <Stack.Item grow>
              <Slider
                minValue={0}
                maxValue={max_strength}
                value={current_strength}
                stepPixelSize={35}
                step={0.5}
				unit={"Pulse Strength"}
                onDrag={(e, nu) => act("change_rate", { target: nu })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                content={"Pulse"}
                disabled={is_open || pulsing}
                color="green"
                onClick={() => act("pulse")}/>
            </Stack.Item>
          </Stack>
		  </>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
