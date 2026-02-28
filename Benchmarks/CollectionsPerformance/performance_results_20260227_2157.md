# Performance Results
Generated on: 27/02/2026 21:57:28


## Dictionary

| Scenario | Type | Size | RTL (ms) | Dext (ms) | Ratio % |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Add | Integer | 100 | 0,0898 | 0,0784 | 87,3% |
| Add | Integer | 10000 | 5,1556 | 2,8093 | 54,5% |
| Add | Integer | 100000 | 60,2173 | 37,7753 | 62,7% |
| Lookup | Integer | 100 | 0,0055 | 0,0133 | 241,8% |
| Lookup | Integer | 10000 | 0,9188 | 1,0505 | 114,3% |
| Lookup | Integer | 100000 | 9,6087 | 8,6068 | 89,6% |

## List

| Scenario | Type | Size | RTL (ms) | Dext (ms) | Ratio % |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Add/Populate | Integer | 100 | 0,0621 | 0,0586 | 94,4% |
| Add/Populate | Currency | 100 | 0,0331 | 0,0240 | 72,5% |
| Add/Populate | RecordSmall | 100 | 0,0362 | 0,0208 | 57,5% |
| Add/Populate | Object | 100 | 0,0240 | 0,0221 | 92,1% |
| Add/Populate | String | 100 | 0,0424 | 0,0302 | 71,2% |
| Add/Populate | Pointer | 100 | 0,0478 | 0,0205 | 42,9% |
| Add/Populate | Integer | 10000 | 0,1075 | 0,1369 | 127,3% |
| Add/Populate | Object | 10000 | 0,9269 | 0,8161 | 88,0% |
| Add/Populate | Pointer | 10000 | 0,1068 | 0,1179 | 110,4% |
| Add/Populate | Currency | 10000 | 0,0906 | 0,1605 | 177,2% |
| Add/Populate | RecordSmall | 10000 | 0,2842 | 1,0837 | 381,3% |
| Add/Populate | String | 10000 | 1,2462 | 1,3015 | 104,4% |
| Add/Populate | Pointer | 100000 | 0,4761 | 1,1892 | 249,8% |
| Add/Populate | String | 100000 | 10,9472 | 18,8226 | 171,9% |
| Add/Populate | Object | 100000 | 6,8317 | 6,1471 | 90,0% |
| Add/Populate | Integer | 100000 | 0,7085 | 2,0816 | 293,8% |
| Add/Populate | Currency | 100000 | 0,5686 | 2,2854 | 401,9% |
| Add/Populate | RecordSmall | 100000 | 4,3562 | 10,1190 | 232,3% |
| IndexOf | Integer | 100 | 0,0090 | 0,0006 | 6,7% |
| IndexOf | Integer | 10000 | 0,0069 | 0,0110 | 159,4% |
| IndexOf | Integer | 100000 | 0,0683 | 0,1137 | 166,5% |
| Iteration | Object | 100 | 0,0010 | 0,0026 | 260,0% |
| Iteration | String | 100 | 0,0035 | 0,0053 | 151,4% |
| Iteration | RecordSmall | 100 | 0,0028 | 0,0031 | 110,7% |
| Iteration | Currency | 100 | 0,0010 | 0,0038 | 380,0% |
| Iteration | Integer | 100 | 0,0019 | 0,0373 | 1963,2% |
| Iteration | Pointer | 100 | 0,0009 | 0,0028 | 311,1% |
| Iteration | Pointer | 10000 | 0,0499 | 0,1703 | 341,3% |
| Iteration | Object | 10000 | 0,0490 | 0,1767 | 360,6% |
| Iteration | Integer | 10000 | 0,0465 | 0,1994 | 428,8% |
| Iteration | String | 10000 | 0,3327 | 0,4784 | 143,8% |
| Iteration | RecordSmall | 10000 | 0,2587 | 0,2551 | 98,6% |
| Iteration | Currency | 10000 | 0,0552 | 0,2956 | 535,5% |
| Iteration | RecordSmall | 100000 | 1,6625 | 1,5253 | 91,7% |
| Iteration | Object | 100000 | 0,3042 | 1,0940 | 359,6% |
| Iteration | String | 100000 | 2,9308 | 4,0207 | 137,2% |
| Iteration | Integer | 100000 | 0,4858 | 1,6178 | 333,0% |
| Iteration | Currency | 100000 | 0,3428 | 1,8937 | 552,4% |
| Iteration | Pointer | 100000 | 0,3018 | 1,1332 | 375,5% |
| Remove-First | Integer | 100 | 0,0035 | 0,0068 | 194,3% |
| Remove-First | Integer | 10000 | 5,8983 | 5,7746 | 97,9% |
| Remove-First | Integer | 100000 | 636,5001 | 720,5759 | 113,2% |
| Remove-Last | String | 100 | 0,0045 | 0,0145 | 322,2% |
| Remove-Last | String | 10000 | 0,4467 | 1,5010 | 336,0% |
| Remove-Last | String | 100000 | 6,2134 | 10,8667 | 174,9% |
| Sort | String | 100 | 0,0287 | 0,0467 | 162,7% |
| Sort | Integer | 100 | 0,0055 | 0,0509 | 925,5% |
| Sort | Integer | 10000 | 0,7429 | 1,6712 | 225,0% |
| Sort | String | 10000 | 5,4925 | 6,4162 | 116,8% |
| Sort | Integer | 100000 | 9,8320 | 21,8359 | 222,1% |
| Sort | String | 100000 | 69,9276 | 51,5965 | 73,8% |

