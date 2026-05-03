export const metadata = {
  title: "GuestMemories Widget",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="hu">
      <body style={{ margin: 0 }}>{children}</body>
    </html>
  );
}
