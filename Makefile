# Makefile for homog2d library
# see https://github.com/skramm/homog2d

.PHONY: doc test testall install demo check demo_opencv doc_fig nobuild

.PRECIOUS: BUILD/figures_test/%.cpp

CFLAGS += -std=c++14 -Wall -Wextra -Wshadow -Wnon-virtual-dtor -pedantic

ifeq "$(USE_OPENCV)" ""
	USE_OPENCV=N
endif

ifeq ($(USE_OPENCV),Y)
	CFLAGS += -DHOMOG2D_USE_OPENCV
	LDFLAGS += `pkg-config --libs opencv`
endif

ifeq ($(USE_EIGEN),Y)
	CFLAGS += -DHOMOG2D_USE_EIGEN
endif

TEST_FIG_LOC=misc/figures_test
TEST_FIG_SRC=$(wildcard $(TEST_FIG_LOC)/*.code)
TEST_FIG_PNG=$(patsubst $(TEST_FIG_LOC)/%.code,$(TEST_FIG_LOC)/%.png, $(TEST_FIG_SRC))

TEX_FIG_LOC=docs
TEX_FIG_SRC=$(wildcard $(TEX_FIG_LOC)/*.tex)
TEX_FIG_PNG=$(patsubst $(TEX_FIG_LOC)/%.tex,$(TEX_FIG_LOC)/%.png, $(TEX_FIG_SRC))

DOC_IMAGES_LOC:=docs/figures_src
DOC_IMAGES_SRC:=$(wildcard $(DOC_IMAGES_LOC)/*.cpp)
DOC_IMAGES_PNG:=$(patsubst $(DOC_IMAGES_LOC)/%.cpp,$(DOC_IMAGES_LOC)/%.png, $(DOC_IMAGES_SRC))

show:
	@echo "DOC_IMAGES_LOC=$(DOC_IMAGES_LOC)"
	@echo "DOC_IMAGES_SRC=$(DOC_IMAGES_SRC)"
	@echo "DOC_IMAGES_PNG=$(DOC_IMAGES_PNG)"
	@echo "TEX_FIG_LOC=$(TEX_FIG_LOC)"
	@echo "TEX_FIG_SRC=$(TEX_FIG_SRC)"
	@echo "TEX_FIG_PNG=$(TEX_FIG_PNG)"

test: BUILD/homog2d_test nobuild #demo_check
	@echo "Make: run test, build using $(CXX)"
	BUILD/homog2d_test

testall: BUILD/homog2d_test_f BUILD/homog2d_test_d BUILD/homog2d_test_l
	@echo "Make: run testall, build using $(CXX)"
	misc/test_all.sh

# compute code coverage (EXPERIMENTAL !)
cov:
	gcov -m -f -r -i homog2d_test.cpp >gcov_stdout

check:
	cppcheck . --enable=all -DHOMOG2D_INUMTYPE=double --std=c++11 2>cppcheck.log
	xdg-open cppcheck.log


demo_check: misc/demo_check.cpp homog2d.hpp Makefile
	$(CXX) $(CFLAGS) -I. -o demo_check misc/demo_check.cpp

# 2019-11-15: added options for code coverage with gcov
BUILD/homog2d_test: misc/homog2d_test.cpp homog2d.hpp Makefile
	$(CXX) $(CFLAGS) -O2 -o $@ $< $(LDFLAGS)
#	$(CXX) $(CFLAGS) -O0 -g --coverage -o homog2d_test $< $(LDFLAGS)

BUILD/homog2d_test_f: misc/homog2d_test.cpp homog2d.hpp
	$(CXX) $(CFLAGS) -DNUMTYPE=float -O2 -o $@ $< $(LDFLAGS)

BUILD/homog2d_test_d: misc/homog2d_test.cpp homog2d.hpp
	$(CXX) $(CFLAGS) -DNUMTYPE=double -O2 -o $@ $< $(LDFLAGS)

BUILD/homog2d_test_l: misc/homog2d_test.cpp homog2d.hpp
	$(CXX) $(CFLAGS) "-DHOMOG2D_INUMTYPE=long double" "-DNUMTYPE=long double" -O2 -o $@ $< $(LDFLAGS)

ptest1: precision_test1
	./precision_test1

ptest2: precision_test2
	./precision_test2

precision_test1: misc/precision_test_opencv.cpp
	$(CXX) $(CFLAGS) `pkg-config --cflags opencv` -I. -o $@ $< `pkg-config --libs opencv`

precision_test2: misc/precision_test.cpp
	$(CXX) $(CFLAGS) -I. -o $@ $<

#=======================================================================
# Generation of the doc figures from code
.PRECIOUS: docs/figures_src/%

# run the program
$(DOC_IMAGES_LOC)/%.png: $(DOC_IMAGES_LOC)/%
	$<
	mv $(notdir $@) $(DOC_IMAGES_LOC)/

# build the program
$(DOC_IMAGES_LOC)/%: $(DOC_IMAGES_LOC)/%.cpp
	$(CXX) $(CFLAGS) `pkg-config --cflags opencv` -I. -o $@ $< `pkg-config --libs opencv`

doc_fig: $(DOC_IMAGES_PNG)

#=======================================================================
# Generation of the doc figures from LaTeX sources

$(TEX_FIG_LOC)/%.png: $(TEX_FIG_LOC)/%.tex
	cd docs; pdflatex --shell-escape $(notdir $<) 1>latex.stdout 2>latex.stderr

doc_fig_tex: $(TEX_FIG_PNG)

#=======================================================================
# Generation of figures for the test samples
$(TEST_FIG_LOC)/%.png: BUILD/figures_test/%
	@./$<
	@mogrify -flip $<.png

BUILD/figures_test/%: BUILD/figures_test/%.cpp
	@$(CXX) `pkg-config --cflags opencv` -o $@ $< `pkg-config --libs opencv`

BUILD/figures_test/%.cpp: $(TEST_FIG_LOC)/%.code homog2d.hpp $(TEST_FIG_LOC)/header.cpp $(TEST_FIG_LOC)/footer.cpp
	@mkdir -p BUILD/figures_test/
	@cat $(TEST_FIG_LOC)/header.cpp $< $(TEST_FIG_LOC)/footer.cpp >BUILD/figures_test/$(notdir $(basename $<)).cpp

test_fig: $(TEST_FIG_PNG)
#=======================================================================


doc: BUILD/html/index.html
	xdg-open BUILD/html/index.html

# also (re)builds the figures, but requires Opencv AND Latex!
docall: BUILD/html/index.html doc_fig doc_fig_tex
	xdg-open BUILD/html/index.html

BUILD/html/index.html: misc/homog2d_test.cpp homog2d.hpp misc/doxyfile README.md docs/homog2d_manual.md
	@mkdir -p BUILD/html
	doxygen misc/doxyfile 1>BUILD/doxygen.stdout 2>BUILD/doxygen.stderr

install:
	cp homog2d.hpp /usr/local/include

demo: BUILD/demo_opencv
	BUILD/demo_opencv

# this target REQUIRES Opencv
BUILD/demo_opencv: misc/demo_opencv.cpp homog2d.hpp
	$(CXX) $(CFLAGS) `pkg-config --cflags opencv` -I. -o $@ $< `pkg-config --libs opencv`

demo_sdl2: misc/demo_sdl2.cpp homog2d.hpp
	$(CXX) $(CFLAGS) `pkg-config --cflags sdl2` -I. -o demo_sdl2 $< `pkg-config --libs sdl2`

diff:
	git diff | colordiff | aha > diff.html
	xdg-open diff.html

#=================================================================
# The following is used to make sure that some constructions will not build

NOBUILD_SRC_FILES := $(notdir $(wildcard misc/no_build/*.cxx))
NOBUILD_OBJ_FILES := $(patsubst %.cxx, /tmp/%.o, $(NOBUILD_SRC_FILES))

#.PRECIOUS: /tmp/no_build_%.cpp

nobuild: $(NOBUILD_OBJ_FILES)
	@echo "done target $@"

$(NOBUILD_OBJ_FILES): rm_nb

rm_nb:
	-rm BUILD/*.stdout
	-rm BUILD/*.stderr

# assemble file to create a cpp program holding a main()
/tmp/no_build_%.cpp: misc/no_build/no_build_%.cxx
	@cat misc/no_build/header.txt >/tmp/$(notdir $@)
	@cat $< >>/tmp/$(notdir $@)
	@cat misc/no_build/footer.txt >>/tmp/$(notdir $@)

# compile, and return 0 if compilation fails (which is supposed to happen)
/tmp/no_build_%.o: /tmp/no_build_%.cpp
	@echo "Checking build failure of $<" >>BUILD/no_build.stdout
	@echo -e "-----------------------------\nChecking build failure of $(notdir $<)\n" >>BUILD/no_build.stderr
	! $(CXX) -o $@ -c $< 1>>BUILD/no_build.stdout 2>>BUILD/no_build.stderr

#=================================================================
showcase: BUILD/showcase1
	$<
	docs/build_gif.sh

BUILD/showcase1: misc/showcase1.cpp homog2d.hpp
	@$(CXX) `pkg-config --cflags opencv` -o $@ $< `pkg-config --libs opencv`

clean:
	@-rm -r BUILD/*
	@-rm homog2d_test
	@-rm demo_opencv
	@-rm *.gcov
