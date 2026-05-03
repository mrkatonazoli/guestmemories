export const PLATFORMS = ["google", "meta", "booking", "tripadvisor"] as const;
export type Platform = (typeof PLATFORMS)[number];

export const SEGMENTS = ["family", "couple", "solo", "business", "friends", "unknown"] as const;
export type Segment = (typeof SEGMENTS)[number];
