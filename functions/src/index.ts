import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { generateFortune } from "./anthropic";
import { getCachedFortune, getRecentHistory, saveFortune } from "./history";

initializeApp();

const anthropicApiKey = defineSecret("ANTHROPIC_API_KEY");

/**
 * Returns today's fortune for the calling user.
 *
 * - Requires Firebase Auth (anonymous auth is fine) and a valid App Check
 *   token, so only the real myfortune app can reach this — never call the
 *   AI API directly, and never ship this key in the client.
 * - Cached per user per day in Firestore: at most one AI call per user per
 *   day, which is also the main cost control (see docs/ai-backend-setup.md).
 * - The AI is given the user's recent history so today's message builds on
 *   (and doesn't repeat) past results; the result itself becomes tomorrow's
 *   history.
 */
export const analyzeFortune = onCall(
  {
    secrets: [anthropicApiKey],
    enforceAppCheck: true,
    // Keep concurrency/memory modest — this is a short, cheap call.
    memory: "256MiB",
    timeoutSeconds: 30,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Sign-in is required.");
    }

    const db = getFirestore();

    const cached = await getCachedFortune(db, uid);
    if (cached) {
      return { ...cached, cached: true };
    }

    const history = await getRecentHistory(db, uid);

    let fortune: { text: string; category: string };
    try {
      fortune = await generateFortune(anthropicApiKey.value(), history);
    } catch (error) {
      console.error("Fortune generation failed", error);
      throw new HttpsError("internal", "Failed to generate today's fortune.");
    }

    await saveFortune(db, uid, fortune);

    return { ...fortune, cached: false };
  }
);
