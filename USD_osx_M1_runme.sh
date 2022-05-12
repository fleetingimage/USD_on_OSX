
# Following instructions from:
#  https://simo.virokannas.fi/2022/04/compiling-pixars-usd-natively-on-apple-m1/

# With modifications (no conda needed)

# Install XCode, and run it at least once.
# Install CMake from cmake.org.

# Create destination and work directories. (Need sudo for /opt)
#### USER CUSTOMIZATION HERE

export DIST=/opt/USD
export WORK=~/third_party

#### END OF USER CUSTOMIZATION


export PATH=$PATH:/Applications/CMake.app/Contents/bin

# User issues password...
sudo mkdir -p $DIST
sudo chmod 777 $DIST

# Create download/build location
mkdir -p $WORK

# Create a venv in the distribution directory for later activation.
cd $DIST

# Create pip with requirements:
python3 -m venv venv_arm64-Darwin
source venv_arm64-Darwin/bin/activate
pip install --upgrade pip
pip install PyOpenGL PySide6 numpy

# Hack to modify virtual environment to simplify patches to USD:
pushd venv_arm64-Darwin/bin
ln -s pyside6-uic pyside2-uic
cd ../lib/python3.8/site-packages
ln -s PySide6 PySide2
popd

cd $WORK

# Get USD
git clone https://github.com/PixarAnimationStudios/USD.git

# Patch USD
cd USD
curl -O https://simo.virokannas.fi/wp-content/uploads/2022/04/usdview_pyside6_patches.zip
unzip usdview_pyside6_patches.zip

patch -p1 < usdview_pyside6_to_2.patch 
patch -p1  < usdview_stage_pyside6_to_2.patch 

# Third change as a patch...
patch -p0 <<'EOF'
diff --git a/build_scripts/build_usd.py b/build_scripts/build_usd.py
index b00449266..05b15e50c 100644
--- build_scripts/build_usd.py
+++ build_scripts/build_usd.py
@@ -424,6 +424,7 @@ def RunCMake(context, force, extraArgs = None):
             '-DCMAKE_INSTALL_PREFIX="{instDir}" '
             '-DCMAKE_PREFIX_PATH="{depsInstDir}" '
             '-DCMAKE_BUILD_TYPE={config} '
+            '-DPXR_PY_UNDEFINED_DYNAMIC_LOOKUP=ON '
             '{osx_rpath} '
             '{generator} '
             '{toolset} '
EOF

# Build USD
python build_scripts/build_usd.py --build-args TBB,"arch=arm64" --python $DIST

# Build activator:

echo "source $DIST/venv_arm64-Darwin/bin/activate" > $DIST/activate
echo "export PATH=\$PATH:$DIST/bin" >> $DIST/activate
echo "export PYTHONPATH=\$PYTHONPATH:$DIST/lib/python" >> $DIST/activate

echo "To use USD, open a shell and type: source $DIST/activate"

# Test it out...
# curl -O https://graphics.pixar.com/usd/files/Kitchen_set.zip
# unzip Kitchen_set.zip
# export PATH=$PATH:$DIST/bin
# export PYTHONPATH=$PYTHONPATH:$DIST/lib/python
#
# usdview Kitchen_set/Kitchen_set.usd

