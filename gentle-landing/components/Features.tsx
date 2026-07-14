"use client";

import { memo } from "react";
import { useLang } from "@/context/LangContext";

const featureEmojis = ["☁️", "🍅", "🫁", "🎮", "💬", "🤝"];

function Features() {
  const { t } = useLang();
  const features = t.features.items;

  return (
    <section className="py-32 px-6">
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-20">
          <p className="text-purple-400 text-sm tracking-widest uppercase mb-4">
            {t.features.badge}
          </p>
          <h2 className="text-4xl md:text-5xl font-medium">
            {t.features.title}
            <br />
            <span className="text-white/50">{t.features.titleHighlight}</span>
          </h2>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-px bg-white/5 rounded-2xl overflow-hidden">
          {features.map((f, i) => (
            <div
              key={i}
              className="bg-[#0d1117] p-8 hover:bg-white/[0.03] transition-colors group"
            >
              <div className="text-3xl mb-4">
                {featureEmojis[i]}
              </div>
              <h3 className="text-lg font-medium mb-2 group-hover:text-white/90 transition">
                {f.title}
              </h3>
              <p className="text-white/40 text-sm leading-relaxed">{f.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export default memo(Features);
