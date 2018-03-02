[![](https://gitlab.com/grigorye/GEObfuscationSample/badges/master/pipeline.svg)](https://gitlab.com/grigorye/GEObfuscationSample/commits/master)

# GEObfuscationSample

A project built atop of task of implementing example of string obfuscation. Doesn't focus on the obfuscation details itself, rather on building a complete automated solution for verification of *any* obfuscation implementation.

## Interesting details

   1. For now NSString is used as backing storage for both unobfuscated and obfuscated versions of "secrets".
   2. Unobfuscated version is [available](x-source-tag://withUnobfuscated) via `.withUbfuscated(allowCopy: Bool, handler: (String) -> Void) throws`. Using `false` for `allowCopy` enables detection of attempts to make a copy of unobfuscated value.
   3. (Unit) tests use real process memory scanning via stringdups(1). The whole thing is fully automated and includes simple but efficient [solution](preTest) for running external tool as part of verification, based on [shell2http](https://github.com/msoap/shell2http).
   4. There's a [generic workaround](XCInjectLoggingAndTrapExitInPrePostAction.sh) for pre-/post-action failures not aborting main action/not tracked in Xcode action logs.
