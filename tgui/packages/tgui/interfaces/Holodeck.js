import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

export const Holodeck = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    can_toggle_safety,
    default_programs = [],
    emag_programs = [],
    emagged,
    program,
  } = data;
  return (
    <Window
      width={400}
      height={500}
      resizable>
      <Window.Content scrollable>
        <Section
          title="Default Programs"
          buttons={(
            <Button
              icon={emagged ? "unlock" : "lock"}
              content="Safeties"
              color="bad"
              disabled={!can_toggle_safety}
              selected={!emagged}
              onClick={() => act('safety')} />
          )}>
          {default_programs.map(def_program => (
            <Button
              fluid
              key={def_program.type}
              content={def_program.name.substring(11)}
              textAlign="center"
              selected={def_program.type === program}
              onClick={() => act('load_program', {
                type: def_program.type,
              })} />
          ))}
        </Section>
        {!!emagged && (
          <Section title="Dangerous Programs">
            {emag_programs.map(emag_program => (
              <Button
                fluid
                key={emag_program.type}
                content={emag_program.name.substring(11)}
                color="bad"
                textAlign="center"
                selected={emag_program.type === program}
                onClick={() => act('load_program', {
                  type: emag_program.type,
                })} />
            ))}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
