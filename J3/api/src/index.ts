import express, { Request, Response } from "express";
import { Transaction } from "@mysten/sui/transactions";
import { fromBase64, isValidSuiAddress, toBase64 } from "@mysten/sui/utils";
import dotenv from "dotenv";
import { SuiClient } from "@mysten/sui/client";
import { getAdminSigner } from "./getAdminSigner";
import axios, { AxiosError } from "axios";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

const suiClient = new SuiClient({
  url: process.env.SUI_NETWORK!,
});
app.use(express.json());

/**
 * GET /health endpoint for checking if the api is running and if the .env variables are parsed.
 */
app.get("/", (req: Request, res: Response) => {
  res.status(200).json({
    SUI_NETWORK: process.env.SUI_NETWORK,
    PACKAGE_ID: process.env.PACKAGE_ID,
    status: "ok",
  });
});

/**
 * POST /mint endpoint for minting a Hero NFT
 */
app.post("/mint", async (req: Request, res: Response) => {
  // dummy validation of the recipient address
  const { address } = req.body;
  if (!address) {
    res.status(400).send({
      message: "Missing address",
    });
    return;
  }
  if (!isValidSuiAddress(address)) {
    res.status(400).send({
      message: "Invalid format of address",
    });
    return;
  }

  // create and populate the tx with commands
  const tx = new Transaction();
  const hero = tx.moveCall({
    target: `${process.env.PACKAGE_ID}::hero::mint`,
    arguments: [
      // randomly throw errors to have real-world monitoring outputs
      Math.random() < 0.5 ? tx.pure.u64(4) : tx.pure.string("Name"),
      tx.object(process.env.HEROES_REGISTRY_ID!),
    ],
  });
  tx.transferObjects([hero], address);

  // build the transaction bytes
  // return error if it fails
  let txBytes: Uint8Array | null = null;
  try {
    if (Math.random() < 0.4) {
      throw Error("Mock error in building transaction");
    }
    txBytes = await tx.build({
      client: suiClient,
      onlyTransactionKind: true,
    });
  } catch (error) {
    res.status(500).send({
      message: `Error building transaction for ${address}`,
      error: (error as Error).message,
    });
    return;
  }

  // create the sponsored transactio instance using Enoki API
  // return error if it fails
  let { bytes, digest } = { bytes: "", digest: "" };
  try {
    const createResponse = await axios.post(
      "https://api.enoki.mystenlabs.com/v1/transaction-blocks/sponsor",
      {
        network: process.env.SUI_NETWORK_NAME,
        transactionBlockKindBytes: toBase64(txBytes),
        sender: process.env.ADMIN_ADDRESS!,
        allowedAddresses: [address],
        allowedMoveCallTargets: [`${process.env.PACKAGE_ID}::hero::mint`],
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.ENOKI_SECRET_KEY}`,
        },
      }
    );
    let data = createResponse.data.data;
    bytes = data.bytes;
    digest = data.digest;
  } catch (error) {
    const err = (error as AxiosError).response?.data;
    res.status(400).send({
      message: `Error creating sponsored transaction for ${address}`,
      error: err,
    });
    return;
  }

  // sign the sponsored bytes
  // return error if it fails
  let signature = "";
  try {
    if (Math.random() < 0.4) {
      throw Error("Mock error in signing sponsored bytes");
    }
    const signer = getAdminSigner();
    let signResult = await signer.signTransaction(fromBase64(bytes));
    signature = signResult.signature;
  } catch (err) {
    res.status(500).send({
      message: `Error signing transaction bytes for ${address}`,
      error: (err as Error).message,
    });
    return;
  }

  // execute the sponsored-signed bytes
  // return the minting txDigest if it succeeds
  // return error if it fails
  try {
    const executeResponse = await axios.post(
      `https://api.enoki.mystenlabs.com/v1/transaction-blocks/sponsor/${digest}`,
      {
        signature,
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.ENOKI_SECRET_KEY}`,
        },
      }
    );
    res.status(200).send({
      message: "Hero minted successfully",
      digest: executeResponse.data.data.digest,
    });
    return;
  } catch (error) {
    const err = (error as AxiosError).response?.data;
    res.status(400).send({
      message: `Error executing sponsored transaction for ${address}`,
      error: err,
    });
  }
});

app.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
});
