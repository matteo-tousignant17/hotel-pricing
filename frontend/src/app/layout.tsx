import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Hotel Pricing — Denver",
  description: "Hotel pricing intelligence tool for the Denver, CO market",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-gray-50 text-gray-900 antialiased">
        <nav className="border-b border-gray-200 bg-white px-6 py-4">
          <div className="mx-auto flex max-w-7xl items-center justify-between">
            <a href="/hotels" className="text-lg font-semibold text-brand-700">
              Denver Hotel Pricing
            </a>
            <div className="flex gap-6 text-sm text-gray-600">
              <a href="/hotels" className="hover:text-blue-600">Hotels</a>
              <a href="/events" className="hover:text-blue-600">Events</a>
            </div>
          </div>
        </nav>
        <main className="mx-auto max-w-7xl px-6 py-8">{children}</main>
      </body>
    </html>
  );
}
