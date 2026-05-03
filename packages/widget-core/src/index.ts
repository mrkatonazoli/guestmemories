export type WidgetTheme = {
  primaryColor: string;
  secondaryColor: string;
  fontFamily: string;
  borderRadius: number;
  mode: "light" | "dark";
};

export const defaultTheme: WidgetTheme = {
  primaryColor: "#1a73e8",
  secondaryColor: "#f1f3f4",
  fontFamily: "system-ui, sans-serif",
  borderRadius: 8,
  mode: "light",
};
