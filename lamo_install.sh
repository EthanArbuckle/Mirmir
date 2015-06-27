#!/bin/sh

#  lamo_install.sh
#  Lamo
#
#  Created by Ethan Arbuckle on 6/23/15.
#  Copyright © 2015 CortexDevTeam. All rights reserved.

rm -rf Builds/ || true
xctool -sdk iphoneos -project Lamo.xcodeproj/ -scheme Lamo CODE_SIGNING_REQUIRED=NO owner=$1
scp Builds/Lamo.dylib root@192.168.1.122:/Library/MobileSubstrate/DynamicLibraries/Lamo.dylib
scp Builds/LamoClient.dylib root@192.168.1.122:/Library/MobileSubstrate/DynamicLibraries/LamoClient.dylib
ssh root@192.168.1.122 "killall SpringBoard"


#sleep 1
#echo 'dlopen("/Library/MobileSubstrate/DynamicLibraries/Lamo.dylib", 9)' >> inject_lamo.cy
#scp inject_lamo.cy root@192.168.1.122:inject_lamo.cy
#rm inject_lamo.cy
#ssh root@192.168.1.122 "cycript -p SpringBoard inject_lamo.cy && rm inject_lamo.cy"