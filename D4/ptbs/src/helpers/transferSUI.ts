import { SuiTransactionBlockResponse } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";
import { suiClient } from "../suiClient";
import { getSigner } from "./getSigner";

interface Args {
  amount: number;
  senderSecretKey: string;
  recipientAddress: string;
}

/**
 * Transfers the specified amount of SUI from the sender secret key to the recipient address.
 * Returns the transaction response, as it is returned by the SDK.
 */
export const transferSUI = async ({
  amount,
  senderSecretKey,
  recipientAddress,
}: Args): Promise<SuiTransactionBlockResponse> => {
  const tx = new Transaction();

  // Option 1
  const [coin] = tx.splitCoins(tx.gas, [amount]);
  tx.transferObjects([coin], recipientAddress);

  // Option 2
  // const [coin] = tx.splitCoins(
  //   tx.object(
  //     "0x46b94f20fe5e28ed4ec5491c365f341376b33f75817dfbf69e11bd305e509490" // Get `gasCoinId` with CLI `sui client gas`
  //   ),
  //   [amount]
  // );

  return suiClient.signAndExecuteTransaction({
    transaction: tx,
    signer: getSigner({ secretKey: senderSecretKey }),
    options: {
      showEffects: true,
      showBalanceChanges: true,
    },
  });
};
