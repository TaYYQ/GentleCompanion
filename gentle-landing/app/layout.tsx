import type { Metadata } from "next";
import "./globals.css";
import { LangProvider } from "@/context/LangContext";

export const metadata: Metadata = {
  title: "GentleCompanion — A Calm Space for Your Mind | 为心灵留一处安静",
  description:
    "A macOS app that doesn't push you to be productive — it simply stays with you until things feel lighter. | 一款不催促你的 macOS 应用，只是安静地陪着你。",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <LangProvider>{children}</LangProvider>
      </body>
    </html>
  );
}
