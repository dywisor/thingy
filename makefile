S := ${.CURDIR}
O := ${.CURDIR}/obj

PHONY =

PHONY += default
default: all

.include "${.CURDIR}/mk/env.mk"
.include "${.CURDIR}/mk/config.mk"
.include "${.CURDIR}/mk/config_bsd.mk"
.include "${.CURDIR}/mk/sed_edit.mk"
.include "${.CURDIR}/mk/file_targets.mk"
.include "${.CURDIR}/mk/bindir_targets.mk"

FORCE:

.PHONY: ${PHONY}
