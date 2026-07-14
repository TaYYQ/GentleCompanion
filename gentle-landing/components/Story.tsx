"use client";

import { memo } from "react";
import { useLang } from "@/context/LangContext";

function Story() {
  const { t } = useLang();

  return (
    <section className="py-32 px-6 text-center max-w-3xl mx-auto">
      <h2 className="text-3xl md:text-4xl font-medium">{t.story.title}</h2>

      <p className="mt-10 text-white/60 leading-relaxed text-lg">
        {t.story.paragraph1}
      </p>

      <p className="mt-6 text-white/60 leading-relaxed text-lg">
        {t.story.paragraph2}
      </p>

      <p className="mt-6 text-white/80 text-lg">
        {t.story.paragraph3}
      </p>
    </section>
  );
}

export default memo(Story);
