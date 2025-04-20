import { Box, Input, NoticeBox, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  valid_id: BooleanLike;
  redeemed_coupons: CouponData[];
  printed_coupons: CouponData[];
};

type CouponData = {
  goody: string;
  discount: number;
};

export const NtosCouponMaster = (props) => {
  const { act, data } = useBackend<Data>();
  const { valid_id, redeemed_coupons = [], printed_coupons = [] } = data;
  return (
    <NtosWindow width={400} height={400}>
      <NtosWindow.Content scrollable>
        {!valid_id ? (
          <NoticeBox danger>
            No valid bank account detected. Insert a valid ID.
          </NoticeBox>
        ) : (
          <>
            <NoticeBox info>
              You can print redeemed coupons by right-clicking a photocopier.
            </NoticeBox>
            <Input
              fontSize={1.2}
              placeholder="Insert your coupon code here"
              onEnter={(value) =>
                act('redeem', {
                  code: value,
                })
              }
            />
            <Section title="Redeemed Coupons">
              {redeemed_coupons.map((coupon, index) => (
                <Box key={index} className="candystripe">
                  {coupon.goody} ({coupon.discount}% OFF)
                </Box>
              ))}
            </Section>
            <Section title="Printed Coupons">
              {printed_coupons.map((coupon, index) => (
                <Box key={index} className="candystripe">
                  {coupon.goody} ({coupon.discount}% OFF)
                </Box>
              ))}
            </Section>
          </>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
