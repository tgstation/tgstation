import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend } from '../backend';
import { Button, Section, Stack } from '../components';
import { Window } from '../layouts';

export const StationAlertConsole = (props, context) => {
  const { data } = useBackend(context);
  const {
    cameraView,
  } = data;
  return (
    <Window
      width={cameraView ? 390 : 345}
      height={587}>
      <Window.Content scrollable>
        <StationAlertConsoleContent />
      </Window.Content>
    </Window>
  );
};

export const StationAlertConsoleContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    cameraView,
  } = data;

  const sortingKey = {
    "Fire": 0,
    "Atmosphere": 1,
    "Power": 2,
    "Burglar": 3,
    "Motion": 4,
    "Camera": 5,
  };

  const sortedAlarms = flow([
    sortBy((alarm) => sortingKey[alarm.name]),
  ])(data.alarms || []);

  return (
    <>
      {sortedAlarms.map(category => (
        <Section key={category.name} title={category.name + " Alarms"}>
          <ul>
            {category.alerts.length === 0 && (
              <li className="color-good">
                Systems Nominal
              </li>
            )}
            {category.alerts.map(alert => (
              <Stack 
                key={alert.name} 
                height="30px" 
                align="baseline">
                <Stack.Item grow>
                  <li className="color-average">
                    {alert.name} {!!cameraView && alert.sources > 1 
                      ? " (" + alert.sources + " sources)" : ""}
                  </li>
                </Stack.Item>
                {!!cameraView && (      
                  <Stack.Item>       
                    <Button
                      textAlign="center"
                      width="100px"
                      icon={alert.cameras ? "video" : ""}
                      disabled={!alert.cameras}
                      content={alert.cameras === 1 
                        ? alert.cameras + " Camera" : alert.cameras > 1
                          ? alert.cameras + " Cameras" : "No Camera"}
                      onClick={() => act('select_camera', {
                        alert: alert.ref,
                      })} />
                  </Stack.Item>
                )}  
              </Stack>
            ))}
          </ul>
        </Section>
      ))}
    </>
  );
};
