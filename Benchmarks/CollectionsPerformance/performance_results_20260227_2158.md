# Performance Results
Generated on: 27/02/2026 21:58:30


## Dictionary

| Scenario | Type | Size | RTL (ms) | Dext (ms) | Ratio % |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Add | Integer | 100 | 0,0880 | 0,0601 | 68,3% |
| Add | Integer | 10000 | 4,7757 | 2,8440 | 59,6% |
| Add | Integer | 100000 | 62,2459 | 25,6475 | 41,2% |
| Lookup | Integer | 100 | 0,0055 | 0,0095 | 172,7% |
| Lookup | Integer | 10000 | 0,5817 | 1,0505 | 180,6% |
| Lookup | Integer | 100000 | 8,6346 | 7,5880 | 87,9% |

## List

| Scenario | Type | Size | RTL (ms) | Dext (ms) | Ratio % |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Add/Populate | Currency | 100 | 0,0322 | 0,0296 | 91,9% |
| Add/Populate | Currency | 10000 | 0,0904 | 0,1758 | 194,5% |
| Add/Populate | Currency | 100000 | 0,6034 | 2,3120 | 383,2% |
| Add/Populate | Integer | 100 | 0,0615 | 0,0499 | 81,1% |
| Add/Populate | Integer | 10000 | 0,1201 | 0,1192 | 99,3% |
| Add/Populate | Integer | 100000 | 0,8620 | 1,8088 | 209,8% |
| Add/Populate | Object | 100 | 0,0207 | 0,0288 | 139,1% |
| Add/Populate | Object | 10000 | 0,9167 | 0,7942 | 86,6% |
| Add/Populate | Object | 100000 | 7,1230 | 6,3200 | 88,7% |
| Add/Populate | Pointer | 100 | 0,0688 | 0,0232 | 33,7% |
| Add/Populate | Pointer | 10000 | 0,0693 | 0,1232 | 177,8% |
| Add/Populate | Pointer | 100000 | 0,4239 | 1,3026 | 307,3% |
| Add/Populate | RecordSmall | 100 | 0,0479 | 0,0275 | 57,4% |
| Add/Populate | RecordSmall | 10000 | 0,2836 | 1,0298 | 363,1% |
| Add/Populate | RecordSmall | 100000 | 4,4673 | 10,2838 | 230,2% |
| Add/Populate | String | 100 | 0,0395 | 0,0360 | 91,1% |
| Add/Populate | String | 10000 | 2,1038 | 1,3740 | 65,3% |
| Add/Populate | String | 100000 | 10,6385 | 11,5780 | 108,8% |
| IndexOf | Integer | 100 | 0,0089 | 0,0005 | 5,6% |
| IndexOf | Integer | 10000 | 0,0070 | 0,0110 | 157,1% |
| IndexOf | Integer | 100000 | 0,0734 | 0,0707 | 96,3% |
| Iteration | Currency | 100 | 0,0013 | 0,0044 | 338,5% |
| Iteration | Currency | 10000 | 0,0553 | 0,2960 | 535,3% |
| Iteration | Currency | 100000 | 0,3453 | 1,8525 | 536,5% |
| Iteration | Integer | 100 | 0,0016 | 0,0316 | 1975,0% |
| Iteration | Integer | 10000 | 0,0494 | 0,1981 | 401,0% |
| Iteration | Integer | 100000 | 0,5011 | 2,0489 | 408,9% |
| Iteration | Object | 100 | 0,0012 | 0,0027 | 225,0% |
| Iteration | Object | 10000 | 0,0639 | 0,2735 | 428,0% |
| Iteration | Object | 100000 | 0,3078 | 1,4859 | 482,7% |
| Iteration | Pointer | 100 | 0,0010 | 0,0027 | 270,0% |
| Iteration | Pointer | 10000 | 0,0488 | 0,1561 | 319,9% |
| Iteration | Pointer | 100000 | 0,3108 | 0,9788 | 314,9% |
| Iteration | RecordSmall | 100 | 0,0041 | 0,0034 | 82,9% |
| Iteration | RecordSmall | 10000 | 0,2745 | 0,2358 | 85,9% |
| Iteration | RecordSmall | 100000 | 1,6914 | 1,6556 | 97,9% |
| Iteration | String | 100 | 0,0037 | 0,0055 | 148,6% |
| Iteration | String | 10000 | 0,3867 | 0,4764 | 123,2% |
| Iteration | String | 100000 | 2,2142 | 3,2561 | 147,1% |
| Remove-First | Integer | 100 | 0,0035 | 0,0063 | 180,0% |
| Remove-First | Integer | 10000 | 6,0227 | 6,0355 | 100,2% |
| Remove-First | Integer | 100000 | 753,2801 | 642,2342 | 85,3% |
| Remove-Last | String | 100 | 0,0048 | 0,0156 | 325,0% |
| Remove-Last | String | 10000 | 0,4597 | 1,6241 | 353,3% |
| Remove-Last | String | 100000 | 3,9261 | 10,4112 | 265,2% |
| Sort | Integer | 100 | 0,0054 | 0,0511 | 946,3% |
| Sort | Integer | 10000 | 0,8190 | 1,6282 | 198,8% |
| Sort | Integer | 100000 | 9,3425 | 18,7836 | 201,1% |
| Sort | String | 100 | 0,0304 | 0,0532 | 175,0% |
| Sort | String | 10000 | 5,7125 | 6,7130 | 117,5% |
| Sort | String | 100000 | 45,3842 | 53,0252 | 116,8% |

