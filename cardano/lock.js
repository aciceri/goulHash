// import { mConStr0 } from "@meshsdk/common";
// import { deserializeAddress } from "@meshsdk/core";
// import {
//   getTxBuilder,
//     beneficiary_wallet,
//     owner_wallet,
//   scriptAddr,
// } from "./common.js";

// async function depositFundTx(amount, lockUntilTimeStampMs) {
//   const utxos = await owner_wallet.getUtxos();
//   const { pubKeyHash: ownerPubKeyHash } = deserializeAddress(
//     owner_wallet.addresses.baseAddressBech32
//   );

//   await beneficiary_wallet.getUtxos();
//   const { pubKeyHash: beneficiaryPubKeyHash } = deserializeAddress(
//     beneficiary_wallet.addresses.baseAddressBech32
//   );
//   const txBuilder = getTxBuilder();
//   await txBuilder
//     .changeAddress(owner_wallet.addresses.baseAddressBech32)
//         .selectUtxosFrom(utxos)
//             .txOut(scriptAddr, amount, {
//             plutusData: mConStr0([10])
//         })

//     .complete();
//   return txBuilder.txHex;
// }

// async function main() {
//   const assets = [
//     {
//       unit: "lovelace",
//       quantity: "3000000", // amount to lock
//     },
//   ];

//   const lockUntilTimeStamp = new Date();
//   lockUntilTimeStamp.setMinutes(lockUntilTimeStamp.getMinutes() + 10); // you have 10 minutes to withdraw from the contract

//     const unsignedTx = await depositFundTx(assets, lockUntilTimeStamp.getTime());

//   const signedTx = await owner_wallet.signTx(unsignedTx);
//   const txHash = await owner_wallet.submitTx(signedTx);

//   //Copy this txHash. You will need this hash in vesting_unlock.mjs
//   console.log("txHash", txHash);
// }

// main();

import { mConStr0 } from "@meshsdk/common";
import { deserializeAddress } from "@meshsdk/core";
import {
  getTxBuilder,
  owner_wallet,
  beneficiary_wallet,
  scriptAddr,
} from "./common.js";

async function depositFundTx(amount, lockUntilTimeStampMs) {
  const utxos = await owner_wallet.getUtxos();
  // const { pubKeyHash: ownerPubKeyHash } = deserializeAddress(
  //   owner_wallet.addresses.baseAddressBech32
  // );

  // const { pubKeyHash: beneficiaryPubKeyHash } = deserializeAddress(
  //   beneficiary_wallet.addresses.baseAddressBech32
  // );

  const txBuilder = getTxBuilder();
  await txBuilder
    .txOut(scriptAddr, amount)
    .txOutInlineDatumValue(mConStr0([]))
    .changeAddress(owner_wallet.addresses.baseAddressBech32)
    .selectUtxosFrom(utxos)
    .complete();
  return txBuilder.txHex;
}

async function main() {
  const assets = [
    {
      unit: "lovelace",
      quantity: "3000000",
    },
  ];

  const lockUntilTimeStamp = new Date();
  lockUntilTimeStamp.setMinutes(lockUntilTimeStamp.getMinutes() + 10);

  const unsignedTx = await depositFundTx(assets, lockUntilTimeStamp.getTime());

  const signedTx = await owner_wallet.signTx(unsignedTx);
  const txHash = await owner_wallet.submitTx(signedTx);

  //Copy this txHash. You will need this hash in vesting_unlock.mjs
  console.log("txHash", txHash);
}

main();
