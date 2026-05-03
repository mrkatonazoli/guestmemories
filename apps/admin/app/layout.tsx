export const metadata = {
  title: "GuestMemories Admin",
  description: "Hotel review aggregator admin",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="hu">
      <body>{children}</body>
    </html>
  );
}
