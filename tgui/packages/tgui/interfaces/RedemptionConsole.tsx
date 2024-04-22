import { useBackend } from '../backend';
import { LabeledList, Section } from '../components';
import { Window } from '../layouts';
import { logger } from '../logging';

type Data = {
  points: number;
  available_points: number;
  total_prisoners: number;
};

export function RedemptionConsole(props) {
  const { data } = useBackend<Data>();
  const { points: total_points, available_points, total_prisoners } = data;
  logger.log(data);

  return (
    <Window width={500} height={500}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Total Points">
              {total_points}
            </LabeledList.Item>
            <LabeledList.Item label="Available Points">
              {available_points}
            </LabeledList.Item>
            <LabeledList.Item label="Total Prisoners">
              {total_prisoners}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
}
