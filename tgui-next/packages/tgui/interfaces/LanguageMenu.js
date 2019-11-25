import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, Section } from '../components';

export const LanguageMenu = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const {
    admin_mode,
    is_living,
    omnitongue,
    languages = [],
    unknown_languages = [],
  } = data;
  return (
    <Fragment>
      <Section title="Known Languages">
        <LabeledList>
          {languages.map(language => (
            <LabeledList.Item
              key={language.name}
              label={language.name}
              buttons={(
                <Fragment>
                  {!!is_living && (
                    <Button
                      content={language.is_default ? "Default Language" : "Select as Default"}
                      disabled={!language.can_speak}
                      selected={language.is_default}
                      onClick={() => act(ref, 'select_default', {language_name: language.name})}
                    />
                  )}
                  {!!admin_mode && (
                    <Fragment>
                      <Button
                        content="Grant"
                        onClick={() => act(ref, "grant_language", {language_name: language.name})}
                      />
                      <Button
                        content="Remove"
                        onClick={() => act(ref, "remove_language", {language_name: language.name})}
                      />
                    </Fragment>
                  )}
                </Fragment>
              )}
            >
              {language.desc}
              {' '}
              Key: ,{language.key}
              {' '}
              {!!language.shadow && ("(gained from mob)")}
              {' '}
              {language.can_speak ? "Can speak." : "Cannot speak." }
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
      {!!admin_mode && (
        <Section
          title="Unknown Languages"
          buttons={(
            <Button
              content={"Omnitongue " + (omnitongue ? "Enabled" : "Disabled")}
              selected={omnitongue}
              onClick={() => act(ref, "toggle_omnitongue")}
            />
          )}
        >
          <LabeledList>
            {unknown_languages.map(language => (
              <LabeledList.Item
                key={language.name}
                label={language.name}
                buttons={(
                  <Button
                    content="Grant"
                    onClick={() => act(ref, "grant_language", {language_name: language.name})}
                  />
                )}
              >
                {language.desc}
                {' '}
                  Key: ,{language.key}
                {' '}
                {!!language.shadow && ("(gained from mob)")}
                {' '}
                {language.can_speak ? "Can speak." : "Cannot speak." }
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      )}
    </Fragment>
  );
};
