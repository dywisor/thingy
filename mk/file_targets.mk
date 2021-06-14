BUILD_FILE_TARGETS =

#FILENAME: %: $(SRC)/%
#   ...
# -- works in GNU make only

BUILD_FILE_TARGETS += ashrc
ashrc: ${SRC}/ashrc
	${RUN_SED_EDIT} < '${SRC}/ashrc' > '${@}.make_tmp'
	${SHELL} -n '${@}.make_tmp'
	mv -f -- '${@}.make_tmp' '${@}'


BUILD_FILE_TARGETS += bashrc
bashrc: ${SRC}/bashrc
	${RUN_SED_EDIT} < '${SRC}/bashrc' > '${@}.make_tmp'
#	bash -n '${@}.make_tmp'
	mv -f -- '${@}.make_tmp' '${@}'


BUILD_FILE_TARGETS += gitconfig
gitconfig: ${SRC}/gitconfig
	${RUN_SED_EDIT} < '${SRC}/gitconfig' > '${@}.make_tmp'
	mv -f -- '${@}.make_tmp' '${@}'


BUILD_FILE_TARGETS += vimrc
vimrc: ${SRC}/vimrc
	${RUN_SED_EDIT} < '${SRC}/vimrc' > '${@}.make_tmp'
	mv -f -- '${@}.make_tmp' '${@}'

clean:
	rm -f -- ${BUILD_FILE_TARGETS}

all: ${BUILD_FILE_TARGETS}
