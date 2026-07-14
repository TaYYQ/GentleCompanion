"use client";

import { memo } from "react";
import { useLang } from "@/context/LangContext";

const philosophyEmojis = ["🌱", "🤲", "✨"];

function Developer() {
  const { t } = useLang();

  return (
    <section className="py-32 px-6 relative">
      {/* Background glow */}
      <div className="absolute w-[500px] h-[500px] bg-purple-500/8 blur-[140px] rounded-full right-[-150px] top-0" />
      <div className="absolute w-[400px] h-[400px] bg-blue-500/6 blur-[120px] rounded-full left-[-100px] bottom-0" />

      <div className="max-w-4xl mx-auto relative z-10">
        <div className="text-center mb-16">
          <p className="text-purple-400 text-sm tracking-widest uppercase mb-4">
            {t.developer.badge}
          </p>
          <h2 className="text-3xl md:text-4xl font-medium">
            {t.developer.title}
          </h2>
        </div>

        {/* Developer Card */}
        <div className="bg-white/[0.03] border border-white/10 rounded-3xl p-10 md:p-16 backdrop-blur-sm">
          <div className="flex flex-col md:flex-row items-center gap-10">
            {/* Avatar */}
            <div className="shrink-0">
              <div className="w-32 h-32 rounded-full border-2 border-white/10 overflow-hidden ring-2 ring-purple-500/20">
                <img
                  src="/doxiang.JPG"
                  alt="张天成"
                  className="w-full h-full object-cover"
                />
              </div>
            </div>

            {/* Info */}
            <div className="flex-1 text-center md:text-left">
              <h3 className="text-2xl md:text-3xl font-medium mb-2">
                {t.developer.name}
              </h3>
              <p className="text-white/40 text-sm mb-6">{t.developer.role}</p>

              <p className="text-white/60 leading-relaxed text-base mb-8 max-w-xl">
                {t.developer.bio}
              </p>

              {/* Tech stack */}
              <div className="flex flex-wrap gap-2 justify-center md:justify-start">
                {t.developer.tags.map((tag) => (
                  <span
                    key={tag}
                    className="px-3 py-1 rounded-full bg-white/5 border border-white/10 text-xs text-white/50"
                  >
                    {tag}
                  </span>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Philosophy */}
        <div className="mt-10 grid grid-cols-1 md:grid-cols-3 gap-4">
          {t.developer.philosophy.map((item, i) => (
            <div
              key={i}
              className="bg-white/[0.02] border border-white/5 rounded-2xl p-6 text-center hover:bg-white/[0.04] transition-colors"
            >
              <div className="text-2xl mb-3">{philosophyEmojis[i]}</div>
              <h4 className="text-white/80 font-medium mb-2">{item.title}</h4>
              <p className="text-white/40 text-sm leading-relaxed">{item.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export default memo(Developer);
