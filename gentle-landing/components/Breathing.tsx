"use client";

import { memo } from "react";
import { useLang } from "@/context/LangContext";

function Breathing() {
  const { t } = useLang();

  return (
    <section className="py-24 px-6">
      <div className="max-w-6xl mx-auto flex flex-col lg:flex-row items-center gap-16">
        {/* Mockup */}
        <div className="flex-1 flex justify-center">
          <div className="w-[320px] aspect-square rounded-[32px] bg-[#0a0a1a] border border-white/10 flex items-center justify-center relative overflow-hidden">
            <div className="absolute inset-0 opacity-20"
              style={{
                backgroundImage:
                  "radial-gradient(circle at 50% 50%, rgba(139,92,246,0.3) 0%, transparent 50%)",
              }}
            />
            <div className="relative z-10 text-center">
              <div className="w-24 h-24 rounded-full bg-gradient-to-br from-purple-500/40 via-blue-500/30 to-pink-500/20 blur-md mx-auto animate-pulse"
                style={{ animationDuration: "4s" }} />
              <p className="mt-6 text-white/60 text-sm tracking-wider">{t.breathing.inhale}</p>
              <div className="flex justify-center gap-1 mt-3">
                {["●", "●", "○", "○"].map((d, i) => (
                  <span key={i} className={d === "●" ? "text-purple-400" : "text-white/10"}>{d}</span>
                ))}
              </div>
              <p className="mt-2 text-white/20 text-xs">{t.breathing.method}</p>
            </div>
          </div>
        </div>

        {/* Text */}
        <div className="flex-1">
          <p className="text-purple-400 text-sm tracking-widest uppercase mb-4">{t.breathing.badge}</p>
          <h2 className="text-3xl md:text-4xl font-medium mb-6">
            {t.breathing.title}
          </h2>
          <p className="text-white/50 leading-relaxed text-lg mb-8">
            {t.breathing.description}
          </p>
          <div className="flex gap-8 text-sm text-white/30">
            {t.breathing.stats.map((s) => (
              <div key={s.label}><span className="text-purple-400 text-2xl font-medium block">{s.value}</span>{s.label}</div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

export default memo(Breathing);
