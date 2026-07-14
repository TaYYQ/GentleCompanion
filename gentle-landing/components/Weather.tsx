"use client";

import { memo } from "react";
import { useLang } from "@/context/LangContext";

function Weather() {
  const { t } = useLang();

  return (
    <section className="py-24 px-6 relative">
      <div className="absolute w-[500px] h-[500px] bg-blue-500/8 blur-[120px] rounded-full left-[-150px] bottom-0" />

      <div className="max-w-6xl mx-auto flex flex-col lg:flex-row-reverse items-center gap-16">
        {/* Mockup */}
        <div className="flex-1 flex justify-center">
          <div className="w-[320px] rounded-[32px] bg-gradient-to-b from-[#FFFBEB] via-[#FEF3C7] to-[#FDE68A] border border-orange-200/30 p-8 text-center overflow-hidden relative">
            <div className="absolute top-6 right-8 w-16 h-16 rounded-full bg-orange-400/20 blur-xl" />
            <div className="relative z-10">
              <div className="text-5xl mb-3 drop-shadow-sm">☀️</div>
              <p className="text-4xl font-thin text-gray-800 mb-1 tabular-nums">23°</p>
              <p className="text-sm text-gray-500 mb-6">{t.weather.mockCity}</p>
              <div className="flex justify-center gap-6 text-xs text-gray-500 mb-6">
                <span>💧 55%</span>
                <span>💨 8.5 km/h</span>
              </div>
              <div className="bg-white/60 backdrop-blur-sm rounded-2xl p-4 text-sm text-gray-600 leading-relaxed">
                &ldquo;{t.weather.mockMessage}&rdquo;
              </div>
            </div>
          </div>
        </div>

        {/* Text */}
        <div className="flex-1">
          <p className="text-blue-400 text-sm tracking-widest uppercase mb-4">{t.weather.badge}</p>
          <h2 className="text-3xl md:text-4xl font-medium mb-6">
            {t.weather.title}
          </h2>
          <p className="text-white/50 leading-relaxed text-lg mb-8">
            {t.weather.description}
          </p>
          <div className="flex gap-3 flex-wrap">
            {t.weather.tags.map((e) => (
              <span key={e} className="px-3 py-1 rounded-full bg-blue-500/10 text-xs text-blue-300/70">
                {e}
              </span>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

export default memo(Weather);
