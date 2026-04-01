import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Dropdown, LabeledList, Tooltip } from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

type JeffJeffData = {
  availableTypes: string[];
  availableThemes: string[];
  guardianType: string | null;
  guardianTheme: string | null;
};

export const JeffJeff = (props) => {
  const { act, data } = useBackend<JeffJeffData>();
  const { availableTypes, availableThemes, guardianType, guardianTheme } = data;
  return (
    <Window title="JeffJeff's Peculiar Excursion" width={400} height={500}>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item
            label={
              <Tooltip content='The type of guardian you wish to have. Select "None" to opt out of having a guardian.'>
                Guardian Type
              </Tooltip>
            }
          >
            <Dropdown
              options={[
                'None',
                ...availableTypes.map((type) => {
                  return { displayText: capitalize(type), value: type };
                }),
              ]}
              selected={capitalize(guardianType || 'None')}
              onSelected={(value) => act('setGuardianType', { type: value })}
            />
          </LabeledList.Item>
          <LabeledList.Item
            label={
              <Tooltip content='The theme of the guardian you will be. Select "None" to opt out of being a guardian.'>
                Guardian Theme
              </Tooltip>
            }
          >
            <Dropdown
              options={[
                'None',
                ...availableThemes.map((type) => {
                  return { displayText: capitalize(type), value: type };
                }),
              ]}
              selected={capitalize(guardianTheme || 'None')}
              onSelected={(value) => act('setGuardianTheme', { type: value })}
            />
          </LabeledList.Item>
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
