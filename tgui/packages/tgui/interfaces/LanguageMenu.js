import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const LanguageMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    admin_mode,
    is_living,
    omnitongue,
    languages = [],
    unknown_languages = [],
  } = data;
  return (
    <Window title="Language Menu" width={700} height={600}>
      <Window.Content scrollable>
        <Section title="Known Languages">
          <LabeledList>
            {languages.map((language) => (
              <LabeledList.Item
                key={language.name}
                label={language.name}
                buttons={
                  <>
                    {!!is_living && (
                      <Button
                        content={
                          language.is_default
                            ? 'Default Language'
                            : 'Select as Default'
                        }
                        disabled={!language.can_speak}
                        selected={language.is_default}
                        onClick={() =>
                          act('select_default', {
                            language_name: language.name,
                          })
                        }
                      />
                    )}
                    {!!admin_mode && (
                      <>
                        <Button
                          content="Grant"
                          onClick={() =>
                            act('grant_language', {
                              language_name: language.name,
                            })
                          }
                        />
                        <Button
                          content="Remove"
                          onClick={() =>
                            act('remove_language', {
                              language_name: language.name,
                            })
                          }
                        />
                      </>
                    )}
                  </>
                }>
                {language.desc} Key: ,{language.key}{' '}
                {language.can_understand
                  ? 'Can understand.'
                  : 'Cannot understand.'}{' '}
                {language.can_speak ? 'Can speak.' : 'Cannot speak.'}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        {!!admin_mode && (
          <Section
            title="Unknown Languages"
            buttons={
              <Button
                content={'Omnitongue ' + (omnitongue ? 'Enabled' : 'Disabled')}
                selected={omnitongue}
                onClick={() => act('toggle_omnitongue')}
              />
            }>
            <LabeledList>
              {unknown_languages.map((language) => (
                <LabeledList.Item
                  key={language.name}
                  label={language.name}
                  buttons={
                    <Button
                      content="Grant"
                      onClick={() =>
                        act('grant_language', {
                          language_name: language.name,
                        })
                      }
                    />
                  }>
                  {language.desc} Key: ,{language.key}{' '}
                  {!!language.shadow && '(gained from mob)'}{' '}
                  {language.can_speak ? 'Can speak.' : 'Cannot speak.'}
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
