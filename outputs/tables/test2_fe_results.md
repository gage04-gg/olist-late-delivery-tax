# Test 2: Seller fixed effects

| sample            | outcome      |   estimate |     se |   ci_low |   ci_high |      p |     n |
|:------------------|:-------------|-----------:|-------:|---------:|----------:|-------:|------:|
| all single-seller | review_score |    -1.9473 | 0.0260 |  -1.9983 |   -1.8964 | 0.0000 | 93532 |
| all single-seller | low_review   |     0.5186 | 0.0071 |   0.5046 |    0.5326 | 0.0000 | 93532 |

# Dose-response (outcome review_score, reference = 1-7 days early)

| sample        | outcome      |   estimate |     se |   ci_low |   ci_high |      p |     n | bin        |
|:--------------|:-------------|-----------:|-------:|---------:|----------:|-------:|------:|:-----------|
| dose_response | review_score |     0.2920 | 0.0131 |   0.2663 |    0.3178 | 0.0000 | 93532 | bin_le_m15 |
| dose_response | review_score |     0.1606 | 0.0122 |   0.1367 |    0.1844 | 0.0000 | 93532 | bin_m14_m8 |
| dose_response | review_score |    -0.1573 | 0.0373 |  -0.2304 |   -0.0842 | 0.0000 | 93532 | bin_0      |
| dose_response | review_score |    -0.8329 | 0.0386 |  -0.9087 |   -0.7572 | 0.0000 | 93532 | bin_1_3    |
| dose_response | review_score |    -2.0028 | 0.0406 |  -2.0825 |   -1.9231 | 0.0000 | 93532 | bin_4_7    |
| dose_response | review_score |    -2.3979 | 0.0371 |  -2.4707 |   -2.3251 | 0.0000 | 93532 | bin_8_14   |
| dose_response | review_score |    -2.3491 | 0.0397 |  -2.4271 |   -2.2712 | 0.0000 | 93532 | bin_ge_15  |

# Heterogeneity (secondary)

| sample                          | outcome      |   estimate |     se |   ci_low |   ci_high |      p |     n |   z_diff |   p_diff |
|:--------------------------------|:-------------|-----------:|-------:|---------:|----------:|-------:|------:|---------:|---------:|
| North + Northeast               | review_score |    -2.0200 | 0.0519 |  -2.1219 |   -1.9181 | 0.0000 | 10055 |  -1.5612 |   0.1185 |
| South + Southeast + Centre-West | review_score |    -1.9271 | 0.0290 |  -1.9841 |   -1.8702 | 0.0000 | 82937 |  -1.5612 |   0.1185 |
| North + Northeast               | low_review   |     0.5490 | 0.0161 |   0.5174 |    0.5806 | 0.0000 | 10055 |   2.1119 |   0.0347 |
| South + Southeast + Centre-West | low_review   |     0.5110 | 0.0080 |   0.4954 |    0.5266 | 0.0000 | 82937 |   2.1119 |   0.0347 |