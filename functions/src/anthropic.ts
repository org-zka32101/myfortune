/**
 * Minimal Anthropic Messages API client. Deliberately dependency-free (uses
 * the Node 20 runtime's built-in fetch) so the deployed function bundle
 * stays small.
 */

const ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages";
const ANTHROPIC_VERSION = "2023-06-01";

// Cheap, fast model — good enough for a short daily-fortune message and
// keeps per-call cost low. Revisit if generation quality needs improving.
const MODEL = "claude-haiku-4-5-20251001";

export interface HistoryEntry {
  date: string;
  text: string;
  category: string;
}

/**
 * Asks Claude for today's fortune message, informed by the user's recent
 * history so it can vary tone/theme instead of repeating itself.
 */
export async function generateFortune(
  apiKey: string,
  history: HistoryEntry[]
): Promise<{ text: string; category: string }> {
  const prompt = buildPrompt(history);

  const response = await fetch(ANTHROPIC_API_URL, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": ANTHROPIC_VERSION,
    },
    body: JSON.stringify({
      model: MODEL,
      max_tokens: 300,
      messages: [{ role: "user", content: prompt }],
    }),
  });

  if (!response.ok) {
    const body = await response.text().catch(() => "");
    throw new Error(`Anthropic API error ${response.status}: ${body}`);
  }

  const data = (await response.json()) as {
    content: Array<{ type: string; text?: string }>;
  };

  const raw = data.content.find((block) => block.type === "text")?.text ?? "";
  return parseFortuneResponse(raw);
}

function buildPrompt(history: HistoryEntry[]): string {
  const historyBlock =
    history.length === 0
      ? "(過去の記録はまだありません。これが最初の占いです。)"
      : history
          .map((h) => `- ${h.date} [${h.category}] ${h.text}`)
          .join("\n");

  return [
    "あなたは前向きで温かい占い師です。ユーザーの過去の占い結果の履歴を踏まえて、",
    "今日だけの新しい占いメッセージを日本語で1つ生成してください。",
    "過去の履歴と似た内容の繰り返しは避け、その日らしい新鮮なメッセージにしてください。",
    "",
    "## 過去の占い履歴(新しい順)",
    historyBlock,
    "",
    "## 出力形式",
    "以下のJSON形式のみを出力してください。説明文やコードブロック記法は不要です。",
    '{"text": "占いメッセージ本文(80文字程度)", "category": "カテゴリ名(例: 恋愛, 仕事, 健康, 総合)"}',
  ].join("\n");
}

function parseFortuneResponse(raw: string): { text: string; category: string } {
  try {
    const parsed = JSON.parse(raw.trim());
    if (typeof parsed.text === "string" && typeof parsed.category === "string") {
      return { text: parsed.text, category: parsed.category };
    }
  } catch {
    // fall through to fallback below
  }

  // If the model didn't return clean JSON, still give the user something
  // rather than failing the whole request.
  return { text: raw.trim() || "今日も良い一日になりますように。", category: "総合" };
}
