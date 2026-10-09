#!/bin/bash

# AdMob設定スクリプト
# .envファイルからAdMob App IDを読み込んで各プラットフォームに設定

# .envファイルの存在確認
if [ ! -f .env ]; then
    echo "Error: .env file not found"
    exit 1
fi

# .envファイルから値を読み込み
source .env

# iOS設定
if [ ! -z "$ADMOB_APP_ID_IOS" ]; then
    echo "Setting iOS AdMob App ID..."
    # Info.plistの更新（実際のIDで置換）
    sed -i '' "s/\$(ADMOB_APP_ID)/$ADMOB_APP_ID_IOS/g" ios/Runner/Info.plist
    echo "iOS configuration updated"
fi

# Android設定
if [ ! -z "$ADMOB_APP_ID_ANDROID" ]; then
    echo "Setting Android AdMob App ID..."
    # build.gradle.ktsの更新
    sed -i '' "s/ca-app-pub-3940256099942544~3347511713/$ADMOB_APP_ID_ANDROID/g" android/app/build.gradle.kts
    echo "Android configuration updated"
fi

echo "AdMob setup completed!"