import { useBackend } from '../backend';
import { Section } from '../components';
import { Window } from '../layouts';

export const StationAlertConsole = () => {
  return (
    <Window
      width={345}
      height={587}>
      <Window.Content scrollable>
        <StationAlertConsoleContent />
      </Window.Content>
    </Window>
  );
};

export const StationAlertConsoleContent = (props, context) => {
  const { data } = useBackend(context);
  const categories = data.alarms || [];
  const fire = categories['Fire'];
  const atmos = categories['Atmosphere'];
  const power = categories['Power'];
  const motion = categories['Motion'];
  const burglar = categories['Burglar'];
  const camera = categories['Camera'];
  return (
    <>
      {fire && (
        <Section title="Fire Alarms">
          <ul>
            {fire.length === 0 && (
              <li className="color-good">
                Systems Nominal
              </li>
            )}
            {fire.map(alert => (
              <li key={alert} className="color-average">
                {alert}
              </li>
            ))}
          </ul>
        </Section>
      )}
      {atmos && (
        <Section title="Atmospherics Alarms">
          <ul>
            {atmos.length === 0 && (
              <li className="color-good">
                Systems Nominal
              </li>
            )}
            {atmos.map(alert => (
              <li key={alert} className="color-average">
                {alert}
              </li>
            ))}
          </ul>
        </Section>
      )}
      {power && (
        <Section title="Power Alarms">
          <ul>
            {power.length === 0 && (
              <li className="color-good">
                Systems Nominal
              </li>
            )}
            {power.map(alert => (
              <li key={alert} className="color-average">
                {alert}
              </li>
            ))}
          </ul>
        </Section>
      )}
      {burglar && (
        <Section title="Burglar Alarms">
          <ul>
            {burglar.length === 0 && (
              <li className="color-good">
                Systems Nominal
              </li>
            )}
            {burglar.map(alert => (
              <li key={alert} className="color-average">
                {alert}
              </li>
            ))}
          </ul>
        </Section>
      )}
      {motion && (
        <Section title="Motion Alarms">
          <ul>
            {motion.length === 0 && (
              <li className="color-good">
                Systems Nominal
              </li>
            )}
            {motion.map(alert => (
              <li key={alert} className="color-average">
                {alert}
              </li>
            ))}
          </ul>
        </Section>
      )}      
    {camera && (
      <Section title="Camera Alarms">
        <ul>
          {camera.length === 0 && (
            <li className="color-good">
              Systems Nominal
            </li>
          )}
          {camera.map(alert => (
            <li key={alert} className="color-average">
              {alert}
            </li>
          ))}
        </ul>
      </Section>
      )}
    </>
  );
};
