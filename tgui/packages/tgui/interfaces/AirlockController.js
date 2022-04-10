import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const AirlockController = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    airlockState,
    sensorPressure,
    pumpStatus,
    interiorStatus,
    exteriorStatus,
  } = data;
  const currentStatus = ["ERROR, REPORT THIS TO CODERS", ""];
  let chamberStatusColor = "average";
  switch (airlockState) {
    case "inopen":
      currentStatus[0] = "Interior Airlock Open";
      currentStatus[1] = "Chamber Pressurized";
      chamberStatusColor = "good";
      break;
    case "pressurize":
      currentStatus[0] = "Cycling to Interior Airlock";
      currentStatus[1] = "Chamber Pressurizing";
      break;
    case "closed":
      currentStatus[0] = "Inactive";
      break;
    case "depressurize":
      currentStatus[0] = "Cycling to Exterior Airlock";
      currentStatus[1] = "Chamber Depressurizing";
      break;
    case "outopen":
      currentStatus[0] = "Exterior Airlock Open";
      currentStatus[1] = "Chamber Depressurized";
      chamberStatusColor = "bad";
      break;
  }
  return (
    <Window width={500} height={190}>
      <Window.Content>
        <Section title="Airlock Status" buttons={(
          ((airlockState === "pressurize" || airlockState === "depressurize")
            && <Button
              icon="stop-circle"
              content="Abort"
              onClick={() => act("abort")}
            />
          ) || (
            airlockState === "closed" && (
              <>
                <Button
                  icon="lock-open"
                  content="Open Interior Airlock"
                  onClick={() => act("cycleInterior")}
                />
                <Button
                  icon="lock-open"
                  content="Open Exterior Airlock"
                  onClick={() => act("cycleExterior")}
                />
              </>
            )
          ) || (
            airlockState === "inopen" && (
              <>
                <Button
                  icon="lock"
                  content="Close Interior Airlock"
                  onClick={() => act("cycleClosed")}
                />
                <Button
                  icon="sync"
                  content="Cycle to Exterior Airlock"
                  onClick={() => act("cycleExterior")}
                />
              </>
            )
          ) || (
            airlockState === "outopen" && (
              <>
                <Button
                  icon="lock"
                  content="Close Exterior Airlock"
                  onClick={() => act("cycleClosed")}
                />
                <Button
                  icon="sync"
                  content="Cycle to Interior Airlock"
                  onClick={() => act("cycleInterior")}
                />
              </>
            )
          )
        )}>
          <LabeledList>
            <LabeledList.Item label="Current Status">
              {currentStatus[0]}{currentStatus[1] !== "" && ", "}<Box as="span" color={chamberStatusColor}> {currentStatus[1]} </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Chamber Pressure">
              {sensorPressure} kPa
            </LabeledList.Item>
            <LabeledList.Item label="Control Pump">
              {pumpStatus}
            </LabeledList.Item>
            <LabeledList.Item label="Interior Door">
              {interiorStatus}
            </LabeledList.Item>
            <LabeledList.Item label="Exterior Door">
              {exteriorStatus}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
