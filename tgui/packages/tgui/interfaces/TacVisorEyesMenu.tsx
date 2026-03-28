import { Button, Dropdown, LabeledList, Section } from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  friendlyFaction: string;
  hostileFaction: string;
  visorDisplay: string;
  threatFlags: number;

  validFriendlyFactions: string[];
  validHostileFactions: string[];
  visorOptions: string[];
  threatOptions: Record<string, number>;
};

export const TacVisorEyesMenu = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    friendlyFaction,
    hostileFaction,
    visorDisplay,
    threatFlags,
    validFriendlyFactions,
    validHostileFactions,
    visorOptions,
    threatOptions,
  } = data;
  return (
    <Window title="Tactical IFF Visor" width={320} height={264}>
      <Window.Content>
        <Section title="Settings">
          <LabeledList>
            <LabeledList.Item label="Friendly Faction">
              <Dropdown
                options={validFriendlyFactions}
                selected={friendlyFaction}
                onSelected={(value) => act('set_friendly', { faction: value })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Hostile Faction">
              <Dropdown
                options={validHostileFactions}
                selected={hostileFaction}
                onSelected={(value) => act('set_hostile', { faction: value })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Visor Image">
              <Dropdown
                options={visorOptions}
                selected={visorDisplay}
                onSelected={(value) => act('set_display', { display: value })}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Threat Parameters">
          {Object.keys(threatOptions).map((option) => (
            <Button.Checkbox
              key={option}
              checked={threatFlags & threatOptions[option]}
              onClick={() =>
                act('set_threat_flags', {
                  threat_flags: threatFlags ^ threatOptions[option],
                })
              }
            >
              {option}
            </Button.Checkbox>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
