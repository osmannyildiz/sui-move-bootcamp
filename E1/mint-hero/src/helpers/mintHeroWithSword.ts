import { SuiTransactionBlockResponse } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";
import { ENV } from "../env";
import { suiClient } from "../suiClient";
import { getAddress } from "./getAddress";
import { getSigner } from "./getSigner";

/**
 * Builds, signs, and executes a transaction for:
 * * minting a Hero NFT: use the `package_id::hero::mint_hero` function
 * * minting a Sword NFT: use the `package_id::blacksmith::new_sword` function
 * * attaching the Sword to the Hero: use the `package_id::hero::equip_sword` function
 * * transferring the Hero to the signer
 */
export const mintHeroWithSword =
  async (): Promise<SuiTransactionBlockResponse> => {
    const signer = getSigner({ secretKey: ENV.USER_SECRET_KEY });
    const signerAddress = getAddress({ secretKey: ENV.USER_SECRET_KEY });

    const tx = new Transaction();

    const hero = tx.moveCall({
      target: `${ENV.PACKAGE_ID}::hero::mint_hero`,
    });

    const sword = tx.moveCall({
      target: `${ENV.PACKAGE_ID}::blacksmith::new_sword`,
      arguments: [tx.pure.u64(10)],
    });

    tx.moveCall({
      target: `${ENV.PACKAGE_ID}::hero::equip_sword`,
      arguments: [hero, sword],
    });

    tx.transferObjects([hero], signerAddress);

    return suiClient.signAndExecuteTransaction({
      transaction: tx,
      signer,
      options: {
        showEffects: true,
        showObjectChanges: true,
      },
    });
  };
