[![](https://gitlab.com/grigorye/GEObfuscationSample/badges/master/pipeline.svg)](https://gitlab.com/grigorye/GEObfuscationSample/commits/master)

# GEObfuscationSample

A project built atop of task of implementing example of string obfuscation. Doesn't focus on the obfuscation details itself, rather on building a complete automated solution for verification of *any* obfuscation implementation.

## Details

   1. To make things simple, obfuscated value is [available](x-source-tag://Obfuscated-Value-Wrapper) as `ObfuscatedString`, a wrapper around `String`. The value is disposed from memory together with the wrapper.
   2. Unobfuscated value is [available](x-source-tag://withUnobfuscated) via `.withUbfuscated(allowCopy: Bool, handler: (String) -> Void) throws`. Using `false` for `allowCopy` enables [detection](x-source-tag://Copy-Violation-Detection) of attempts to make a copy of unobfuscated value.
   3. The correctness of the implementation is basically [confirmed](x-source-tag://Obfuscation-Verificaion) through observation of (un)obfuscated value in memory while and *only while* it's allowed by API.
   4. For now `NSString` is used as backing storage for both unobfuscated and obfuscated values.
   5. (Unit) tests use real process memory scanning via stringdups(1). The whole thing is fully automated and includes simple but efficient [solution](preTest) for running external tool as part of verification, based on [shell2http](https://github.com/msoap/shell2http).
   6. There's a [generic workaround](XCInjectLoggingAndTrapExitInPrePostAction.sh) for pre-/post-action failures not aborting main action/not tracked in Xcode action logs.
