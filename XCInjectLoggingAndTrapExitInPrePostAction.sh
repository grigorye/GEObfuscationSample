#!/bin/sh

#  XCInjectLoggingAndTrapExitInPrePostAction.sh
#  GEObfuscationSample
#
#  Created by Grigory Entin on 02.03.2018.
#  Copyright © 2018 Grigory Entin. All rights reserved.

#  This script is a workaround for two problems with Xcode pre- and post-actions (everything below is applicable to post-actions as well, but post-actions are not mentioned for brevity):
#  1. Exit status of the pre-action is not respected, Xcode proceeds with the action even if pre-action fails.
#  2. Pre-action log is lost when running from Xcode.
#
#  After this script is sourced (see below), if pre-action fails from within Xcode, the build will be stopped, and alert with diagnostics is presented with an option to open the pre-action log.
#  If pre-action fails from xcodebuild, xcodebuild will be interrupted as well.
#
#  Usage: source this script at the beginning of pre- or post-action, passing it a user-friendly *unique* pre- or post-action name, like below:
#
#      . "${SRCROOT:?}"/XCInjectLoggingAndTrapExitInPrePostAction.sh "preTest"

phaseName="${1:?}"; shift

log="${PROJECT_TEMP_DIR:?}"/"${phaseName:?}".log

if ps -p ${PPID:?} -o comm | tail -1 | grep -e '/Xcode$'
then
	runningInXcode=true
else
	runningInXcode=false
fi

if $runningInXcode
then
	exec > "${log:?}" 2>&1
fi

trap '
if $runningInXcode
then
	osascript <<-END
		tell application "Xcode"
			-- Build is not actually stopped at this point, but blocked by this very script; we can not stop it at this point as it would kill the osascript itself.
			set reply to display alert "Build stopped: ${phaseName:?} failed" message "$0" buttons ("Open Log", "OK")
			if button returned of reply is "Open Log" then
				tell application "Finder"
					open POSIX file "${log:?}"
				end tell
			end if
			-- This should be the last script command as stopping the build means aborting pre- or post action, and this very osascript will be aborted as part of it, hence other commands will not have a chance to be executed
			tell workspace document 1
				stop
			end tell
		end tell
	END
else
	kill ${PPID:?}
fi
' ERR

