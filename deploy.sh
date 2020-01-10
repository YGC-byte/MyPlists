#!/bin/bash
echo "================================================================"
echo "请确保ipa已在当前目录下"
echo "注意⚠️: 一次只能部署一种环境，请不要放多个ipa到当前目录下"
echo "================================================================"

read -p "部署Release环境: y/n" env
if [[ -n "$env" ]]; then
	 if [[ "$env"="y" ]]; then
	 	echo "默认为Release环境"
	 else
	 	echo "默认为Debug环境"
	 fi
else
	echo "默认为Release环境"
	env="y"
fi

read -p "版本号: " version
if [[ -n "$version" ]]; then
	echo "${version}"
else
	exit 1
fi

read -p "应用的BundleId(不填写则默认不修改): " bundleId
if [[ -n "$bundleId" ]]; then
	echo "${bundleId}"
else
  if [[ "$env" = "y" ]]; then
  	  bundleId=plistbuddy -c 'Print :items:0:metadata:bundle-identifier' ./manifest.plist
  	else
  	  bundleId=plistbuddy -c 'Print :items:0:metadata:bundle-identifier' ./manifest_test.plist
  fi
fi

# bundle-identifier

read -p "部署版本描述信息: " commit_message
if [[ -n "$commit_message" ]]; then

else
	commit_message="🚀update~"
fi

key=""

#建立软链接 直接使用`PlistBuddy`
ln -s /usr/libexec/PlistBuddy /usr/local/bin/PlistBuddy


if [[ "$env" = "y" ]]; then
 
  plistbuddy -c 'Set :items:0:metadata:bundle-version "$version"' ./manifest.plist
  plistbuddy -c 'Set :items:0:metadata:bundle-identifier string "$bundleId"' ./manifest.plist
  sudo cp -f ./*ipa  /Library/WebServer/Documents/app/ipa/release/app.ipa

else

  plistbuddy -c 'Set :items:0:metadata:bundle-version "$version"' ./manifest_test.plist
  plistbuddy -c 'Set :items:0:metadata:bundle-identifier string "$bundleId"' ./manifest_test.plist
  sudo cp -f ./*ipa  /Library/WebServer/Documents/app/ipa/debug/app.ipa

fi

echo "🎉🎉🎉 部署成功！！！"

rm -rf *.ipa #移除记录 

echo "🚀🚀🚀提交代码"

git add .
git commit -am  "$commit_message"
git push origin master 
