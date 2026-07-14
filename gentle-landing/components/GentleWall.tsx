"use client";

import { memo } from "react";
import { useLang } from "@/context/LangContext";

const emotionColors: Record<string, string> = {
  "疲惫": "bg-orange-500/10 text-orange-300/70",
  "焦虑": "bg-yellow-500/10 text-yellow-300/70",
  "孤独": "bg-blue-500/10 text-blue-300/70",
  "复杂开心": "bg-pink-500/10 text-pink-300/70",
  "丧/空": "bg-gray-500/10 text-gray-300/70",
  "压抑": "bg-red-500/10 text-red-300/70",
  "Exhausted": "bg-orange-500/10 text-orange-300/70",
  "Anxious": "bg-yellow-500/10 text-yellow-300/70",
  "Lonely": "bg-blue-500/10 text-blue-300/70",
  "Bittersweet": "bg-pink-500/10 text-pink-300/70",
  "Empty": "bg-gray-500/10 text-gray-300/70",
  "Suppressed": "bg-red-500/10 text-red-300/70",
};

function GentleWall() {
  const { t } = useLang();
  const messages = t.gentleWall.messages;

  return (
    <section className="py-32 px-6 relative">
      <div className="absolute w-[600px] h-[600px] bg-purple-500/6 blur-[140px] rounded-full left-1/2 -translate-x-1/2 top-0" />

      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-16">
          <p className="text-purple-400 text-sm tracking-widest uppercase mb-4">{t.gentleWall.badge}</p>
          <h2 className="text-3xl md:text-4xl font-medium mb-4">{t.gentleWall.title}</h2>
          <p className="text-white/40 max-w-lg mx-auto">
            {t.gentleWall.subtitle}
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {messages.map((msg, i) => (
            <div
              key={i}
              className="bg-white/[0.03] border border-white/5 rounded-2xl p-6 hover:bg-white/[0.05] hover:border-white/10 transition-all group"
            >
              <div className="flex items-center gap-2 mb-3">
                <span
                  className={`px-2.5 py-0.5 rounded-full text-[11px] ${emotionColors[msg.emotion] || "bg-white/10 text-white/50"}`}
                >
                  {msg.emotion}
                </span>
              </div>
              <p className="text-white/60 text-sm leading-relaxed mb-4">
                &ldquo;{msg.text}&rdquo;
              </p>
              <div className="flex items-center gap-2 text-white/20 text-xs">
                <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5}
                    d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12z" />
                </svg>
                <span>{msg.likes}</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export default memo(GentleWall);
