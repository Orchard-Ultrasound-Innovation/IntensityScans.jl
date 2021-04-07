scope = initialize(TcpInstruments.FakeDSOX4034A)
lts = initialize(ThorlabsLTStage.FakeLTS)

scanner = IntensityScan(
    xyz = lts,
    scope = scope,
    channel = 1,
    precapture_delay = 0u"µs",
    sample_size =TcpInstruments.num_samples(scope)
)

wave_x = scan_x(scanner, [0u"m", 100u"mm"], 5)
wave_xy = scan_xy(scanner, [0u"m", 0.1u"m"], 5, [0u"mm", 0.1u"m"], 7)
wave_xyz = scan_xyz(scanner, [0u"m", 0.1u"m"], 3, [0u"m", 0.1u"m"], 3, [0u"m", 0.1u"m"], 3)

params = ScanParameters(
    medium = Medium(),
    excitation = Excitation(),
    f0 = 15e6,
    hydrophone_id = :Onda_HGL0200_2322,
    preamp_id = :Onda_AH2020_1238_20dB,
)

metrics_x = compute_metrics(wave_x, params)
metrics_xy = compute_metrics(wave_xy, params)
metrics_xyz = compute_metrics(wave_xyz, params)
