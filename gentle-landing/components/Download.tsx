"use client";

import { memo } from "react";
import Link from "next/link";
import { useLang } from "@/context/LangContext";

function Download() {
  const { t } = useLang();

  return (
    <section className="py-32 px-6 relative">
      <div className="absolute w-[700px] h-[700px] bg-purple-500/10 blur-[160px] rounded-full left-1/2 -translate-x-1/2 top-1/2 -translate-y-1/2 pointer-events-none" />

      <div className="max-w-2xl mx-auto text-center relative z-10">
        <h2 className="text-4xl md:text-5xl font-medium mb-6">
          {t.download.title}
          <br />
          <span className="text-white/40">{t.download.titleHighlight}</span>
        </h2>

        <p className="text-white/40 text-lg mb-10">
          {t.download.description}
        </p>

        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Link
            href="/download"
            className="px-8 py-4 rounded-full bg-white text-black font-medium hover:scale-105 transition text-lg"
          >
            {t.download.downloadBtn}
          </Link>
          <a
            href="https://github.com/TaYYQ/GentleCompanion"
            target="_blank"
            rel="noopener noreferrer"
            className="px-8 py-4 rounded-full border border-white/20 hover:bg-white/10 transition text-lg text-white/60"
          >
            {t.download.githubBtn}
          </a>
        </div>

        <p className="mt-8 text-white/20 text-xs">
          {t.download.footnote}
        </p>
      </div>
    </section>
  );
}

export default memo(Download);
