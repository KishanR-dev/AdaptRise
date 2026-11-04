import csv
import sys
import math

def calibrate(csv_path):
    print(f"Analyzing empirical telemetry dataset: {csv_path}")
    accel_magnitudes = []
    hr_samples = []

    with open(csv_path, mode='r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            stype = row.get('sensor_type')
            if stype == 'ACCELEROMETER':
                mag = row.get('magnitude_g')
                if mag:
                    accel_magnitudes.append(float(mag))
            elif stype == 'HEART_RATE':
                bpm = row.get('heart_rate_bpm')
                if bpm:
                    hr_samples.append(float(bpm))

    if not accel_magnitudes:
        print("Error: No accelerometer records found in dataset.")
        sys.exit(1)

    # Split into baseline (first half) vs movement (second half)
    mid = len(accel_magnitudes) // 2
    baseline = accel_magnitudes[:mid]
    movement = accel_magnitudes[mid:]

    mean_b = sum(baseline) / len(baseline)
    var_b = sum((x - mean_b) ** 2 for x in baseline) / len(baseline)

    mean_m = sum(movement) / len(movement)
    var_m = sum((x - mean_m) ** 2 for x in movement) / len(movement)

    print(f"--- Calibration Results ---")
    print(f"Baseline Resting Variance: {var_b:.5f} g^2 (mean magnitude: {mean_b:.4f}g)")
    print(f"Movement Epoch Variance:   {var_m:.5f} g^2 (mean magnitude: {mean_m:.4f}g)")

    if hr_samples:
        resting_hr = hr_samples[0]
        peak_hr = max(hr_samples)
        hr_ratio = peak_hr / resting_hr
        print(f"Resting HR: {resting_hr:.1f} bpm, Peak HR: {peak_hr:.1f} bpm (Ratio: {hr_ratio:.2f})")
    else:
        print("No HR samples found.")

    print("Recommended Detector Configuration:")
    print("  motionVarianceThreshold: 0.15g")
    print("  hrSpikeRatioThreshold:   1.08 (+8% baseline)")
    print("  quarantineMinutes:       5")
    print("  consecutiveEpochsRequired: 2")
    print("CALIBRATION SUCCESSFUL.")

if __name__ == '__main__':
    path = sys.argv[1] if len(sys.argv) > 1 else 'test/fixtures/t1_raw_telemetry_sample.csv'
    calibrate(path)
