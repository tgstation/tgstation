import { useBackend, useLocalState } from '../backend';
import { Button, Collapsible, Input, NoticeBox, Section, Stack } from '../components';
import { Window } from '../layouts';

enum MuteTypes {
  MUTE_NONE = 0,
  MUTE_IC = 1,
  MUTE_OOC = 2,
  MUTE_PRAY = 4,
  MUTE_ADMINHELP = 8,
  MUTE_DEADCHAT = 16,
  MUTE_INTERNET_REQUEST = 32,
  MUTE_ALL = 32767,
}

type MuteData = {
  id: number;
  muted_flag: number;
  reason: string;
  admin: string;
  datetime: string;
  deleted: boolean;
  deleted_datetime: string;
};

type PMMData = {
  ckey_cache: string[];
  mutes: Record<string, MuteData[]>;
  polling_ckeys: string[];
  whoami: string;
};

enum ActiveView {
  overview = 'Overview',
  add_mute = 'Add Mute',
  view_mutes = 'View Mutes',
}

enum SortType {
  ckey,
  amount,
}

// eslint-disable-next-line func-style
function muteFlagToString(flag: number): string {
  switch (flag) {
    case MuteTypes.MUTE_IC:
      return 'IC';
    case MuteTypes.MUTE_OOC:
      return 'OOC';
    case MuteTypes.MUTE_PRAY:
      return 'Pray';
    case MuteTypes.MUTE_ADMINHELP:
      return 'Adminhelp';
    case MuteTypes.MUTE_DEADCHAT:
      return 'Deadchat';
    case MuteTypes.MUTE_INTERNET_REQUEST:
      return 'Internet Request';
    case MuteTypes.MUTE_ALL:
      return 'All';
    default:
      return 'Unknown';
  }
}

export const PersistentMuteManager = (_: any, context: any) => {
  const { act, data } = useBackend<PMMData>(context);
  const { ckey_cache, mutes } = data;

  const [target_ckey, set_target_ckey] = useLocalState<string>(
    context,
    'target_ckey',
    ''
  );
  const [active_view, set_active_view] = useLocalState<ActiveView>(
    context,
    'active_view',
    ActiveView.overview
  );
  const [sort_type, set_sort_type] = useLocalState<SortType>(
    context,
    'sort_type',
    SortType.ckey
  );

  if (target_ckey && data.polling_ckeys.includes(target_ckey)) {
    return (
      <Window title="Persistent Mute Manager">
        <Window.Content>
          <NoticeBox info>Polling {target_ckey}...</NoticeBox>
        </Window.Content>
      </Window>
    );
  }

  const [editing_mute, set_editing_mute] = useLocalState<MuteData | undefined>(
    context,
    'editing_mute',
    undefined
  );
  const edit_mute = (mute: MuteData) => {
    set_editing_mute(mute);
    set_active_view(ActiveView.add_mute);
  };

  return (
    <Window title="Persistent Mute Manager" width={600}>
      <Window.Content>
        <Section
          title="Management"
          buttons={
            <>
              <Button
                icon="refresh"
                onClick={() => act('refresh')}
                color="green"
              />
              <Button
                icon="times"
                color="red"
                disabled={target_ckey === ''}
                onClick={() => {
                  set_active_view(ActiveView.overview);
                  set_target_ckey('');
                }}
                title="Clear"
              />
              <Button
                icon="list"
                content={ActiveView.overview}
                selected={active_view === ActiveView.overview}
                onClick={() => set_active_view(ActiveView.overview)}
              />
              <Button
                icon="plus"
                content={ActiveView.add_mute}
                selected={active_view === ActiveView.add_mute}
                disabled={target_ckey === ''}
                onClick={() => set_active_view(ActiveView.add_mute)}
              />
              <Button
                icon="search"
                content={ActiveView.view_mutes}
                selected={active_view === ActiveView.view_mutes}
                disabled={target_ckey === ''}
                onClick={() => set_active_view(ActiveView.view_mutes)}
              />
            </>
          }>
          <Stack vertical>
            <Stack.Item>
              Target -&nbsp;
              {target_ckey === '' ? (
                <Input
                  placeholder="ckey"
                  onChange={(_: any, value: string) => set_target_ckey(value)}
                />
              ) : (
                target_ckey
              )}
            </Stack.Item>
            <Stack.Item>
              Sorting:&nbsp;
              <Button
                icon="sort-alpha-asc"
                content="Ckey"
                selected={sort_type === SortType.ckey}
                onClick={() => set_sort_type(SortType.ckey)}
              />
              <Button
                icon="sort-numeric-desc"
                content="Amount"
                selected={sort_type === SortType.amount}
                onClick={() => set_sort_type(SortType.amount)}
              />
            </Stack.Item>
          </Stack>
        </Section>
        {active_view === ActiveView.overview && (
          <Overview
            ckey_cache={ckey_cache}
            mutes={mutes}
            target_ckey={target_ckey}
            set_target_ckey={set_target_ckey}
            set_active_view={set_active_view}
            sort_type={sort_type}
          />
        )}
        {active_view === ActiveView.add_mute && (
          <AddMuteMenu
            ckey={target_ckey}
            whoami={data.whoami}
            isEdit={editing_mute !== undefined}
            reason={editing_mute?.reason}
            muted_flags={editing_mute?.muted_flag}
            id={editing_mute?.id}
            setActiveView={set_active_view}
            cancelEdit={() => {
              set_active_view(ActiveView.view_mutes);
              set_editing_mute(undefined);
            }}
          />
        )}
        {active_view === ActiveView.view_mutes && (
          <ViewMuteMenu
            ckey={target_ckey}
            mutes={mutes[target_ckey]}
            edit_mute={edit_mute}
          />
        )}
      </Window.Content>
    </Window>
  );
};

type OverviewProps = {
  ckey_cache: string[];
  mutes: Record<string, MuteData[]>;
  target_ckey: string;
  set_target_ckey: (ckey: string) => void;
  set_active_view: (view: ActiveView) => void;
  sort_type: SortType;
};

const Overview = (props: OverviewProps, context: any) => {
  const { act } = useBackend(context);
  const [filter_text, set_filter_text] = useLocalState<string>(
    context,
    'filter_text',
    ''
  );

  return (
    <Section
      title="Overview"
      buttons={
        <>
          <Input
            placeholder="Filter"
            onChange={(_: any, value: string) => set_filter_text(value)}
          />
          <Button
            icon="times"
            color="red"
            disabled={filter_text === ''}
            onClick={() => set_filter_text('')}
            title="Clear"
          />
        </>
      }>
      <Stack vertical>
        {props.ckey_cache
          .sort((a, b) => {
            if (props.sort_type === SortType.ckey) {
              return a.localeCompare(b);
            }
            const totalMutesA =
              props.mutes[a]?.filter((mute) => !mute.deleted).length ?? 0;
            const totalMutesB =
              props.mutes[b]?.filter((mute) => !mute.deleted).length ?? 0;
            return totalMutesB - totalMutesA;
          })
          .map((ckey) => {
            const totalMutes =
              props.mutes[ckey]?.filter((mute) => !mute.deleted).length ?? 0;
            return (
              <Stack.Item key={ckey}>
                <Button
                  fluid
                  content={`${ckey} - (${totalMutes})`}
                  onClick={() => {
                    props.set_target_ckey(ckey);
                    act('poll-ckey', { ckey: ckey });
                    props.set_active_view(ActiveView.view_mutes);
                  }}
                  disabled={props.target_ckey === ckey}
                />
              </Stack.Item>
            );
          })}
      </Stack>
    </Section>
  );
};

type AddMuteProps = {
  ckey: string;
  whoami: string;
  isEdit?: boolean;
  reason?: string;
  muted_flags?: number;
  id?: number;
  setActiveView: (view: ActiveView) => void;
  cancelEdit?: () => void;
};

const AddMuteMenu = (props: AddMuteProps, context: any) => {
  let { ckey, whoami } = props;

  const [reason, set_reason] = useLocalState<string>(
    context,
    'reason',
    props.reason ?? ''
  );
  const [muted_flag, set_muted_flag] = useLocalState<number>(
    context,
    'muted_flag',
    props.muted_flags ?? MuteTypes.MUTE_NONE
  );
  const { act } = useBackend(context);

  return (
    <Section title={`Add Mute - [${ckey}]`}>
      <Stack vertical>
        <Stack.Item>
          <Input
            fluid
            monospace
            placeholder="Reason"
            value={reason}
            onChange={(_: any, value: string) => set_reason(value)}
          />
        </Stack.Item>
        <Stack.Item>
          <FlagPicker flag={muted_flag} set_flag={set_muted_flag} />
        </Stack.Item>
        <Stack.Item>
          {props.isEdit ? (
            <>
              <Button
                content="Cancel"
                onClick={() => {
                  props.cancelEdit?.();
                }}
              />
              <Button
                content="Save"
                onClick={() => {
                  act('edit', {
                    id: props.id,
                    reason: reason,
                    muted_flag: muted_flag,
                    admin: whoami,
                  });
                  props.cancelEdit?.();
                }}
              />
            </>
          ) : (
            <Button
              content="Add"
              onClick={() => {
                act('add', {
                  ckey: ckey,
                  reason: reason,
                  muted_flag: muted_flag,
                  admin: whoami,
                });
                props.setActiveView(ActiveView.view_mutes);
              }}
            />
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

AddMuteMenu.defaultProps = {
  isEdit: false,
};

type FlagPickerProps = {
  flag: number;
  set_flag: (flag: number) => void;
};

const FlagPicker = (props: FlagPickerProps, context: any) => {
  const { flag, set_flag } = props;
  return (
    <Stack>
      <Stack.Item>
        <Button
          content="All"
          selected={flag === MuteTypes.MUTE_ALL}
          onClick={() =>
            set_flag(
              flag === MuteTypes.MUTE_ALL
                ? MuteTypes.MUTE_NONE
                : MuteTypes.MUTE_ALL
            )
          }
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          content="IC"
          selected={flag & MuteTypes.MUTE_IC}
          disabled={flag === MuteTypes.MUTE_ALL}
          onClick={() => set_flag(flag ^ MuteTypes.MUTE_IC)}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          content="OOC"
          selected={flag & MuteTypes.MUTE_OOC}
          disabled={flag === MuteTypes.MUTE_ALL}
          onClick={() => set_flag(flag ^ MuteTypes.MUTE_OOC)}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          content="Pray"
          selected={flag & MuteTypes.MUTE_PRAY}
          disabled={flag === MuteTypes.MUTE_ALL}
          onClick={() => set_flag(flag ^ MuteTypes.MUTE_PRAY)}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          content="Adminhelp"
          selected={flag & MuteTypes.MUTE_ADMINHELP}
          disabled={flag === MuteTypes.MUTE_ALL}
          onClick={() => set_flag(flag ^ MuteTypes.MUTE_ADMINHELP)}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          content="Deadchat"
          selected={flag & MuteTypes.MUTE_DEADCHAT}
          disabled={flag === MuteTypes.MUTE_ALL}
          onClick={() => set_flag(flag ^ MuteTypes.MUTE_DEADCHAT)}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          content="Internet Request"
          selected={flag & MuteTypes.MUTE_INTERNET_REQUEST}
          disabled={flag === MuteTypes.MUTE_ALL}
          onClick={() => set_flag(flag ^ MuteTypes.MUTE_INTERNET_REQUEST)}
        />
      </Stack.Item>
    </Stack>
  );
};

type ViewMuteProps = {
  ckey: string;
  mutes: MuteData[];
  edit_mute: (mute: MuteData) => void;
};

const ViewMuteMenu = (props: ViewMuteProps, context: any) => {
  let { ckey, mutes } = props;

  const [active_only, set_active_only] = useLocalState<boolean>(
    context,
    'active_only',
    true
  );

  return (
    <Section
      title={`View Mutes - ${ckey}`}
      buttons={
        <Button
          icon="clock"
          content="Active Only"
          selected={active_only}
          onClick={() => set_active_only(!active_only)}
        />
      }>
      <Stack vertical>
        {mutes?.map((mute) => {
          if (active_only && mute.deleted) {
            return null;
          }
          return (
            <>
              <Stack.Item key={mute.id}>
                <MuteDisplay mute={mute} edit_mute={props.edit_mute} />
              </Stack.Item>
              <Stack.Divider />
            </>
          );
        })}
      </Stack>
    </Section>
  );
};

type MuteDisplayProps = {
  mute: MuteData;
  edit_mute: (mute: MuteData) => void;
};

const MuteDisplay = (props: MuteDisplayProps, context: any) => {
  const mute = props.mute;
  const { act } = useBackend(context);
  return (
    <Collapsible title={`${muteFlagToString(mute.muted_flag)} - ${mute.admin}`}>
      <Stack vertical>
        <Stack.Item>Reason: {mute.reason}</Stack.Item>
        <Stack.Item>Time: {mute.datetime}</Stack.Item>
        {(!mute.deleted && (
          <Stack.Item>
            <Button
              icon="times"
              color="red"
              onClick={() => act('delete', { id: mute.id })}
            />
            <Button
              icon="edit"
              color="yellow"
              onClick={() => props.edit_mute(mute)}
            />
          </Stack.Item>
        )) || <Stack.Item>Deleted At: {mute.deleted_datetime}</Stack.Item>}
      </Stack>
    </Collapsible>
  );
};
