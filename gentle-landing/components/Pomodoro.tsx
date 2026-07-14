"use client";

import { memo } from "react";
import { useLang } from "@/context/LangContext";

function Pomodoro() {
  const { t } = useLang();

  return (
    <section className="py-24 px-6 relative">
      <div className="absolute w-[400px] h-[400px] bg-orange-500/8 blur-[120px] rounded-full right-[-100px] top-0" />

      <div className="max-w-6xl mx-auto flex flex-col lg:flex-row items-center gap-16">
        {/* Mockup */}
        <div className="flex-1 flex justify-center">
          <div className="w-[320px] aspect-square rounded-[32px] bg-gradient-to-br from-purple-500/20 via-pink-500/10 to-orange-500/10 border border-white/10 backdrop-blur-xl flex flex-col items-center justify-center gap-4 relative overflow-hidden">
            <div className="absolute inset-0 bg-gradient-to-b from-white/[0.04] to-transparent" />
            <div className="relative z-10 w-40 h-40 rounded-full border-4 border-transparent bg-gradient-to-br from-purple-400 via-pink-400 to-orange-400 flex items-center justify-center"
              style={{ backgroundClip: "padding-box" }}>
              <div className="w-full h-full rounded-full border-[3px] border-white/20 flex items-center justify-center backdrop-blur-sm">
                <span className="text-3xl font-light text-white/80 tabular-nums">25:00</span>
              </div>
            </div>
            <div className="relative z-10 flex gap-3">
              <span className="px-4 py-1.5 rounded-full bg-white/10 text-xs text-white/60">15 min</span>
              <span className="px-4 py-1.5 rounded-full bg-white/20 text-xs text-white">25 min</span>
              <span className="px-4 py-1.5 rounded-full bg-white/10 text-xs text-white/60">45 min</span>
            </div>
            <div className="relative z-10 flex gap-2 mt-2">
              {t.pomodoro.quickIntents.map((s) => (
                <span key={s} className="px-3 py-1 rounded-full bg-white/5 text-[10px] text-white/40">
                  {s}
                </span>
              ))}
            </div>
          </div>
        </div>

        {/* Text */}
        <div className="flex-1">
          <p className="text-orange-400 text-sm tracking-widest uppercase mb-4">{t.pomodoro.badge}</p>
          <h2 className="text-3xl md:text-4xl font-medium mb-6">
            {t.pomodoro.title}
          </h2>
          <p className="text-white/50 leading-relaxed text-lg mb-8">
            {t.pomodoro.description}
          </p>
          <div className="flex gap-8 text-sm text-white/30">
            {t.pomodoro.stats.map((s) => (
              <div key={s.label}><span className="text-white/60 text-2xl font-medium block">{s.value}</span>{s.label}</div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

export default memo(Pomodoro);
