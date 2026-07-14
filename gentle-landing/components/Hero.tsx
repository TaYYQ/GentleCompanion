"use client";

import { memo } from "react";
import Link from "next/link";
import { useLang } from "@/context/LangContext";
import { flagMap } from "@/locales";

function Hero() {
  const { t, lang, setLang } = useLang();

  return (
    <section className="relative h-screen flex flex-col justify-center items-center text-center px-6">
      {/* Glow blobs */}
      <div className="absolute w-[600px] h-[600px] bg-purple-500/20 blur-[140px] rounded-full top-[-120px] pointer-events-none" />
      <div className="absolute w-[500px] h-[500px] bg-blue-500/10 blur-[140px] rounded-full bottom-[-120px] pointer-events-none" />

      {/* Gentle glow pulse */}
      <div className="absolute w-[200px] h-[200px] bg-purple-400/10 blur-[80px] rounded-full top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 animate-pulse pointer-events-none" />

      {/* Language switch */}
      <button
        onClick={() => setLang(lang === "zh" ? "en" : "zh")}
        className="absolute top-8 right-8 px-4 py-2 rounded-full border border-white/10 hover:bg-white/10 transition-all text-sm text-white/60 hover:text-white/80"
      >
        {flagMap[lang === "zh" ? "en" : "zh"]} {t.langSwitch}
      </button>

      <h1 className="text-6xl md:text-7xl font-semibold tracking-tight">
        {t.hero.title}
      </h1>

      <p className="mt-6 text-xl text-white/70 max-w-xl">
        {t.hero.subtitle}
      </p>

      <p className="mt-4 text-white/40 max-w-lg">
        {t.hero.description}
      </p>

      <div className="mt-10 flex gap-4">
        <Link
          href="/download"
          className="px-6 py-3 rounded-full bg-white text-black font-medium hover:scale-105 hover:bg-gray-100 transition-all"
        >
          {t.hero.downloadBtn}
        </Link>

        <a
          href="https://github.com/TaYYQ/GentleCompanion"
          target="_blank"
          rel="noopener noreferrer"
          className="px-6 py-3 rounded-full border border-white/20 hover:bg-white/10 transition-all"
        >
          {t.hero.githubBtn}
        </a>
      </div>

      {/* Scroll hint */}
      <div className="absolute bottom-8 left-1/2 -translate-x-1/2 flex flex-col items-center gap-2 opacity-0 animate-[fadeIn_1s_ease-out_2s_forwards] pointer-events-none">
        <span className="text-white/20 text-xs tracking-widest">{t.hero.scroll}</span>
        <svg
          className="w-4 h-4 text-white/20 animate-bounce"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M19 14l-7 7m0 0l-7-7m7 7V3" />
        </svg>
      </div>
    </section>
  );
}

export default memo(Hero);
