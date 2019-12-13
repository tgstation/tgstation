import { Button, Flex, NoticeBox } from '../../components';

export const InterfaceLockNoticeBox = props => {
  const {
    siliconUser,
    locked,
    onLockStatusChange,
    accessText,
  } = props;
  // For silicon users
  if (siliconUser) {
    return (
      <NoticeBox>
        <Flex align="center">
          <Flex.Item>
            Interface lock status:
          </Flex.Item>
          <Flex.Item grow={1} />
          <Flex.Item>
            <Button
              m={0}
              color="gray"
              icon={locked ? 'lock' : 'unlock'}
              content={locked ? 'Locked' : 'Unlocked'}
              onClick={() => {
                if (onLockStatusChange) {
                  onLockStatusChange(!locked);
                }
              }} />
          </Flex.Item>
        </Flex>
      </NoticeBox>
    );
  }
  // For everyone else
  return (
    <NoticeBox>
      Swipe {accessText || 'an ID card'}{' '}
      to {locked ? 'unlock' : 'lock'} this interface.
    </NoticeBox>
  );
};
