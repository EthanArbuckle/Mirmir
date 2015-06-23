rm wingedgudda.deb || true
rm lamo_staging/Library/MobileSubstrate/DynamicLibraries/Lamo.dylib || true
rm lamo_staging/Library/MobileSubstrate/DynamicLibraries/LamoClient.dylib || true
xctool -sdk iphoneos -project Lamo.xcodeproj/ -scheme Lamo CODE_SIGNING_REQUIRED=NO
cp Builds/Lamo.dylib lamo_staging/Library/MobileSubstrate/DynamicLibraries/Lamo.dylib
cp Builds/LamoClient.dylib lamo_staging/Library/MobileSubstrate/DynamicLibraries/LamoClient.dylib
dpkg-deb -b lamo_staging/ wingedgudda.deb