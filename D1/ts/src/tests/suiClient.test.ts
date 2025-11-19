import { CoinBalance, getFullnodeUrl, SuiClient } from "@mysten/sui/client";
import { getFaucetHost, requestSuiFromFaucetV2 } from "@mysten/sui/faucet";
import { MIST_PER_SUI } from "@mysten/sui/utils";

const mistToSui = (b: CoinBalance) =>
  Number(b.totalBalance) / Number(MIST_PER_SUI);

test("SuiClient: getBalance + faucet (devnet)", async () => {
  // 1) Address to fund (must be a valid Sui address)
  const MY_ADDRESS =
    "0x56c0e9057f33f5521585eea98cc5605f2beb304590fe59e1c493149482f146c5";

  // 2) Initialize client (devnet)
  const suiClient = new SuiClient({ url: getFullnodeUrl("devnet") });

  // 3) Balance BEFORE
  const before = await suiClient.getAllBalances({
    owner: MY_ADDRESS,
  });

  // 4) Request from faucet (devnet)
  await requestSuiFromFaucetV2({
    host: getFaucetHost("devnet"),
    recipient: MY_ADDRESS,
  });

  // Wait 2 seconds before checking balance
  await new Promise((r) => setTimeout(r, 2000));
  // TODO suiClient.waitForTransaction

  // 5) Balance AFTER (no polling, just one check)
  const after = await suiClient.getAllBalances({
    owner: MY_ADDRESS,
  });

  // 6) Assert it increased
  expect(Number(after[0].totalBalance)).toBeGreaterThan(
    Number(before[0].totalBalance)
  );
  console.log(`Before: ${mistToSui(before[0])} SUI`);
  console.log(`After : ${mistToSui(after[0])} SUI`);
});
