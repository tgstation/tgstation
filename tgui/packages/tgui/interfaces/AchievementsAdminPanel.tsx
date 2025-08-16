import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  orphaned_keys: string[];
  archived_keys: string[];
};

export const AchievementsAdminPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { orphaned_keys } = data;
  return (
    <Window title="Achievements Admin Panel" width={540} height={680}>
      <Window.Content scrollable>
        <Section title="Orphaned achievements">
          <NoticeBox>
            These achievements are present in the database but are missing
            definitions in code. Most likely these were removed and can be
            cleaned up safely. If you're sharing the same database on multiple
            servers it's possible these come from a server with later version of
            the code than this one.
          </NoticeBox>
          <LabeledList>
            {orphaned_keys.map((key) => (
              <LabeledList.Item
                key={key}
                label=""
                buttons={
                  <>
                    <Button.Confirm
                      onClick={() => act('archive', { key: key })}
                    >
                      Archive
                    </Button.Confirm>
                    <Button.Confirm
                      onClick={() => act('cleanup_orphan', { key: key })}
                    >
                      Cleanup
                    </Button.Confirm>
                  </>
                }
              >
                {key}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section title="Archived achievements">
          <NoticeBox>Archived achievements in the database.</NoticeBox>
          <LabeledList>
            {orphaned_keys.map((key) => (
              <LabeledList.Item
                key={key}
                label=""
                buttons={
                  <Button.Confirm
                    onClick={() => act('cleanup_orphan', { key: key })}
                  >
                    Cleanup
                  </Button.Confirm>
                }
              >
                {key}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
