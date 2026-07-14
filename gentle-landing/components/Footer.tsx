"use client";

import { memo } from "react";
import { useLang } from "@/context/LangContext";

function Footer() {
  const { t } = useLang();

  return (
    <footer className="py-20 text-center text-white/40">
      <p className="text-lg">{t.footer.line1}</p>
      <p className="mt-2 text-sm text-white/20">{t.footer.line2}</p>
      <p className="mt-6 text-xs text-white/15">
        {t.footer.developer}
      </p>
    </footer>
  );
}

export default memo(Footer);
