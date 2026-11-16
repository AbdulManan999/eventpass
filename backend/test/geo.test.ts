import { describe, expect, it } from 'vitest';
import { distanceMeters } from '../src/lib/geo.js';

describe('distanceMeters', () => {
  it('is zero for the same point', () => {
    expect(distanceMeters(31.4757, 74.3424, 31.4757, 74.3424)).toBe(0);
  });

  it('matches known distances', () => {
    // 0.001 degrees of latitude is about 111 m everywhere.
    expect(distanceMeters(31.4757, 74.3424, 31.4767, 74.3424)).toBeCloseTo(111.2, 0);
    // Lahore to Islamabad is about 270 km in a straight line.
    expect(distanceMeters(31.5204, 74.3587, 33.6844, 73.0479) / 1000).toBeCloseTo(270, -1);
  });
});
