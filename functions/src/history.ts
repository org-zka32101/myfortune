import { Firestore } from "firebase-admin/firestore";
import { HistoryEntry } from "./anthropic";

const HISTORY_LIMIT = 14; // how many past days feed into the AI prompt

export interface FortuneRecord {
  text: string;
  category: string;
  createdAt: FirebaseFirestore.FieldValue | FirebaseFirestore.Timestamp;
}

function fortunesCollection(db: Firestore, uid: string) {
  return db.collection("users").doc(uid).collection("fortunes");
}

/** Today's date as a stable document ID, in the server's UTC calendar day. */
export function todayDocId(): string {
  return new Date().toISOString().slice(0, 10); // YYYY-MM-DD
}

/** Returns today's cached fortune for this user, if one was already generated. */
export async function getCachedFortune(
  db: Firestore,
  uid: string
): Promise<{ text: string; category: string } | null> {
  const doc = await fortunesCollection(db, uid).doc(todayDocId()).get();
  if (!doc.exists) return null;
  const data = doc.data() as FortuneRecord;
  return { text: data.text, category: data.category };
}

/** Fetches the user's most recent fortune history for prompt context. */
export async function getRecentHistory(
  db: Firestore,
  uid: string
): Promise<HistoryEntry[]> {
  const snapshot = await fortunesCollection(db, uid)
    .orderBy("createdAt", "desc")
    .limit(HISTORY_LIMIT)
    .get();

  return snapshot.docs.map((doc) => ({
    date: doc.id,
    text: (doc.data() as FortuneRecord).text,
    category: (doc.data() as FortuneRecord).category,
  }));
}

/** Persists today's freshly generated fortune so it's cached and part of future history. */
export async function saveFortune(
  db: Firestore,
  uid: string,
  fortune: { text: string; category: string }
): Promise<void> {
  await fortunesCollection(db, uid).doc(todayDocId()).set({
    text: fortune.text,
    category: fortune.category,
    createdAt: new Date(),
  });
}
