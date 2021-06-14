BINDIR_TARGETS += ssh-wrapper-links
PHONY += ssh-wrapper-links
ssh-wrapper-links:
	${PYTHON3} '${PRJ_BINDIR}/_ssh_wrapper_names.py' | \
		xargs -r -I '{NAME}' -- ln -f -s -- ./_ssh_wrapper.pl '${PRJ_BINDIR}/{NAME}'


PHONY += bindir
bindir: ${BINDIR_TARGETS}
