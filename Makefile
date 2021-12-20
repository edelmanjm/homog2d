# Makefile for homog2d library
# see https://github.com/skramm/homog2d

.PHONY: doc test testall install demo check demo_opencv doc_fig nobuild showcase speed_test

.PRECIOUS: BUILD/figures_test/%.cpp BUILD/%.png BUILD/no_build/%.cpp BUILD/showcase/%
.SECONDARY:

#Disabling the built-in rules is done by writing an empty rule for .SUFFIXES:
.SUFFIXES:


SHELL=bash
CXXFLAGS += -std=c++14 -Wall -Wextra -Wshadow -Wnon-virtual-dtor -pedantic


#=======================================================================
# makefile options

ifeq "$(USE_OPENCV)" ""
	USE_OPENCV=N
endif

ifeq ($(USE_OPENCV),Y)
	CXXFLAGS += -DHOMOG2D_USE_OPENCV
	LDFLAGS += `pkg-config --libs opencv`
endif

ifeq ($(USE_EIGEN),Y)
	CXXFLAGS += -DHOMOG2D_USE_EIGEN
endif

ifeq ($(DEBUG),Y)
	CXXFLAGS += -g
endif

#=======================================================================
# general/common targets

check:
	@cppcheck --version
	cppcheck . -iBUILD -imisc/figures_test -imisc/figures_src --enable=all -DHOMOG2D_INUMTYPE=double --std=c++11 2>cppcheck.log
	xdg-open cppcheck.log

doc: BUILD/html/index.html
	xdg-open BUILD/html/index.html

# also (re)builds the figures, but requires Opencv AND Latex!
docall: BUILD/html/index.html doc_fig doc_fig_tex
	xdg-open BUILD/html/index.html

install:
	cp homog2d.hpp /usr/local/include

demo: BUILD/demo_opencv
	BUILD/demo_opencv

clean:
	@-rm -r BUILD/*
	@-rm homog2d_test
	@-rm demo_opencv
	@-rm *.gcov

# just a debug target...
show:
	@echo "DOC_IMAGES_LOC=$(DOC_IMAGES_LOC)"
	@echo "DOC_IMAGES_SRC=$(DOC_IMAGES_SRC)"
	@echo "DOC_IMAGES_PNG=$(DOC_IMAGES_PNG)"
	@echo "TEX_FIG_LOC=$(TEX_FIG_LOC)"
	@echo "TEX_FIG_SRC=$(TEX_FIG_SRC)"
	@echo "TEX_FIG_PNG=$(TEX_FIG_PNG)"
	@echo "SHOWCASE_SRC=$(SHOWCASE_SRC)"
	@echo "SHOWCASE_BIN=$(SHOWCASE_BIN)"
	@echo "SHOWCASE_PNG=$(SHOWCASE_PNG)"
	@echo "SHOWCASE_GIF=$(SHOWCASE_GIF)"
	@echo "TEST_FIG_SRC=$(TEST_FIG_SRC)"
	@echo "TEST_FIG_PNG=$(TEST_FIG_PNG)"
	@echo "NOBUILD_SRC_FILES=$(NOBUILD_SRC_FILES)"
	@echo "NOBUILD_OBJ_FILES=$(NOBUILD_OBJ_FILES)"

#=======================================================================
# testing targets

variants=test_SY test_SN
#BUILD/homog2d_test_SY BUILD/homog2d_test_SN

.PHONY: newtests_before

newtests_before: CXXFLAGS += -Wno-unused-but-set-variable

newtests: newtests_before
	@if [ -f BUILD/homog2d_test.stderr ]; then echo "start test">BUILD/homog2d_test.stderr; fi
	$(foreach variant,$(variants),$(MAKE) $(variant) 2>>BUILD/homog2d_test.stderr;)

test: test_SY test_SN nobuild
	@echo "Make: run test, build using $(CXX)"
	BUILD/homog2d_test_SY
	BUILD/homog2d_test_SN

test_SY: CXXFLAGS += -DHOMOG2D_OPTIMIZE_SPEED

test_SY: BUILD/homog2d_test_SY

test_SN: BUILD/homog2d_test_SN


BUILD/homog2d_test_SY BUILD/homog2d_test_SN: misc/homog2d_test.cpp homog2d.hpp Makefile
	$(CXX) $(CXXFLAGS) -O2 -o $@ $< $(LDFLAGS) 2>>BUILD/homog2d_test.stderr


testall: test BUILD/homog2d_test_f BUILD/homog2d_test_d BUILD/homog2d_test_l speed_test_b
	@echo "Make: run testall, build using $(CXX)"
	misc/test_all.sh

BUILD/homog2d_test_f: misc/homog2d_test.cpp homog2d.hpp
	$(CXX) $(CXXFLAGS) -DNUMTYPE=float -O2 -o $@ $< $(LDFLAGS) 2>BUILD/homog2d_test_f.stderr

BUILD/homog2d_test_d: misc/homog2d_test.cpp homog2d.hpp
	$(CXX) $(CXXFLAGS) -DNUMTYPE=double -O2 -o $@ $< $(LDFLAGS) 2>BUILD/homog2d_test_d.stderr

BUILD/homog2d_test_l: misc/homog2d_test.cpp homog2d.hpp
	$(CXX) $(CXXFLAGS) "-DHOMOG2D_INUMTYPE=long double" "-DNUMTYPE=long double" -O2 -o $@ $< $(LDFLAGS) 2>BUILD/homog2d_test_l.stderr

# to be removed
demo_check: misc/demo_check.cpp homog2d.hpp Makefile
	$(CXX) $(CXXFLAGS) -I. -o demo_check misc/demo_check.cpp


#=======================================================================
# speed test
speed_test: speed_test_b
	@time BUILD/ellipse_speed_test_SYCN
	@time BUILD/ellipse_speed_test_SY
	@time BUILD/ellipse_speed_test_SN

speed_test_b: BUILD/ellipse_speed_test_SYCN BUILD/ellipse_speed_test_SY BUILD/ellipse_speed_test_SN

BUILD/ellipse_speed_test_SY: CXXFLAGS += -DHOMOG2D_OPTIMIZE_SPEED

# No Checking
BUILD/ellipse_speed_test_SYCN: CXXFLAGS += -DHOMOG2D_OPTIMIZE_SPEED -DHOMOG2D_NOCHECKS

BUILD/ellipse_speed_test_SY: misc/ellipse_speed_test.cpp homog2d.hpp Makefile
	$(CXX) $(CXXFLAGS) -O2 -o $@ $< $(LDFLAGS) 2>BUILD/ellipse_speed_test_SY.stderr

BUILD/ellipse_speed_test_SYCN: misc/ellipse_speed_test.cpp homog2d.hpp Makefile
	$(CXX) $(CXXFLAGS) -O2 -o $@ $< $(LDFLAGS) 2>BUILD/ellipse_speed_test_SY.stderr

BUILD/ellipse_speed_test_SN: misc/ellipse_speed_test.cpp homog2d.hpp Makefile
	$(CXX) $(CXXFLAGS) -O2 -o $@ $< $(LDFLAGS) 2>BUILD/ellipse_speed_test_NY.stderr


#=======================================================================
# Generation of the doc figures from code

DOC_IMAGES_LOC:=misc/figures_src/src
DOC_IMAGES_SRC:=$(wildcard $(DOC_IMAGES_LOC)/*.cpp)
DOC_IMAGES_PNG:=$(patsubst $(DOC_IMAGES_LOC)/%.cpp,BUILD/img/png/%.png, $(DOC_IMAGES_SRC))

.PRECIOUS: BUILD/img/png/%

# run the program => builds the png image
BUILD/img/png/%.png: BUILD/img/png/bin/%
	cd BUILD/img/png; bin/$(notdir $<)

# build the program
BUILD/img/png/bin/%: $(DOC_IMAGES_LOC)/%.cpp homog2d.hpp
	@mkdir -p BUILD/img/png/bin
	$(CXX) $(CXXFLAGS) `pkg-config --cflags opencv` -I. -o $@ $< `pkg-config --libs opencv`

doc_fig: $(DOC_IMAGES_PNG)

#=======================================================================
# Generation of the doc figures from LaTeX sources

TEX_FIG_LOC=misc/figures_src/latex
TEX_FIG_SRC=$(wildcard $(TEX_FIG_LOC)/*.tex)
TEX_FIG_PNG=$(patsubst $(TEX_FIG_LOC)/%.tex,BUILD/fig_latex/%.png, $(TEX_FIG_SRC))

BUILD/fig_latex/%.tex: $(TEX_FIG_LOC)/%.tex
	@mkdir -p BUILD/fig_latex/
	@cp $< $@

BUILD/fig_latex/%.png: BUILD/fig_latex/%.tex
	cd BUILD/fig_latex; pdflatex --shell-escape $(notdir $<) 1>latex.stdout 2>latex.stderr

doc_fig_tex: $(TEX_FIG_PNG)

#=======================================================================
# Generation of figures for the test samples

TEST_FIG_LOC=misc/figures_test
TEST_FIG_SRC=$(wildcard $(TEST_FIG_LOC)/*.code)
TEST_FIG_PNG=$(patsubst $(TEST_FIG_LOC)/%.code,BUILD/figures_test/%.png, $(TEST_FIG_SRC))

test_fig: $(TEST_FIG_PNG)

# run the program to produce image, and flip it vertically (so vertical axis is going up)
BUILD/figures_test/%.png: BUILD/figures_test/%
	@echo "Running $<"
	@./$<
	@mogrify -flip $<.png

# build the program from source
BUILD/figures_test/%: BUILD/figures_test/%.cpp
	@echo "Building $<"
	@$(CXX) `pkg-config --cflags opencv` -o $@ $< `pkg-config --libs opencv`

# build source file
BUILD/figures_test/frect_%.cpp: $(TEST_FIG_LOC)/frect_%.code homog2d.hpp $(TEST_FIG_LOC)/t_header.cxx $(TEST_FIG_LOC)/t_footer_frect_1.cxx
	@echo "generating $<"
	@mkdir -p BUILD/figures_test/
	@cat $(TEST_FIG_LOC)/t_header.cxx $< $(TEST_FIG_LOC)/t_footer_frect_1.cxx >BUILD/figures_test/$(notdir $(basename $<)).cpp

# build source file
BUILD/figures_test/polyline_%.cpp: $(TEST_FIG_LOC)/polyline_%.code homog2d.hpp $(TEST_FIG_LOC)/t_header.cxx $(TEST_FIG_LOC)/t_footer_polyline_1.cxx
	@echo "generating $<"
	@mkdir -p BUILD/figures_test/
	@cat $(TEST_FIG_LOC)/t_header.cxx $< $(TEST_FIG_LOC)/t_footer_polyline_1.cxx >BUILD/figures_test/$(notdir $(basename $<)).cpp

#=======================================================================

DOC_MD_PAGES=$(wildcard docs/*.md)
BUILD/html/index.html: misc/homog2d_test.cpp homog2d.hpp misc/doxyfile README.md $(DOC_MD_PAGES)
	@mkdir -p BUILD/html
	doxygen misc/doxyfile 1>BUILD/doxygen.stdout 2>BUILD/doxygen.stderr


# this target REQUIRES Opencv
BUILD/demo_opencv: misc/demo_opencv.cpp homog2d.hpp
	$(CXX) $(CXXFLAGS) `pkg-config --cflags opencv` -I. -o $@ $< `pkg-config --libs opencv`

demo_sdl2: misc/demo_sdl2.cpp homog2d.hpp
	$(CXX) $(CXXFLAGS) `pkg-config --cflags sdl2` -I. -o demo_sdl2 $< `pkg-config --libs sdl2`

diff:
	git diff | colordiff | aha > diff.html
	xdg-open diff.html

#=================================================================
# The following is used to make sure that some constructions will not build

NOBUILD_SRC_FILES := $(notdir $(wildcard misc/no_build/*.cxx))
NOBUILD_OBJ_FILES := $(patsubst %.cxx,BUILD/no_build/%.o, $(NOBUILD_SRC_FILES))


nobuild: $(NOBUILD_OBJ_FILES) #BUILD/no_build.stdout
	@echo "done target $@"

$(NOBUILD_OBJ_FILES): rm_nb

rm_nb:
	@if [ -e BUILD/no_build.stdout ]; then rm BUILD/no_build.stdout; fi
	@if [ -e BUILD/no_build.stderr ]; then rm BUILD/no_build.stderr; fi


# assemble file to create a cpp program holding a main()
BUILD/no_build/no_build_%.cpp: misc/no_build/no_build_%.cxx
	@mkdir -p BUILD/no_build/
	@cat misc/no_build/header.txt >BUILD/no_build/$(notdir $@)
	@cat $< >>BUILD/no_build/$(notdir $@)
	@cat misc/no_build/footer.txt >>BUILD/no_build/$(notdir $@)

# compile, and return 0 if compilation fails (which is supposed to happen)
BUILD/no_build/no_build_%.o: BUILD/no_build/no_build_%.cpp
	@echo "Checking build failure of $<" >>BUILD/no_build.stdout
	@echo -e "-----------------------------\nChecking build failure of $(notdir $<)\n" >>BUILD/no_build.stderr
	@! $(CXX) -o $@ -c $< 1>>BUILD/no_build.stdout 2>>BUILD/no_build.stderr

#=================================================================
# SHOWCASE: generates gif images of some situations

SHOWCASE_SRC_LOC=misc/showcase
SHOWCASE_SRC=$(wildcard $(SHOWCASE_SRC_LOC)/showcase*.cpp)
SHOWCASE_BIN=$(patsubst $(SHOWCASE_SRC_LOC)/showcase%.cpp,BUILD/showcase/showcase%, $(SHOWCASE_SRC))
SHOWCASE_GIF=$(patsubst $(SHOWCASE_SRC_LOC)/showcase%.cpp,BUILD/showcase/showcase%.gif, $(SHOWCASE_SRC))

# compile program that will generate the set of png files
BUILD/showcase/showcase%: $(SHOWCASE_SRC_LOC)/showcase%.cpp homog2d.hpp
	@mkdir -p BUILD/showcase/
	$(CXX) `pkg-config --cflags opencv` -o $@ $< `pkg-config --libs opencv`
	cd BUILD/showcase/; ./$(notdir $@)

showcase_b: $(SHOWCASE_BIN)
	@echo "done target $@"

showcase: showcase_b
	misc/build_gif.sh
	@echo "done target $@"

#------------------------------------------------------------------------------
.PHONY: dtest1

dtest1: BUILD/dtest1_f.png

DTEST1_BIN:=BUILD/dtest1_f BUILD/dtest1_d BUILD/dtest1_l

DTEST1_DATA=$(patsubst %,%.data,$(DTEST1_BIN) )

BUILD/dtest1_f.png: $(DTEST1_DATA) misc/dtest1.plt
	misc/dtest1.plt


showdtest1:
	@echo "DTEST1_BIN=$(DTEST1_BIN)"
	@echo "DTEST1_DATA=$(DTEST1_DATA)"

BUILD/dtest1_%.data:BUILD/dtest1_%
	@echo "#" > $@
	./$< .0001 >> $@
	./$< .001 >> $@
	./$< .01 >> $@
	./$< .1 >> $@
	./$< 1 >> $@
	./$< 10 >> $@
	./$< 100 >> $@
	./$< 1000 >> $@
	./$< 10000 >> $@
	./$< 100000 >> $@

BUILD/dtest1_f: CXXFLAGS+=-DHOMOG2D_INUMTYPE=float
BUILD/dtest1_d: CXXFLAGS+=-DHOMOG2D_INUMTYPE=double
BUILD/dtest1_l: CXXFLAGS+="-DHOMOG2D_INUMTYPE=long double"

$(DTEST1_BIN): misc/dtest1.cpp Makefile homog2d.hpp
	$(CXX) $(CXXFLAGS) -o $@ $<


#=================================================================
