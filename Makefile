# The directory where all the douml files will be installed, you
# can change it for instance because you don't have root permission
DOUML_LIB = /usr/lib/douml

# The directory where the douml shell script will be installed, you
# can change it for instance because you don't have root permission
DOUML_DIR = /usr/bin

# The directory where the doc will be installed, you
# can change it for instance because you don't have root permission
DOUML_DOC_DIR = /usr/share/doc/douml

# The directory where the doc will be installed, you
# can change it for instance because you don't have root permission
DOUML_LOCALE_DIR = ${DOUML_LIB}/locale

# The directory containing douml.desktop
# The copy is not done if you comment the definition
DOUML_DESKTOP_DIR = /usr/share/applications

# The directories containing the douml icons are
# <DOUML_ICONS_PREFIX_DIR>/<size>x<size>/apps
# The copy is not done if you comment the definition
DOUML_ICONS_PREFIX_DIR = /usr/share/icons/hicolor

# On several Unix systems, the icons used inside the
# menus must be stored inside the pixmaps' directory.
# The copy is done if you uncomment the definition.
DOUML_UNIX_PIXMAPS_DIR = /usr/share/pixmaps

# Using uname to detect the platform
uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')

# If not defined (local install), DoUML will be install into LOCAL_DESTDIR or "./install" directory
# Else (packaging) desktop and executable script are copied into DESTDIR but reference are /
ifndef DESTDIR
  ifndef LOCAL_DESTDIR
    LOCAL_DESTDIR = ${PWD}/install
  endif
  DESTDIR = ${LOCAL_DESTDIR}
endif

QMAKE=qmake

MAKE=make

# using CONFIG variable for 'release' or 'debug' and it's case sensitive!
ifndef CONFIG
  CONFIG=release
endif

SRC_DIRS=\
	src/CppGenerator  \
	src/CppReverse  \
	src/CppRoundtrip  \
	src/IdlGenerator  \
	src/JavaCat  \
	src/JavaGenerator  \
	src/JavaReverse  \
	src/JavaRoundtrip  \
	src/PhpGenerator  \
	src/PhpReverse  \
	src/PlugOutUpgrade  \
	src/ProjectControl  \
	src/ProjectSynchro  \
	src/PythonGenerator  \
	src/RoundtripBody

PLUGOUT_DIRS=genplugouts/BrowserSort  \
	genplugouts/CppUtilities  \
	genplugouts/deploy  \
	genplugouts/FileControl  \
	genplugouts/GlobalChange  \
	genplugouts/gpro  \
	genplugouts/HtmlDoc  \
	genplugouts/import_rose  \
	genplugouts/singleton  \
	genplugouts/sm  \
	genplugouts/uml_projection  \
	genplugouts/usecasewizard  \
	genplugouts/xmi  \
	genplugouts/Xmi2Generator  \
	genplugouts/xmi2import

# the main program (built as a .app bundle on OS X)
MAINPROG=douml

# all the other side programs (NOT built as .app bundle on OS X)
SIDEPROGS= \
	browsersort  \
	cpp_generator  \
	cpp_reverse  \
	cpp_roundtrip  \
	cpp_util  \
	deplcl \
	file_control  \
	ghtml  \
	global_change \
	gpro \
	gxmi \
	gxmi2  \
	idl_generator  \
	ixmi2 \
	java_catalog  \
	java_generator  \
	java_reverse  \
	java_roundtrip  \
	php_generator  \
	php_reverse  \
	python_generator  \
	roundtrip_body  \
	usecasewizard

# all the programs
PROGS = $(MAINPROG) $(SIDEPROGS)

compile:
	( cd src/Libs/L_UniversalModels ; $(QMAKE) -config ${CONFIG} L_UniversalModels.pro; ) || exit 1 ; $(MAKE) -C src/Libs/L_UniversalModels || exit 1
	( cd src ; $(QMAKE) -config ${CONFIG} douml.pro; ) || exit 1 ; $(MAKE) -C src || exit 1
	for i in $(SRC_DIRS); do if [ -d $$i ]; then ( cd $$i; $(QMAKE) -config ${CONFIG}; ) || exit 1 ; $(MAKE) -C $$i || exit 1 ; fi; done
	for i in $(PLUGOUT_DIRS); do if [ -d $$i ]; then ( cd $$i; $(QMAKE) -config ${CONFIG}; ) || exit 1 ; $(MAKE) -C $$i || exit 1 ; fi; done

# Useful for debugging on OS X with XCode, this target will generate appropriate xcode projects files
xcodeprojects: $(QTPROJECTFILES)
	( cd src/Libs/L_UniversalModels ; $(QMAKE) -config ${CONFIG} -spec macx-xcode L_UniversalModels.pro; ) || exit 1
	( cd src ; $(QMAKE) -config ${CONFIG} -spec macx-xcode douml.pro; ) || exit 1
	for i in $(SRC_DIRS); do if [ -d $$i ]; then ( cd $$i; $(QMAKE) -config ${CONFIG} -spec macx-xcode; ) || exit 1 ; fi; done
	for i in $(PLUGOUT_DIRS); do if [ -d $$i ]; then ( cd $$i; $(QMAKE) -config ${CONFIG} -spec macx-xcode; ) || exit 1 ; fi; done

install:
	mkdir -p "$(DESTDIR)$(DOUML_DIR)"
	if test -n "$(DOUML_ICONS_PREFIX_DIR)" ; \
	then \
		for i in 16 32 48 64; do \
			mkdir -p "$(DESTDIR)$(DOUML_ICONS_PREFIX_DIR)/$$i"x"$$i/apps"; \
			cp -p douml.$$i.png "$(DESTDIR)$(DOUML_ICONS_PREFIX_DIR)/$$i"x"$$i/apps/douml.png"; \
		done; \
	fi
	if test -n "$(DOUML_UNIX_PIXMAPS_DIR)"; then \
		mkdir -p "$(DESTDIR)$(DOUML_UNIX_PIXMAPS_DIR)"; \
		cp -f douml.48.png "$(DESTDIR)$(DOUML_UNIX_PIXMAPS_DIR)/douml.png"; \
	fi
	mkdir -p "$(DESTDIR)$(DOUML_LIB)"
	cp -Rp plugouts/empty "$(DESTDIR)$(DOUML_LIB)"
	mkdir -p "$(DESTDIR)$(DOUML_DOC_DIR)"
	mkdir -p "$(DESTDIR)$(DOUML_LOCALE_DIR)"
	cp -p *.lang "$(DESTDIR)$(DOUML_LOCALE_DIR)"
# If on Darwin/Mac OS X, we are building a .dmg for deployment of a .app bundle
ifeq ($(uname_S),Darwin)
# First we copy the douml.app bundle directory that only contains the douml executable
	cp -pR bin/$(MAINPROG).app "$(DESTDIR)$(DOUML_LIB)"
# We then copy all the other side programs (executables built with qt no app bundle option)
# inside the bundle's Contents/MacOS subfolder.
	for i in $(SIDEPROGS); do cp -p bin/$$i "$(DESTDIR)$(DOUML_LIB)/$(MAINPROG).app/Contents/MacOS" ; done
# We also copy the douml icon for OS X in the Resources subfolder
	mkdir -p "$(DESTDIR)$(DOUML_LIB)/$(MAINPROG).app/Contents/Resources/"
	cp ./douml.icns "$(DESTDIR)$(DOUML_LIB)/$(MAINPROG).app/Contents/Resources/"
# We run the macdeployqt tool to add the appropriate frameworks and
# configuration files to the bundle and to create a .dmg disk image file.
ifeq ($(CONFIG),debug)
# In debug mode we don't create the dmg file. Instead we tell macdeployqt to add the debug versions of
# the Qt frameworks, and we edit the bundle's Info.plist to set the environment variable
# DYLD_IMAGE_SUFFIX=_debug so that the app will load the debug versions of Qt libraries
	/usr/libexec/PlistBuddy -c "Add :LS_Environment dict" "$(DESTDIR)$(DOUML_LIB)/$(MAINPROG).app/Contents/Info.plist"
	/usr/libexec/PlistBuddy -c "Add :LS_Environment:DYLD_IMAGE_SUFFIX string '_debug'" "$(DESTDIR)$(DOUML_LIB)/$(MAINPROG).app/Contents/Info.plist"
	macdeployqt "$(DESTDIR)$(DOUML_LIB)/$(MAINPROG).app" -verbose=2 -use-debug-libs \
		$(patsubst %,-executable="$(DESTDIR)$(DOUML_LIB)/$(MAINPROG).app/Contents/MacOS/%",$(SIDEPROGS))
else
	macdeployqt "$(DESTDIR)$(DOUML_LIB)/$(MAINPROG).app" -verbose=2 -dmg \
		$(patsubst %,-executable="$(DESTDIR)$(DOUML_LIB)/$(MAINPROG).app/Contents/MacOS/%",$(SIDEPROGS))
endif
else
	for i in $(PROGS); do cp -p bin/$$i "$(DESTDIR)$(DOUML_LIB)" ; done
endif
	echo "#!/bin/sh" >$(DESTDIR)$(DOUML_DIR)/douml
	echo "PATH=$(LOCAL_DESTDIR)$(DOUML_LIB):$$"PATH >>$(DESTDIR)$(DOUML_DIR)/douml
	echo "DOUML_LIB_DIR=$(LOCAL_DESTDIR)$(DOUML_LIB)" >>$(DESTDIR)$(DOUML_DIR)/douml
	echo "export PATH" >>$(DESTDIR)$(DOUML_DIR)/douml
	echo "export DOUML_LIB_DIR" >>$(DESTDIR)$(DOUML_DIR)/douml
	echo "exec $(LOCAL_DESTDIR)$(DOUML_LIB)/douml \"$$"@"\"" >>$(DESTDIR)$(DOUML_DIR)/douml
	chmod +x "$(DESTDIR)$(DOUML_DIR)/douml"
	if test -n "$(DOUML_DESKTOP_DIR)" ; \
	then \
		mkdir -p "$(DESTDIR)$(DOUML_DESKTOP_DIR)" ; \
		echo "[Desktop Entry]" > "$(DESTDIR)$(DOUML_DESKTOP_DIR)/douml.desktop" ; \
		echo "Encoding=UTF-8" >> "$(DESTDIR)$(DOUML_DESKTOP_DIR)/douml.desktop" ; \
		echo "Name=DoUML" >> "$(DESTDIR)$(DOUML_DESKTOP_DIR)/douml.desktop" ; \
		echo "Type=Application" >> "$(DESTDIR)$(DOUML_DESKTOP_DIR)/douml.desktop" ; \
		echo "GenericName=Free UML 2 modeler" >> "$(DESTDIR)$(DOUML_DESKTOP_DIR)/douml.desktop" ; \
		echo "Comment=Free UML 2 modeler" >> "$(DESTDIR)$(DOUML_DESKTOP_DIR)/douml.desktop" ; \
		echo "Exec=$(LOCAL_DESTDIR)$(DOUML_DIR)/douml" >> "$(DESTDIR)$(DOUML_DESKTOP_DIR)/douml.desktop" ; \
		echo "TryExec=douml" >> "$(DESTDIR)$(DOUML_DESKTOP_DIR)/douml.desktop" ; \
		echo "Icon=douml" >> "$(DESTDIR)$(DOUML_DESKTOP_DIR)/douml.desktop" ; \
		echo "Categories=Development;Building;GUIDesigner;IDE;Documentation;" >> "$(DESTDIR)$(DOUML_DESKTOP_DIR)/douml.desktop" ; \
	fi

uninstall:
	rm -rf $(DESTDIR)$(DOUML_LIB) $(DESTDIR)$(DOUML_DIR)/douml
	for i in 16 32 48 64; do \
		rm -f "$(DESTDIR)$(DOUML_ICONS_PREFIX_DIR)/$$i"x"$$i/apps/douml.png"; \
	done
	rm -f "$(DESTDIR)$(DOUML_UNIX_PIXMAPS_DIR)/douml.png"
	rm -f "$(DESTDIR)$(DOUML_DESKTOP_DIR)/douml.desktop"

clean:
	for i in $(SRC_DIRS) $(PLUGOUT_DIRS); do if [ -d $$i ]; then (cd $$i; $(QMAKE) -config ${CONFIG}; $(MAKE) clean; rm -f Makefile; ) || exit 1 ; fi; done
	( cd src ; $(QMAKE) -config ${CONFIG} douml.pro; ) || exit 1 ; (cd src; $(MAKE) clean; rm -f Makefile; ) || exit 1
	( cd src/Libs/L_UniversalModels ; $(QMAKE) -config ${CONFIG} L_UniversalModels.pro; ) || exit 1 ; (cd src/Libs/L_UniversalModels; $(MAKE) clean; rm -f Makefile; ) || exit 1
# If on Darwin/Mac OS X we are removing the douml .app bundle
ifeq ($(uname_S),Darwin)
	rm -rf "bin/$(MAINPROG).app"
	for i in $(SIDEPROGS); do rm -f bin/$$i; done
else
	for i in $(PROGS); do rm -f bin/$$i; done
endif
	rm -rf bin/moc_release bin/moc_debug
	rm -rf bin/obj_release bin/obj_debug

.PHONY: compile clean install uninstall
