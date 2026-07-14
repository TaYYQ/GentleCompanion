import zh from "./zh";
import en from "./en";

export type Lang = "zh" | "en";
export type Translations = typeof zh;

const locales: Record<Lang, Translations> = { zh, en };

export function getTranslations(lang: Lang): Translations {
  return locales[lang] || en;
}

export const flagMap: Record<Lang, string> = {
  zh: "🇨🇳",
  en: "🇺🇸",
};
