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
        <nav className="border-b border-gray-200 bg-white px-4 py-3 sm:px-6 sm:py-4">
          <div className="mx-auto flex max-w-7xl items-center justify-between">
            <a href="/hotels" className="text-base font-semibold text-gray-900 sm:text-lg">
              Denver Hotel Pricing
            </a>
            <div className="flex gap-4 text-sm text-gray-600 sm:gap-6">
              <a href="/hotels" className="hover:text-blue-600">Hotels</a>
              <a href="/events" className="hover:text-blue-600">Events</a>
              <a
                href="https://hotel-pricing-nine.vercel.app"
                target="_blank"
                rel="noopener noreferrer"
                className="hover:text-blue-600"
              >
                Live Site ↗
              </a>
            </div>
          </div>
        </nav>
        <main className="mx-auto max-w-7xl px-4 py-6 sm:px-6 sm:py-8">{children}</main>
      </body>
    </html>
  );
}
