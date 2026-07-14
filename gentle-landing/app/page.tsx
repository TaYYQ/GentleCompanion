import dynamic from "next/dynamic";
import Hero from "@/components/Hero";
import Showcase from "@/components/Showcase";
import Features from "@/components/Features";

const Weather = dynamic(() => import("@/components/Weather"));
const Pomodoro = dynamic(() => import("@/components/Pomodoro"));
const Breathing = dynamic(() => import("@/components/Breathing"));
const GentleWall = dynamic(() => import("@/components/GentleWall"));
const Story = dynamic(() => import("@/components/Story"));
const Developer = dynamic(() => import("@/components/Developer"));
const Download = dynamic(() => import("@/components/Download"));
const Footer = dynamic(() => import("@/components/Footer"));

export default function Home() {
  return (
    <main className="overflow-hidden">
      <Hero />
      <Showcase />
      <Features />
      <Weather />
      <Pomodoro />
      <Breathing />
      <GentleWall />
      <Story />
      <Developer />
      <Download />
      <Footer />
    </main>
  );
}
