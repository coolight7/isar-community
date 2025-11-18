export http_proxy=http://172.29.48.1:7897
export https_proxy=http://172.29.48.1:7897
export HTTP_PROXY=http://172.29.48.1:7897
export HTTPS_PROXY=http://172.29.48.1:7897

current_dir=$PWD

source ~/.bashrc && rustc --version && cargo --version
echo "ISAR_VERSION=$ISAR_VERSION" >> $GITHUB_ENV

# . ./tool/download_sdk.sh
# export LIBCLANG_PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/lib64
# bash ./tool/build_android.sh
# bash ./tool/build_android.sh armv7
# bash ./tool/build_android.sh x64
# bash ./tool/build_android.sh x86

bash ./tool/build_linux.sh x64

echo "Listing contents of all downloaded artifacts..."
ls -Rlh binaries/
echo "Listing complete."

cd $current_dir

output_dir=$current_dir/output/
rm -rf $output_dir
mkdir -p $output_dir

mkdir -p $output_dir/linux/
cp $current_dir/target/x86_64-unknown-linux-gnu/release/deps/libisar.so $output_dir/linux/
llvm-strip-18 $output_dir/linux/*.so