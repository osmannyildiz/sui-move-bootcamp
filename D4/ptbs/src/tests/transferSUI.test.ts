import { SuiTransactionBlockResponse } from "@mysten/sui/client";
import { MIST_PER_SUI } from "@mysten/sui/utils";
import { ENV } from "../env";
import { getAddress } from "../helpers/getAddress";
import { parseBalanceChanges } from "../helpers/parseBalanceChanges";
import { transferSUI } from "../helpers/transferSUI";

const AMOUNT = 0.01 * Number(MIST_PER_SUI);

describe("Transfer SUI amount", () => {
  let txResponse: SuiTransactionBlockResponse;

  beforeAll(async () => {
    txResponse = await transferSUI({
      amount: AMOUNT,
      senderSecretKey: ENV.USER_SECRET_KEY,
      recipientAddress: ENV.RECIPIENT_ADDRESS,
    });
    console.log("Executed transaction with txDigest:", txResponse.digest);
  });

  test("Transaction Status", () => {
    expect(txResponse.effects).toBeDefined();
    expect(txResponse.effects!.status.status).toBe("success");
  });

  test("SUI Balance Changes", () => {
    console.log("== Balance Changes: ", txResponse.balanceChanges);
    expect(txResponse.balanceChanges).toBeDefined();
    const balanceChanges = parseBalanceChanges({
      balanceChanges: txResponse.balanceChanges!,
      senderAddress: getAddress({ secretKey: ENV.USER_SECRET_KEY }),
      recipientAddress: ENV.RECIPIENT_ADDRESS,
    });
    expect(balanceChanges.recipientSUIBalanceChange).toBe(AMOUNT);
    expect(balanceChanges.senderSUIBalanceChange).toBeLessThan(-AMOUNT);
  });
});
