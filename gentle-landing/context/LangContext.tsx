"use client";

import { createContext, useContext, useState, useEffect, useCallback, useMemo, ReactNode } from "react";
import { Lang, Translations, getTranslations } from "@/locales";

interface LangContextType {
  lang: Lang;
  setLang: (lang: Lang) => void;
  t: Translations;
}

const LangContext = createContext<LangContextType>({
  lang: "en",
  setLang: () => {},
  t: getTranslations("en"),
});

export function LangProvider({ children }: { children: ReactNode }) {
  const [lang, setLang] = useState<Lang>("en");

  useEffect(() => {
    const saved = localStorage.getItem("gentle-lang") as Lang | null;
    if (saved === "zh" || saved === "en") setLang(saved);
  }, []);

  const handleSetLang = useCallback((l: Lang) => {
    setLang(l);
    localStorage.setItem("gentle-lang", l);
  }, []);

  const t = useMemo(() => getTranslations(lang), [lang]);

  const value = useMemo(
    () => ({ lang, setLang: handleSetLang, t }),
    [lang, handleSetLang, t]
  );

  return (
    <LangContext.Provider value={value}>
      {children}
    </LangContext.Provider>
  );
}

export function useLang() {
  return useContext(LangContext);
}
