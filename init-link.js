// init-link.js
const { GoogleAuth } = require("google-auth-library");
const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));
const path = require("path");

const keyFile = path.join(__dirname, "service-account.json");

const endpoint = "https://us-central1-clioapp-1dc1f.cloudfunctions.net/ext-firebase-flow-links-initialize";

// 🔁 Replace with your actual shareID value stored in Firestore
const shareID = "QvB9wWLpNn";  // e.g., from list doc

async function main() {
  const auth = new GoogleAuth({
    keyFile,
    scopes: ["https://www.googleapis.com/auth/cloud-platform"]
  });
  const client = await auth.getClient();
  const accessToken = await client.getAccessToken();

  const body = {
    data: {
      shareID: shareID,
      platform: "ios",
      bundleId: "Vivien-Quach.Clio",
      domainUriPrefix: "https://clioapp-1dc1f-flowlinks-v2.web.app",
      title: "Open this reading list in Clio",
      description: "A curated set of books to match your mood or moment.",
      imageURL: "https://clioapp-1dc1f-flowlinks-v2.web.app/images/thumb.jpg"
    }
  };

  const res = await fetch(endpoint, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken.token || accessToken}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(body)
  });

  const text = await res.text();
  if (!res.ok) {
    console.error("❌ FlowLink Error:", text);
  } else {
    try {
      const json = JSON.parse(text);
      console.log("✅ Success:", json);
    } catch {
      console.log("⚠️ Raw response wasn't JSON:", text);
    }
  }
}

main().catch(console.error);